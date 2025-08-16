// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{self, ASSETS, DrawAt, DrawCommand, Sprite, Texture, get_scale},
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
                draw::request_draw(DrawCommand::Texture {
                    texture: ASSETS
                        .with(|assets| assets.get().unwrap().texture(Texture::Obstacle).unwrap())
                        .clone(),
                    x,
                    y,
                    color: WHITE,
                    params: DrawTextureParams {
                        dest_size: Some(Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y)),
                        ..Default::default()
                    },
                    z_index: 10,
                });
            }
            TileType::Cover {
                left,
                right,
                top,
                bottom,
            } => {
                let sprite = ASSETS
                    .with(|assets| {
                        assets
                            .get()
                            .unwrap()
                            .sprite_sheet(Sprite::WallSnow)
                            .unwrap()
                    })
                    .clone();

                if *left > 0 {
                    sprite.draw_frame_with_index(x, y, 0, dimensions, 0);
                }

                if *top > 0 {
                    sprite.draw_frame_with_index(x, y, 1, dimensions, 0);
                }

                if *right > 0 {
                    sprite.draw_frame_with_index(x, y, 2, dimensions, 0);
                }

                // Draw the unit if present before the bottom cover.
                self.unit
                    .as_ref()
                    .and_then(|unit| Some(unit.draw_at(position, dimensions)));

                if *bottom > 0 {
                    sprite.draw_frame_with_index(x, y, 3, dimensions, 10);
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
