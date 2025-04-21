// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::param_tests;

use commander::param;
use std::{bcs, unit_test::assert_eq};

#[test]
fun param_flow() {
    let mut param = param::new(10);

    param.decrease(5);
    assert_eq!(param.max_value(), 10);
    assert_eq!(param.value(), 5);

    param.decrease(5);
    assert!(param.is_empty());
    assert_eq!(param.decrease(5), 0);

    param.reset();
    assert_eq!(param.value(), 10);
    assert!(param.is_full());
}

#[test]
fun to_string() {
    let param = param::new(10);
    assert_eq!(param.to_string(), b"10/10".to_string());

    let mut param = param::new(10);
    param.decrease(5);
    assert_eq!(param.to_string(), b"5/10".to_string());

    param.decrease(5);
    assert_eq!(param.to_string(), b"0/10".to_string());
}

#[test]
fun from_bcs() {
    let mut param = param::new(10);
    param.decrease(5);
    let bytes = bcs::to_bytes(&param);
    let param_copy = param::from_bytes(bytes);

    assert_eq!(param, param_copy);
}
