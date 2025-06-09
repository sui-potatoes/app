// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Checkers game implementation.
/// See https://en.wikipedia.org/wiki/Checkers for more information.
module grid::checkers;

use grid::{direction, grid::{Self, Grid}};
use std::{macros::num_diff, string::String};

/// The type of a tile on the checkers board. Black tiles are unavailable,
/// white tiles are empty, red tiles are red checkers, and blue tiles are blue
/// checkers.
public enum Tile has copy, drop, store {
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
        grid: grid::tabulate!(8, 8, |x, y| {
            if ((x + y) % 2 == 1) Tile::Unavailable
            else if (x < 3 && (x + y) % 2 == 0) Tile::Red
            else if (x > 4 && (x + y) % 2 == 0) Tile::Blue
            else Tile::Empty
        }),
        turn: true,
    }
}

/// Play a move on the checkers board, x0 and y0 are the starting position, and
/// x1 and y1 are the ending position. This implementation is incomplete, and
/// only supports moving a single tile or a jump over an opponent's piece.
public fun play(game: &mut Checkers, x0: u8, y0: u8, x1: u8, y1: u8) {
    let is_red = game.turn;
    let distance = num_diff!(x0, x1) + num_diff!(y0, y1);

    assert!(distance == 2 || distance == 4);

    let piece = game.grid.swap(x0 as u16, y0 as u16, Tile::Empty);
    assert!(piece == if (is_red) Tile::Red else Tile::Blue);
    let target = game.grid.swap(x1 as u16, y1 as u16, piece);
    assert!(target == Tile::Empty);

    if (distance == 4) {
        // if a move is a jump over a piece, it can only move to an empty tile, but
        // the piece in between must be a piece of the opposite color
        let direction = direction::direction!(x0, y0, x1, y1);
        let mut cursor = direction::new_cursor(x0 as u16, y0 as u16);
        cursor.move_to(direction); // get to the piece in between
        let (xp, yp) = cursor.to_values();
        let piece = game.grid.swap(xp, yp, Tile::Empty);
        assert!(piece == if (is_red) Tile::Blue else Tile::Red);
    };

    game.turn = !game.turn;
}

/// Destroy a checkers game.
public fun destroy(game: Checkers) {
    let Checkers { id, .. } = game;
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

#[test_only]
public fun debug(game: &Checkers) { game.grid.debug!() }

#[test]
fun test_checkers() {
    let ctx = &mut tx_context::dummy();
    let mut checkers = new(ctx);

    checkers.play(2, 0, 3, 1);
    checkers.play(5, 1, 4, 2);
    checkers.play(2, 2, 3, 3);
    checkers.play(4, 2, 2, 0); // take red piece by jumping over it

    // checkers.debug();

    checkers.destroy();
}
