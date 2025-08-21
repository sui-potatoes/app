#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{
    str::FromStr,
    sync::{
        Arc, Mutex,
        mpsc::{Receiver, Sender, channel},
    },
    time::Duration,
};

use gamepads::Gamepads;
use macroquad::{miniquad::conf::Icon, prelude::*};
use quad_storage::STORAGE;
use serde::{Deserialize, Serialize};

use sui_crypto::ed25519::Ed25519PrivateKey;
use sui_rpc::{Client, proto::sui::rpc::v2beta2::Object};
use sui_sdk_types::{
    Address, Ed25519PublicKey, ObjectDigest, ObjectId, ObjectReference, Version, ZkLoginInputs,
};
use tokio::runtime::Runtime;

mod config;
mod draw;
mod errors;
mod game;
mod input;
mod sui;
mod types;
mod zklogin;

use crate::{
    draw::{ASSETS, AssetStore},
    game::{App, Message as AppMessage},
    sui::{fetch::GameClient, tx::TxExecutor},
    types::{Game, Preset, Recruit, Replay},
};

/// Messages sent from the tokio runtime to the Application.
pub enum Message {
    Text(String),
    StateUpdated,
    GameStarted,
}

const SESSION_KEY: &str = "session";

#[derive(Serialize, Deserialize)]
pub struct Session {
    pub address: Address,
    pub keypair: String,
    pub zkp: ZkLoginInputs,
    pub max_epoch: u64,
}

#[derive(Serialize, Deserialize)]
/// The state of the application, consists of fetched data from the server.
/// Passed into the `App` during initialization and filled in + updated in event
/// handlers.
pub struct State {
    pub address: Option<Address>,
    pub presets: Vec<WithRef<Preset>>,
    pub recruits: Vec<WithRef<Recruit>>,
    pub replays: Vec<WithRef<Replay>>,
    pub active_game: Option<Game>,
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
    let mut asset_store = AssetStore::new();
    asset_store.load_all().await;

    ASSETS
        .with(|assets| assets.set(Arc::new(asset_store)))
        .unwrap();

    // Main game loop.
    loop {
        gamepads.poll();
        clear_background(LIGHTGRAY);

        input::handle_input(&mut app);
        input::handle_gamepad_input(&mut app, &mut gamepads);

        app.tick();

        if let Ok(msg) = rx.try_recv() {
            app.update_from_message(msg);
        }

        // Flush the draw registry (draws everything) before the next frame.
        draw::flush_draw_registry();

        next_frame().await;
    }
}

const GRPC_URL: &str =
    "https://fullnode.testnet.sui.io/sui.rpc.v2beta2.LiveDataService/SimulateTransaction";

