// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use super::{Direction, ID, Tile, TileType};
use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{Draw, DrawAt, get_scale},
};

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
/// Follows the Move definition of a Map.
pub struct Map {
    pub id: ID,
    pub grid: Vec<Vec<Tile>>,
    pub turn: u16,
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

    pub fn width(&self) -> u8 {
        self.cols()
    }

    pub fn height(&self) -> u8 {
        self.rows()
    }

    pub fn walkable_tiles(&self, start: (u8, u8), limit: u8) -> Vec<(u8, u8)> {
        let mut tiles = Vec::new();
        let mut map = vec![vec![0; self.width() as usize]; self.height() as usize];
        let mut queue = vec![start];
        let mut num = 1;

        map[start.0 as usize][start.1 as usize] = num;

        while !queue.is_empty() {
            let temp_queue = queue.drain(..).collect::<Vec<(u8, u8)>>();
            num += 1;

            if num > limit + 1 {
                break;
            }

            for (nx, ny) in temp_queue {
                for (x, y) in self.von_neumann(nx, ny) {
                    let to = &self.grid[x as usize][y as usize];
                    let from = &self.grid[nx as usize][ny as usize];
                    let direction = Direction::from_coords((nx, ny), (x, y));

                    if to.unit.is_some()
                        || matches!(to.tile_type, TileType::Obstacle)
                        || map[x as usize][y as usize] != 0
                    {
                        continue;
                    }

                    if let TileType::Cover {
                        left,
                        top,
                        right,
                        bottom,
                    } = to.tile_type
                    {
                        match direction {
                            Direction::Up if bottom > 0 => continue,
                            Direction::Down if top > 0 => continue,
                            Direction::Left if right > 0 => continue,
                            Direction::Right if left > 0 => continue,
                            _ => {}
                        }
                    }

                    if let TileType::Cover {
                        left,
                        top,
                        right,
                        bottom,
                    } = from.tile_type
                    {
                        match direction {
                            Direction::Up if top > 0 => continue,
                            Direction::Down if bottom > 0 => continue,
                            Direction::Left if left > 0 => continue,
                            Direction::Right if right > 0 => continue,
                            _ => {}
                        }
                    }

                    if map[x as usize][y as usize] == 0 {
                        map[x as usize][y as usize] = num;
                        queue.push((x, y));
                        tiles.push((x, y));
                    }
                }
            }
        }

        tiles
    }

    fn coords_to_direction(&self, from: (u8, u8), to: (u8, u8)) -> Direction {
        let (x0, y0) = from;
        let (x1, y1) = to;

        if x0 < x1 {
            Direction::Down
        } else if x0 > x1 {
            Direction::Up
        } else if y0 > y1 {
            Direction::Left
        } else if y0 < y1 {
            Direction::Right
        } else {
            panic!("Invalid direction");
        }
    }

    fn von_neumann(&self, x: u8, y: u8) -> Vec<(u8, u8)> {
        let mut points = Vec::new();

        if x < self.height() - 1 {
            points.push((x + 1, y));
        }

        if y < self.width() - 1 {
            points.push((x, y + 1));
        }

        if x > 0 {
            points.push((x - 1, y));
        }

        if y > 0 {
            points.push((x, y - 1));
        }

        points
    }
}

impl Draw for Map {
    fn draw(&self) {
        let (scale_x, scale_y) = get_scale((self.width(), self.height()));
        for (y, row) in self.grid.iter().enumerate() {
            for (x, tile) in row.iter().enumerate() {
                draw_rectangle_lines(
                    x as f32 * TILE_WIDTH * scale_x,
                    y as f32 * TILE_WIDTH * scale_y,
                    TILE_WIDTH * scale_x,
                    TILE_HEIGHT * scale_y,
                    1.0,
                    DARKGRAY,
                );

                tile.draw_at((x as u8, y as u8), (self.width(), self.height()));
            }
        }
    }
}
