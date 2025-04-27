// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::test_runner;

use commander::commander::{Self, Commander, Game};
use sui::{clock::{Self, Clock}, test_scenario::{Self as test, Scenario}, transfer::Receiving};
use sui::test_utils::destroy;

public struct TestRunner { scenario: Scenario, sender: address, game: Option<Game> }

public fun new(sender: address): TestRunner {
    TestRunner {
        sender,
        scenario: test::begin(sender),
        game: option::none(),
    }
}

public fun init_registry(test: &mut TestRunner) {
    commander::init_for_testing(test.scenario.ctx());
    test.scenario.next_tx(test.sender);
}

public use fun store_game as TestRunner.return_game;

public fun store_game(test: &mut TestRunner, game: Game) {
    test.game.fill(game);
}

public fun game(test: &TestRunner): &Game {
    test.game.borrow()
}

public fun game_mut(test: &mut TestRunner): &mut Game {
    test.game.borrow_mut()
}

public fun take_game(test: &mut TestRunner): Game {
    test.game.extract()
}

public macro fun commander_tx($test: &mut TestRunner, $f: |&mut Commander|) {
    let test = $test;
    let sender = test.sender();
    test.scenario_mut().next_tx(sender);
    let mut commander = test::take_shared<Commander>(test.scenario());
    $f(&mut commander);
    test::return_shared(commander);
}

public macro fun receiving_tx<$T: key>(
    $test: &mut TestRunner,
    $f: |&mut Commander, Receiving<$T>|,
) {
    let test = $test;
    let sender = test.sender();
    test.scenario_mut().next_tx(sender);
    let mut commander = test::take_shared<Commander>(test.scenario());
    let commander_id = object::id(&commander);
    let receiving = test::most_recent_receiving_ticket<$T>(&commander_id);
    $f(&mut commander, receiving);
    test::return_shared(commander);
}

public macro fun game_tx($test: &mut TestRunner, $f: |&mut Game, &mut TxContext|) {
    let test = $test;
    let sender = test.sender();
    test.scenario_mut().next_tx(sender);
    let mut game = test.take_game();
    $f(&mut game, test.ctx());
    test.return_game(game);
}

public fun clock(test: &mut TestRunner): Clock { clock::create_for_testing(test.ctx()) }

public fun ctx(test: &mut TestRunner): &mut TxContext { test.scenario_mut().ctx() }

public fun sender(test: &TestRunner): address { test.sender }

public fun set_sender(test: &mut TestRunner, sender: address) {
    test.sender = sender;
}

public fun scenario(test: &TestRunner): &Scenario { &test.scenario }

public fun scenario_mut(test: &mut TestRunner): &mut Scenario { &mut test.scenario }

public fun end(test: TestRunner) {
    let TestRunner { scenario, game, .. } = test;
    scenario.end();
    destroy(game);
}
