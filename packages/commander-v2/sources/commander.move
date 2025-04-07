// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander
module commander::commander;

use commander::{history::{Self, History}, map::{Self, Map}, recruit::Recruit};
use sui::{clock::Clock, object_table::{Self, ObjectTable}, random::Random, vec_map::{Self, VecMap}};

/// Stack limit of public games in the `Commander` object.
const PUBLIC_GAMES_LIMIT: u64 = 20;

/// The main object of the game, controls the game state, configuration and
/// serves as the registry for all users and their recruits.
public struct Commander has key {
    id: UID,
    /// List of the 10 most recent games.
    games: VecMap<ID, u64>,
}

/// A single instance of the game. A `Game` object is created when a new game is
/// started, it contains the Map and the
public struct Game has key {
    id: UID,
    map: Map,
    history: History,
    /// Temporarily stores recruits for the duration of the game.
    /// If recruits are KIA, they're "killed" upon removal from this table.
    recruits: ObjectTable<ID, Recruit>,
}

/// Start a new game.
public fun new(ctx: &mut TxContext): Game {
    let id = object::new(ctx);
    Game {
        map: map::default(id.to_inner()),
        history: history::empty(),
        recruits: object_table::new(ctx),
        id,
    }
}

/// Create a new public game, allowing anyone to spectate.
public fun register_game(cmd: &mut Commander, clock: &Clock, game: &Game, _ctx: &mut TxContext) {
    if (cmd.games.size() == PUBLIC_GAMES_LIMIT) {
        // remove the oldest game, given that the VecMap is following the insertion order
        let (_, _) = cmd.games.remove_entry_by_idx(0);
    };

    cmd.games.insert(game.id.to_inner(), clock.timestamp_ms());
}

/// Start a new game with a custom map passed directly as a byte array.
public fun new_with_map(map: vector<u8>, ctx: &mut TxContext): Game {
    let id = object::new(ctx);
    Game {
        map: map::from_bytes(map),
        history: history::empty(),
        recruits: object_table::new(ctx),
        id,
    }
}

/// Create a new demo game.
public fun demo_1(ctx: &mut TxContext): Game {
    let id = object::new(ctx);
    Game {
        map: map::demo_1(id.to_inner()),
        history: history::empty(),
        recruits: object_table::new(ctx),
        id,
    }
}

/// Create a new demo game.
public fun demo_2(ctx: &mut TxContext): Game {
    let id = object::new(ctx);
    Game {
        map: map::demo_2(id.to_inner()),
        history: history::empty(),
        recruits: object_table::new(ctx),
        id,
    }
}

/// Place a Recruit on the map, store it in the `Game`.
public fun place_recruit(game: &mut Game, recruit: Recruit, x: u16, y: u16, ctx: &mut TxContext) {
    assert!(recruit.leader() == ctx.sender()); // make sure the sender owns the recruit

    let history = game.map.place_recruit(&recruit, x, y);
    game.recruits.add(object::id(&recruit), recruit);
    game.history.add(history);
}

/// Move a unit along the path, the first point is the current position of the unit.
public fun move_unit(game: &mut Game, path: vector<u8>, _ctx: &mut TxContext) {
    game.history.add(game.map.move_unit(path))
}

/// Perform a reload action, replenishing ammo.
public fun perform_reload(game: &mut Game, x: u16, y: u16, _ctx: &mut TxContext) {
    game.history.add(game.map.perform_reload(x, y))
}

/// Perform a grenade throw action.
entry fun perform_grenade(
    game: &mut Game,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &mut TxContext,
) {
    let mut rng = rng.new_generator(ctx);
    let history = game.map.perform_grenade(&mut rng, x0, y0, x1, y1);

    history::list_kia(&history).do!(|id| {
        let recruit = game.recruits.remove(id);
        let leader = recruit.leader();
        transfer::public_transfer(recruit.kill(ctx), leader);
    });

    game.history.append(history)
}

/// Perform an attack action.
entry fun perform_attack(
    game: &mut Game,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &mut TxContext,
) {
    let mut rng = rng.new_generator(ctx);
    let history = game.map.perform_attack(&mut rng, x0, y0, x1, y1);

    history::list_kia(&history).do!(|id| {
        if (id.to_address() == @0) return; // skip empty addresses
        let recruit = game.recruits.remove(id);
        let leader = recruit.leader();
        transfer::public_transfer(recruit.kill(ctx), leader);
    });

    game.history.append(history)
}

/// Switch to the next turn.
public fun next_turn(game: &mut Game) {
    game.history.add(game.map.next_turn());
}

/// Share the `key`-only object after placing Recruits on the map.
public fun share(game: Game) {
    transfer::share_object(game)
}

// === Getters ===

#[allow(unused_function)]
/// Get the current turn of the game.
fun turn(self: &Game): u16 {
    self.map.turn()
}

// === Init ===

/// On publish, share the `Commander` object.
fun init(ctx: &mut TxContext) {
    transfer::share_object(Commander {
        id: object::new(ctx),
        games: vec_map::empty(),
    });
}
