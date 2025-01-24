// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander
module commander::commander;

use commander::{map::{Self, Map}, recruit::Recruit};
use grid::point::{Self, Point};
use sui::table::{Self, Table};

/// The main object of the game, controls the game state, configuration and
/// serves as the registry for all users and their recruits.
public struct Commander has key {
    id: UID,
}

/// A single instance of the game. A `Game` object is created when a new game is
/// started, it contains the Map and the
public struct Game has key {
    id: UID,
    map: Map,
    /// Temporarily stores recruits for the duration of the game.
    /// If recruits are KIA, they're "killed" upon removal from this table.
    recruits: Table<ID, Recruit>,
}

/// Start a new game.
public fun new(ctx: &mut TxContext): Game {
    Game {
        id: object::new(ctx),
        map: map::default(),
        recruits: table::new(ctx),
    }
}

/// Create a new demo game.
public fun demo(ctx: &mut TxContext): Game {
    Game {
        id: object::new(ctx),
        map: map::demo_1(),
        recruits: table::new(ctx),
    }
}

/// Place a Recruit on the map, store it in the `Game`.
public fun place_recruit(game: &mut Game, recruit: Recruit, x: u16, y: u16, ctx: &mut TxContext) {
    assert!(recruit.leader() == ctx.sender()); // make sure the sender owns the recruit

    game.map.place_recruit(&recruit, x, y);
    game.recruits.add(object::id(&recruit), recruit);
}

/// Move a unit along the path, the first point is the current position of the unit.
public fun move_unit(game: &mut Game, path: vector<vector<u16>>, _ctx: &mut TxContext) {
    game.map.move_unit(path);
}

/// Share the `key`-only object after placing Recruits on the map.
public fun share(game: Game) {
    transfer::share_object(game)
}
