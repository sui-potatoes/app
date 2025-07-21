// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implementation of the `format!` macro in Move. Fills the template with the
/// given values, using the `{}` syntax.
module format::format;

use ascii::char;
use std::string::String;

const EIndicesLengthMismatch: u64 = 0;

/// Format a string with the given values. Similar to `format!` in Rust.
///
/// Example:
/// ```
/// let result = format(b"Hello, {}! It's good to see you, {}!", vector[
///     b"John".to_string(),
///     b"Jane".to_string(),
/// ]);
///
/// assert!(result == b"Hello, John! It's good to see you, Jane!".to_string());
/// ```
public fun format(template: String, values: vector<String>): String {
    let (t, v) = (template, values);
    let mut indices = vector[];
    let len = t.length();
    let v_len = v.length();
    let bytes = t.as_bytes();

    // early return if the values are empty
    if (v_len == 0) return template;

    // push all the indices of the braces, so we can reference them
    // their number must match the length of `v`
    0u64.range_do!(
        len - 1,
        |i| if (bytes[i] == char::left_brace!() && bytes[i + 1] == char::right_brace!()) {
            indices.push_back(i);
        },
    );

    // enforce the invariant
    assert!(v_len == indices.length(), EIndicesLengthMismatch);

    // now construct the string `s`
    let t = t;
    let mut s = b"".to_string();
    let mut offset = 0;

    // iterate over the indices, and concat substrings
    indices.length().do!(|i| {
        s.append(t.substring(offset, indices[i]));
        s.append(v[i]);
        offset = indices[i] + 2;
    });

    s
}

/// Test-only function to print the values to the stdout. Inner call to
/// `debug::print` cannot be published.
///
/// Named `dbg` to make it shorter (compared to `format`).
public macro fun dbg($template: vector<u8>, $values: vector<String>) {
    let t = $template;
    std::debug::print(&format(t.to_string(), $values));
}

#[test]
fun test_format() {
    use std::unit_test::assert_eq;

    // early return if the values are empty
    assert_eq!(b"Hello world!".to_string(), format(b"Hello world!".to_string(), vector[]));

    // simple case
    assert_eq!(
        b"Hello, John! It's good to see you, Jane".to_string(),
        format(
            b"Hello, {}! It's good to see you, {}".to_string(),
            vector[b"John".to_string(), b"Jane".to_string()],
        ),
    );

    // utf-8, emojis
    assert_eq!(
        b"Hello world! 🌍 🌍".to_string(),
        format(
            b"Hello world! 🌍 {}".to_string(),
            vector[b"🌍".to_string()],
        ),
    );

    assert_eq!(
        b"Здравствуй, мир! 🌍 🌍".to_string(),
        format(
            b"Здравствуй, мир! 🌍 {}".to_string(),
            vector[b"🌍".to_string()],
        ),
    );

    dbg!(b"Hello, {}! It's good to see you, {}!", vector[b"John".to_string(), b"Jane".to_string()]);
}
