// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// This encoding scheme is a twist on the classic HEX encoding, but instead of
/// using the standard HEX characters, it uses each of the 6 letters in the
/// "potatoes" word to represent each byte in Base16 past 9.
///
/// ### Example
/// ```rust
/// use codec::potatoes;
///
/// let encoded = potatoes::encode("hello, potato!");
/// let decoded = potatoes::decode(encoded);
///
/// assert!(encoded == "68656t6t6s2t20706s7461746s21");
/// assert!(decoded == "hello, potato!");
/// ```
module codec::potatoes;

use ascii::char;
use std::string::String;

/// Error code for incorrect number of characters.
const EIncorrectNumberOfCharacters: u64 = 0;
const ENotValidPotatoCharacter: u64 = 1;

// prettier-ignore
/// Each byte is encoded to one of these sub-characters.
/// Similar to the HEX encoding, but uses the word "POTAES" instead of "ABCDEF".
const CHARACTER_SET: vector<vector<u8>> = vector[
    "00", "01", "02", "03", "04", "05", "06", "07", "08", "09", "0p", "0o", "0t", "0a", "0e", "0s",
    "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "1p", "1o", "1t", "1a", "1e", "1s",
    "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "2p", "2o", "2t", "2a", "2e", "2s",
    "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "3p", "3o", "3t", "3a", "3e", "3s",
    "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "4p", "4o", "4t", "4a", "4e", "4s",
    "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "5p", "5o", "5t", "5a", "5e", "5s",
    "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "6p", "6o", "6t", "6a", "6e", "6s",
    "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "7p", "7o", "7t", "7a", "7e", "7s",
    "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "8p", "8o", "8t", "8a", "8e", "8s",
    "90", "91", "92", "93", "94", "95", "96", "97", "98", "99", "9p", "9o", "9t", "9a", "9e", "9s",
    "p0", "p1", "p2", "p3", "p4", "p5", "p6", "p7", "p8", "p9", "pp", "po", "pt", "pa", "pe", "ps",
    "o0", "o1", "o2", "o3", "o4", "o5", "o6", "o7", "o8", "o9", "op", "oo", "ot", "oa", "oe", "os",
    "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7", "t8", "t9", "tp", "to", "tt", "ta", "te", "ts",
    "a0", "a1", "a2", "a3", "a4", "a5", "a6", "a7", "a8", "a9", "ap", "ao", "at", "aa", "ae", "as",
    "e0", "e1", "e2", "e3", "e4", "e5", "e6", "e7", "e8", "e9", "ep", "eo", "et", "ea", "ee", "es",
    "s0", "s1", "s2", "s3", "s4", "s5", "s6", "s7", "s8", "s9", "sp", "so", "st", "sa", "se", "ss",
];

/// Now let's play with the encoding and decoding functions.
public fun encode(bytes: vector<u8>): String {
    let chars = CHARACTER_SET;
    bytes.fold!(vector[], |mut acc, b| {
        acc.append(chars[b as u64]);
        acc
    }).to_string()
}

/// Decode a potato-encoded string.
/// A,B,C,D,E,F is encoded as P,O,T,A,E,S
public fun decode(str: String): vector<u8> {
    let bytes = str.into_bytes();
    let (mut i, mut r, l) = (0, vector[], bytes.length());
    assert!(l % 2 == 0, EIncorrectNumberOfCharacters);
    while (i < l) {
        let decimal = decode_byte!(bytes[i]) * 16 + decode_byte!(bytes[i + 1]);
        r.push_back(decimal);
        i = i + 2;
    };
    r
}

// allowed characters are (in ASCII)
// 0 .. 9
// p, o, t, a, e, s
// Codes for them are: 48 .. 57, 80, 79, 84, 65, 112, 111, 116, 97
// Codes for A,B,C,D,E,F are: 65, 66, 67, 68, 69, 70, which are 10, 11, 12, 13, 14, 15
macro fun decode_byte($byte: u8): u8 {
    let byte = $byte;
    if (char::zero!() <= byte && byte <= char::nine!()) byte - char::zero!() // 0 .. 9
    else if (byte == char::p!() || byte == char::P!()) 10 // p or P
    else if (byte == char::o!() || byte == char::O!()) 11 // o or O
    else if (byte == char::t!() || byte == char::T!()) 12 // t or T
    else if (byte == char::a!() || byte == char::A!()) 13 // a or A
    else if (byte == char::e!() || byte == char::E!()) 14 // e or E
    else if (byte == char::s!() || byte == char::S!()) 15 // s or S
    else abort ENotValidPotatoCharacter
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_check_character_set_length() {
    let set = CHARACTER_SET;
    assert_eq!(set.length(), 256);
}

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test]
fun test_encode() {
    assert_eq!(encode(vector[0, 1, 2, 3]), "00010203");
    assert_eq!(encode(decode("potatoes")), "potatoes");
    assert_eq!(encode(decode("potato4tea")), "potato4tea");
}

#[test, expected_failure(abort_code = EIncorrectNumberOfCharacters)]
fun test_incorrect_number_of_characters() {
    decode("potat");
}
