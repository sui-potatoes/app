// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements URL encoding and decoding.
/// Can operate on UTF8 strings, encoding only ASCII characters.
module codec::urlencode;

use std::string::String;

/// Encode a string into URL format. Supports non-printable characters, takes
/// a vector of bytes as input. This function is safe to use with UTF8 strings.
public fun encode(string: vector<u8>): String {
    let mut res = vector[];
    string.do!(
        |c| if (c == 32) {
            res.append(b"%20");
        } else if ((c < 48 || c > 57) && (c < 65 || c > 90) && (c < 97 || c > 122)) {
            res.push_back(37);
            res.push_back((c / 16) + if (c / 16 < 10) 48 else 55);
            res.push_back((c % 16) + if (c % 16 < 10) 48 else 55);
        } else {
            res.push_back(c);
        },
    );

    res.to_string()
}

/// Decode a URL-encoded string.
public fun decode(s: String): vector<u8> {
    let mut res = vector[];
    let mut bytes = s.into_bytes();
    bytes.reverse();

    while (bytes.length() > 0) {
        let c = bytes.pop_back();
        if (c == 37) {
            // percent "%"
            let a = bytes.pop_back();
            let b = bytes.pop_back();
            let a = if (a >= 65) a - 55 else a - 48;
            let b = if (b >= 65) b - 55 else b - 48;
            res.push_back(a * 16 + b);
        } else {
            res.push_back(c);
        };
    };

    res
}

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

#[test]
fun test_urlencode() {
    use sui::test_utils::assert_eq;

    assert_eq(
        encode(b"Hello, World!"),
        b"Hello%2C%20World%21".to_string(),
    );

    let str = b"Hello, World!?<>aa:;";
    assert_eq(decode(encode(str)), str);

    let str = b"    ";
    assert_eq(decode(encode(str)), str);

    let str = x"00FF00";
    assert_eq(decode(encode(str)), str);

    let str = x"FF00FF";
    assert_eq(decode(encode(str)), str);

    let str = b"🦄🦄🦄🦄🦄";
    assert_eq(decode(encode(str)), str);
}
