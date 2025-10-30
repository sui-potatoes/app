// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::cell_tests;

use grid::cell;
use std::unit_test::assert_eq;

#[test]
fun cell() {
    let p = cell::new(1, 2);
    assert_eq!(p.row(), 1);
    assert_eq!(p.col(), 2);

    let (_, _) = p.to_values();
    let (row, col) = p.into_values();
    assert_eq!(row, 1);
    assert_eq!(col, 2);

    let v = p.to_vector();
    assert_eq!(v, vector[1, 2]);

    let p2 = cell::new(3, 4);
    assert_eq!(p.manhattan_distance(&p2), 4);

    let n = p.von_neumann(1);
    assert_eq!(n.length(), 4);
    assert!(n.contains(&cell::new(1, 1)));
    assert!(n.contains(&cell::new(1, 3)));
    assert!(n.contains(&cell::new(2, 2)));
    assert!(n.contains(&cell::new(0, 2)));

    let str = p.to_string();
    assert_eq!(str, b"[1, 2]".to_string());
}

#[test]
fun distance() {
    let p1 = cell::new(1, 1);
    let p2 = cell::new(4, 5);

    assert_eq!(p1.manhattan_distance(&p2), 7);
    assert_eq!(p1.chebyshev_distance(&p2), 4);
    assert_eq!(p1.euclidean_distance(&p2), 5);
}

#[test]
fun moore() {
    let neighbors = cell::new(0, 0).moore(0);
    assert_eq!(neighbors, vector[]);

    let neighbors = cell::new(0, 0).moore(1);
    assert_eq!(neighbors.length(), 3);

    let neighbors = cell::new(1, 1).moore(1);
    assert_eq!(neighbors.length(), 8);

    let neighbors = cell::new(3, 3).moore(3);
    assert_eq!(neighbors.length(), 48); // 7x7 without the center

    let neighbors = cell::new(0, 0).moore(3);
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
fun von_neumann() {
    let p = cell::new(1, 1);
    assert!(p.von_neumann(0) == vector[]);

    let n = p.von_neumann(1);
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

    let n = cell::new(2, 2).von_neumann(2);
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

    let n = cell::new(3, 3).von_neumann(3);
    assert_eq!(n.length(), 24);

    let n = cell::new(0, 0).von_neumann(3);
    assert_eq!(n.length(), 9);
}

#[test]
fun from_bcs() {
    let p1 = cell::new(10, 10);
    let bytes = p1.to_bytes();
    let p2 = cell::from_bytes(bytes);

    assert_eq!(p1, p2);
}
