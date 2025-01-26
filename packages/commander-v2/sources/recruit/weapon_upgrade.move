// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `WeaponUpgrade` - a module that can be attached to a `Weapon` to
/// modify its stats.
module commander::weapon_upgrade;

use commander::stats::Stats;
use std::string::String;

/// `WeaponUpgrade` is a primitive which represents an upgrade module for a
/// `Weapon`. Upgrades are identified by their name, and can be applied to a
/// `Weapon` to modify its stats.
public struct WeaponUpgrade has drop, store {
    name: String,
    tier: u8,
    modifier: Stats,
}

/// Create a new `WeaponUpgrade` with the provided parameters.
public fun new(name: String, tier: u8, modifier: Stats): WeaponUpgrade {
    WeaponUpgrade { name, tier, modifier }
}

/// Get the name of the `WeaponUpgrade`.
public fun name(u: &WeaponUpgrade): String { u.name }

/// Get the tier of the `WeaponUpgrade`.
public fun tier(u: &WeaponUpgrade): u8 { u.tier }

/// Get the modifier of the `WeaponUpgrade`.
public fun modifier(u: &WeaponUpgrade): &Stats { &u.modifier }

/// Destroy the `WeaponUpgrade`.
public fun destroy(u: WeaponUpgrade) { let WeaponUpgrade { .. } = u; }

/// Print the `WeaponUpgrade` as a string.
public fun to_string(u: &WeaponUpgrade): String {
    let mut str = u.name;
    str.append_utf8(b" (Tier ");
    str.append(u.tier.to_string());
    str.append_utf8(b")");
    str
}
