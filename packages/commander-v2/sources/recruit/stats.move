// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Attempt to replace the `Stats` struct with a single `u64` value which uses
/// bit manipulation to store all the stats at right positions.
module commander::stats;

use sui::bcs::{Self, BCS};

/// Max mobility value, in tiles.
const MAX_MOBILITY: u8 = 30;
/// Max aim value %.
const MAX_AIM: u8 = 100;
/// Max willpower value %.
const MAX_WILL: u8 = 100;
/// Max health value, in health points.
const MAX_HEALTH: u8 = 30;
/// Max armor value, in armor points.
const MAX_ARMOR: u8 = 10;
/// Dodge chance %.
const MAX_DODGE: u8 = 100;

/// Error code for incorrect value passed into `new` function.
const EIncorrectValue: u64 = 1;

/// The `BitStats` struct is a single `u64` value that stores all the stats of
/// a `Recruit` in a single value. It uses bit manipulation to store the values
/// at the right positions.
///
/// Order (8bit each):
/// - version: 10
/// - mobility
/// - aim
/// - will
/// - health
/// - armor
/// - dodge
/// - hack
public struct Stats(u64) has copy, drop, store;

/// Create a new `BitStats` struct with the given values.
public fun new(mobility: u8, aim: u8, will: u8, health: u8, armor: u8, dodge: u8, hack: u8): Stats {
    assert!(mobility < MAX_MOBILITY, EIncorrectValue);
    assert!(health < MAX_HEALTH, EIncorrectValue);
    assert!(aim < MAX_AIM, EIncorrectValue);
    assert!(will < MAX_WILL, EIncorrectValue);
    assert!(armor < MAX_ARMOR, EIncorrectValue);
    assert!(dodge < MAX_DODGE, EIncorrectValue);

    let mut stats: u64 = 0;

    // first byte is a version header, starting with 10
    stats = stats | 10u64 << 0;
    stats = stats | (mobility as u64) << 8;
    stats = stats | (aim as u64) << 16;
    stats = stats | (will as u64) << 24;
    stats = stats | (health as u64) << 32;
    stats = stats | (armor as u64) << 40;
    stats = stats | (dodge as u64) << 48;
    stats = stats | (hack as u64) << 56;

    Stats(stats)
}

/// Default stats for a Recruit.
public fun default(): Stats { new(7, 65, 65, 10, 0, 0, 0) }

/// Get the version of the `Stats`, first 8 bits.
public fun version(stats: &Stats): u8 { (stats.0 & 0xFF) as u8 }

/// Get the mobility of the `Stats`.
public fun mobility(stats: &Stats): u8 { (stats.0 >> 8 & 0xFF) as u8 }

/// Get the aim of the `Stats`.
public fun aim(stats: &Stats): u8 { (stats.0 >> 16 & 0xFF) as u8 }

/// Get the will of the `Stats`.
public fun will(stats: &Stats): u8 { (stats.0 >> 24 & 0xFF) as u8 }

/// Get the health of the `Stats`.
public fun health(stats: &Stats): u8 { (stats.0 >> 32 & 0xFF) as u8 }

/// Get the armor of the `Stats`.
public fun armor(stats: &Stats): u8 { (stats.0 >> 40 & 0xFF) as u8 }

/// Get the dodge of the `Stats`.
public fun dodge(stats: &Stats): u8 { (stats.0 >> 48 & 0xFF) as u8 }

/// Get the hack of the `Stats`.
public fun hack(stats: &Stats): u8 { (stats.0 >> 56 & 0xFF) as u8 }

// === Convenience and compatibility ===

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Stats {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): Stats {
    Stats(bcs.peel_u64())
}

#[test]
fun test_stats() {
    use std::unit_test::assert_eq;

    let stats = Self::new(
        7, // mobility
        50, // aim
        60, // will
        10, // health
        0, // armor
        0, // dodge
        0, // hack
    );

    assert_eq!(stats.version(), 10);
    assert_eq!(stats.mobility(), 7);
    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.will(), 60);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.hack(), 0);
}
