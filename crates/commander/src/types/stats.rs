// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct Stats(u128);

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

impl Default for Stats {
    fn default() -> Self {
        Self(0x07_41_0A_00_00_00_00_00_00_00_00_00_00_00_00_00)
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
