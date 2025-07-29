// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use macroquad::prelude::*;
use sui_sdk_types::Address;

use crate::{
    WithRef,
    draw::{Draw, FONTS},
    move_types::{Preset, Recruit, Replay},
};

const SELECTED_COLOR: Color = WHITE;
const TEXT_COLOR: Color = LIGHTGRAY;
const FONT_SIZE: f32 = 24.0;
const TITLE_FONT_SIZE: f32 = 40.0;

/// Draws the menu based on the items, tracks the currently selected item. Reacts
/// on keyboard input to navigate the menu.
pub struct Menu<Item: MenuItem> {
    pub title: Option<String>,
    /// The items in the menu.
    pub items: Vec<Item>,
    /// The index of the currently selected item.
    pub selected_item: usize,
    /// Size of the window (how many to show at once).
    pub window: Option<usize>,
}

#[derive(Debug, Clone, Copy)]
pub enum MainMenuItem {
    StartGame,
    Login,
    Address(Address),
    Replays,
    Presets,
    Recruits,
    Settings,
    Quit,
}

#[derive(Debug, Clone)]
pub enum ReplayMenuItem {
    Replay(WithRef<Replay>),
    Back,
}

#[derive(Debug, Clone)]
pub enum RecruitMenuItem {
    Recruit(WithRef<Recruit>),
    Back,
}

#[derive(Debug, Clone)]
pub enum PresetMenuItem {
    Preset(WithRef<Preset>),
    Back,
}

#[derive(Debug, Clone)]
pub enum SettingsMenuItem {
    WindowSize,
    Logout,
    Back,
}

#[derive(Debug, Clone)]
pub enum WindowSettingsMenuItem {
    SizeSmall,
    SizeMedium,
    SizeLarge,
    Back,
}

pub trait MenuItem: Display {}

impl MenuItem for MainMenuItem {}
impl MenuItem for ReplayMenuItem {}
impl MenuItem for PresetMenuItem {}
impl MenuItem for SettingsMenuItem {}
impl MenuItem for WindowSettingsMenuItem {}
impl MenuItem for RecruitMenuItem {}

// === Menu impls ===

impl Menu<MainMenuItem> {
    pub fn main(address: Option<Address>) -> Self {
        let items = if let Some(_) = address {
            vec![
                MainMenuItem::StartGame,
                MainMenuItem::Presets,
                MainMenuItem::Replays,
                MainMenuItem::Recruits,
                MainMenuItem::Settings,
                MainMenuItem::Quit,
            ]
        } else {
            vec![
                MainMenuItem::Login,
                MainMenuItem::Settings,
                MainMenuItem::Quit,
            ]
        };

        Self {
            title: Some("Commander".to_string()),
            items,
            selected_item: 0,
            window: None,
        }
    }
}

impl Menu<ReplayMenuItem> {
    pub fn replays(replays: &Vec<WithRef<Replay>>) -> Self {
        Self {
            title: Some("Replays".to_string()),
            items: vec![ReplayMenuItem::Back]
                .into_iter()
                .chain(replays.iter().map(|r| ReplayMenuItem::Replay(r.clone())))
                .collect(),
            selected_item: 0,
            window: Some(20),
        }
    }
}

impl Menu<PresetMenuItem> {
    pub fn presets(presets: &Vec<WithRef<Preset>>) -> Self {
        Self {
            title: Some("Presets".to_string()),
            items: vec![PresetMenuItem::Back]
                .into_iter()
                .chain(presets.iter().map(|p| PresetMenuItem::Preset(p.clone())))
                .collect(),
            selected_item: 0,
            window: Some(20),
        }
    }
}

impl Menu<SettingsMenuItem> {
    pub fn settings() -> Self {
        Self {
            title: Some("Settings".to_string()),
            items: vec![
                SettingsMenuItem::WindowSize,
                SettingsMenuItem::Logout,
                SettingsMenuItem::Back,
            ],
            selected_item: 0,
            window: None,
        }
    }
}

impl Menu<WindowSettingsMenuItem> {
    pub fn window_settings() -> Self {
        Self {
            title: Some("Window Settings".to_string()),
            items: vec![
                WindowSettingsMenuItem::SizeSmall,
                WindowSettingsMenuItem::SizeMedium,
                WindowSettingsMenuItem::SizeLarge,
                WindowSettingsMenuItem::Back,
            ],
            selected_item: 0,
            window: None,
        }
    }
}

