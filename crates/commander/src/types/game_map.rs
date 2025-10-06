// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{cell::RefCell, rc::Rc};

use macroquad::prelude::*;

use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{Asset, Draw, DrawAt, DrawCommand, Sprite, Texture, ZIndex, get_scale},
    types::{Direction, ID, Map, Tile, TileType, Unit},
};

#[derive(Clone)]
/// Game Map is a transformed instance of the `Map` type defined in Move.
pub struct GameMap {
    pub grid: Vec<Vec<GameTile>>,
    pub units: Vec<Rc<RefCell<Unit>>>,
    pub turn: u16,
}

#[derive(Clone)]
/// Transformed instance of a single `Tile` from the `Map` type. Unlike `Tile`,
/// the unit is a `Rc<Unit>` to allow for sharing the same unit instance between
/// tiles.
pub struct GameTile {
    pub unit: Option<Rc<RefCell<Unit>>>,
    pub tile_type: TileType,
}

#[derive(Debug, Clone)]
/// A single target which can be attacked by a unit.
pub struct Target {
    pub position: (u8, u8),
    pub range: u8,
    pub chance: Option<u8>,
    pub target_id: ID,
}

impl GameMap {
    /// Create a new `Map` with given dimensions. Only used in `Editor` mode,
    /// actual Game and Replay maps are deserialized from grpc object query
    /// responses.
    pub fn new(width: u8, height: u8) -> Self {
        Self {
            grid: vec![
                vec![
                    GameTile {
                        unit: None,
                        tile_type: TileType::Empty
                    };
                    width as usize
                ];
                height as usize
            ],
            units: Vec::new(),
            turn: 0,
        }
    }

    pub fn next_turn(&mut self, update_units: bool) {
        self.turn += 1;

        if update_units {
            for row in self.grid.iter_mut() {
                for tile in row.iter_mut() {
                    if let Some(unit) = &tile.unit {
                        unit.borrow_mut().ap.reset();
                        unit.borrow_mut().last_turn = self.turn;

                        println!("Reset AP for unit: {:?}", unit.borrow().ap);
                    }
                }
            }
        }
    }

    pub fn dimensions(&self) -> (u8, u8) {
        (self.cols(), self.rows())
    }

    pub fn rows(&self) -> u8 {
        self.grid.len() as u8
    }

    pub fn cols(&self) -> u8 {
        self.grid[0].len() as u8
    }

    pub fn unit_position(&self, unit: &Unit) -> Option<(u8, u8)> {
        self.grid.iter().enumerate().find_map(|(x, row)| {
            row.iter().enumerate().find_map(|(y, tile)| {
                if let Some(tile_unit) = &tile.unit {
                    if tile_unit.borrow().recruit == unit.recruit {
                        return Some((x as u8, y as u8));
                    }
                }

                None
            })
        })
    }

    pub fn targets(&self, origin: (u8, u8)) -> Vec<Target> {
        let mut targets = Vec::new();
        let unit = &self.grid[origin.0 as usize][origin.1 as usize].unit;

        for (x, row) in self.grid.iter().enumerate() {
            for (y, tile) in row.iter().enumerate() {
                let range = self.manhattan_distance((x as u8, y as u8), origin);
                if origin == (x as u8, y as u8) {
                    continue;
                }

                if let Some(target) = &tile.unit {
                    targets.push(Target {
                        position: (x as u8, y as u8),
                        range,
                        chance: unit.clone().map(|unit| chance(&unit.borrow(), range)),
                        target_id: target.borrow().recruit,
                    });
                }
            }
        }
        targets
    }

    pub fn cherbyshev_distance(&self, origin: (u8, u8), target: (u8, u8)) -> u8 {
        let (x0, y0) = origin;
        let (x1, y1) = target;
        x0.abs_diff(x1).max(y0.abs_diff(y1))
    }

    pub fn manhattan_distance(&self, origin: (u8, u8), target: (u8, u8)) -> u8 {
        let (x0, y0) = origin;
        let (x1, y1) = target;
        x0.abs_diff(x1) + y0.abs_diff(y1)
    }

    /// Use a Dijkstra algorithm to trace a path from `start` to `target` with a
    /// given `limit`. Use already computed `walkable_tiles` to speed up the
    /// algorithm.
    pub fn trace_path(&self, start: (u8, u8), target: (u8, u8)) -> Option<Vec<(u8, u8)>> {
        let mut map = vec![vec![0; self.cols() as usize]; self.rows() as usize];
        let mut queue = vec![start];
        let mut num = 1;

        if start == target {
            return Some(vec![]);
        }

        map[start.0 as usize][start.1 as usize] = num;

        'path: while !queue.is_empty() {
            let temp_queue = queue.drain(..).collect::<Vec<(u8, u8)>>();
            num += 1;

            for (nx, ny) in temp_queue {
                for (x, y) in self.von_neumann(nx, ny) {
                    let to = &self.grid[x as usize][y as usize];
                    let from = &self.grid[nx as usize][ny as usize];
                    let direction = Direction::from_coords((nx, ny), (x, y));

                    // if the tile is already visited, skip
                    // if the tile is an obstacle, skip
                    // if the tile is a unit, skip
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

                    if x == target.0 && y == target.1 {
                        map[x as usize][y as usize] = num;
                        break 'path;
                    }

                    map[x as usize][y as usize] = num;
                    queue.push((x, y));
                }
            }
        }

        if map[target.0 as usize][target.1 as usize] == 0 {
            return None;
        }

        let (mut nx, mut ny) = target;
        let mut path = vec![target];
        let mut num2 = map[target.0 as usize][target.1 as usize];

