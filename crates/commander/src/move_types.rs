#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use sui_types::base_types::SuiAddress;

use crate::draw::{Draw, TEXTURES, Texture};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct ID(pub SuiAddress);

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

#[derive(Debug, Clone, Serialize, Deserialize)]
/// Follows the Move definition of a Map.
pub struct Map {
    pub id: ID,
    pub grid: Vec<Vec<Tile>>,
    pub turn: u16,
}

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq)]
pub struct History(pub Vec<Record>);

#[derive(Debug, Clone, Serialize, Deserialize, Eq, PartialEq)]
pub enum Record {
    /// Header: single action.
    Reload(Vec<u16>),
    /// Header: single action.
    NextTurn(u16),
    /// Header: single action.
    Move(Vec<u8>),
    /// Header: action with effects.
    Attack { origin: Vec<u16>, target: Vec<u16> },
    /// Header: single action.
    RecruitPlaced(u16, u16),
    /// Effect: damage.
    Damage(u8),
    /// Effect: miss.
    Miss,
    /// Effect: explosion.
    Explosion,
    /// Effect: critical hit.
    CriticalHit(u8),
    /// Header: action with effects.
    Grenade(u16, u16, u16),
    /// Effect: unit KIA.
    UnitKIA(ID),
    /// Effect: unit dodged.
    Dodged,
}

