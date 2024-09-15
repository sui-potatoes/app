// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::unit_tests;

use commander::unit;
use std::unit_test::assert_eq;
use sui::bcs;

#[test]
fun sniper_creation() {
    let sniper = unit::sniper();

    assert_eq!(sniper.symbol(), b"L".to_string());
    assert_eq!(sniper.name(), b"Sniper".to_string());
    assert_eq!(sniper.health().value(), 60);
    assert_eq!(sniper.ap().value(), 10);
    assert_eq!(sniper.action(0).name(), b"Move".to_string());
    assert_eq!(sniper.action(1).name(), b"Shoot".to_string());
    assert_eq!(sniper.action(2).name(), b"Wait".to_string());
    assert_eq!(sniper.action(0).cost(), 1);
    assert_eq!(sniper.action(1).cost(), 5);
    assert_eq!(sniper.action(2).cost(), 1);
}

#[test]
fun to_from_bcs() {
    let sniper = unit::sniper();
    let bytes = bcs::to_bytes(&sniper);

    assert_eq!(sniper, unit::from_bytes(bytes));
}
