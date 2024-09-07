// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::desc_tests;

use svg::desc;

#[test]
fun test_shapes() {
    use sui::test_utils::assert_eq;

    assert_eq(
        desc::desc(b"Hello, world!".to_string()).to_string(),
        b"<desc>Hello, world!</desc>".to_string(),
    );
    assert_eq(desc::metadata(b"".to_string()).to_string(), b"<metadata></metadata>".to_string());
    assert_eq(
        desc::title(b"Hello, world!".to_string()).to_string(),
        b"<title>Hello, world!</title>".to_string(),
    );
}
