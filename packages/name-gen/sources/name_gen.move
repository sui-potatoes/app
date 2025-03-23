// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: name_gen
module name_gen::name_gen;

use std::string::String;
use sui::random::RandomGenerator;

//

const MALE_LIMIT: u16 = 343;
const FEMALE_LIMIT: u16 = 341;
const LAST_NAME_LIMIT: u16 = 1481;
const CONSONANT: u8 = 30;
const POST_CONSONANT: u8 = 30;

#[allow(lint(public_random))]
/// This function must be used as a part of a `Random` entry function call.
public fun new_male_name(g: &mut RandomGenerator): String {
    let mut res = b"".to_string();
    let name = name_gen::male::select(g.generate_u16_in_range(0, MALE_LIMIT));

    // whether to use consonant
    let last_name = if (g.generate_bool()) {
        name_gen::consonant::select(
            g.generate_u8_in_range(0, CONSONANT),
            g.generate_u8_in_range(0, POST_CONSONANT),
        )
    } else name_gen::last_name::select(g.generate_u16_in_range(0, LAST_NAME_LIMIT));

    res.append(name);
    res.append_utf8(b" ");
    res.append(last_name);
    res
}

#[allow(lint(public_random))]
/// This function must be used as a part of a `Random` entry function call.
public fun new_female_name(g: &mut RandomGenerator): String {
    let mut res = b"".to_string();
    let name = name_gen::female::select(g.generate_u16_in_range(0, FEMALE_LIMIT));

    // whether to use consonant
    let last_name = if (g.generate_bool()) {
        name_gen::consonant::select(
            g.generate_u8_in_range(0, CONSONANT),
            g.generate_u8_in_range(0, POST_CONSONANT),
        )
    } else name_gen::last_name::select(g.generate_u16_in_range(0, LAST_NAME_LIMIT));

    res.append(name);
    res.append_utf8(b" ");
    res.append(last_name);
    res
}

#[random_test]
fun test_generator(seed: vector<u8>) {
    use sui::random;

    let mut gen = random::new_generator_from_seed_for_testing(seed);
    10u8.do!(|_| std::debug::print(&new_male_name(&mut gen)));

    let mut gen = random::new_generator_from_seed_for_testing(seed);
    10u8.do!(|_| std::debug::print(&new_female_name(&mut gen)));
}
