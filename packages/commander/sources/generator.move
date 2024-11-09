/* ERROR: */
/* ERROR: */
/* ERROR: */
// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Recruit new rookies to the crew. Currently available without any
/// restrictions, but in the future, to aquire a new rookie one would need a
/// ticket, a special item or a certain event will be happening.
module commander::recruiting;

use std::string::String;
use sui::random::Random;

/// Rank of the recruit.
public enum Rank has store, drop {
    Rookie,
    Squaddie,
    Corporal,
    Sergeant,
    Lieutenant,
    Captain,
    Major,
    Colonel,
}

/// A struct that represents a rookie.
public struct Recruit has key {
    id: UID,
    /// The rank of the recruit.
    rank: Rank,
    /// Aim in percentage.
    aim: u16,
    /// Hacking in percentage.
    hacking: u16,
    /// Mobility in tiles.
    mobility: u16,
    /// Name of the rookie.
    name: String,
    /// Backstory which is opened up as rookie gets promoted.
    backstory: vector<String>,
}

/// A struct that represents the recruiting center for rookies.
public struct Recruiting has key, store {
    id: UID,
    /// The total number of recruits that have been recruited to any crew.
    /// Used to show stats.
    total_recruits: u32,
    /// The base aim of the rookie, chance of hitting the target.
    base_aim: u16,
    /// The base hacking of the rookie, chance of hacking the target.
    base_hacking: u16,
    /// The base mobility of the rookie, in tiles.
    base_mobility: u16,
    /// The maximum bonus that can be added to the base aim. Based on the rng.
    max_bonus_aim: u16,
    /// The maximum bonus that can be added to the base mobility. Based on the rng.
    max_bonus_hacking: u16,
    /// The maximum bonus that can be added to the base mobility. Based on the rng.
    max_bonus_mobility: u16,
}

fun init(ctx: &mut TxContext) {
    transfer::share_object(Recruiting {
        id: object::new(ctx),
        total_recruits: 0,
        base_aim: 50,
        base_hacking: 30,
        base_mobility: 8,
        max_bonus_aim: 10,
        max_bonus_hacking: 10,
        max_bonus_mobility: 4,
    })
}

/// Generate new `Recruit` with random stat modifiers and transfer it to the
/// sender.
entry fun recruit(
    recruiting: &mut Recruiting,
    rng: &Random,
    _num: u8,
    ctx: &mut TxContext,
) {
    let mut generator = rng.new_generator(ctx);

    // aim has base value of 50, in the damage formula we rely SOLELY on aim
    // additional buff can
    let aim_bonus = generator.generate_u16_in_range(0, recruiting.max_bonus_aim);
    let hacking_bonus = generator.generate_u16_in_range(0, recruiting.max_bonus_hacking);
    let mobility_bonus = generator.generate_u16_in_range(0, recruiting.max_bonus_mobility);

    // increment the total recruits (though completely optional and may actually
    // be removed to increase processing speeds on immutable reads)
    recruiting.total_recruits = recruiting.total_recruits + 1;

    transfer::transfer(
        Recruit {
            id: object::new(ctx),
            rank: Rank::Rookie,
            aim: recruiting.base_aim + aim_bonus,
            hacking: recruiting.base_hacking + hacking_bonus,
            mobility: recruiting.base_mobility + mobility_bonus,
            name: b"Rookie".to_string(),
            backstory: vector[],
        },
        ctx.sender(),
    );
}

#[test]
fun test_default_flow() {
    use sui::test_scenario as test;
    use sui::random;

    let user = @0x0;
    let mut test = test::begin(user);

    // do the initial setup for publishing
    init(test.ctx());
    random::create_for_testing(test.ctx());

    // next tx, recruit a rookie
    test.next_tx(user);
    let mut recruiting = test.take_shared<Recruiting>();
    let random = test.take_shared<Random>();

    recruit(&mut recruiting, &random, 0, test.ctx());
    test::return_shared(recruiting);
    test::return_shared(random);

    // next tx, check that the recruit is in the system
    test.next_tx(user);
    let recruit = test.take_from_sender<Recruit>();
    std::debug::print(&recruit);
    test.return_to_sender(recruit);

    test.end();
}
