// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Param` component and its methods.
module commander::param;

use std::string::String;
use sui::bcs::{Self, BCS};

/// A parameter for a `Unit`. Parameters are used to define the state of a
/// `Unit` such as health, action points, and other stats. Parameters have a
/// value and a maximum value, and can be reset to the maximum value at the
/// start of each turn.
public struct Param has copy, drop, store {
    value: u16,
    max_value: u16,
}

/// Create a new `Param` a maximum value.
public fun new(max_value: u16): Param { Param { value: max_value, max_value } }

/// Get the current value of the parameter.
public fun value(param: &Param): u16 { param.value }

/// Get the maximum value of the parameter.
public fun max_value(param: &Param): u16 { param.max_value }

/// Check if the parameter is full, i.e. the value is equal to the maximum value.
public fun is_full(param: &Param): bool { param.value == param.max_value }

/// Check if the parameter is empty, i.e. the value is 0.
public fun is_empty(param: &Param): bool { param.value == 0 }

/// Decrease the value of the parameter by a certain amount. The value cannot go
/// below 0.
public fun decrease(param: &mut Param, amount: u16) {
    param.value = param.value - amount.min(param.value);
}

/// Deplete the value of the parameter to 0.
public fun deplete(param: &mut Param) { param.value = 0; }

/// Reset the value of the parameter to the maximum value.
public fun reset(param: &mut Param) { param.value = param.max_value; }

/// Deserialize bytes into a `Param`.
public fun from_bytes(bytes: vector<u8>): Param {
    let mut bcs = bcs::new(bytes);
    from_bcs(&mut bcs)
}

/// Helper method to allow nested deserialization of `Param`.
public(package) fun from_bcs(bcs: &mut BCS): Param {
    Param {
        value: bcs.peel_u16(),
        max_value: bcs.peel_u16(),
    }
}

/// Convert a parameter to a `String` representation.
public fun to_string(param: &Param): String {
    let mut str = param.value.to_string();
    str.append_utf8(b"/");
    str.append(param.max_value.to_string());
    str
}

#[test]
fun test_param() {
    use std::unit_test::assert_eq;

    let mut param = new(10);

    param.decrease(5);
    assert_eq!(param.max_value(), 10);
    assert_eq!(param.value(), 5);

    param.decrease(5);
    assert!(param.is_empty());

    param.reset();
    assert_eq!(param.value(), 10);
    assert!(param.is_full());

    let old_param = *&param;
    let bytes = bcs::to_bytes(&param);
    let param = from_bytes(bytes);

    assert_eq!(old_param, param);
}
