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
    let (row, col) = cursor.to_values();
    assert_eq!(row + col, 0); // lazy check
    assert_eq!(row, cursor.row());
    assert_eq!(col, cursor.col());

    cursor.move_to(down!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 0);

    cursor.move_to(right!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 1);

    cursor.move_to(up!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 0);
    assert_eq!(col, 1);

    cursor.move_to(left!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 0);
    assert_eq!(col, 0);

    cursor.move_to(down!() | right!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 1);

    cursor.move_to(down!() | left!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 2);
    assert_eq!(col, 0);

    cursor.move_to(up!() | right!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 1);

    cursor.move_to(up!() | left!());
    let (row, col) = cursor.to_values();
    assert_eq!(row, 0);
    assert_eq!(col, 0);

    // === move back ===

    cursor.move_back();
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 1);

    cursor.move_back();
    let (row, col) = cursor.to_values();
    assert_eq!(row, 2);
    assert_eq!(col, 0);

    cursor.move_back();
    let (row, col) = cursor.to_values();
    assert_eq!(row, 1);
    assert_eq!(col, 1);
}

#[test, expected_failure(abort_code = cursor::EOutOfBounds)]
fun move_back_out_of_bounds_fail() {
    let mut cursor = cursor::new(0, 0);
    cursor.move_to(up!());
}

#[test, expected_failure(abort_code = cursor::EOutOfBounds)]
fun move_back_out_of_bounds_2_fail() {
    let mut cursor = cursor::new(0, 0);
    cursor.move_to(left!());
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

#[test]
fun to_vector() {
    let cursor = cursor::new(1, 2);
    assert_eq!(cursor.to_vector(), vector[1, 2]);
}

#[test]
fun can_move_to() {
    let cursor = cursor::new(0, 0);
    assert!(cursor.can_move_to(down!()));
    assert!(cursor.can_move_to(right!()));
    assert!(!cursor.can_move_to(up!()));
    assert!(!cursor.can_move_to(left!()));
}

#[test]
fun to_from_bcs() {
    use sui::bcs;

    let mut cursor = cursor::new(1, 2);

    cursor.move_to(down!());
    cursor.move_to(right!());

    let bytes = bcs::to_bytes(&cursor);
    let copied = cursor::from_bytes(bytes);

    assert_eq!(cursor, copied);
}

#[test]
fun to_string() {
    let cursor = cursor::new(1, 2);
    assert_eq!(cursor.to_string(), b"[1, 2]".to_string());
}
