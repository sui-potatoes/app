// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module formula::formula_tests;

use formula::{formula as f, macros::uint_max};
use std::{u128, u16, u256, u32, u64, u8, unit_test::assert_eq};

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

#[test, expected_failure(abort_code = f::EUnderflow)]
fun sub_underflow_no_optimizations_fail() {
    // don't optimize, will underflow
    let f = f::new().disable_optimizations().sub(255).add(200);
    assert_eq!(f.calc_u8(100), 55);
}

// === Op::Mul ===

#[test]
fun mul() {
    // f(x) = x * 10 * 100
    let f = f::new().mul(10).mul(100);
    assert_eq!(f.calc_u32(100), 100_000);

    // f(x) = x / 100 * 1000 (optimized)
    let f = f::new().div(100).mul(1000);
    assert_eq!(f.calc_u32(10), 100);

    // f(x) = x / 100 * 1000 (no optimizations), div
    let f = f::new().disable_optimizations().div(100).mul(1000);
    assert_eq!(f.calc_u32(10), 99);

    // f(x) = x / 100 * 1000 (no optimizations), div_up
    let f = f::new().disable_optimizations().div_up(100).mul(1000);
    assert_eq!(f.calc_u32(10), 100);
}

// === Op::Div ===

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

// === u8 ===

#[test]
fun u8_type() {
    let v = vector[0, 1, 2, 10, u8::max_value!()];
    mul_div_cases!<u8>(v, |f, v| f.calc_u8(v));
    add_sub_cases!<u8>(v, |f, v| f.calc_u8(v));
    rem_cases!<u8>(v, |f, v| f.calc_u8(v));
    // bps_cases!<u8>(v, |f, v| f.calc_u8(v)); // BPS is not supported for u8
}

#[test]
fun u16_type() {
    let v = vector[0, 1, 2, 10, u16::max_value!()];
    mul_div_cases!<u16>(v, |f, v| f.calc_u16(v));
    add_sub_cases!<u16>(v, |f, v| f.calc_u16(v));
    bps_cases!<u16>(v, |f, v| f.calc_u16(v));
}

#[test]
fun u32_type() {
    let v = vector[0, 1, 2, 10, u32::max_value!()];
    mul_div_cases!<u32>(v, |f, v| f.calc_u32(v));
    add_sub_cases!<u32>(v, |f, v| f.calc_u32(v));
    bps_cases!<u32>(v, |f, v| f.calc_u32(v));
}

#[test]
fun u64_type() {
    let v = vector[0, 1, 2, 10, u64::max_value!()];
    mul_div_cases!<u64>(v, |f, v| f.calc_u64(v));
    add_sub_cases!<u64>(v, |f, v| f.calc_u64(v));
    bps_cases!<u64>(v, |f, v| f.calc_u64(v));
}

#[test]
fun u128_type() {
    let v = vector[0, 1, 2, 10, u128::max_value!()];
    mul_div_cases!<u128>(v, |f, v| f.calc_u128(v));
    add_sub_cases!<u128>(v, |f, v| f.calc_u128(v));
    bps_cases!<u128>(v, |f, v| f.calc_u128(v));
}

#[test]
fun uint_max_values() {
    assert_eq!(uint_max!(), u8::max_value!());
    assert_eq!(uint_max!(), u16::max_value!());
    assert_eq!(uint_max!(), u32::max_value!());
    assert_eq!(uint_max!(), u64::max_value!());
    assert_eq!(uint_max!(), u128::max_value!());
    assert_eq!(uint_max!(), u256::max_value!());
}

macro fun cases($cases: vector<_>, $max: _, $f: |_, _, _| -> _) {
    let cases = $cases;
    cases.destroy!(|case| $f(case.max(1) - 1, case, case.min($max - 1) + 1));
}


macro fun bps_cases<$T>($cases: vector<_>, $f: |_, _| -> _) {
    let max = uint_max!<$T>();
    cases!($cases, max, |_, curr, _| {
        assert_eq!($f(f::new().bps(100), curr), curr / 100);
        assert_eq!($f(f::new().bps(0), curr), 0);
        assert_eq!($f(f::new().bps(10_000), curr), curr);
    });
}

macro fun mul_div_cases<$T>($cases: vector<$T>, $calc: |_, _| -> $T) {
    let max = uint_max!<$T>();

    cases!($cases, max, |_, curr, _| {
        assert_eq!($calc(f::new().mul(curr).div_up(curr.max(1)), curr), curr);
        assert_eq!($calc(f::new().mul(max).div_up(max), curr), curr);
        assert_eq!($calc(f::new().div(curr.max(1)).mul(curr), curr), curr);
        assert_eq!($calc(f::new().div(max.max(1)).mul(max), curr), curr);
        assert_eq!($calc(f::new().mul(1).div(1), curr), curr);
    });
}

macro fun add_sub_cases<$T>($cases: vector<_>, $f: |_, _| -> _) {
    let max = uint_max!<$T>();
    cases!($cases, max, |_, curr, _| {
        assert_eq!($f(f::new().add(max).sub(max), curr), curr);
        assert_eq!($f(f::new().disable_optimizations().add(max).sub(max), curr), curr);
        assert_eq!($f(f::new().sub(max).add(max), curr), curr);
    });
}

macro fun rem_cases<$T>($cases: vector<_>, $f: |_, _| -> _) {
    let max = uint_max!<$T>();
    cases!($cases, max, |_, _, next| {
        assert_eq!($f(f::new().rem(next), next), 0);
    });
}
