// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Armor` struct and its methods. Armor is a property of a `Unit`
/// that reduces the damage taken by the unit. The armor has a name and a damage
/// reduction in basis points.
module commander::armor;

use std::string::String;
use sui::bcs::{Self, BCS};

#[error]
const EIncorrectValue: vector<u8> = b"Damage reduction must be between 0 and 100_00 (basis points)";

/// The `Armor` struct represents the armor of a `Unit`. Armor reduces incoming
/// damage by a certain percentage (set in `reduction_bp` field).
public struct Armor has store, copy, drop {
    /// No armor. The unit will take full damage.
    name: String,
    /// Damage reduction in basis points.
    /// 0 = no reduction, 100_00 = full reduction.
    reduction_bp: u16,
}

/// Create a new Armor with the given name and reduction in basis points.
public fun new(name: String, reduction_bp: u16): Armor {
    assert!(reduction_bp <= 100_00, EIncorrectValue);
    Armor { name, reduction_bp }
}

/// Reduce the damage value by the armor's reduction.
public fun reduce(armor: &Armor, damage: u16): u16 {
    if (armor.reduction_bp == 0) {
        return damage
    };

    let damage = damage as u32;
    let reduction = damage * (armor.reduction_bp as u32) / 100_00;
    (damage - reduction) as u16
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
    let reduction_bp = bcs.peel_u16();
    Armor { name, reduction_bp }
}

/// Get the name of the armor.
public fun name(armor: &Armor): String { armor.name }

/// Get the damage reduction in basis points.
public fun reduction_bp(armor: &Armor): u16 { armor.reduction_bp }

/// Print the armor as a string.
public fun to_string(armor: &Armor): String { armor.name }

#[test]
fun test_armor() {
    use std::unit_test::assert_eq;

    // Create a new armor with 10% reduction.
    let armor = new(b"Leather".to_string(), 10_00);

    assert_eq!(armor.name(), b"Leather".to_string());
    assert_eq!(armor.reduction_bp(), 10_00);

    // Reduce the damage by the armor's reduction.
    assert_eq!(armor.reduce(100), 90);
    assert_eq!(armor.reduce(50), 45);
}
