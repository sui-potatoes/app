// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements base16 (hex) encoding and decoding.
///
/// ### Example
/// ```rust
/// use codec::hex;
///
/// let encoded = hex::encode("hello, potato!");
/// let decoded = hex::decode(encoded);
///
/// assert!(encoded == "68656c6c6f2c20706f7461746f");
/// assert!(decoded == "hello, potato!");
/// ```
module codec::hex;

use ascii::char;
use std::string::String;

const EIncorrectNumberOfCharacters: u64 = 0;
const ENotValidHexCharacter: u64 = 1;

// prettier-ignore
/// Each byte is encoded to one of these sub-characters.
const CHARACTER_SET: vector<vector<u8>> = vector[
    "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0a", "0b", "0c", "0d", "0e", "0f",
    "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1a", "1b", "1c", "1d", "1e", "1f",
    "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2a", "2b", "2c", "2d", "2e", "2f",
    "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3a", "3b", "3c", "3d", "3e", "3f",
    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4a", "4b", "4c", "4d", "4e", "4f",
    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5a", "5b", "5c", "5d", "5e", "5f",
    "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "6a", "6b", "6c", "6d", "6e", "6f",
    "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "7a", "7b", "7c", "7d", "7e", "7f",
    "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8a", "8b", "8c", "8d", "8e", "8f",
    "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9a", "9b", "9c", "9d", "9e", "9f",
    "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "aa", "ab", "ac", "ad", "ae", "af",
    "b0", "b1", "b2", "b3", "b4", "b5", "b6", "b7", "b8", "b9", "ba", "bb", "bc", "bd", "be", "bf",
    "c0", "c1", "c2", "c3", "c4", "c5", "c6", "c7", "c8", "c9", "ca", "cb", "cc", "cd", "ce", "cf",
    "d0", "d1", "d2", "d3", "d4", "d5", "d6", "d7", "d8", "d9", "da", "db", "dc", "dd", "de", "df",
    "e0", "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "e9", "ea", "eb", "ec", "ed", "ee", "ef",
    "f0", "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "fa", "fb", "fc", "fd", "fe", "ff",
];

/// Encode a string to hex format.
public fun encode(bytes: vector<u8>): String {
    let chars = CHARACTER_SET;
    let mut r = vector[];
    bytes.length().do!(|i| r.append(chars[bytes[i] as u64]));
    r.to_string()
}

/// Decode a hex-encoded string.
public fun decode(str: String): vector<u8> {
    let bytes = str.into_bytes();
    let (mut i, mut r, l) = (0, vector[], bytes.length());
    assert!(l % 2 == 0, EIncorrectNumberOfCharacters);
    while (i < l) {
        let decimal = decode_byte(bytes[i]) * 16 + decode_byte(bytes[i + 1]);
        r.push_back(decimal);
        i = i + 2;
    };
    r
}

// Allowed characters are (in ASCII)
// 0 .. 9
// A .. F
// a .. f
fun decode_byte(byte: u8): u8 {
    // let byte = $byte;
    if (char::zero!() <= byte && byte <= char::nine!()) byte - char::zero!()
    else if (char::A!() <= byte && byte <= char::F!()) 10 + byte - char::A!()
    else if (char::a!() <= byte && byte <= char::f!()) 10 + byte - char::a!()
    else abort ENotValidHexCharacter
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_encode_decode() {
    encode_decode("hello");
    encode_decode("world");
    encode_decode("");
    encode_decode("1234567890");
    encode_decode("!@#$%^&*()");
    encode_decode("🦄🦄🦄🦄🦄");
}

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test_only]
fun encode_decode(bytes: vector<u8>) {
    let encoded = encode(bytes);
    let decoded = decode(encoded);
    assert_eq!(bytes, decoded);
}

#[test, expected_failure(abort_code = EIncorrectNumberOfCharacters)]
fun test_incorrect_number_of_characters() {
    decode("beefe");
}
