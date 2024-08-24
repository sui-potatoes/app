// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module mathematical::mathematical_tests;

use mathematical::{formula, nums};

#[test]
fun test_mathematical() {}

#[test]
fun utils_to_string() {
    assert!(nums::to_string!(100u8) == b"100".to_string());
    assert!(nums::to_string!(12349u16) == b"12349".to_string());
    assert!(nums::to_string!(123456789u128) == b"123456789".to_string());
    assert!(nums::to_string!(0u256) == b"0".to_string());
}

#[test]
fun test_formula_u8() {
    standard_formula!().calc_u8(5);
}

macro fun standard_formula<$T>(): formula::Formula<$T> {
    formula::new().add(10 as $T).mul(100 as $T).div(10 as $T).sub(5 as $T)
}
