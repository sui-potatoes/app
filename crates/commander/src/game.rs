// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::Message as TokioMessage;
use crate::draw::*;
use crate::move_types::{Game, ID, Preset, Recruit, Replay};
use macroquad::miniquad::window::set_window_size;
use macroquad::prelude::*;
use sui_types::base_types::SuiAddress;
use std::collections::HashMap;
use std::fmt::Display;
use std::sync::mpsc::Sender;

pub struct App {
    pub screen: Screen,
    pub replays: Vec<Replay>,
    pub presets: Vec<Preset>,
    pub recruits: Vec<Recruit>,
    pub game: Option<Game>,

    /// Textures for the game.
    pub textures: HashMap<String, Texture2D>,

    /// Cursor position on the Map.
    /// Only relevant in certain screens, like the Preset screen.
    pub cursor: (u8, u8),

    /// Tiles that are currently highlighted.
    pub highlight: Vec<(u8, u8)>,

    /// Address of the user.
    pub address: Option<SuiAddress>,

    /// Sender for messages to the tokio runtime.
    pub tx: Sender<Message>,
}

/// Draws the menu based on the items, tracks the currently selected item. Reacts
/// on keyboard input to navigate the menu.
pub struct Menu<T: MenuItem> {
    pub title: Option<String>,
    pub items: Vec<T>,
    pub selected_item: usize,
    /// Size of the window (how many to show at once).
    pub window: Option<usize>,
}

/// Messages sent from Application to the tokio runtime.
pub enum Message {
    /// Prepare to open a login window.
    PrepareLogin,
}

