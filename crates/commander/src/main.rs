#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use macroquad::prelude::*;
use std::path::Path;
use std::sync::mpsc::{Sender, channel};
use sui_sdk::SuiClient;
use tokio::runtime::Runtime;

mod client;
mod draw;
mod game;
mod input;
mod move_types;

use crate::client::CommanderClient;
use crate::game::Game;
use crate::move_types::{Preset, Recruit, Replay};
enum Message {
    Presets(Vec<Preset>),
    Recruits(Vec<Recruit>),
    Replays(Vec<Replay>),
    Text(String),
}

#[macroquad::main("Commander")]
async fn main() -> Result<(), anyhow::Error> {
    // Setup channel to receive data from the tokio task
    let (tx, rx) = channel::<Message>();

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

            loop {}
        });
    });

    // Load the texture from the assets folder in the root of the crate.
    let root = env!("CARGO_MANIFEST_DIR");
    let path = Path::new(root).join("assets/texture-sand.png");
    let path = path.to_str().unwrap();
    let tile_texture = load_texture(path).await.unwrap();

    let mut game = Game::new();

    game.textures.insert("background".to_string(), tile_texture);

    // Main game loop
    loop {
        clear_background(LIGHTGRAY);
        input::handle_input(&mut game);
        game.draw();

        if let Ok(msg) = rx.try_recv() {
            game.update_from_message(msg);
        }

        next_frame().await;
    }
}

async fn startup_action(tx: &Sender<Message>, client: &SuiClient) -> Result<(), anyhow::Error> {
    // Send a message back to the game
    let _ = tx.send(Message::Text(format!(
        "Sui testnet version: {}",
        client.api_version()
    )));

    Ok(())
}
