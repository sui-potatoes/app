// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::unit_tests;

use commander::unit;
use std::unit_test::assert_eq;
use sui::bcs;

#[test]
fun to_from_bcs() {
    let sniper = unit::sniper();
    let bytes = bcs::to_bytes(&sniper);

    assert_eq!(sniper, unit::from_bytes(bytes));
}
