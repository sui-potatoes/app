#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use fastcrypto::traits::KeyPair;
use macroquad::prelude::*;
use fastcrypto::ed25519::Ed25519PublicKey;
use sui_types::base_types::SuiAddress;
use std::path::Path;
use std::sync::mpsc::{Sender, channel};
use sui_sdk::SuiClient;
use tokio::runtime::Runtime;

mod client;
mod draw;
mod game;
mod input;
mod move_types;
mod zklogin;

use crate::client::CommanderClient;
use crate::draw::Draw;
use crate::game::App;
use crate::game::Message as AppMessage;
use crate::move_types::{Preset, Recruit, Replay};

/// Messages sent from the tokio runtime to the Application.
pub enum Message {
    Presets(Vec<Preset>),
    Recruits(Vec<Recruit>),
    Replays(Vec<Replay>),
    Address(SuiAddress),
    Text(String),
}

#[macroquad::main("Commander")]
async fn main() -> Result<(), anyhow::Error> {
    // Setup channel to receive data from the tokio task
    let (tx, rx) = channel::<Message>();
    let (tx_app, rx_app) = channel::<AppMessage>();

    // Spawn tokio runtime in a background thread
    std::thread::spawn(move || {
        let rt = Runtime::new().unwrap();
        rt.block_on(async move {
            let client = CommanderClient::new().await.unwrap();
            println!("Sui testnet version: {}", client.as_inner().api_version());

            let recruits = client.get_recruits().await.unwrap();
            let _ = tx.send(Message::Recruits(recruits));

            let presets = client.get_presets().await.unwrap();
            let _ = tx.send(Message::Presets(presets));

            let replays = client.get_replays().await.unwrap();
            let _ = tx.send(Message::Replays(replays));

            startup_action(&tx, client.as_inner())
                .await
                .unwrap_or_else(|e| eprintln!("Error: {}", e));

            loop {
                if let Ok(msg) = rx_app.try_recv() {
                    match msg {
                        AppMessage::PrepareLogin => {
                            // let skp =SuiKeyPair::Ed25519(Ed25519KeyPair::generate(&mut StdRng::from_seed([0; 32])));
                            // let jwt_randomness = BigUint::from_bytes_be(&[0; 32]).to_string();
                            // let mut eph_pk_bytes = vec![0x00];
                            // eph_pk_bytes.extend(skp.public().as_ref());
                            // let kp_bigint = BigUint::from_bytes_be(&eph_pk_bytes).to_string();
                            // let nonce = get_nonce(&eph_pk_bytes, max_epoch, &jwt_randomness).unwrap();

                            let keypair = fastcrypto::ed25519::Ed25519KeyPair::generate(
                                &mut ::rand::thread_rng(),
                            );
                            let public_key = keypair.public();

                            let address = login_action(&tx, public_key)
                                .await
                                .map(|e| Some(e))
                                .unwrap_or_else(|e| {
                                    eprintln!("Error: {}", e);
                                    None
                                });

                            if let Some(address) = address {
                                let _ = tx.send(Message::Address(address));
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

    app.textures.insert("background".to_string(), tile_texture);

    // Main game loop
    loop {
        clear_background(LIGHTGRAY);
        input::handle_input(&mut app);
        app.draw();

        if let Ok(msg) = rx.try_recv() {
            app.update_from_message(msg);
        }

        next_frame().await;
    }
}

/// Handles the login process.
async fn login_action(
    tx: &Sender<Message>,
    public_key: &Ed25519PublicKey,
) -> Result<SuiAddress, anyhow::Error> {
    // fetch nonce from zklogin and send it to the game
    let nonce = zklogin::get_nonce(public_key).await.unwrap();

    println!("Nonce: {:?}", nonce);

    zklogin::open_auth_page(&nonce.nonce);

    println!("Preparing login");

    let jwt = if let Ok(Some(code)) = zklogin::start_auth_listener(&tx).await {
        println!("Login code: {}", code);
        if let Ok(jwt) = zklogin::get_jwt(code).await.map_err(|err| {
            println!("Error getting JWT: {:?}", err);
            err
        }) {
            jwt
        } else {
            return Err(anyhow::anyhow!("Error getting JWT"));
        }
    } else {
        return Err(anyhow::anyhow!("Error getting login code"));
    };

    println!("JWT: {}", jwt);

    let zkp = if let Ok(zkp) = zklogin::get_zkp(jwt, nonce, public_key)
        .await
        .map_err(|err| {
            println!("Error getting ZKP: {:?}", err);
            err
        }) {
        zkp
    } else {
        return Err(anyhow::anyhow!("Error getting ZKP"));
    };

    println!("ZKP: {:?}", zkp);

    let address = SuiAddress::try_from_unpadded(&zkp).unwrap();
    println!("Address: {}", address);

    Ok(address)
}

async fn startup_action(tx: &Sender<Message>, client: &SuiClient) -> Result<(), anyhow::Error> {
    // Send a message back to the game
    let _ = tx.send(Message::Text(format!(
        "Sui testnet version: {}",
        client.api_version()
    )));

    Ok(())
}
