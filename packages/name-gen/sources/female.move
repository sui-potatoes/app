// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// prettier-ignore
module name_gen::female;

use std::string::String;

const BUCKET_0: vector<vector<u8>> = vector[b"Aela", b"Adi", b"Ahn", b"Ana", b"Andromeda", b"Annia", b"Andra", b"Apoch", b"Ai", b"Aimi"];
const BUCKET_1: vector<vector<u8>> = vector[b"Aries", b"Asta", b"Astra", b"Astria", b"Atsu", b"Ava", b"Avalon", b"Aurora", b"Aves", b"Aylo"];
const BUCKET_2: vector<vector<u8>> = vector[b"Ada", b"Addy", b"Ah Cy", b"Ah Kum", b"Ah Lam", b"Aiguo", b"Aki", b"Akiko", b"Akina", b"Akira"];
const BUCKET_3: vector<vector<u8>> = vector[b"Alexa", b"Alpha", b"Alva", b"Ami", b"Amaretto", b"Amaratsu", b"Amarterasu", b"Amaya", b"Amida", b"Amidala"];
const BUCKET_4: vector<vector<u8>> = vector[b"Amiga", b"Angel", b"Ani", b"An", b"Ann", b"Angela", b"Anita", b"Alita", b"Anna", b"Antikythera"];
const BUCKET_5: vector<vector<u8>> = vector[b"Apogee", b"Asa", b"Asami", b"Ava", b"Ayaka", b"Ayako", b"Aycee", b"Ayvee", b"Azerty", b"Bao"];
const BUCKET_6: vector<vector<u8>> = vector[b"Beep", b"Betty", b"Bet", b"Bit", b"Biyu", b"Biju", b"Blythe", b"Birdie", b"Bloom", b"Bunko"];
const BUCKET_7: vector<vector<u8>> = vector[b"Cam", b"Cameron", b"Candela", b"Capi", b"Cat", b"Calli", b"Calla", b"Calypso", b"Case", b"Cass"];
const BUCKET_8: vector<vector<u8>> = vector[b"Ceres", b"Clare", b"Catalina", b"Corona", b"Cleo", b"Clea", b"Cosmina", b"Cosmia", b"Cosima", b"Cathode"];
const BUCKET_9: vector<vector<u8>> = vector[b"Ceedee", b"Centra", b"Chassis", b"Chang", b"Changchang", b"Changying", b"Chika", b"Chikako", b"China", b"Chizo"];
const BUCKET_10: vector<vector<u8>> = vector[b"Chizu", b"Chyna", b"Cho", b"Chu", b"Chyu", b"Comma", b"Cookie", b"Cordy", b"Crystal", b"Cyberna"];
const BUCKET_11: vector<vector<u8>> = vector[b"Daisy", b"Daiyu", b"Deci", b"Deevee", b"Den", b"Delphine", b"Delphina", b"Dot", b"Dong", b"Dongmei"];
const BUCKET_12: vector<vector<u8>> = vector[b"Dyna", b"Eisa", b"Elsa", b"Ellio", b"Em", b"Ember", b"Emiko", b"Emily", b"Electra", b"Epoxy"];
const BUCKET_13: vector<vector<u8>> = vector[b"Eve", b"Evelyn", b"Exa", b"Fang", b"Fangtastic", b"Fangs", b"Frances", b"Farrah", b"Fawke", b"Falidae"];
const BUCKET_14: vector<vector<u8>> = vector[b"Freya", b"Freysa", b"Frost", b"Futura", b"Gamma", b"Gabriella", b"Gai", b"Gerty", b"Geri", b"Genesis"];
const BUCKET_15: vector<vector<u8>> = vector[b"Geneva", b"Genji", b"Gevie", b"Graze", b"Gielle", b"Golda", b"Grace", b"Halo", b"Hack", b"Hax"];
const BUCKET_16: vector<vector<u8>> = vector[b"Haven", b"Helvetica", b"Hinge", b"Hun", b"Hel", b"Hedy", b"Hong", b"Hua", b"Huilang", b"Ida"];
const BUCKET_17: vector<vector<u8>> = vector[b"Infinity", b"Io", b"Iris", b"Jan", b"Janet", b"Jago", b"Jay", b"Java", b"Juno", b"Jean"];
const BUCKET_18: vector<vector<u8>> = vector[b"Jeri", b"Jia", b"Jiao", b"Jinx", b"Joliet", b"Joi", b"Joy", b"Juan", b"Katusha", b"Kathleen"];
const BUCKET_19: vector<vector<u8>> = vector[b"Kay", b"Kate", b"Kala", b"Kale", b"Kai", b"Kibi", b"Kira", b"Kika", b"Kiyoko", b"Lan"];
const BUCKET_20: vector<vector<u8>> = vector[b"Lara", b"Laura", b"Larp", b"Legacy", b"Lela", b"Leeloo", b"Lexie", b"Luna", b"Lunar", b"Luv"];
const BUCKET_21: vector<vector<u8>> = vector[b"Lain", b"Libby", b"Lien", b"Lady", b"Lucia", b"Lux", b"Lilly", b"Lillix", b"Lin", b"Liu"];
const BUCKET_22: vector<vector<u8>> = vector[b"Laya", b"Loo", b"Loot", b"Lo", b"Lynx", b"Link", b"Ling", b"Lynn", b"Mae", b"Mai"];
const BUCKET_23: vector<vector<u8>> = vector[b"May", b"Marlyn", b"Magda", b"Media", b"Maria", b"Mariette", b"Melissa", b"Meta", b"Mica", b"Milli"];
const BUCKET_24: vector<vector<u8>> = vector[b"Mim", b"Molly", b"Maybelline", b"Moanna", b"Mosella", b"Moxie", b"Nikola", b"Nikki", b"Ning", b"Nui"];
const BUCKET_25: vector<vector<u8>> = vector[b"Neve", b"Nova", b"Noona", b"Nya", b"Nyx", b"Ori", b"Oria", b"Oriana", b"Organia", b"Orion"];
const BUCKET_26: vector<vector<u8>> = vector[b"Osson", b"Parity", b"Paradox", b"Parris", b"Pine", b"Pip", b"Pris", b"Prissy", b"Perigee", b"Perl"];
const BUCKET_27: vector<vector<u8>> = vector[b"Pixie", b"Plasma", b"Plink", b"Poly", b"Peach", b"Proxy", b"Qwerty", b"Queen", b"Radius", b"Raze"];
const BUCKET_28: vector<vector<u8>> = vector[b"Rexx", b"Roxxy", b"Ripley", b"Rina", b"Roberta", b"Radia", b"Rain", b"Refurb", b"Relay", b"Rosetta"];
const BUCKET_29: vector<vector<u8>> = vector[b"Rosie", b"Ruby", b"Rubi", b"Ruth", b"Rust", b"Samsung", b"Sata", b"Sara", b"Silica", b"Simula"];
const BUCKET_30: vector<vector<u8>> = vector[b"Shay", b"Shaylea", b"Sophie", b"Sony", b"Sprite", b"Star", b"Synergy", b"Tao", b"Taffi", b"Template"];
const BUCKET_31: vector<vector<u8>> = vector[b"Tera", b"Tetra", b"Tiff", b"Tilde", b"Ting", b"Toni", b"Trinity", b"Triniti", b"Trini", b"Trinny"];
const BUCKET_32: vector<vector<u8>> = vector[b"Uma", b"Una", b"Vasa", b"Veekay", b"Veronica", b"Vira", b"Willamette", b"Winifred", b"Yotta", b"Zetta"];
const BUCKET_33: vector<vector<u8>> = vector[b"Zinc", b"Zhora"];

