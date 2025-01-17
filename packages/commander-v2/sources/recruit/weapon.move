// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the Weapon - a piece of equipment that Recruits can use in battle.
/// Weapons have different stats and can be upgraded with additional modules.
module commander::weapon;

use std::string::String;

/// Weapon is an equipment that Recruits can use in battle. Each weapon has its
/// own stats with a potential to be upgraded with additional modules.
///
/// Some weapons might be unique and have special abilities.
public struct Weapon has key, store {
    id: UID,
    /// The name of the weapon. "Plasma Rifle", "Sniper Rifle", etc.
    name: String,
    /// The base damage the weapon deals.
    damage: u8,
    /// The spread of the weapon, min/max modifier to damage.
    /// For example, if the weapon has a spread of 2, the damage will be between
    /// `damage - 2` and `damage + 2`.
    spread: u8,
    /// A chance to deal additional damage, in %.
    plus_one: u8,
    /// A chance to deal critical damage, in %.
    /// 0 for most weapons, 10% for sniper and other high-crit weapons.
    crit_chance: u8,
    /// Whether the weapon can be dodged.
    is_dodgeable: bool,
    /// Whether the weapon damages the area.
    area_damage: bool,
    /// The area size of the weapon, in tiles, an odd number.
    area_size: u8,
    /// The effective range of the weapon, without penalties.
    range: u8,
    /// Ammo capacity of the weapon. When the ammo is depleted, the weapon
    /// requires reloading.
    ammo: u8,
    // Upgrades that this weapon has. Non-detachable but replaceable by other
    // upgrades.
    // upgrades: /* ... */
}

/// Create a new `Weapon` with the provided parameters.
public fun new(
    name: String,
    damage: u8,
    spread: u8,
    plus_one: u8,
    crit_chance: u8,
    is_dodgeable: bool,
    area_damage: bool,
    area_size: u8,
    range: u8,
    ammo: u8,
    ctx: &mut TxContext,
): Weapon {
    Weapon {
        id: object::new(ctx),
        name,
        damage,
        spread,
        plus_one,
        crit_chance,
        is_dodgeable,
        area_damage,
        area_size,
        range,
        ammo,
    }
}

/// Create a new default `Weapon`.
public fun default(ctx: &mut TxContext): Weapon {
    Weapon {
        id: object::new(ctx),
        name: b"Standard Issue Rifle".to_string(),
        damage: 5,
        spread: 1,
        plus_one: 0,
        crit_chance: 0,
        is_dodgeable: true,
        area_damage: false,
        area_size: 1,
        range: 5,
        ammo: 3,
    }
}

/// Destroy the `Weapon`.
public fun destroy(weapon: Weapon) {
    let Weapon { id, .. } = weapon;
    id.delete();
}

/// Get the name of the `Weapon`.
public fun name(w: &Weapon): String { w.name }

/// Get the base damage of the `Weapon`.
public fun damage(w: &Weapon): u8 { w.damage }

/// Get the spread of the `Weapon`.
public fun spread(w: &Weapon): u8 { w.spread }

/// Get the chance to deal additional point of damage of the `Weapon`.
public fun plus_one(w: &Weapon): u8 { w.plus_one }

/// Get the chance to deal critical damage of the `Weapon`.
public fun crit_chance(w: &Weapon): u8 { w.crit_chance }

/// Get the dodgeability of the `Weapon`, i.e. whether the weapon can be dodged.
///
/// Grenades and explosives are not dodgeable, while bullets are. However, some
/// weapons might have special abilities that make them undodgeable.
public fun is_dodgeable(w: &Weapon): bool { w.is_dodgeable }

/// Get the area damage of the `Weapon`.
public fun area_damage(w: &Weapon): bool { w.area_damage }

/// Get the area size of the `Weapon`, only for area damage weapons.
///
/// Expected value for most of the weapons is `1`. Each increment adds all the
/// neighboring tiles to the area of effect.
///
/// This example illustrates different area sizes (1-3):
/// ```
/// | | |3| | |
/// | |3|2|3| |
/// |3|2|1|2|3|
/// | |3|2|3| |
/// | | |3| | |
/// ```
public fun area_size(w: &Weapon): u8 { w.area_size }

/// Get the range of the `Weapon`.
public fun range(w: &Weapon): u8 { w.range }

/// Get the ammo of the `Weapon`.
public fun ammo(w: &Weapon): u8 { w.ammo }
