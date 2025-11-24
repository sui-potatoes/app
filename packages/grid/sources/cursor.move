// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The `Cursor` struct represents a movable `Cell` on the grid, and can be used
/// to trace paths, use the `direction` API and get coordinates for the current
/// position.
///
/// ```move
/// use grid::cursor;
/// use grid::direction;
///
/// #[test]
/// fun test_cursor() {
///     let mut cursor = cursor::new(0, 0);
///     cursor.move_to(direction::down!());
///     cursor.move_to(direction::down!() | direction::right!());
///
///     let (row, col) = cursor.to_values();
///     assert!(row == 2 && col == 1);
/// }
/// ```
///
/// The `Cursor` struct is tightly coupled with the `direction` module. Refer to
/// the `direction` module for more information.
module grid::cursor;

use grid::{cell::{Self, Cell}, direction::{Self, up, down, left, right}};
use std::string::String;
use sui::bcs::{Self, BCS};

/// Trying to move out of bounds.
const EOutOfBounds: u64 = 0;
/// Trying to move back when there is no history.
const ENoHistory: u64 = 1;

/// Cursor is similar to a `Cell` as it stores the coordinates, but also tracks
/// directions where it was moved, so it could be moved back.
public struct Cursor(u16, u16, vector<u8>) has copy, drop, store;

/// Create a new `Cursor` at `(row, column)`.
public fun new(row: u16, column: u16): Cursor { Cursor(row, column, vector[]) }

/// Get both coordinates of the cursor.
public fun to_values(c: &Cursor): (u16, u16) {
    let Cursor(row, column, _) = c;
    (*row, *column)
}

/// Get the `row` coordinate of the cursor.
public fun row(c: &Cursor): u16 { c.0 }

public use fun col as Cursor.column;

/// Get the `column` coordinate of the cursor.
public fun col(c: &Cursor): u16 { c.1 }

/// Construct a `Cell` from a `Cursor`.
///
/// ```move
/// use grid::cell;
///
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_cell() == cell::new(1, 2));
/// ```
public fun to_cell(c: &Cursor): Cell { cell::new(c.0, c.1) }

/// Convert a `Cursor` to a vector of two values.
/// ```move
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_vector() == vector[1, 2]); // (row, column)
/// ```
public fun to_vector(c: &Cursor): vector<u16> { vector[c.0, c.1] }

/// Construct a `Cursor` from a `Cell`. Alias: `Cell.to_cursor`.
///
/// ```move
/// use grid::cell;
///
/// let cursor = cell::new(1, 2).to_cursor();
/// assert!(cursor == cursor::new(1, 2));
/// ```
public fun from_cell(p: &Cell): Cursor {
    let (row, col) = p.to_values();
    Cursor(row, col, vector[])
}

/// Reset the `Cursor` to a given cell, clears the history.
public fun reset(c: &mut Cursor, row: u16, column: u16) {
    c.0 = row;
    c.1 = column;
    c.2 = vector[]; // resets history!
}

/// Move `Cursor` in a given direction. Aborts if the `Cursor` is out of bounds.
/// Stores the direction in the history.
///
/// ```move
/// use grid::direction;
///
/// let mut cursor = cursor::new(0, 0);
/// cursor.move_to(direction::down!());
/// cursor.move_to(direction::right!() | direction::down!());
/// ```
public fun move_to(c: &mut Cursor, direction: u8) {
    let Cursor(row, col, path) = c;
    if (direction & up!() > 0) {
        assert!(*row > 0, EOutOfBounds);
        *row = *row - 1;
    } else if (direction & down!() > 0) {
        *row = *row + 1;
    };

    if (direction & left!() > 0) {
        assert!(*col > 0, EOutOfBounds);
        *col = *col - 1;
    } else if (direction & right!() > 0) {
        *col = *col + 1;
    };

    path.push_back(direction);
}

/// Move the `Cursor` back to the previous position. Aborts if there is no history.
///
/// ```move
/// use grid::direction;
///
/// let mut cursor = cursor::new(0, 0);
/// cursor.move_to(direction::down!());
/// assert!(cursor.to_vector() == vector[1, 0]);
///
/// cursor.move_back(); // return to the initial position
/// assert!(cursor.to_vector() == vector[0, 0]);
/// ```
public fun move_back(c: &mut Cursor) {
    assert!(c.2.length() > 0, ENoHistory);
    let direction = direction::inverse!(c.2.pop_back());
    c.move_to(direction); // perform move
    c.2.pop_back(); // hacky: remove the direction we just added
}

/// Check if a `Cursor` can move in a given direction. Checks 0-index bounds.
public fun can_move_to(c: &Cursor, direction: u8): bool {
    let Cursor(row, column, _) = c;
    let is_up = direction & up!() > 0;
    let is_left = direction & left!() > 0;
    (is_up && *row > 0 || !is_up) && (is_left && *column > 0 || !is_left)
}

// === Convenience & Compatibility ===

/// Parse bytes (encoded as BCS) into a `Cursor`.
public fun from_bytes(bytes: vector<u8>): Cursor {
    from_bcs(&mut bcs::new(bytes))
}

/// Parse `BCS` bytes into a `Cursor`. Useful when `Cursor` is a field of another
/// struct that is being deserialized from BCS.
public fun from_bcs(bcs: &mut BCS): Cursor {
    Cursor(bcs.peel_u16(), bcs.peel_u16(), bcs.peel_vec!(|bcs| bcs.peel_u8()))
}

/// Print a `Cursor` as a string.
///
/// ```move
///
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_string() == b"[1, 2]".to_string());
/// ```
public fun to_string(p: &Cursor): String {
    p.to_cell().to_string()
}
