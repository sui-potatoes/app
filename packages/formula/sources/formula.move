// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// This module implements linear formulas for integer types in the range `u8`-
/// `u128` and prevents from shooting oneself in the foot with common math-related
/// mistakes, such as division before multiplication, or underflow/overflow.
///
/// The operations are registered in the Formula instance until the `calc_*`
/// function is called to perform calculation of the final result. Formula can
/// be copied and stored and applied multiple times to different values of a
/// single type.
///
/// ## Important:
/// - formula changes the order of operations in some cases to prevent precision
/// loss, eg `x / 10 * 2` becomes `x * 2 / 10`
/// - formula changes the order of subtraction and addition in some cases to
/// prevent underflow, eg `x - 10 + 2` becomes `x + 2 - 10`
/// - formula upscales the value to the default scaling factor before applying
/// operations which may cause underflow or precision loss: `div`, `sqrt` and
/// `sub`
/// - scaling factor is defined as `1 << `type_bits` / 2`, where `type_bits` is
/// the number of bits in the result type
///
/// ## Example
/// ```
/// use formula::formula;
///
/// #[test]
/// fun formula_example() {
///     // f(x) = (x + 100) / 10 * 2 - 5
///     let f = formula::new().add(100).div(10).mul(2).sub(5);
///     let _res1 = f.calc_u16(100);
///     let _res2 = f.calc_u16(200);
/// }
/// ```
///
/// ## Available operations
/// - `div` - division
/// - `mul` - multiplication
/// - `add` - addition
/// - `sub` - subtraction
/// - `pow` - power
/// - `bps` - basis points (scaled by 100_00)
/// - `min` - cap the intermediate result to a maximum value
/// - `max` - cap the intermediate result to a minimum value
/// - `sqrt` - square root
///
/// Utility functions:
/// - `scale` - set the scaling factor for the formula manually
module formula::formula;

const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivideByZero: u64 = 2;

/// Max value for basis points scaling.
const BPS_MAX: u16 = 100_00;

/// Represents a single operation in a formula.
public enum Op<T> has copy, drop, store {
    Div(T),
    Mul(T),
    Add(T),
    Sub(T),
    Pow(u8),
    BPS(u16),
    Min(T),
    Max(T),
    Sqrt,
}

/// Represents a formula with a list of expressions and an optional scaling
/// factor. Formula remains untyped until the `calc_*` function is called.
///
/// ```rust
/// // f(x) = (x + 100) / 10 * 2 - 5
/// let f = formula::new().add(100).div(10).mul(2).sub(5).min(100);
/// let _res1 = f.calc_u16(100);
/// let _res2 = f.calc_u16(200);
/// ```
public struct Formula<T> has copy, drop, store {
    expressions: vector<Op<T>>,
    scaling: Option<T>,
    optimize: bool,
}

/// Create a new formula.
public fun new<T: drop>(): Formula<T> {
    Formula { expressions: vector[], scaling: option::none(), optimize: true }
}

/// Set the scaling factor for the formula. When not set, the default
/// scaling is `1 << type / 2`, where `type` is the number of bits in the
/// integer type.
///
/// ```rust
/// // f(x) = x / 10
/// let f = formula::new().scale(10).div(10);
/// assert_eq!(f.calc_u8(10), 1);
/// assert_eq!(f.calc_u8(100), 10);
/// ```
public fun scale<T: drop>(mut self: Formula<T>, scaling: T): Formula<T> {
    self.scaling = option::some(scaling);
    self
}

/// Disables operation order optimizations in the formula, effectively executing
/// operations in the order they are registered.
public fun disable_optimizations<T: drop>(mut self: Formula<T>): Formula<T> {
    self.optimize = false;
    self
}

// === Operations ===

/// Register a division operation to be executed in the `calc_*` functions.
/// Value is upscaled to prevent precision loss. Aborts if the divisor is zero.
///
/// ```rust
/// // f(x) = x / 10
/// let f = formula::new().div(10);
/// assert_eq!(f.calc_u8(10), 1);
/// assert_eq!(f.calc_u8(100), 10);
/// ```
public fun div<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Div(arg));
    self
}

/// Register a multiplication operation to be executed in the `calc_*`
/// functions.
///
/// ```rust
/// // f(x) = x * 10
/// let f = formula::new().mul(10);
///
public fun mul<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Mul(arg));
    self
}

/// Register an addition operation to be executed in the `calc_*` functions.
/// Can overlow if the intermediary result is greater than `uX.max_value!()`;
///
/// ```rust
/// // f(x) = x + 10
/// let f = formula::new().add(10);
/// assert_eq!(f.calc_u8(10), 20);
/// assert_eq!(f.calc_u8(15), 25);
/// ```
public fun add<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Add(arg));
    self
}

/// Register a subtraction operation to be executed in the `calc_*`
/// functions. Can underflow if the intermediary result is less than the
/// subtrahend.
///
/// ```rust
/// // f(x) = x - 10
/// let f = formula::new().sub(10);
/// assert_eq!(f.calc_u8(10), 0);
/// assert_eq!(f.calc_u8(15), 5);
/// ```
public fun sub<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Sub(arg));
    self
}

/// Register a square root operation to be executed in the `calc_*`
/// functions. Upscales the value to prevent precision loss.
///
/// ```rust
/// // f(x) = sqrt(x * 100)
/// let f = formula::new().mul(100).sqrt();
/// assert_eq!(f.calc_u8(100), 100);
/// assert_eq!(f.calc_u8(1_000), 316);
/// assert_eq!(f.calc_u8(10_000), 1000);
/// ```
public fun sqrt<T: drop>(mut self: Formula<T>): Formula<T> {
    self.expressions.push_back(Op::Sqrt);
    self
}

