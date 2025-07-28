#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{
    path::Path,
    sync::{
        Arc, Mutex,
        mpsc::{Receiver, Sender, channel},
    },
};

use fastcrypto::{
    ed25519::{Ed25519KeyPair, Ed25519PublicKey},
    traits::KeyPair,
};
use fastcrypto_zkp::bn254::zk_login::ZkLoginInputs;
use gamepads::Gamepads;
use macroquad::{miniquad::conf::Icon, prelude::*};
use quad_storage::STORAGE;
use serde::{Deserialize, Serialize};
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
    draw::{Draw, TEXTURES, Texture},
    game::{App, Message as AppMessage},
    move_types::{Preset, Recruit, Replay},
    tx::TxRunner,
};

/// Messages sent from the tokio runtime to the Application.
pub enum Message {
    Text(String),
    StateUpdated,
}

const SESSION_KEY: &str = "session";

#[derive(Serialize, Deserialize)]
pub struct Session {
    pub address: SuiAddress,
    pub keypair: Ed25519KeyPair,
    pub zkp: ZkLoginInputs,
    pub max_epoch: u64,
}

#[derive(Serialize, Deserialize)]
/// The state of the application, consists of fetched data from the server.
/// Passed into the `App` during initialization and filled in + updated in event
/// handlers.
pub struct State {
    pub address: Option<SuiAddress>,
    pub presets: Vec<WithRef<Preset>>,
    pub recruits: Vec<WithRef<Recruit>>,
    pub replays: Vec<WithRef<Replay>>,
}

/// Configure Macroquad on start.
fn window_conf() -> macroquad::window::Conf {
    Conf {
        window_title: "Commander".to_owned(),
        window_width: 1000,
        window_height: 1000,
        fullscreen: false,
        window_resizable: true,
        icon: Some(Icon::miniquad_logo()),
        ..Default::default()
    }
}

#[macroquad::main(window_conf)]
async fn main() -> Result<(), anyhow::Error> {
    // Setup channel to receive data from the tokio task
    let (tx, rx) = channel::<Message>();
    let (tx_app, rx_app) = channel::<AppMessage>();
    let state = Arc::new(Mutex::new(State::default()));

    // Create an app and pass the reference to the state.
    let mut app = App::new(tx_app, state.clone());

    // Spawn tokio runtime in a background thread.
    std::thread::spawn(move || tokio_runtime(tx, rx_app, state));

    // Initialize gamepad tracker.
    let mut gamepads = Gamepads::new();

    // Register global textures before the game loop starts.
    global_load_texture(Texture::Background, "assets/texture-sand.png").await;
    global_load_texture(Texture::Unit, "assets/unit-soldier.png").await;

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

fn tokio_runtime(tx: Sender<Message>, rx_app: Receiver<AppMessage>, state: Arc<Mutex<State>>) {
    let rt = Runtime::new().unwrap();
    let mut tx_runner = None;
    let prev_session = STORAGE.lock().unwrap().get(SESSION_KEY);

    rt.block_on(async move {
        let client: CommanderClient = CommanderClient::new().await.unwrap();
        println!("Sui testnet version: {}", client.as_inner().api_version());

        if let Some(prev_session) = prev_session {
            if let Ok(mut session) = serde_json::from_str::<Session>(&prev_session) {
                let zkp = session.zkp.init().unwrap();
                state.lock().unwrap().address = Some(session.address);
                tx.send(Message::StateUpdated).unwrap();
                tx_runner = Some(TxRunner::new(
                    session.keypair,
                    zkp,
                    session.max_epoch,
                    client.as_inner().clone(),
                ));
            } else {
                // Clean up session storage if data cannot be deserialized (very
                // likely due to data format changes).
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
                            state.lock().unwrap().address = Some(new_address);
                            tx_runner = Some(TxRunner::new(
                                keypair.copy(),
                                zkp.clone(),
                                max_epoch,
                                client.as_inner().clone(),
                            ));
                            state.lock().unwrap().address = Some(new_address);
                            tx.send(Message::StateUpdated).unwrap();
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
                        match &mut tx_runner {
                            Some(tx_runner) => {
                                let start = std::time::Instant::now();
                                tx_runner.test_tx().await.unwrap();
                                let end = std::time::Instant::now();
                                println!("Test tx executed in {:?}", end.duration_since(start));
                            }
                            None => println!("No tx runner"),
                        }
                    }
                    AppMessage::FetchPresets => match client.get_presets().await {
                        Ok(presets) => {
                            state.lock().unwrap().presets = presets;
                            tx.send(Message::StateUpdated).unwrap();
                        }
                        Err(e) => eprintln!("Error fetching presets. Something went wrong: {}", e),
                    },
                    AppMessage::FetchRecruits => {
                        let mut state = state.lock().unwrap();

                        if let Some(address) = state.address {
                            match client.get_recruits(address).await {
                                Ok(recruits) => {
                                    state.recruits = recruits;
                                    tx.send(Message::StateUpdated).unwrap();
                                }
                                Err(e) => eprintln!(
                                    "Error fetching recruits. Something went wrong: {}",
                                    e
                                ),
                            }
                        }
                    }
                    AppMessage::FetchReplays => {
                        let mut state = state.lock().unwrap();

                        if let Some(address) = state.address {
                            match client.get_replays(address).await {
                                Ok(replays) => {
                                    state.replays = replays;
                                    tx.send(Message::StateUpdated).unwrap();
                                }
                                Err(e) => {
                                    eprintln!("Error fetching replays. Something went wrong: {}", e)
                                }
                            }
                        }
                    }
                }
            }
        }
    });
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

async fn global_load_texture(name: Texture, path: &str) {
    // Load the texture from the assets folder in the root of the crate.
    let root = env!("CARGO_MANIFEST_DIR");
    let path = Path::new(root).join(path);
    let path = path.to_str().unwrap();
    let tile_texture = load_texture(path).await.unwrap();

    TEXTURES.lock().unwrap().insert(name, tile_texture);
}

// === Impls ===

impl Default for State {
    fn default() -> Self {
        Self {
            address: None,
            presets: vec![],
            recruits: vec![],
            replays: vec![],
        }
    }
}
