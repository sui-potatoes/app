// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// A simple builder for easier creation and testing of `Stats` instances.
module commander::stats_builder;

use commander::stats::{Self, Stats};

/// Test-only utility to create a stats with custom parameters.
public struct StatsBuilder {
    mobility: Option<u8>,
    aim: Option<u8>,
    hp: Option<u8>,
    armor: Option<u8>,
    dodge: Option<u8>,
    defense: Option<u8>,
    damage: Option<u8>,
    spread: Option<u8>,
    plus_one: Option<u8>,
    crit_chance: Option<u8>,
    is_dodgeable: Option<u8>,
    area_size: Option<u8>,
    env_damage: Option<u8>,
    range: Option<u8>,
    ammo: Option<u8>,
}

/// Create a new builder instance.
public fun new(): StatsBuilder {
    StatsBuilder {
        mobility: option::none(),
        aim: option::none(),
        hp: option::none(),
        armor: option::none(),
        dodge: option::none(),
        defense: option::none(),
        damage: option::none(),
        spread: option::none(),
        plus_one: option::none(),
        crit_chance: option::none(),
        is_dodgeable: option::none(),
        area_size: option::none(),
        env_damage: option::none(),
        range: option::none(),
        ammo: option::none(),
    }
}

/// Set the mobility in the `Stats`.
public fun mobility(mut self: StatsBuilder, mobility: u8): StatsBuilder {
    self.mobility = option::some(mobility);
    self
}

/// Set the aim in the `Stats`.
public fun aim(mut self: StatsBuilder, aim: u8): StatsBuilder {
    self.aim = option::some(aim);
    self
}

/// Set the hp in the `Stats`.
public fun hp(mut self: StatsBuilder, hp: u8): StatsBuilder {
    self.hp = option::some(hp);
    self
}

/// Set the armor in the `Stats`.
public fun armor(mut self: StatsBuilder, armor: u8): StatsBuilder {
    self.armor = option::some(armor);
    self
}

/// Set the dodge in the `Stats`.
public fun dodge(mut self: StatsBuilder, dodge: u8): StatsBuilder {
    self.dodge = option::some(dodge);
    self
}

/// Set the defense in the `Stats`.
public fun defense(mut self: StatsBuilder, defense: u8): StatsBuilder {
    self.defense = option::some(defense);
    self
}

/// Set the damage in the `Stats`.
public fun damage(mut self: StatsBuilder, damage: u8): StatsBuilder {
    self.damage = option::some(damage);
    self
}

/// Set the spread in the `Stats`.
public fun spread(mut self: StatsBuilder, spread: u8): StatsBuilder {
    self.spread = option::some(spread);
    self
}

/// Set the plus_one in the `Stats`.
public fun plus_one(mut self: StatsBuilder, plus_one: u8): StatsBuilder {
    self.plus_one = option::some(plus_one);
    self
}

/// Set the crit_chance in the `Stats`.
public fun crit_chance(mut self: StatsBuilder, crit_chance: u8): StatsBuilder {
    self.crit_chance = option::some(crit_chance);
    self
}

/// Set the is_dodgeable in the `Stats`.
public fun is_dodgeable(mut self: StatsBuilder, is_dodgeable: u8): StatsBuilder {
    self.is_dodgeable = option::some(is_dodgeable);
    self
}

/// Set the area_size in the `Stats`.
public fun area_size(mut self: StatsBuilder, area_size: u8): StatsBuilder {
    self.area_size = option::some(area_size);
    self
}

/// Set the env_damage in the `Stats`.
public fun env_damage(mut self: StatsBuilder, env_damage: u8): StatsBuilder {
    self.env_damage = option::some(env_damage);
    self
}

/// Set the range in the `Stats`.
public fun range(mut self: StatsBuilder, range: u8): StatsBuilder {
    self.range = option::some(range);
    self
}

/// Set the ammo in the `Stats`.
public fun ammo(mut self: StatsBuilder, ammo: u8): StatsBuilder {
    self.ammo = option::some(ammo);
    self
}

/// Build the `Stats` from the provided parameters.
public fun build(self: StatsBuilder): Stats {
    let StatsBuilder {
        mobility,
        aim,
        hp,
        armor,
        dodge,
        defense,
        damage,
        spread,
        plus_one,
        crit_chance,
        is_dodgeable,
        area_size,
        env_damage,
        range,
        ammo,
    } = self;

    stats::new_unchecked(
        bit_field::bit_field::pack_u8!(
            vector[
                mobility.destroy_or!(5),
                aim.destroy_or!(50),
                hp.destroy_or!(10),
                armor.destroy_or!(0),
                dodge.destroy_or!(0),
                defense.destroy_or!(0),
                damage.destroy_or!(4),
                spread.destroy_or!(2),
                plus_one.destroy_or!(0),
                crit_chance.destroy_or!(0),
                is_dodgeable.destroy_or!(1),
                area_size.destroy_or!(1),
                env_damage.destroy_or!(0),
                range.destroy_or!(4),
                ammo.destroy_or!(3),
            ],
        ),
    )
}

/// Build base stats
public fun build_base(self: StatsBuilder): Stats {
    let StatsBuilder {
        mobility,
        aim,
        hp,
        armor,
        dodge,
        defense,
        damage,
        spread,
        plus_one,
        crit_chance,
        is_dodgeable,
        area_size,
        env_damage,
        range,
        ammo,
    } = self;

    stats::new_unchecked(
        bit_field::bit_field::pack_u8!(
            vector[
                mobility.destroy_or!(5),
                aim.destroy_or!(50),
                hp.destroy_or!(10),
                armor.destroy_or!(0),
                dodge.destroy_or!(0),
                defense.destroy_or!(0),
                damage.destroy_or!(0),
                spread.destroy_or!(0),
                plus_one.destroy_or!(0),
                crit_chance.destroy_or!(0),
                is_dodgeable.destroy_or!(0),
                area_size.destroy_or!(0),
                env_damage.destroy_or!(0),
                range.destroy_or!(0),
                ammo.destroy_or!(0),
            ],
        ),
    )
}

/// Build stats for weapon.
public fun build_weapon(self: StatsBuilder): Stats {
    let StatsBuilder {
        mobility,
        aim,
        hp,
        armor,
        dodge,
        defense,
        damage,
        spread,
        plus_one,
        crit_chance,
        is_dodgeable,
        area_size,
        env_damage,
        range,
        ammo,
    } = self;

    stats::new_unchecked(
        bit_field::bit_field::pack_u8!(
            vector[
                mobility.destroy_or!(0),
                aim.destroy_or!(0),
                hp.destroy_or!(0),
                armor.destroy_or!(0),
                dodge.destroy_or!(0),
                defense.destroy_or!(0),
                damage.destroy_or!(4),
                spread.destroy_or!(2),
                plus_one.destroy_or!(0),
                crit_chance.destroy_or!(0),
                is_dodgeable.destroy_or!(1),
                area_size.destroy_or!(1),
                env_damage.destroy_or!(0),
                range.destroy_or!(4),
                ammo.destroy_or!(3),
            ],
        ),
    )
}

#[test_only]
public fun destroy(self: StatsBuilder) {
    sui::test_utils::destroy(self)
}

#[test]
fun test_stats_builder() {
    use std::unit_test::assert_eq;
    let stats = Self::new().mobility(10).aim(50).hp(10).armor(0).dodge(0).build();

    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.mobility(), 10);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
}
