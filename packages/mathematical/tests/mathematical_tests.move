// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module mathematical::mathematical_tests;

use mathematical::{formula, nums};
use sui::test_utils::assert_eq;

#[test]
fun nums_to_string() {
    assert_eq(nums::to_string!(100u8), b"100".to_string());
    assert_eq(nums::to_string!(12349u16), b"12349".to_string());
    assert_eq(nums::to_string!(123456789u128), b"123456789".to_string());
    assert_eq(nums::to_string!(0u256), b"0".to_string());
}

#[test]
fun nums_ux_max() {
    assert_eq(nums::u8_max(), 255);
    assert_eq(nums::u16_max(), 65535);
    assert_eq(nums::u32_max(), 4294967295);
    assert_eq(nums::u64_max(), 18446744073709551615);
    assert_eq(
        nums::u128_max(),
        340282366920938463463374607431768211455,
    );
    assert_eq(
        nums::u256_max(),
        115792089237316195423570985008687907853269984665640564039457584007913129639935,
    );
}

#[test]
fun formula_u8() {
    assert_eq(standard_formula!().calc_u8(5), 145);
    assert_eq(sub_add_swap_formula!().calc_u8(5), 5);
    assert_eq(div_mul_swap_formula!().calc_u8(123), 12);
}

#[test]
fun formula_u16() {
    assert_eq(standard_formula!().calc_u16(5), 145);
    assert_eq(sub_add_swap_formula!().calc_u16(5), 5);
    assert_eq(div_mul_swap_formula!().calc_u16(123), 12);
}

#[test]
fun formula_u32() {
    assert_eq(standard_formula!().calc_u32(5), 145);
    assert_eq(sub_add_swap_formula!().calc_u32(5), 5);
    assert_eq(div_mul_swap_formula!().calc_u32(123), 12);
}

#[test]
fun formula_u64() {
    assert_eq(standard_formula!().calc_u64(5), 145);
    assert_eq(sub_add_swap_formula!().calc_u64(5), 5);
    assert_eq(div_mul_swap_formula!().calc_u64(123), 12);
}

#[test]
fun formula_u128() {
    assert_eq(standard_formula!().calc_u128(5), 145);
    assert_eq(sub_add_swap_formula!().calc_u128(5), 5);
    assert_eq(div_mul_swap_formula!().calc_u128(123), 12);
}

/// Formulat that adds 10, multiplies by 100, divides by 10, and subtracts 5.
/// Pretty much a standard formula.
macro fun standard_formula<$T>(): formula::Formula<$T> {
    formula::new().add(10 as $T).mul(100 as $T).div(10 as $T).sub(5 as $T)
}

/// Formula that subtracts 100, adds 100. Except that we are expecting the
/// operations to be flipped, and precision loss to be minimal.
macro fun sub_add_swap_formula<$T>(): formula::Formula<$T> {
    formula::new().sub(100 as $T).add(100 as $T)
}

/// Formula that divides by 100, multiplies by 10. We expect the operations to
/// be flipped resulting in smaller precision loss.
macro fun div_mul_swap_formula<$T>(): formula::Formula<$T> {
    formula::new().div(100 as $T).mul(10 as $T)
}
