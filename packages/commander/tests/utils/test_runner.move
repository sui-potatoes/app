// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::test_runner;

use commander::commander::{Self, Commander};
use sui::{clock::{Self, Clock}, test_scenario::{Self as test, Scenario}, transfer::Receiving};

public struct TestRunner { scenario: Scenario, sender: address }

public fun new(sender: address): TestRunner {
    TestRunner {
        sender,
        scenario: test::begin(sender),
    }
}

public fun init_registry(test: &mut TestRunner) {
    commander::init_for_testing(test.scenario.ctx());
    test.scenario.next_tx(test.sender);
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

public fun clock(test: &mut TestRunner): Clock { clock::create_for_testing(test.ctx()) }

public fun ctx(test: &mut TestRunner): &mut TxContext { test.scenario_mut().ctx() }

public fun sender(test: &TestRunner): address { test.sender }

public fun set_sender(test: &mut TestRunner, sender: address) {
    test.sender = sender;
}

public fun scenario(test: &TestRunner): &Scenario { &test.scenario }

public fun scenario_mut(test: &mut TestRunner): &mut Scenario { &mut test.scenario }

public fun end(test: TestRunner) {
    let TestRunner { scenario, .. } = test;
    scenario.end();
}
