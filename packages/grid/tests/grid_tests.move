// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::grid_tests;

use grid::{grid, point};
use std::unit_test::{assert_eq, assert_ref_eq};
use sui::bcs;

#[test]
fun creation() {
    let grid = grid::from_vector(vector[vector[0]]);
    assert_eq!(grid.cols(), 1);
    assert_eq!(grid.rows(), 1);
    assert_eq!(grid[0, 0], 0);

    let inner = grid.into_vector();
    assert_eq!(inner.length(), 1);
    assert_eq!(inner[0].length(), 1);
    assert_eq!(inner[0][0], 0);

    let grid2 = grid::from_vector_unchecked(inner);
    assert_eq!(grid2.cols(), 1);
    assert_eq!(grid2.rows(), 1);
    assert_eq!(grid2[0, 0], 0);
}

#[test, expected_failure(abort_code = grid::EIncorrectLength)]
fun from_vector_fail() {
    grid::from_vector<u8>(vector[]);
}

#[test, expected_failure(abort_code = grid::EIncorrectLength)]
fun from_vector_inconsistent_lengths_fail() {
    grid::from_vector<u8>(vector[vector[], vector[1]]);
}

#[test]
fun do_and_do_ref_mut() {
    let mut grid = grid::from_vector(vector[vector[0, 1, 2], vector[3, 4, 5], vector[6, 7, 8]]);

    let mut sum = 0;
    grid.do_ref!(|cell| sum = sum + *cell);
    assert_eq!(sum, 36);

    let mut sum = 0;
    grid.do!(|cell| sum = sum + cell);
    assert_eq!(sum, 36);

    grid.do_mut!(|cell| *cell = 0);

    let zero_vec = vector[0, 0, 0];

    assert_eq!(grid, grid::from_vector(vector::tabulate!(3, |_| zero_vec)));
}

#[test]
fun map_and_map_ref() {
    let grid = grid::from_vector<u8>(vector[vector[0, 1, 2], vector[3, 4, 5], vector[6, 7, 8]]);
    let mapped_ref = grid.map_ref!(|cell| (*cell * 2) as u16);
    let new_grid = grid.map!(|cell| (cell * 2) as u16);

    assert_eq!(new_grid.cols(), 3);
    assert_eq!(new_grid.rows(), 3);
    assert_eq!(mapped_ref, new_grid);
}

#[test]
fun traverse() {
    let grid = grid::from_vector(vector[vector[0, 1, 2], vector[3, 4, 5], vector[6, 7, 8]]);

    let mut sum = 0;
    grid.traverse!(|cell, (_, _)| sum = sum + *cell);
    assert_eq!(sum, 36);
}

#[test]
fun borrows() {
    let mut grid = grid::from_vector(vector[vector[0]]);
    assert_eq!(grid[0, 0], 0);

    // perform a mutable borrow
    *&mut grid[0, 0] = 1;
    assert_eq!(grid[0, 0], 1);
}

