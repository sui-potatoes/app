// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements the actual game of Go.
module go_game::go;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;

/// The move is invalid, the field is already occupied.
const EInvalidMove: u64 = 1;
/// The move is a suicide move.
const ESuicideMove: u64 = 2;
/// The move repeats previous state of the board.
const EKoRuleBroken: u64 = 3;

/// The game board.
public struct Board has copy, drop, store {
    /// The size of the board.
    size: u16,
    /// The internal grid of the Game.
    grid: Grid<Tile>,
    /// The current player. `true` if black, `false` if white.
    is_black: bool,
    /// Captured stones.
    score: Score,
    /// Stores history of moves.
    moves: vector<Point>,
    /// Stores last 2 states to implement the ko rule.
    prev_states: vector<Grid<Tile>>,
}

/// The score of the game, black and white stones.
public struct Score has copy, drop, store {
    black: u16,
    white: u16,
}

/// A group of stones on the board. Tile marks the color of the group.
/// Empty tile returns an empty group.
public struct Group(Tile, vector<Point>) has copy, drop;

/// A tile on the board. Implements a `to_string` method to allow printing.
public enum Tile has copy, drop, store {
    Empty,
    Black,
    White,
}

/// Create a new `Board` of the given `size`. Size can be `9`, `13`, or `19`.
public fun new(size: u16): Board {
    Board {
        size,
        grid: grid::tabulate!(size, size, |_, _| Tile::Empty),
        is_black: true,
        moves: vector[],
        score: Score { black: 0, white: 0 },
        prev_states: vector[],
    }
}

/// Place a stone on the board at the given position.
public fun place(board: &mut Board, x: u16, y: u16) {
    let stone = if (board.is_black) Tile::Black else Tile::White;

    assert!(board.grid.swap(x, y, stone) == Tile::Empty, EInvalidMove);

    // Check for suicide move: count neighbors of the point, if all of them are
    // opponent's stones, the move is suicide. However, if the surrounding group
    // is surrounded, the move is a capture.
    let (mut my_stones, mut enemy_stones) = (vector[], vector[]);
    let mut empty_num = 0;

    // Get all neighbors of the point. Split them into my stones and enemy stones.
    // All my stones which are neighbors, actually form a group. The only tricky
    // part is checking the enemy stones and their groups.
    point::new(x, y).von_neumann(1).destroy!(|p| {
        let (x, y) = p.into_values();
        if (x >= board.size || y >= board.size) return;
        match (board.grid[x, y]) {
            Tile::Empty => (empty_num = empty_num + 1),
            t @ _ => if (t == stone) {
                my_stones.push_back(p);
            } else {
                enemy_stones.push_back(p);
            },
        }
    });

    // Now we need to get unique groups of enemy stones. It is possible that the
    // surrounding stones are connected to each other.
    let mut enemy_groups = vector[];
    enemy_stones.destroy!(|p| {
        enemy_groups
            // Check if the point is already in a group.
            .find_index!(|Group(_, points)| points.contains(&p))
            .destroy_or!({ enemy_groups.push_back(board.find_group(p.x(), p.y())); 0 });
    });

    // Now we need to check if any of the enemy groups are surrounded.
    let surrounded_groups = enemy_groups.filter!(|g| board.is_group_surrounded(g));

    // If any of the enemy groups are surrounded, we capture them.
    if (surrounded_groups.length() > 0) {
        surrounded_groups.destroy!(|Group(_, points)| {
            // Increase score by the number of stones in the group.
            if (board.is_black) board.score.black = points.length() as u16 + board.score.black
            else board.score.white = points.length() as u16 + board.score.white;

            // Remove the group from the board.
            points.destroy!(|p| board.grid.swap(p.x(), p.y(), Tile::Empty));
        });
    } else if (empty_num == 0) {
        // If there are no empty neighbors, we need to check if the move is a
        // suicide by checking if the new group is surrounded.
        assert!(!board.is_group_surrounded(&board.find_group(x, y)), ESuicideMove);
    };

    board
        .prev_states
        .find_index!(|history| history == &board.grid)
        .is_some_and!(|_| abort EKoRuleBroken);

    if (board.prev_states.length() == 2) {
        board.prev_states.swap_remove(0);
    };

    // Add the move and the current state to the history.
    board.prev_states.push_back(copy board.grid);
    board.moves.push_back(point::new(x, y));
    board.is_black = !board.is_black;
}

/// Find a group of stones on the board. Returns an empty group if the Tile is
/// empty, alternatively goes through Von Neumann neighbors and adds them to the
/// group if they are of the same color.
public fun find_group(board: &Board, x: u16, y: u16): Group {
    // Store the stone color or return an empty group if the field is empty.
    let stone = match (board.grid[x, y]) {
        Tile::Empty => return Group(Tile::Empty, vector[]),
        _ => board.grid[x, y],
    };

    // Find the group of stones of the same color.
    let mut group = board
        .grid // Go Game relies on the Von Neumann neighborhood.
        .find_group!(point::new(x, y), |p| p.von_neumann(1), |tile| tile == &stone);

    // Sort the group to make them comparable.
    group.insertion_sort_by!(|a, b| a.le(b));

    Group(stone, group)
}

/// Checks if the group is surrounded.
public fun is_group_surrounded(board: &Board, group: &Group): bool {
    'search: {
        let Group(_, points) = group;
        points.do_ref!(|p| {
            // To make a call whether a group is surrounded, we need to check
            // for a single empty field neighboring the group. If there isn't
            // one, the group is surrounded. That is, assuming that the group
            // is homogeneous and exhaustive.
            let count = board.grid.von_neumann_count!(*p, 1, |t| t == &Tile::Empty);
            if (count > 0) return 'search false;
        });
        true
    }
}

