#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use fastcrypto::{
    ed25519::{Ed25519KeyPair, Ed25519PublicKey},
    traits::KeyPair,
};
use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;
use gamepads::Gamepads;
use macroquad::prelude::*;
use quad_storage::STORAGE;
use serde::{Deserialize, Serialize};
use std::{
    path::Path,
    sync::mpsc::{Sender, channel},
};
use sui_sdk::SuiClient;
use sui_types::base_types::SuiAddress;
use tokio::runtime::Runtime;

mod client;
mod config;
mod draw;
mod errors;
mod game;
mod input;
mod move_types;
mod tx;
mod zklogin;

use crate::{
    client::{CommanderClient, WithRef},
    draw::Draw,
    game::{App, Message as AppMessage},
    move_types::{Preset, Recruit, Replay},
    tx::TxRunner,
};

/// Messages sent from the tokio runtime to the Application.
pub enum Message {
    Presets(Vec<WithRef<Preset>>),
    Recruits(Vec<WithRef<Recruit>>),
    Replays(Vec<WithRef<Replay>>),
    Address(SuiAddress),
    Text(String),
}

const SESSION_KEY: &str = "session";

#[derive(Serialize, Deserialize)]
pub struct Session {
    pub address: SuiAddress,
    pub keypair: Ed25519KeyPair,
    pub zkp: ZkLoginInputs,
    pub max_epoch: u64,
}

#[macroquad::main("Commander")]
async fn main() -> Result<(), anyhow::Error> {
    // Setup channel to receive data from the tokio task
    let (tx, rx) = channel::<Message>();
    let (tx_app, rx_app) = channel::<AppMessage>();
    let mut tx_runner = None;
    let mut address = None;
    let prev_session = STORAGE.lock().unwrap().get(SESSION_KEY);

    // Spawn tokio runtime in a background thread
    std::thread::spawn(move || {
        let rt = Runtime::new().unwrap();
        rt.block_on(async move {
            let client: CommanderClient = CommanderClient::new().await.unwrap();
            println!("Sui testnet version: {}", client.as_inner().api_version());

            startup_action(&tx, client.as_inner())
                .await
                .unwrap_or_else(|e| eprintln!("Error: {}", e));

            if let Some(prev_session) = prev_session {
                if let Ok(mut session) = serde_json::from_str::<Session>(&prev_session) {
                    let _ = tx.send(Message::Address(session.address));
                    let zkp = session.zkp.init().unwrap();
                    address.replace(session.address);
                    tx_runner = Some(TxRunner::new(
                        session.keypair,
                        zkp,
                        session.max_epoch,
                        client.as_inner().clone(),
                    ));
                } else {
                    STORAGE.lock().unwrap().remove(SESSION_KEY);
                }
            }

            loop {
                if let Ok(msg) = rx_app.try_recv() {
                    match msg {
                        AppMessage::Logout => {
                            STORAGE.lock().unwrap().remove(SESSION_KEY);
                            tx_runner = None;
                        }
                        AppMessage::PrepareLogin => {
                            let keypair = Ed25519KeyPair::generate(&mut ::rand::thread_rng());
                            let public_key = keypair.public();
                            let login_res = login_action(public_key)
                                .await
                                .map(|e| Some(e))
                                .unwrap_or_else(|e| {
                                    eprintln!("Error: {}", e);
                                    None
                                });

                            if let Some((new_address, zkp, max_epoch)) = login_res {
                                let _ = tx.send(Message::Address(new_address));
                                tx_runner = Some(TxRunner::new(
                                    keypair.copy(),
                                    zkp.clone(),
                                    max_epoch,
                                    client.as_inner().clone(),
                                ));
                                address.replace(new_address);
                                STORAGE.lock().unwrap().set(
                                    SESSION_KEY,
                                    &serde_json::to_string(&Session {
                                        address: new_address,
                                        keypair,
                                        zkp,
                                        max_epoch,
                                    })
                                    .unwrap(),
                                );
                            }
                        }
                        AppMessage::StartGame => {
                            // measure time between start and end of tx
                            let start = std::time::Instant::now();
                            if let Some(tx_runner) = &mut tx_runner {
                                tx_runner.test_tx().await.unwrap();
                                let end = std::time::Instant::now();
                                println!("Test tx executed in {:?}", end.duration_since(start));
                            } else {
                                println!("No tx runner");
                            }
                        }
                        AppMessage::FetchPresets => {
                            if let Some(_) = address {
                                let presets = client.get_presets().await.unwrap();
                                tx.send(Message::Presets(presets)).unwrap();
                            } else {
                                eprintln!("Not logged in");
                            }
                        }
                        AppMessage::FetchRecruits => {
                            if let Some(address) = address {
                                let recruits = client.get_recruits(address).await.unwrap();
                                tx.send(Message::Recruits(recruits)).unwrap();
                            } else {
                                eprintln!("Not logged in");
                            }
                        }
                        AppMessage::FetchReplays => {
                            if let Some(address) = address {
                                let replays = client.get_replays(address).await.unwrap();
                                tx.send(Message::Replays(replays)).unwrap();
                            } else {
                                eprintln!("Not logged in");
                            }
                        }
                    }
                }
            }
        });
    });

    // Load the texture from the assets folder in the root of the crate.
    let root = env!("CARGO_MANIFEST_DIR");
    let path = Path::new(root).join("assets/texture-sand.png");
    let path = path.to_str().unwrap();
    let tile_texture = load_texture(path).await.unwrap();

    let mut app = App::new(tx_app);
    let mut gamepads = Gamepads::new();

    app.textures.insert("background".to_string(), tile_texture);

    // let gamepads = get_connected_gamepads();
    // dbg!(&gamepads);

    // Main game loop
    loop {
        gamepads.poll();
        clear_background(LIGHTGRAY);
        input::handle_input(&mut app);
        input::handle_gamepad_input(&mut app, &mut gamepads);

        app.draw();

        if let Ok(msg) = rx.try_recv() {
            app.update_from_message(msg);
        }

        next_frame().await;
    }
}

/// Handles the login process.
async fn login_action(
    public_key: &Ed25519PublicKey,
) -> Result<(SuiAddress, ZkLoginInputs, u64), anyhow::Error> {
    // fetch nonce from zklogin and send it to the game
    let nonce = zklogin::get_nonce(public_key).await.unwrap();
    let max_epoch = nonce.max_epoch;

    zklogin::open_auth_page(&nonce.nonce);

    let jwt = if let Ok(Some(code)) = zklogin::start_auth_listener().await {
        zklogin::get_jwt(code)
            .await
            .map_err(|e| anyhow::anyhow!("Error getting JWT: {}", e))?
    } else {
        return Err(anyhow::anyhow!("Error getting login code"));
    };

    let zkp = zklogin::get_zkp(jwt, nonce, public_key)
        .await
        .map_err(|e| anyhow::anyhow!("Error getting ZKP: {}", e))?;

    let address = SuiAddress::try_from_unpadded(&zkp)?;
    Ok((address, zkp, max_epoch))
}

async fn startup_action(tx: &Sender<Message>, client: &SuiClient) -> Result<(), anyhow::Error> {
    // Send a message back to the game
    let _ = tx.send(Message::Text(format!(
        "Sui testnet version: {}",
        client.api_version()
    )));

    Ok(())
}
