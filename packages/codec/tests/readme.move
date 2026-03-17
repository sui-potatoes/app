// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_variable)]
module codec::readme_tests;

use std::string::String;

#[test]
fun test_hex() {
    use codec::hex;

    let encoded: String = hex::encode("hello, potato!");
    let decoded: vector<u8> = hex::decode("DEADBEEF");
}

#[test]
fun test_base64() {
    use codec::base64;

    let encoded: String = base64::encode("hello, potato!");
    let decoded: vector<u8> = base64::decode("aGVsbG8sIHBvdGF0byE=");
}

#[test]
fun test_base64url() {
    use codec::base64url;

    let encoded: String = base64url::encode("hello, potato!");
    let decoded: vector<u8> = base64url::decode("aGVsbG8sIHBvdGF0byE");
}

#[test]
fun test_urlencode() {
    use codec::urlencode;

    let encoded: String = urlencode::encode("hello, potato!");
    let decoded: vector<u8> = urlencode::decode("hello%2C%20potato%21");
}

#[test]
fun test_potatoes() {
    use codec::potatoes;

    let encoded: String = potatoes::encode("hello, potato!");
    let decoded: vector<u8> = potatoes::decode("10POTATOES");
}
