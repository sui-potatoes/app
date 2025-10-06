// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// ! Defines all application settings. Settings are stored in the local config
// ! file, and loaded on application startup.

use std::fmt::Display;

use macroquad::miniquad::window::set_window_size;
use quad_storage::STORAGE;
use serde::{Deserialize, Serialize};

use crate::sound::Background;

const SETTINGS_KEY: &str = "settings";

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Settings {
    pub main_menu_volume: u8,
    pub effects_volume: u8,
    pub window_size: WindowSize,
    pub fullscreen: bool,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum WindowSize {
    Small,
    Medium,
    Large,
}

impl Settings {
    pub fn load() -> Self {
        STORAGE
            .lock()
            .unwrap()
            .get(SETTINGS_KEY)
            .and_then(|s| serde_json::from_str(&s).ok())
            .unwrap_or_default()
    }

    pub fn save(&self) {
        self.update();

        STORAGE
            .lock()
            .unwrap()
            .set(SETTINGS_KEY, &serde_json::to_string(self).unwrap());
    }

    fn update(&self) {
        match self.window_size {
            WindowSize::Small => set_window_size(750, 750),
            WindowSize::Medium => set_window_size(1000, 1000),
            WindowSize::Large => set_window_size(1250, 1250),
        }

        // update main menu volume
        Background::Main.set_volume(self.main_menu_volume as f32 / 100.0);
    }
}

impl Default for Settings {
    fn default() -> Self {
        Self {
            main_menu_volume: 70,
            effects_volume: 70,
            window_size: WindowSize::Medium,
            fullscreen: false,
        }
    }
}

impl Default for WindowSize {
    fn default() -> Self {
        Self::Medium
    }
}

impl Into<i32> for WindowSize {
    fn into(self) -> i32 {
        match self {
            WindowSize::Small => 750,
            WindowSize::Medium => 1000,
            WindowSize::Large => 1250,
        }
    }
}

impl Display for WindowSize {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            WindowSize::Small => write!(f, "Small"),
            WindowSize::Medium => write!(f, "Medium"),
            WindowSize::Large => write!(f, "Large"),
        }
    }
}
