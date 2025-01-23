// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `WeaponStats` type - a structure very similar to the `Stats`.
/// Allows storing arbitrary number of stats for a weapon with potential for
/// upgrades.
module commander::weapon_stats;

use bit_field::bit_field as bf;
use std::{macros::num_min, string::String};
use sui::bcs::{Self, BCS};

const MAX_DAMAGE: u8 = 10;
const MAX_SPREAD: u8 = 5;
const MAX_PLUS_ONE: u8 = 100;
const MAX_CRIT_CHANCE: u8 = 100;
const MAX_AREA_SIZE: u8 = 10;
const MAX_RANGE: u8 = 10;
const MAX_AMMO: u8 = 10;
const SIGN_VALUE: u8 = 128;
const NUM_PARAMS: u8 = 9;

/// Error code for not implemented functions.
const ENotImplemented: u64 = 264;
/// Error code for incorrect value passed into `new` function.
const EIncorrectValue: u64 = 1;

/// Stores the stats as bit fields in a single `u128` value.
public struct WeaponStats(u128) has copy, drop, store;

/// Modifier is a single `u128` value that replicates the structure of the `WeaponStats`,
/// and can be used to store the modifiers for the stats as signed integers.
public struct Modifier(u128) has copy, drop, store;

/// Create a new `WeaponStats` struct with the given values.
public fun new(
    damage: u8,
    spread: u8,
    plus_one: u8,
    crit_chance: u8,
    is_dodgeable: bool,
    area_size: u8,
    environmental_damage: bool,
    range: u8,
    ammo: u8,
): WeaponStats {
    assert!(damage < MAX_DAMAGE, EIncorrectValue);
    assert!(spread < MAX_SPREAD, EIncorrectValue);
    assert!(plus_one < MAX_PLUS_ONE, EIncorrectValue);
    assert!(crit_chance < MAX_CRIT_CHANCE, EIncorrectValue);
    assert!(area_size < MAX_AREA_SIZE, EIncorrectValue);
    assert!(range < MAX_RANGE, EIncorrectValue);
    assert!(ammo < MAX_AMMO, EIncorrectValue);

    WeaponStats(
        bf::pack_u8!(
            vector[
                damage,
                spread,
                plus_one,
                crit_chance,
                if (is_dodgeable) 1 else 0,
                area_size,
                if (environmental_damage) 1 else 0,
                range,
                ammo,
            ],
        ),
    )
}

/// Create a new `Modifier` struct with the given values.
public fun new_modifier(
    damage: u8,
    spread: u8,
    plus_one: u8,
    crit_chance: u8,
    is_dodgeable: u8,
    area_size: u8,
    environmental_damage: u8,
    range: u8,
    ammo: u8,
): Modifier {
    Modifier(
        bf::pack_u8!(
            vector[
                damage,
                spread,
                plus_one,
                crit_chance,
                is_dodgeable,
                area_size,
                environmental_damage,
                range,
                ammo,
            ],
        ),
    )
}

/// Negates the modifier values. Creates a new `Modifier` which, when applied to
/// the `WeaponStats`, will negate the effects of the original modifier.
public fun negate(modifier: &Modifier): Modifier {
    let modifier = modifier.0;
    let sign = SIGN_VALUE;
    let negated = bf::unpack_u8!(modifier, NUM_PARAMS).map!(|value| {
        if (value > sign) value - sign
        else value + sign
    });

    Modifier(bf::pack_u8!(negated))
}

/// Create a new default `WeaponStats`.
public fun default(): WeaponStats { new(7, 2, 0, 0, true, 1, true, 5, 5) }

/// The base damage the weapon deals.
public fun damage(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 0) }

/// The spread of the weapon, min/max modifier to damage.
/// For example, if the weapon has a spread of 2, the damage will be between
/// `damage - 2` and `damage + 2`.
public fun spread(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 1) }

/// A chance to deal additional damage, in %.
public fun plus_one(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 2) }

/// A chance to deal critical damage, in %.
/// 0 for most weapons, 10% for sniper and other high-crit weapons.
public fun crit_chance(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 3) }

