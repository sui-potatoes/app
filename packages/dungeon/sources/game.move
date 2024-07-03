// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The game module contains the main game logic.
module dungeon::game;

use sui::{
    table::{Self, Table},
    random::{Self, Random, RandomGenerator},
};
use dungeon::{
    game_master::GameMaster,
    player::{Self, Player},
    room::{Self, Room},
};

// === Errors ===

const EOneGamePerPlayer: u64 = 0;
const EInvalidDifficultyScalar: u64 = 1;
const EWrongMove: u64 = 2;
const EGameNotOver: u64 = 3;

// === Constants ===

const INITIAL_DIFFICULTY_SCALAR: u64 = 20_000;
const MAX_DIFFICULTY_SCALAR: u64 = 1_000_000;
const UP: u64 = 0;
const DOWN: u64 = 1;
const RIGHT: u64 = 2;
const LEFT: u64 = 3;

// === Structs ===

public struct Registry has key {
    id: UID,
    users: Table<address, address>,
    difficulty_scalar: u64,
}

public struct Game has key {
    id: UID,
    level: u8,
    difficulty_scalar: u64,
    room: Room,
    player: Player,
}

// === Public Mutative Function ===

fun init(ctx: &mut TxContext) {
    transfer::share_object(Registry {
        id: object::new(ctx),
        users: table::new(ctx),
        difficulty_scalar: INITIAL_DIFFICULTY_SCALAR,
    });
}

public fun new(registry: &mut Registry, size: u64, ctx: &mut TxContext) {
    assert!(!registry.users.contains(ctx.sender()), EOneGamePerPlayer);

    let id = object::new(ctx);
    registry.users.add(ctx.sender(), id.to_address());

    transfer::transfer(
        Game { 
            id, 
            level: 1, 
            difficulty_scalar: registry.difficulty_scalar,
            room: room::new(size),
            player: player::new(size),
        },
        ctx.sender(),
    )
}

entry fun `move`(game: &mut Game, random: &Random, dir: u64, ctx: &mut TxContext) {
    let mut gen = random.new_generator(ctx);
    game.make_move(&mut gen, dir, ctx);
}

public fun make_move(game: &mut Game, gen: &mut RandomGenerator, dir: u64, ctx: &mut TxContext) {
    match (dir) {
        UP => {
            assert!(game.player.position().y() < game.room.size(), EWrongMove);
            game.player.move_up()
        },
        DOWN => {
            assert!(game.player.position().y() > 0, EWrongMove);
            game.player.move_down()
        },
        RIGHT => {
            assert!(game.player.position().x() < game.room.size(), EWrongMove);
            game.player.move_right()
        },
        LEFT => {
            assert!(game.player.position().x() > 0, EWrongMove);
            game.player.move_left()
        },
        _ => abort EWrongMove
    };

    if (game.room.is_exit(game.player.position())) {
        game.win()
    } else { // if empty cell, we randomly generate a mine or not
        let number = gen.generate_u64_in_range(0, MAX_DIFFICULTY_SCALAR);
        if (number < game.difficulty_scalar) {
            game.lose();
        }
    }
}

public fun destroy(game: Game) {
    let Game { id, level, .. } = game;
    assert!(level == 0, EGameNotOver);
    id.delete();
}

// === Admin Only Function ===

public fun set_difficulty_scalar(self: &mut Registry, _: &GameMaster, difficulty_scalar: u64) {
    assert!(MAX_DIFFICULTY_SCALAR >= difficulty_scalar, EInvalidDifficultyScalar);
    
    self.difficulty_scalar = difficulty_scalar;
}

// === Package Only Function ===

public(package) fun level(self: &Game): u8 {
    self.level
}

public(package) fun difficulty_scalar(self: &Game): u64 {
    self.difficulty_scalar
}

// === Private functions ===

fun win(self: &mut Game) {
    self.level = self.level + 1;
    self.room = room::new(self.room.size() + 1);
    self.player.reposition(self.room.size());
}

fun lose(self: &mut Game) {
    self.level = 0;
}

// === Test functions ===

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(ctx);
}

