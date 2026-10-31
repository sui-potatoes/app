// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// prettier-ignore
module name_gen::male;

use std::string::String;

const BUCKET_0: vector<vector<u8>> = vector["Abdul", "Adi", "Audi", "Agner", "Ajax", "Alan", "Alyn", "Alt", "Alton", "Altair"];
const BUCKET_1: vector<vector<u8>> = vector["Amp", "Apple", "Andon", "Andy", "Andrew", "Ang", "App", "Arax", "Arakan", "Akira"];
const BUCKET_2: vector<vector<u8>> = vector["Akihero", "Akihiko", "Arin", "Arp", "Ash", "Atsushi", "Atto", "Audio", "Avi", "Axis"];
const BUCKET_3: vector<vector<u8>> = vector["Batch", "Baud", "Balun", "Bear", "Ben", "Beep", "Bic", "Bing", "Bit", "Blade"];
const BUCKET_4: vector<vector<u8>> = vector["Board", "Bo", "Boot", "Bot", "Botan", "Box", "Buddy", "Bug", "Bus", "Biff"];
const BUCKET_5: vector<vector<u8>> = vector["Biffo", "Bigun", "Bingwen", "Bo", "Bryant", "Byte", "Cam", "Cap", "Cas", "Case"];
const BUCKET_6: vector<vector<u8>> = vector["Cadium", "Cadmium", "Cael", "Cap", "Cell", "Cermet", "Charles", "Chip", "Chonglin", "Chen"];
const BUCKET_7: vector<vector<u8>> = vector["Choi", "Cipher", "Claude", "Clifford", "Cloud", "Click", "Clip", "Codec", "Code", "Coco"];
const BUCKET_8: vector<vector<u8>> = vector["Coil", "Cord", "Crash", "Cron", "Crypto", "Cyber", "Cybo", "Cyrix", "Cyke", "Cyko"];
const BUCKET_9: vector<vector<u8>> = vector["Daemon", "Dai", "Daryl", "Dash", "David", "Degauss", "Del", "Dell", "Delun", "Delboy"];
const BUCKET_10: vector<vector<u8>> = vector["Deming", "Digit", "Dirk", "Diode", "Ding", "Dingdong", "Dingbang", "Donut", "Dock", "Donk"];
const BUCKET_11: vector<vector<u8>> = vector["Dong", "Dom", "Domdom", "Dommy", "Dyker", "Dollar", "Dyne", "Edgar", "Error", "Enlai"];
const BUCKET_12: vector<vector<u8>> = vector["Eno", "Eiko", "Eldon", "Fax", "Fa", "Fai", "Far", "Farwang", "Flash", "Frag"];
const BUCKET_13: vector<vector<u8>> = vector["Fragmeister", "Fragman", "Fu", "Gan", "Gaff", "Gaffa", "Gaffacake", "Glitch", "Glitchman", "Glenjamin"];
const BUCKET_14: vector<vector<u8>> = vector["Genghis", "Gort", "Gram", "Grep", "Grid", "Grit", "Guang", "Guoliang", "Guowei", "Guozhi"];
const BUCKET_15: vector<vector<u8>> = vector["Guy", "Guybrush", "Hai", "Han", "Hans", "Hannibal", "Hash", "Hecto", "Hu", "Hud"];
const BUCKET_16: vector<vector<u8>> = vector["Ho", "Hoho", "Hong", "Howie", "Howin", "Hu", "Hui", "Hung", "Isaac", "Indigo"];
const BUCKET_17: vector<vector<u8>> = vector["Jack", "Jax", "Jank", "Jango", "Jinx", "Jiang", "Jin", "Jing", "Jinghai", "John"];
const BUCKET_18: vector<vector<u8>> = vector["Johnjohn", "Jojo", "Johnny", "Ronseal", "Silicon", "Spider", "Spizzo", "Strobe", "Kaiser", "Kaizen"];
const BUCKET_19: vector<vector<u8>> = vector["Kaneda", "Kang", "Kilo", "Kriz", "Ky", "Kyle", "Kylo", "Kade", "Knox", "Kirone"];
const BUCKET_20: vector<vector<u8>> = vector["Kid", "Kei", "Lan", "Llan", "Larry", "Leo", "Lee", "Leon", "Leonard", "Len"];
const BUCKET_21: vector<vector<u8>> = vector["Lenny", "Leonardo", "Link", "Lithium", "Li", "Ling", "Lo", "Lock", "Loot", "Lynx"];
const BUCKET_22: vector<vector<u8>> = vector["Lynk", "Mac", "Masaru", "Masato", "Masoto", "Masala", "Mic", "Mike", "Miles", "Ming"];
const BUCKET_23: vector<vector<u8>> = vector["Mingli", "Minzhe", "M.M", "Mod", "Mortimer", "Mylar", "Nano", "Nandez", "Nate", "Neo"];
const BUCKET_24: vector<vector<u8>> = vector["Neon", "Nova", "Nokia", "Niander", "Nike", "Nezu", "Nut", "Oberon", "Onyx", "Orion"];
const BUCKET_25: vector<vector<u8>> = vector["Osson", "Otto", "Patch", "Phase", "Paradox", "Phoenix", "Pine", "Piezo", "Ping", "Pingu"];
const BUCKET_26: vector<vector<u8>> = vector["Pluton", "Proto", "Peng", "Pulse", "Quad", "Quail", "Quade", "Quaid", "Quan", "Rack"];
const BUCKET_27: vector<vector<u8>> = vector["Radian", "Radius", "Ray", "Raze", "Rexx", "Ren", "Renshu", "Robby", "Rom", "Rick"];
const BUCKET_28: vector<vector<u8>> = vector["Rik", "Rip", "Ron", "Router", "Roy", "Rye", "Ryo", "Ryuk", "Ru", "Ruse"];
const BUCKET_29: vector<vector<u8>> = vector["Rush", "Rocket", "Ryker", "Skip", "Slag", "Sonny", "Shen", "Stack", "Stephen", "Syke"];
const BUCKET_30: vector<vector<u8>> = vector["Sike", "Srike", "Sike", "Stryker", "Superhans", "Synch", "Synchro", "Tag", "Taff", "Taffy"];
const BUCKET_31: vector<vector<u8>> = vector["Tetsuo", "Thread", "Thomas", "Thunk", "Thyristor", "Track", "Troy", "Tuple", "Turbo", "Turbotax"];
const BUCKET_32: vector<vector<u8>> = vector["Vax", "Vaxen", "Vector", "Verizon", "Voxel", "We", "Wedge", "Wire", "Yukimasa", "Yosuke"];
const BUCKET_33: vector<vector<u8>> = vector["Zero", "Zinc", "Zippo", "Zed", "Zip"];

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
