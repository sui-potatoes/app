#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::Message;
use crate::draw::*;
use crate::move_types::{ID, Preset, Recruit, Replay};
use macroquad::prelude::*;
use std::collections::HashMap;
use std::fmt::Display;

pub struct Game {
    pub screen: Screen,
    pub replays: Vec<Replay>,
    pub presets: Vec<Preset>,
    pub recruits: Vec<Recruit>,

    /// Textures for the game.
    pub textures: HashMap<String, Texture2D>,
    /// Cursor position on the Map.
    /// Only relevant in certain screens, like the Preset screen.
    pub cursor: (u8, u8),

    /// Tiles that are currently highlighted.
    pub highlight: Vec<(u8, u8)>,
}

/// Draws the menu based on the items, tracks the currently selected item. Reacts
/// on keyboard input to navigate the menu.
pub struct Menu<T: MenuItem> {
    pub title: Option<String>,
    pub items: Vec<T>,
    pub selected_item: usize,
}

pub enum Screen {
    /// Show main menu.
    MainMenu(Menu<MainMenuItem>),
    /// Show list of presets.
    Presets(Menu<PresetMenuItem>),
    /// Show in-game Preset map.
    Preset(Preset),
    /// Show list of replays.
    Replays(Menu<ReplayMenuItem>),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum MainMenuItem {
    StartGame,
    Replays,
    Presets,
    Recruits,
}

#[derive(Debug, Clone)]
pub enum ReplayMenuItem {
    Replay(Replay),
    Back,
}

#[derive(Debug, Clone)]
pub enum PresetMenuItem {
    Preset(Preset),
    Back,
}

impl Game {
    pub fn new() -> Self {
        Self {
            screen: Screen::MainMenu(Menu::main()),
            replays: Vec::new(),
            presets: Vec::new(),
            recruits: Vec::new(),
            textures: HashMap::new(),
            cursor: (0, 0),
            highlight: Vec::new(),
        }
    }

    pub fn get_preset(&self, id: &ID) -> Option<&Preset> {
        self.presets.iter().find(|p| p.id == *id)
    }

    pub fn update_from_message(&mut self, msg: Message) {
        match msg {
            Message::Presets(presets) => self.presets = presets,
            Message::Recruits(recruits) => self.recruits = recruits,
            Message::Replays(replays) => self.replays = replays,
            Message::Text(_) => {}
        }
    }

    pub fn handle_key_press(&mut self, key: KeyCode) {
        match &mut self.screen {
            Screen::MainMenu(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Enter => match menu.select() {
                    MainMenuItem::StartGame => {
                        println!("Starting game");
                    }
                    MainMenuItem::Replays => {
                        self.screen = Screen::Replays(Menu::replays(&self.replays));
                        self.cursor = (0, 0);
                    }
                    MainMenuItem::Presets => {
                        self.screen = Screen::Presets(Menu::presets(&self.presets));
                        self.cursor = (0, 0);
                    }
                    MainMenuItem::Recruits => {
                        println!("Showing recruits");
                    }
                },
                _ => {}
            },
            Screen::Replays(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Enter => match menu.select() {
                    ReplayMenuItem::Replay(replay) => {
                        println!("Starting replay {}", replay.id);
                    }
                    ReplayMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main());
                        self.cursor = (0, 0);
                    }
                },
                _ => {}
            },
            Screen::Presets(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Enter => match menu.select() {
                    PresetMenuItem::Preset(preset) => {
                        self.screen = Screen::Preset(preset.clone());
                        self.cursor = (0, 0);
                    }
                    PresetMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main());
                        self.cursor = (0, 0);
                    }
                },
                _ => {}
            },
            Screen::Preset(preset) => match key {
                KeyCode::Up => {
                    self.cursor.0 = (self.cursor.0 + preset.map.height() - 1) % preset.map.height();
                    self.highlight.drain(..);
                }
                KeyCode::Down => {
                    self.cursor.0 = (self.cursor.0 + 1) % preset.map.height();
                    self.highlight.drain(..);
                }
                KeyCode::Left => {
                    self.cursor.1 = (self.cursor.1 + preset.map.width() - 1) % preset.map.width();
                    self.highlight.drain(..);
                }
                KeyCode::Right => {
                    self.cursor.1 = (self.cursor.1 + 1) % preset.map.width();
                    self.highlight.drain(..);
                }
                KeyCode::Space => {
                    self.highlight = preset.map.walkable_tiles(self.cursor, 3);
                }
                _ => self.screen = Screen::MainMenu(Menu::main()),
            },
        }
    }

    pub fn draw(&self) {
        match &self.screen {
            Screen::MainMenu(menu) => menu.draw(),
            Screen::Replays(menu) => menu.draw(),
            Screen::Presets(menu) => menu.draw(),
            Screen::Preset(preset) => {
                if let Some(texture) = self.textures.get("background") {
                    draw_texture_background((preset.map.width(), preset.map.height()), texture);
                }

                preset.map.draw();
                draw_cursor(self.cursor, (preset.map.width(), preset.map.height()));
                draw_highlight(
                    self.highlight.clone(),
                    (preset.map.width(), preset.map.height()),
                );
            }
        }
    }
}

