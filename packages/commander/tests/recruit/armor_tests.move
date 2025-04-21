// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::armor_tests;

use commander::{armor, stats_builder};
use std::unit_test::assert_eq;

#[test]
fun default() {
    let ctx = &mut tx_context::dummy();
    let armor = armor::default(ctx);

    assert_eq!(armor.name(), b"Standard Armor".to_string());
    assert_eq!(armor.stats().inner(), 0);

    armor.destroy();
}

#[test]
fun new_with_args() {
    let ctx = &mut tx_context::dummy();
    let stats = stats_builder::new().defense(5).hp(10).build();
    let armor = armor::new(b"Titanium Armor".to_string(), stats, ctx);

    assert_eq!(armor.name(), b"Titanium Armor".to_string());
    assert_eq!(armor.stats().inner(), stats.inner());
    assert_eq!(armor.to_string(), b"Titanium Armor".to_string());

    armor.destroy();
}