// === Getters ===

/// Get the size of the board.
public fun size(b: &Board): u16 { b.size }

/// Get a reference to the inner `Grid`.
public fun grid(b: &Board): &Grid<Tile> { &b.grid }

#[syntax(index)]
/// Borrow a tile
public fun borrow(b: &Board, x: u16, y: u16): &Tile { &b.grid[x, y] }

/// Return true if the current turn is black.
public fun is_black_turn(b: &Board): bool { b.is_black }

// === Convenience ===

/// Return true if the tile is empty.
public fun is_empty(t: &Tile): bool { t == &Tile::Empty }

/// Return true if the tile is black.
public fun is_black(t: &Tile): bool { t == &Tile::Black }

/// Return true if the tile is white.
public fun is_white(t: &Tile): bool { t == &Tile::White }

/// As long as `Tile.to_string()` exists, we allow debug printing.
public use fun tile_to_string as Tile.to_string;

/// Convert a `Tile` to a `String`.
public fun tile_to_string(t: &Tile): String {
    match (t) {
        Tile::Empty => b"_",
        Tile::Black => b"B",
        Tile::White => b"W",
    }.to_string()
}

/// Alias for `tile_to_number`
public use fun tile_to_number as Tile.to_number;

/// Convert tile to `u8` representation.
public fun tile_to_number(t: &Tile): u8 {
    match (t) {
        Tile::Empty => 0,
        Tile::Black => 1,
        Tile::White => 2,
    }
}

#[test_only, allow(unused_function)]
public(package) fun from_vector(data: vector<vector<u8>>): Board {
    let grid = grid::tabulate!(data.length() as u16, data[0].length() as u16, |i, j| {
        match (data[i as u64][j as u64]) {
            0 => Tile::Empty,
            1 => Tile::Black,
            2 => Tile::White,
            _ => abort,
        }
    });

    Board {
        grid,
        is_black: true,
        moves: vector[],
        size: data.length() as u16,
        score: Score { black: 0, white: 0 },
        prev_states: vector[grid],
    }
}

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_find_group() {
    let board = from_vector(vector[
        vector[0, 1, 0, 0],
        vector[0, 1, 0, 0],
        vector[0, 1, 0, 2],
        vector[0, 0, 0, 0],
    ]);

    assert_eq!(board.find_group(0, 0), Group(Tile::Empty, vector[]));
    assert_eq!(
        board.find_group(0, 1),
        Group(Tile::Black, vector[point::new(0, 1), point::new(1, 1), point::new(2, 1)]),
    );

    assert_eq!(board.find_group(2, 3), Group(Tile::White, vector[point::new(2, 3)]));
}

#[test]
fun test_is_group_surrounded() {
    let board = from_vector(vector[
        vector[2, 1, 2, 1],
        vector[2, 1, 2, 1],
        vector[2, 1, 2, 2],
        vector[1, 0, 0, 0],
    ]);

    assert!(board.is_group_surrounded(&board.find_group(0, 0)));
    assert!(!board.is_group_surrounded(&board.find_group(0, 1)));
    assert!(!board.is_group_surrounded(&board.find_group(0, 2)));
    assert!(board.is_group_surrounded(&board.find_group(0, 3)));
}

#[test, expected_failure(abort_code = ESuicideMove)]
fun test_suicide_move() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[0, 2, 0],
        vector[1, 2, 0],
        vector[2, 2, 0],
    ]);

    // |B|W|_|
    // |B|W|_|
    // |W|W|_|
    board.place(0, 0);
}

#[test, expected_failure(abort_code = ESuicideMove)]
fun test_suicide_move_two_eyes() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[0, 2, 2],
        vector[1, 2, 2],
        vector[2, 2, 0],
    ]);

    // |B|W|_|
    // |B|W|_|
    // |W|W|_|
    board.place(0, 0);
}

#[test]
fun test_suicide_success_move() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[0, 2, 2],
        vector[1, 2, 2],
        vector[2, 2, 2],
    ]);

    // |B|_|_|
    // |B|_|_|
    // |_|_|_|
    board.place(0, 0);

    assert_eq!(board.score.black, 7);
}

#[test]
fun test_take_multiple_groups() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[2, 0, 2],
        vector[1, 0, 1],
        vector[0, 0, 0],
    ]);

    // |_|B|_|
    // |B|_|B|
    // |_|_|_|
    board.place(0, 1);

    assert_eq!(board.score.black, 2);
}

#[test, expected_failure(abort_code = EKoRuleBroken)]
fun test_ko_rule() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[2, 0, 2],
        vector[1, 2, 0],
        vector[0, 0, 0],
    ]);

    // |_|B|W|
    // |B|W|_|
    // |_|_|_|
    board.place(0, 1); // take the white stone

    // |W|_|W|
    // |B|W|_|
    // |_|_|_|
    board.place(0, 0); // place the white stone back
}

#[test]
fun test_ko_rule_bypassed() {
    // prettier-ignore
    let mut board = from_vector(vector[
        vector[2, 0, 2],
        vector[1, 2, 0],
        vector[0, 0, 0],
    ]);

    // |_|B|W|
    // |B|W|_|
    // |_|_|_|
    board.place(0, 1); // take the white stone

    // |_|B|W|
    // |B|W|_|
    // |W|_|_|
    board.place(2, 0); // place the white stone somewhere else

    // |_|B|W|
    // |B|W|_|
    // |W|_|B|
    board.place(2, 2); // another move

    // |W|_|W|
    // |_|W|_|
    // |W|_|B|
    board.place(0, 0); // previously illegal move

    assert_eq!(board.score.black, 1);
    assert_eq!(board.score.white, 2);
}