pub trait MenuItem: Display {}

impl MenuItem for MainMenuItem {}
impl MenuItem for ReplayMenuItem {}
impl MenuItem for PresetMenuItem {}

impl Menu<MainMenuItem> {
    pub fn main() -> Self {
        Self {
            title: Some("Commander".to_string()),
            items: vec![
                MainMenuItem::StartGame,
                MainMenuItem::Presets,
                MainMenuItem::Replays,
                MainMenuItem::Recruits,
            ],
            selected_item: 0,
        }
    }
}

impl Menu<ReplayMenuItem> {
    pub fn replays(replays: &Vec<Replay>) -> Self {
        Self {
            title: Some("Replays".to_string()),
            items: vec![ReplayMenuItem::Back]
                .into_iter()
                .chain(replays.iter().map(|r| ReplayMenuItem::Replay(r.clone())))
                .collect(),
            selected_item: 0,
        }
    }
}

impl Menu<PresetMenuItem> {
    pub fn presets(presets: &Vec<Preset>) -> Self {
        Self {
            title: Some("Presets".to_string()),
            items: vec![PresetMenuItem::Back]
                .into_iter()
                .chain(presets.iter().map(|p| PresetMenuItem::Preset(p.clone())))
                .collect(),
            selected_item: 0,
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

    pub fn draw(&self) {
        let offset = if let Some(title) = &self.title {
            draw_text(&title, 20.0, 40.0, 40.0, WHITE);
            80.0
        } else {
            20.0
        };

        for (i, item) in self.items.iter().enumerate() {
            let color = if i == self.selected_item {
                WHITE
            } else {
                BLACK
            };
            draw_text(
                &item.to_string(),
                20.0,
                offset + (i as f32 * 20.0),
                20.0,
                color,
            );
        }
    }

    pub fn select(&mut self) -> &T {
        &self.items[self.selected_item]
    }
}

// === Display impls ===

impl Display for MainMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            MainMenuItem::StartGame => write!(f, "Start Game"),
            MainMenuItem::Replays => write!(f, "Replays"),
            MainMenuItem::Presets => write!(f, "Presets"),
            MainMenuItem::Recruits => write!(f, "Recruits"),
        }
    }
}

impl Display for ReplayMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ReplayMenuItem::Replay(replay) => {
                write!(f, "{} (Actions: {})", replay.id, replay.history.0.len())
            }
            ReplayMenuItem::Back => write!(f, "Back"),
        }
    }
}

impl Display for PresetMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PresetMenuItem::Preset(preset) => write!(f, "{}", preset.name),
            PresetMenuItem::Back => write!(f, "Back"),
        }
    }
}
