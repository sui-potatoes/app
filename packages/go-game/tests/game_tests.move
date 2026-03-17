// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module go_game::game_tests;

use go_game::game::{Self, Game};
use sui::{clock, test_scenario};

#[test]
fun play_solo_game() {
    let mut test = test_scenario::begin(@1);
    let clock = clock::create_for_testing(test.ctx());

    // 1st tx: create a new account and a new game
    let mut account = game::new_account(test.ctx());
    game::new(&mut account, 9, &clock, test.ctx());

    // 2nd tx: join the game
    test.next_tx(@1);
    test.with_shared!<Game>(|game, test| {
        game.make_public(&account, test.ctx());
        game.join(&mut account, &clock, test.ctx());
        game.play(&account, 3, 3, &clock, test.ctx());
        game.play(&account, 4, 4, &clock, test.ctx());
        game.play(&account, 5, 5, &clock, test.ctx());
    });

    // 3rd tx: wrap up the game as a solo player
    test.next_tx(@1);
    let game = test.take_shared<Game>();
    game.wrap_up(&mut account, test.ctx());

    clock.destroy_for_testing();
    account.delete(test.ctx());
    test.end();
}
