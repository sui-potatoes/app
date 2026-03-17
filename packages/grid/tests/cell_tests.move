// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::cell_tests;

use grid::{cell, direction};
use std::unit_test::assert_eq;

#[test]
fun cell() {
    let c = cell::new(1, 2);
    assert_eq!(c.row(), 1);
    assert_eq!(c.col(), 2);

    let (_, _) = c.to_values();
    let (row, col) = c.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 2);

    let v = c.to_vector();
    assert_eq!(v, vector[1, 2]);

    let c2 = cell::new(3, 4);
    assert_eq!(c.manhattan_distance(&c2), 4);

    let n = c.von_neumann_neighbors(1);
    assert_eq!(n.length(), 4);
    assert!(n.contains(&cell::new(1, 1)));
    assert!(n.contains(&cell::new(1, 3)));
    assert!(n.contains(&cell::new(2, 2)));
    assert!(n.contains(&cell::new(0, 2)));

    let str = c.to_string();
    assert_eq!(str, b"[1, 2]".to_string());
}

#[test]
fun from() {
    let a = cell::from_vector(vector[0, 1]);
    let b = cell::from_world(1, 0);

    a.linf_distance(&b);

    assert_eq!(a.row(), 0);
    assert_eq!(a.col(), 1);
    assert_eq!(a, b);

    let (x, y) = a.to_world();

    assert_eq!(x, 1);
    assert_eq!(y, 0);
}

#[test]
fun distance() {
    let c1 = cell::new(1, 1);
    let c2 = cell::new(4, 5);

    assert_eq!(c1.manhattan_distance(&c2), 7);
    assert_eq!(c1.chebyshev_distance(&c2), 4);
    assert_eq!(c1.euclidean_distance(&c2), 5);
}

#[test]
// Note: practically speaking, we don't need to support distances that large.
// This test is here to ensure that the upscaling is done correctly.
// And, if needed, there's an option to use a larger type.
fun distance_overflow() {
    let u16_max = std::u16::max_value!();
    let c1 = cell::new(0, 0);
    let c2 = cell::new(u16_max / 2, u16_max / 2);

    assert_eq!(c1.euclidean_distance(&c2), 46339);
}

#[test]
fun moore_neighbors() {
    let neighbors = cell::new(0, 0).moore_neighbors(0);
    assert_eq!(neighbors, vector[]);

    let neighbors = cell::new(0, 0).moore_neighbors(1);
    assert_eq!(neighbors.length(), 3);

    let neighbors = cell::new(1, 1).moore_neighbors(1);
    assert_eq!(neighbors.length(), 8);

    let neighbors = cell::new(3, 3).moore_neighbors(3);
    assert_eq!(neighbors.length(), 48); // 7x7 without the center

    let neighbors = cell::new(0, 0).moore_neighbors(3);
    assert_eq!(neighbors.length(), 15);
}

#[test]
fun le_compare() {
    let mut cells = vector[
        cell::new(1, 1),
        cell::new(0, 0),
        cell::new(2, 2),
        cell::new(2, 0),
        cell::new(0, 1),
        cell::new(1, 0),
    ];
    cells.insertion_sort_by!(|a, b| a.le(b));
    assert!(cells.is_sorted_by!(|a, b| a.le(b)));
    assert_eq!(
        cells,
        vector[
            cell::new(0, 0),
            cell::new(0, 1),
            cell::new(1, 0),
            cell::new(1, 1),
            cell::new(2, 0),
            cell::new(2, 2),
        ],
    );
}

#[test]
fun direction_to() {
    let c0 = cell::new(0, 0);
    let c1 = cell::new(2, 0);
    let c2 = cell::new(2, 2);

    assert_eq!(c0.direction_to(&c1), direction::down!());
    assert_eq!(c0.direction_to(&c2), direction::down_right!());
}

#[test]
fun von_neumann_neighbors() {
    let c = cell::new(1, 1);
    assert!(c.von_neumann_neighbors(0) == vector[]);

    let n = c.von_neumann_neighbors(1);
    assert!(n.contains(&cell::new(1, 0)));
    assert!(n.contains(&cell::new(0, 1)));
    assert!(n.contains(&cell::new(2, 1)));
    assert!(n.contains(&cell::new(1, 2)));
    assert!(n.length() == 4);

    //     0 1 2 3 4
    // 0: | | |2| | |
    // 1: | |2|1|2| |
    // 2: |2|1|0|1|2|
    // 3: | |2|1|2| |
    // 4: | | |2| | |

    let n = cell::new(2, 2).von_neumann_neighbors(2);
    assert!(n.contains(&cell::new(0, 2))); // 2
    assert!(n.contains(&cell::new(1, 1))); // 2
    assert!(n.contains(&cell::new(1, 2))); // 1
    assert!(n.contains(&cell::new(1, 3))); // 2
    assert!(n.contains(&cell::new(2, 0))); // 2
    assert!(n.contains(&cell::new(2, 1))); // 2
    assert!(n.contains(&cell::new(2, 3))); // 1
    assert!(n.contains(&cell::new(2, 4))); // 2
    assert!(n.contains(&cell::new(3, 1))); // 2
    assert!(n.contains(&cell::new(3, 2))); // 1
    assert!(n.contains(&cell::new(3, 3))); // 2
    assert!(n.contains(&cell::new(4, 2))); // 2
    assert!(n.length() == 12);

    let n = cell::new(3, 3).von_neumann_neighbors(3);
    assert_eq!(n.length(), 24);

    let n = cell::new(0, 0).von_neumann_neighbors(3);
    assert_eq!(n.length(), 9);
}

#[test]
fun from_bcs() {
    let c1 = cell::new(10, 10);
    let bytes = c1.to_bytes();
    let c2 = cell::from_bytes(bytes);

    assert_eq!(c1, c2);
}
