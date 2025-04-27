// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The frontend module for the Commander game. Defines the `Commander` object,
/// which is used to store recent games, their metadata and the map presets.
///
/// Additionally, handles the interaction between players, such as hosting a
/// game, joining it, canceling a game, etc.
///
///
/// Game State:
///
/// - Waiting to Join(host_id)
/// - Placing Recruits(positions)
/// - Playing(last_turn)
/// - Finished(winner)
module commander::commander;

use commander::{
    history::{Self, History},
    map::{Self, Map},
    recruit::Recruit,
    replay::{Self, Replay}
};
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
const EIncorrectHost: u64 = 4;
const EHostNotSpecified: u64 = 5;
const ECannotPlay: u64 = 6;
const ENotReady: u64 = 7;
const EInvalidState: u64 = 8;
const EMustPlaceRecruits: u64 = 9;
const EAlreadyPlacedRecruits: u64 = 10;

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

/// The state of the game, used to determine the game state.
public enum GameState has drop, store {
    /// The game is waiting to be joined. Stores the ID of the Host object.
    Waiting(ID),
    /// Players are expected to place their recruits.
    /// Makes sure that each player has placed their recruits only once.
    PlacingRecruits(vector<address>),
    /// The game is in progress. Stores the timestamp of the last turn.
    Playing(u64),
    /// The game is over. Stores the winner.
    Finished(address),
}

/// A single instance of the game. A `Game` object is created when a new game is
/// started, it contains the Map and the
public struct Game has key {
    id: UID,
    map: Map,
    state: GameState,
    /// The time limit (in ms) for a single turn.
    time_limit: u64,
    /// The timestamp of the last turn.
    last_turn: u64,
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
    preset: Receiving<Preset>,
    clock: &Clock,
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
    let host_uid = object::new(ctx);
    let host_id = host_uid.to_inner();

