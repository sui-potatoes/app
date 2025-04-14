// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Common macro functions provided by the package. All of them are public and
/// can be used elsewhere freely.
module formula::macros;

/// Get the max value of the given uint based on its type.
public macro fun uint_max<$T: drop>(): $T {
    let tn = std::type_name::get<$T>();
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

/// Implements a missing `sqrt` function for `u256` type.
/// Implementation is based on various community projects, and suggested to
/// this project by @kklas
public macro fun sqrt_u256($x: u256): u256 {
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

public macro fun log2_u256($x: u256): u8 {
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
