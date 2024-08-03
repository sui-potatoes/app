// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_variable)]
module codec::readme_tests;

use std::string::String;

#[test]
fun test_hex() {
    use codec::hex;

    let encoded: String = hex::encode(b"hello, potato!");
    let decoded: vector<u8> = hex::decode(b"DEADBEEF".to_string());
}

#[test]
fun test_base64() {
    use codec::base64;

    let encoded: String = base64::encode(b"hello, potato!");
    let decoded: vector<u8> = base64::decode(b"aGVsbG8sIHBvdGF0byE=".to_string());
}

#[test]
fun test_urlencode() {
    use codec::urlencode;

    let encoded: String = urlencode::encode(b"hello, potato!");
    let decoded: vector<u8> = urlencode::decode(b"hello%2C%20potato%21".to_string());
}

#[test]
fun test_potatoes() {
    use codec::potatoes;

    let encoded: String = potatoes::encode(b"hello, potato!");
    let decoded: vector<u8> = potatoes::decode(b"10POTATOES".to_string());
}
