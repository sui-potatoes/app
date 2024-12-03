// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines different types of ammo that can be used in the game.
module commander::ammo;

use std::string::String;
use sui::bcs::{Self, BCS};

/// All available Ammo types to be used in the game.
public enum Ammo has drop, store {
    /// Standard ammo type, no special properties.
    Standard,
    /// Ignores armor.
    ArmorPiercing,
    /// Increases critical hit chance.
    Talon,
    /// Applies `burn` effect.
    Incendiary,
    /// Applies `poison` effect.
    Poison,
    /// Applies `stun` effect.
    Stun,
}

/// Get the standard ammo type.
public fun standard(): Ammo { Ammo::Standard }

/// Get the armor piercing ammo type.
public fun armor_piercing(): Ammo { Ammo::ArmorPiercing }

/// Get the talon ammo type.
public fun talon(): Ammo { Ammo::Talon }

/// Get the incendiary ammo type.
public fun incendiary(): Ammo { Ammo::Incendiary }

/// Get the poison ammo type.
public fun poison(): Ammo { Ammo::Poison }

/// Get the stun ammo type.
public fun stun(): Ammo { Ammo::Stun }

/// Deserialize bytes into a `Ammo`.
public fun from_bytes(bytes: vector<u8>): Ammo {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Ammo`.
public(package) fun from_bcs(bcs: &mut BCS): Ammo {
    match (bcs.peel_u8()) {
        0 => Ammo::Standard,
        1 => Ammo::ArmorPiercing,
        2 => Ammo::Talon,
        3 => Ammo::Incendiary,
        4 => Ammo::Poison,
        5 => Ammo::Stun,
        _ => abort 264,
    }
}

/// Convert the Ammo type to a string.
public fun to_string(a: &Ammo): String {
    match (a) {
        Ammo::Standard => b"Standard".to_string(),
        Ammo::ArmorPiercing => b"ArmorPiercing".to_string(),
        Ammo::Talon => b"Talon".to_string(),
        Ammo::Incendiary => b"Incendiary".to_string(),
        Ammo::Poison => b"Poison".to_string(),
        Ammo::Stun => b"Stun".to_string(),
    }
}
