// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::input::Command;
use crate::Message as TokioMessage;
use crate::client::WithRef;
use crate::draw::*;
use crate::move_types::{Game, ID, Preset, Recruit, Replay};
use macroquad::miniquad::window::set_window_size;
use macroquad::prelude::*;
use std::collections::HashMap;
use std::fmt::Display;
use std::sync::mpsc::Sender;
use sui_types::base_types::SuiAddress;

pub struct App {
    pub screen: Screen,
    pub replays: Vec<WithRef<Replay>>,
    pub presets: Vec<WithRef<Preset>>,
    pub recruits: Vec<WithRef<Recruit>>,
    pub game: Option<Game>,

    /// Textures for the game.
    pub textures: HashMap<String, Texture2D>,

    /// Cursor position on the Map.
    /// Only relevant in certain screens, like the Preset screen.
    pub cursor: (u8, u8),

    /// Tiles that are currently highlighted.
    pub highlight: Vec<(u8, u8)>,

    /// Address of the user. If present, the user is expected to be logged in.
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
    /// Start a new game.
    StartGame,
    /// Logout the user.
    Logout,
    /// Fetch the list of presets.
    FetchPresets,
    /// Fetch the list of recruits.
    FetchRecruits,
    /// Fetch the list of replays.
    FetchReplays,
}

pub enum Screen {
    /// Show main menu.
    MainMenu(Menu<MainMenuItem>),
    /// Show an active game.
    Play(Game),
    /// Show list of presets.
    Presets(Menu<PresetMenuItem>),
    /// Show in-game Preset map.
    Preset(WithRef<Preset>),
    /// Show list of recruits.
    Recruits(Menu<RecruitMenuItem>),
    /// Show a single recruit.
    Recruit(WithRef<Recruit>),
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

    pub fn get_preset(&self, id: &ID) -> Option<&WithRef<Preset>> {
        self.presets.iter().find(|p| p.data.id == *id)
    }

    /// Sends a message to the tokio runtime.
    pub fn send_message(&self, msg: Message) {
        self.tx.send(msg).unwrap();
    }

    pub fn update_from_message(&mut self, msg: TokioMessage) {
        match msg {
            TokioMessage::Presets(presets) => {
                self.presets = presets;
                self.reload_screen();
            }
            TokioMessage::Recruits(recruits) => {
                self.recruits = recruits;
                self.reload_screen();
            }
            TokioMessage::Replays(replays) => {
                self.replays = replays;
                self.reload_screen();
            }
            TokioMessage::Address(address) => {
                println!("Received address: {}", address);
                self.address = Some(address);
                self.reload_screen();
            }
            TokioMessage::Text(txt) => println!("Received text message: {}", txt),
        }
    }

