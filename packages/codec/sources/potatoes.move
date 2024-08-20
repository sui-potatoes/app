// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// This encoding scheme is a twist on the classic HEX encoding, but instead of
/// using the standard HEX characters, it uses each of the 6 letters in the
/// "potatoes" word to represent each byte in Base16 past 9.
///
/// ```move
/// use codec::potatoes;
/// assert!(b"potatoes".to_string() == potatoes::encode(x"0xabcdcbef"));
/// ```
module codec::potatoes;

use std::string::String;

// prettier-ignore
/// Each byte is encoded to one of these sub-characters.
/// Similar to the HEX encoding, but uses the word "POTAES" instead of "ABCDEF".
const CHARACTER_SET: vector<vector<u8>> = vector[
    b"00", b"01", b"02", b"03", b"04", b"05", b"06", b"07", b"08", b"09", b"0p", b"0o", b"0t", b"0a", b"0e", b"0s",
    b"10", b"11", b"12", b"13", b"14", b"15", b"16", b"17", b"18", b"19", b"1p", b"1o", b"1t", b"1a", b"1e", b"1s",
    b"20", b"21", b"22", b"23", b"24", b"25", b"26", b"27", b"28", b"29", b"2p", b"2o", b"2t", b"2a", b"2e", b"2s",
    b"30", b"31", b"32", b"33", b"34", b"35", b"36", b"37", b"38", b"39", b"3p", b"3o", b"3t", b"3a", b"3e", b"3s",
    b"40", b"41", b"42", b"43", b"44", b"45", b"46", b"47", b"48", b"49", b"4p", b"4o", b"4t", b"4a", b"4e", b"4s",
    b"50", b"51", b"52", b"53", b"54", b"55", b"56", b"57", b"58", b"59", b"5p", b"5o", b"5t", b"5a", b"5e", b"5s",
    b"60", b"61", b"62", b"63", b"64", b"65", b"66", b"67", b"68", b"69", b"6p", b"6o", b"6t", b"6a", b"6e", b"6s",
    b"70", b"71", b"72", b"73", b"74", b"75", b"76", b"77", b"78", b"79", b"7p", b"7o", b"7t", b"7a", b"7e", b"7s",
    b"80", b"81", b"82", b"83", b"84", b"85", b"86", b"87", b"88", b"89", b"8p", b"8o", b"8t", b"8a", b"8e", b"8s",
    b"90", b"91", b"92", b"93", b"94", b"95", b"96", b"97", b"98", b"99", b"9p", b"9o", b"9t", b"9a", b"9e", b"9s",
    b"p0", b"p1", b"p2", b"p3", b"p4", b"p5", b"p6", b"p7", b"p8", b"p9", b"pp", b"po", b"pt", b"pa", b"pe", b"ps",
    b"o0", b"o1", b"o2", b"o3", b"o4", b"o5", b"o6", b"o7", b"o8", b"o9", b"op", b"oo", b"ot", b"oa", b"oe", b"os",
    b"t0", b"t1", b"t2", b"t3", b"t4", b"t5", b"t6", b"t7", b"t8", b"t9", b"tp", b"to", b"tt", b"ta", b"te", b"ts",
    b"a0", b"a1", b"a2", b"a3", b"a4", b"a5", b"a6", b"a7", b"a8", b"a9", b"ap", b"ao", b"at", b"aa", b"ae", b"as",
    b"e0", b"e1", b"e2", b"e3", b"e4", b"e5", b"e6", b"e7", b"e8", b"e9", b"ep", b"eo", b"et", b"ea", b"ee", b"es",
    b"s0", b"s1", b"s2", b"s3", b"s4", b"s5", b"s6", b"s7", b"s8", b"s9", b"sp", b"so", b"st", b"sa", b"se", b"ss",
];

/// Now let's play with the encoding and decoding functions.
public fun encode(bytes: vector<u8>): String {
    let chars = CHARACTER_SET;
    let result = bytes.fold!(
        vector[],
        |mut acc, b| {
            acc.append(chars[b as u64]);
            acc
        },
    );

    result.to_string()
}

/// Decode a potato-encoded string.
/// A,B,C,D,E,F is encoded as P,O,T,A,E,S
public fun decode(str: String): vector<u8> {
    let bytes = str.into_bytes();
    let (mut i, mut r, l) = (0, vector[], bytes.length());
    assert!(l % 2 == 0);
    while (i < l) {
        let decimal = decode_byte(bytes[i]) * 16 + decode_byte(bytes[i + 1]);
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
fun decode_byte(byte: u8): u8 {
    if (48 <= byte && byte < 58) byte - 48 // 0 .. 9
    else if (byte == 112 || byte == 80) 10 // p or P
    else if (byte == 111 || byte == 79) 11 // o or O
    else if (byte == 116 || byte == 84) 12 // t or T
    else if (byte == 97 || byte == 65) 13 // a or A
    else if (byte == 101 || byte == 69) 14 // e or E
    else if (byte == 115 || byte == 83) 15 // s or S
    else abort 1
}

#[test]
fun check_character_set_length() {
    let set = CHARACTER_SET;
    assert!(set.length() == 256);
}

#[test]
fun test_encode() {
    assert!(encode(vector[0, 1, 2, 3]) == b"00010203".to_string());
    assert!(encode(decode(b"potatoes".to_string())) == b"potatoes".to_string());
    assert!(encode(decode(b"potato4tea".to_string())) == b"potato4tea".to_string());
}
