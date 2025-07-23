#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::game::Game;
use macroquad::prelude::*;

/// Keys that are tracked for input.
const TRACKED_KEYS: [KeyCode; 8] = [
    KeyCode::Up,
    KeyCode::Down,
    KeyCode::Left,
    KeyCode::Right,
    KeyCode::Escape,
    KeyCode::Space,
    KeyCode::Enter,
    KeyCode::Space,
];

pub fn handle_input(game: &mut Game) {
    for key in TRACKED_KEYS {
        if is_key_pressed(key) {
            game.handle_key_press(key);
        }
    }
}
