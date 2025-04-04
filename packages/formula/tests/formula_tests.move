// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module formula::formula_tests;

use formula::{formula as f, macros};
use std::unit_test::assert_eq;

#[test]
fun pow_scaled() {
    // f(x) = (x / 10) ^ 2
    let f = f::new<u32>().div(10).pow(2);
    assert_eq!(f.calc_u32(100), 100);
}

// === Op::Add ===

#[test]
fun add() {
    let f = f::new().add(10).add(100);
    assert_eq!(f.calc_u8(100), 210);
    assert_eq!(f.calc_u8(0), 110);
    assert_eq!(f.calc_u8(1), 111);
}

#[test, expected_failure(abort_code = f::EOverflow)]
fun add_overflow_fail() {
    let _ = f::new().add(100).calc_u8(200);
}

// === Op::Sub ===

#[test]
fun sub() {
    // f(x) = x - 10 - 100;
    let f = f::new().sub(10).sub(100);
    assert_eq!(f.calc_u8(110), 0);
    assert_eq!(f.calc_u8(200), 90);

    // doesn't underflow, operation is optimized
    // f(x) = x + 100 - 100;
    let f = f::new().sub(100).add(100);
    assert_eq!(f.calc_u8(0), 0);
    assert_eq!(f.calc_u8(1), 1);
}

#[test, expected_failure(abort_code = f::EUnderflow)]
fun sub_underflow_fail() {
    let _ = f::new().sub(100).calc_u8(10);
}

// === Op::Mul ===

#[test, expected_failure(abort_code = f::EDivideByZero)]
fun div_zero_fail() {
    let _ = f::new().div(0).calc_u8(1);
}

#[test, expected_failure(abort_code = f::EDivideByZero)]
fun div_up_zero_fail() {
    let _ = f::new().div(0).calc_u8(1);
}

#[test]
fun operation_order() {
    // f(x) = x / 10 * 2; tranformed: f(x) = x * 2 / 10
    let f = f::new().div(10).mul(2);
    assert_eq!(f.calc_u8(15), 3); // swapped operations, or we'd get 2

    // f(x) = x - 10 + 2; transformed: f(x) = x + 2 - 10
    let f = f::new().sub(10).add(2);
    assert_eq!(f.calc_u8(8), 0); // swapped operations, or we'd get underflow!
}

#[test]
fun min_max() {
    // f(x) = max(x * 10, 1_000) / 100
    let f = f::new().mul(10).max(1_000).div(100);
    assert_eq!(f.calc_u16(1), 10);
    assert_eq!(f.calc_u16(100), 10);
    assert_eq!(f.calc_u16(1000), 100);

    // f(x) = max(X / 100, 10) * 10
    let f = f::new().div(100).max(10).mul(10);

    assert_eq!(f.calc_u16(1), 100);
    assert_eq!(f.calc_u16(100), 100);
    assert_eq!(f.calc_u16(1_000), 100);
    assert_eq!(f.calc_u16(10_000), 1_000);
}

#[test]
fun bps() {
    // f(x) = x * 0.0003
    let f = f::new().bps(3); // .03%
    assert_eq!(f.calc_u64(1_000_000_000), 300_000);
    assert_eq!(f.calc_u64(100_00), 3);
    assert_eq!(f.calc_u64(100), 0);

    // try bps on a scaled value
    // f(x) = x / 10 * 0.1
    let f = f::new().div(10).bps(10_00); // 10% from X / 10
    assert_eq!(f.calc_u64(100), 1);

    // try bps on a subtracted value
    // f(x) = (x - 10) * 0.1
    let f = f::new().sub(10).bps(10_00); // 10% from X - 10
    assert_eq!(f.calc_u64(100), 9);

    let f = f::new().mul(1000).bps(10_00);
    let r = f.calc_u16(100);
    assert_eq!(r, 10000); // 10% from X * 1000
}

#[test, expected_failure(abort_code = f::EOverflow)]
fun bps_overflow() {
    // f(x) = x * 1.0001
    let _ = f::new().bps(100_00 + 1).calc_u32(10);
}

#[test]
fun formula() {
    // f(x) = (x + 10) * 100 / 10 - 5
    let f = f::new().add(10u8).mul(100).div(10).sub(5);

    assert_eq!((*&f).calc_u8(5), 145);
    assert_eq!((*&f).calc_u8(10), 195);

    // f(x) = sqrt(x / 10000 + 1) * 412481737123559485879
    let res = f::new<u128>()
        .scale(2 << 64)
        .div(10000)
        .add(1)
        .sqrt()
        .mul(412481737123559485879)
        .calc_u128(100);

    // f(x) = x / 1 / 1 / 1 / 1 / 1
    let scaling = f::new().div(1).div(1).div(1).div(1).calc_u128(1);

    assert_eq!(
        414539015407565617054 / 10, // expected result
        res / 10,
    );

    assert_eq!(scaling, 1);
}

#[test]
fun uint_max() {
    assert_eq!(macros::uint_max!(), std::u8::max_value!());
    assert_eq!(macros::uint_max!(), std::u16::max_value!());
    assert_eq!(macros::uint_max!(), std::u32::max_value!());
    assert_eq!(macros::uint_max!(), std::u64::max_value!());
    assert_eq!(macros::uint_max!(), std::u128::max_value!());
    assert_eq!(macros::uint_max!(), std::u256::max_value!());
}
