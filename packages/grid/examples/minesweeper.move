// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Zero information and zero pre-knowledge of the board. Implementation relies
/// on the fact that the board is finite and the number of mines is known, but
/// the turns and the values are completely random and defined on each step.
module grid::minesweeper;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;
use sui::random::RandomGenerator;

public enum Tile has copy, drop {
    Hidden,
    Flagged,
    Revealed(u8),
}

public enum SolverTile has copy, drop {
    Unknown,
    Solutions(vector<Point>),
    Solved(u8),
}

public struct Minesweeper has drop {
    grid: Grid<Tile>,
    rng: RandomGenerator,
    turn: u16,
    mines: u16,
    revealed: u16,
}

#[allow(lint(public_random))]
/// Only playing square tiles.
public fun new(rng: RandomGenerator, width: u16, height: u16, mines: u16): Minesweeper {
    Minesweeper {
        grid: grid::tabulate!(width, height, |_, _| Tile::Hidden),
        revealed: 0,
        turn: 0,
        mines,
        rng,
    }
}

public fun flag(ms: &mut Minesweeper, x: u16, y: u16) {
    match (ms.grid[x, y]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    ms.grid.swap(x, y, Tile::Flagged);
}

public fun reveal(ms: &mut Minesweeper, x: u16, y: u16) {
    match (ms.grid[x, y]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    // track if this tile can be a mine, based on the analysis of the neighbors
    let mut potential_score = 0;
    let neighbors = ms.grid.moore!(point::new(x, y), 1);
    let mut max_score = 0u8;

    neighbors.do_ref!(|p| {
        let (x, y) = p.to_values();
        match (ms.grid[x, y]) {
            Tile::Revealed(n) => {
                let (is_solved, _mines) = ms.is_tile_solved(x, y);
                assert!(!is_solved);
                potential_score = potential_score + n
            },
            Tile::Hidden => max_score = max_score + 1,
            Tile::Flagged => max_score = max_score + 1,
        }
    });

    let num = ms.rng.generate_u8_in_range(0, max_score.min(5));
    if (num == 0) {
        ms.grid.swap(x, y, Tile::Revealed(0))
    } else {
        ms.grid.swap(x, y, Tile::Revealed(num))
    };

    ms.turn = ms.turn + 1;
}

fun solve(ms: &mut Minesweeper) {
    let (width, height) = (ms.grid.width(), ms.grid.height());

    // each coordinate 

    ms.grid.traverse!(|t, x, y| {
        match (t) {
            Tile::Hidden | Tile::Flagged => (),
            Tile::Revealed(n) => {
                let solutions = point::new(x, y).moore(1).filter!(|point| {
                    let (x, y) = point.to_values();
                    x < width && y < height
                });

                // let (is_solved, mines) = ms.is_tile_solved(x, y);
                // board.swap(x, y, Tile::Revealed(0));

                // is_solved
            },
        }

        // let (is_solved, mines) = ms.is_tile_solved(x, y);
        // board.swap(x, y, Tile::Revealed(0));

        // is_solved
    });
}

fun board_has_solution(ms: &Minesweeper): bool {
    let mut board = copy ms.grid;
    let (w, h) = (board.width(), board.height());

    w.do!(|x| h.do!(|y| {
        let (is_solved, mines) = ms.is_tile_solved(x, y);
        mines.do!(|p| {
            let (x, y) = p.to_values();
            board.swap(x, y, Tile::Flagged)
        });
        // board.swap(x, y, Tile::Flagged);
    }));
    // 'scan: {
    //     board.traverse!(|t, x, y| {
    //         let (is_solved, mines) = ms.is_tile_solved(x, y);
    //         board.swap(x, y, Tile::Revealed(0));

    //         is_solved
    //     });
    // };

    let mut str = b"\n".to_string();
    str.append(board.to_string!());
    std::debug::print(&str);

    true
}

/// Check that the number of untouched tiles is equal to the number of mines.
/// Additionally, prove that the neighbor tiles can have a solution.
fun is_tile_solved(ms: &Minesweeper, x: u16, y: u16): (bool, vector<Point>) {
    let num_mines = match (ms.grid[x, y]) {
        Tile::Revealed(n) => n,
        _ => return (false, vector[]),
    };

    let neighbors = ms.grid.moore!(point::new(x, y), 1);
    let mut count = neighbors.length() as u8;
    let mut mines = vector[];
    neighbors.do!(|p| {
        let (x, y) = p.to_values();
        match (ms.grid[x, y]) {
            Tile::Revealed(_) => count = count - 1,
            _ => mines.push_back(p),
        }
    });

    (count == num_mines, mines)
}

#[test_only]
public fun debug(self: &Minesweeper) {
    let mut s = b"\n".to_string();
    s.append(self.grid.to_string!());
    std::debug::print(&s);
}

public use fun tile_to_string as Tile.to_string;

public fun tile_to_string(t: &Tile): String {
    match (t) {
        Tile::Hidden => b"_".to_string(),
        Tile::Flagged => b"F".to_string(),
        Tile::Revealed(n) => (*n).to_string(),
    }
}

#[test]
fun test_minesweeper() {
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = new(rng, 4, 4, 4); // 10x10, 10 mines

    ms.debug();
    ms.reveal(1, 1);
    ms.reveal(0, 1);

    ms.debug();
    ms.flag(0, 0);
    ms.reveal(0, 2);

    ms.board_has_solution();

    // ms.reveal(1, 0);
    // ms.reveal(2, 0);

    // ms.reveal(0, 0);
    // ms.reveal(2, 1);
    // ms.reveal(2, 1);

    // ms.debug();
}
