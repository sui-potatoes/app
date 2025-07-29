// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{
    collections::HashMap,
    sync::{Arc, Mutex, mpsc::Sender},
};

use macroquad::{miniquad::window::set_window_size, prelude::*};
use sui_sdk_types::Address;

use super::{menu::*, player::*};
use crate::{
    Message as TokioMessage, State, WithRef,
    draw::*,
    input::Command,
    move_types::{Game, ID, Preset, Recruit, Replay},
};

pub struct App {
    pub screen: Screen,
    pub state: Arc<Mutex<State>>,
    pub game: Option<Game>,
    /// Cursor position on the Map.
    /// Only relevant in certain screens, like the Preset screen.
    pub cursor: (u8, u8),
    /// Tiles that are currently highlighted.
    pub highlight: Option<Highlight>,
    /// Sender for messages to the tokio runtime.
    pub tx: Sender<Message>,
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
    /// Play a replay.
    Replay(Player),
    /// Show settings menu.
    Settings(Menu<SettingsMenuItem>),
    /// Show window settings menu.
    WindowSettings(Menu<WindowSettingsMenuItem>),
}

impl App {
    pub fn new(tx: Sender<Message>, state: Arc<Mutex<State>>) -> Self {
        Self {
            screen: Screen::MainMenu(Menu::main(None)),
            game: None,
            state,
            highlight: None,
            cursor: (0, 0),
            tx,
        }
    }

    /// Returns a preset by its ID.
    pub fn get_preset(&self, id: &ID) -> Option<WithRef<Preset>> {
        self.state
            .lock()
            .unwrap()
            .presets
            .iter()
            .find(|p| p.data.id == *id)
            .cloned()
    }

    /// Sends a message to the tokio runtime.
    pub fn send_message(&self, msg: Message) {
        self.tx.send(msg).unwrap();
    }

    /// Updates the app from a message received from the tokio runtime.
    /// Triggered in the main loop, cannot be blocking.
    pub fn update_from_message(&mut self, msg: TokioMessage) {
        // If we're currently in Replay, fill in the Preset.
        if let Screen::Replay(player) = &mut self.screen {
            let preset_id = player.preset_id;
            if let Some(preset) = self
                .state
                .lock()
                .unwrap()
                .presets
                .iter()
                .find(|p| p.data.id == preset_id)
            {
                player.add_preset(preset.data.clone());
            }
        }

        match msg {
            TokioMessage::Text(txt) => println!("Received text message: {}", txt),
            TokioMessage::StateUpdated => self.reload_screen(),
        }
    }

