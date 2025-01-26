// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the Armor - an equipment that Recruits can wear in battle.
module commander::armor;

use commander::stats::{Self, Stats};
use std::string::String;

/// Armor is a piece of equipment that Recruits can use in battle. Each armor has
/// its own stats, normally adding to the `defense` and `health` of the Recruit.
///
/// However, given reusability of `Stats`, it can augment other stats as well.
public struct Armor has key, store {
    id: UID,
    /// The name of the armor. "Standard Armor", "Titanium Armor", etc.
    name: String,
    /// The `Stats` of the armor.
    stats: Stats,
}

/// Create a new `Armor` with the provided parameters.
public fun new(name: String, stats: Stats, ctx: &mut TxContext): Armor {
    Armor { id: object::new(ctx), name, stats }
}

/// Create a new default `Armor`.
public fun default(ctx: &mut TxContext): Armor {
    Armor {
        id: object::new(ctx),
        name: b"Standard Armor".to_string(),
        stats: stats::default_armor(),
    }
}

/// Destroy the `Armor`.
public fun destroy(armor: Armor) {
    let Armor { id, .. } = armor;
    id.delete();
}

// === Reads ===

/// Get the name of the `Armor`.
public fun name(a: &Armor): String { a.name }

/// Get the stats of the `Armor`.
public fun stats(a: &Armor): &Stats { &a.stats }

// === Convenience and compatibility ===

/// Add an upgrade to the `Armor`.
public fun to_string(a: &Armor): String { a.name }

#[test]
fun test_armor() {
    use std::unit_test::assert_eq;

    let ctx = &mut tx_context::dummy();
    let arm = Self::default(ctx);

    assert_eq!(arm.name(), b"Standard Armor".to_string());
    assert_eq!(arm.stats().inner(), 0);

    arm.destroy();
}