/// Get the dodgeability of the `Weapon`, i.e. whether the weapon can be dodged.
///
/// Grenades and explosives are not dodgeable, while bullets are. However, some
/// weapons might have special abilities that make them undodgeable.
public fun is_dodgeable(s: &WeaponStats): bool { bf::read_u8_at_offset!(s.0, 4) > 0 }

/// Get the area size of the `Weapon`, only for area damage weapons.
///
/// Expected value for most of the weapons is `1`. Each increment adds all the
/// neighboring tiles to the area of effect.
///
/// This example illustrates different area sizes (1-3):
/// ```
/// | | |3| | |
/// | |3|2|3| |
/// |3|2|1|2|3|
/// | |3|2|3| |
/// | | |3| | |
/// ```
public fun area_size(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 5) }

/// Environmental damage can destroy covers and obstacles.
public fun environmental_damage(s: &WeaponStats): bool { bf::read_u8_at_offset!(s.0, 6) > 0 }

/// The effective range of the weapon, without penalties.
public fun range(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 7) }

/// Ammo capacity of the weapon. When the ammo is depleted, the weapon
/// requires reloading.
public fun ammo(s: &WeaponStats): u8 { bf::read_u8_at_offset!(s.0, 8) }

/// Get the inner `u128` value of the `WeaponStats`. Can be used for performance
/// optimizations and macros.
public fun inner(stats: &WeaponStats): u128 { stats.0 }

// === Modifier ===

/// Apply the modifier to the stats and return the modified value. Each value in
/// the `Modifier` can be positive or negative (the first sign bit is used), and
/// the value (0-127) is added or subtracted from the base stats.
///
/// The result can never overflow the base stats, and the values are capped at
/// the maximum values for each stat.
public fun apply_modifier(stats: &WeaponStats, modifier: &Modifier): WeaponStats {
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
            0 => num_min!(new_value, MAX_DAMAGE),
            1 => num_min!(new_value, MAX_SPREAD),
            2 => num_min!(new_value, MAX_PLUS_ONE),
            3 => num_min!(new_value, MAX_CRIT_CHANCE),
            4 => num_min!(new_value, 1),
            5 => num_min!(new_value, MAX_AREA_SIZE),
            6 => num_min!(new_value, 1),
            7 => num_min!(new_value, MAX_RANGE),
            8 => num_min!(new_value, MAX_AMMO),
            _ => 0x00, // unreachable
        };
    });

    WeaponStats(bf::pack_u8!(stat_values))
}

// === Convenience and compatibility ===

/// Print the `Stats` as a string.
public fun to_string(_stats: &WeaponStats): String {
    abort ENotImplemented
}

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): WeaponStats {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): WeaponStats {
    WeaponStats(bcs.peel_u128())
}

#[test]
fun test_stats() {
    use std::unit_test::assert_eq;

    let stats = Self::new(
        7, // damage
        2, // spread
        0, // plus_one
        0, // crit_chance
        true, // is_dodgeable
        1, // area_size
        true, // environmental_damage
        5, // range
        5, // ammo
    );

    assert_eq!(stats.damage(), 7);
    assert_eq!(stats.spread(), 2);
    assert_eq!(stats.plus_one(), 0);
    assert_eq!(stats.crit_chance(), 0);
    assert!(stats.is_dodgeable());
    assert_eq!(stats.area_size(), 1);
    assert!(stats.environmental_damage());
    assert_eq!(stats.range(), 5);
    assert_eq!(stats.ammo(), 5);

    let modifier = Self::new_modifier(
        128 + 2, // damage
        1, // spread
        50, // plus_one
        30, // crit_chance
        128 + 1, // is_dodgeable
        0, // area_size
        128 + 1, // environmental_damage
        2, // range
        1, // ammo
    );

    let modified = stats.apply_modifier(&modifier);

    assert_eq!(modified.damage(), 5);
    assert_eq!(modified.spread(), 3);
    assert_eq!(modified.plus_one(), 50);
    assert_eq!(modified.crit_chance(), 30);
    assert!(!modified.is_dodgeable()); // negated bool value
    assert_eq!(modified.area_size(), 1);
    assert!(!modified.environmental_damage()); // negated bool value
    assert_eq!(modified.range(), 7);
    assert_eq!(modified.ammo(), 6);

    let negated = modified.apply_modifier(&modifier.negate());

    assert_eq!(negated, stats);
}
