// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, path::Path, rc::Rc, sync::Arc};

use macroquad::audio::{
    PlaySoundParams, Sound, load_sound, play_sound, set_sound_volume, stop_sound,
};
use macroquad::prelude::*;

use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

use crate::draw::Asset;
use crate::settings::Settings;

thread_local! {
    pub static SOUNDS: OnceCell<Arc<SoundStore>> = OnceCell::new();
}

macro_rules! load_and_register_effect {
    (
        $map:expr,
        $key:expr,
        $file:literal
    ) => {
        let sound = load_sound(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join("assets/sounds")
                .join($file)
                .to_str()
                .unwrap(),
        )
        .await
        .unwrap();

        $map.insert($key, Rc::new(sound));
    };
}

#[derive(Debug, Clone)]
pub struct SoundStore {
    pub effects: HashMap<Effect, Rc<Sound>>,
    pub background: HashMap<Background, Rc<Sound>>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Effect {
    Too,
    Tada,
    Data,
    VoiceAttack,
    VoiceCommander,
    VoiceMovingToTheTarget,
    VoiceWillDo,
    VoiceYes,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Background {
    Main,
}

impl SoundStore {
    pub fn new() -> Self {
        Self {
            effects: HashMap::new(),
            background: HashMap::new(),
        }
    }

    pub async fn load_all(&mut self) {
        load_and_register_effect!(self.effects, Effect::Data, "da-ta.wav");
        load_and_register_effect!(self.effects, Effect::Tada, "ta-da.wav");
        load_and_register_effect!(self.effects, Effect::Too, "too.wav");
        load_and_register_effect!(self.effects, Effect::VoiceAttack, "voice/attack.wav");
        load_and_register_effect!(self.effects, Effect::VoiceCommander, "voice/commander.wav");
        load_and_register_effect!(
            self.effects,
            Effect::VoiceMovingToTheTarget,
            "voice/moving-to-the-target.wav"
        );
        load_and_register_effect!(self.effects, Effect::VoiceWillDo, "voice/will-do.wav");
        load_and_register_effect!(self.effects, Effect::VoiceYes, "voice/yes.wav");

        let main = load_sound(sound_path("main.wav").as_str()).await.unwrap();
        self.background.insert(Background::Main, Rc::new(main));
    }
}

impl Asset for Effect {
    type AssetType = Sound;

    fn load(&self) -> Option<Rc<Self::AssetType>> {
        SOUNDS.with(|assets| assets.get().unwrap().effects.get(self).cloned())
    }
}

impl Asset for Background {
    type AssetType = Sound;

    fn load(&self) -> Option<Rc<Self::AssetType>> {
        SOUNDS.with(|assets| assets.get().unwrap().background.get(self).cloned())
    }
}

impl Effect {
    pub fn play(&self) {
        let sound = self.load().unwrap();
        play_sound(
            sound.as_ref(),
            PlaySoundParams {
                volume: Settings::load().effects_volume as f32 / 100.0,
                looped: false,
            },
        );
    }
}

impl Background {
    pub fn play(&self) {
        let sound = self.load().unwrap();
        play_sound(
            sound.as_ref(),
            PlaySoundParams {
                looped: true,
                volume: Settings::load().main_menu_volume as f32 / 100.0,
            },
        );
    }

    pub fn set_volume(&self, volume: f32) {
        let sound = self.load().unwrap();
        set_sound_volume(sound.as_ref(), volume);
    }

    pub fn stop(&self) {
        let sound = self.load().unwrap();
        stop_sound(sound.as_ref());
    }
}

fn sound_path(path: &str) -> String {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("assets/sounds")
        .join(path)
        .to_str()
        .unwrap()
        .to_string()
}

pub fn random_effect(effects: &[Effect]) {
    let index = rand::gen_range(0, effects.len());
    let effect = effects[index];
    effect.play();
}
