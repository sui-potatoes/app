// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements base16 (hex) encoding and decoding.
///
/// ### Example
/// ```rust
/// use codec::hex;
///
/// let encoded = hex::encode(b"hello, potato!");
/// let decoded = hex::decode(encoded);
///
/// assert!(encoded == b"68656c6c6f2c20706f7461746f".to_string());
/// assert!(decoded == b"hello, potato!");
/// ```
module codec::hex;

use std::string::String;
use ascii::char;

const EIncorrectNumberOfCharacters: u64 = 0;
const ENotValidHexCharacter: u64 = 1;

// prettier-ignore
/// Each byte is encoded to one of these sub-characters.
const CHARACTER_SET: vector<vector<u8>> = vector[
    b"00", b"01", b"02", b"03", b"04", b"05", b"06", b"07", b"08", b"09", b"0a", b"0b", b"0c", b"0d", b"0e", b"0f",
    b"10", b"11", b"12", b"13", b"14", b"15", b"16", b"17", b"18", b"19", b"1a", b"1b", b"1c", b"1d", b"1e", b"1f",
    b"20", b"21", b"22", b"23", b"24", b"25", b"26", b"27", b"28", b"29", b"2a", b"2b", b"2c", b"2d", b"2e", b"2f",
    b"30", b"31", b"32", b"33", b"34", b"35", b"36", b"37", b"38", b"39", b"3a", b"3b", b"3c", b"3d", b"3e", b"3f",
    b"40", b"41", b"42", b"43", b"44", b"45", b"46", b"47", b"48", b"49", b"4a", b"4b", b"4c", b"4d", b"4e", b"4f",
    b"50", b"51", b"52", b"53", b"54", b"55", b"56", b"57", b"58", b"59", b"5a", b"5b", b"5c", b"5d", b"5e", b"5f",
    b"60", b"61", b"62", b"63", b"64", b"65", b"66", b"67", b"68", b"69", b"6a", b"6b", b"6c", b"6d", b"6e", b"6f",
    b"70", b"71", b"72", b"73", b"74", b"75", b"76", b"77", b"78", b"79", b"7a", b"7b", b"7c", b"7d", b"7e", b"7f",
    b"80", b"81", b"82", b"83", b"84", b"85", b"86", b"87", b"88", b"89", b"8a", b"8b", b"8c", b"8d", b"8e", b"8f",
    b"90", b"91", b"92", b"93", b"94", b"95", b"96", b"97", b"98", b"99", b"9a", b"9b", b"9c", b"9d", b"9e", b"9f",
    b"a0", b"a1", b"a2", b"a3", b"a4", b"a5", b"a6", b"a7", b"a8", b"a9", b"aa", b"ab", b"ac", b"ad", b"ae", b"af",
    b"b0", b"b1", b"b2", b"b3", b"b4", b"b5", b"b6", b"b7", b"b8", b"b9", b"ba", b"bb", b"bc", b"bd", b"be", b"bf",
    b"c0", b"c1", b"c2", b"c3", b"c4", b"c5", b"c6", b"c7", b"c8", b"c9", b"ca", b"cb", b"cc", b"cd", b"ce", b"cf",
    b"d0", b"d1", b"d2", b"d3", b"d4", b"d5", b"d6", b"d7", b"d8", b"d9", b"da", b"db", b"dc", b"dd", b"de", b"df",
    b"e0", b"e1", b"e2", b"e3", b"e4", b"e5", b"e6", b"e7", b"e8", b"e9", b"ea", b"eb", b"ec", b"ed", b"ee", b"ef",
    b"f0", b"f1", b"f2", b"f3", b"f4", b"f5", b"f6", b"f7", b"f8", b"f9", b"fa", b"fb", b"fc", b"fd", b"fe", b"ff",
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
    encode_decode(b"hello");
    encode_decode(b"world");
    encode_decode(b"");
    encode_decode(b"1234567890");
    encode_decode(b"!@#$%^&*()");
    encode_decode(b"🦄🦄🦄🦄🦄");
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
    decode(b"beefe".to_string());
}
