// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use super::{ID, Param, Stats};

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
