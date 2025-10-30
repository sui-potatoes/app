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

    // === move back ===

    cursor.move_back();
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_back();
    let (x, y) = cursor.to_values();
    assert_eq!(x, 2);
    assert_eq!(y, 0);

    cursor.move_back();
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);
}

#[test, expected_failure(abort_code = cursor::EOutOfBounds)]
fun move_back_out_of_bounds_fail() {
    let mut cursor = cursor::new(0, 0);
    cursor.move_to(up!());
}

#[test, expected_failure(abort_code = cursor::ENoHistory)]
fun move_back_no_history_fail() {
    let mut cursor = cursor::new(0, 0);
    cursor.move_back();
}

#[test]
fun to_from_cell() {
    let cursor = cursor::new(10, 10);
    let cell = cursor.to_cell();
    let cursor = cell.to_cursor();

    let (cursor_row, cursor_col) = cursor.to_values();
    let (cell_row, cell_col) = cell.to_values();

    assert_eq!(cursor_row, cell_row);
    assert_eq!(cursor_col, cell_col);
}
