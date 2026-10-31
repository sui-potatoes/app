// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// prettier-ignore
module name_gen::female;

use std::string::String;

const BUCKET_0: vector<vector<u8>> = vector["Aela", "Adi", "Ahn", "Ana", "Andromeda", "Annia", "Andra", "Apoch", "Ai", "Aimi"];
const BUCKET_1: vector<vector<u8>> = vector["Aries", "Asta", "Astra", "Astria", "Atsu", "Ava", "Avalon", "Aurora", "Aves", "Aylo"];
const BUCKET_2: vector<vector<u8>> = vector["Ada", "Addy", "Ah Cy", "Ah Kum", "Ah Lam", "Aiguo", "Aki", "Akiko", "Akina", "Akira"];
const BUCKET_3: vector<vector<u8>> = vector["Alexa", "Alpha", "Alva", "Ami", "Amaretto", "Amaratsu", "Amarterasu", "Amaya", "Amida", "Amidala"];
const BUCKET_4: vector<vector<u8>> = vector["Amiga", "Angel", "Ani", "An", "Ann", "Angela", "Anita", "Alita", "Anna", "Antikythera"];
const BUCKET_5: vector<vector<u8>> = vector["Apogee", "Asa", "Asami", "Ava", "Ayaka", "Ayako", "Aycee", "Ayvee", "Azerty", "Bao"];
const BUCKET_6: vector<vector<u8>> = vector["Beep", "Betty", "Bet", "Bit", "Biyu", "Biju", "Blythe", "Birdie", "Bloom", "Bunko"];
const BUCKET_7: vector<vector<u8>> = vector["Cam", "Cameron", "Candela", "Capi", "Cat", "Calli", "Calla", "Calypso", "Case", "Cass"];
const BUCKET_8: vector<vector<u8>> = vector["Ceres", "Clare", "Catalina", "Corona", "Cleo", "Clea", "Cosmina", "Cosmia", "Cosima", "Cathode"];
const BUCKET_9: vector<vector<u8>> = vector["Ceedee", "Centra", "Chassis", "Chang", "Changchang", "Changying", "Chika", "Chikako", "China", "Chizo"];
const BUCKET_10: vector<vector<u8>> = vector["Chizu", "Chyna", "Cho", "Chu", "Chyu", "Comma", "Cookie", "Cordy", "Crystal", "Cyberna"];
const BUCKET_11: vector<vector<u8>> = vector["Daisy", "Daiyu", "Deci", "Deevee", "Den", "Delphine", "Delphina", "Dot", "Dong", "Dongmei"];
const BUCKET_12: vector<vector<u8>> = vector["Dyna", "Eisa", "Elsa", "Ellio", "Em", "Ember", "Emiko", "Emily", "Electra", "Epoxy"];
const BUCKET_13: vector<vector<u8>> = vector["Eve", "Evelyn", "Exa", "Fang", "Fangtastic", "Fangs", "Frances", "Farrah", "Fawke", "Falidae"];
const BUCKET_14: vector<vector<u8>> = vector["Freya", "Freysa", "Frost", "Futura", "Gamma", "Gabriella", "Gai", "Gerty", "Geri", "Genesis"];
const BUCKET_15: vector<vector<u8>> = vector["Geneva", "Genji", "Gevie", "Graze", "Gielle", "Golda", "Grace", "Halo", "Hack", "Hax"];
const BUCKET_16: vector<vector<u8>> = vector["Haven", "Helvetica", "Hinge", "Hun", "Hel", "Hedy", "Hong", "Hua", "Huilang", "Ida"];
const BUCKET_17: vector<vector<u8>> = vector["Infinity", "Io", "Iris", "Jan", "Janet", "Jago", "Jay", "Java", "Juno", "Jean"];
const BUCKET_18: vector<vector<u8>> = vector["Jeri", "Jia", "Jiao", "Jinx", "Joliet", "Joi", "Joy", "Juan", "Katusha", "Kathleen"];
const BUCKET_19: vector<vector<u8>> = vector["Kay", "Kate", "Kala", "Kale", "Kai", "Kibi", "Kira", "Kika", "Kiyoko", "Lan"];
const BUCKET_20: vector<vector<u8>> = vector["Lara", "Laura", "Larp", "Legacy", "Lela", "Leeloo", "Lexie", "Luna", "Lunar", "Luv"];
const BUCKET_21: vector<vector<u8>> = vector["Lain", "Libby", "Lien", "Lady", "Lucia", "Lux", "Lilly", "Lillix", "Lin", "Liu"];
const BUCKET_22: vector<vector<u8>> = vector["Laya", "Loo", "Loot", "Lo", "Lynx", "Link", "Ling", "Lynn", "Mae", "Mai"];
const BUCKET_23: vector<vector<u8>> = vector["May", "Marlyn", "Magda", "Media", "Maria", "Mariette", "Melissa", "Meta", "Mica", "Milli"];
const BUCKET_24: vector<vector<u8>> = vector["Mim", "Molly", "Maybelline", "Moanna", "Mosella", "Moxie", "Nikola", "Nikki", "Ning", "Nui"];
const BUCKET_25: vector<vector<u8>> = vector["Neve", "Nova", "Noona", "Nya", "Nyx", "Ori", "Oria", "Oriana", "Organia", "Orion"];
const BUCKET_26: vector<vector<u8>> = vector["Osson", "Parity", "Paradox", "Parris", "Pine", "Pip", "Pris", "Prissy", "Perigee", "Perl"];
const BUCKET_27: vector<vector<u8>> = vector["Pixie", "Plasma", "Plink", "Poly", "Peach", "Proxy", "Qwerty", "Queen", "Radius", "Raze"];
const BUCKET_28: vector<vector<u8>> = vector["Rexx", "Roxxy", "Ripley", "Rina", "Roberta", "Radia", "Rain", "Refur", "Relay", "Rosetta"];
const BUCKET_29: vector<vector<u8>> = vector["Rosie", "Ruby", "Rubi", "Ruth", "Rust", "Samsung", "Sata", "Sara", "Silica", "Simula"];
const BUCKET_30: vector<vector<u8>> = vector["Shay", "Shaylea", "Sophie", "Sony", "Sprite", "Star", "Synergy", "Tao", "Taffi", "Template"];
const BUCKET_31: vector<vector<u8>> = vector["Tera", "Tetra", "Tiff", "Tilde", "Ting", "Toni", "Trinity", "Triniti", "Trini", "Trinny"];
const BUCKET_32: vector<vector<u8>> = vector["Uma", "Una", "Vasa", "Veekay", "Veronica", "Vira", "Willamette", "Winifred", "Yotta", "Zetta"];
const BUCKET_33: vector<vector<u8>> = vector["Zinc", "Zhora"];

public(package) fun select(num: u16): String {
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
