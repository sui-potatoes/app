// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Contains all definitions for items that can be used by `Recruits`.
module commander::items;

use bit_field::bit_field as bf;
use commander::{
    armor::{Self, Armor},
    stats,
    weapon::{Self, Weapon},
    weapon_upgrade::{Self as upgrade, WeaponUpgrade}
};

// === Armor ===

/// Creates a new `Armor` with the given tier.
public fun armor(tier: u8, ctx: &mut TxContext): Armor {
    let (name, stats) = match (tier) {
        // +1 ARM, +10% DODGE
        1 => (b"Light Armor", vector[0, 0, 0, 1, 10]),
        // +2 ARM
        2 => (b"Medium Armor", vector[0, 0, 0, 2, 0]),
        // -1 MOB, +1 HP, +3 ARM, -10% DODGE
        3 => (b"Heavy Armor", vector[128 + 1, 0, 1, 3, 128 + 10]),
        _ => abort,
    };

    armor::new(name.to_string(), stats::new_unchecked(bf::pack_u8!(stats)), ctx)
}

// === Weapons ===

/// Creates a new rifle with the given tier.
public fun rifle(tier: u8, ctx: &mut TxContext): Weapon {
    let (name, stats) = match (tier) {
        // 4 DMG, 2 SPREAD, +10% CRIT, 1 AREA, 4 RANGE, 3 AMMO
        1 => (b"Standard Rifle", 0x03_04_00_01_01_0A_0A_02_04 << (6 * 8)),
        // 5 DMG, 1 SPREAD, +20% CRIT, 1 AREA, 5 RANGE, 3 AMMO
        2 => (b"Sharpshooter Rifle", 0x03_05_00_01_01_14_14_01_05 << (6 * 8)),
        // 6 DMG, 1 SPREAD, +30% CRIT, 1 AREA, 5 RANGE, 3 AMMO
        3 => (b"Plasma Rifle", 0x03_05_00_01_01_1E_1E_01_06 << (6 * 8)),
        _ => abort,
    };
    weapon::new(name.to_string(), stats::new_unchecked(stats), ctx)
}

// === Weapon Upgrades ===

/// Adds `5-15%` to the `aim` stat of the `Weapon` depending on the tier.
public fun scope(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        // +5 AIM
        1 => (b"Basic Scope", 0x05 << (1 * 8)),
        // +10 AIM
        2 => (b"Advanced Scope", 0x0A << (1 * 8)),
        // +15 AIM
        3 => (b"Superior Scope", 0x0F << (1 * 8)),
        _ => abort,
    };

    upgrade::new(name.to_string(), tier, stats::new_unchecked(stats))
}

/// Adds `5-15%` to the `crit_chance` stat of the `Weapon` depending on the tier.
public fun laser_sight(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        // +5 CRIT
        1 => (b"Basic Laser Sight", 0x05 << (9 * 8)),
        // +10 CRIT
        2 => (b"Advanced Laser Sight", 0x0A << (9 * 8)),
        // +15 CRIT
        3 => (b"Sniper Laser Sight", 0x0F << (9 * 8)),
        _ => abort,
    };

    upgrade::new(name.to_string(), tier, stats::new_unchecked(stats))
}

/// Adds 1-3 to `range` stat of the `Weapon` depending on the tier.
public fun stock(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        // +1 RANGE
        1 => (b"Basic Stock", 0x01 << (13 * 8)),
        // +2 RANGE
        2 => (b"Advanced Stock", 0x02 << (13 * 8)),
        // +3 RANGE
        3 => (b"Sniper Stock", 0x03 << (13 * 8)),
        _ => abort,
    };

    upgrade::new(name.to_string(), tier, stats::new_unchecked(stats))
}

