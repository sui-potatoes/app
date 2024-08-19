// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_use)]
/// Implements the game of Go. The game of Go is a board game for two players
/// that originated in China more than 2,500 years ago. The game is rich in
/// strategy despite its simple rules. The game is played on a square grid of
/// size 19x19, 13x13, or 9x9. Players take turns placing stones of their
/// colour on the intersections of the grid. The goal is to surround territory
/// and capture the opponent's stones. The game ends when both players pass
/// consecutively, and the player with the most territory wins.
///
/// TODO: Implement scoring
module gogame::go;

use std::ascii::{Self, String};
use sui::bcs;

const EMPTY: u8 = 0;
const BLACK: u8 = 1;
const WHITE: u8 = 2;

public use fun gogame::render::svg as Board.print_svg;

/// Trying to place a stone on an invalid field (already occupied).
const EInvalidMove: u64 = 0;
/// The move would result in the group being surrounded.
const ESuicideMove: u64 = 1;
/// The move would violate the Ko rule (repeating the board state).
const EKoRule: u64 = 2;

/// A colour of a player. The colour can be `BLACK` or `WHITE`.
public struct Color(u8) has store, copy, drop;

/// A player's move on the board, simply a pair of coordinates.
public struct Point(u8, u8) has store, copy, drop;

/// A group of stones on the board. A group is a set of connected stones of
/// the same colour. A group can be captured if all its liberties are taken.
/// The first element is the colour of the group, the second element is the
/// set of points that make up the group.
public struct Group(u8, vector<Point>) has store, copy, drop;

/// The game board. The board is a square grid of size `size` by `size`.
/// Normally, the board is 19x19, but casual games can be played on smaller
/// boards, such as 9x9 or 13x13.
public struct Board has store, copy, drop {
    /// The board data. The board is a 2D vector of `u8` values. The values
    /// can be `EMPTY`, `BLACK`, or `WHITE`.
    data: vector<vector<Color>>,
    /// The size of the board. The board is a square grid of size `size` by
    /// `size`.
    size: u8,
    /// The current turn. The turn is either `BLACK` or `WHITE`.
    /// The game starts with the black player.
    turn: u8,
    /// The moves made on the board. The moves are stored as a vector of
    /// points, where each point represents a stone placed on the board.
    moves: vector<Point>,
    /// The score of the game. The score is a vector of three elements:
    /// - the neutral score (empty intersections)
    /// - the score of the black player
    /// - the score of the white player
    scores: vector<u64>,
    /// Stores the last two board states to check for the Ko rule.
    ko_store: vector<vector<vector<Color>>>,
}

/// Create a new board.
public fun new(size: u8): Board {
    let row = vector::tabulate!(size as u64, |_| Color(EMPTY));
    let data = vector::tabulate!(size as u64, |_| row);

    Board {
        data,
        size,
        turn: BLACK,
        moves: vector[],
        scores: vector[0, 0, 0],
        ko_store: vector[],
    }
}

/// Place a stone on the board at the given coordinates. The stone is placed
/// on the intersection of the grid at the coordinates `(x, y)`. The stone
/// is placed by the current player. The player's turn is then switched.
public fun place(board: &mut Board, x: u8, y: u8) {
    let point = &mut board.data[x as u64][y as u64];
    let turn = board.turn;

    assert!(point.is_empty(), EInvalidMove); // #[can't on a non-empty field]

    *point = Color(board.turn);
    board.turn = if (board.turn == BLACK) { WHITE } else { BLACK };
    board.moves.push_back(Point(x, y));

    let neighbours = neighbours(board.size, Point(x, y));
    let mut opponent_stones = vector[];
    let mut score = 0;

    // quick scan through the neighbours for the following reasons:
    // 1. find enemy groups for the "sacrifice move"
    // 2. learn the state of the points around the put stone
    neighbours
        .length()
        .do!(
            |i| {
                let stone = board[neighbours[i]];
                if (!stone.is(turn) && !stone.is_empty()) {
                    opponent_stones.push_back(neighbours[i]);
                };
            },
        );

    // kill all opponent stones if they're affected by this move
    opponent_stones.destroy!(|point| {
        if (board[point].is_empty()) return; // already killed
        let group = board.get_group(point);
        if (board.is_group_surrounded(&group)) {
            score = score + board.replace_group(group, EMPTY);
        }
    });

    // check if the move is a suicide move
    let group = board.get_group(Point(x, y));
    assert!(!board.is_group_surrounded(&group), ESuicideMove);

    // deal with the Ko Rule: check the state against 2 previous rounds
    board.ko_store.insert(board.data, 0);
    if (board.ko_store.length() > 2) {
        assert!(&board.data != &board.ko_store.pop_back(), EKoRule);
    };

    // update the score with taken stones
    *&mut board.scores[turn as u64] = board.scores[turn as u64] + score;
}

/// Calculates the territory taken by each of the players.
/// Supposed to use the flood fill algorithm eventually :wink:
public fun score(_board: &Board): vector<u64> {
    abort 0
}

