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

use std::string::String;

/// Encode a string into URL format. Supports non-printable characters, takes
/// a vector of bytes as input. This function is safe to use with UTF8 strings.
public fun encode(string: vector<u8>): String {
    let mut res = vector[];
    string.do!(|c| {
        // 32 = space
        if (c == 32) {
            res.push_back(37); // %
            res.push_back(50); // 2
            res.push_back(48); // 0
        } else if ((c < 48 || c > 57) && (c < 65 || c > 90) && (c < 97 || c > 122)) {
            res.push_back(37); // %
            res.push_back((c / 16) + if (c / 16 < 10) 48 else 55);
            res.push_back((c % 16) + if (c % 16 < 10) 48 else 55);
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
                let a = if (a >= 65) a - 55 else a - 48;
                let b = if (b >= 65) b - 55 else b - 48;
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
/// Check if this byte (from potentially a UTF8 string) is an ASCII character.
fun is_ascii(byte: u8): bool {
    byte < 128
}

#[test]
fun test_is_ascii_character() {
    x"F09F9098".to_string().into_bytes().do!(|c| assert!(!is_ascii(c)));
    x"25".to_string().into_bytes().do!(|c| assert!(is_ascii(c)));
    b"hahaha, yes".to_string().into_bytes().do!(|c| assert!(is_ascii(c)));

    // russian letter Ф, greek letter Δ, and slovak letter Ť
    x"D0A4".to_string().into_bytes().do!(|c| assert!(!is_ascii(c)));
    x"CE94".to_string().into_bytes().do!(|c| assert!(!is_ascii(c)));
    x"C5A4".to_string().into_bytes().do!(|c| assert!(!is_ascii(c)));
    x"F09F9098".to_string().into_bytes().do!(|c| assert!(!is_ascii(c)));
}

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    use std::unit_test::assert_eq;
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test]
fun test_urlencode() {
    use std::unit_test::assert_eq;

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
}
