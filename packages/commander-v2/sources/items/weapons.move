// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

///
module commander::weapons;

use commander::{
    weapon::{Self, Weapon},
    weapon_stats as stats,
    weapon_upgrade::{Self as upgrade, WeaponUpgrade}
};

// === Weapons ===

/// Creates a new rifle with the given tier.
public fun rifle(tier: u8, ctx: &mut TxContext): Weapon {
    match (tier) {
        1 => weapon::new(
            b"Standard Issue Rifle".to_string(),
            stats::new(4, 2, 10, 10, true, 1, false, 4, 3),
            ctx,
        ),
        2 => weapon::new(
            b"Sharpshooter Rifle".to_string(),
            stats::new(5, 1, 20, 20, true, 1, false, 5, 3),
            ctx,
        ),
        3 => weapon::new(
            b"Plasma Rifle".to_string(),
            stats::new(6, 1, 30, 30, true, 1, false, 5, 3),
            ctx,
        ),
        _ => abort,
    }
}

public fun laser_sight(tier: u8): WeaponUpgrade {
    match (tier) {
        1 => upgrade::new(
            b"Basic Laser Sight".to_string(),
            1,
            stats::new_modifier(0, 0, 0, 5, 0, 0, 0, 0, 0),
        ),
        2 => upgrade::new(
            b"Advanced Laser Sight".to_string(),
            2,
            stats::new_modifier(0, 0, 0, 10, 0, 0, 0, 0, 0),
        ),
        3 => upgrade::new(
            b"Sniper Laser Sight".to_string(),
            3,
            stats::new_modifier(0, 0, 0, 15, 0, 0, 0, 0, 0),
        ),
        _ => abort,
    }
}

/// Adds 1-3 to `range` stat of the `Weapon` depending on the tier.
public fun stock(tier: u8): WeaponUpgrade {
    match (tier) {
        1 => upgrade::new(
            b"Basic Stock".to_string(),
            1,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 1, 0),
        ),
        2 => upgrade::new(
            b"Advanced Stock".to_string(),
            2,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 2, 0),
        ),
        3 => upgrade::new(
            b"Sniper Stock".to_string(),
            3,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 3, 0),
        ),
        _ => abort,
    }
}

/// Expanded clip increases the `ammo` stat by 1-3 depending on the tier.
public fun expanded_clip(tier: u8): WeaponUpgrade {
    match (tier) {
        1 => upgrade::new(
            b"Basic Expanded Clip".to_string(),
            1,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 0, 1),
        ),
        2 => upgrade::new(
            b"Advanced Expanded Clip".to_string(),
            2,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 0, 2),
        ),
        3 => upgrade::new(
            b"Sniper Expanded Clip".to_string(),
            3,
            stats::new_modifier(0, 0, 0, 0, 0, 0, 0, 0, 3),
        ),
        _ => abort,
    }
}
