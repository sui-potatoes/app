// // Copyright (c) Sui Potatoes
// // SPDX-License-Identifier: MIT

// /// Implements the game of Go. The game of Go is a board game for two players
// /// that originated in China more than 2,500 years ago. The game is rich in
// /// strategy despite its simple rules. The game is played on a square grid of
// /// size 19x19, 13x13, or 9x9. Players take turns placing stones of their
// /// color on the intersections of the grid. The goal is to surround territory
// /// and capture the opponent's stones. The game ends when both players pass
// /// consecutively, and the player with the most territory wins.
// ///
// /// TODO: Implement scoring
// module go_game::go_;

// use grid::{grid::{Self, Grid}, point::{Self, Point}};

// // public use fun go_game::render::svg as Board.print_svg;

// /// Trying to place a stone on an invalid field (already occupied).
// const EInvalidMove: u64 = 0;
// /// The move would result in the group being surrounded.
// const ESuicideMove: u64 = 1;
// /// The move would violate the Ko rule (repeating the board state).
// const EKoRule: u64 = 2;

// /// A color of a player or `Empty` when the field is not taken.
// public enum Tile has copy, drop, store {
//     Empty,
//     Black,
//     White,
// }

// /// The current turn of the game. The turn is either `Black` or `White`.
// public enum Turn has copy, drop, store {
//     Black,
//     White,
// }

// /// A group of stones on the board. A group is a set of connected stones of
// /// the same color. A group can be captured if all its liberties are taken.
// /// The first element is the color of the group, the second element is the
// /// set of points that make up the group.
// public struct Group(Tile, vector<Point>) has copy, drop, store;

// /// The game board. The board is a square grid of size `size` by `size`.
// /// Normally, the board is 19x19, but casual games can be played on smaller
// /// boards, such as 9x9 or 13x13.
// public struct Board has copy, drop, store {
//     /// The board data. The board is a 2D vector of `u8` values. The values
//     /// can be `EMPTY`, `BLACK`, or `WHITE`.
//     grid: Grid<Tile>,
//     /// The size of the board. The board is a square grid of size `size` by
//     /// `size`. Uses `u16` type for compatibility with the `Grid`.
//     size: u16,
//     /// The current turn. The turn is either `BLACK` or `WHITE`.
//     /// The game starts with the black player.
//     turn: Turn,
//     /// The moves made on the board. The moves are stored as a vector of
//     /// points, where each point represents a stone placed on the board.
//     moves: vector<Point>,
//     /// The score of the game. The score is a vector of three elements:
//     /// - the neutral score (empty intersections)
//     /// - the score of the black player
//     /// - the score of the white player
//     scores: vector<u64>,
//     /// Stores the last two board states to check for the Ko rule.
//     ko_store: vector<Grid<Tile>>,
// }

// /// Create a new board.
// public fun new(size: u8): Board {
//     Board {
//         size,
//         grid: grid::tabulate!(size, size, |_, _| Tile::Empty),
//         turn: Turn::Black,
//         moves: vector[],
//         scores: vector[0, 0, 0],
//         ko_store: vector[],
//     }
// }

// /// Place a stone on the board at the given coordinates. The stone is placed
// /// on the intersection of the grid at the coordinates `(x, y)`. The stone
// /// is placed by the current player. The player's turn is then switched.
// public fun place(board: &mut Board, x: u16, y: u16) {
//     let point = &mut board.grid[x, y];
//     let turn = board.turn;

//     assert!(point.is_empty(), EInvalidMove); // #[can't on a non-empty field]

//     *point = board.turn.to_color();
//     board.turn.switch();
//     board.moves.push_back(point::new(x, y));

//     let neighbors = neighbors(board.size, point::new(x, y));
//     let mut opponent_stones = vector[];
//     let mut score = 0;

//     // quick scan through the neighbors for the following reasons:
//     // 1. find enemy groups for the "sacrifice move"
//     // 2. learn the state of the points around the put stone
//     neighbors.length().do!(|i| {
//         let stone = board[neighbors[i]];
//         if (stone != turn.to_color() && !stone.is_empty()) {
//             opponent_stones.push_back(neighbors[i]);
//         };
//     });

//     // kill all opponent stones if they're affected by this move
//     opponent_stones.destroy!(|point| {
//         if (board[point].is_empty()) return; // already killed
//         let group = board.get_group(point);
//         if (board.is_group_surrounded(&group)) {
//             score = score + board.replace_group(group, Tile::Empty);
//         }
//     });

//     // check if the move is a suicide move
//     let group = board.get_group(point::new(x, y));
//     assert!(!board.is_group_surrounded(&group), ESuicideMove);

//     // deal with the Ko Rule: check the state against 2 previous rounds
//     board.ko_store.insert(board.grid, 0);
//     if (board.ko_store.length() > 2) {
//         assert!(&board.grid != &board.ko_store.pop_back(), EKoRule);
//     };

//     // update the score with taken stones
//     let idx = turn.to_color().to_index();
//     *&mut board.scores[idx] = board.scores[idx] + score;
// }

// /// Calculates the territory taken by each of the players.
// /// Supposed to use the flood fill algorithm eventually :wink:
// public fun score(_board: &Board): vector<u64> {
//     abort 0
// }

