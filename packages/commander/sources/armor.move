// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Armor` struct and its methods. Armor is a property of a `Unit`
/// that reduces the damage taken by the unit. The armor has a name and a damage
/// reduction in basis points.
module commander::armor;

use std::string::String;
use sui::bcs::{Self, BCS};

#[error]
const EIncorrectValue: vector<u8> = b"Armor level cannot be greater than 10";

/// The `Armor` struct represents the armor of a `Unit`. Armor reduces incoming
/// damage by a value equal to the armor's level. The level can be 0-10.
public struct Armor has store, copy, drop {
    /// No armor. The unit will take full damage.
    name: String,
    /// Damage reduction in basis points.
    /// 0 = no reduction, 100_00 = full reduction.
    level: u16,
}

/// Create a new Armor with the given name and level (can be 0-10).
public fun new(name: String, level: u16): Armor {
    assert!(level <= 10, EIncorrectValue);
    Armor { name, level }
}

/// Reduce the damage value by the armor's reduction.
public fun reduce(armor: &Armor, damage: u16): u16 {
    if (damage == 0) return 0;
    if (damage <= armor.level) 1
    else damage - armor.level
}

// === BCS ===

/// Deserialize the armor from BCS bytes.
public fun from_bytes(bytes: vector<u8>): Armor {
    let mut bcs = bcs::new(bytes);
    from_bcs(&mut bcs)
}

/// Deserialize the armor from the `BCS` instance.
public fun from_bcs(bcs: &mut BCS): Armor {
    let name = bcs.peel_vec!(|e| e.peel_u8()).to_string();
    let level = bcs.peel_u16();
    Armor { name, level }
}

/// Get the name of the armor.
public fun name(armor: &Armor): String { armor.name }

/// Armor decreases the damage taken by the unit.
public fun level(armor: &Armor): u16 { armor.level }

/// Print the armor as a string.
public fun to_string(armor: &Armor): String { armor.name }

#[test]
fun test_armor() {
    use std::unit_test::assert_eq;

    // Create a new armor with 10% reduction.
    let armor = new(b"Leather".to_string(), 1);

    assert_eq!(armor.name(), b"Leather".to_string());
    assert_eq!(armor.level(), 1);

    // Reduce the damage by the armor's reduction.
    assert_eq!(armor.reduce(5), 4);
    assert_eq!(armor.reduce(2), 1);
    assert_eq!(armor.reduce(1), 1);
    assert_eq!(armor.reduce(0), 0);
}
