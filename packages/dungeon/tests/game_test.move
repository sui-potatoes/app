// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module dungeon::game_test;

use std::debug::print;
use sui::{
    test_scenario as ts,
    random,    
};
use dungeon::{
    game::{Self, Game, Registry},
    game_master::{Self, GameMaster},
};

const OWNER: address = @0xBABE;

#[test]
fun play_until_level_2_no_mine() {
    // create mock and init modules
    let mut gen = random::new_generator_for_testing();
    let mut scenario = ts::begin(OWNER);
    game::init_for_testing(scenario.ctx());
    game_master::init_for_testing(scenario.ctx());

    // param and create game
    scenario.next_tx(OWNER);
    let mut registry = scenario.take_shared<Registry>();
    let game_master = scenario.take_from_sender<GameMaster>();
    registry.set_difficulty_scalar(&game_master, 0);
    game::new(&mut registry, 3, scenario.ctx());

    // move until win first level 
    scenario.next_tx(OWNER);
    let mut game = scenario.take_from_sender<Game>();
    game.make_move(&mut gen, 0, scenario.ctx());
    game.make_move(&mut gen, 0, scenario.ctx());
    game.make_move(&mut gen, 0, scenario.ctx());
    assert!(game.level() == 2);

    ts::return_shared(registry);
    scenario.return_to_sender(game_master);
    scenario.return_to_sender(game);
    scenario.end();
}

#[test]
fun play_until_mine() {
    // create mock and init modules
    let mut gen = random::new_generator_for_testing();
    let mut scenario = ts::begin(OWNER);
    game::init_for_testing(scenario.ctx());
    game_master::init_for_testing(scenario.ctx());

    // param and create game
    scenario.next_tx(OWNER);
    let mut registry = scenario.take_shared<Registry>();
    game::new(&mut registry, 3, scenario.ctx());

    // move until win first level 
    scenario.next_tx(OWNER);
    let mut game = scenario.take_from_sender<Game>();
    while (game.level() != 0) {
        game.make_move(&mut gen, 0, scenario.ctx());
    };
    assert!(game.level() == 0);

    ts::return_shared(registry);
    scenario.return_to_sender(game);
    scenario.end();
}