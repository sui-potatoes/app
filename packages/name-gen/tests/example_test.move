// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module name_gen::hero_tests;

use name_gen::hero::{Self, Hero};
use sui::{random::{Self, Random}, test_scenario};
use std::unit_test::destroy;

#[test]
fun test_new_hero() {
    let mut test = test_scenario::begin(@0);
    random::create_for_testing(test.ctx());
    test.next_tx(@0);

    // pull the Random (0x6) object from the test scenario
    let rng = test_scenario::take_shared<Random>(&test);

    // create a new hero
    hero::new(&rng, test.ctx());
    test.next_tx(@0);

    // make sure a new object was sent to the sender
    let hero = test_scenario::take_from_address<Hero>(&test, @0);
    assert!(hero.name().length() > 0);
    destroy(hero);

    test_scenario::return_shared(rng);
    test.end();
}
