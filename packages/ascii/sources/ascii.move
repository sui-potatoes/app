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
