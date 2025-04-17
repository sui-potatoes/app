// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Simple Sudoku Generator and verifier.
module 0::sudoku;

use grid::grid::{Self, Grid};
use sui::random::{Random, RandomGenerator};

const EModifiedPuzzle: u64 = 0;
const EIncorrectSolution: u64 = 1;

const COMPLETE: u16 = 0x3fe;

/// A Sudoku puzzle. Can be burned by solving it.
public struct Sudoku has key {
    id: UID,
    /// The grid component of the sudoku puzzle.
    grid: Grid<u8>,
}

/// Create a new `Sudoku` object and transfer it to the caller.
entry fun new(r: &Random, level: u8, ctx: &mut TxContext) {
    transfer::transfer(
        Sudoku {
            id: object::new(ctx),
            grid: generate(&mut r.new_generator(ctx), level),
        },
        ctx.sender(),
    )
}

/// Destroy the `Sudoku` puzzle by presenting the solution.
public fun solve(sudoku: Sudoku, solution: vector<vector<u8>>) {
    let Sudoku { grid, id } = sudoku;
    let inner = grid.into_vector();
    let complete = COMPLETE;

    // check verticals and rows in the same iteration
    let mut verticals = vector::tabulate!(9, |_| 0u16);
    9u64.do!(|i| {
        let mut row_complete = 0u16;
        9u64.do!(|j| {
            let v = solution[i][j];
            let o = inner[i][j];

            assert!(o == 0 || o == v, EModifiedPuzzle);
            row_complete = row_complete | (1 << v);
            *&mut verticals[j] = verticals[j] | (1 << v);
        });
        assert!(row_complete == complete, EIncorrectSolution);
    });

    verticals.destroy!(|result| assert!(result == complete, EIncorrectSolution));
    id.delete();
}

/// Generate a new `Sudoku` puzzle with the given level of difficulty.
/// The level is the percentage of cells that will be removed from the grid.
/// The seed for the first row is 1, 2, 3, 4, 5, 6, 7, 8, 9.
/// The numbers are then rotated with shifts (each row is rotated with a different shift): 3 3 1 3 3 1 3 3
/// 3. Remove X% of the cells
fun generate(rng: &mut RandomGenerator, level: u8): Grid<u8> {
    let mut seed = vector[8, 9, 3, 2, 7, 6, 4, 5, 1];
    let mut sudoku = grid::from_vector_unchecked(vector[
        seed,
        seed.rotate(3),
        seed.rotate(3),
        seed.rotate(1),
        seed.rotate(3),
        seed.rotate(3),
        seed.rotate(1),
        seed.rotate(3),
        seed.rotate(3),
    ]);

    // Remove 40% of the cells
    9u16.do!(|i| 9u16.do!(|j| {
        if (rng.generate_u8() % 10 < level) {
            *&mut sudoku[i, j] = 0;
        }
    }));

    sudoku
}

use fun rotate as vector.rotate;

/// Rotate the vector num times by removing the first element and appending it to the end.
fun rotate<T: copy>(seed: &mut vector<T>, num: u64): vector<T> {
    num.do!(|_| { let n = seed.remove(0); seed.push_back(n) });
    *seed
}

#[random_test]
fun test_generate_verify(seed: vector<u8>) {
    use sui::random;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(seed);
    let grid = generate(&mut rng, 0);
    let solution = (copy grid).into_vector();
    let sudoku = Sudoku { id: object::new(ctx), grid };

    solve(sudoku, solution);
}

#[random_test, expected_failure(abort_code = EModifiedPuzzle)]
fun test_modify_puzzle_fail(seed: vector<u8>) {
    use sui::random;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(seed);
    let grid = generate(&mut rng, 0);
    let solution = (copy grid).into_vector();
    let mut sudoku = Sudoku { id: object::new(ctx), grid };

    // perform modification to the grid
    *&mut sudoku.grid[0, 0] = 3;

    solve(sudoku, solution);
}

// This test depends on the seed of the RNG. Make sure to run `debug!()` to
// print the grid before changing the seed.
// For empty seed, the grid is:
// |8|9|3|2|7|6|4|5|1|
// |2|7|6|4|5|1|8|9|3|
// |4|5|1|8|9|3|2|7|6|
// |_|1|8|9|_|_|7|6|4| // 5, 3, 2
// |9|3|2|7|6|4|_|1|8| // 5
// |7|6|4|5|1|_|9|3|2| // 8
// |6|4|5|1|8|9|3|2|_| // 7
// |1|8|9|3|2|7|6|_|5| // 4
// |3|_|7|6|4|5|1|8|9| // 2
#[test, expected_failure(abort_code = EIncorrectSolution)]
fun test_incorrect_solution_fail() {
    use sui::random;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(b"");
    let grid = generate(&mut rng, 1);
    let mut solution = (copy grid).into_vector();
    let sudoku = Sudoku { id: object::new(ctx), grid };

    // perform modification to the grid
    *&mut solution[3][0] = 5;
    *&mut solution[3][4] = 3;
    *&mut solution[3][5] = 2;
    *&mut solution[4][6] = 5;
    *&mut solution[5][5] = 8;
    *&mut solution[6][8] = 7;
    *&mut solution[7][7] = 4;
    *&mut solution[8][1] = 2;

    // ^ solution is correct

    *&mut solution[8][1] = 4; // change mind - fail test

    solve(sudoku, solution);
}
