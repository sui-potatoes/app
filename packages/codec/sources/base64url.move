// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Modification of the base64 encoding which uses `-` and `_` instead of `+`
/// and `/`, and does not use padding.
///
/// See [RFC 4648; section 5](https://datatracker.ietf.org/doc/html/rfc4648#section-5)
/// for more details.
///
/// ### Example
/// ```rust
/// use codec::base64url;
///
/// let encoded = base64url::encode(b"hello, potato!");
/// let decoded = base64url::decode(encoded);
///
/// assert!(encoded == b"aGVsbG8sIHBvdGF0byE".to_string());
/// assert!(decoded == b"hello, potato!");
/// ```
module codec::base64url;

use codec::base64;
use std::string::String;

#[allow(unused_const)]
/// Error code for illegal character.
const EIllegalCharacter: u64 = 0;

/// Base64url keys
const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_";

/// Encode the `bytes` into base64url String.
public fun encode(bytes: vector<u8>): String {
    base64::encode_impl!(bytes, KEYS, true)
}

/// Decode the base64url `str` into bytes.
public fun decode(str: String): vector<u8> {
    base64::decode_impl!(str, KEYS, true)
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_encode_decode() {
    let annoying_str =
        b"abc def ghi jkl mno pqrs tuv wxyz ABC DEF GHI JKL MNO PQRS TUV WXYZ /() =?* ' {} abc def ghi jkl mno pqrs tuv wxyz ABC DEF GHI JKL MNO PQRS TUV WXYZ !";

    assert_eq!(
        decode(b"ZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA".to_string()),
        std::bcs::to_bytes(&100u256),
    );

    assert_eq!(
        decode(b"YWJjIGRlZiBnaGkgamtsIG1ubyBwcXJzIHR1diB3eHl6IEFCQyBERUYgR0hJIEpLTCBNTk8gUFFSUyBUVVYgV1hZWiAvKCkgPT8qICcge30gYWJjIGRlZiBnaGkgamtsIG1ubyBwcXJzIHR1diB3eHl6IEFCQyBERUYgR0hJIEpLTCBNTk8gUFFSUyBUVVYgV1hZWiAh".to_string()),
        annoying_str,
    );

    assert_eq!(
        decode(b"G_yJ1_4w0Cqtc5b4QqVlSxW2ejaOx4nDdn6SLEe_h48".to_string()),
        x"1bfc89d7fe30d02aad7396f842a5654b15b67a368ec789c3767e922c47bf878f",
    );

    assert_eq!(
        encode(x"1bfc89d7fe30d02aad7396f842a5654b15b67a368ec789c3767e922c47bf878f"),
        b"G_yJ1_4w0Cqtc5b4QqVlSxW2ejaOx4nDdn6SLEe_h48".to_string(),
    );

    assert_eq!(
        encode(annoying_str),
        b"YWJjIGRlZiBnaGkgamtsIG1ubyBwcXJzIHR1diB3eHl6IEFCQyBERUYgR0hJIEpLTCBNTk8gUFFSUyBUVVYgV1hZWiAvKCkgPT8qICcge30gYWJjIGRlZiBnaGkgamtsIG1ubyBwcXJzIHR1diB3eHl6IEFCQyBERUYgR0hJIEpLTCBNTk8gUFFSUyBUVVYgV1hZWiAh".to_string(),
    );

    assert_eq!(encode(b"<<???>>"), b"PDw_Pz8-Pg".to_string());
}

#[random_test]
fun test_encode_random(bytes: vector<u8>) {
    assert_eq!(decode(encode(bytes)), bytes);
}

#[random_test]
fun test_encode_random_u256(value: u256) {
    let bytes = std::bcs::to_bytes(&value);
    assert_eq!(decode(encode(bytes)), bytes);
}
