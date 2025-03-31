// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module 0::hero;

use name_gen::name_gen;
use std::string::String;
use sui::random::Random;

/// The `Hero` who has a name.
public struct Hero has key, store { id: UID, name: String }

// The function MUST be an `entry` function for `Random` to work.
entry fun new(rng: &Random, ctx: &mut TxContext) {
    let mut gen = rng.new_generator(ctx); // acquire generator instance
    let name = name_gen::new_male_name(&mut gen); // also `new_female_name`
    transfer::transfer(
        Hero {
            id: object::new(ctx),
            name,
        },
        ctx.sender(),
    );
}

/// Get the name of the hero.
public fun name(h: &Hero): String { h.name }
