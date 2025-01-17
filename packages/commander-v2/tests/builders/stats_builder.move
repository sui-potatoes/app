// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// A simple builder for easier creation and testing of `Stats` instances.
module commander::stats_builder;

use commander::stats::{Self, Stats};

/// Test-only utility to create a stats with custom parameters.
public struct StatsBuilder has drop {
    mobility: Option<u8>,
    aim: Option<u8>,
    will: Option<u8>,
    hp: Option<u8>,
    armor: Option<u8>,
    dodge: Option<u8>,
    hack: Option<u8>,
}

/// Create a new builder instance.
public fun new(): StatsBuilder {
    StatsBuilder {
        mobility: option::none(),
        aim: option::none(),
        will: option::none(),
        hp: option::none(),
        armor: option::none(),
        dodge: option::none(),
        hack: option::none(),
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

/// Set the will in the `Stats`.
public fun will(mut self: StatsBuilder, will: u8): StatsBuilder {
    self.will = option::some(will);
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

/// Set the hack in the `Stats`.
public fun hack(mut self: StatsBuilder, hack: u8): StatsBuilder {
    self.hack = option::some(hack);
    self
}

/// Build the `Stats` from the provided parameters.
public fun build(self: StatsBuilder): Stats {
    stats::new(
        self.mobility.destroy_or!(5),
        self.aim.destroy_or!(50),
        self.will.destroy_or!(10),
        self.hp.destroy_or!(10),
        self.armor.destroy_or!(0),
        self.dodge.destroy_or!(0),
        self.hack.destroy_or!(0),
    )
}

#[test]
fun test_stats_builder() {
    use std::unit_test::assert_eq;
    let stats = new().mobility(10).aim(50).will(50).hp(10).armor(0).dodge(0).hack(0).build();

    assert_eq!(stats.aim(), 50);
    assert_eq!(stats.mobility(), 10);
    assert_eq!(stats.will(), 50);
    assert_eq!(stats.health(), 10);
    assert_eq!(stats.armor(), 0);
    assert_eq!(stats.dodge(), 0);
    assert_eq!(stats.hack(), 0);
}