impl Menu<RecruitMenuItem> {
    pub fn recruits(recruits: &Vec<WithRef<Recruit>>) -> Self {
        Self {
            title: Some("Recruits".to_string()),
            items: vec![RecruitMenuItem::Back]
                .into_iter()
                .chain(recruits.iter().map(|r| RecruitMenuItem::Recruit(r.clone())))
                .collect(),
            selected_item: 0,
            window: Some(20),
        }
    }
}

impl<T: MenuItem> Menu<T> {
    pub fn next_item(&mut self) {
        self.selected_item = (self.selected_item + 1) % self.items.len();
    }

    pub fn previous_item(&mut self) {
        self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len();
    }

    pub fn select(&mut self) -> &T {
        &self.items[self.selected_item]
    }
}

impl<T: MenuItem> Draw for Menu<T> {
    fn draw(&self) {
        let offset = if let Some(title) = &self.title {
            draw_text_ex(
                &title,
                20.0,
                40.0,
                TextParams {
                    font: Some(FONTS.lock().unwrap().get("doto").unwrap()),
                    font_size: TITLE_FONT_SIZE as u16,
                    color: WHITE,
                    ..Default::default()
                },
            );
            TITLE_FONT_SIZE * 2.0
        } else {
            FONT_SIZE
        };

        // If window is not set, draw all items at all times.
        if self.window.is_none() {
            for (i, item) in self.items.iter().enumerate() {
                let color = if i == self.selected_item {
                    SELECTED_COLOR
                } else {
                    TEXT_COLOR
                };
                draw_text_ex(
                    &item.to_string(),
                    20.0,
                    offset + (i as f32 * FONT_SIZE),
                    TextParams {
                        font: Some(FONTS.lock().unwrap().get("doto").unwrap()),
                        font_size: FONT_SIZE as u16,
                        color,
                        ..Default::default()
                    },
                );
            }
            return;
        }

        // If window is set, cursor shifts the window when moving up/down.
        let window = self.window.unwrap();
        let start = self.selected_item.saturating_sub(window / 2);
        let end = start + window;
        let mut j = 0;

        for (i, item) in self.items.iter().enumerate().skip(start).take(end - start) {
            let color = if i == self.selected_item {
                SELECTED_COLOR
            } else {
                TEXT_COLOR
            };
            draw_text_ex(
                &item.to_string(),
                20.0,
                offset + (j as f32 * FONT_SIZE),
                TextParams {
                    font: Some(FONTS.lock().unwrap().get("doto").unwrap()),
                    font_size: FONT_SIZE as u16,
                    color,

                    ..Default::default()
                },
            );
            j += 1;
        }
    }
}

// === Display impls ===

impl Display for MainMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MainMenuItem::StartGame => write!(f, "Start Game"),
            MainMenuItem::Address(_address) => write!(f, "Logged in"),
            MainMenuItem::Login => write!(f, "Login (Google)"),
            MainMenuItem::Replays => write!(f, "Replays"),
            MainMenuItem::Presets => write!(f, "Presets"),
            MainMenuItem::Recruits => write!(f, "Recruits"),
            MainMenuItem::Settings => write!(f, "Settings"),
            MainMenuItem::Quit => write!(f, "Quit"),
        }
    }
}

impl Display for RecruitMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            RecruitMenuItem::Recruit(recruit) => {
                write!(
                    f,
                    "{} (Rank: {})",
                    recruit.data.metadata.name, recruit.data.rank
                )
            }
            RecruitMenuItem::Back => write!(f, "Back"),
        }
    }
}

impl Display for ReplayMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ReplayMenuItem::Replay(replay) => {
                write!(
                    f,
                    "{} (Actions: {})",
                    replay.data.id,
                    replay.data.history.0.len()
                )
            }
            ReplayMenuItem::Back => write!(f, "Back"),
        }
    }
}

impl Display for PresetMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PresetMenuItem::Preset(preset) => write!(f, "{}", preset.data.name),
            PresetMenuItem::Back => write!(f, "Back"),
        }
    }
}

impl Display for SettingsMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SettingsMenuItem::WindowSize => write!(f, "Window Size"),
            SettingsMenuItem::Logout => write!(f, "Logout"),
            SettingsMenuItem::Back => write!(f, "Back"),
        }
    }
}

impl Display for WindowSettingsMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            WindowSettingsMenuItem::SizeSmall => write!(f, "Small (700x700)"),
            WindowSettingsMenuItem::SizeMedium => write!(f, "Medium (1000x1000)"),
            WindowSettingsMenuItem::SizeLarge => write!(f, "Large (1200x1200)"),
            WindowSettingsMenuItem::Back => write!(f, "Back"),
        }
    }
}
