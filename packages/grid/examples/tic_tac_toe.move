// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Tic-Tac-Toe game with custom grid and custom victory condition. A regular
/// game can be expressed as `3x3` grid with `3` in a row, while a custom game
/// could, for example, be a `10x10` grid with `5` in a row.
///
/// This example illustrates how to:
/// - Create a grid with a custom `Tile` type (and support printing it).
/// - Use the `grid::direction` module to handle directional movement.
/// - Tile swapping feature to mark empty tiles as `X` or `O`.
module grid::tic_tac_toe;

use grid::{direction, grid::{Self, Grid}};
use std::string::String;

const EInvalidMove: u64 = 0;
const EInvalidVictory: u64 = 1;
const EInvalidDirection: u64 = 2;
const EAlreadyFinished: u64 = 3;

/// The tile of the tic-tac-toe game.
/// Can have 3 possible values: `Empty`, `X`, or `O`.
public enum Tile has copy, drop, store {
    Empty,
    X,
    O,
}

/// The tic-tac-toe game. For demonstration purposes, the game is single-player,
/// however it should be relatively easy to extend this example to use shared
/// object and track players.
public struct TicTacToe has key, store {
    id: UID,
    grid: Grid<Tile>,
    win_condition: u8,
    /// True means `X`, false means `O`. Rotates on each play.
    current_player: bool,
    /// None means no winner yet, true means `X` won, false means `O` won.
    winner: Option<bool>,
}

/// Create a new `TicTacToe` game and transfer it to the caller.
public fun new(size: u8, win_condition: u8, ctx: &mut TxContext): TicTacToe {
    TicTacToe {
        id: object::new(ctx),
        grid: grid::tabulate!(size as u16, size as u16, |_, _| Tile::Empty),
        win_condition,
        current_player: true,
        winner: option::none(),
    }
}

/// Play a move in the `TicTacToe` game.
public fun play(game: &mut TicTacToe, x: u8, y: u8) {
    assert!(game.winner.is_none(), EAlreadyFinished);

    let swapped_tile = game
        .grid
        .swap(x as u16, y as u16, if (game.current_player) Tile::X else Tile::O);

    assert!(swapped_tile == Tile::Empty, EInvalidMove);
    game.current_player = !game.current_player;
}

/// Prove victory in the `TicTacToe` game by sending the winning tiles.
public fun prove_victory(game: &mut TicTacToe, tiles: vector<vector<u8>>) {
    assert!(game.winner.is_none(), EAlreadyFinished);

    let start = tiles[0];
    let len = tiles.length();
    let end = tiles[len - 1];

    assert!(len as u8 == game.win_condition, EInvalidVictory);

    // 1. Get the start->end direction.
    // 2. Place the cursor at the start.
    // 3. Move cursor one by one in the given direction, check each tile.
    // 4. If succeeds, then the player has won.
    let direction = direction::direction!(start[0], start[1], end[0], end[1]);
    let mut cursor = direction::new_cursor(start[0] as u16, start[1] as u16);
    let is_x = game.grid[start[0] as u16, start[1] as u16] == Tile::X;

    // Go through each tile in the vector, check if it maps to the cursor
    // position, and if the tile at that position is the same as the initial
    // tile (either `X` or `O`).
    tiles.do!(|tile| {
        let (x, y) = cursor.to_values();
        assert!(tile[0] as u16 == x && tile[1] as u16 == y, EInvalidDirection);
        assert!(game.grid[x, y] == if (is_x) Tile::X else Tile::O, EInvalidVictory);
        if (tile != end) cursor.move_to(direction);
    });

    game.winner.fill(is_x);
}

/// Destroy the `TicTacToe` object.
public fun destroy(game: TicTacToe) {
    let TicTacToe { id, .. } = game;
    id.delete();
}

/// Alias to support the `.to_string!()` Grid macro (and `grid.debug!()`).
public use fun tile_to_string as Tile.to_string;

/// Utility function to allow printing the `TicTacToe` Grid in the `.to_string!()`
/// Grid macro.
public fun tile_to_string(tile: &Tile): String {
    match (tile) {
        Tile::Empty => b" ",
        Tile::X => b"X",
        Tile::O => b"O",
    }.to_string()
}

#[test_only]
/// Utility debug function to print the grid.
public fun debug(game: &TicTacToe) { game.grid.debug!() }

#[test_only]
/// Clone the game state into a new `TicTacToe` object.
public fun clone(game: &TicTacToe, ctx: &mut TxContext): TicTacToe {
    TicTacToe {
        id: object::new(ctx),
        grid: game.grid, // implicit copy
        win_condition: game.win_condition,
        current_player: game.current_player,
        winner: game.winner,
    }
}

#[test]
fun test_default_game() {
    let ctx = &mut tx_context::dummy();
    let mut game = new(3, 3, ctx);

    // play a bunch of moves
    game.play(1, 1);
    game.play(0, 1);
    game.play(1, 0);
    game.play(1, 2);
    game.play(0, 0);
    game.play(2, 0);
    game.play(2, 2);

    // prove diagonal win.
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[0, 0], vector[1, 1], vector[2, 2]]);
        game.destroy();
    };

    // do the same but in reverse.
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[2, 2], vector[1, 1], vector[0, 0]]);
        game.destroy();
    };

    game.destroy();
}

#[test]
// 5x5 grid, 3 in a row
fun test_larger_game_with_multiple_wins() {
    let ctx = &mut tx_context::dummy();
    let mut game = new(5, 3, ctx);

    // play a bunch of moves
    game.play(1, 1);
    game.play(0, 1);
    game.play(1, 0);
    game.play(2, 3);
    game.play(2, 2);
    game.play(4, 4);
    game.play(3, 2);
    game.play(0, 0);
    game.play(1, 2);

    // horizontal
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[1, 0], vector[1, 1], vector[1, 2]]);
        game.destroy();
    };

    // reverse horizontal
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[1, 2], vector[1, 1], vector[1, 0]]);
        game.destroy();
    };

    // vertical + reverse
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[1, 2], vector[2, 2], vector[3, 2]]);
        game.destroy();
    };

    // reverse vertical
    {
        let mut game = game.clone(ctx);
        game.prove_victory(vector[vector[3, 2], vector[2, 2], vector[1, 2]]);
        game.destroy();
    };

    game.destroy();
}
