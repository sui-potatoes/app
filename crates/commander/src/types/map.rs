// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use super::{ID, Unit};

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
/// Follows the Move definition of a Map.
pub struct Map {
    pub id: ID,
    pub grid: Vec<Vec<Tile>>,
    pub turn: u16,
}

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

impl Map {
    pub fn dimensions(&self) -> (u8, u8) {
        (self.cols(), self.rows())
    }

    pub fn rows(&self) -> u8 {
        self.grid.len() as u8
    }

    pub fn cols(&self) -> u8 {
        self.grid[0].len() as u8
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
