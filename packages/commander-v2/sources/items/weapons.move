// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

///
module commander::weapons;

use commander::{stats, weapon::{Self, Weapon}, weapon_upgrade::{Self as upgrade, WeaponUpgrade}};

// === Weapons ===

/// Creates a new rifle with the given tier.
public fun rifle(tier: u8, ctx: &mut TxContext): Weapon {
    let (name, stats) = match (tier) {
        1 => (b"Standard Rifle".to_string(), 0x00_00_00_00_00_00___04_02_0A_0A_01_01_00_04_03),
        2 => (b"Sharpshooter Rifle".to_string(), 0x00_00_00_00_00_00___05_01_14_14_01_01_00_05_03),
        3 => (b"Plasma Rifle".to_string(), 0x00_00_00_00_00_00___06_01_1E_1E_01_01_00_05_03),
        _ => abort,
    };
    weapon::new(name, stats::new_unchecked(stats), ctx)
}

public fun laser_sight(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        1 => (b"Basic Laser Sight".to_string(), 0x00_00_00_00_00_00___00_00_00_05_00_00_00_00_00),
        2 => (b"Advanced Laser Sight".to_string(), 0x00_00_00_00_00_00___00_00_00_0A_00_00_00_00_00),
        3 => (b"Sniper Laser Sight".to_string(), 0x00_00_00_00_00_00___00_00_00_0F_00_00_00_00_00),
        _ => abort,
    };

    upgrade::new(name, tier, stats::new_unchecked(stats))
}

/// Adds 1-3 to `range` stat of the `Weapon` depending on the tier.
public fun stock(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        1 => (b"Basic Stock".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_01_00),
        2 => (b"Advanced Stock".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_02_00),
        3 => (b"Sniper Stock".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_03_00),
        _ => abort,
    };

    upgrade::new(name, tier, stats::new_unchecked(stats))
}

/// Expanded clip increases the `ammo` stat by 1-3 depending on the tier.
public fun expanded_clip(tier: u8): WeaponUpgrade {
    let (name, stats) = match (tier) {
        1 => (b"Basic Expanded Clip".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_00_01),
        2 => (b"Advanced Expanded Clip".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_00_02),
        3 => (b"Superior Expanded Clip".to_string(), 0x00_00_00_00_00_00___00_00_00_00_00_00_00_00_03),
        _ => abort,
    };

    upgrade::new(name, tier, stats::new_unchecked(stats))
}
