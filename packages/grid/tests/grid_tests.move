// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::grid_tests;

use grid::{grid, point};
use std::unit_test::{assert_eq, assert_ref_eq};
use sui::bcs;

#[test]
fun test_borrows() {
    let mut grid = grid::from_vector(vector[vector[0]]);
    assert_eq!(grid[0, 0], 0);

    // perform a mutable borrow
    *&mut grid[0, 0] = 1;
    assert_eq!(grid[0, 0], 1);
}

#[test]
fun test_swap() {
    let mut grid = grid::from_vector_unchecked(vector[
        // simple 3x3 grid
        vector[0, 0, 0],
        vector[0, 9, 0],
        vector[0, 0, 0],
    ]);

    let swapped = grid.swap(1, 1, 3);

    assert_eq!(swapped, 9);
    assert_eq!(grid[1, 1], 3);
    assert_eq!(grid[1, 0], 0);
    assert_eq!(grid[1, 2], 0);
}

#[test]
fun test_directions() {
    assert!(grid::is_up!(1, 1, 0, 1));
    assert!(grid::is_down!(0, 0, 1, 0));
    assert!(grid::is_left!(0, 1, 0, 0));
    assert!(grid::is_right!(0, 0, 0, 1));
}

#[test]
fun test_path_tracing() {
    let grid = grid::from_vector(vector[
        vector[1, 0, 0, 0, 0],
        vector[0, 0, 0, 0, 2],
        vector[0, 0, 0, 0, 0],
        vector[0, 0, 0, 0, 0], // 9 is a wall
        vector[0, 0, 0, 0, 0],
    ]);

    let path = grid::trace!(&grid, 0, 0, 1, 4, 6, |_, _, x, y| grid[x, y] == &0);

    assert!(path.is_some());
    assert!(path.borrow().length() == 5);
    assert!(path.borrow()[4] == point::new(1, 4));

    let grid = grid::from_vector(vector[
        vector[0, 1, 0, 0, 0],
        vector[0, 0, 0, 0, 0],
        vector[4, 4, 0, 0, 0],
        vector[2, 4, 0, 0, 0], // 9 is a wall
        vector[0, 0, 0, 0, 0],
    ]);

    let path = grid::trace!(&grid, 0, 1, 3, 0, 10, |_, _, x, y| grid[x, y] == &0);

    assert!(path.is_some());
    assert_ref_eq!(
        path.borrow(),
        &vector[
            point::new(1, 1), // down
            point::new(1, 2), // right
            point::new(2, 2), // down
            point::new(3, 2), // down
            point::new(4, 2), // down
            point::new(4, 1), // left
            point::new(4, 0), // left
            point::new(3, 0), // up
        ],
    )
}

#[test]
fun test_find_group() {
    let grid = grid::from_vector /* ERROR: */ (vector[
        vector[0, 0, 1, 0, 0],
        vector[0, 0, 1, 0, 2],
        vector[0, 0, 1, 0, 0],
        vector[1, 0, 1, 0, 0],
        vector[0, 1, 1, 0, 0],
        vector[0, 0, 0, 0, 0],
    ]);

    let group = grid.find_group!(0, 2, |el| *el == 1);
    assert_eq!(group.length(), 6);
}

#[test]
fun test_to_string() {
    let grid = grid::from_vector<u8>(vector[vector[1, 2, 3], vector[4, 5, 6], vector[7, 8, 9]]);
    assert_eq!(grid.to_string!(), b"|1|2|3|\n|4|5|6|\n|7|8|9|\n".to_string());
}

#[test]
fun test_from_bcs() {
    let grid = grid::from_vector(vector[vector[0, 1, 2], vector[3, 4, 5], vector[6, 7, 8]]);
    let bytes = bcs::to_bytes(&grid);
    let grid2 = grid::from_bcs!(&mut bcs::new(bytes), |bcs| bcs.peel_u8());

    assert!(grid2.width() == 3);
    assert_ref_eq!(&grid, &grid2);
}

#[test]
fun test_from_bcs_with_custom_type() {
    let grid = grid::tabulate!(3, 3, |x, y| point::new(x, y));
    let bytes = bcs::to_bytes(&grid);
    let grid2 = grid::from_bcs!(&mut bcs::new(bytes), |bcs| point::from_bcs(bcs));

    assert!(grid2.width() == 3);
    assert_ref_eq!(&grid, &grid2);
}
