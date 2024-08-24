// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements a formula calculation module. This module is designed for simple linear formulas
/// with all basic operations like addition, subtraction, multiplication, division, and square root.
///
/// - Works on any type in the integer range from `u8` to `u128`.
/// - The formula remains untyped until the `calc_*` function is called.
/// - The formula can be scaled with a custom scaling factor.
module mathematical::formula;

use mathematical::nums;

const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivideByZero: u64 = 2;

/// Represents an expression in a formula.
public enum Op<T> has copy, drop {
    Div(T),
    Mul(T),
    Add(T),
    Sub(T),
    Pow(u8),
    Sqrt,
}

/// Represents a formula with a list of expressions and an optional scaling
/// factor. Formula remains untyped until the `calc_*` function is called.
///
/// Usage:
/// ```move
/// let formula = new().add(10u8).mul(100).div(10).sub(5).calc_u8(5);
/// ```
/// The above example will calculate the formula for `u8` type with the value 5.
public struct Formula<T> has copy, drop {
    expressions: vector<Op<T>>,
    scaling: Option<T>,
}

/// Create a new formula.
public fun new<T>(): Formula<T> {
    Formula { expressions: vector[], scaling: option::none() }
}

/// Set the scaling factor for the formula. When not set, the default
/// scaling is `1 << type / 2`, where `type` is the number of bits in the
/// integer type.
public fun scale<T>(mut self: Formula<T>, scaling: T): Formula<T> {
    self.scaling.fill(scaling);
    self
}

// === Operations ===

/// Register a division operation to be executed in the `calc_*` functions.
public fun div<T>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Div(arg));
    self
}

/// Register a multiplication operation to be executed in the `calc_*`
/// functions.
public fun mul<T>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Mul(arg));
    self
}

/// Register an addition operation to be executed in the `calc_*` functions.
public fun add<T>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Add(arg));
    self
}

/// Register a subtraction operation to be executed in the `calc_*`
/// functions.
public fun sub<T>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Sub(arg));
    self
}

/// Register a square root operation to be executed in the `calc_*`
/// functions.
public fun sqrt<T>(mut self: Formula<T>): Formula<T> {
    self.expressions.push_back(Op::Sqrt);
    self
}

/// Register a power operation to be executed in the `calc_*` functions.
///
/// Important: the power operation downscales the formula to the base
/// scaling factor, hence it's recommended to use it as the last operation.
public fun pow<T>(mut self: Formula<T>, arg: u8): Formula<T> {
    self.expressions.push_back(Op::Pow(arg));
    self
}

// === Calculation ===

/// Calculate formula for `u8` type.
public fun calc_u8(self: Formula<u8>, value: u8): u8 {
    calc!<u8, u16>(self, value, |v| v.sqrt(), nums::u8_max(), 0)
}

/// Calculate formula for `u16` type.
public fun calc_u16(self: Formula<u16>, value: u16): u16 {
    calc!<u16, u32>(self, value, |v| v.sqrt(), nums::u16_max(), 8)
}

/// Calculate formula for `u32` type.
public fun calc_u32(self: Formula<u32>, value: u32): u32 {
    calc!<u32, u64>(self, value, |v| v.sqrt(), nums::u32_max(), 16)
}

/// Calculate formula for `u64` type.
public fun calc_u64(self: Formula<u64>, value: u64): u64 {
    calc!<u64, u128>(self, value, |v| v.sqrt(), nums::u64_max(), 32)
}

/// Calculate formula for `u128` type.
public fun calc_u128(self: Formula<u128>, value: u128): u128 {
    calc!<u128, u256>(self, value, |v| sqrt_u256(v), nums::u128_max(), 64)
}

// === Internal ===

