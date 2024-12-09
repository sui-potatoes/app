// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Proxies Base16 encoding library from the Sui Framework, but does it for
/// strings instead of bytes.
module codec::hex;

use std::string::String;
use sui::hex;

/// Encode a string to hex format.
public fun encode(bytes: vector<u8>): String {
    hex::encode(bytes).to_string()
}

/// Decode a hex-encoded string.
public fun decode(string: String): vector<u8> {
    hex::decode(string.into_bytes())
}

#[test]
fun test_encode_decode() {
    encode_decode(b"hello");
    encode_decode(b"world");
    encode_decode(b"");
    encode_decode(b"1234567890");
    encode_decode(b"!@#$%^&*()");
    encode_decode(b"🦄🦄🦄🦄🦄");
}

#[test_only]
fun encode_decode(bytes: vector<u8>) {
    use std::unit_test::assert_eq;

    let encoded = encode(bytes);
    let decoded = decode(encoded);
    assert_eq!(bytes, decoded);
}
