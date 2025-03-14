// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module name_gen::consonant;

use std::string::String;

const CONSONANTS: vector<vector<u8>> = vector[
    b"B",
    b"Br",
    b"C",
    b"Cr",
    b"D",
    b"F",
    b"G",
    b"H",
    b"J",
    b"Jad",
    b"K",
    b"Kr",
    b"L",
    b"M",
    b"N",
    b"P",
    b"Pr",
    b"Qu",
    b"R",
    b"S",
    b"Sr",
    b"St",
    b"Sp",
    b"T",
    b"Tr",
    b"V",
    b"W",
    b"Wr",
    b"Y",
    b"Z",
];

const POST_CONSONANT: vector<vector<u8>> = vector[
    b"anson",
    b"urton",
    b"onic",
    b"all",
    b"acker",
    b"aban",
    b"aden",
    b"ark",
    b"brough",
    b"eyoun",
    b"ell",
    b"ellis",
    b"edex",
    b"etmer",
    b"ates",
    b"ideman",
    b"yler",
    b"illy",
    b"illiumson",
    b"oan",
    b"ostov",
    b"olotov",
    b"ozhenko",
    b"oss",
    b"omm",
    b"iker",
    b"ik",
    b"allister",
    b"onson",
    b"ogawa",
    b"ulan",
    b"ursor",
];

#[allow(implicit_const_copy)]
public fun select(num: u8, num_2: u8): String {
    let consonant = (num % 30) as u64;
    let post_consonant = (num_2 % 30) as u64;
    let mut last_name = CONSONANTS[consonant].to_string();
    last_name.append_utf8(POST_CONSONANT[post_consonant]);
    last_name
}
