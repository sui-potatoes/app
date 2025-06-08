// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_function)]
/// Zero information and zero pre-knowledge of the board. Implementation relies
/// on the fact that the board is finite and the number of mines is known, but
/// the turns and the values are completely random and defined on each step.
module grid::minesweeper;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;
use sui::random::RandomGenerator;

// const ENumMinesExceeded: u64 = 0;
// const ENotAllMinesFound: u64 = 1;

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
    NotMine,
    Mine,
}

public struct CheckedTile has copy, drop {
    point: Point,
    score: u8,
    solutions: vector<Point>,
    is_solved: bool,
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

fun new_solver_grid(ms: &Minesweeper): (Grid<SolverTile>, vector<CheckedTile>) {
    // sweep the board, mark tiles that can be a mine, and then calculate the
    // total number of 100% defined mines.
    let mut check_tiles = vector<CheckedTile>[];
    let solver_grid = grid::tabulate!(ms.grid.height(), ms.grid.width(), |x, y| {
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
                        _ => solutions.push_back(p),
                    }
                });

                solutions.insertion_sort_by!(|a, b| a.compare(b));

                // TODO: insert at the right idx to avoid sorting
                check_tiles.push_back(CheckedTile {
                    point: point::new(x, y),
                    score,
                    solutions,
                    is_solved: solutions.length() == score as u64,
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

    check_tiles.insertion_sort_by!(|a, b| {
        let (a_len, b_len) = (a.solutions.length(), b.solutions.length());
        a_len < b_len || (a_len == b_len && (a.score <= b.score))
    });

    (solver_grid, check_tiles)
}

use fun print_tiles as vector.print_tiles;

fun print_tiles(v: vector<CheckedTile>) {
    std::debug::print(
        &v.map_ref!(|CheckedTile { solutions, point, score, .. }| {
            let mut s = point.to_string();
            s.append_utf8(b"[");
            s.append((*score).to_string());
            s.append_utf8(b"]: ");
            solutions.do_ref!(|p| {
                s.append(p.to_string());
                s.append_utf8(b", ");
            });
            s
        }),
    );
}

public fun reveal(ms: &mut Minesweeper, x: u16, y: u16) {
    // Tile already revealed. Abort.
    match (ms.grid[x, y]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    dbg!(b"turn: {}, grid before reveal\n{}", vector[ms.turn.to_string(), ms.grid.to_string!()]);

    let (mut solver_grid, mut check_tiles) = new_solver_grid(ms);

    dbg!(b"Length: {}", vector[check_tiles.length().to_string()]);

    first_stage(&mut solver_grid, &mut check_tiles);

    dbg!(b"Length: {}", vector[check_tiles.length().to_string()]);

    if (check_tiles.length() == 0) return; // SUCCESS!

    check_tiles.print_tiles();
    remove_duplicates(&mut solver_grid, &mut check_tiles);
    check_tiles.print_tiles();

    dbg!(b"Length: {}", vector[check_tiles.length().to_string()]);

    // the first row is the one with the smallest number of solutions * mines
    // so we start with it and try to solve;
    // let mut solutions = check_tiles[0].solutions;
    // 'solution: {
    //     solutions.do_ref!(|p| {
    //         dbg!(b"Trying mine point: {}", vector[p.to_string()]);
    //         // try marking as mine.
    //         *solver_grid.borrow_point_mut(p) = SolverTile::Mine;
    //         // try solving.
    //         first_stage(&mut solver_grid, &mut check_tiles);
    //         // length.
    //         check_tiles.print_tiles();
    //         dbg!(b"Length (after this attempt): {}", vector[check_tiles.length().to_string()]);
    //         // return 'solution ()
    //     });
    // };
    // check_tiles.print_tiles();
    // dbg!(b"length: {}", vector[check_tiles.length().to_string()]);
    // solver_grid.debug!();

    return
}

#[allow(unused_mut_parameter)]
/// During this stage we try to decrease the scope of SAT by solving already
/// certain mines. This way we reduce number of future iterations, hence,
/// reduce gas spent on iterations and lookups.
fun first_stage(solver: &mut Grid<SolverTile>, check_tiles: &mut vector<CheckedTile>) {
    let mut changes = 1u64;
    while (changes > 0) {
        changes = 0;
        // prep work: solve the tiles that we already know the solution for
        // follow the logic:
        // 1. if the tile is solved, mark all mines
        // 2. if not solved, check if any of the solutions overlap with the mines
        // 3. decrease the searched score by the number of mines found in the solutions
        check_tiles.do_mut!(|CheckedTile { solutions, score: score_ref, is_solved, point: _ }| {
            let mut score = *score_ref as u64;
            let mut solutions_len = solutions.length();

            // If (score == solutions), all of them are mines, we can mark the
            // tile as solved. Then, must place the mines on the grid.
            if (score == solutions_len && !*is_solved) {
                *is_solved = true;
                solutions.do_ref!(|p| *solver.borrow_point_mut(p) = SolverTile::Mine);
                changes = changes + 1;
                return
            };

            // Map tiles
            let mut solver_tiles = solutions.map_ref!(|p| *solver.borrow_point(p));

            // If solutions contains fields marked as `NotMine`, filter them out
            // and compare the score to the leftover length.
            let mut remove_indices = vector[];
            solutions_len.do!(|i| if (solver_tiles[i] == SolverTile::NotMine) {
                remove_indices.push_back(i);
            });

            // Do the cleanup of all NotMine indices.
            remove_indices.destroy!(|i| {
                solutions_len = solutions_len - 1;
                solver_tiles.remove(i);
                solutions.remove(i);
            });

            assert!(score <= solutions_len);

            // Silly check: maybe we meet the (solutions_len == score) check.
            if (score == solutions_len) {
                *is_solved = true;
                solutions.do_ref!(|p| *solver.borrow_point_mut(p) = SolverTile::Mine);
                changes = changes + 1;
                return
            };

            // Now to mines. Collect all indices known to be mines.
            // If we know that a certain tile is a mine, decrease the score.
            let mut mine_indices = vector[];
            solutions_len.do!(|i| if (solver_tiles[i] == SolverTile::Mine) {
                mine_indices.push_back(i);
            });

            // Decrease the score by the found mines. If the score is 0, we know
            // that the rest of the solutions are NotMines
            mine_indices.destroy!(|i| {
                score = score - 1;
                *score_ref = score as u8;
                solutions.remove(i);
            });

            // We solved this already, mark the rest as not mines.
            if (score == 0) {
                *is_solved = true;
                solutions.do_ref!(|p| *solver.borrow_point_mut(p) = SolverTile::NotMine);
                changes = changes + 1;
                return
            };

            // If we're lucky, try solving this tile post filtering.
            if (score == solutions_len) {
                *is_solved = true;
                solutions.do_ref!(|p| *solver.borrow_point_mut(p) = SolverTile::Mine);
                changes = changes + 1;
                return
            };
        });

        *check_tiles = (*check_tiles).filter!(|CheckedTile { is_solved, .. }| !*is_solved);
    };
}

/// Second stage of optimizations: remove identical records (given, that all
/// records follow the same Point order).
fun remove_duplicates(_solver: &mut Grid<SolverTile>, check_tiles: &mut vector<CheckedTile>) {
    let (mut len, mut i) = (check_tiles.length(), 0);
    while (i < len) {
        let mut j = (i + 1).min(len - 1);
        let mut remove_indices = vector[];
        while (j < len) {
            let (lhs, rhs) = (&check_tiles[i], &check_tiles[j]);
            if (i != j && &lhs.solutions == &rhs.solutions && &lhs.score == &rhs.score) {
                remove_indices.push_back(j);
            };
            j = j + 1;
        };
        remove_indices.destroy!(|i| check_tiles.swap_remove(i));
        len = len - remove_indices.length();
        i = i + 1;
    };
}

fun find_mismatch(solution: &Grid<SolverTile>, check_tiles: vector<CheckedTile>): Option<u64> {
    'search: {
        let len = check_tiles.length();
        len.do!(|i| {
            let i = len - i - 1;
            let CheckedTile { point, score, .. } = check_tiles[i];
            let mines = solution.moore_count!(point, 1, |tile| tile == SolverTile::Mine);
            if (mines as u8 != score) {
                dbg!(
                    b"not all mines found for point {}: {} != {}; at index {}",
                    vector[point.to_string(), mines.to_string(), score.to_string(), i.to_string()],
                );
                return 'search option::some(i)
            };
        });

        option::none()
    }
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
        SolverTile::NotMine => b"N".to_string(),
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
        rng,
        mines,
        turn: 0,
        revealed: 0,
        grid: grid::tabulate!(v.length() as u16, v[0].length() as u16, |x, y| {
            match (v[x as u64][y as u64]) {
                9 => Tile::Hidden,
                num @ _ if (*num < 9) => Tile::Revealed(num),
                _ => abort,
            }
        }),
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
