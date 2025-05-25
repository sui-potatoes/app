// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module ascii::ascii_tests;

use ascii::{ascii, char, control, extended};

#[test]
fun is_set() {
    assert!(ascii::is_bytes_printable(&b"Hello, world!"));
    assert!(b"Hello, world!".all!(|c| char::is_printable!(*c))); // alternative!

    assert!(ascii::is_bytes_control(&b"\x00\x01"));
    assert!(b"\x00\x01".all!(|c| control::is_control!(*c))); // alternative!

    assert!(ascii::is_bytes_extended(&b"\xFA"));
    assert!(b"\xFA".all!(|c| extended::is_extended!(*c))); // alternative!

    // Check if a vector of characters is printable.
    assert!(vector[char::K!(), char::L!(), char::M!()].all!(|c| char::is_printable!(*c)));
}