    /// Triggered by `input::handle_input`, handles key presses for each screen.
    pub fn handle_key_press(&mut self, key: Command) {
        let state = self.state.lock().unwrap();
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
                        self.screen = Screen::Replays(Menu::replays(&state.replays))
                    }
                    MainMenuItem::Presets => {
                        self.send_message(Message::FetchPresets);
                        self.screen = Screen::Presets(Menu::presets(&state.presets))
                    }
                    MainMenuItem::Recruits => {
                        self.send_message(Message::FetchRecruits);
                        self.screen = Screen::Recruits(Menu::recruits(&state.recruits))
                    }
                    MainMenuItem::Settings => self.screen = Screen::Settings(Menu::settings()),
                    MainMenuItem::Quit => std::process::exit(0),
                },
                _ => {}
            },
            Screen::Settings(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Select => match menu.select() {
                    SettingsMenuItem::WindowSize => {
                        self.screen = Screen::WindowSettings(Menu::window_settings())
                    }
                    SettingsMenuItem::Logout => {
                        self.send_message(Message::Logout);
                        // state.address = None;
                        self.screen = Screen::MainMenu(Menu::main(state.address));
                    }
                    SettingsMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::Recruits(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Select => match menu.select() {
                    RecruitMenuItem::Recruit(recruit) => {
                        let recruit = recruit.clone();
                        self.screen = Screen::Recruit(recruit);
                    }
                    RecruitMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::Recruit(_) => match key {
                Command::Menu => self.screen = Screen::Recruits(Menu::recruits(&state.recruits)),
                _ => {}
            },
            Screen::Replays(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Select => match menu.select() {
                    ReplayMenuItem::Replay(replay) => {
                        self.screen = Screen::Replay(Player::new(replay.data.clone()));
                        self.send_message(Message::FetchPresets);
                    }
                    ReplayMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::Replay(player) => match key {
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Right => {
                    if let Err(e) = player.next_action() {
                        eprintln!("Error: {}", e);
                    }
                }
                Command::Left => {
                    if let Err(e) = player.prev_action() {
                        eprintln!("Error: {}", e);
                    }
                }
                _ => {}
            },
            Screen::Presets(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Select => match menu.select() {
                    PresetMenuItem::Preset(preset) => self.screen = Screen::Preset(preset.clone()),
                    PresetMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::WindowSettings(menu) => match key {
                Command::Up => menu.previous_item(),
                Command::Down => menu.next_item(),
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Select => match menu.select() {
                    WindowSettingsMenuItem::SizeSmall => set_window_size(700, 700),
                    WindowSettingsMenuItem::SizeMedium => set_window_size(1000, 1000),
                    WindowSettingsMenuItem::SizeLarge => set_window_size(1200, 1200),
                    WindowSettingsMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::Preset(preset) => match key {
                Command::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                Command::Up => {
                    self.cursor.0 =
                        (self.cursor.0 + preset.data.map.height() - 1) % preset.data.map.height();
                    self.highlight = None;
                }
                Command::Down => {
                    self.cursor.0 = (self.cursor.0 + 1) % preset.data.map.height();
                    self.highlight = None;
                }
                Command::Left => {
                    self.cursor.1 =
                        (self.cursor.1 + preset.data.map.width() - 1) % preset.data.map.width();
                    self.highlight = None;
                }
                Command::Right => {
                    self.cursor.1 = (self.cursor.1 + 1) % preset.data.map.width();
                    self.highlight = None;
                }
                Command::Select => {
                    self.highlight = Some(Highlight(
                        preset.data.map.walkable_tiles(self.cursor, 3),
                        Color {
                            b: 200.0,
                            a: 0.2,
                            ..Default::default()
                        },
                    ));
                }
            },
            Screen::Play(_game) => match key {
                _ => {}
            },
        }
    }

    fn set_screen(&mut self, screen: Screen) {
        self.screen = screen;
        self.cursor = (0, 0);
        self.highlight = None;
    }

    fn reload_screen(&mut self) {
        let state = self.state.lock().unwrap();
        let screen = match &self.screen {
            Screen::MainMenu(_) => Screen::MainMenu(Menu::main(state.address)),
            Screen::Presets(_) => Screen::Presets(Menu::presets(&state.presets)),
            Screen::Replays(_) => Screen::Replays(Menu::replays(&state.replays)),
            Screen::Recruits(_) => Screen::Recruits(Menu::recruits(&state.recruits)),
            Screen::Recruit(_)
            | Screen::Replay(_)
            | Screen::Preset(_)
            | Screen::Play(_)
            | Screen::Settings(_)
            | Screen::WindowSettings(_) => return,
        };

        self.screen = screen;
        self.cursor = (0, 0);
        self.highlight = None;
    }
}

/// === Draw impls ===

impl Draw for App {
    fn draw(&self) {
        match &self.screen {
            Screen::MainMenu(menu) => menu.draw(),
            Screen::Play(game) => {
                if let Some(texture) = TEXTURES.lock().unwrap().get(&Texture::Background) {
                    draw_texture_background((game.map.width(), game.map.height()), texture);
                }

                game.map.draw();
                draw_cursor(self.cursor, (game.map.width(), game.map.height()));
                if let Some(highlight) = &self.highlight {
                    draw_highlight(highlight, (game.map.width(), game.map.height()));
                }
            }
            Screen::Replay(replay) => {
                if let Some(preset) = self.get_preset(&replay.preset_id) {
                    if let Some(texture) = TEXTURES.lock().unwrap().get(&Texture::Background) {
                        draw_texture_background(
                            (preset.data.map.width(), preset.data.map.height()),
                            texture,
                        );
                    }

                    replay.draw();
                    if let Some(highlight) = &self.highlight {
                        draw_highlight(
                            highlight,
                            (preset.data.map.width(), preset.data.map.height()),
                        );
                    }
                } else {
                    draw_text("No preset found for replay", 10.0, 10.0, 20.0, BLACK);
                }
            }
            Screen::Recruit(_) => {}
            Screen::Recruits(menu) => menu.draw(),
            Screen::Replays(menu) => menu.draw(),
            Screen::Presets(menu) => menu.draw(),
            Screen::Settings(menu) => menu.draw(),
            Screen::WindowSettings(menu) => menu.draw(),
            Screen::Preset(preset) => {
                if let Some(texture) = TEXTURES.lock().unwrap().get(&Texture::Background) {
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
                if let Some(highlight) = &self.highlight {
                    draw_highlight(
                        highlight,
                        (preset.data.map.width(), preset.data.map.height()),
                    );
                }
            }
        }
    }
}
