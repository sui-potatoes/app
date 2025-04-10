// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Base64 encoding.
///
/// See [RFC 4648; Section 4](https://datatracker.ietf.org/doc/html/rfc4648#section-4) for more details.
module codec::base64;

use std::string::String;

#[allow(unused_const)]
/// Error code for illegal character.
const EIllegalCharacter: u64 = 0;
#[allow(unused_const)]
/// Error code for incorrect number of characters.
const EIncorrectNumberOfCharacters: u64 = 1;

/// Base64 keys.
const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

/// Encode the `str` to base64.
public fun encode(bytes: vector<u8>): String {
    encode_impl!(bytes, KEYS, true)
}

/// Decode the base64 `str`.
public fun decode(str: String): vector<u8> {
    decode_impl!(str, KEYS)
}

/// Internal macro for base64-based encodings, allows to use different dictionaries
/// and control padding.
public(package) macro fun encode_impl(
    $bytes: vector<u8>,
    $dictionary: vector<u8>,
    $pad: bool,
): String {
    let mut bytes = $bytes;
    let keys = $dictionary;
    let mut res = vector[];
    let mut len = bytes.length();
    bytes.reverse();

    while (len > 0) {
        len = len - 1;
        let b1 = bytes.pop_back();
        let b2 = if (bytes.length() > 0) {
            len = len - 1;
            bytes.pop_back()
        } else 0;

        let b3 = if (bytes.length() > 0) {
            len = len - 1;
            bytes.pop_back()
        } else 0;

        let c1 = b1 >> 2;
        let c2 = ((b1 & 3) << 4) | (b2 >> 4);
        let c3 = if (len == 0 && b2 == 0) 64 else ((b2 & 15) << 2) | (b3 >> 6);
        let c4 = if (len == 0 && b3 == 0) 64 else b3 & 63;

        res.append(vector[keys[c1 as u64], keys[c2 as u64], keys[c3 as u64], keys[c4 as u64]]);
    };

    res.to_string()
}

public(package) macro fun decode_impl($str: String, $dictionary: vector<u8>): vector<u8> {
    let keys = $dictionary;
    let str = $str;
    let mut res = vector[];
    let mut bytes = str.into_bytes();
    let mut len = bytes.length();
    bytes.reverse();

    // Ensure the length is a multiple of 4.
    assert!(len % 4 == 0, 1);

    while (len > 0) {
        let (res1, b1) = keys.index_of(&bytes.pop_back());
        let (res2, b2) = keys.index_of(&bytes.pop_back());
        let (res3, b3) = keys.index_of(&bytes.pop_back());
        let (res4, b4) = keys.index_of(&bytes.pop_back());

        assert!(res1 && res2 && res3 && res4, 0); //

        let c1 = (b1 << 2) | (b2 >> 4);
        let c2 = ((b2 & 15) << 4) | (b3 >> 2);
        let c3 = ((b3 & 3) << 6) | b4;

        res.push_back(c1 as u8);
        if (b3 != 64) res.push_back(c2 as u8);
        if (b4 != 64) res.push_back(c3 as u8);
        len = len - 4;
    };

    res
}

#[test]
fun test_encode() {
    use std::unit_test::assert_eq;

    assert_eq!(encode(b"hello"), b"aGVsbG8=".to_string());
    assert_eq!(encode(b"world"), b"d29ybGQ=".to_string());
    assert_eq!(encode(b"hello world"), b"aGVsbG8gd29ybGQ=".to_string());
    assert_eq!(encode(b"sui potatoes"), b"c3VpIHBvdGF0b2Vz".to_string());

    // need to create tricky use case for encode - padding
    assert_eq!(encode(b"/"), b"Lw==".to_string());
    assert_eq!(encode(b"//"), b"Ly8=".to_string());
    assert_eq!(encode(b"///"), b"Ly8v".to_string());
}

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    use std::unit_test::assert_eq;
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test]
fun test_decode() {
    use std::unit_test::assert_eq;

    assert_eq!(decode(b"aGVsbG8=".to_string()), b"hello");
    assert_eq!(decode(b"d29ybGQ=".to_string()), b"world");
    assert_eq!(decode(b"aGVsbG8gd29ybGQ=".to_string()), b"hello world");
    assert_eq!(decode(b"c3VpIHBvdGF0b2Vz".to_string()), b"sui potatoes");
}

#[test, expected_failure(abort_code = EIncorrectNumberOfCharacters)]
fun test_decode_length_failure() {
    // count of characters is not multiple of 4
    decode(b"aGVsbG8".to_string());
}

#[test, expected_failure(abort_code = EIllegalCharacter)]
fun test_decode_character_failure() {
    // count of characters is not multiple of 4
    decode(b"aGVs\\G8=".to_string());
}
