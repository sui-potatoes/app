// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The frontend module for the Commander game. Defines the `Commander` object,
/// which is used to store recent games, their metadata and the map presets.
///
/// Additionally, handles the interaction between players, such as hosting a
/// game, joining it, canceling a game, etc.
module commander::commander;

use commander::{history::{Self, History}, map::{Self, Map}, recruit::Recruit, replay};
use std::string::String;
use sui::{
    bcs,
    clock::Clock,
    object_table::{Self, ObjectTable},
    random::Random,
    transfer::Receiving,
    vec_map::{Self, VecMap}
};

const ENotAuthor: u64 = 0;
const ENotPlayer: u64 = 1;
const EInvalidGame: u64 = 2;
const ENotYourRecruit: u64 = 3;
const ENoPositions: u64 = 4;

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
    /// The name of the preset, purely for display purposes.
    name: String,
    /// Stores the spawn positions of recruits.
    positions: vector<vector<u8>>,
    /// The author of the preset.
    author: address,
    /// Popularity score.
    popularity: u64,
}

/// Host is an object created to mark a hosted game. An account joining a hosted
/// game will consume this object and create a new `Game` with it.
public struct Host has key {
    id: UID,
    game_id: ID,
    name: String,
    timestamp_ms: u64,
    host: address,
}

/// A single instance of the game. A `Game` object is created when a new game is
/// started, it contains the Map and the
public struct Game has key {
    id: UID,
    map: Map,
    /// The players in the game.
    players: vector<address>,
    /// The spawn positions of recruits.
    positions: vector<vector<u8>>,
    /// History of the game.
    history: History,
    /// Temporarily stores recruits for the duration of the game.
    /// If recruits are KIA, they're "killed" upon removal from this table.
    recruits: ObjectTable<ID, Recruit>,
}

// === Map Registration & Removal ===

/// Register a new `Map` so it can be played.
public fun publish_map(cmd: &mut Commander, name: String, bytes: vector<u8>, ctx: &mut TxContext) {
    let mut bcs = bcs::new(bytes);
    let mut map = map::from_bcs(&mut bcs);
    let positions = bcs.peel_vec!(|bcs| bcs.peel_vec!(|bcs| bcs.peel_u8()));
    let id = object::new(ctx);

    map.set_id(id.to_inner());
    transfer::transfer(
        Preset { id, name, map, positions, author: ctx.sender(), popularity: 0 },
        cmd.id.to_address(),
    );
}

/// Delete a map from the `Commander` object. Can only be done by the author.
/// Once a `Preset` is deleted, it makes `Replay`s of the game using that map invalid.
public fun delete_map(cmd: &mut Commander, preset: Receiving<Preset>, ctx: &mut TxContext) {
    let Preset { id, map, author, .. } = transfer::receive(&mut cmd.id, preset);
    assert!(author == ctx.sender(), ENotAuthor);
    map.destroy();
    id.delete();
}

// === Multiplayer Features: Host and Join ===

/// Host a new game.
public fun host_game(
    cmd: &mut Commander,
    clock: &Clock,
    preset: Receiving<Preset>,
    ctx: &mut TxContext,
): Game {
    let mut preset = transfer::receive(&mut cmd.id, preset);
    preset.popularity = preset.popularity + 1; // increment popularity

    let name = preset.name;
    let map = preset.map.clone();
    let positions = preset.positions;
    let cmd_address = cmd.id.to_address();
    let timestamp_ms = clock.timestamp_ms();
    let id = object::new(ctx);

    transfer::transfer(preset, cmd_address);
    transfer::transfer(
        Host {
            id: object::new(ctx),
            game_id: id.to_inner(),
            name,
            timestamp_ms,
            host: ctx.sender(),
        },
        cmd_address,
    );

    Game {
        id,
        map,
        positions,
        history: history::empty(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
    }
}

/// Join a hosted game.
public fun join_game(
    cmd: &mut Commander,
    game: &mut Game,
    host: Receiving<Host>,
    ctx: &mut TxContext,
) {
    let Host { id, game_id, .. } = transfer::receive(&mut cmd.id, host);
    assert!(game_id == game.id.to_inner(), EInvalidGame);

    game.players.push_back(ctx.sender());
    id.delete();
}

// === New Game Registration & Removal ===

/// Start a new game with a custom map passed directly as a byte array.
public fun new_game(cmd: &mut Commander, preset: Receiving<Preset>, ctx: &mut TxContext): Game {
    let mut preset = transfer::receive(&mut cmd.id, preset);
    let map = preset.map.clone();
    let positions = preset.positions;

    preset.popularity = preset.popularity + 1; // increment popularity
    transfer::transfer(preset, cmd.id.to_address()); // transfer back

    Game {
        map,
        id: object::new(ctx),
        history: history::empty(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
        positions,
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

#[allow(lint(self_transfer))]
/// Destroy a game object, remove it from the registry's most recent if present.
public fun destroy_game(cmd: &mut Commander, game: Game, save_replay: bool, ctx: &mut TxContext) {
    let Game { id, map, mut recruits, history, players, .. } = game;
    let preset_id = map.id();
    map.destroy().do!(|unit| transfer::public_transfer(recruits.remove(unit), ctx.sender()));

    // only the players can destroy the game, no garbage collection
    assert!(players.any!(|player| player == ctx.sender()), ENotPlayer);

    if (cmd.games.contains(id.as_inner())) { cmd.games.remove(id.as_inner()); };
    recruits.destroy_empty();

    // save the replay if the flag is set
    if (save_replay) {
        transfer::public_transfer(replay::new(preset_id, history, ctx), ctx.sender());
    };

    id.delete();
}

// === Game Actions ===

/// Place a Recruit on the map, store it in the `Game`.
public fun place_recruit(game: &mut Game, recruit: Recruit, ctx: &mut TxContext) {
    assert!(recruit.leader() == ctx.sender(), ENotYourRecruit); // make sure the sender owns the recruit
    assert!(game.positions.length() > 0, ENoPositions);

    let position = game.positions.pop_back();
    let history = game.map.place_recruit(&recruit, position[0] as u16, position[1] as u16);
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
fun turn(self: &Game): u16 { self.map.turn() }

// === Init ===

/// On publish, share the `Commander` object with map presets. Demos have reserved IDs 0 and 1.
fun init(ctx: &mut TxContext) {
    let id = object::new(ctx);
    let id_address = id.to_address();

    // prettier-ignore
    transfer::transfer({
        let id = object::new(ctx);
        Preset {
            map: map::demo_1(id.to_inner()),
            name: b"Demo 1".to_string(),
            positions: vector[vector[0, 3], vector[6, 5]],
            popularity: 0,
            author: @0,
            id,
        }
    }, id_address);

    // prettier-ignore
    transfer::transfer({
        let id = object::new(ctx);
        Preset {
            map: map::demo_2(id.to_inner()),
            name: b"Demo 2".to_string(),
            positions: vector[vector[8, 2], vector[7, 6], vector[1, 2], vector[1, 7]],
            author: @0,
            popularity: 0,
            id,
        }
    }, id_address);

    transfer::share_object(Commander { id, games: vec_map::empty() });
}

#[test]
fun test_deserialize_map() {
    let bytes =
        x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a0000000000000000000000000000000000000000000001020801";
    let mut bcs = bcs::new(bytes);
    let map = map::from_bcs(&mut bcs);
    let _positions = bcs.peel_vec!(|bcs| bcs.peel_vec!(|bcs| bcs.peel_u8()));

    assert!(map.id() == @0.to_id());
    assert!(map.turn() == 0);
    // assert!(positions.length() > 0);

    map.destroy();
}