    transfer::transfer(preset, cmd_address);
    transfer::transfer(
        Host {
            id: host_uid,
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
        state: GameState::Waiting(host_id),
        time_limit: 100_000, // 100 seconds.
        last_turn: timestamp_ms,
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
    clock: &Clock,
    ctx: &mut TxContext,
) {
    let host_id = game.state.to_host_id!();

    let Host { id, game_id, .. } = transfer::receive(&mut cmd.id, host);
    assert!(game_id == game.id.to_inner(), EInvalidGame);
    assert!(host_id == id.to_inner(), EIncorrectHost);

    game.last_turn = clock.timestamp_ms();
    game.players.push_back(ctx.sender());
    game.state = GameState::PlacingRecruits(game.players); // 2 players.
    id.delete();
}

// === New Game Registration & Removal ===

/// Start a new game with a custom map passed directly as a byte array.
public fun new_game(
    cmd: &mut Commander,
    preset: Receiving<Preset>,
    clock: &Clock,
    ctx: &mut TxContext,
): Game {
    let mut preset = transfer::receive(&mut cmd.id, preset);
    let map = preset.map.clone();
    let positions = preset.positions;

    preset.popularity = preset.popularity + 1; // Increment popularity.
    transfer::transfer(preset, cmd.id.to_address()); // Transfer back to Commander.

    Game {
        map,
        positions,
        state: GameState::PlacingRecruits(vector[ctx.sender()]),
        time_limit: 100_000, // 100 seconds.
        last_turn: clock.timestamp_ms(),
        id: object::new(ctx),
        history: history::empty(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
    }
}

/// Create a new public game, allowing anyone to spectate.
public fun register_game(cmd: &mut Commander, game: &Game, clock: &Clock, _ctx: &mut TxContext) {
    if (cmd.games.size() == PUBLIC_GAMES_LIMIT) {
        // Remove the oldest game, given that the VecMap is following the insertion order.
        let (_, _) = cmd.games.remove_entry_by_idx(0);
    };

    cmd.games.insert(game.id.to_inner(), clock.timestamp_ms());
}

#[allow(lint(self_transfer))]
/// Destroy a game object, remove it from the registry's most recent if present.
public fun destroy_game(
    cmd: &mut Commander,
    game: Game,
    host: Option<Receiving<Host>>,
    ctx: &mut TxContext,
): Replay {
    let Game { id, map, mut recruits, history, players, state, .. } = game;
    let preset_id = map.id();
    map.destroy().do!(|unit| {
        let recruit = recruits.remove(unit);
        let leader = recruit.leader();
        transfer::public_transfer(recruit, leader)
    });

    assert!(!state.is_waiting!() || host.is_some(), EHostNotSpecified);

    host.do!(|host| {
        let Host { id: host_uid, game_id, .. } = transfer::receive(&mut cmd.id, host);
        assert!(game_id == id.to_inner(), EInvalidGame);
        assert!(state.to_host_id!() == host_uid.to_inner(), EIncorrectHost);

        host_uid.delete();
    });

    // Only the players can destroy the game, no garbage collection.
    assert!(players.any!(|player| player == ctx.sender()), ENotPlayer);

    if (cmd.games.contains(id.as_inner())) { cmd.games.remove(id.as_inner()); };
    recruits.destroy_empty();

    id.delete();

    replay::new(preset_id, history, ctx)
}

// === Game Actions ===

/// Place a Recruit on the map, store it in the `Game`.
public fun place_recruits(game: &mut Game, recruits: vector<Recruit>, ctx: &mut TxContext) {
    let sender = ctx.sender();

    assert!(recruits.length() > 0, EMustPlaceRecruits);
    assert!(game.players.contains(&sender), ENotPlayer);

    match (&mut game.state) {
        GameState::PlacingRecruits(players) => {
            let idx = players
                .find_index!(|player| *player == sender)
                .destroy_or!(abort EAlreadyPlacedRecruits);

            players.remove(idx);

            if (players.length() == 0) {
                game.state = GameState::Playing(0);
            }
        },
        _ => abort EInvalidGame,
    };

    let position = game.positions.pop_back();
    let mut neighbors = game.map.spawn_points(position);

    recruits.destroy!(|recruit| {
        assert!(recruit.leader() == sender, ENotYourRecruit); // Make sure the sender owns the recruit.
        let point = neighbors.pop_back();
        let history = game.map.place_recruit(&recruit, point);

        game.recruits.add(object::id(&recruit), recruit);
        game.history.add(history);
    })
}

/// Move a unit along the path, the first point is the current position of the unit.
public fun move_unit(game: &mut Game, path: vector<u8>, clock: &Clock, ctx: &mut TxContext) {
    assert!(game.state.is_playing!(), ENotReady);
    assert!(game.can_play!(clock, ctx), ECannotPlay);

    game.history.add(game.map.move_unit(path))
}

/// Perform a reload action, replenishing ammo.
public fun perform_reload(game: &mut Game, x: u16, y: u16, clock: &Clock, ctx: &mut TxContext) {
    assert!(game.state.is_playing!(), ENotReady);
    assert!(game.can_play!(clock, ctx), ECannotPlay);

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
    clock: &Clock,
    ctx: &mut TxContext,
) {
    assert!(game.state.is_playing!(), ENotReady);
    assert!(game.can_play!(clock, ctx), ECannotPlay);

    let mut rng = rng.new_generator(ctx);
    let history_records = game.map.perform_grenade(&mut rng, x0, y0, x1, y1);

    history::list_kia(&history_records).do!(|id| {
        let recruit = game.recruits.remove(id);
        let leader = recruit.leader();
        transfer::public_transfer(recruit.kill(ctx), leader);
    });

    game.history.append(history_records)
}

/// Perform an attack action.
entry fun perform_attack(
    game: &mut Game,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    assert!(game.state.is_playing!(), ENotReady);
    assert!(game.can_play!(clock, ctx), ECannotPlay);

    let mut rng = rng.new_generator(ctx);
    let history = game.map.perform_attack(&mut rng, x0, y0, x1, y1);

    history::list_kia(&history).do!(|id| {
        if (id.to_address() == @0) return; // Skip empty addresses; needed for tests.
        let recruit = game.recruits.remove(id);
        let leader = recruit.leader();
        transfer::public_transfer(recruit.kill(ctx), leader);
    });

    game.history.append(history)
}

/// Switch to the next turn.
public fun next_turn(game: &mut Game, clock: &Clock, ctx: &mut TxContext) {
    assert!(game.state.is_playing!(), ENotReady);
    assert!(game.can_play!(clock, ctx), ECannotPlay);

    if (game.players.length() == 2) game.players.swap(0, 1);
    game.history.add(game.map.next_turn());
    game.last_turn = clock.timestamp_ms();
}

/// Share the `key`-only object after placing Recruits on the map.
public fun share(game: Game) {
    transfer::share_object(game)
}

// === Clock Management ===

/// Check if the current player is within the time limit. If over, turn is illegal, and next player
/// can play. Past this limit, we forbid any action, including the next turn (which will be called
/// by the next player).
macro fun can_play($game: &mut Game, $clock: &Clock, $ctx: &TxContext): bool {
    let ctx = $ctx;
    let game = $game;
    let clock = $clock;
    let sender = ctx.sender();
    let timestamp_ms = clock.timestamp_ms();

    // If the game is single player, allow the host to play indefinitely.
    if (game.players.length() == 1 && game.state.is_playing!()) {
        true
    } else if (sender == game.players[0]) {
        // Multiplayer: if the current player is within the time limit, allow them to play.
        (timestamp_ms - game.last_turn) <= game.time_limit
    } else if (sender == game.players[1]) {
        // Multiplayer: if player one missed their turn, and turn wasn't switched, allow player two
        // to end turn.
        // WARNING: expectation is that player two will first call next_turn();
        (timestamp_ms - game.last_turn) > game.time_limit
    } else {
        false
    }
}

// === Getters ===

/// Get the current turn of the game.
public(package) fun turn(self: &Game): u16 { self.map.turn() }

/// Get the time limit of the game.
public(package) fun time_limit(self: &Game): u64 { self.time_limit }

/// Get the last turn timestamp.
public(package) fun last_turn(self: &Game): u64 { self.last_turn }

/// Get the players in the game.
public(package) fun players(self: &Game): vector<address> { self.players }

/// Get the positions of the recruits.
public(package) fun positions(self: &Game): vector<vector<u8>> { self.positions }

/// Whether the game is in waiting state.
public(package) fun is_waiting(self: &Game): bool {
    self.state.is_waiting!()
}

/// Whether the game is in placing recruits state.
public(package) fun is_placing_recruits(self: &Game): bool {
    self.state.is_placing_recruits!()
}

/// Whether the game is in playing state.
public(package) fun is_playing(self: &Game): bool {
    self.state.is_playing!()
}

/// Whether the game is in finished state.
public(package) fun is_finished(self: &Game): bool {
    self.state.is_finished!()
}

// === State ===

/// Convert the `GameState` into a `Host` ID. Fails if the state is not `Waiting`.
macro fun to_host_id($state: &GameState): ID {
    match ($state) {
        GameState::Waiting(host_id) => *host_id,
        _ => abort EInvalidState,
    }
}

use fun state_is_waiting as GameState.is_waiting;

macro fun state_is_waiting($state: &GameState): bool {
    match ($state) {
        GameState::Waiting(_) => true,
        _ => false,
    }
}

use fun state_is_placing_recruits as GameState.is_placing_recruits;

macro fun state_is_placing_recruits($state: &GameState): bool {
    match ($state) {
        GameState::PlacingRecruits(_) => true,
        _ => false,
    }
}

use fun state_is_playing as GameState.is_playing;

macro fun state_is_playing($state: &GameState): bool {
    match ($state) {
        GameState::Playing(_) => true,
        _ => false,
    }
}

use fun state_is_finished as GameState.is_finished;

macro fun state_is_finished($state: &GameState): bool {
    match ($state) {
        GameState::Finished(_) => true,
        _ => false,
    }
}

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

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}

#[test]
fun test_deserialize_map() {
    let bytes =
        x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a0000000000000000000000000000000000000000000001020801";
    let mut bcs = bcs::new(bytes);
    let map = map::from_bcs(&mut bcs);
    let positions = bcs.peel_vec_length();

    assert!(map.id() == @0.to_id());
    assert!(map.turn() == 0);
    assert!(positions > 0);

    map.destroy();
}