impl Display for Record {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Record::Reload(at) => write!(f, "Reload: {:?}", at),
            Record::NextTurn(turn) => write!(f, "Next Turn: {}", turn),
            Record::Move(path) => write!(f, "Move: {:?}", path),
            Record::Attack { origin, target } => write!(f, "Attack: {:?} -> {:?}", origin, target),
            Record::RecruitPlaced(x, y) => write!(f, "Recruit Placed: ({}, {})", x, y),
            Record::Damage(damage) => write!(f, "Damage: {}", damage),
            Record::Miss => write!(f, "Miss"),
            Record::Explosion => write!(f, "Explosion"),
            Record::CriticalHit(damage) => write!(f, "Critical Hit: {}", damage),
            Record::Grenade(x, y, damage) => write!(f, "Grenade: ({}, {}) -> {}", x, y, damage),
            Record::UnitKIA(id) => write!(f, "Unit KIA: {}", id),
            Record::Dodged => write!(f, "Dodged"),
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
/// Stores value and max value of a parameter.
pub struct Param(u16, u16);

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Stats(u128);

impl Default for Stats {
    fn default() -> Self {
        Self(0x07_41_0A_00_00_00_00_00_00_00_00_00_00_00_00_00)
    }
}

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
            recruit: ID(SuiAddress::default()),
            ap: Param(2, 0),
            hp: Param(15, 0),
            ammo: Param(5, 0),
            grenade_used: false,
            stats: Stats::default(),
            last_turn: 0,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Armor {
    pub id: ID,
    pub name: String,
    pub stats: Stats,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum Rank {
    Rookie,
    Squaddie,
    Corporal,
    Sergeant,
    Lieutenant,
    Captain,
    Major,
    Colonel,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Metadata {
    pub name: String,
    pub backstory: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Weapon {
    pub id: ID,
    pub name: String,
    pub stats: Stats,
    pub upgrades: Vec<WeaponUpgrade>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeaponUpgrade {
    pub name: String,
    pub tier: u8,
    pub stats: Stats,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Recruit {
    pub id: ID,
    pub metadata: Metadata,
    pub rank: Rank,
    pub stats: Stats,
    pub weapon: Option<Weapon>,
    pub armor: Option<Armor>,
    pub leader: SuiAddress,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Preset {
    pub id: ID,
    pub map: Map,
    pub name: String,
    pub positions: Vec<Vec<u8>>,
    pub author: SuiAddress,
    pub popularity: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Game {
    pub id: ID,
    pub map: Map,
    pub players: Vec<SuiAddress>,
    pub positions: Vec<Vec<u8>>,
    pub history: History,
    pub recruits: (SuiAddress, u64),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Commander {
    pub id: ID,
    /// List of the 10 most recent games, the index is the ID of the game.
    /// And the value is the timestamp when this game was created.
    pub games: Vec<(ID, u64)>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Replay {
    pub id: ID,
    pub preset_id: ID,
    pub history: History,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum Direction {
    Up,
    Down,
    Left,
    Right,
    None,
}

impl TryFrom<u8> for Direction {
    type Error = ();

    fn try_from(value: u8) -> Result<Self, Self::Error> {
        match value {
            1 => Ok(Self::Up),
            2 => Ok(Self::Right),
            4 => Ok(Self::Down),
            8 => Ok(Self::Left),
            0 => Ok(Self::None),
            _ => Err(()),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Cursor {
    pub position: (u8, u8),
    pub history: Vec<(u8, u8)>,
}

impl Cursor {
    pub fn new(position: (u8, u8)) -> Self {
        Self {
            position,
            history: vec![position],
        }
    }

    pub fn move_to(&mut self, direction: Direction) {
        let new_position = match direction {
            Direction::Up => (self.position.0 - 1, self.position.1),
            Direction::Down => (self.position.0 + 1, self.position.1),
            Direction::Left => (self.position.0, self.position.1 - 1),
            Direction::Right => (self.position.0, self.position.1 + 1),
            Direction::None => self.position,
        };

        self.position = new_position;
        self.history.push(self.position);
    }
}

impl Into<Vec<(u8, u8)>> for Cursor {
    fn into(self) -> Vec<(u8, u8)> {
        self.history
    }
}

/// Stats are a bit field of 10 bytes, each byte is a stat value, encoded as a
/// bit endian integer.
///
/// In Move, due to lack of `i8` support, the stats are `u8` with a custom sign
/// bit handling. In Rust, we can use `i8` directly.
impl Stats {
    pub fn mobility(&self) -> i8 {
        read_u8_at_offset_be(self.0, 0)
    }

    pub fn aim(&self) -> i8 {
        read_u8_at_offset_be(self.0, 1)
    }

    pub fn health(&self) -> i8 {
        read_u8_at_offset_be(self.0, 2)
    }

    pub fn armor(&self) -> i8 {
        read_u8_at_offset_be(self.0, 3)
    }

    pub fn dodge(&self) -> i8 {
        read_u8_at_offset_be(self.0, 4)
    }

    pub fn defense(&self) -> i8 {
        read_u8_at_offset_be(self.0, 5)
    }

    pub fn damage(&self) -> i8 {
        read_u8_at_offset_be(self.0, 6)
    }

    pub fn spread(&self) -> i8 {
        read_u8_at_offset_be(self.0, 7)
    }

    pub fn plus_one(&self) -> i8 {
        read_u8_at_offset_be(self.0, 8)
    }

    pub fn crit_chance(&self) -> i8 {
        read_u8_at_offset_be(self.0, 9)
    }

    pub fn can_be_dodged(&self) -> i8 {
        read_u8_at_offset_be(self.0, 10)
    }

    pub fn area_size(&self) -> i8 {
        read_u8_at_offset_be(self.0, 11)
    }

    pub fn env_damage(&self) -> i8 {
        read_u8_at_offset_be(self.0, 12)
    }

    pub fn range(&self) -> i8 {
        read_u8_at_offset_be(self.0, 13)
    }

    pub fn ammo(&self) -> i8 {
        read_u8_at_offset_be(self.0, 14)
    }

    pub fn inner(&self) -> u128 {
        self.0
    }
}

/// The difference with Move implementation in `bit_field` is that in Rust the
/// `u128` is little endian, so a symmetric function in Move looks differently.
fn read_u8_at_offset_be(value: u128, offset: u8) -> i8 {
    (value >> (8 * (15 - offset)) & 0xFF) as i8
}

impl Map {
    pub fn width(&self) -> u8 {
        self.grid[0].len() as u8
    }

    pub fn height(&self) -> u8 {
        self.grid.len() as u8
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

// === Draw impls ===

impl Draw for Map {
    fn draw(&self) {
        let _offset = 16.0;
        let tile_width = 20.0;
        let thickness = 3.0;
        let color = BLACK;

        let (screen_width, screen_height) = (screen_width(), screen_height());
        let (scale_x, scale_y) = (
            screen_width / (tile_width * self.grid[0].len() as f32),
            screen_height / (tile_width * self.grid.len() as f32),
        );

        for (y, row) in self.grid.iter().enumerate() {
            for (x, tile) in row.iter().enumerate() {
                draw_rectangle_lines(
                    x as f32 * tile_width * scale_x,
                    y as f32 * tile_width * scale_y,
                    tile_width * scale_x,
                    tile_width * scale_y,
                    1.0,
                    DARKGRAY,
                );

                match tile.tile_type {
                    TileType::Empty => {}
                    TileType::Cover {
                        left,
                        top,
                        right,
                        bottom,
                    } => {
                        // Draw the cover as a thin line depending on the cover direction.
                        // Non-zero value means the cover is present in that direction.

                        if left > 0 {
                            draw_line(
                                x as f32 * tile_width * scale_x,
                                y as f32 * tile_width * scale_y,
                                x as f32 * tile_width * scale_x,
                                y as f32 * tile_width * scale_y + tile_width * scale_y,
                                thickness,
                                color,
                            );
                        }

                        if top > 0 {
                            draw_line(
                                x as f32 * tile_width * scale_x,
                                y as f32 * tile_width * scale_y,
                                x as f32 * tile_width * scale_x + tile_width * scale_x,
                                y as f32 * tile_width * scale_y,
                                thickness,
                                color,
                            );
                        }

                        if right > 0 {
                            draw_line(
                                x as f32 * tile_width * scale_x + tile_width * scale_x,
                                y as f32 * tile_width * scale_y,
                                x as f32 * tile_width * scale_x + tile_width * scale_x,
                                y as f32 * tile_width * scale_y + tile_width * scale_y,
                                thickness,
                                color,
                            );
                        }

                        if bottom > 0 {
                            draw_line(
                                x as f32 * tile_width * scale_x + tile_width * scale_x,
                                y as f32 * tile_width * scale_y + tile_width * scale_y,
                                x as f32 * tile_width * scale_x,
                                y as f32 * tile_width * scale_y + tile_width * scale_y,
                                thickness,
                                color,
                            );
                        }
                    }
                    TileType::Obstacle => {
                        draw_rectangle(
                            x as f32 * tile_width * scale_x,
                            y as f32 * tile_width * scale_y,
                            tile_width * scale_x,
                            tile_width * scale_y,
                            color,
                        );
                    }
                }

                // Draw the unit if present.
                if let Some(_unit) = tile.unit {
                    if let Some(texture) = TEXTURES.lock().unwrap().get(&Texture::Unit) {
                        draw_texture_ex(
                            texture,
                            x as f32 * tile_width * scale_x,
                            y as f32 * tile_width * scale_y,
                            WHITE,
                            DrawTextureParams {
                                dest_size: Some(Vec2::new(
                                    tile_width * scale_x,
                                    tile_width * scale_y,
                                )),
                                ..Default::default()
                            },
                        );
                    }
                }
            }
        }
    }
}

impl From<SuiAddress> for ID {
    fn from(address: SuiAddress) -> Self {
        Self(address)
    }
}

// === Display impls ===

impl Display for Rank {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Rank::Rookie => "Rookie",
                Rank::Squaddie => "Squaddie",
                Rank::Corporal => "Corporal",
                Rank::Sergeant => "Sergeant",
                Rank::Lieutenant => "Lieutenant",
                Rank::Captain => "Captain",
                Rank::Major => "Major",
                Rank::Colonel => "Colonel",
            }
        )
    }
}

impl Display for ID {
    /// Split the address into 4 characters at start and 4 at the end.
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let addr = self.0.to_string();
        let start = addr[..4].to_string();
        let end = addr[addr.len() - 4..].to_string();

        write!(f, "{}..{}", start, end)
    }
}

impl Direction {
    pub fn from_coords(from: (u8, u8), to: (u8, u8)) -> Self {
        if from.0 < to.0 {
            Self::Down
        } else if from.0 > to.0 {
            Self::Up
        } else if from.1 < to.1 {
            Self::Right
        } else if from.1 > to.1 {
            Self::Left
        } else {
            Self::None
        }
    }
}

impl Display for Direction {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            match self {
                Direction::Up => "Up",
                Direction::Down => "Down",
                Direction::Left => "Left",
                Direction::Right => "Right",
                Direction::None => "None",
            }
        )
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

#[test]
fn test_stats() {
    // 7, 65, 10, 0, 0
    let stats = Stats(0x07_41_0A_00_00_00_00_00_00_00_00_00_00_00_00_00);

    assert_eq!(stats.mobility(), 7);
    assert_eq!(stats.aim(), 65);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.defense(), 0);

    assert_eq!(stats.damage(), 0);
    assert_eq!(stats.spread(), 0);
    assert_eq!(stats.plus_one(), 0);
    assert_eq!(stats.crit_chance(), 0);
    assert_eq!(stats.can_be_dodged(), 0);
    assert_eq!(stats.area_size(), 0);
    assert_eq!(stats.env_damage(), 0);
    assert_eq!(stats.range(), 0);
    assert_eq!(stats.ammo(), 0);

    let weapon_stats = Stats(0x00_00_00_00_00_00_04_02_00_00_01_01_00_04_03_00);

    assert_eq!(weapon_stats.mobility(), 0);
    assert_eq!(weapon_stats.aim(), 0);
    assert_eq!(weapon_stats.health(), 0);
    assert_eq!(weapon_stats.armor(), 0);
    assert_eq!(weapon_stats.dodge(), 0);
    assert_eq!(weapon_stats.defense(), 0);

    assert_eq!(weapon_stats.damage(), 4);
    assert_eq!(weapon_stats.spread(), 2);
    assert_eq!(weapon_stats.plus_one(), 0);
    assert_eq!(weapon_stats.crit_chance(), 0);
    assert_eq!(weapon_stats.can_be_dodged(), 1);
    assert_eq!(weapon_stats.area_size(), 1);
    assert_eq!(weapon_stats.env_damage(), 0);
    assert_eq!(weapon_stats.range(), 4);
    assert_eq!(weapon_stats.ammo(), 3);
}
