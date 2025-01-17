// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Attempt to replace the `Stats` struct with a single `u64` value which uses
/// bit manipulation to store all the stats at right positions.
module commander::stats;

use sui::bcs::{Self, BCS};
use std::macros::num_min;

/// Capped at 7 bits. Max value for signed 8-bit integers.
const SIGN_VALUE: u64 = 128;
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
/// Hack value %.
const MAX_HACK: u8 = 100;
/// Default version of the `Stats`.
const VERSION: u64 = 10;

/// Error code for incorrect value passed into `new` function.
const EIncorrectValue: u64 = 1;
/// Modifier version does not match the stats version.
const EVersionMismatch: u64 = 2;

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

/// Modifier is a single `u64` value that replicates the structure of the `Stats`,
/// but is used to store the modifiers for the stats as signed integers. Modifiers
/// are applied to the base stats of the Recruit to calculate the final stats.
public struct Modifier(u64) has copy, drop, store;

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
    stats = stats | VERSION << 0;
    stats = stats | (mobility as u64) << 8;
    stats = stats | (aim as u64) << 16;
    stats = stats | (will as u64) << 24;
    stats = stats | (health as u64) << 32;
    stats = stats | (armor as u64) << 40;
    stats = stats | (dodge as u64) << 48;
    stats = stats | (hack as u64) << 56;

    Stats(stats)
}

/// Create a new `Modifier` struct with the given values. Values are passed in
/// as signed integers: if the value is bigger than 128, it is subtracted from
/// the base stats, if it is smaller than 128, it is added to the base stats.
///
/// Modifiers cannot overflow the base stats, and the values are capped at their
/// corresponding maximum values.
public fun new_modifier(
    mobility: u8,
    aim: u8,
    will: u8,
    health: u8,
    armor: u8,
    dodge: u8,
    hack: u8,
): Modifier {
    let mut modifier: u64 = 0;

    modifier = modifier | VERSION << 0;
    modifier = modifier | (mobility as u64) << 8;
    modifier = modifier | (aim as u64) << 16;
    modifier = modifier | (will as u64) << 24;
    modifier = modifier | (health as u64) << 32;
    modifier = modifier | (armor as u64) << 40;
    modifier = modifier | (dodge as u64) << 48;
    modifier = modifier | (hack as u64) << 56;

    Modifier(modifier)
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

/// Get the inner `u64` value of the `Stats`. Can be used for performance
/// optimizations and macros.
public fun inner(stats: &Stats): u64 { stats.0 }

// === Modifier ===

/// Apply the modifier to the stats and return the modified value. Each value in
/// the `Modifier` can be positive or negative (the first sign bit is used), and
/// the value (0-127) is added or subtracted from the base stats.
///
/// The result can never overflow the base stats, and the values are capped at
/// the maximum values for each stat.
public fun apply_modifier(stats: &Stats, modifier: &Modifier): Stats {
    let mut stats = stats.0;
    let modifier = modifier.0;
    let sign = SIGN_VALUE;

    assert!(stats >> 0 & 0xFF == modifier >> 0 & 0xFF, EVersionMismatch);

    // version is not modified, the rest of the values are modified
    // based on the signed values of the modifier
    7u8.do!(|i| {
        let offset = i * 8 + 8;
        let modifier = modifier >> offset & 0xFF;

        // skip 0 and -0 values
        if (modifier == 0 || modifier == sign) return;

        // update the value based on the modifier, either add or subtract
        let value = stats >> offset & 0xFF;
        let reset_mask = 0xFFFFFFFFFFFFFFFF ^ (0xFF << offset);
        let new_value = if (modifier > sign) {
            (value - num_min!(modifier - sign, value) as u64)
        } else {
            ((stats >> offset & 0xFF) + modifier)
        };

        // prettier-ignore
        stats = stats & reset_mask | match (i) {
            0 => num_min!(new_value, MAX_MOBILITY as u64),
            1 => num_min!(new_value, MAX_AIM as u64),
            2 => num_min!(new_value, MAX_WILL as u64),
            3 => num_min!(new_value, MAX_HEALTH as u64),
            4 => num_min!(new_value, MAX_ARMOR as u64),
            5 => num_min!(new_value, MAX_DODGE as u64),
            6 => num_min!(new_value, MAX_HACK as u64),
            _ => 0x00, // unreachable
        } << offset;
    });

    Stats(stats)
}

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

    assert_eq!(stats.version(), VERSION as u8);
    assert_eq!(stats.mobility(), 7);
    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.will(), 60);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.hack(), 0);
}

#[test]
fun test_with_modifier() {
    use std::unit_test::assert_eq;

    let stats = Self::new(7, 50, 60, 10, 0, 0, 0);

    // hyperfocus modifier: -2 mobility, +30 aim, -20 will
    let modifier = Self::new_modifier(128 + 2, 30, 128 + 20, 0, 0, 0, 0);

    assert_eq!(stats.mobility(), 7);

    // apply the modifier and check the new stats
    let modified = stats.apply_modifier(&modifier);

    assert_eq!(modified.mobility(), 5);
    assert_eq!(modified.aim(), 80);
    assert_eq!(modified.will(), 40);
    assert_eq!(modified.health(), 10);
    assert_eq!(modified.armor(), 0);
    assert_eq!(modified.dodge(), 0);
    assert_eq!(modified.hack(), 0);

    // test overflow (max value) and underflow (arithmetic error) protection
    let modifier = Self::new_modifier(100, 0, 0, 0, 255, 255, 255);
    let modified = modified.apply_modifier(&modifier);

    assert_eq!(modified.mobility(), MAX_MOBILITY); // overflow -> capped
    assert_eq!(modified.armor(), 0); // underflow -> 0
    assert_eq!(modified.dodge(), 0); // underflow -> 0
    assert_eq!(modified.hack(), 0); // underflow -> 0
}
