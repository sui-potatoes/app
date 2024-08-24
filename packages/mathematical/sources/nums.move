// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Contains common utility functions such as converting a number to a string.
module mathematical::nums;

use std::string::String;

/// Returns the maximum value for `u8`.
public fun u8_max(): u8 { 255 }

/// Returns the maximum value for `u16`.
public fun u16_max(): u16 { 65535 }

/// Returns the maximum value for `u32`.
public fun u32_max(): u32 { 4294967295 }

/// Returns the maximum value for `u64`.
public fun u64_max(): u64 { 18446744073709551615 }

/// Returns the maximum value for `u128`.
public fun u128_max(): u128 { 340282366920938463463374607431768211455 }

/// Returns the maximum value for `u256`.
public fun u256_max(): u256 {
    115792089237316195423570985008687907853269984665640564039457584007913129639935
}

/// Converts a number to a string.
public macro fun to_string<$T>($num: $T): String {
    let mut num = $num;
    let mut res = vector[];
    if (num == 0) return vector[48].to_string();
    while (num > 0) {
        let digit = (num % 10) as u8;
        num = num / 10;
        res.insert(digit + 48, 0);
    };

    res.to_string()
}