public fun select(num: u16): String {
    let bucket_idx = num % 34;
    let bucket = match (bucket_idx) {
        0 => BUCKET_0,
        1 => BUCKET_1,
        2 => BUCKET_2,
        3 => BUCKET_3,
        4 => BUCKET_4,
        5 => BUCKET_5,
        6 => BUCKET_6,
        7 => BUCKET_7,
        8 => BUCKET_8,
        9 => BUCKET_9,
        10 => BUCKET_10,
        11 => BUCKET_11,
        12 => BUCKET_12,
        13 => BUCKET_13,
        14 => BUCKET_14,
        15 => BUCKET_15,
        16 => BUCKET_16,
        17 => BUCKET_17,
        18 => BUCKET_18,
        19 => BUCKET_19,
        20 => BUCKET_20,
        21 => BUCKET_21,
        22 => BUCKET_22,
        23 => BUCKET_23,
        24 => BUCKET_24,
        25 => BUCKET_25,
        26 => BUCKET_26,
        27 => BUCKET_27,
        28 => BUCKET_28,
        29 => BUCKET_29,
        30 => BUCKET_30,
        31 => BUCKET_31,
        32 => BUCKET_32,
        33 => BUCKET_33,
        _ => abort,
    };

    let index = (num as u64 % bucket.length());
    bucket[index].to_string()
}
