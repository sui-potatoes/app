// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use macroquad::prelude::*;
use sui_sdk_types::Address;

use crate::{
    WithRef,
    config::{MENU_FONT_COLOR as TEXT_COLOR, MENU_FONT_SIZE as FONT_SIZE},
    draw::{self, Draw, DrawCommand, ZIndex},
    types::{Preset, Recruit, Replay},
};

const SELECTED_COLOR: Color = WHITE;
const TITLE_FONT_SIZE: f32 = 40.0;

#[derive(Debug, Clone)]
/// Draws the menu based on the items, tracks the currently selected item. Reacts
/// on keyboard input to navigate the menu.
pub struct Menu<Item> {
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
    Editor,
    Settings,
    Quit,
}

#[derive(Debug, Clone)]
pub enum ReplayMenuItem {
    Replay(WithRef<Replay>),
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

#[derive(Debug, Clone)]
pub enum RecruitSubMenuItem {
    Stats,
    Weapon,
    Armor,
    Back,
}

pub trait Selectable {
    type Item;

    fn next_item(&mut self);
    fn previous_item(&mut self);
    fn selected_item(&self) -> &Self::Item;
}

// === Menu impls ===

impl Menu<MainMenuItem> {
    pub fn main(address: Option<Address>) -> Self {
        let items = if let Some(_) = address {
            vec![
                MainMenuItem::StartGame,
                MainMenuItem::Replays,
                MainMenuItem::Editor,
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

impl Menu<RecruitSubMenuItem> {
    pub fn recruit_sub(recruit: &WithRef<Recruit>) -> Self {
        Self {
            title: Some(format!("{}", recruit.data.metadata.name)),
            items: vec![
                RecruitSubMenuItem::Stats,
                RecruitSubMenuItem::Weapon,
                RecruitSubMenuItem::Armor,
                RecruitSubMenuItem::Back,
            ],
            selected_item: 0,
            window: None,
        }
    }
}

impl<T> Selectable for Menu<T> {
    type Item = T;

    fn next_item(&mut self) {
        self.selected_item = (self.selected_item + 1) % self.items.len();
    }

    fn previous_item(&mut self) {
        self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len();
    }

    fn selected_item(&self) -> &T {
        &self.items[self.selected_item]
    }
}

impl<T: Display> Draw for Menu<T> {
    fn draw(&self) {
        let offset = if let Some(title) = &self.title {
            DrawCommand::text(title.clone())
                .position(20.0, 40.0)
                .font_size(TITLE_FONT_SIZE as u16)
                .color(WHITE)
                .z_index(ZIndex::MenuText)
                .schedule();

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

                DrawCommand::text(item.to_string())
                    .position(20.0, offset + (i as f32 * FONT_SIZE))
                    .font_size(FONT_SIZE as u16)
                    .color(color)
                    .z_index(ZIndex::MenuText)
                    .schedule();
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

            DrawCommand::text(item.to_string())
                .position(20.0, offset + (j as f32 * FONT_SIZE))
                .font_size(FONT_SIZE as u16)
                .color(color)
                .z_index(ZIndex::MenuText)
                .schedule();

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
            MainMenuItem::Editor => write!(f, "Editor"),
            MainMenuItem::Settings => write!(f, "Settings"),
            MainMenuItem::Quit => write!(f, "Quit"),
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

impl Display for RecruitSubMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            RecruitSubMenuItem::Stats => write!(f, "Stats"),
            RecruitSubMenuItem::Weapon => write!(f, "Weapon"),
            RecruitSubMenuItem::Armor => write!(f, "Armor"),
            RecruitSubMenuItem::Back => write!(f, "Back"),
        }
    }
}