// public fun get_group(board: &Board, point: Point): Group {
//     let mut visited = vector[point];
//     get_group_int(board, point, &mut visited);
//     Group(board[point], visited)
// }

// /// Removes the group from the field, returns the size of the group.
// public fun replace_group(board: &mut Board, group: Group, with: Tile): u64 {
//     let Group(_, group) = group;
//     let size = group.length();
//     group.destroy!(|el| *board.get_mut(el) = with);
//     size
// }

// /// Checks if the group is surrounded, eg has no liberties.
// public fun is_group_surrounded(board: &Board, group: &Group): bool {
//     let mut i = 0;
//     let Group(_, group) = group;
//     while (i < group.length()) {
//         let neighbors = neighbors(board.size, group[i]);
//         let mut j = 0;
//         while (j < neighbors.length()) {
//             let neighbor = neighbors[j];
//             if (board[neighbor].is_empty()) return false;
//             j = j + 1;
//         };
//         i = i + 1;
//     };

//     true
// }

// /// Helper function to get the `Point` neighbors of a given point. Helps
// /// ignore out-of-bounds neighbors for points on the edge of the board.
// public fun neighbors(size: u16, p: Point): vector<Point> {
//     let (x, y) = p.to_values();
//     let mut neighbors = vector[];

//     if (x > 0) neighbors.push_back(point::new(x - 1, y)); // left
//     if (y > 0) neighbors.push_back(point::new(x, y - 1)); // top
//     if (x < size - 1) neighbors.push_back(point::new(x + 1, y)); // right
//     if (y < size - 1) neighbors.push_back(point::new(x, y + 1)); // bottom

//     neighbors
// }

// /// Public accessor for the board size.
// public fun size(b: &Board): u16 { b.size }

// /// Public accessor for the current turn.
// public fun turn(b: &Board): Turn { b.turn }

// /// Public accessor for the moves made on the board.
// public fun moves(b: &Board): &vector<Point> { &b.moves }

// /// Public accessor for the scores of the game (captured stones).
// public fun scores(b: &Board): &vector<u64> { &b.scores }

// /// Public accessor for the board data.
// public fun data(b: &Board): &Grid<Tile> { &b.grid }

// /// Convert a `u64` index to a `Tile`.
// public fun from_index(index: u64): Tile {
//     match (index) {
//         0 => Tile::Empty,
//         1 => Tile::Black,
//         2 => Tile::White,
//         _ => abort,
//     }
// }

// /// Convert a `Tile` to a `u64` index.
// public fun to_index(p: &Tile): u64 {
//     match (p) {
//         Tile::Empty => 0,
//         Tile::Black => 1,
//         Tile::White => 2,
//     }
// }

// /// Is the field empty or taken?
// public fun is_empty(p: &Tile): bool { p == &Tile::Empty }

// /// Is the Tile black?
// public fun is_black(p: &Tile): bool { p == &Tile::Black }

// /// Is the Tile white?
// public fun is_white(p: &Tile): bool { p == &Tile::White }

// /// Switch the turn to the other player.
// public fun switch(turn: &mut Turn) {
//     match (turn) {
//         Turn::Black => *turn = Turn::White,
//         Turn::White => *turn = Turn::Black,
//     }
// }

// /// Convert the turn to a color.
// public fun to_color(turn: &Turn): Tile {
//     match (turn) {
//         Turn::Black => Tile::Black,
//         Turn::White => Tile::White,
//     }
// }

// #[syntax(index)]
// public fun get(b: &Board, p: Point): &Tile {
//     b.grid.borrow_point(&p)
// }

// /// Mutable accessor for the board data.
// fun get_mut(b: &mut Board, p: Point): &mut Tile {
//     b.grid.borrow_point_mut(&p)
// }

// /// Internal function to get the group of stones that a point belongs to.
// /// Uses a depth-first search to find all connected stones of the same color.
// /// Returns a vector of points that make up the group.
// fun get_group_int(b: &Board, p: Point, visited: &mut vector<Point>) {
//     let mut stack = vector[];
//     let color = b[p];

//     neighbors(b.size, p).destroy!(|neighbor| {
//         if (visited.contains(&neighbor)) return;
//         if (b[neighbor] == color) {
//             visited.push_back(neighbor);
//             stack.push_back(neighbor);
//         };
//     });

//     stack.destroy!(|e| get_group_int(b, e, visited));
// }

// // === Testing ===

// #[test_only]
// use sui::bcs;

// #[test_only]
// /// Asserts that the board is in a certain state. Used for testing.
// public fun assert_state(board: &Board, state: vector<vector<u8>>) {
//     assert!(bcs::to_bytes(&board.grid) == bcs::to_bytes(&state), 0);
// }

// #[test_only]
// /// Asserts the score of the game. Used for testing.
// public fun assert_score(board: &Board, scores: vector<u64>) {
//     assert!(&board.scores == &scores, 0);
// }

// #[test_only]
// // TODO: ignores scores!
// // TODO: lacks validation, used only in tests!
// public fun from_vector(data: vector<vector<Tile>>): Board {
//     Board {
//         grid: grid::from_vector_unchecked(data),
//         size: data.length() as u16,
//         turn: Turn::Black,
//         moves: vector[],
//         scores: vector[0, 0, 0],
//         ko_store: vector[],
//     }
// }
