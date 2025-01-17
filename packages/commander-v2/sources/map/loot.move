// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Lootbox module is responsible for handling the lootboxes on the map. Each
/// box can contain up to 2 items, which can be weapons, armor, items - all of
/// which apply modifiers to the base stats.
///
/// Loot rarity can be (with chance of appearing):
/// - Common (55%)
/// - Uncommon (30%)
/// - Rare (12%)
/// - Epic (3%)
module commander::loot;

use sui::random::RandomGenerator;

#[allow(lint(public_random))]
public fun open_lootbox(gen: &mut RandomGenerator) {
    let num_items = (gen.generate_u8() % 3) as u64;

    vector::tabulate!(num_items, |_| {
        let rarity = gen.generate_u8() % 100;
        let score = match (rarity) {
            c if (*c > 96) => b"Epic",
            c if (*c > 84) => b"Rare",
            c if (*c > 54) => b"Uncommon",
            _ => b"Common",
        };

        score
    });
}