    /// Triggered by `input::handle_input`, handles key presses for each screen.
    pub fn handle_key_press(&mut self, key: Command) {
        match &mut self.screen {
            Screen::MainMenu(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Select => match menu.select() {
                    MainMenuItem::Address(_address) => {}
                    MainMenuItem::Login => {
                        // Starts the login process.
                        self.send_message(Message::PrepareLogin);
                    }
                    MainMenuItem::StartGame => {
                        self.send_message(Message::StartGame);
                    }
                    MainMenuItem::Replays => {
                        self.send_message(Message::FetchReplays);
                        self.set_screen(Screen::Replays(Menu::replays(&self.replays)))
                    }
                    MainMenuItem::Presets => {
                        self.send_message(Message::FetchPresets);
                        self.set_screen(Screen::Presets(Menu::presets(&self.presets)))
                    }
                    MainMenuItem::Recruits => {
                        self.send_message(Message::FetchRecruits);
                        self.set_screen(Screen::Recruits(Menu::recruits(&self.recruits)))
                    }
                    MainMenuItem::Settings => self.set_screen(Screen::Settings(Menu::settings())),
                    MainMenuItem::Quit => std::process::exit(0),
                },
                _ => {}
            },
            Screen::Settings(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Select => match menu.select() {
                    SettingsMenuItem::WindowSize => {
                        self.set_screen(Screen::WindowSettings(Menu::window_settings()))
                    }
                    SettingsMenuItem::Logout => {
                        self.send_message(Message::Logout);
                        self.address = None;
                        self.switch_to_main_screen();
                    }
                    SettingsMenuItem::Back => self.switch_to_main_screen(),
                },
                _ => {}
            },
            Screen::Recruits(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Select => match menu.select() {
                    RecruitMenuItem::Recruit(recruit) => {
                        let recruit = recruit.clone();
                        self.set_screen(Screen::Recruit(recruit));
                    }
                    RecruitMenuItem::Back => self.switch_to_main_screen(),
                },
                _ => {}
            },
            Screen::Recruit(_) => match key {
                Command::Menu => {
                    self.set_screen(Screen::Recruits(Menu::recruits(&self.recruits)))
                }
                _ => {}
            },
            Screen::Replays(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Select => match menu.select() {
                    ReplayMenuItem::Replay(replay) => {
                        println!("Starting replay {}", replay.data.id)
                    }
                    ReplayMenuItem::Back => self.switch_to_main_screen(),
                },
                _ => {}
            },
            Screen::Presets(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Select => match menu.select() {
                    PresetMenuItem::Preset(preset) => self.screen = Screen::Preset(preset.clone()),
                    PresetMenuItem::Back => self.switch_to_main_screen(),
                },
                _ => {}
            },
            Screen::WindowSettings(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Select => match menu.select() {
                    WindowSettingsMenuItem::SizeSmall => set_window_size(700, 700),
                    WindowSettingsMenuItem::SizeMedium => set_window_size(1000, 1000),
                    WindowSettingsMenuItem::SizeLarge => set_window_size(1200, 1200),
                    WindowSettingsMenuItem::Back => self.switch_to_main_screen(),
                },
                _ => {}
            },
            Screen::Preset(preset) => match key {
                Command::Menu => self.set_screen(Screen::MainMenu(Menu::main(self.address))),
                Command::Up => {
                    self.cursor.0 =
                        (self.cursor.0 + preset.data.map.height() - 1) % preset.data.map.height();
                    self.highlight.drain(..);
                }
                Command::Down => {
                    self.cursor.0 = (self.cursor.0 + 1) % preset.data.map.height();
                    self.highlight.drain(..);
                }
                Command::Left => {
                    self.cursor.1 =
                        (self.cursor.1 + preset.data.map.width() - 1) % preset.data.map.width();
                    self.highlight.drain(..);
                }
                Command::Right => {
                    self.cursor.1 = (self.cursor.1 + 1) % preset.data.map.width();
                    self.highlight.drain(..);
                }
                Command::Select => {
                    self.highlight = preset.data.map.walkable_tiles(self.cursor, 3);
                }
                // _ => self.switch_to_main_screen(),
            },
            Screen::Play(_game) => match key {
                _ => {}
            },
        }
    }

    fn switch_to_main_screen(&mut self) {
        self.set_screen(Screen::MainMenu(Menu::main(self.address)));
    }

    fn set_screen(&mut self, screen: Screen) {
        self.screen = screen;
        self.cursor = (0, 0);
        self.highlight.drain(..);
    }

    fn reload_screen(&mut self) {
        let screen = match &self.screen {
            Screen::MainMenu(_) => Screen::MainMenu(Menu::main(self.address)),
            Screen::Presets(_) => Screen::Presets(Menu::presets(&self.presets)),
            Screen::Replays(_) => Screen::Replays(Menu::replays(&self.replays)),
            Screen::Recruits(_) => Screen::Recruits(Menu::recruits(&self.recruits)),
            Screen::Recruit(_)
            | Screen::Preset(_)
            | Screen::Play(_)
            | Screen::Settings(_)
            | Screen::WindowSettings(_) => return,
        };

        self.set_screen(screen);
    }
}

pub trait MenuItem: Display {}

impl MenuItem for MainMenuItem {}
impl MenuItem for ReplayMenuItem {}
impl MenuItem for PresetMenuItem {}
impl MenuItem for SettingsMenuItem {}
impl MenuItem for WindowSettingsMenuItem {}
impl MenuItem for RecruitMenuItem {}

impl Menu<MainMenuItem> {
    pub fn main(address: Option<SuiAddress>) -> Self {
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
            vec![MainMenuItem::Login, MainMenuItem::Settings, MainMenuItem::Quit]
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
            Screen::Recruit(_) => {}
            Screen::Recruits(menu) => menu.draw(),
            Screen::Replays(menu) => menu.draw(),
            Screen::Presets(menu) => menu.draw(),
            Screen::Settings(menu) => menu.draw(),
            Screen::WindowSettings(menu) => menu.draw(),
            Screen::Preset(preset) => {
                if let Some(texture) = self.textures.get("background") {
                    draw_texture_background(
                        (preset.data.map.width(), preset.data.map.height()),
                        texture,
                    );
                }

                preset.data.map.draw();
                draw_cursor(
                    self.cursor,
                    (preset.data.map.width(), preset.data.map.height()),
                );
                draw_highlight(
                    self.highlight.clone(),
                    (preset.data.map.width(), preset.data.map.height()),
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
