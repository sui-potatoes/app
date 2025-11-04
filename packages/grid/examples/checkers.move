// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Checkers game implementation.
/// See https://en.wikipedia.org/wiki/Checkers for more information.
module grid::checkers;

use grid::{cell, direction, grid::{Self, Grid}};
use std::string::String;

/// The type of a tile on the checkers board. Black tiles are unavailable,
/// white tiles are empty, red tiles are red checkers, and blue tiles are blue
/// checkers.
public enum Tile has store {
    Unavailable,
    Empty,
    Red,
    Blue,
}

/// A single instance of a Checkers game.
public struct Checkers has key, store {
    id: UID,
    grid: Grid<Tile>,
    /// The current turn: `true` for red, `false` for blue.
    turn: bool,
}

/// Create a new `Checkers` game.
public fun new(ctx: &mut TxContext): Checkers {
    Checkers {
        id: object::new(ctx),
        grid: grid::tabulate!(8, 8, |row, col| {
            if ((row + col) % 2 == 1) Tile::Unavailable
            else if (row < 3 && (row + col) % 2 == 0) Tile::Red
            else if (row > 4 && (row + col) % 2 == 0) Tile::Blue
            else Tile::Empty
        }),
        turn: true,
    }
}

/// Play a move on the checkers board, row0 and col0 are the starting position,
/// and row1 and col1 are the ending position. This implementation is incomplete,
/// and only supports moving a single tile or a jump over an opponent's piece.
public fun play(game: &mut Checkers, mut moves: vector<vector<u16>>) {
    let is_red = game.turn;
    let mut c0 = cell::from_vector(moves.remove(0));

    // There must be more than 1 move.
    assert!(moves.length() > 0);

    // Take the figure from the board.
    // Make sure the right figure is taken based on the turn number.
    let piece = game.grid.swap_cell(&c0, Tile::Empty);
    assert!(if (is_red) piece.is_red() else piece.is_blue());

    // Each move in checkers follows the same rules: repeat for each move.
    moves.do!(|c1| {
        let c1 = cell::from_vector(c1);
        let direction = c0.direction_to(&c1);
        let linf_distance = c0.linf_distance(&c1);

        assert!(game.grid.borrow_cell(&c1).is_empty());
        assert!(direction::is_direction_diagonal!(direction));
        assert!(linf_distance == 1 || linf_distance == 2);

        // If a move is a jump over a piece, it can only move to an empty tile, but
        // the piece in between must be a piece of the opposite color.
        if (linf_distance == 2) {
            let mut cursor = c0.to_cursor();
            cursor.move_to(direction); // get to the piece in between
            let (xp, yp) = cursor.to_values();
            let piece = game.grid.swap(xp, yp, Tile::Empty);
            assert!(if (is_red) piece.is_blue() else piece.is_red());

            // Remove the piece from the board.
            piece.destroy();
        };

        c0 = c1; // Final assignment for next (and final) move.
    });

    // Place the piece at the last location. We already know it's empty.
    game.grid.swap_cell(&c0, piece).destroy();
    game.turn = !game.turn;
}

/// Destroy a checkers game.
public fun destroy(game: Checkers) {
    let Checkers { id, grid, .. } = game;
    grid.destroy!(|tile| tile.destroy());
    id.delete();
}

/// Alias to support `grid.debug!()` macro.
public use fun tile_to_string as Tile.to_string;

/// Print a tile as a `String`.
public fun tile_to_string(tile: &Tile): String {
    match (tile) {
        Tile::Unavailable => b"=",
        Tile::Empty => b"_",
        Tile::Red => b"R",
        Tile::Blue => b"B",
    }.to_string()
}

/// Check if the Tile is Red.
public fun is_red(tile: &Tile): bool {
    match (tile) {
        Tile::Red => true,
        _ => false,
    }
}

/// Check if the Tile is Blue.
public fun is_blue(tile: &Tile): bool {
    match (tile) {
        Tile::Blue => true,
        _ => false,
    }
}

/// Check if the Tile is Empty.
public fun is_empty(tile: &Tile): bool {
    match (tile) {
        Tile::Empty => true,
        _ => false,
    }
}

public use fun destroy_tile as Tile.destroy;

/// Destroy the Tile by matching on the value.
public fun destroy_tile(tile: Tile) {
    match (tile) {
        Tile::Red => {},
        Tile::Blue => {},
        Tile::Empty => {},
        Tile::Unavailable => {},
    }
}

#[test_only]
public fun debug(game: &Checkers) { game.grid.debug!() }

#[test]
fun test_checkers() {
    let ctx = &mut tx_context::dummy();
    let mut checkers = new(ctx);

    checkers.play(vector[vector[2, 0], vector[3, 1]]); // red
    checkers.play(vector[vector[5, 1], vector[4, 2]]);
    checkers.play(vector[vector[2, 2], vector[3, 3]]);
    checkers.play(vector[vector[6, 0], vector[5, 1]]);
    checkers.play(vector[vector[2, 4], vector[3, 5]]);
    // double kill!
    checkers.play(vector[vector[4, 2], vector[2, 4], vector[4, 6]]);
    checkers.play(vector[vector[3, 1], vector[4, 2]]);
    // single kill
    checkers.play(vector[vector[5, 3], vector[3, 1]]);

    // Uncomment this call to see the board state.
    // checkers.debug();

    checkers.destroy();
}
