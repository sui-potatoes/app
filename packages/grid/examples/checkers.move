// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Checkers game implementation.
///
/// - Red are at the top; Blue are at the bottom.
/// - Red can only go down before an upgrade; Blue - only up.
/// - Until a piece upgraded, it can only move and consume forward.
///
/// See https://en.wikipedia.org/wiki/Checkers for more information.
module grid::checkers;

use grid::{cell, direction::{Self, down, up}, grid::{Self, Grid}};
use std::string::String;

#[error(code = 0)]
const ENoMoves: vector<u8> = b"To move a piece, pass at least two cells";
#[error(code = 1)]
const ENotYourTurn: vector<u8> = b"Trying to move a piece in a wrong turn";
#[error(code = 2)]
const ETargetCellNotEmpty: vector<u8> = b"Non-empty cell is in the path";
#[error(code = 3)]
const EIncorrectDistance: vector<u8> = b"A single move must be one or two cells away";
#[error(code = 4)]
const ENotDiagonalMove: vector<u8> = b"Only diagonal moves are allowed";
#[error(code = 5)]
const EIncorrectDirection: vector<u8> = b"Non-upgraded pieces can only go forward";
#[error(code = 6)]
const EOnlyConsumeEnemy: vector<u8> = b"Trying to jump over a friendly piece";

/// The type of a tile on the checkers board. Black tiles are unavailable,
/// white tiles are empty, red tiles are red checkers, and blue tiles are blue
/// checkers.
public enum Tile has store {
    Unavailable,
    Empty,
    Red(bool),
    Blue(bool),
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
            else if (row < 3 && (row + col) % 2 == 0) Tile::Red(false)
            else if (row > 4 && (row + col) % 2 == 0) Tile::Blue(false)
            else Tile::Empty
        }),
        turn: true,
    }
}

/// Play a move on the checkers board, row0 and col0 are the starting position,
/// and row1 and col1 are the ending position. This implementation is incomplete,
/// and only supports moving a single tile or a jump over an opponent's piece.
public fun play(game: &mut Checkers, mut moves: vector<vector<u16>>) {
    assert!(moves.length() > 2, ENoMoves);

    let is_red = game.turn;
    let mut c0 = cell::from_vector(moves.remove(0));

    // Take the piece from the board.
    // Make sure the right piece is taken based on the turn number.
    let mut piece = game.grid.swap_cell(&c0, Tile::Empty);
    let is_super = piece.can_go_backwards();
    assert!(if (is_red) piece.is_red() else piece.is_blue(), ENotYourTurn);

    // Each move in checkers follows the same rules: repeat for each move.
    moves.do!(|c1| {
        let c1 = cell::from_vector(c1);
        let direction = c0.direction_to(&c1);
        let linf_distance = c0.linf_distance(&c1);

        assert!(game.grid.borrow_cell(&c1).is_empty(), ETargetCellNotEmpty);
        assert!(linf_distance == 1 || linf_distance == 2, EIncorrectDistance);
        assert!(direction::is_direction_diagonal!(direction), ENotDiagonalMove);

        // Perform forward movement checks.
        // Red can only go down until it received an upgrade. Blue only up.
        let is_forward = if (is_red) direction & down!() > 0 else direction & up!() > 0;
        assert!(is_super || is_forward, EIncorrectDirection);

        if (linf_distance == 2) {
            let mut cursor = c0.to_cursor();
            cursor.move_to(direction); // Get to the piece in between.
            let (xp, yp) = cursor.to_values();
            let piece = game.grid.swap(xp, yp, Tile::Empty);
            assert!(if (is_red) piece.is_blue() else piece.is_red(), EOnlyConsumeEnemy);

            // Remove the piece from the board.
            piece.destroy();
        };

        c0 = c1; // Final assignment for next (and final) move.
    });

    // Upgrade the piece if it reached the opposite side.
    match (&mut piece) {
        Tile::Blue(is_super) if (c0.row() == 0) => *is_super = true,
        Tile::Red(is_super) if (c0.row() == 7) => *is_super = true,
        _ => {},
    };

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
        Tile::Red(_) => b"R",
        Tile::Blue(_) => b"B",
    }.to_string()
}

/// Check if the piece can move both ways.
public fun can_go_backwards(tile: &Tile): bool {
    match (tile) {
        Tile::Red(v) => *v,
        Tile::Blue(v) => *v,
        _ => false,
    }
}

/// Check if the Tile is Red.
public fun is_red(tile: &Tile): bool {
    match (tile) {
        Tile::Red(_) => true,
        _ => false,
    }
}

/// Check if the Tile is Blue.
public fun is_blue(tile: &Tile): bool {
    match (tile) {
        Tile::Blue(_) => true,
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
        Tile::Red(_) => {},
        Tile::Blue(_) => {},
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
    checkers.play(vector[vector[4, 2], vector[2, 4]]);
    checkers.play(vector[vector[3, 1], vector[4, 2]]);
    // single kill
    checkers.play(vector[vector[5, 3], vector[3, 1]]);

    // Uncomment this call to see the board state.
    // checkers.debug();

    checkers.destroy();
}