        while num2 > 1 {
            for (x, y) in self.von_neumann(nx, ny) {
                if map[x as usize][y as usize] == num2 - 1 {
                    let direction = Direction::from_coords((nx, ny), (x, y));
                    let from = &self.grid[nx as usize][ny as usize];
                    let to = &self.grid[x as usize][y as usize];

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

                    nx = x;
                    ny = y;

                    path.push((x, y));
                    num2 -= 1;
                    break;
                }
            }
        }

        path.reverse();
        Some(path)
    }

    pub fn walkable_tiles(&self, start: (u8, u8), limit: u8) -> Vec<(u8, u8)> {
        let mut tiles = Vec::new();
        let mut map = vec![vec![0; self.cols() as usize]; self.rows() as usize];
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
        let (rows, cols) = self.dimensions();

        if x < rows - 1 {
            points.push((x + 1, y));
        }

        if y < cols - 1 {
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

impl From<Map> for GameMap {
    fn from(map: Map) -> Self {
        let mut units = Vec::new();
        let Map { id: _, grid, turn } = map;

        let grid = grid
            .into_iter()
            .map(|row| {
                row.into_iter()
                    .map(|tile| GameTile {
                        unit: tile.unit.map(|unit| {
                            let unit = Rc::new(RefCell::new(unit));
                            units.push(unit.clone());
                            unit
                        }),
                        tile_type: tile.tile_type,
                    })
                    .collect::<Vec<_>>()
            })
            .collect();

        Self { grid, units, turn }
    }
}

impl Into<Map> for GameMap {
    fn into(self) -> Map {
        let id = ID::default();
        let GameMap { grid, turn, .. } = self;
        let grid = grid
            .into_iter()
            .map(|row| {
                row.into_iter()
                    .map(|tile| Tile {
                        unit: tile.unit.map(|unit| unit.borrow().clone()),
                        tile_type: tile.tile_type,
                    })
                    .collect()
            })
            .collect();

        Map { id, grid, turn }
    }
}

impl Draw for GameMap {
    fn draw(&self) {
        let (scale_x, scale_y) = get_scale(self.dimensions());
        for (y, row) in self.grid.iter().enumerate() {
            for (x, tile) in row.iter().enumerate() {
                DrawCommand::rectangle_lines(
                    x as f32 * TILE_WIDTH * scale_x,
                    y as f32 * TILE_HEIGHT * scale_y,
                    TILE_WIDTH * scale_x,
                    TILE_HEIGHT * scale_y,
                )
                .color(DARKGRAY)
                .thickness(1.0)
                .z_index(ZIndex::Grid)
                .schedule();

                tile.draw_at((x as u8, y as u8), self.dimensions());
            }
        }
    }
}

impl DrawAt for GameTile {
    fn draw_at(&self, position: (u8, u8), dimensions: (u8, u8)) {
        let (scale_x, scale_y) = get_scale(dimensions);
        let (x, y) = (
            position.0 as f32 * TILE_WIDTH * scale_x,
            position.1 as f32 * TILE_HEIGHT * scale_y,
        );

        match &self.tile_type {
            TileType::Empty => {}
            TileType::Obstacle => {
                let texture = Texture::Obstacle.load().unwrap();

                DrawCommand::texture(texture)
                    .position(x, y)
                    .color(WHITE)
                    .dest_size(Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y))
                    .z_index(ZIndex::Obstacle)
                    .schedule();
            }
            TileType::Cover {
                left,
                right,
                top,
                bottom,
            } => {
                let sprite = Sprite::WallSnow.load().unwrap();
                let (x, y) = (x, y);

                if *left > 0 {
                    sprite
                        .draw_frame_with_index(x, y, 0, WHITE, dimensions, ZIndex::TopCover)
                        .schedule();
                }

                if *top > 0 {
                    sprite
                        .draw_frame_with_index(x, y, 1, WHITE, dimensions, ZIndex::TopCover)
                        .schedule();
                }

                if *right > 0 {
                    sprite
                        .draw_frame_with_index(x, y, 2, WHITE, dimensions, ZIndex::TopCover)
                        .schedule();
                }

                if *bottom > 0 {
                    sprite
                        .draw_frame_with_index(x, y, 3, WHITE, dimensions, ZIndex::BottomCover)
                        .schedule();
                }
            }
        };
    }
}

const CLOSE_DISTANCE_MODIFIER: u8 = 5;
const DISTANCE_MODIFIER: u8 = 10;
// const MAX_DISTANCE_OFFSET: u8 = 3;

fn chance(unit: &Unit, range: u8) -> u8 {
    let aim = unit.stats.aim() as u8;
    let eff_range = unit.stats.range() as u8;

    if range == eff_range {
        return aim;
    } else if range < eff_range {
        return aim + (eff_range - range) * CLOSE_DISTANCE_MODIFIER;
    } else {
        let diff = (range - eff_range) * DISTANCE_MODIFIER;
        return aim - aim.min(diff);
    }
}

#[test]
fn test_game_map() {
    use super::{ID, Tile};

    let mut map = Map {
        id: ID::default(),
        grid: vec![
            vec![
                Tile {
                    unit: None,
                    tile_type: TileType::Empty,
                };
                5
            ];
            5
        ],
        turn: 0,
    };
    map.grid[0][0].unit = Some(Unit::default());

    let mut game_map: GameMap = map.into();

    game_map.grid[0][0].unit.as_mut().unwrap().borrow_mut().ap.0 = 10;

    assert_eq!(game_map.grid[0][0].unit.as_ref().unwrap().borrow().ap.0, 10);
    assert_eq!(game_map.units[0].borrow().ap.0, 10);
}