/// Expanded clip increases the `ammo` stat by 1-3 depending on the tier.
public fun expanded_clip(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        // +1 AMMO
        1 => (b"Basic Expanded Clip", 0x01 << (14 * 8)),
        // +2 AMMO
        2 => (b"Advanced Expanded Clip", 0x02 << (14 * 8)),
        // +3 AMMO
        3 => (b"Superior Expanded Clip", 0x03 << (14 * 8)),
        _ => abort,
    };

    upgrade::new(name.to_string(), tier, stats::new_unchecked(stats))
}

#[test]
fun test_weapons() {
    use std::unit_test::assert_eq;
    let ctx = &mut tx_context::dummy();

    {
        let rifle = rifle(1, ctx);
        assert_eq!(rifle.stats().damage(), 4);
        assert_eq!(rifle.stats().spread(), 2);
        assert_eq!(rifle.stats().plus_one(), 10);
        assert_eq!(rifle.stats().crit_chance(), 10);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 4);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };

    {
        let rifle = rifle(2, ctx);
        assert_eq!(rifle.stats().damage(), 5);
        assert_eq!(rifle.stats().spread(), 1);
        assert_eq!(rifle.stats().plus_one(), 20);
        assert_eq!(rifle.stats().crit_chance(), 20);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 5);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };

    {
        let rifle = rifle(3, ctx);
        assert_eq!(rifle.stats().damage(), 6);
        assert_eq!(rifle.stats().spread(), 1);
        assert_eq!(rifle.stats().plus_one(), 30);
        assert_eq!(rifle.stats().crit_chance(), 30);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 5);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };
}

#[test]
fun test_armor() {
    use std::unit_test::assert_eq;
    let ctx = &mut tx_context::dummy();

    {
        let armor = armor(1, ctx);
        assert_eq!(armor.stats().armor(), 1);
        assert_eq!(armor.stats().dodge(), 10);
        armor.destroy();
    };

    {
        let armor = armor(2, ctx);
        assert_eq!(armor.stats().armor(), 2);
        assert_eq!(armor.stats().dodge(), 0);
        armor.destroy();
    };

    {
        let armor = armor(3, ctx);
        assert_eq!(armor.stats().mobility(), 0x80 + 1);
        assert_eq!(armor.stats().health(), 1);
        assert_eq!(armor.stats().armor(), 3);
        assert_eq!(armor.stats().dodge(), 0x80 + 10);
        armor.destroy();
    };
}

#[test]
fun test_weapon_upgrades() {
    use std::unit_test::assert_eq;
    let ctx = &mut tx_context::dummy();
    let mut rifle = rifle(1, ctx);

    assert_eq!(rifle.stats().aim(), 0);

    // scope 1
    rifle.add_upgrade(scope(1));
    assert_eq!(rifle.stats().aim(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    // scope 2
    rifle.add_upgrade(scope(2));
    assert_eq!(rifle.stats().aim(), 10);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    // scope 3
    rifle.add_upgrade(scope(3));
    assert_eq!(rifle.stats().aim(), 15);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 1
    rifle.add_upgrade(laser_sight(1));
    assert_eq!(rifle.stats().crit_chance(), 15);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 2
    rifle.add_upgrade(laser_sight(2));
    assert_eq!(rifle.stats().crit_chance(), 20);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 3
    rifle.add_upgrade(laser_sight(3));
    assert_eq!(rifle.stats().crit_chance(), 25);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // stock 1
    rifle.add_upgrade(stock(1));
    assert_eq!(rifle.stats().range(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // stock 2
    rifle.add_upgrade(stock(2));
    assert_eq!(rifle.stats().range(), 6);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // stock 3
    rifle.add_upgrade(stock(3));
    assert_eq!(rifle.stats().range(), 7);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // expanded clip 1
    rifle.add_upgrade(expanded_clip(1));
    assert_eq!(rifle.stats().ammo(), 4);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    // expanded clip 2
    rifle.add_upgrade(expanded_clip(2));
    assert_eq!(rifle.stats().ammo(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    // expanded clip 3
    rifle.add_upgrade(expanded_clip(3));
    assert_eq!(rifle.stats().ammo(), 6);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    rifle.destroy();
}
