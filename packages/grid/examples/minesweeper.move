// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Zero information and zero pre-knowledge of the board. Implementation relies
/// on the fact that the board is finite and the number of mines is known, but
/// the turns and the values are completely random and defined on each step.
module grid::minesweeper;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;
use sui::{random::RandomGenerator, vec_map::{Self, VecMap}};

const ENumMinesExceeded: u64 = 0;
const ENotAllMinesFound: u64 = 1;

public enum Tile has copy, drop {
    Hidden,
    Flagged,
    Revealed(u8),
}

public struct Minesweeper has drop {
    grid: Grid<Tile>,
    rng: RandomGenerator,
    turn: u16,
    mines: u16,
    revealed: u16,
}

/// A tile in the solver.
public enum SolverTile has copy, drop {
    Unknown,
    SolutionScore(u8, u8),
    Solved(u8, bool), // score, is_solved
    Mine,
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

fun new_solver_grid(
    ms: &Minesweeper,
    x0: u16,
    y0: u16,
): (Grid<SolverTile>, vector<CheckedTile>, VecMap<u16, Point>) {
    // sweep the board, mark tiles that can be a mine, and then calculate the
    // total number of 100% defined mines.
    let mut indexes = vec_map::empty<u16, Point>();
    let mut check_tiles = vector<CheckedTile>[];
    let solver_grid = grid::tabulate!(ms.grid.width(), ms.grid.height(), |x, y| {
        let mut score = 0;
        let mut tiles_score = 0;

        // if the tile is revealed, we check if it is already solved
        // so if there's a clear solution, we can mark it on the solution
        // board right away.
        match (ms.grid[x, y]) {
            // TODO: come back to me, this may be the right place to mark the
            //       tile as solved. but haven't figured out how to do it so
            //       early in the algorithm.
            Tile::Revealed(0) => return SolverTile::Solved(0, true),
            Tile::Revealed(score) => {
                let mut solutions = vector[];
                ms.grid.neighbors(point::new(x, y)).destroy!(|p| {
                    let (x, y) = p.to_values();
                    match (ms.grid[x, y]) {
                        Tile::Revealed(_) => (),
                        _ => {
                            let idx = (x + 1) * 100 + (y + 1);
                            if (!indexes.contains(&idx)) indexes.insert(idx, p);
                            solutions.push_back(idx);
                        },
                    }
                });

                // TODO: insert at the right idx to avoid sorting
                check_tiles.push_back(CheckedTile {
                    point: point::new(x, y),
                    score,
                    solutions,
                });
                return SolverTile::Solved(0, false)
            },
            _ => (),
        };

        let neighbors = ms.grid.neighbors(point::new(x, y));

        // Count number of neighbors for the (x0, y0) tile.
        // if (x == x0 && y == y0) num_neighbors = neighbors.length();

        // count the number of mines in the neighborhood
        neighbors.destroy!(|p| {
            let (x, y) = p.to_values();
            match (ms.grid[x, y]) {
                Tile::Revealed(n) if (*n > 0) => {
                    score = score + n;
                    tiles_score = tiles_score + 1;
                },
                _ => (),
            }
        });

        // if the score is 0, we don't know anything about the tile
        if (score == 0) SolverTile::Unknown else SolverTile::SolutionScore(score, tiles_score)
    });

    check_tiles.insertion_sort_by!(|a, b| a.solutions.length() >= b.solutions.length());

    (solver_grid, check_tiles, indexes)
}

public struct CheckedTile has copy, drop {
    point: Point,
    score: u8,
    solutions: vector<u16>,
}

public fun reveal(ms: &mut Minesweeper, x: u16, y: u16) {
    // Tile already revealed. Abort.
    match (ms.grid[x, y]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    dbg!(b"turn: {}, grid before reveal\n{}", vector[ms.turn.to_string(), ms.grid.to_string!()]);

    let (mut solver_grid, check_tiles, indexes) = new_solver_grid(ms, x, y);

    solver_grid.debug!();
    std::debug::print(&check_tiles.map!(|CheckedTile { solutions, .. }| solutions));

    verify_solution(&solver_grid, check_tiles);
}

public fun reveal_(ms: &mut Minesweeper, x0: u16, y0: u16) {
    // Tile already revealed. Abort.
    match (ms.grid[x0, y0]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    dbg!(b"turn: {}, grid before reveal\n{}", vector[ms.turn.to_string(), ms.grid.to_string!()]);

    let (mut solver_grid, check_tiles, num_neighbors) = new_solver_grid(ms, x0, y0);

    dbg!(b"solver grid: initial state (scores calculated)\n{}", vector[solver_grid.to_string!()]);

    // ms.rng.shuffle(&mut check_tiles);
    // std::debug::print(&check_tiles);

    // now with all the weights in place, we can do another pass to mark the
    // tiles that have the highest score as solved.
    let mut mines = vector[];

    check_tiles.do_ref!(|CheckedTile { point, score, solutions }| {
        dbg!(
            b"point: {}; score: {}; solutions: {}",
            vector[point.to_string(), (*score).to_string(), solutions.length().to_string()],
        );
    });

    check_tiles.destroy!(|CheckedTile { point, score, .. }| {
        let (x, y) = point.to_values();
        // keep track of how many mines we already marked around this
        // tile, so we don't try to place more than possible.
        let mut to_place = score;

        // Take all the neighbors of the tile and filter out everything
        // that is not a potential mine. For existing mines, we decrement
        // the number of mines to place.
        let points = solver_grid.neighbors(point::new(x, y)).filter!(|p| {
            let (x, y) = p.to_values();
            match (solver_grid[x, y]) {
                SolverTile::SolutionScore(_, _) => true,
                SolverTile::Mine => {
                    // Trick: use this iteration to decrement the number
                    // of mines to place. Still return false to decrease
                    // number of points to check.
                    // TODO: verify that this is the right strategy.

                    // Makes sure we don't break the invariant.
                    // Very important assertion.
                    assert!(to_place > 0, ENumMinesExceeded);
                    to_place = to_place - 1;
                    false
                },
                _ => false,
            }
        });

        // if (x == 0 && y == 0) std::debug::print(&points);
        // if (x == 0 && y == 0) {
        //     dbg!(b"(0,0) score {}, to_place: {}", vector[score.to_string(), to_place.to_string()]);
        // };

        // Early exit if we have no mines to place; the tile is solved.
        if (to_place == 0) {
            dbg!(
                b"early exit on a tile: {}; score: {}",
                vector[point.to_string(), score.to_string()],
            );
            solver_grid.swap(x, y, SolverTile::Solved(score, true));
            return
        };

        // Filter out Mines for fields that are already solved;
        // This is to prevent duplicate symmetric solutions, like this:
        // |_|1|_|
        // |_|2|_|
        // |_|_|_|
        // TODO: merge this iteration with the previous one.
        let mut points = points.filter!(|p| 'search: {
            solver_grid.neighbors(*p).destroy!(|p| {
                let (x, y) = p.to_values();
                match (solver_grid[x, y]) {
                    SolverTile::Solved(_, true) => return 'search false,
                    _ => (),
                }
            });
            true
        });

        // Shuffle the points to get random order, then do stable sort
        // by score. This way even same score points will have different
        // order depending on the random.
        ms.rng.shuffle(&mut points);
        points.insertion_sort_by!(|a, b| {
            let (x1, y1) = a.to_values();
            let (x2, y2) = b.to_values();

            let score_1 = match (solver_grid[x1, y1]) {
                SolverTile::SolutionScore(s, _) => s,
                _ => 0,
            };

            let score_2 = match (solver_grid[x2, y2]) {
                SolverTile::SolutionScore(s, _) => s,
                _ => 0,
            };

            score_2 <= score_1
        });

        // take the first `n` points
        (to_place as u64).min(points.length()).do!(|i| {
            let (x, y) = points[i].to_values();
            if (!mines.contains(&points[i])) mines.push_back(points[i]);
            solver_grid.swap(x, y, SolverTile::Mine);
        });

        // mark the number of mines surrounding the tile now
        solver_grid.swap(x, y, SolverTile::Solved(score, true));
    });

    // solving ambiguous cases - the final pass;
    dbg!(b"solver grid: after marking mines\n{}", vector[solver_grid.to_string!()]);

    // verify that the solution is valid
    verify_solution(&solver_grid, check_tiles);

    assert!(mines.length() <= ms.mines as u64);

    // means we solved it all (?)
    // then the board is at the state where we know everything and can give score directly
    if (mines.length() == ms.mines as u64) {
        let target = point::new(x0, y0);
        match (solver_grid[x0, y0]) {
            SolverTile::Mine => abort,
            _ => (),
        };

        // if the target tile is not a mine, we can reveal it and count neighbors
        let mut mine_count = 0;
        ms.grid.neighbors(target).destroy!(|p| {
            let (x, y) = p.to_values();
            match (solver_grid[x, y]) {
                SolverTile::Mine => mine_count = mine_count + 1,
                _ => (),
            }
        });

        ms.grid.swap(x0, y0, Tile::Revealed(mine_count));
        ms.revealed = ms.revealed + 1;
        ms.turn = ms.turn + 1;
        return;
    };

    solver_grid.debug!();

    // TODO: we currently fail on scores if the first tile is 0.
    let num_neighbors = 8u64;
    let min = if (ms.turn == 0) 1 else 0;
    let max = (ms.mines as u8 - (mines.length() as u8)).min(num_neighbors as u8);
    let num = ms.rng.generate_u8_in_range(min, max);

    ms.grid.swap(x0, y0, Tile::Revealed(num));

    dbg!(b"num picked: {}; num neighbors: {}", vector[num.to_string(), num_neighbors.to_string()]);

    ms.turn = ms.turn + 1;
}

fun verify_solution(solution: &Grid<SolverTile>, check_tiles: vector<CheckedTile>) {
    check_tiles.destroy!(|CheckedTile { point, score, .. }| {
        let mines = solution.neighbors(point).count!(|p| {
            let (x, y) = p.to_values();
            match (solution[x, y]) {
                SolverTile::Mine => true,
                _ => false,
            }
        });

        if (mines as u8 != score) {
            dbg!(
                b"not all mines found for point {}: {} != {}",
                vector[point.to_string(), mines.to_string(), score.to_string()],
            );
            abort ENotAllMinesFound
        };
    });
}

public use fun tile_to_string as Tile.to_string;

public fun tile_to_string(t: &Tile): String {
    match (t) {
        Tile::Hidden => b"_".to_string(),
        Tile::Flagged => b"F".to_string(),
        Tile::Revealed(n) => (*n).to_string(),
    }
}

public use fun solver_tile_to_string as SolverTile.to_string;

public fun solver_tile_to_string(t: &SolverTile): String {
    match (t) {
        SolverTile::Unknown => b"_".to_string(),
        SolverTile::SolutionScore(_, n) => (*n).to_string(),
        SolverTile::Solved(n, _) => (*n).to_string(),
        SolverTile::Mine => b"M".to_string(),
    }
}

use fun neighbors as Grid.neighbors;

fun neighbors<T>(grid: &Grid<T>, point: Point): vector<Point> {
    grid.moore!(point, 1)
}

#[test_only]
public fun debug(self: &Minesweeper) {
    let mut s = b"\n".to_string();
    s.append(self.grid.to_string!());
    std::debug::print(&s);
}

#[test_only]
public fun from_vector(mines: u16, v: vector<vector<u8>>): Minesweeper {
    let rng = sui::random::new_generator_from_seed_for_testing(b"seed");
    Minesweeper {
        grid: grid::tabulate!(v.length() as u16, v[0].length() as u16, |x, y| {
            match (v[x as u64][y as u64]) {
                9 => Tile::Hidden,
                num @ _ if (*num < 9) => Tile::Revealed(num),
                _ => abort,
            }
        }),
        rng,
        turn: 0,
        mines,
        revealed: 0,
    }
}

#[test]
fun test_minesweeper() {
    let rng = sui::random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = new(rng, 4, 4, 4); // 10x10, 10 mines

    ms.debug();
    ms.reveal(1, 1);
    ms.reveal(0, 1);

    ms.debug();
    ms.flag(0, 0);
    ms.reveal(0, 2);
}

#[test]
fun test_known_solution() {
    let mut ms = from_vector(
        8,
        vector[
            vector[9, 9, 9, 9, 9, 9],
            vector[9, 2, 2, 2, 2, 9],
            vector[9, 2, 0, 0, 2, 9],
            vector[9, 2, 0, 0, 2, 9],
            vector[9, 2, 2, 2, 2, 9],
            vector[9, 9, 9, 9, 9, 9],
        ],
    );

    ms.reveal(0, 0);
    ms.reveal(0, 1);
    ms.reveal(1, 0);
    ms.reveal(0, 4);
    ms.reveal(0, 5);
    ms.reveal(1, 5);

    ms.debug();
}

#[test]
fun test_random_solution_0() {
    let mut ms = from_vector(
        1,
        vector[
            // 3x3 no
            vector[0, 9, 9],
            vector[0, 9, 9],
            vector[0, 1, 9],
        ],
    );

    ms.reveal(1, 1);
    ms.reveal(1, 2);
    ms.reveal(0, 1);
    ms.reveal(0, 2);
    ms.flag(2, 2);
    // ms.reveal(1, 0);
    // ms.reveal(1, 0);
    // ms.reveal(0, 1);
    // ms.reveal(0, 1);
    // ms.reveal(1, 1);
    // ms.reveal(0, 2);
    // ms.reveal(1, 2);
    // ms.flag(2, 0);

    ms.debug();
}

#[test]
fun test_random_solution_1() {
    let mut ms = from_vector(
        1,
        vector[
            // 3x3 grid with revealed tile (1) in the middle
            vector[9, 9, 9],
            vector[9, 1, 9],
            vector[9, 9, 9],
        ],
    );

    ms.reveal(0, 0);
    ms.reveal(0, 1);
    ms.reveal(1, 0);
    ms.debug();
}

#[test]
fun test_random_solution_2() {
    let mut ms = from_vector(
        2,
        vector[
            // 3x3 grid with revealed tile (2) in the middle
            vector[9, 9, 9],
            vector[9, 2, 9],
            vector[9, 9, 9],
        ],
    );

    ms.reveal(0, 1);
    ms.reveal(0, 2);
    ms.debug();
}

#[test]
fun test_random_solution_2_1() {
    let mut ms = from_vector(
        2,
        vector[
            // 3x3 grid with revealed tile (2) in the middle
            vector[9, 1, 9],
            vector[9, 2, 9],
            vector[9, 9, 9],
        ],
    );

    ms.reveal(1, 2);
    ms.debug();
}

#[test]
fun test_random_solution_3_1() {
    let mut ms = from_vector(
        3,
        vector[
            // 3x3 grid with 3 mines, and two revealed tiles 1 and 3
            vector[9, 1, 9],
            vector[9, 3, 9],
            vector[9, 9, 9],
        ],
    );

    ms.reveal(1, 2);
    ms.debug();
}

#[test]
// Notes: given the order of iteration, the (1, 0) is always a mine in any setup.
// ...which is not totally random.
//
// I believe the `wire` case should not be predictable.
fun test_binary_wire() {
    let mut ms = from_vector(
        5,
        vector[
            vector[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
            vector[9, 1, 9, 9, 1, 9, 9, 1, 9, 9, 1, 9, 9],
            vector[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        ],
    );

    ms.reveal(1, 2);
    ms.reveal(1, 8);
    ms.debug();
}

#[test]
fun test_not_gate() {
    let mut ms = from_vector(
        9,
        vector[
            vector[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
            vector[1, 1, 1, 1, 1, 1, 1, 1, 2, 9, 2, 1, 1, 1, 1, 1, 1, 1, 1],
            vector[9, 9, 1, 9, 9, 1, 9, 9, 3, 9, 3, 9, 9, 1, 9, 9, 1, 9, 9],
            vector[1, 1, 1, 1, 1, 1, 1, 1, 2, 9, 2, 1, 1, 1, 1, 1, 1, 1, 1],
            vector[0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0],
        ],
    );

    ms.reveal(2, 1);
    ms.reveal(2, 4);
    ms.reveal(2, 7); // center
    ms.debug();
}

#[test]
fun test_large_map() {
    let mut ms = from_vector(
        5,
        vector[
            vector[9, 9, 9, 9, 9],
            vector[9, 9, 1, 9, 9],
            vector[9, 1, 2, 9, 9],
            vector[9, 1, 1, 9, 9],
            vector[9, 9, 9, 9, 9],
        ],
    );

    ms.reveal(1, 1);
    ms.debug();
}

#[allow(unused_function)]
macro fun dbg($t: vector<u8>, $v: vector<String>) {
    std::debug::print(&format($t, $v))
}

#[allow(unused_function)]
fun format(t: vector<u8>, v: vector<String>): String {
    let mut indices = vector[];
    let len = t.length();

    // push all the indices of the braces, so we can reference them
    // their number must match the length of `v`
    len.do!(|i| if (t[i] == 0x7b || t[i.min(len - 3) + 1] == 0x7d) {
        indices.push_back(i);
    });

    // enforce the invariant
    assert!(v.length() == indices.length());

    // now construct the string `s`
    let t = t.to_ascii_string();
    let mut s = b"".to_string();
    let mut offset = 0;

    // iterate over the indices, and concat substrings
    indices.length().do!(|i| {
        s.append(t.substring(offset, indices[i]).to_string());
        s.append(v[i]);
        offset = indices[i] + 2;
    });

    s
}

#[test]
fun test_format() {
    let v = vector[b"world".to_string(), b"foo".to_string(), b"bar".to_string()];
    std::unit_test::assert_eq!(
        format(b"Hello {} haha {} yoyo {}", v),
        b"Hello world haha foo yoyo bar".to_string(),
    );
}
