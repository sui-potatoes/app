// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// prettier-ignore
module name_gen::male;

use std::string::String;

const BUCKET_0: vector<vector<u8>> = vector[b"Abdul", b"Adi", b"Audi", b"Agner", b"Ajax", b"Alan", b"Alyn", b"Alt", b"Alton", b"Altair"];
const BUCKET_1: vector<vector<u8>> = vector[b"Amp", b"Apple", b"Andon", b"Andy", b"Andrew", b"Ang", b"App", b"Arax", b"Arakan", b"Akira"];
const BUCKET_2: vector<vector<u8>> = vector[b"Akihero", b"Akihiko", b"Arin", b"Arp", b"Ash", b"Atsushi", b"Atto", b"Audio", b"Avi", b"Axis"];
const BUCKET_3: vector<vector<u8>> = vector[b"Batch", b"Baud", b"Balun", b"Bear", b"Ben", b"Beep", b"Bic", b"Bing", b"Bit", b"Blade"];
const BUCKET_4: vector<vector<u8>> = vector[b"Board", b"Bob", b"Boot", b"Bot", b"Botan", b"Box", b"Buddy", b"Bug", b"Bus", b"Biff"];
const BUCKET_5: vector<vector<u8>> = vector[b"Biffo", b"Bigun", b"Bingwen", b"Bo", b"Bryant", b"Byte", b"Cam", b"Cap", b"Cas", b"Case"];
const BUCKET_6: vector<vector<u8>> = vector[b"Cadium", b"Cadmium", b"Cael", b"Cap", b"Cell", b"Cermet", b"Charles", b"Chip", b"Chonglin", b"Chen"];
const BUCKET_7: vector<vector<u8>> = vector[b"Choi", b"Cipher", b"Claude", b"Clifford", b"Cloud", b"Click", b"Clip", b"Codec", b"Code", b"Coco"];
const BUCKET_8: vector<vector<u8>> = vector[b"Coil", b"Cord", b"Crash", b"Cron", b"Crypto", b"Cyber", b"Cybo", b"Cyrix", b"Cyke", b"Cyko"];
const BUCKET_9: vector<vector<u8>> = vector[b"Daemon", b"Dai", b"Daryl", b"Dash", b"David", b"Degauss", b"Del", b"Dell", b"Delun", b"Delboy"];
const BUCKET_10: vector<vector<u8>> = vector[b"Deming", b"Digit", b"Dirk", b"Diode", b"Ding", b"Dingdong", b"Dingbang", b"Donut", b"Dock", b"Donk"];
const BUCKET_11: vector<vector<u8>> = vector[b"Dong", b"Dom", b"Domdom", b"Dommy", b"Dyker", b"Dollar", b"Dyne", b"Edgar", b"Error", b"Enlai"];
const BUCKET_12: vector<vector<u8>> = vector[b"Eno", b"Eiko", b"Eldon", b"Fax", b"Fa", b"Fai", b"Far", b"Farwang", b"Flash", b"Frag"];
const BUCKET_13: vector<vector<u8>> = vector[b"Fragmeister", b"Fragman", b"Fu", b"Gan", b"Gaff", b"Gaffa", b"Gaffacake", b"Glitch", b"Glitchman", b"Glenjamin"];
const BUCKET_14: vector<vector<u8>> = vector[b"Genghis", b"Gort", b"Gram", b"Grep", b"Grid", b"Grit", b"Guang", b"Guoliang", b"Guowei", b"Guozhi"];
const BUCKET_15: vector<vector<u8>> = vector[b"Guy", b"Guybrush", b"Hai", b"Han", b"Hans", b"Hannibal", b"Hash", b"Hecto", b"Hub", b"Hud"];
const BUCKET_16: vector<vector<u8>> = vector[b"Ho", b"Hoho", b"Hong", b"Howie", b"Howin", b"Hu", b"Hui", b"Hung", b"Isaac", b"Indigo"];
const BUCKET_17: vector<vector<u8>> = vector[b"Jack", b"Jax", b"Jank", b"Jango", b"Jinx", b"Jiang", b"Jin", b"Jing", b"Jinghai", b"John"];
const BUCKET_18: vector<vector<u8>> = vector[b"Johnjohn", b"Jojo", b"Johnny", b"Ronseal", b"Silicon", b"Spider", b"Spizzo", b"Strobe", b"Kaiser", b"Kaizen"];
const BUCKET_19: vector<vector<u8>> = vector[b"Kaneda", b"Kang", b"Kilo", b"Kriz", b"Ky", b"Kyle", b"Kylo", b"Kade", b"Knox", b"Kirone"];
const BUCKET_20: vector<vector<u8>> = vector[b"Kid", b"Kei", b"Lan", b"Llan", b"Larry", b"Leo", b"Lee", b"Leon", b"Leonard", b"Len"];
const BUCKET_21: vector<vector<u8>> = vector[b"Lenny", b"Leonardo", b"Link", b"Lithium", b"Li", b"Ling", b"Lo", b"Lock", b"Loot", b"Lynx"];
const BUCKET_22: vector<vector<u8>> = vector[b"Lynk", b"Mac", b"Masaru", b"Masato", b"Masoto", b"Masala", b"Mic", b"Mike", b"Miles", b"Ming"];
const BUCKET_23: vector<vector<u8>> = vector[b"Mingli", b"Minzhe", b"M.M", b"Mod", b"Mortimer", b"Mylar", b"Nano", b"Nandez", b"Nate", b"Neo"];
const BUCKET_24: vector<vector<u8>> = vector[b"Neon", b"Nova", b"Nokia", b"Niander", b"Nike", b"Nezu", b"Nut", b"Oberon", b"Onyx", b"Orion"];
const BUCKET_25: vector<vector<u8>> = vector[b"Osson", b"Otto", b"Patch", b"Phase", b"Paradox", b"Phoenix", b"Pine", b"Piezo", b"Ping", b"Pingu"];
const BUCKET_26: vector<vector<u8>> = vector[b"Pluton", b"Proto", b"Peng", b"Pulse", b"Quad", b"Quail", b"Quade", b"Quaid", b"Quan", b"Rack"];
const BUCKET_27: vector<vector<u8>> = vector[b"Radian", b"Radius", b"Ray", b"Raze", b"Rexx", b"Ren", b"Renshu", b"Robby", b"Rom", b"Rick"];
const BUCKET_28: vector<vector<u8>> = vector[b"Rik", b"Rip", b"Ron", b"Router", b"Roy", b"Rye", b"Ryo", b"Ryuk", b"Ru", b"Ruse"];
const BUCKET_29: vector<vector<u8>> = vector[b"Rush", b"Rocket", b"Ryker", b"Skip", b"Slag", b"Sonny", b"Shen", b"Stack", b"Stephen", b"Syke"];
const BUCKET_30: vector<vector<u8>> = vector[b"Sike", b"Srike", b"Sike", b"Stryker", b"Superhans", b"Synch", b"Synchro", b"Tag", b"Taff", b"Taffy"];
const BUCKET_31: vector<vector<u8>> = vector[b"Tetsuo", b"Thread", b"Thomas", b"Thunk", b"Thyristor", b"Track", b"Troy", b"Tuple", b"Turbo", b"Turbotax"];
const BUCKET_32: vector<vector<u8>> = vector[b"Vax", b"Vaxen", b"Vector", b"Verizon", b"Voxel", b"Web", b"Wedge", b"Wire", b"Yukimasa", b"Yosuke"];
const BUCKET_33: vector<vector<u8>> = vector[b"Zero", b"Zinc", b"Zippo", b"Zed", b"Zip"];


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
