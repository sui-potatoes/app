// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Universal stats for Recruits and their equipment, and for `Unit`s.
///
/// Stats are built in a way that allows easy modification, negation and
/// addition. Recruit stats are distributed in their equipment, and during the
/// conversion to `Unit` (pre-battle), the stats are combined into a single
/// `Stats` value.
module commander::stats_tests;

use commander::stats;
use std::unit_test::assert_eq;

const SIGN_VALUE: u8 = 0x80;

#[test]
fun test_stats() {
    let stats = stats::new(
        7, // mobility
        50, // aim
        10, // health
        0, // armor
        0, // dodge
    );

    assert_eq!(stats.mobility(), 7);
    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
}

#[test]
fun test_defaults() {
    let stats = stats::default();

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
    assert_eq!(stats.is_dodgeable(), 0);
    assert_eq!(stats.area_size(), 0);
    assert_eq!(stats.env_damage(), 0);
    assert_eq!(stats.range(), 0);
    assert_eq!(stats.ammo(), 0);

    let weapon_stats = stats::default_weapon();

    assert_eq!(weapon_stats.damage(), 4);
    assert_eq!(weapon_stats.spread(), 2);
    assert_eq!(weapon_stats.plus_one(), 0);
    assert_eq!(weapon_stats.crit_chance(), 0);
    assert_eq!(weapon_stats.is_dodgeable(), 1);
    assert_eq!(weapon_stats.area_size(), 1);
    assert_eq!(weapon_stats.env_damage(), 0);
    assert_eq!(weapon_stats.range(), 4);
    assert_eq!(weapon_stats.ammo(), 3);

    assert_eq!(weapon_stats.mobility(), 0);
    assert_eq!(weapon_stats.aim(), 0);
    assert_eq!(weapon_stats.health(), 0);
    assert_eq!(weapon_stats.armor(), 0);
    assert_eq!(weapon_stats.dodge(), 0);
    assert_eq!(weapon_stats.defense(), 0);
}

#[test]
fun test_with_modifier() {
    let stats = stats::new(7, 50, 10, 0, 0);
    let modifier = stats::new(128 + 2, 30, 0, 0, 0); // hyperfocus modifier: -2 mobility, +30 aim
    let modified = stats.add(&modifier); // apply the modifier and check the new stats

    assert_eq!(modified.mobility(), 5);
    assert_eq!(modified.aim(), 80);
    assert_eq!(modified.health(), 10);
    assert_eq!(modified.armor(), 0);
    assert_eq!(modified.dodge(), 0);

    // test negation
    assert_eq!(modified.add(&modifier.negate()), stats);

    // test overflow (max value) and underflow (arithmetic error) protection
    let modifier = stats::new(127, 0, 0, 255, 255);
    let modified = modified.add(&modifier);

    assert_eq!(modified.mobility(), SIGN_VALUE - 1); // overflow -> capped
    assert_eq!(modified.armor(), 0); // underflow -> 0
    assert_eq!(modified.dodge(), 0); // underflow -> 0
}
