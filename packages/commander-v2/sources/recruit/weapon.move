// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the Weapon - a piece of equipment that Recruits can use in battle.
/// Weapons have different stats and can be upgraded with additional modules.
module commander::weapon;

use commander::{stats::{Self, Stats}, weapon_upgrade::WeaponUpgrade};
use std::string::String;

/// Attempt to attach too many upgrades to a weapon.
const ETooManyUpgrades: u64 = 1;
/// Attempt to remove an upgrade that does not exist.
const ENoUpgrade: u64 = 2;

/// Weapon is an equipment that Recruits can use in battle. Each weapon has its
/// own stats with a potential to be upgraded with additional modules.
///
/// Some weapons might be unique and have special abilities.
public struct Weapon has key, store {
    id: UID,
    /// The name of the weapon. "Plasma Rifle", "Sniper Rifle", etc.
    name: String,
    /// The `Stats` of the weapon.
    stats: Stats,
    /// The list of upgrades that the weapon has.
    upgrades: vector<WeaponUpgrade>,
}

/// Create a new `Weapon` with the provided parameters.
public fun new(name: String, stats: Stats, ctx: &mut TxContext): Weapon {
    Weapon { id: object::new(ctx), name, stats, upgrades: vector[] }
}

/// Create a new default `Weapon`.
public fun default(ctx: &mut TxContext): Weapon {
    Weapon {
        id: object::new(ctx),
        name: b"Standard Issue Rifle".to_string(),
        stats: stats::default_weapon(),
        upgrades: vector[],
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
public fun stats(w: &Weapon): &Stats { &w.stats }

/// Get the upgrades of the `Weapon`.
public fun upgrades(w: &Weapon): &vector<WeaponUpgrade> { &w.upgrades }

/// Add an upgrade to the `Weapon`.
public fun add_upgrade(w: &mut Weapon, upgrade: WeaponUpgrade) {
    assert!(w.upgrades.length() < 3, ETooManyUpgrades);
    w.stats = w.stats.add(upgrade.modifier());
    w.upgrades.push_back(upgrade);
}

/// Remove an upgrade from the `Weapon`.
public fun remove_upgrade(w: &mut Weapon, upgrade_idx: u8) {
    assert!(w.upgrades.length() > upgrade_idx as u64, ENoUpgrade);
    let upgrade = w.upgrades.remove(upgrade_idx as u64);
    w.stats = w.stats.add(&upgrade.modifier().negate());
}
