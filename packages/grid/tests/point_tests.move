// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::point_tests;

use grid::point;
use std::unit_test::assert_eq;

#[test]
fun point() {
    let p = point::new(1, 2);
    assert_eq!(p.x(), 1);
    assert_eq!(p.y(), 2);

    let (_, _) = p.to_values();
    let (x, y) = p.into_values();
    assert_eq!(x, 1);
    assert_eq!(y, 2);

    let v = p.to_vector();
    assert_eq!(v, vector[1, 2]);

    let p2 = point::new(3, 4);
    assert_eq!(p.manhattan_distance(&p2), 4);

    let n = p.von_neumann(1);
    assert_eq!(n.length(), 4);
    assert!(n.contains(&point::new(1, 1)));
    assert!(n.contains(&point::new(1, 3)));
    assert!(n.contains(&point::new(2, 2)));
    assert!(n.contains(&point::new(0, 2)));

    let str = p.to_string();
    assert_eq!(str, b"(1, 2)".to_string());
}

#[test]
fun distance() {
    let p1 = point::new(1, 1);
    let p2 = point::new(4, 5);

    assert_eq!(p1.manhattan_distance(&p2), 7);
    assert_eq!(p1.chebyshev_distance(&p2), 4);
    assert_eq!(p1.euclidean_distance(&p2), 5);
}

#[test]
fun moore() {
    let neighbors = point::new(0, 0).moore(0);
    assert_eq!(neighbors, vector[]);

    let neighbors = point::new(0, 0).moore(1);
    assert_eq!(neighbors.length(), 3);

    let neighbors = point::new(1, 1).moore(1);
    assert_eq!(neighbors.length(), 8);

    let neighbors = point::new(3, 3).moore(3);
    assert_eq!(neighbors.length(), 48); // 7x7 without the center

    let neighbors = point::new(0, 0).moore(3);
    assert_eq!(neighbors.length(), 15);
}

#[test]
fun le_compare() {
    let mut points = vector[
        point::new(1, 1),
        point::new(0, 0),
        point::new(2, 2),
        point::new(2, 0),
        point::new(0, 1),
        point::new(1, 0),
    ];
    points.insertion_sort_by!(|a, b| a.le(b));
    assert!(points.is_sorted_by!(|a, b| a.le(b)));
    assert_eq!(
        points,
        vector[
            point::new(0, 0),
            point::new(0, 1),
            point::new(1, 0),
            point::new(1, 1),
            point::new(2, 0),
            point::new(2, 2),
        ],
    );
}

#[test]
fun von_neumann() {
    let p = point::new(1, 1);
    assert!(p.von_neumann(0) == vector[]);

    let n = p.von_neumann(1);
    assert!(n.contains(&point::new(1, 0)));
    assert!(n.contains(&point::new(0, 1)));
    assert!(n.contains(&point::new(2, 1)));
    assert!(n.contains(&point::new(1, 2)));
    assert!(n.length() == 4);

    //     0 1 2 3 4
    // 0: | | |2| | |
    // 1: | |2|1|2| |
    // 2: |2|1|0|1|2|
    // 3: | |2|1|2| |
    // 4: | | |2| | |

    let n = point::new(2, 2).von_neumann(2);
    assert!(n.contains(&point::new(0, 2))); // 2
    assert!(n.contains(&point::new(1, 1))); // 2
    assert!(n.contains(&point::new(1, 2))); // 1
    assert!(n.contains(&point::new(1, 3))); // 2
    assert!(n.contains(&point::new(2, 0))); // 2
    assert!(n.contains(&point::new(2, 1))); // 2
    assert!(n.contains(&point::new(2, 3))); // 1
    assert!(n.contains(&point::new(2, 4))); // 2
    assert!(n.contains(&point::new(3, 1))); // 2
    assert!(n.contains(&point::new(3, 2))); // 1
    assert!(n.contains(&point::new(3, 3))); // 2
    assert!(n.contains(&point::new(4, 2))); // 2
    assert!(n.length() == 12);

    let n = point::new(3, 3).von_neumann(3);
    assert_eq!(n.length(), 24);

    let n = point::new(0, 0).von_neumann(3);
    assert_eq!(n.length(), 9);
}

#[test]
fun from_bcs() {
    let p1 = point::new(10, 10);
    let bytes = p1.to_bytes();
    let p2 = point::from_bytes(bytes);

    assert_eq!(p1, p2);
}
