// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// A simple builder for easier creation and testing of `Weapon` instances.
module commander::weapon_builder;

use commander::weapon::{Self, Weapon};
use std::string::String;

/// Test-only utility to create a weapon with custom parameters.
public struct WeaponBuilder has drop {
    name: Option<String>,
    damage: Option<u8>,
    spread: Option<u8>,
    plus_one: Option<u8>,
    crit_chance: Option<u8>,
    is_dodgeable: Option<bool>,
    area_size: Option<u8>,
    range: Option<u8>,
    ammo: Option<u8>,
}

/// Create a new builder instance.
public fun new(): WeaponBuilder {
    WeaponBuilder {
        name: option::none(),
        damage: option::none(),
        spread: option::none(),
        plus_one: option::none(),
        crit_chance: option::none(),
        is_dodgeable: option::none(),
        area_size: option::none(),
        range: option::none(),
        ammo: option::none(),
    }
}

/// Set the name of the weapon.
public fun name(mut self: WeaponBuilder, name: String): WeaponBuilder {
    self.name = option::some(name);
    self
}

/// Set the base damage of the weapon.
public fun damage(mut self: WeaponBuilder, damage: u8): WeaponBuilder {
    self.damage = option::some(damage);
    self
}

/// Set the spread of the weapon.
public fun spread(mut self: WeaponBuilder, spread: u8): WeaponBuilder {
    self.spread = option::some(spread);
    self
}

/// Set the plus one of the weapon.
public fun plus_one(mut self: WeaponBuilder, plus_one: u8): WeaponBuilder {
    self.plus_one = option::some(plus_one);
    self
}

/// Set the crit chance of the weapon.
public fun crit_chance(mut self: WeaponBuilder, crit_chance: u8): WeaponBuilder {
    self.crit_chance = option::some(crit_chance);
    self
}

/// Set whether the weapon is dodgeable.
public fun is_dodgeable(mut self: WeaponBuilder, is_dodgeable: bool): WeaponBuilder {
    self.is_dodgeable = option::some(is_dodgeable);
    self
}

/// Set the area size of the weapon.
public fun area_size(mut self: WeaponBuilder, area_size: u8): WeaponBuilder {
    self.area_size = option::some(area_size);
    self
}

/// Set the range of the weapon.
public fun range(mut self: WeaponBuilder, range: u8): WeaponBuilder {
    self.range = option::some(range);
    self
}

/// Set the ammo of the weapon.
public fun ammo(mut self: WeaponBuilder, ammo: u8): WeaponBuilder {
    self.ammo = option::some(ammo);
    self
}

/// Build the weapon.
public fun build(self: WeaponBuilder, ctx: &mut TxContext): Weapon {
    weapon::new(
        self.name.destroy_or!(b"Standard Issue Rifle".to_string()),
        self.damage.destroy_or!(5),
        self.spread.destroy_or!(1),
        self.plus_one.destroy_or!(0),
        self.crit_chance.destroy_or!(0),
        self.is_dodgeable.destroy_or!(true),
        self.area_size.destroy_or!(1),
        self.range.destroy_or!(5),
        self.ammo.destroy_or!(3),
        ctx,
    )
}

#[test]
fun test_weapon_builder() {
    use std::unit_test::assert_eq;
    let ctx = &mut tx_context::dummy();
    let weapon = Self::new()
        .name(b"Custom Weapon".to_string())
        .damage(7)
        .spread(1)
        .plus_one(0)
        .crit_chance(0)
        .is_dodgeable(true)
        .area_size(1)
        .range(5)
        .ammo(3)
        .build(ctx);

    assert_eq!(weapon.name(), b"Custom Weapon".to_string());
    assert_eq!(weapon.damage(), 7);
    assert_eq!(weapon.spread(), 1);
    assert_eq!(weapon.plus_one(), 0);
    assert_eq!(weapon.crit_chance(), 0);
    assert_eq!(weapon.is_dodgeable(), true);
    assert_eq!(weapon.area_damage(), false);
    assert_eq!(weapon.area_size(), 1);
    assert_eq!(weapon.range(), 5);
    assert_eq!(weapon.ammo(), 3);

    weapon.destroy();
}