fn tokio_runtime(tx: Sender<Message>, rx_app: Receiver<AppMessage>, state_arc: Arc<Mutex<State>>) {
    let default_provider = rustls::crypto::aws_lc_rs::default_provider();
    rustls::crypto::CryptoProvider::install_default(default_provider).unwrap();

    let rt = Runtime::new().unwrap();
    let prev_session = STORAGE.lock().unwrap().get(SESSION_KEY);

    rt.block_on(async move {
        let client = Client::new(GRPC_URL).unwrap();
        let mut game_client = GameClient::new(client.clone());
        let mut tx_runner: Option<TxExecutor> = None;

        if let Some(prev_session) = prev_session {
            if let Ok(session) = serde_json::from_str::<Session>(&prev_session) {
                state_arc.lock().unwrap().address = Some(session.address);
                tx_runner = Some(TxExecutor::new(
                    Ed25519PrivateKey::from_pem(&session.keypair).unwrap(),
                    session.zkp,
                    session.max_epoch,
                    client,
                ));

                tx.send(Message::StateUpdated).unwrap();
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
                        state_arc.lock().unwrap().address = None;
                        tx.send(Message::StateUpdated).unwrap();
                    }
                    AppMessage::PrepareLogin => {
                        let keypair = Ed25519PrivateKey::generate(&mut ::rand::thread_rng());
                        let public_key = keypair.public_key();
                        let login_res = login_action(&public_key)
                            .await
                            .map(|e| Some(e))
                            .unwrap_or_else(|e| {
                                eprintln!("Error: {}", e);
                                None
                            });

                        if let Some((new_address, zkp, max_epoch)) = login_res {
                            state_arc.lock().unwrap().address = Some(new_address);
                            tx.send(Message::StateUpdated).unwrap();

                            STORAGE.lock().unwrap().set(
                                SESSION_KEY,
                                &serde_json::to_string(&Session {
                                    address: new_address,
                                    keypair: keypair.to_pem().unwrap(),
                                    zkp,
                                    max_epoch,
                                })
                                .unwrap(),
                            );
                        }
                    }
                    AppMessage::StartGame => {
                        // Fetch presets if they are not already fetched.
                        let mut state = state_arc.lock().unwrap();
                        if state.presets.is_empty() {
                            state.presets = game_client.list_presets().await;
                        }

                        if let Some(game) = STORAGE.lock().unwrap().get("active_game") {
                            let game = serde_json::from_str::<Game>(game.as_ref()).unwrap();
                            state.active_game = Some(game);
                            println!("Game already started");
                            tx.send(Message::GameStarted).unwrap();
                            continue;
                        }

                        if state.active_game.is_some() {
                            continue;
                        }

                        if let Some(tx_runner) = tx_runner.as_mut() {
                            match tx_runner.start_game(state.presets[0].clone()).await {
                                Ok(game_id) => {
                                    println!("https://suiscan.xyz/testnet/object/{}", game_id);
                                    std::thread::sleep(Duration::from_secs(5));

                                    let game = game_client
                                        .get_game(game_id)
                                        .await
                                        .unwrap_or_else(|e| panic!("Error: {}", e));

                                    state.active_game = Some(game);
                                    STORAGE.lock().unwrap().set(
                                        "active_game",
                                        &serde_json::to_string(&state.active_game).unwrap(),
                                    );

                                    tx.send(Message::StateUpdated).unwrap();
                                }
                                Err(err) => {
                                    eprintln!("Error: {}", err);
                                    continue;
                                }
                            }
                        }
                    }
                    AppMessage::FetchPresets => {
                        #[cfg(feature = "cache")]
                        if let Some(state) = STORAGE.lock().unwrap().get("presets") {
                            println!("fetching presets from cache");
                            let presets: Vec<WithRef<Preset>> =
                                serde_json::from_str(state.as_ref()).unwrap();
                            state_arc.lock().unwrap().presets = presets;
                            tx.send(Message::StateUpdated).unwrap();
                            continue;
                        }

                        let mut state = state_arc.lock().unwrap();

                        state.presets = game_client.list_presets().await;

                        STORAGE
                            .lock()
                            .unwrap()
                            .set("presets", &serde_json::to_string(&state.presets).unwrap());

                        tx.send(Message::StateUpdated).unwrap();
                    }
                    AppMessage::FetchRecruits => {
                        #[cfg(feature = "cache")]
                        if let Some(state) = STORAGE.lock().unwrap().get("recruits") {
                            println!("fetching recruits from cache");
                            let recruits: Vec<WithRef<Recruit>> =
                                serde_json::from_str(state.as_ref()).unwrap();
                            state_arc.lock().unwrap().recruits = recruits;
                            tx.send(Message::StateUpdated).unwrap();
                            continue;
                        }

                        let mut state = state_arc.lock().unwrap();

                        if let Some(address) = state.address {
                            state.recruits = game_client.list_recruits(address).await;
                            STORAGE
                                .lock()
                                .unwrap()
                                .set("recruits", &serde_json::to_string(&state.recruits).unwrap());

                            tx.send(Message::StateUpdated).unwrap();
                        } else {
                            panic!("No address found");
                        }
                    }
                    AppMessage::FetchReplays => {
                        #[cfg(feature = "cache")]
                        if let Some(state) = STORAGE.lock().unwrap().get("replays") {
                            println!("fetching replays from cache");
                            let replays: Vec<WithRef<Replay>> =
                                serde_json::from_str(state.as_ref()).unwrap();
                            state_arc.lock().unwrap().replays = replays;
                            tx.send(Message::StateUpdated).unwrap();
                            continue;
                        }

                        let mut state = state_arc.lock().unwrap();

                        if let Some(address) = state.address {
                            state.replays = game_client.list_replays(address).await;

                            STORAGE
                                .lock()
                                .unwrap()
                                .set("replays", &serde_json::to_string(&state.replays).unwrap());

                            tx.send(Message::StateUpdated).unwrap();
                        } else {
                            panic!("No address found");
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
) -> Result<(Address, ZkLoginInputs, u64), anyhow::Error> {
    // fetch nonce from zklogin and send it to the game
    let nonce = zklogin::get_nonce(public_key).await.unwrap();
    let max_epoch = nonce.max_epoch;

    zklogin::open_auth_page(&nonce.nonce);

    let jwt = match zklogin::start_auth_listener().await {
        Ok(Some(code)) => zklogin::get_jwt(code).await.unwrap(),
        Ok(None) => return Err(anyhow::anyhow!("Error getting login code")),
        Err(e) => return Err(anyhow::anyhow!("Error getting login code: {}", e)),
    };

    let zkp = zklogin::get_zkp(jwt, nonce, public_key).await?;
    let address = zklogin::zkp_to_address(&zkp)?;

    Ok((address, zkp, max_epoch))
}

// === Utils ===

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WithRef<T> {
    pub object_ref: ObjectReference,
    pub data: T,
}

impl<'de, T> WithRef<T> {
    pub fn from_rpc_object(obj: &'de Object) -> Result<Self, anyhow::Error>
    where
        T: Deserialize<'de>,
    {
        Ok(WithRef {
            data: bcs::from_bytes(
                obj.contents
                    .as_ref()
                    .ok_or(anyhow::anyhow!("No contents"))?
                    .value(),
            )?,
            object_ref: ObjectReference::new(
                ObjectId::from_str(&obj.object_id()).unwrap(),
                Version::from(obj.version()),
                ObjectDigest::from_base58(&obj.digest()).unwrap(),
            ),
        })
    }
}

impl Default for State {
    fn default() -> Self {
        Self {
            address: None,
            presets: vec![],
            recruits: vec![],
            replays: vec![],
            active_game: None,
        }
    }
}
