#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use gamepads::{Button, Gamepads};
use macroquad::prelude::*;

use crate::game::App;

/// Keys that are tracked for input.
const TRACKED_KEYS: [KeyCode; 9] = [
    KeyCode::Up,
    KeyCode::Down,
    KeyCode::Left,
    KeyCode::Right,
    KeyCode::Escape,
    KeyCode::Space,
    KeyCode::Enter,
    KeyCode::Space,
    KeyCode::Tab,
];

pub enum InputCommand {
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
    /// Tool key - triangle / Y on controller, tab on keyboard.
    Tool,
}

pub fn handle_input(app: &mut App) {
    for key in TRACKED_KEYS {
        if is_key_pressed(key) {
            app.handle_key_press(match &key {
                KeyCode::Up => InputCommand::Up,
                KeyCode::Down => InputCommand::Down,
                KeyCode::Left => InputCommand::Left,
                KeyCode::Right => InputCommand::Right,
                KeyCode::Escape => InputCommand::Menu,
                KeyCode::Space => InputCommand::Select,
                KeyCode::Enter => InputCommand::Select,
                KeyCode::Tab => InputCommand::Tool,
                _ => {
                    println!("Unhandled key: {:?}", key);
                    continue;
                }
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
                    Button::DPadUp => InputCommand::Up,
                    Button::DPadDown => InputCommand::Down,
                    Button::DPadLeft => InputCommand::Left,
                    Button::DPadRight => InputCommand::Right,
                    Button::RightCenterCluster => InputCommand::Menu,
                    Button::ActionDown => InputCommand::Select,
                    Button::ActionUp => InputCommand::Tool,
                    b @ _ => {
                        println!("Unhandled button: {:?}", b);
                        continue;
                    }
                });

                println!("Just pressed button: {:?}", button);
                // gamepads.rumble(gamepad.id(), 1000, 0, 1.0, 0.0);
            }
        }
        // println!("Left thumbstick: {:?}", gamepad.left_stick());
        // println!("Right thumbstick: {:?}", gamepad.right_stick());
    }
}
