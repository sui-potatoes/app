// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use super::menu::*;
use crate::{
    draw::{Draw, draw},
    game::AppComponent,
    input::InputCommand,
    settings::{Settings, WindowSize},
    sound::Effect,
};

#[derive(Debug, Clone)]
pub struct SettingsScreen {
    pub settings: Settings,
    pub menu: Menu<SettingsScreenItem>,
}

#[derive(Debug, Clone)]
pub enum SettingsScreenItem {
    MainMenuVolume,
    EffectsVolume,
    WindowSize,
    Faucet,
    Logout,
    Back,
}

#[derive(Debug, Clone)]
pub enum SettingsScreenMessage {
    Exit,
    Logout,
    Faucet,
    None,
}

impl SettingsScreen {
    pub fn new() -> Self {
        Self {
            settings: Settings::load(),
            menu: Menu::new(),
        }
    }
}

impl AppComponent for SettingsScreen {
    type Message = SettingsScreenMessage;

    fn handle_key_press(&mut self, key: InputCommand) -> Self::Message {
        match key {
            InputCommand::Up => self.menu.previous_item(),
            InputCommand::Down => self.menu.next_item(),
            InputCommand::Left => self.menu.prev_sub_item(&mut self.settings),
            InputCommand::Right => self.menu.next_sub_item(&mut self.settings),
            InputCommand::Select => match self.menu.selected_item() {
                SettingsScreenItem::Back => return SettingsScreenMessage::Exit,
                SettingsScreenItem::Logout => return SettingsScreenMessage::Logout,
                SettingsScreenItem::Faucet => return SettingsScreenMessage::Faucet,
                _ => {}
            },
            _ => {}
        };

        SettingsScreenMessage::None
    }

    fn tick(&mut self) {
        draw::draw_main_menu_background();
        self.menu.draw();
    }
}

impl Menu<SettingsScreenItem> {
    pub fn new() -> Self {
        Self {
            title: Some("Settings".to_string()),
            items: vec![
                SettingsScreenItem::WindowSize,
                SettingsScreenItem::EffectsVolume,
                SettingsScreenItem::MainMenuVolume,
                SettingsScreenItem::Faucet,
                SettingsScreenItem::Logout,
                SettingsScreenItem::Back,
            ],
            selected_item: 0,
            window: None,
        }
    }

    pub fn next_sub_item(&mut self, settings: &mut Settings) {
        match self.selected_item() {
            SettingsScreenItem::WindowSize => match settings.window_size {
                WindowSize::Small => settings.window_size = WindowSize::Medium,
                WindowSize::Medium => settings.window_size = WindowSize::Large,
                WindowSize::Large => settings.window_size = WindowSize::Small,
            },
            SettingsScreenItem::EffectsVolume => {
                settings.effects_volume += 0.1;
                settings.effects_volume = settings.effects_volume.clamp(0.0, 1.0);
                settings.save();

                Effect::Too.play();
            }
            SettingsScreenItem::MainMenuVolume => {
                settings.main_menu_volume += 0.1;
                settings.main_menu_volume = settings.main_menu_volume.clamp(0.0, 1.0);
            }
            SettingsScreenItem::Faucet => {}
            SettingsScreenItem::Logout => {}
            SettingsScreenItem::Back => {}
        }

        settings.save()
    }

    pub fn prev_sub_item(&mut self, settings: &mut Settings) {
        match self.selected_item() {
            SettingsScreenItem::WindowSize => match settings.window_size {
                WindowSize::Small => settings.window_size = WindowSize::Large,
                WindowSize::Medium => settings.window_size = WindowSize::Small,
                WindowSize::Large => settings.window_size = WindowSize::Medium,
            },
            SettingsScreenItem::EffectsVolume => {
                settings.effects_volume -= 0.1;
                settings.effects_volume = settings.effects_volume.clamp(0.0, 1.0);
                settings.save();

                Effect::Too.play();
            }
            SettingsScreenItem::MainMenuVolume => {
                settings.main_menu_volume -= 0.1;
                settings.main_menu_volume = settings.main_menu_volume.clamp(0.0, 1.0);
            }
            SettingsScreenItem::Faucet => {}
            SettingsScreenItem::Logout => {}
            SettingsScreenItem::Back => {}
        }

        settings.save()
    }

    pub fn previous_sub_item(&mut self) {
        self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len();
    }
}

impl Display for SettingsScreenItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SettingsScreenItem::WindowSize => write!(f, "Window Size"),
            SettingsScreenItem::EffectsVolume => write!(f, "Effects Volume"),
            SettingsScreenItem::MainMenuVolume => write!(f, "Main Menu Volume"),
            SettingsScreenItem::Faucet => write!(f, "Open Faucet"),
            SettingsScreenItem::Logout => write!(f, "Logout"),
            SettingsScreenItem::Back => write!(f, "Back"),
        }
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