public fun get_group(board: &Board, point: Point): Group {
    let mut visited = vector[point];
    get_group_int(board, point, &mut visited);
    Group(board[point].0, visited)
}

/// Removes the group from the field, returns the size of the group.
public fun replace_group(board: &mut Board, group: Group, with: u8): u64 {
    let Group(_, mut group) = group;
    let size = group.length();
    while (!group.is_empty()) {
        *board.get_mut(group.pop_back()) = Color(with);
    }; // and now we
    size
}

/// Checks if the group is surrounded, eg has no liberties.
public fun is_group_surrounded(board: &Board, group: &Group): bool {
    let mut i = 0;
    let Group(_, group) = group;
    while (i < group.length()) {
        let neighbours = neighbours(board.size, group[i]);
        let mut j = 0;
        while (j < neighbours.length()) {
            let neighbour = neighbours[j];
            if (board[neighbour].is_empty()) return false;
            j = j + 1;
        };
        i = i + 1;
    };

    true
}

/// Helper function to get the `Point` neighbours of a given point. Helps
/// ignore out-of-bounds neighbours for points on the edge of the board.
public fun neighbours(size: u8, p: Point): vector<Point> {
    let Point(x, y) = p;
    let mut neighbours = vector[];

    if (x > 0) { neighbours.push_back(Point(x - 1, y)); }; // left
    if (y > 0) { neighbours.push_back(Point(x, y - 1)); }; // top
    if (x < size - 1) { neighbours.push_back(Point(x + 1, y)); }; // right
    if (y < size - 1) { neighbours.push_back(Point(x, y + 1)); }; // bottom

    neighbours
}

/// Public accessor for the board size.
public fun size(b: &Board): u8 { b.size }

/// Public accessor for the current turn.
public fun turn(b: &Board): u8 { b.turn }

/// Public accessor for the moves made on the board.
public fun moves(b: &Board): &vector<Point> { &b.moves }

/// Public accessor for the scores of the game (captured stones).
public fun scores(b: &Board): &vector<u64> { &b.scores }

/// Public accessor for the board data.
public fun data(b: &Board): &vector<vector<Color>> { &b.data }

/// Public accessor for the x coordinate of a point.
public fun x(p: &Point): u8 { p.0 }

/// Public accessor for the y coordinate of a point.
public fun y(p: &Point): u8 { p.1 }

/// Is the field empty or taken?
public fun is_empty(p: &Color): bool { p.0 == EMPTY }

/// Is the Colour black?
public fun is_black(p: &Color): bool { p.0 == BLACK }

/// Is the Colour white?
public fun is_white(p: &Color): bool { p.0 == WHITE }

/// Is the Colour the same as the given number?
public fun is(p: &Color, n: u8): bool { p.0 == n }

#[syntax(index)]
public fun get(b: &Board, p: Point): &Color {
    let Point(x, y) = p;
    &b.data[x as u64][y as u64]
}

/// Mutable accessor for the board data.
fun get_mut(b: &mut Board, p: Point): &mut Color {
    let Point(x, y) = p;
    &mut b.data[x as u64][y as u64]
}

/// Internal function to get the group of stones that a point belongs to.
/// Uses a depth-first search to find all connected stones of the same colour.
/// Returns a vector of points that make up the group.
fun get_group_int(b: &Board, p: Point, visited: &mut vector<Point>): vector<Point> {
    let mut stack = vector[];
    let colour = b[p];

    let mut neighbours = neighbours(b.size, p);
    while (neighbours.length() > 0) {
        let neighbour = neighbours.pop_back();
        if (visited.contains(&neighbour)) continue;
        if (b[neighbour] == colour) {
            visited.push_back(neighbour);
            stack.push_back(neighbour);
        };
    };

    while (stack.length() > 0) {
        get_group_int(b, stack.pop_back(), visited);
    };

    *visited
}

// === Testing ===

#[test_only]
/// Asserts that the board is in a certain state. Used for testing.
public fun assert_state(board: &Board, state: vector<vector<u8>>) {
    assert!(bcs::to_bytes(&board.data) == bcs::to_bytes(&state), 0);
}

#[test_only]
/// Asserts the score of the game. Used for testing.
public fun assert_score(board: &Board, scores: vector<u64>) {
    assert!(&board.scores == &scores, 0);
}

#[test_only]
// TODO: ignores scores!
// TODO: lacks validation, used only in tests!
public fun from_vector(data: vector<vector<u8>>): Board {
    let size = data.length();
    let mut i = 0;
    let mut board = vector[];
    while (i < size) {
        let mut row = vector[];
        let mut j = 0;
        while (j < size) {
            row.push_back(Color(data[i][j]));
            j = j + 1;
        };
        board.push_back(row);
        i = i + 1;
    };

    Board {
        data: board,
        size: size as u8,
        turn: BLACK,
        moves: vector[],
        scores: vector[0, 0, 0],
        ko_store: vector[board],
    }
}
