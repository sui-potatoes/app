// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module name_gen::consonant;

use std::string::String;

const CONSONANTS: vector<vector<u8>> = vector[
    "B",
    "Br",
    "C",
    "Cr",
    "D",
    "F",
    "G",
    "H",
    "J",
    "Jad",
    "K",
    "Kr",
    "L",
    "M",
    "N",
    "P",
    "Pr",
    "Qu",
    "R",
    "S",
    "Sr",
    "St",
    "Sp",
    "T",
    "Tr",
    "V",
    "W",
    "Wr",
    "Y",
    "Z",
];

const POST_CONSONANT: vector<vector<u8>> = vector[
    "anson",
    "urton",
    "onic",
    "all",
    "acker",
    "aban",
    "aden",
    "ark",
    "brough",
    "eyoun",
    "ell",
    "ellis",
    "edex",
    "etmer",
    "ates",
    "ideman",
    "yler",
    "illy",
    "illiumson",
    "oan",
    "ostov",
    "olotov",
    "ozhenko",
    "oss",
    "omm",
    "iker",
    "ik",
    "allister",
    "onson",
    "ogawa",
    "ulan",
    "ursor",
];

#[allow(implicit_const_copy)]
public(package) fun select(num: u8, num_2: u8): String {
    let consonant = (num % 30) as u64;
    let post_consonant = (num_2 % 30) as u64;
    let mut last_name = CONSONANTS[consonant].to_string();
    last_name.append_utf8(POST_CONSONANT[post_consonant]);
    last_name
}
