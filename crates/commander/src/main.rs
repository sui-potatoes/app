#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use macroquad::prelude::*;
use std::sync::mpsc::{Sender, channel};
use sui_sdk::SuiClient;
use tokio::runtime::Runtime;

mod client;
mod move_types;

use crate::client::CommanderClient;
use crate::move_types::{Preset, Recruit};
enum Message {
    Presets(Vec<Preset>),
    Recruits(Vec<Recruit>),
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

            startup_action(&tx, client.as_inner())
                .await
                .unwrap_or_else(|e| eprintln!("Error: {}", e));

            loop {}
        });
    });

    let mut saved_recruits = Vec::<Recruit>::new();
    let mut stored_presets = Vec::<Preset>::new();

    // Main game loop
    loop {
        clear_background(LIGHTGRAY);

        if let Ok(msg) = rx.try_recv() {
            match msg {
                Message::Recruits(mut recruits) => saved_recruits.append(&mut recruits),
                Message::Presets(mut presets) => stored_presets.append(&mut presets),
                _ => {}
            }
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
