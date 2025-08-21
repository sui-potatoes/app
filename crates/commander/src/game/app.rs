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
    game::{Editor, play::Play},
    input::InputCommand,
    types::{Game, ID, Preset, Recruit, Replay},
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
    /// Show the editor.
    Editor(Editor),
    /// Show main menu.
    MainMenu(Menu<MainMenuItem>),
    /// Show an active game.
    Play(Play),
    /// Show list of replays.
    Replays(Menu<ReplayMenuItem>),
    /// Play a replay.
    Replay(Player),
    /// Show settings menu.
    Settings(Menu<SettingsMenuItem>),
    /// Show window settings menu.
    WindowSettings(Menu<WindowSettingsMenuItem>),
}

#[derive(Debug, Clone)]
pub struct RecruitScreen {
    pub menu: Menu<RecruitSubMenuItem>,
    pub recruit: WithRef<Recruit>,
}

/// Trait for separate screens that can be used in the App.
pub trait AppComponent {
    /// Handles a key press. Returns true if the screen should be closed, false
    /// otherwise. Eg, on `InputCommand::Menu` or `InputCommand::Select`, an
    /// app component may request to close the screen.
    fn handle_key_press(&mut self, key: InputCommand) -> bool;

    /// Updates the component on each frame.
    fn tick(&mut self);
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
            TokioMessage::GameStarted => {
                self.screen = Screen::Play(Play::from(
                    self.state
                        .lock()
                        .as_ref()
                        .unwrap()
                        .active_game
                        .clone()
                        .unwrap(),
                ));
            }
        }
    }

    /// Triggered by `input::handle_input`, handles key presses for each screen.
    pub fn handle_key_press(&mut self, key: InputCommand) {
        let state = self.state.lock().unwrap();
        match &mut self.screen {
            Screen::Editor(editor) => {
                if editor.handle_key_press(key) {
                    self.screen = Screen::MainMenu(Menu::main(state.address));
                }
            }
            Screen::Play(play) => {
                if play.handle_key_press(key) {
                    self.screen = Screen::MainMenu(Menu::main(state.address));
                }
            }
            Screen::Replay(player) => {
                if player.handle_key_press(key) {
                    self.screen = Screen::MainMenu(Menu::main(state.address));
                }
            }
            Screen::MainMenu(menu) => match key {
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Select => match menu.selected_item() {
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
                    MainMenuItem::Editor => {
                        self.screen = Screen::Editor(Editor::new(10, 10));
                    }
                    MainMenuItem::Settings => self.screen = Screen::Settings(Menu::settings()),
                    MainMenuItem::Quit => std::process::exit(0),
                },
                _ => {}
            },
            Screen::Settings(menu) => match key {
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                InputCommand::Select => match menu.selected_item() {
                    SettingsMenuItem::WindowSize => {
                        self.screen = Screen::WindowSettings(Menu::window_settings())
                    }
                    SettingsMenuItem::Logout => {
                        self.send_message(Message::Logout);
                        self.screen = Screen::MainMenu(Menu::main(state.address));
                    }
                    SettingsMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
            Screen::Replays(menu) => match key {
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                InputCommand::Select => match menu.selected_item() {
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
            Screen::WindowSettings(menu) => match key {
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Menu => self.screen = Screen::MainMenu(Menu::main(state.address)),
                InputCommand::Select => match menu.selected_item() {
                    WindowSettingsMenuItem::SizeSmall => set_window_size(700, 700),
                    WindowSettingsMenuItem::SizeMedium => set_window_size(1000, 1000),
                    WindowSettingsMenuItem::SizeLarge => set_window_size(1200, 1200),
                    WindowSettingsMenuItem::Back => {
                        self.screen = Screen::MainMenu(Menu::main(state.address))
                    }
                },
                _ => {}
            },
        }
    }

    pub fn tick(&mut self) {
        match &mut self.screen {
            Screen::Replay(player) => player.tick(),
            Screen::Play(play) => play.tick(),
            _ => self.draw(),
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
            Screen::Replays(_) => Screen::Replays(Menu::replays(&state.replays)),
            Screen::Replay(_)
            | Screen::Play(_)
            | Screen::Settings(_)
            | Screen::Editor(_)
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
            Screen::Editor(editor) => editor.draw(),
            Screen::MainMenu(menu) => menu.draw(),
            Screen::Replays(menu) => menu.draw(),
            Screen::Settings(menu) => menu.draw(),
            Screen::WindowSettings(menu) => menu.draw(),
            Screen::Play(_play) => unreachable!("Play manages its own draw"),
            Screen::Replay(_player) => unreachable!("Player manages its own draw"),
        }
    }
}
