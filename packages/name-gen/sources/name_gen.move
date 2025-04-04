// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Cyberpunk Name Generator - a "stateless" solution for generating names,
/// based on the `random` module.
///
/// ## Usage
/// This package provides utility functions which must be integrated directly
/// into an application's Move codebase, due to the use of `RandomGenerator`.
///
/// ## Example
/// ```
/// module my_package::hero;
///
/// use std::string::String;
/// use sui::random::Random;
/// use name_gen::name_gen;
///
/// /// Some object to hold the name.
/// public struct Hero has key, store { id: UID, name: String }
///
/// /// The function MUST be an `entry` function for `Random` to work.
/// /// See https://docs.sui.io/guides/developer/advanced/randomness-onchain
/// entry fun new_hero(rng: &Random, ctx: &mut TxContext) {
///     let mut gen = rng.new_generator(ctx); // acquire generator instance
///     let name = name_gen::new_male_name(&mut gen); // also `new_female_name`
///     transfer::transfer(Hero {
///         id: object::new(ctx),
///         name
///     }, ctx.sender());
/// }
/// ```
module name_gen::name_gen;

use std::string::String;
use sui::random::RandomGenerator;

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
    } else {
        name_gen::last_name::select(g.generate_u16_in_range(0, LAST_NAME_LIMIT))
    };

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
    } else {
        name_gen::last_name::select(g.generate_u16_in_range(0, LAST_NAME_LIMIT))
    };

    res.append(name);
    res.append_utf8(b" ");
    res.append(last_name);
    res
}

#[test]
fun generate_male_name() {
    use sui::random;
    let mut gen = random::new_generator_for_testing();
    new_male_name(&mut gen);
}

#[test]
fun generate_female_name() {
    use sui::random;
    let mut gen = random::new_generator_for_testing();
    new_female_name(&mut gen);
}

#[random_test]
fun test_generator(seed: vector<u8>) {
    use sui::random;

    let mut gen = random::new_generator_from_seed_for_testing(seed);
    100u16.do!(|_| new_male_name(&mut gen));

    let mut gen = random::new_generator_from_seed_for_testing(seed);
    100u16.do!(|_| new_female_name(&mut gen));
}
