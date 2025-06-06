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

    let p2 = point::new(3, 4);
    assert_eq!(p.range(&p2), 4);

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
    // 3: | |3|1|2| |
    // 4: | | |2| | |

    let n = point::new(2, 2).von_neumann(2);
    assert!(n.contains(&point::new(0, 2))); // 0
    assert!(n.contains(&point::new(1, 1))); // 1
    assert!(n.contains(&point::new(1, 2))); // 1
    assert!(n.contains(&point::new(1, 3))); // 1
    assert!(n.contains(&point::new(2, 0))); // 2
    assert!(n.contains(&point::new(2, 1))); // 2
    assert!(n.contains(&point::new(2, 3))); // 2
    assert!(n.contains(&point::new(2, 4))); // 2
    assert!(n.contains(&point::new(3, 1))); // 3
    assert!(n.contains(&point::new(3, 2))); // 3
    assert!(n.contains(&point::new(3, 3))); // 3
    assert!(n.contains(&point::new(4, 2))); // 4
    assert!(n.length() == 12);
}

#[test]
fun from_bcs() {
    let p1 = point::new(10, 10);
    let bytes = std::bcs::to_bytes(&p1);
    let p2 = point::from_bytes(bytes);

    assert_eq!(p1, p2);
}
