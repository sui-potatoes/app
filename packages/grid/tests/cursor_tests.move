// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::cursor_tests;

use grid::{cursor, direction::{down, right, up, left}};
use std::unit_test::assert_eq;

#[test]
// goes in a square: down, right, up, left
// then in zigzag: down-right, down-left, up-right, up-left
fun cursor() {
    let mut cursor = cursor::new(0, 0);
    let (x, y) = cursor.to_values();
    assert_eq!(x + y, 0); // lazy check

    cursor.move_to(down!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 0);

    cursor.move_to(right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(up!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 1);

    cursor.move_to(left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 0);

    cursor.move_to(down!() | right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(down!() | left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 2);
    assert_eq!(y, 0);

    cursor.move_to(up!() | right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(up!() | left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 0);
}

#[test]
fun cursor_to_from_point() {
    let cursor = cursor::new(10, 10);
    let point = cursor.to_point();
    let cursor = point.to_cursor();

    let (xc, yc) = cursor.to_values();
    let (xp, yp) = point.to_values();

    assert_eq!(xc, xp);
    assert_eq!(yc, yp);
}
