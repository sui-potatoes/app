#![allow(dead_code)]
// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

mod game_map;
mod map;
mod path;
mod stats;
mod unit;

pub use game_map::*;
pub use map::*;
pub use path::*;
pub use stats::*;
pub use unit::*;

use std::fmt::Display;

use macroquad::prelude::*;
use serde::{Deserialize, Serialize};
use sui_sdk_types::{Address, ObjectId};

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub struct ID(pub Address);

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

impl Param {
    pub fn new(value: u16, max_value: u16) -> Self {
        Self(value, max_value)
    }

    pub fn value(&self) -> u16 {
        self.0
    }

    pub fn max_value(&self) -> u16 {
        self.1
    }

    pub fn decrease(&mut self, amount: u16) {
        self.0 = self.0.saturating_sub(amount);
    }

    pub fn reset(&mut self) {
        self.0 = self.1;
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
    pub leader: Address,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Preset {
    pub id: ID,
    pub map: Map,
    pub name: String,
    pub positions: Vec<Vec<u8>>,
    pub author: Address,
    pub popularity: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Game {
    pub id: ID,
    pub map: Map,
    pub players: Vec<Address>,
    pub positions: Vec<Vec<u8>>,
    pub history: History,
    pub recruits: (Address, u64),
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

#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum Direction {
    Up,
    Down,
    Left,
    Right,
    None,
}

impl Direction {
    pub fn rotate(&mut self) {
        *self = match self {
            Direction::Up => Direction::Right,
            Direction::Right => Direction::Down,
            Direction::Down => Direction::Left,
            Direction::Left => Direction::Up,
            Direction::None => Direction::Up, // goes to Up and never happens again
        };
    }
}

impl Into<u8> for Direction {
    fn into(self) -> u8 {
        match self {
            Direction::Up => 1,
            Direction::Down => 4,
            Direction::Left => 8,
            Direction::Right => 2,
            Direction::None => 0,
        }
    }
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
    /// Current position of the cursor.
    pub position: (u8, u8),
    /// List of positions visited by the cursor, including the starting position.
    pub history: Vec<(u8, u8)>,
}

impl Cursor {
    pub fn new(position: (u8, u8)) -> Self {
        Self {
            position,
            history: vec![position],
        }
    }

    pub fn position(&self) -> (u8, u8) {
        self.position
    }

    pub fn x(&self) -> u8 {
        self.position.0
    }

    pub fn y(&self) -> u8 {
        self.position.1
    }

    pub fn reset(&mut self, position: (u8, u8)) {
        self.position = position;
        self.history.clear();
        self.history.push(position);
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

impl From<Address> for ID {
    fn from(address: Address) -> Self {
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

impl Default for ID {
    fn default() -> Self {
        Self(Address::ZERO)
    }
}

impl Into<ObjectId> for ID {
    fn into(self) -> ObjectId {
        ObjectId::from(self.0)
    }
}
