// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines common ASCII utilities, including checks for printable and control
/// characters.
///
/// For checks on individual characters, see `ascii::char` and `ascii::control`.
/// While this module provides checks for bytes, its calls can be performed on
/// `String` or `vector<u8>` directly. See example below.
///
/// ```rust
/// use ascii::char;
/// use ascii::ascii;
///
/// // Check if bytes are printable.
/// ascii::is_bytes_printable(b"Hello, world!");
/// b"Hello, world!".all!(|c| char::is_printable!(*c)); // alternative!
///
/// // Check if bytes are control characters.
/// ascii::is_bytes_control(b"\x00\x01");
/// b"\x00\x01".all!(|c| control::is_control!(*c)); // alternative!
///
/// // Check if bytes are extended characters.
/// ascii::is_bytes_extended(b"\xFA");
/// b"\xFA".all!(|c| extended::is_extended!(*c)); // alternative!
/// ```
module ascii::ascii;

use ascii::{char, control, extended};
use std::string::String;

/// Check if a `String` is ASCII.
public fun is_ascii(s: &String): bool {
    s.as_bytes().all!(|c| *c >= 32 && *c <= 127)
}

/// Check if bytes are printable.
public fun is_bytes_printable(bytes: &vector<u8>): bool {
    bytes.all!(|c| char::is_printable!(*c))
}

/// Check if bytes are control characters.
public fun is_bytes_control(bytes: &vector<u8>): bool {
    bytes.all!(|c| control::is_control!(*c))
}

/// Check if bytes are extended characters.
public fun is_bytes_extended(bytes: &vector<u8>): bool {
    bytes.all!(|c| extended::is_extended!(*c))
}

/// Compare two vectors of ASCII bytes, returns true if lhs is less or equal to rhs.
/// This function is extremely helpful for sorting vectors of ASCII bytes.
///
/// Example:
/// ```rust
/// let mut iso_dates = vector[
///     b"2025-05-30T00:00:00Z",
///     b"2025-05-30T01:00:00Z",
///     b"2025-03-10T00:00:00Z",
///     b"2020-10-30T00:00:00Z",
///     b"2025-01-22T00:00:00Z",
/// ];
///
/// // No need to implement a custom comparator!
/// iso_dates.insertion_sort_by!(|a, b| cmp_bytes(a, b));
/// ```
public fun cmp_bytes(a: &vector<u8>, b: &vector<u8>): bool {
    let (a_len, b_len) = (a.length(), b.length());
    'search: {
        a_len.min(b_len).do!(|i| {
            if (a[i] > b[i]) return 'search false;
            if (a[i] < b[i]) return 'search true;
        });
        a_len <= b_len
    }
}

#[test]
fun test_compare() {
    use std::unit_test::assert_eq;

    assert!(cmp_bytes(&b"aaaa", &b"bbbb"));
    assert!(cmp_bytes(&b"aaaa", &b"aaaa"));
    assert!(!cmp_bytes(&b"aaab", &b"aaaa"));

    let mut iso_dates = vector[
        b"2025-05-30T00:00:00Z",
        b"2025-05-30T01:00:00Z",
        b"2025-03-10T00:00:00Z",
        b"2020-10-30T00:00:00Z",
        b"2025-01-22T00:00:00Z",
    ];

    iso_dates.insertion_sort_by!(|a, b| cmp_bytes(a, b));

    assert_eq!(iso_dates, vector[
        b"2020-10-30T00:00:00Z",
        b"2025-01-22T00:00:00Z",
        b"2025-03-10T00:00:00Z",
        b"2025-05-30T00:00:00Z",
        b"2025-05-30T01:00:00Z",
    ]);
}
