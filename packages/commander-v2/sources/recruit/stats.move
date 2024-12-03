// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the stats of a recruit, similar to the stats in the XCom game, stats
/// are a part of the `Recruit` struct and define available actions and their
/// parameters.
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

/// Defines the stats of the Recruit, similar to the stats in the XCom game.
public struct Stats has copy, drop, store {
    /// Number of tiles a Recruit can move in a single action (normally, there
    /// can be up to two actions per turn).
    mobility: u8,
    /// Aim of the Recruit, value between 0 and 100, can be modified by the
    /// weapon and other factors.
    aim: u8,
    /// Willpower of the Recruit.
    will: u8,
    /// Max health of the Recruit.
    health: u8,
    /// Armor of the Recruit.
    armor: u8,
    /// Dodge of the Recruit.
    dodge: u8,
    /// Hack of the Recruit.
    hack: u8,
}

/// Create a new `Stats` struct with the given values.
public fun new(mobility: u8, aim: u8, will: u8, health: u8, armor: u8, dodge: u8, hack: u8): Stats {
    assert!(mobility < MAX_MOBILITY, EIncorrectValue);
    assert!(health < MAX_HEALTH, EIncorrectValue);
    assert!(aim < MAX_AIM, EIncorrectValue);
    assert!(will < MAX_WILL, EIncorrectValue);
    assert!(armor < MAX_ARMOR, EIncorrectValue);
    assert!(dodge < MAX_DODGE, EIncorrectValue);

    Stats { mobility, aim, will, health, armor, dodge, hack }
}

/// Default stats for a Recruit.
public fun default(): Stats {
    Stats {
        mobility: 5,
        aim: 65,
        will: 40,
        health: 5,
        armor: 0,
        dodge: 0,
        hack: 0,
    }
}

/// Get the aim of the Recruit.
public fun aim(stats: &Stats): u8 { stats.aim }

/// Get the mobility of the Recruit.
public fun mobility(stats: &Stats): u8 { stats.mobility }

/// Get the willpower of the Recruit.
public fun will(stats: &Stats): u8 { stats.will }

/// Get the health of the Recruit.
public fun health(stats: &Stats): u8 { stats.health }

/// Get the armor of the Recruit.
public fun armor(stats: &Stats): u8 { stats.armor }

/// Get the dodge of the Recruit.
public fun dodge(stats: &Stats): u8 { stats.dodge }

/// Get the hack of the Recruit.
public fun hack(stats: &Stats): u8 { stats.hack }

// === Convenience and compatibility ===

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Stats {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): Stats {
    Stats {
        mobility: bcs.peel_u8(),
        aim: bcs.peel_u8(),
        will: bcs.peel_u8(),
        health: bcs.peel_u8(),
        armor: bcs.peel_u8(),
        dodge: bcs.peel_u8(),
        hack: bcs.peel_u8(),
    }
}

#[test]
fun test_stats() {
    use std::unit_test::assert_eq;

    let stats = Self::new(10, 50, 50, 10, 0, 0, 0);

    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.mobility(), 10);
    assert_eq!(stats.will(), 50);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.hack(), 0);

    let stats = Self::default();

    assert_eq!(stats.aim(), 65);
    assert_eq!(stats.mobility(), 5);
    assert_eq!(stats.will(), 40);
    assert_eq!(stats.health(), 5);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.hack(), 0);

    // compare deserialized stats with the original
    assert_eq!(stats, Self::from_bytes(bcs::to_bytes(&stats)));
}
