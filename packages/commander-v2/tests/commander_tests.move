// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::commander_tests;

use commander::{commander::{Preset, Host}, map, recruit, test_runner as test};
use sui::bcs;

// === Working with Presets ===

/// Correct format of the BCS bytes for a preset.
public struct PresetPublish(vector<u8>, vector<vector<u8>>) has drop;

#[test]
fun preset_publish_delete() {
    let mut test = test::new(@0);
    test.init_registry();

    // publish a default map to Commander
    test.commander_tx!(|cmd| {
        let ctx = test.ctx();
        let map = map::default(@0.to_id());
        let preset = PresetPublish(bcs::to_bytes(&map), vector[vector[0, 0]]);

        cmd.publish_map(b"preset 1".to_string(), bcs::to_bytes(&preset), ctx);
        map.destroy();
    });

    // delete the map
    test.receiving_tx!<Preset>(|cmd, preset| cmd.delete_map(preset, test.ctx()));
    test.end();
}

#[test, expected_failure(abort_code = commander::commander::ENotAuthor)]
fun preset_delete_fail_not_author() {
    let mut test = test::new(@0);
    test.init_registry();

    // try deleting the map as a different sender
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
        let mut game = cmd.new_game(preset, ctx);
        cmd.register_game(&clock, &game, ctx);

        // each preset has at least 2 positions
        game.place_recruit(recruit::default(ctx), ctx);
        game.place_recruit(recruit::default(ctx), ctx);

        // now we can delete it
        cmd.destroy_game(game, true, ctx); // save the replay
    });

    // ...

    clock.destroy_for_testing();
    test.end();
}

// === Host & Join ===

#[test, expected_failure]
fun play_multiplayer_game() {
    let mut test = test::new(@0);
    let clock = test.clock();
    let mut game;

    test.init_registry();
    test.receiving_tx!<Preset>(|cmd, preset| {
        game = cmd.host_game(&clock, preset, test.ctx());
    });

    test.receiving_tx!<Host>(|cmd, host| {
        let ctx = test.ctx();
        cmd.join_game(&mut game, host, ctx);
        game.place_recruit(recruit::default(ctx), ctx);
        game.place_recruit(recruit::default(ctx), ctx);
    });

    clock.destroy_for_testing();
    test.end();
}

// #[test]
// fun play_multiplayer_game() {
//     let mut test = test::new(@0);
//     let clock = sui::clock::create_for_testing(test.ctx());

//     test.init_registry();
//     test.receiving_tx!<Preset>(|cmd, preset, ctx| {
//         cmd.host_game(&clock, preset, ctx).share();
//     });
//
//     // test.receiving_tx!<Host>(|cmd, host, ctx| {
//     clock.destroy_for_testing();
//     test.end();
// }