/// The main calculation function crafted to work with different integer
/// types.
///
/// It handles the scaling, operations, and type conversions. Features extra
/// checks for overflow, underflow, and division by zero. As a bonus, it
/// also optimizes the formula by swapping `div` and `mul`, and `sub` and
/// `add` operations.
macro fun calc<$N, $U>(
    $self: Formula<$N>,
    $value: $N,
    $sqrt: |$U| -> $U,
    $max: $N,
    $scale: u8,
): $N {
    let Formula { mut expressions, scaling } = $self;
    let scaling = scaling.destroy_with_default(1 << $scale) as $U;
    let mut is_scaled = false;

    // if there's a `div` followed by `mul`, swap them
    // if there's a `sub` followed by `add`, swap them too
    expressions
        .length()
        .do!(
            |i| match (&expressions[i]) {
                Op::Div(_) => if ((i + 1) < expressions.length()) {
                    match (&expressions[i + 1]) {
                        Op::Mul(_) => expressions.swap(i, i + 1),
                        _ => (),
                    }
                },
                Op::Sub(_) => if ((i + 1) < expressions.length()) {
                    match (&expressions[i + 1]) {
                        Op::Add(_) => expressions.swap(i, i + 1),
                        _ => (),
                    }
                },
                _ => (),
            },
        );

    let mut value = expressions.fold!(
        $value as $U,
        |res, expr| {
            match (expr) {
                Op::Div(divisor) => {
                    assert!(divisor != 0, EDivideByZero);
                    if (is_scaled) {
                        res / (divisor as $U)
                    } else {
                        is_scaled = true;
                        res * scaling / (divisor as $U)
                    }
                },
                Op::Mul(multiplier) => res * (multiplier as $U),
                Op::Add(addend) => {
                    if (is_scaled) res + ((addend as $U) * scaling)
                    else res + (addend as $U)
                },
                Op::Sub(subtrahend) => {
                    if (is_scaled) {
                        assert!(res >= ((subtrahend as $U) * scaling), EUnderflow);
                        res - ((subtrahend as $U) * scaling)
                    } else {
                        assert!(res >= (subtrahend as $U), EUnderflow);
                        res - (subtrahend as $U)
                    }
                },
                Op::Pow(exponent) => {
                    // may overflow quite easily, get back to me!
                    if (is_scaled && exponent > 1) {
                        is_scaled = false;
                        (res / scaling).pow(exponent)
                    } else {
                        res.pow(exponent)
                    }
                },
                Op::Sqrt => {
                    if (is_scaled) {
                        $sqrt(res * scaling)
                    } else {
                        is_scaled = true;
                        $sqrt(res * scaling * scaling)
                    }
                },
            }
        },
    );

    if (is_scaled) {
        value = value / scaling;
    };

    assert!(value <= $max as $U, EOverflow);
    value as $N
}

#[test]
fun test_pow_scaled() {
    use sui::test_utils::assert_eq;

    let formula = new<u32>().div(10).pow(2).calc_u32(100);
    assert_eq(formula, 100);
}

#[test]
fun test_formula() {
    use sui::test_utils::assert_eq;

    let form = new().add(10u8).mul(100).div(10).sub(5);

    assert!((*&form).calc_u8(5) == 145, 0);
    assert!((*&form).calc_u8(10) == 195, 0);

    let formula = new<u128>().scale(2 << 64).div(10000).add(1).sqrt().mul(412481737123559485879);

    let res = formula.calc_u128(100);
    let test_scaling = new().div(1).div(1).div(1).div(1).calc_u128(1);

    assert_eq(
        414539015407565617054 / 10, // expected result
        res / 10,
    );

    assert_eq(test_scaling, 1);
}

// === Polyfill ===

fun log2_u256(mut x: u256): u8 {
    let mut result = 0;
    if (x >> 128 > 0) {
        x = x >> 128;
        result = result + 128;
    };

    if (x >> 64 > 0) {
        x = x >> 64;
        result = result + 64;
    };

    if (x >> 32 > 0) {
        x = x >> 32;
        result = result + 32;
    };

    if (x >> 16 > 0) {
        x = x >> 16;
        result = result + 16;
    };

    if (x >> 8 > 0) {
        x = x >> 8;
        result = result + 8;
    };

    if (x >> 4 > 0) {
        x = x >> 4;
        result = result + 4;
    };

    if (x >> 2 > 0) {
        x = x >> 2;
        result = result + 2;
    };

    if (x >> 1 > 0) result = result + 1;

    result
}

/// Implements a missing `sqrt` function for `u256` type.
/// Implementation is based on various community projects, and suggested to
/// this project by @kklas
fun sqrt_u256(x: u256): u256 {
    if (x == 0) return 0;

    let mut result = 1 << ((log2_u256(x) >> 1) as u8);

    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;

    result.min(x / result)
}
