// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module formula::formula_tests;

use formula::formula;
use std::unit_test::assert_eq;

#[test]
fun test_pow_scaled() {
    // f(x) = (x / 10) ^ 2
    let f = formula::new<u32>().div(10).pow(2);
    assert_eq!(f.calc_u32(100), 100);
}

#[test]
fun test_operation_order() {
    // f(x) = x / 10 * 2; tranformed: f(x) = x * 2 / 10
    let f = formula::new().div(10).mul(2);
    assert_eq!(f.calc_u8(15), 3); // swapped operations, or we'd get 2

    // f(x) = x - 10 + 2; transformed: f(x) = x + 2 - 10
    let f = formula::new().sub(10).add(2);
    assert_eq!(f.calc_u8(8), 0); // swapped operations, or we'd get underflow!
}

#[test]
fun test_min_max() {
    // f(x) = max(x * 10, 1_000) / 100
    let f = formula::new().mul(10).max(1_000).div(100);
    assert_eq!(f.calc_u16(1), 10);
    assert_eq!(f.calc_u16(100), 10);
    assert_eq!(f.calc_u16(1000), 100);

    // f(x) = max(X / 100, 10) * 10
    let f = formula::new().div(100).max(10).mul(10);

    assert_eq!(f.calc_u16(1), 100);
    assert_eq!(f.calc_u16(100), 100);
    assert_eq!(f.calc_u16(1_000), 100);
    assert_eq!(f.calc_u16(10_000), 1_000);
}

#[test]
fun test_bps() {
    // f(x) = x * 0.0003
    let f = formula::new().bps(3); // .03%
    assert_eq!(f.calc_u64(1_000_000_000), 300_000);
    assert_eq!(f.calc_u64(100_00), 3);
    assert_eq!(f.calc_u64(100), 0);

    // try bps on a scaled value
    // f(x) = x / 10 * 0.1
    let f = formula::new().div(10).bps(10_00); // 10% from X / 10
    assert_eq!(f.calc_u64(100), 1);

    // try bps on a subtracted value
    // f(x) = (x - 10) * 0.1
    let f = formula::new().sub(10).bps(10_00); // 10% from X - 10
    assert_eq!(f.calc_u64(100), 9);
}

#[test, expected_failure(abort_code = formula::EOverflow)]
fun test_bps_overflow() {
    // f(x) = x * 1.0001
    let _ = formula::new().bps(100_00 + 1).calc_u32(10);
}

#[test]
fun test_formula() {
    // f(x) = (x + 10) * 100 / 10 - 5
    let f = formula::new().add(10u8).mul(100).div(10).sub(5);

    assert_eq!((*&f).calc_u8(5), 145);
    assert_eq!((*&f).calc_u8(10), 195);

    // f(x) = sqrt(x / 10000 + 1) * 412481737123559485879
    let res = formula::new<u128>()
        .scale(2 << 64)
        .div(10000)
        .add(1)
        .sqrt()
        .mul(412481737123559485879)
        .calc_u128(100);

    // f(x) = x / 1 / 1 / 1 / 1 / 1
    let test_scaling = formula::new().div(1).div(1).div(1).div(1).calc_u128(1);

    assert_eq!(
        414539015407565617054 / 10, // expected result
        res / 10,
    );

    assert_eq!(test_scaling, 1);
}
