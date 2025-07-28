// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, sync::mpsc::Sender};

use macroquad::{miniquad::window::set_window_size, prelude::*};
use sui_types::base_types::SuiAddress;

use super::menu::*;
use crate::{
    Message as TokioMessage,
    client::WithRef,
    draw::*,
    input::Command,
    move_types::{Game, ID, Preset, Recruit, Replay},
};

const FONT_SIZE: f32 = 24.0;
const TITLE_FONT_SIZE: f32 = 40.0;

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

    /// Returns a preset by its ID.
    pub fn get_preset(&self, id: &ID) -> Option<&WithRef<Preset>> {
        self.presets.iter().find(|p| p.data.id == *id)
    }

    /// Sends a message to the tokio runtime.
    pub fn send_message(&self, msg: Message) {
        self.tx.send(msg).unwrap();
    }

    /// Updates the app from a message received from the tokio runtime.
    /// Triggered in the main loop, cannot be blocking.
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
                Command::Menu => self.set_screen(Screen::Recruits(Menu::recruits(&self.recruits))),
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
                } // _ => self.switch_to_main_screen(),
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
            draw_text(&title, 20.0, 40.0, TITLE_FONT_SIZE, WHITE);
            TITLE_FONT_SIZE * 2.0
        } else {
            FONT_SIZE
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
                    offset + (i as f32 * FONT_SIZE),
                    FONT_SIZE,
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
                offset + (j as f32 * FONT_SIZE),
                FONT_SIZE,
                color,
            );
            j += 1;
        }
    }
}