#[test]
fun swap() {
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
fun rotate() {
    let mut grid = grid::from_vector(vector[vector[1, 2, 3], vector[4, 5, 6], vector[7, 8, 9]]);

    grid.rotate(0);

    assert_eq!(grid.into_vector(), vector[vector[1, 2, 3], vector[4, 5, 6], vector[7, 8, 9]]);

    grid.rotate(1); // 90º

    assert_eq!(grid.into_vector(), vector[vector[7, 4, 1], vector[8, 5, 2], vector[9, 6, 3]]);

    grid.rotate(2); // 180º

    assert_eq!(grid.into_vector(), vector[vector[3, 6, 9], vector[2, 5, 8], vector[1, 4, 7]]);

    grid.rotate(1); // 90º
    grid.rotate(3); // 270º

    assert_eq!(grid.into_vector(), vector[vector[3, 6, 9], vector[2, 5, 8], vector[1, 4, 7]]);

    grid.rotate(4);

    // rotate large grid
    let size = 15u16;
    let mut grid = grid::tabulate!(size, size, |x, y| x + y);
    grid.rotate(5); // 5 is equivalent to 1

    // check the last column that it's 0 to 14
    size.do!(|i| assert_eq!(grid[i, size - 1], i));

    // check the first column that it's 14 to 28
    size.do!(|i| assert_eq!(grid[i, 0], i + size - 1));
}

#[test]
fun moore() {
    let grid = grid::from_vector(vector[
        vector[0, 1, 2, 3, 0],
        vector[0, 8, 1, 4, 0],
        vector[0, 7, 6, 5, 0],
        vector[0, 0, 0, 0, 0],
    ]);

    let mut neighbors = grid.moore(point::new(1, 2), 1);
    neighbors.insertion_sort_by!(|a, b| a.le(b));

    assert_eq!(
        neighbors,
        vector[
            vector[0, 1],
            vector[0, 2],
            vector[0, 3],
            vector[1, 1],
            vector[1, 3],
            vector[2, 1],
            vector[2, 2],
            vector[2, 3],
        ].map!(|v| point::from_vector(v)),
    );

    assert_eq!(grid.moore_count!(point::new(1, 2), 1, |v| *v > 4), 4);
}

#[test]
fun von_neumann() {
    let grid = grid::from_vector(vector[
        vector[0, 1, 2, 3, 0],
        vector[0, 8, 1, 4, 0],
        vector[0, 7, 6, 5, 0],
        vector[0, 0, 0, 0, 0],
    ]);

    let mut neighbors = grid.von_neumann(point::new(1, 2), 1);
    neighbors.insertion_sort_by!(|a, b| a.le(b));

    assert_eq!(neighbors, vector[
        vector[0, 2],
        vector[1, 1],
        vector[1, 3],
        vector[2, 2],
    ].map!(|v| point::from_vector(v)));

    assert_eq!(grid.von_neumann_count!(point::new(1, 2), 1, |v| *v > 4), 2);
}

#[test]
fun path_tracing() {
    let grid = grid::from_vector(vector[
        vector[1, 0, 0, 0, 0],
        vector[0, 0, 0, 0, 2],
        vector[0, 0, 0, 0, 0],
        vector[0, 0, 0, 0, 0], // 9 is a wall
        vector[0, 0, 0, 0, 0],
    ]);

    let path = grid::trace!(
        &grid,
        point::new(0, 0),
        point::new(1, 4),
        |p| p.von_neumann(1),
        |(_, _), (_, _)| true,
        6,
    );

    assert!(path.is_some());
    assert_eq!(path.borrow().length(), 5);
    assert_eq!(path.borrow()[4], point::new(1, 4));

    let grid = grid::from_vector(vector[
        vector[0, 1, 0, 0, 0],
        vector[0, 0, 0, 0, 0],
        vector[4, 4, 0, 0, 0],
        vector[2, 4, 0, 0, 0], // 9 is a wall
        vector[0, 0, 0, 0, 0],
    ]);

    let path = grid::trace!(
        &grid,
        point::new(0, 1),
        point::new(3, 0),
        |p| p.von_neumann(1),
        |(_, _), (x1, y1)| {
            grid[x1, y1] == 0 || (x1 == 3 && y1 == 0)
        },
        8,
    );

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
fun find_group() {
    let grid = grid::from_vector(vector[
        vector[0, 0, 1, 0, 0],
        vector[0, 0, 1, 0, 2],
        vector[0, 0, 1, 0, 0],
        vector[1, 0, 1, 0, 0],
        vector[0, 1, 1, 0, 0],
        vector[0, 0, 0, 0, 0],
    ]);

    let group = grid.find_group!(point::new(0, 2), |p| p.von_neumann(1), |el| *el == 1);
    assert_eq!(group.length(), 6);
}

#[test]
fun to_string() {
    let grid = grid::from_vector<u8>(vector[vector[1, 2, 3], vector[4, 5, 6], vector[7, 8, 9]]);
    assert_eq!(grid.to_string!(), b"|1|2|3|\n|4|5|6|\n|7|8|9|\n".to_string());
}

#[test]
fun from_bcs() {
    let grid = grid::from_vector(vector[vector[0, 1, 2], vector[3, 4, 5], vector[6, 7, 8]]);
    let bytes = bcs::to_bytes(&grid);
    let grid2 = grid::from_bcs!(&mut bcs::new(bytes), |bcs| bcs.peel_u8());

    assert!(grid2.cols() == 3);
    assert_ref_eq!(&grid, &grid2);
}

#[test]
fun from_bcs_with_custom_type() {
    let grid = grid::tabulate!(3, 3, |x, y| point::new(x, y));
    let bytes = bcs::to_bytes(&grid);
    let grid2 = grid::from_bcs!(&mut bcs::new(bytes), |bcs| point::from_bcs(bcs));

    assert!(grid2.cols() == 3);
    assert_ref_eq!(&grid, &grid2);
}
