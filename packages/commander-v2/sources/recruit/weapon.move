// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the Weapon - a piece of equipment that Recruits can use in battle.
/// Weapons have different stats and can be upgraded with additional modules.
module commander::weapon;

use commander::weapon_stats::{Self, WeaponStats};
use std::string::String;

/// Weapon is an equipment that Recruits can use in battle. Each weapon has its
/// own stats with a potential to be upgraded with additional modules.
///
/// Some weapons might be unique and have special abilities.
public struct Weapon has key, store {
    id: UID,
    /// The name of the weapon. "Plasma Rifle", "Sniper Rifle", etc.
    name: String,
    /// The `WeaponStats` of the weapon.
    stats: WeaponStats,
}

/// Create a new `Weapon` with the provided parameters.
public fun new(name: String, stats: WeaponStats, ctx: &mut TxContext): Weapon {
    Weapon { id: object::new(ctx), name, stats }
}

/// Create a new default `Weapon`.
public fun default(ctx: &mut TxContext): Weapon {
    Weapon {
        id: object::new(ctx),
        name: b"Standard Issue Rifle".to_string(),
        stats: weapon_stats::default(),
    }
}

/// Destroy the `Weapon`.
public fun destroy(weapon: Weapon) {
    let Weapon { id, .. } = weapon;
    id.delete();
}

/// Get the name of the `Weapon`.
public fun name(w: &Weapon): String { w.name }

/// Get the stats of the `Weapon`.
public fun stats(w: &Weapon): &WeaponStats { &w.stats }