pub enum Screen {
    /// Show main menu.
    MainMenu(Menu<MainMenuItem>),
    /// Show an active game.
    Play(Game),
    /// Show list of presets.
    Presets(Menu<PresetMenuItem>),
    /// Show in-game Preset map.
    Preset(Preset),
    /// Show list of replays.
    Replays(Menu<ReplayMenuItem>),
    /// Show settings menu.
    Settings(Menu<SettingsMenuItem>),
    /// Show window settings menu.
    WindowSettings(Menu<WindowSettingsMenuItem>),
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum MainMenuItem {
    StartGame,
    Login,
    Address(SuiAddress),
    Replays,
    Presets,
    Recruits,
    Settings,
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

#[derive(Debug, Clone)]
pub enum SettingsMenuItem {
    WindowSize,
    Back,
}

#[derive(Debug, Clone)]
pub enum WindowSettingsMenuItem {
    SizeSmall,
    SizeMedium,
    SizeLarge,
    Back,
}

impl App {
    pub fn new(tx: Sender<Message>) -> Self {
        Self {
            screen: Screen::MainMenu(Menu::main(None)),
            replays: Vec::new(),
            presets: Vec::new(),
            recruits: Vec::new(),
            game: None,

            textures: HashMap::new(),
            highlight: Vec::new(),
            cursor: (0, 0),
            address: None,
            tx,
        }
    }

    pub fn get_preset(&self, id: &ID) -> Option<&Preset> {
        self.presets.iter().find(|p| p.id == *id)
    }

    /// Sends a message to the tokio runtime.
    pub fn send_message(&self, msg: Message) {
        self.tx.send(msg).unwrap();
    }

    pub fn update_from_message(&mut self, msg: TokioMessage) {
        match msg {
            TokioMessage::Presets(presets) => self.presets = presets,
            TokioMessage::Recruits(recruits) => self.recruits = recruits,
            TokioMessage::Replays(replays) => self.replays = replays,
            TokioMessage::Address(address) => {
                self.address = Some(address);
                self.set_screen(Screen::MainMenu(Menu::main(self.address)));
            }
            TokioMessage::Text(txt) => println!("Received text message: {}", txt),
        }
    }

    /// Triggered by `input::handle_input`, handles key presses for each screen.
    pub fn handle_key_press(&mut self, key: KeyCode) {
        match &mut self.screen {
            Screen::MainMenu(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Enter => match menu.select() {
                    MainMenuItem::Address(_address) => {}
                    MainMenuItem::Login => {
                        // Requests fetching `nonce` from zklogin, then wait for
                        // the message to be received, and in the message handler
                        // we will open the auth page.
                        self.send_message(Message::PrepareLogin);
                    }
                    MainMenuItem::StartGame => {
                        println!("Starting game");
                    }
                    MainMenuItem::Replays => {
                        self.set_screen(Screen::Replays(Menu::replays(&self.replays)))
                    }
                    MainMenuItem::Presets => {
                        self.set_screen(Screen::Presets(Menu::presets(&self.presets)))
                    }
                    MainMenuItem::Recruits => {
                        println!("Showing recruits");
                    }
                    MainMenuItem::Settings => self.set_screen(Screen::Settings(Menu::settings())),
                },
                _ => {}
            },
            Screen::Settings(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Escape => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                KeyCode::Enter => match menu.select() {
                    SettingsMenuItem::WindowSize => {
                        self.set_screen(Screen::WindowSettings(Menu::window_settings()))
                    }
                    SettingsMenuItem::Back => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                },
                _ => {}
            },
            Screen::Replays(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Escape => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                KeyCode::Enter => match menu.select() {
                    ReplayMenuItem::Replay(replay) => println!("Starting replay {}", replay.id),
                    ReplayMenuItem::Back => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                },
                _ => {}
            },
            Screen::Presets(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Escape => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                KeyCode::Enter => match menu.select() {
                    PresetMenuItem::Preset(preset) => self.screen = Screen::Preset(preset.clone()),
                    PresetMenuItem::Back => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                },
                _ => {}
            },
            Screen::WindowSettings(menu) => match key {
                KeyCode::Up => menu.previous_item(),
                KeyCode::Down => menu.next_item(),
                KeyCode::Escape => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                KeyCode::Enter => match menu.select() {
                    WindowSettingsMenuItem::SizeSmall => set_window_size(700, 700),
                    WindowSettingsMenuItem::SizeMedium => set_window_size(1000, 1000),
                    WindowSettingsMenuItem::SizeLarge => set_window_size(1200, 1200),
                    WindowSettingsMenuItem::Back => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                },
                _ => {}
            },
            Screen::Preset(preset) => match key {
                KeyCode::Escape => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
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
                _ => self.screen = Screen::MainMenu(Menu::main(self.address)),
            },
            Screen::Play(_game) => match key {
                _ => {}
            },
        }
    }

    fn set_screen(&mut self, screen: Screen) {
        self.screen = screen;
        self.cursor = (0, 0);
    }
}

pub trait MenuItem: Display {}

impl MenuItem for MainMenuItem {}
impl MenuItem for ReplayMenuItem {}
impl MenuItem for PresetMenuItem {}
impl MenuItem for SettingsMenuItem {}
impl MenuItem for WindowSettingsMenuItem {}

impl Menu<MainMenuItem> {
    pub fn main(address: Option<SuiAddress>) -> Self {
        Self {
            title: Some("Commander".to_string()),
            items: vec![
                MainMenuItem::StartGame,
                if let Some(address) = address {
                    MainMenuItem::Address(address)
                } else {
                    MainMenuItem::Login
                },
                MainMenuItem::Presets,
                MainMenuItem::Replays,
                MainMenuItem::Recruits,
                MainMenuItem::Settings,
            ],
            selected_item: 0,
            window: None,
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
            window: Some(10),
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
            window: Some(10),
        }
    }
}

impl Menu<SettingsMenuItem> {
    pub fn settings() -> Self {
        Self {
            title: Some("Settings".to_string()),
            items: vec![SettingsMenuItem::WindowSize, SettingsMenuItem::Back],
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

/// === Draw impls ===

impl Draw for App {
    fn draw(&self) {
        match &self.screen {
            Screen::MainMenu(menu) => menu.draw(),
            Screen::Play(game) => {
                if let Some(texture) = self.textures.get("background") {
                    draw_texture_background((game.map.width(), game.map.height()), texture);
                }

                game.map.draw();
                draw_cursor(self.cursor, (game.map.width(), game.map.height()));
                draw_highlight(
                    self.highlight.clone(),
                    (game.map.width(), game.map.height()),
                );
            }
            Screen::Replays(menu) => menu.draw(),
            Screen::Presets(menu) => menu.draw(),
            Screen::Settings(menu) => menu.draw(),
            Screen::WindowSettings(menu) => menu.draw(),
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

impl<T: MenuItem> Draw for Menu<T> {
    fn draw(&self) {
        let offset = if let Some(title) = &self.title {
            draw_text(&title, 20.0, 40.0, 40.0, WHITE);
            80.0
        } else {
            20.0
        };

        // If window is not set, draw all items at all times.
        if self.window.is_none() {
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
            return;
        }

        // If window is set, cursor shifts the window when moving up/down.
        let window = self.window.unwrap();
        let start = self.selected_item.saturating_sub(window / 2);
        let end = start + window;
        let mut j = 0;

        for (i, item) in self.items.iter().enumerate().skip(start).take(end - start) {
            let color = if i == self.selected_item {
                WHITE
            } else {
                BLACK
            };
            draw_text(
                &item.to_string(),
                20.0,
                offset + (j as f32 * 20.0),
                20.0,
                color,
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
            MainMenuItem::Address(address) => write!(f, "Address: {}", address),
            MainMenuItem::Login => write!(f, "Login (Google)"),
            MainMenuItem::Replays => write!(f, "Replays"),
            MainMenuItem::Presets => write!(f, "Presets"),
            MainMenuItem::Recruits => write!(f, "Recruits"),
            MainMenuItem::Settings => write!(f, "Settings"),
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

impl Display for SettingsMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SettingsMenuItem::WindowSize => write!(f, "Window Size"),
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
