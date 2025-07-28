#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::game::App;
use macroquad::prelude::*;
use gamepads::{Button, Gamepads};

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

pub enum Command {
    /// Directional key Up (both menu and in-game).
    Up,
    /// Directional key Down (both menu and in-game).
    Down,
    /// Directional key Left (both menu and in-game).
    Left,
    /// Directional key Right (both menu and in-game).
    Right,
    /// Return / Back (both menu and in-game).
    Menu,
    /// Select / Start (both menu and in-game).
    Select,
}

pub fn handle_input(app: &mut App) {
    for key in TRACKED_KEYS {
        if is_key_pressed(key) {
            app.handle_key_press(match &key {
                KeyCode::Up => Command::Up,
                KeyCode::Down => Command::Down,
                KeyCode::Left => Command::Left,
                KeyCode::Right => Command::Right,
                KeyCode::Escape => Command::Menu,
                KeyCode::Space => Command::Select,
                KeyCode::Enter => Command::Select,
                _ => continue,
            });
        }
    }
}

pub fn handle_gamepad_input(app: &mut App, gamepads: &mut Gamepads) {
    for gamepad in gamepads.all() {
        // println!("Gamepad id: {:?}", gamepad.id());
        for button in gamepad.all_currently_pressed() {
            if gamepad.is_just_pressed(button) {
                app.handle_key_press(match &button {
                    Button::DPadUp => Command::Up,
                    Button::DPadDown => Command::Down,
                    Button::DPadLeft => Command::Left,
                    Button::DPadRight => Command::Right,
                    Button::RightCenterCluster => Command::Menu,
                    Button::ActionDown => Command::Select,
                    b @ _ => {
                        println!("Unhandled button: {:?}", b);
                        continue;
                    },
                });

                println!("Just pressed button: {:?}", button);
                // gamepads.rumble(gamepad.id(), 1000, 0, 1.0, 0.0);
            }

        }
        // println!("Left thumbstick: {:?}", gamepad.left_stick());
        // println!("Right thumbstick: {:?}", gamepad.right_stick());
    }
}
