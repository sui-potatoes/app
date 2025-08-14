// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{ASSETS, DrawAt, Sprite, Texture, get_scale},
};

use super::Unit;

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
/// A single in-game Tile.
pub struct Tile {
    pub tile_type: TileType,
    pub unit: Option<Unit>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum TileType {
    Empty,
    Cover {
        left: u8,
        top: u8,
        right: u8,
        bottom: u8,
    },
    Obstacle,
}

impl DrawAt for Tile {
    fn draw_at(&self, position: (u8, u8), dimensions: (u8, u8)) {
        let (scale_x, scale_y) = get_scale(dimensions);
        let (x, y) = (
            position.0 as f32 * TILE_WIDTH * scale_x,
            position.1 as f32 * TILE_HEIGHT * scale_y,
        );

        match &self.tile_type {
            TileType::Empty => {
                // Draw the unit if present.
                self.unit
                    .as_ref()
                    .and_then(|unit| Some(unit.draw_at(position, dimensions)));
            }
            TileType::Obstacle => {
                draw_texture_ex(
                    ASSETS.get().unwrap().texture(Texture::Obstacle).unwrap(),
                    x,
                    y,
                    WHITE,
                    DrawTextureParams {
                        dest_size: Some(Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y)),
                        ..Default::default()
                    },
                );
            }
            TileType::Cover {
                left,
                right,
                top,
                bottom,
            } => {
                let sprite = ASSETS.get().unwrap().sprite_sheet(Sprite::Wall).unwrap();

                if *left > 0 {
                    sprite.draw_frame(x, y, 0, dimensions);
                }

                if *top > 0 {
                    sprite.draw_frame(x, y, 1, dimensions);
                }

                if *right > 0 {
                    sprite.draw_frame(x, y, 2, dimensions);
                }

                // Draw the unit if present before the bottom cover.
                self.unit
                    .as_ref()
                    .and_then(|unit| Some(unit.draw_at(position, dimensions)));

                if *bottom > 0 {
                    sprite.draw_frame(x, y, 3, dimensions);
                }
            }
        };
    }
}

impl Display for TileType {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                TileType::Empty => "Empty",
                TileType::Cover { .. } => "Cover",
                TileType::Obstacle => "Obstacle",
            }
        )
    }
}