/// Register a power operation to be executed in the `calc_*` functions.
///
/// Important: the power operation downscales the formula to the base
/// scaling factor, hence it's recommended to use it as the last operation.
///
/// ```rust
/// // f(x) = x^2 / 10
/// let f = formula::new().pow(2).div(10);
/// assert_eq!(f.calc_u8(100), 1000);
/// ```
public fun pow<T: drop>(mut self: Formula<T>, arg: u8): Formula<T> {
    self.expressions.push_back(Op::Pow(arg));
    self
}

/// Register a basis points operation to be executed in the `calc_*`
///
/// ```rust
/// // f(x) = x * 0.1
/// let f = formula::new().bps(10_00); // 10%
/// assert_eq!(f.calc_u16(100), 10);
/// assert_eq!(f.calc_u16(1_000), 100);
/// ```
public fun bps<T: drop>(mut self: Formula<T>, arg: u16): Formula<T> {
    assert!(arg <= BPS_MAX, EOverflow);
    self.expressions.push_back(Op::BPS(arg));
    self
}

/// Register a minimum operation to be executed in the `calc_*` functions.
/// Sets the max cap on the intermediate result of the formula, preventing it
/// from going above the specified value. Executes `uX.min()` under the hood.
///
/// ```rust
/// // f(x) = min(x, 10) + 10
/// let f = formula::new().min(10).add(10);
/// assert_eq!(f.calc_u8(5), 15);
/// assert_eq!(f.calc_u8(15), 20);
/// assert_eq!(f.calc_u8(30), 20);
/// ```
public fun min<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Min(arg));
    self
}

/// Register a maximum operation to be executed in the `calc_*` functions.
/// Sets the min cap on the intermediate result of the formula, preventing it
/// from going below the specified value. Executes `uX.max()` under the hood.
///
/// ```rust
/// // f(x) = max(x, 10) + 10
/// let f = formula::new().max(10).add(10);
/// assert_eq!(f.calc_u8(5), 20);
/// assert_eq!(f.calc_u8(15), 25);
/// assert_eq!(f.calc_u8(30), 40);
/// ```
public fun max<T: drop>(mut self: Formula<T>, arg: T): Formula<T> {
    self.expressions.push_back(Op::Max(arg));
    self
}

// === Calculation ===

/// Calculate formula for `u8` type.
public fun calc_u8(self: Formula<u8>, value: u8): u8 {
    calc!<u8, u16>(self, value, |v| v.sqrt(), std::u8::max_value!(), 0)
}

/// Calculate formula for `u16` type.
public fun calc_u16(self: Formula<u16>, value: u16): u16 {
    calc!<u16, u32>(self, value, |v| v.sqrt(), std::u16::max_value!(), 8)
}

/// Calculate formula for `u32` type.
public fun calc_u32(self: Formula<u32>, value: u32): u32 {
    calc!<u32, u64>(self, value, |v| v.sqrt(), std::u32::max_value!(), 16)
}

/// Calculate formula for `u64` type.
public fun calc_u64(self: Formula<u64>, value: u64): u64 {
    calc!<u64, u128>(self, value, |v| v.sqrt(), std::u64::max_value!(), 32)
}

/// Calculate formula for `u128` type.
public fun calc_u128(self: Formula<u128>, value: u128): u128 {
    calc!<u128, u256>(self, value, |v| sqrt_u256!(v), std::u128::max_value!(), 64)
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
    let Formula { mut expressions, scaling, optimize } = $self;
    let scaling = scaling.destroy_or!(1 << $scale) as $U;
    let mut is_scaled = false;

    // if there's a `div` followed by `mul`, swap them
    // if there's a `sub` followed by `add`, swap them too
    if (optimize) {
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
    };

    let mut value = expressions.fold!($value as $U, |res, expr| {
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
            Op::Mul(multiplier) => {
                res * (multiplier as $U)
            },
            Op::Add(addend) => {
                if (is_scaled) res + ((addend as $U) * scaling) else res + (addend as $U)
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
            Op::BPS(bps) => {
                res * (bps as $U) / (BPS_MAX as $U)
            },
            Op::Min(min) => {
                res.min(if (is_scaled) scaling else { 1 } * (min as $U))
            },
            Op::Max(max) => {
                res.max(if (is_scaled) scaling else { 1 } * (max as $U))
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
    });

    if (is_scaled) {
        value = value / scaling;
    };

    assert!(value <= $max as $U, EOverflow);
    value as $N
}

// === Polyfill ===

macro fun log2_u256($x: u256): u8 {
    let mut x = $x;
    if (x == 0) return 0;
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
macro fun sqrt_u256($x: u256): u256 {
    let x = $x;
    if (x == 0) return 0;

    let mut result = 1 << ((log2_u256!(x) >> 1) as u8);

    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;
    result = (result + x / result) >> 1;

    result.min(x / result)
}

public macro fun uint_max<$T>(): $T {
    let tn = std::type_name::get<$T>();
    assert!(tn.is_primitive());
    match (*tn.into_string().as_bytes()) {
        b"u8" => std::u8::max_value!() as $T,
        b"u16" => std::u16::max_value!() as $T,
        b"u32" => std::u32::max_value!() as $T,
        b"u64" => std::u64::max_value!() as $T,
        b"u128" => std::u128::max_value!() as $T,
        b"u256" => std::u256::max_value!() as $T,
        _ => abort,
    }
}
