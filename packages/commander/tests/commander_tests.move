// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::commander_tests;

use commander::{commander::{Preset, Host}, map, recruit, test_runner as test};
use std::unit_test::assert_eq;
use sui::bcs;

// === Working with Presets ===

/// Correct format of the BCS bytes for a preset.
public struct PresetPublish(vector<u8>, vector<vector<u8>>) has drop;

#[test]
fun preset_publish_delete() {
    let mut test = test::new(@0);
    test.init_registry();

    // Publish a default map to Commander.
    test.commander_tx!(|cmd| {
        let ctx = test.ctx();
        let map = map::default(@0.to_id());
        let preset = PresetPublish(bcs::to_bytes(&map), vector[vector[0, 0]]);

        cmd.publish_map(b"preset 1".to_string(), bcs::to_bytes(&preset), ctx);
        map.destroy();
    });

    // Delete the map.
    test.receiving_tx!<Preset>(|cmd, preset| cmd.delete_map(preset, test.ctx()));
    test.end();
}

#[test, expected_failure(abort_code = commander::commander::ENotAuthor)]
fun preset_delete_fail_not_author() {
    let mut test = test::new(@0);
    test.init_registry();

    // Try deleting the map as a different sender.
    test.set_sender(@1);
    test.receiving_tx!<Preset>(|cmd, preset| cmd.delete_map(preset, test.ctx()));

    abort
}

// === Single Player (Demo) ===

#[test]
fun play_registered_demo() {
    let mut test = test::new(@0);
    let clock = test.clock();

    test.init_registry();
    test.receiving_tx!<Preset>(|cmd, preset| {
        let ctx = test.ctx();
        let mut game = cmd.new_game(preset, &clock, ctx);
        cmd.register_game(&game, &clock, ctx);

        assert!(game.is_placing_recruits());

        // each preset has at least 2 positions
        game.place_recruits(vector[recruit::default(ctx), recruit::default(ctx)], ctx);

        assert!(game.is_playing());
        test.store_game(game);
    });

    test.game_tx!(|game, ctx| {
        game.next_turn(&clock, ctx);
        assert!(game.is_playing());
    });

    test.commander_tx!(|cmd| {
        let game = test.take_game();
        cmd.destroy_game(game, option::none(), test.ctx()).delete();
    });

    // ...

    clock.destroy_for_testing();
    test.end();
}

// === Host & Join ===

// Host and join a game.
#[test]
fun play_multiplayer_game() {
    let mut test = test::new(@0);
    let clock = test.clock();

    test.init_registry();
    test.receiving_tx!<Preset>(|cmd, preset| {
        let game = cmd.host_game(preset, &clock, test.ctx());

        assert!(game.is_waiting());
        test.store_game(game);
    });

    test.receiving_tx!<Host>(|cmd, host| {
        let mut game = test.take_game();
        let ctx = test.ctx();
        cmd.join_game(&mut game, host, &clock, ctx);
        assert!(game.is_placing_recruits());
        test.store_game(game);
    });

    clock.destroy_for_testing();
    test.end();
}

#[test]
fun play_multiplayer_game_with_time_limit() {
    let mut test = test::new(@0);
    let mut clock = test.clock();

    test.init_registry();

    // Host a game and place recruits.
    test.receiving_tx!<Preset>(|cmd, preset| {
        let game = cmd.host_game(preset, &clock, test.ctx());
        assert!(game.is_waiting());
        test.store_game(game);
    });

    // Join the game and place recruits, the game should be ready.
    test.set_sender(@1);
    test.receiving_tx!<Host>(|cmd, host| {
        let mut game = test.take_game();
        cmd.join_game(&mut game, host, &clock, test.ctx());
        assert!(game.is_placing_recruits());

        // After the second player joins, the game is ready. And we can place recruits.
        // Technically it is expected to be done in parallel.
        game.place_recruits(
            vector[recruit::default(test.ctx()), recruit::default(test.ctx())],
            test.ctx(),
        );

        test.return_game(game);
    });

    test.set_sender(@0);
    test.game_tx!(|game, ctx| {
        game.place_recruits(vector[recruit::default(ctx), recruit::default(ctx)], ctx);

        assert!(game.is_playing());
        assert_eq!(game.players(), vector[@0, @1]);
        assert_eq!(game.last_turn(), clock.timestamp_ms());

        clock.increment_for_testing(30_000); // 30 seconds
        game.next_turn(&clock, ctx);

        assert_eq!(game.last_turn(), clock.timestamp_ms());
    });

    test.end();
    clock.destroy_for_testing();
}

// Try to join a game with an invalid host.
#[test, expected_failure(abort_code = commander::commander::EInvalidGame)]
fun fail_join_invalid_game() {
    let mut test = test::new(@0);
    let clock = test.clock();
    let mut game;

    test.init_registry();

    // Host a game and store it.
    test.receiving_tx!<Preset>(|cmd, preset| {
        game = cmd.host_game(preset, &clock, test.ctx());
    });

    // Host another game with the same preset.
    test.receiving_tx!<Preset>(|cmd, preset| {
        cmd.host_game(preset, &clock, test.ctx()).share();
    });

    // Try to join the first game with the second host.
    test.receiving_tx!<Host>(|cmd, host| {
        let ctx = test.ctx();
        cmd.join_game(&mut game, host, &clock, ctx);
    });

    abort
}

// Try to destroy a hosted game without specifying a host.
#[test, expected_failure(abort_code = commander::commander::EHostNotSpecified)]
fun fail_destroy_hosted_game() {
    let mut test = test::new(@0);
    let clock = test.clock();
    let game;

    test.init_registry();

    // Host a game and store it.
    test.receiving_tx!<Preset>(|cmd, preset| {
        game = cmd.host_game(preset, &clock, test.ctx());
    });

    // Try to destroy the game without specifying a host.
    test.commander_tx!(|cmd| {
        cmd.destroy_game(game, option::none(), test.ctx()).delete();
    });

    abort
}
