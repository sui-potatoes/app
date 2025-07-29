#![allow(unused_variables)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, sync::Mutex};

use lazy_static::lazy_static;
use macroquad::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Texture {
    Background,
    Main,
    Unit,
}

lazy_static! {
    /// Global singleton to access [`LocalStorage`].
    ///
    /// Usage:
    /// ```rust
    /// let storage = &mut quad_storage::STORAGE.lock().unwrap();
    /// ```
    pub static ref TEXTURES: Mutex<HashMap<Texture, Texture2D>> = Mutex::new(Default::default());
}

lazy_static! {
    pub static ref FONTS: Mutex<HashMap<String, Font>> = Mutex::new(Default::default());
}
