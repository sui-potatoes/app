// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander
module commander::commander;

use commander::{history::{Self, History}, map::{Self, Map}, recruit::Recruit};
use sui::{
    clock::Clock,
    object_table::{Self, ObjectTable},
    random::Random,
    transfer::Receiving,
    vec_map::{Self, VecMap}
};

const ENotAuthor: u64 = 0;

/// Stack limit of public games in the `Commander` object.
const PUBLIC_GAMES_LIMIT: u64 = 20;

/// The main object of the game, controls the game state, configuration and
/// serves as the registry for all users and their recruits.
public struct Commander has key {
    id: UID,
    /// List of the 10 most recent games.
    games: VecMap<ID, u64>,
}

/// A preset is a map that is required to start a new game.
public struct Preset has key {
    id: UID,
    /// The map that will be cloned and used for the new game.
    map: Map,
    /// Stores the spawn positions of recruits.
    positions: vector<vector<u8>>,
    /// The author of the preset.
    author: address,
    /// Popularity score.
    popularity: u64,
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

/// Start a new game with a custom map passed directly as a byte array.
public fun new_game(cmd: &mut Commander, preset: Receiving<Preset>, ctx: &mut TxContext): Game {
    let mut preset = transfer::receive(&mut cmd.id, preset);
    let map = preset.map.clone();

    preset.popularity = preset.popularity + 1; // increment popularity
    transfer::transfer(preset, cmd.id.to_address()); // transfer back

    Game {
        map,
        id: object::new(ctx),
        history: history::empty(),
        recruits: object_table::new(ctx),
    }
}

/// Register a new `Map` so it can be played.
public fun register_map(cmd: &mut Commander, bytes: vector<u8>, ctx: &mut TxContext) {
    let mut map = map::from_bytes(bytes);
    let id = object::new(ctx);

    map.set_id(id.to_inner());
    transfer::transfer(
        Preset { id, map, positions: vector[], author: ctx.sender(), popularity: 0 },
        cmd.id.to_address(),
    );
}

/// Delete a map from the `Commander` object. Can only be done by the author.
public fun delete_map(cmd: &mut Commander, preset: Receiving<Preset>, ctx: &mut TxContext) {
    let Preset { id, map, author, .. } = transfer::receive(&mut cmd.id, preset);
    assert!(author == ctx.sender(), ENotAuthor);
    map.destroy();
    id.delete();
}

/// Create a new public game, allowing anyone to spectate.
public fun register_game(cmd: &mut Commander, clock: &Clock, game: &Game, _ctx: &mut TxContext) {
    if (cmd.games.size() == PUBLIC_GAMES_LIMIT) {
        // remove the oldest game, given that the VecMap is following the insertion order
        let (_, _) = cmd.games.remove_entry_by_idx(0);
    };

    cmd.games.insert(game.id.to_inner(), clock.timestamp_ms());
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

/// On publish, share the `Commander` object with map presets. Demos have reserved IDs 0 and 1.
fun init(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let id_address = id.to_address();

    // positions:
    // [0, 3]
    // [6, 5]
    
    transfer::transfer(
        Preset {
            id: object::new(ctx),
            map: map::demo_1(@0.to_id()),
            positions: vector[],
            author: @0,
            popularity: 0,
        },
        id_address,
    );

    // positions:
    // [8, 2],
    // [7, 6],
    // [1, 2],
    // [1, 7],

    transfer::transfer(
        Preset {
            id: object::new(ctx),
            map: map::demo_2(@1.to_id()),
            positions: vector[],
            author: @0,
            popularity: 0,
        },
        id_address,
    );

    transfer::share_object(Commander { id, games: vec_map::empty() });
}
