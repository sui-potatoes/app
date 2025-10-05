// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, path::Path, rc::Rc, sync::Arc};

use macroquad::audio::{PlaySoundParams, Sound, load_sound, play_sound, stop_sound};
use macroquad::prelude::*;

use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

use crate::draw::Asset;

thread_local! {
    pub static SOUNDS: OnceCell<Arc<SoundStore>> = OnceCell::new();
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
        let da_ta = load_sound(sound_path("da-ta.wav").as_str()).await.unwrap();
        let ta_da = load_sound(sound_path("ta-da.wav").as_str()).await.unwrap();
        let too = load_sound(sound_path("too.wav").as_str()).await.unwrap();

        self.effects.insert(Effect::Data, Rc::new(da_ta));
        self.effects.insert(Effect::Tada, Rc::new(ta_da));
        self.effects.insert(Effect::Too, Rc::new(too));

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
                volume: 1.0,
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
                volume: 0.7,
            },
        );
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
