// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use super::{ID, Param, Stats};
use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{ASSETS, DrawAt, Sprite, Texture, get_scale},
};

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use sui_sdk_types::Address;

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Unit {
    pub recruit: ID,
    pub ap: Param,
    pub hp: Param,
    pub ammo: Param,
    pub grenade_used: bool,
    pub stats: Stats,
    pub last_turn: u16,
}

impl Default for Unit {
    fn default() -> Self {
        Self {
            recruit: ID(Address::ZERO),
            ap: Param(2, 0),
            hp: Param(15, 0),
            ammo: Param(5, 0),
            grenade_used: false,
            stats: Stats::default(),
            last_turn: 0,
        }
    }
}

impl Display for Unit {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Unit: {}", self.recruit)
    }
}

impl DrawAt for Unit {
    fn draw_at(&self, position: (u8, u8), dimensions: (u8, u8)) {
        let (scale_x, scale_y) = get_scale(dimensions);
        let (x, y) = (
            position.0 as f32 * TILE_WIDTH * scale_x,
            position.1 as f32 * TILE_HEIGHT * scale_y,
        );
        if let Some(sprite) = ASSETS.get().unwrap().sprite_sheet(Sprite::UnitSoldier) {
            let frame = (get_time() * 10.0 % sprite.frames as f64) as usize;
            sprite.draw_frame(x, y, frame, dimensions);
        } else {
            draw_rectangle_ex(
                x,
                y,
                TILE_WIDTH * scale_x,
                TILE_HEIGHT * scale_y,
                DrawRectangleParams::default(),
            );
        }
    }
}
