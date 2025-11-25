// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::demo_test;

use commander::{history, items, map, recruit::{Self, Recruit}};
use std::unit_test::{assert_eq, destroy};
use sui::random;

#[test]
fun play_test_demo_1() {
    assert_eq!(run_simulation_demo_1(b"demo_o1"), vector[5, 1]);
    assert_eq!(run_simulation_demo_1(b"demo_o2"), vector[9, 2]);
    assert_eq!(run_simulation_demo_1(b"demo_o3"), vector[3, 1]);
    assert_eq!(run_simulation_demo_1(b"demo_o4"), vector[7, 1]);
    assert_eq!(run_simulation_demo_1(b"demo_o5"), vector[9, 2]);
    assert_eq!(run_simulation_demo_1(b"demo_o6"), vector[8, 1]);
}

#[test]
fun play_test_demo_2() {
    let map = map::demo_2(@1.to_id());
    let mut out = b"\n".to_string();
    out.append(map.to_string());
    map.destroy();
}

// Using the Demo map:
//      0     1     2     3     4     5     6
// 0 |     |     |2002-|0001-|0002-|     |     |
// 1 | XXX |     |     |     |     |     |     |
// 2 |     |     |     |     |     |0001-|0001-|
// 3 |0100-|0210-|     | XXX |     |1000-|1000-|
// 4 |0001-|0012-|     |     |     |     |     |
// 5 |     |     |     |     |     |     |     |
// 6 |     | XXX |     |     |1100-|0100-|0110-|
//
// Actions:
// - Move: (6, 5) -> (4, 1)
// - Attack: (4, 1) -> (0, 3)
// - Attack: (0, 3) -> (4, 1)
// - Repeat attack until one unit dies
fun run_simulation_demo_1(seed: vector<u8>): vector<u16> {
    use grid::direction::{up, left};

    let ctx = &mut tx_context::dummy();
    let id = ctx.fresh_object_address().to_id();
    let mut rng = random::new_generator_from_seed_for_testing(seed);
    let mut map = map::demo_1(id);
    let (r1, r3) = (recruit_one(ctx), recruit_two(ctx));

    // recruit placement over
    map.place_recruit(&r1, 6, 5);
    map.place_recruit(&r3, 0, 3);

    // Unit 1 performs a move action and takes cover in the construction on
    // the left side (high cover + low cover mix)
    map.move_unit(vector[6, 5, up!(), up!(), left!(), left!(), left!(), left!()]);

    map.unit(4, 1).do_ref!(|unit| {
        assert_eq!(unit.ap(), 1); // 1 AP used
        assert_eq!(unit.stats().dodge(), 0);
    });

    map.unit(0, 3).do_ref!(|unit| {
        assert_eq!(unit.hp(), 10); // full health
        assert_eq!(unit.stats().dodge(), 0);
    });

    map.next_turn();

    // prettier-ignore
    let result = 'crossfire: loop {
        map.unit(4, 1).do_ref!(|unit| if (unit.ammo() == 0) { map.perform_reload(4, 1); });
        let history = map.perform_attack(&mut rng, 4, 1, 0, 3);
        if (history::list_kia(&history).length() > 0) {
            break 'crossfire vector[map.turn(), 2]
        };

        // map.unit(0, 3).do_ref!(|unit| if (is_hit) assert!(unit.hp() < 10)); // some damage
        map.unit(4, 1).do_ref!(|unit| assert_eq!(unit.ap(), 0)); // no more AP

        // Unit 2 is in a good position already and chooses to perform an attack
        // Depending on the RNG seed, we want to check different outcomes
        map.unit(0, 3).do_ref!(|unit| if (unit.ammo() == 0) { map.perform_reload(0, 3); });
        let history = map.perform_attack(&mut rng, 0, 3, 4, 1);
        if (history::list_kia(&history).length() > 0) {
            break 'crossfire vector[map.turn(), 1]
        };

        // map.unit(4, 1).do_ref!(|unit| if (is_hit) assert!(unit.hp() < 10)); // some damage
        map.unit(0, 3).do_ref!(|unit| assert_eq!(unit.ap(), 0)); // depleted AP

        // Reset the Map turn
        map.next_turn();
    };

    // print the result (uncomment if results are needed)
    // {
    //     let mut res = b"seed: ".to_string();
    //     res.append(seed.to_string());
    //     res.append_utf8(b"; crossfire over at turn ");
    //     res.append(result[0].to_string());
    //     res.append_utf8(b"; Unit ");
    //     res.append(result[1].to_string());
    //     res.append_utf8(b" is dead");
    //     std::debug::print(&res);
    // };

    destroy(vector[r1, r3]);
    map.destroy();
    result
}

// placed on the map at (6, 5)
fun recruit_one(ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::new(b"Recruit 1".to_string(), b"".to_string(), ctx);

    recruit.add_armor(items::armor(2, ctx)); //  tier 2: medium armor
    recruit.add_weapon(items::rifle(3, ctx)); // tier 3: rifle
    recruit
}

// placed on the map at (2, 6)
fun recruit_two(ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::new(b"Recruit 2".to_string(), b"".to_string(), ctx);

    recruit.add_armor(items::armor(2, ctx)); //  tier 2: medium armor
    recruit.add_weapon(items::rifle(2, ctx)); // tier 2: rifle
    recruit
}
