#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{
    path::Path,
    str::FromStr,
    sync::{
        Arc, Mutex,
        mpsc::{Receiver, Sender, channel},
    },
};

use gamepads::Gamepads;
use macroquad::{miniquad::conf::Icon, prelude::*};
use quad_storage::STORAGE;
use serde::{Deserialize, Serialize};

use sui_crypto::ed25519::Ed25519PrivateKey;
use sui_rpc::{
    Client,
    field::FieldMask,
    proto::sui::rpc::v2beta2::{ListOwnedObjectsRequest, Object},
};
use sui_sdk_types::{
    Address, Ed25519PublicKey, ObjectDigest, ObjectId, ObjectReference, Version, ZkLoginInputs,
};
use tokio::runtime::Runtime;

mod config;
mod draw;
mod errors;
mod game;
mod input;
mod move_types;
mod tx;
mod zklogin;

use crate::{
    config::{COMMANDER_OBJ, PRESET_STRUCT_TAG, RECRUIT_STRUCT_TAG, REPLAY_STRUCT_TAG},
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
    global_load_texture(Texture::Main, "assets/main-screen.png").await;

    // Main game loop
    loop {
        gamepads.poll();
        clear_background(LIGHTGRAY);
        draw_texture_ex(
            TEXTURES.lock().unwrap().get(&Texture::Main).unwrap(),
            0.0,
            0.0,
            WHITE,
            DrawTextureParams {
                dest_size: Some(Vec2::new(screen_width(), screen_height())),
                ..Default::default()
            },
        );

        input::handle_input(&mut app);
        input::handle_gamepad_input(&mut app, &mut gamepads);

        app.draw();

        if let Ok(msg) = rx.try_recv() {
            app.update_from_message(msg);
        }

        next_frame().await;
    }
}

const GRPC_URL: &str =
    "https://fullnode.testnet.sui.io/sui.rpc.v2beta2.LiveDataService/SimulateTransaction";

fn tokio_runtime(tx: Sender<Message>, rx_app: Receiver<AppMessage>, state: Arc<Mutex<State>>) {
    let default_provider = rustls::crypto::aws_lc_rs::default_provider();
    rustls::crypto::CryptoProvider::install_default(default_provider).unwrap();

    let rt = Runtime::new().unwrap();
    let prev_session = STORAGE.lock().unwrap().get(SESSION_KEY);

    rt.block_on(async move {
        let mut client = Client::new(GRPC_URL).unwrap();
        let mut tx_runner: Option<TxRunner> = None;

        if let Some(prev_session) = prev_session {
            if let Ok(session) = serde_json::from_str::<Session>(&prev_session) {
                state.lock().unwrap().address = Some(session.address);
                tx_runner = Some(TxRunner::new(
                    Ed25519PrivateKey::from_pem(&session.keypair).unwrap(),
                    session.zkp,
                    session.max_epoch,
                    client.clone(),
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
                        state.lock().unwrap().address = None;
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
                            state.lock().unwrap().address = Some(new_address);
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
                        if let Some(tx_runner) = tx_runner.as_mut() {
                            let _effects = match tx_runner.test_tx().await {
                                Ok(effects) => effects,
                                Err(err) => {
                                    eprintln!("Error: {}", err);
                                    continue;
                                }
                            };
                        }
                    }
                    AppMessage::FetchPresets => {
                        let mut state = state.lock().unwrap();
                        state.presets = client
                            .live_data_client()
                            .list_owned_objects(ListOwnedObjectsRequest {
                                owner: Some(COMMANDER_OBJ.to_string()),
                                object_type: Some(PRESET_STRUCT_TAG.to_string()),
                                read_mask: Some(FieldMask {
                                    paths: vec!["contents".to_string(), "digest".to_string()],
                                }),
                                ..Default::default()
                            })
                            .await
                            .unwrap()
                            .get_ref()
                            .objects
                            .iter()
                            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
                            .collect::<Vec<WithRef<Preset>>>();

                        tx.send(Message::StateUpdated).unwrap();
                    }
                    AppMessage::FetchRecruits => {
                        let mut state = state.lock().unwrap();

                        state.recruits = client
                            .live_data_client()
                            .list_owned_objects(ListOwnedObjectsRequest {
                                owner: state.address.map(|a| a.to_string()),
                                object_type: Some(RECRUIT_STRUCT_TAG.to_string()),
                                page_size: Some(100),
                                read_mask: Some(FieldMask {
                                    paths: vec!["contents".to_string(), "digest".to_string()],
                                }),
                                ..Default::default()
                            })
                            .await
                            .unwrap()
                            .get_ref()
                            .objects
                            .iter()
                            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
                            .collect::<Vec<WithRef<Recruit>>>();

                        tx.send(Message::StateUpdated).unwrap();
                    }
                    AppMessage::FetchReplays => {
                        let mut state = state.lock().unwrap();
                        state.replays = client
                            .live_data_client()
                            .list_owned_objects(ListOwnedObjectsRequest {
                                owner: state.address.map(|a| a.to_string()),
                                object_type: Some(REPLAY_STRUCT_TAG.to_string()),
                                page_size: Some(100),
                                read_mask: Some(FieldMask {
                                    paths: vec!["contents".to_string(), "digest".to_string()],
                                }),
                                ..Default::default()
                            })
                            .await
                            .unwrap()
                            .get_ref()
                            .objects
                            .iter()
                            .map(|obj| WithRef::from_rpc_object(obj).unwrap())
                            .collect::<Vec<WithRef<Replay>>>();

                        tx.send(Message::StateUpdated).unwrap();
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

async fn global_load_texture(name: Texture, path: &str) {
    // Load the texture from the assets folder in the root of the crate.
    let root = env!("CARGO_MANIFEST_DIR");
    let path = Path::new(root).join(path);
    let path = path.to_str().unwrap();
    let tile_texture = load_texture(path).await.unwrap();

    TEXTURES.lock().unwrap().insert(name, tile_texture);
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
        }
    }
}
