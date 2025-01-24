// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Attempt to replace the `Stats` struct with a single `u64` value which uses
/// bit manipulation to store all the stats at right positions.
///
/// Traits:
/// - default
/// - from_bcs
/// - to_string
module commander::stats;

use bit_field::bit_field as bf;
use std::{macros::num_min, string::String};
use sui::bcs::{Self, BCS};

/// Capped at 7 bits. Max value for signed 8-bit integers.
const SIGN_VALUE: u8 = 128;
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
/// Number of bitmap encoded parameters.
const NUM_PARAMS: u8 = 6;

/// Error code for not implemented functions.
const ENotImplemented: u64 = 264;
/// Error code for incorrect value passed into `new` function.
const EIncorrectValue: u64 = 1;

/// The `BitStats` struct is a single uint value that stores all the stats of
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
public struct Stats(u128) has copy, drop, store;

/// Modifier is a single `u128` value that replicates the structure of the `Stats`,
/// but is used to store the modifiers for the stats as signed integers. Modifiers
/// are applied to the base stats of the Recruit to calculate the final stats.
public struct Modifier(u128) has copy, drop, store;

/// Create a new `BitStats` struct with the given values.
public fun new(mobility: u8, aim: u8, health: u8, armor: u8, dodge: u8, will: u8): Stats {
    assert!(mobility < MAX_MOBILITY, EIncorrectValue);
    assert!(health < MAX_HEALTH, EIncorrectValue);
    assert!(aim < MAX_AIM, EIncorrectValue);
    assert!(armor < MAX_ARMOR, EIncorrectValue);
    assert!(dodge < MAX_DODGE, EIncorrectValue);
    assert!(will < MAX_WILL, EIncorrectValue);

    Stats(bf::pack_u8!(vector[mobility, aim, health, armor, dodge, will]))
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
    health: u8,
    armor: u8,
    dodge: u8,
    will: u8,
): Modifier {
    Modifier(bf::pack_u8!(vector[mobility, aim, health, armor, dodge, will]))
}

/// Negates the modifier values. Creates a new `Modifier` which, when applied to
/// the `WeaponStats`, will negate the effects of the original modifier.
public fun negate(modifier: &Modifier): Modifier {
    let modifier = modifier.0;
    let sign = SIGN_VALUE;
    let negated = bf::unpack_u8!(modifier, NUM_PARAMS).map!(|value| {
        if (value > sign) value - sign else value + sign
    });

    Modifier(bf::pack_u8!(negated))
}

/// Default stats for a Recruit.
public fun default(): Stats { new(7, 65, 10, 0, 0, 65) }

/// Get the `mobility` stat.
public fun mobility(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 0) }

/// Get the `aim` stat.
public fun aim(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 1) }

/// Get the `health` stat.
public fun health(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 2) }

/// Get the `armor` stat.
public fun armor(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 3) }

/// Get the `dodge` stat.
public fun dodge(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 4) }

/// Get the `will` stat.
public fun will(stats: &Stats): u8 { bf::read_u8_at_offset!(stats.0, 5) }

/// Get the inner `u128` value of the `Stats`. Can be used for performance
/// optimizations and macros.
public fun inner(stats: &Stats): u128 { stats.0 }

// === Modifier ===

/// Apply the modifier to the stats and return the modified value. Each value in
/// the `Modifier` can be positive or negative (the first sign bit is used), and
/// the value (0-127) is added or subtracted from the base stats.
///
/// The result can never overflow the base stats, and the values are capped at
/// the maximum values for each stat.
public fun apply_modifier(stats: &Stats, modifier: &Modifier): Stats {
    let stats = stats.0;
    let modifier = modifier.0;
    let sign = SIGN_VALUE;

    let mut stat_values = bf::unpack_u8!(stats, NUM_PARAMS);
    let modifier_values = bf::unpack_u8!(modifier, NUM_PARAMS);

    // version is not modified, the rest of the values are modified
    // based on the signed values of the modifier
    (NUM_PARAMS as u64).do!(|i| {
        let modifier = modifier_values[i];
        let value = stat_values[i];

        // skip 0 and -0 values
        if (modifier == 0 || modifier == sign) return;
        let new_value = if (modifier > sign) {
            value - num_min!(modifier - sign, value)
        } else {
            // cannot overflow (127 is the max for modifier, below we cap values)
            value + modifier
        };

        // prettier-ignore
        *&mut stat_values[i] = match (i) {
            0 => num_min!(new_value, MAX_MOBILITY),
            1 => num_min!(new_value, MAX_AIM),
            2 => num_min!(new_value, MAX_HEALTH),
            3 => num_min!(new_value, MAX_ARMOR),
            4 => num_min!(new_value, MAX_DODGE),
            5 => num_min!(new_value, MAX_WILL),
            _ => 0x00, // unreachable
        };
    });

    Stats(bf::pack_u8!(stat_values))
}

// === Convenience and compatibility ===

/// Print the `Stats` as a string.
public fun to_string(_stats: &Stats): String {
    abort ENotImplemented
}

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Stats {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): Stats {
    Stats(bcs.peel_u128())
}

#[test]
fun test_stats() {
    use std::unit_test::assert_eq;

    let stats = Self::new(
        7, // mobility
        50, // aim
        10, // health
        0, // armor
        0, // dodge
        60, // will
    );

    assert_eq!(stats.mobility(), 7);
    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.will(), 60);
}

#[test]
fun test_with_modifier() {
    use std::unit_test::assert_eq;

    let stats = Self::new(7, 50, 10, 0, 0, 60);

    // hyperfocus modifier: -2 mobility, +30 aim, -20 will
    let modifier = Self::new_modifier(128 + 2, 30, 0, 0, 0, 128 + 20);

    assert_eq!(stats.mobility(), 7);

    // apply the modifier and check the new stats
    let modified = stats.apply_modifier(&modifier);

    assert_eq!(modified.mobility(), 5);
    assert_eq!(modified.aim(), 80);
    // assert_eq!(modified.will(), 40);
    assert_eq!(modified.health(), 10);
    assert_eq!(modified.armor(), 0);
    assert_eq!(modified.dodge(), 0);

    // test negation
    assert_eq!(modified.apply_modifier(&modifier.negate()), stats);

    // test overflow (max value) and underflow (arithmetic error) protection
    let modifier = Self::new_modifier(100, 0, 0, 255, 255, 0);
    let modified = modified.apply_modifier(&modifier);

    assert_eq!(modified.mobility(), MAX_MOBILITY); // overflow -> capped
    assert_eq!(modified.armor(), 0); // underflow -> 0
    assert_eq!(modified.dodge(), 0); // underflow -> 0
}
