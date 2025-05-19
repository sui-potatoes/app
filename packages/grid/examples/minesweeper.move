// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Zero information and zero pre-knowledge of the board. Implementation relies
/// on the fact that the board is finite and the number of mines is known, but
/// the turns and the values are completely random and defined on each step.
module grid::minesweeper;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;
use sui::{random::RandomGenerator, vec_map::{Self, VecMap}};

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
    Solved(u8, bool),
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

public fun reveal(ms: &mut Minesweeper, x0: u16, y0: u16) {
    std::debug::print(&b"Solving another tile".to_string());

    ms.grid.debug!();

    // sweep the board, mark tiles that can be a mine, and then calculate the
    // total number of 100% defined mines.
    let mut score_map: VecMap<u8, vector<Point>> = vec_map::empty();
    let mut target_tile_score = 0;
    let mut highest_score = 0;
    let mut solver_grid = grid::tabulate!(ms.grid.width(), ms.grid.height(), |x, y| {
        let mut score = 0;
        let mut tiles_score = 0;

        // if the tile is revealed, we check if it is already solved
        // so if there's a clear solution, we can mark it on the solution
        // board right away.
        match (ms.grid[x, y]) {
            // TODO: come back to me, this may be the right place to mark the
            //       tile as solved. but haven't figured out how to do it so
            //       early in the algorithm.
            Tile::Revealed(_) => return SolverTile::Solved(0, false),
            _ => (),
        };

        // count the number of mines in the neighborhood
        ms.grid.neighbors(point::new(x, y)).destroy!(|p| {
            let (x, y) = p.to_values();
            match (ms.grid[x, y]) {
                Tile::Revealed(n) if (*n > 0) => {
                    score = score + n;
                    tiles_score = tiles_score + 1;
                },
                _ => (),
            }
        });

        if (score_map.contains(&score)) score_map[&score].push_back(point::new(x, y))
        else score_map.insert(score, vector[point::new(x, y)]);

        // mark the target tile score
        if (x == x0 && y == y0) target_tile_score = score;

        // track the highest score
        if (score > highest_score) highest_score = score;

        // if the score is 0, we don't know anything about the tile
        if (score == 0) SolverTile::Unknown else SolverTile::SolutionScore(score, tiles_score)
    });

    solver_grid.debug!();

    // now with all the weights in place, we can do another pass to mark the
    // tiles that have the highest score as solved.
    let mut mines = vector[];
    ms.grid.traverse!(|tile, x, y| {
        match (tile) {
            Tile::Revealed(n) if (*n > 0) => {
                // if the tile is revealed, we want to solve its neighbors
                // for a tile like this, we want to take the number of mines
                // and pick highest score neighbors, that would be one of the
                // solutions.

                // we want to pick `n` highest scores out of all neighbors
                let mut points = solver_grid.neighbors(point::new(x, y)).filter!(|p| {
                    let (x, y) = p.to_values();
                    match (solver_grid[x, y]) {
                        SolverTile::SolutionScore(_, _) => true,
                        SolverTile::Mine => true,
                        _ => false,
                    }
                });

                ms.rng.shuffle(&mut points);
                points.insertion_sort_by!(|a, b| {
                    let (x1, y1) = a.to_values();
                    let (x2, y2) = b.to_values();

                    let score_1 = match (solver_grid[x1, y1]) {
                        SolverTile::SolutionScore(s, _) => s,
                        SolverTile::Mine => 8, // bypass score if mine is for sure
                        _ => 0,
                    };

                    let score_2 = match (solver_grid[x2, y2]) {
                        SolverTile::SolutionScore(s, _) => s,
                        SolverTile::Mine => 8, // bypass score if mine is for sure
                        _ => 0,
                    };

                    score_2 <= score_1
                });

                // Filter out Mines for fields that are already solved;
                // This is to prevent duplicate symmetric solutions, like this:
                // |_|1|_|
                // |_|2|_|
                // |_|_|_|
                std::debug::print(&b"points before filter:".to_string());
                std::debug::print(&point::new(x, y).to_string());
                std::debug::print(&points.length().to_string());
                let points = points.filter!(|p| 'search: {
                    let score_point = *p;
                    solver_grid.neighbors(*p).destroy!(|p| {
                        let (x, y) = p.to_values();

                        if (x == 0 && y == 1) {
                            std::debug::print(&b"should be caught and filter out mines surrounding it".to_string());
                        } else {
                            std::debug::print(&b"nooo".to_string());
                            std::debug::print(&p.to_string());
                        };

                        match (solver_grid[x, y]) {
                            SolverTile::Solved(_, true) => {
                                std::debug::print(&b"filtering out".to_string());
                                std::debug::print(&p.to_string());
                                return 'search false;
                            },
                            SolverTile::Solved(_, false) => {
                                std::debug::print(&b"didn't filter out".to_string());
                                std::debug::print(&score_point.to_string());
                                return 'search true;
                            },
                            _ => return 'search true,
                        }
                    });
                    true
                });

                std::debug::print(&b"points after filter:".to_string());
                std::debug::print(&points.length().to_string());

                // take the first `n` points
                (*n as u64).do!(|i| {
                    let (x, y) = points[i].to_values();
                    if (!mines.contains(&points[i])) mines.push_back(points[i]);
                    solver_grid.swap(x, y, SolverTile::Mine);
                });

                std::debug::print(&b"mines after filter:".to_string());
                std::debug::print(&mines.map!(|p| p.to_string()));

                // mark the number of mines surronding the tile now
                solver_grid.swap(x, y, SolverTile::Solved(*n, true));
                std::debug::print(&b"marked solved".to_string());
                std::debug::print(&point::new(x, y).to_string());
            },
            Tile::Hidden | Tile::Flagged | Tile::Revealed(_) => (),
        }
    });

    // solving ambiguous cases - the final pass;

    solver_grid.debug!();

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

    match (ms.grid[x0, y0]) {
        Tile::Revealed(_) => abort,
        _ => (),
    };

    let num = ms.rng.generate_u8_in_range(0, ms.mines as u8 - (mines.length() as u8));
    if (num == 0) {
        ms.grid.swap(x0, y0, Tile::Revealed(0))
    } else {
        ms.grid.swap(x0, y0, Tile::Revealed(num))
    };

    ms.turn = ms.turn + 1;
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
        SolverTile::SolutionScore(n, _) => (*n).to_string(),
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
public fun from_vector(rng: RandomGenerator, mines: u16, v: vector<vector<u8>>): Minesweeper {
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
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
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
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = from_vector(
        rng,
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
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = from_vector(
        rng,
        1,
        vector[
            // 3x3 no
            vector[9, 9, 9],
            vector[9, 9, 9],
            vector[9, 9, 9],
        ],
    );

    ms.reveal(0, 0);
    ms.reveal(1, 0);
    ms.reveal(0, 1);
    ms.reveal(1, 1);
    ms.reveal(0, 2);
    ms.reveal(1, 2);
    ms.flag(2, 0);

    ms.debug();
}

#[test]
fun test_random_solution_1() {
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = from_vector(
        rng,
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
    use sui::random;

    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut ms = from_vector(
        rng,
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
