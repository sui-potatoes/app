// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements URL encoding and decoding.
/// Can operate on UTF8 strings, encoding only ASCII characters.
///
/// ### Example
/// ```rust
/// use codec::urlencode;
///
/// let encoded = urlencode::encode(b"hello, potato!");
/// let decoded = urlencode::decode(encoded);
///
/// assert!(encoded == b"hello%2C%20potato%21".to_string());
/// assert!(decoded == b"hello, potato!");
/// ```
module codec::urlencode;

use ascii::char;
use std::string::String;

/// Encode a string into URL format. Supports non-printable characters, takes
/// a vector of bytes as input. This function is safe to use with UTF8 strings.
public fun encode(string: vector<u8>): String {
    let mut res = vector[];
    string.do!(|c| {
        // 32 = space
        if (c == char::space!()) {
            res.push_back(char::percent!()); // %
            res.push_back(char::two!()); // 2
            res.push_back(char::zero!()); // 0
        } else if (
            (c < char::zero!() || c > char::nine!())
            && (c < char::A!() || c > char::Z!())
            && (c < char::a!() || c > char::z!())
        ) {
            res.push_back(char::percent!()); // %
            res.push_back((c / 16) + if (c / 16 < 10) char::zero!() else char::seven!());
            res.push_back((c % 16) + if (c % 16 < 10) char::zero!() else char::seven!());
        } else {
            res.push_back(c);
        }
    });

    res.to_string()
}

/// Decode a URL-encoded string.
/// Supports legacy `+` encoding for spaces.
public fun decode(s: String): vector<u8> {
    let mut res = vector[];
    let mut bytes = s.into_bytes();
    let mut len = bytes.length();
    bytes.reverse();

    while (len > 0) {
        match (bytes.pop_back()) {
            // plus "+"
            43 => {
                len = len - 1;
                res.push_back(32)
            },
            // percent "%"
            37 => {
                len = len - 3;
                let a = bytes.pop_back();
                let b = bytes.pop_back();
                let a = if (a >= char::A!()) a - char::seven!() else a - char::zero!();
                let b = if (b >= char::A!()) b - char::seven!() else b - char::zero!();
                res.push_back(a * 16 + b)
            },
            // regular ASCII character
            c @ _ => {
                len = len - 1;
                res.push_back(c)
            },
        }
    };

    res
}

#[test_only]
use std::unit_test::assert_eq;

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test]
fun test_urlencode() {
    assert_eq!(decode(b"hello+world".to_string()), b"hello world");
    assert_eq!(encode(b"Hello, World!"), b"Hello%2C%20World%21".to_string());

    let str = b"Hello, World!?<>aa:;";
    assert_eq!(decode(encode(str)), str);

    let str = b"    ";
    assert_eq!(decode(encode(str)), str);

    let str = x"00FF00";
    assert_eq!(decode(encode(str)), str);

    let str = x"FF00FF";
    assert_eq!(decode(encode(str)), str);

    let str = b"🦄🦄🦄🦄🦄";
    assert_eq!(decode(encode(str)), str);

    let str = b"картошки самые крутые";
    assert_eq!(decode(encode(str)), str);
}
