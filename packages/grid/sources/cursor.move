// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The `Cursor` struct represents a point on the grid, and can be used to move
/// a point in a given direction. It is tightly coupled with the `direction`
/// module, and is used to represent a "moving point" on the grid.
///
/// ```
/// use grid::direction;
///
/// #[test]
/// fun test_cursor() {
///     let mut cursor = direction::new_cursor(0, 0);
///     cursor.move_to(direction::down!());
///     cursor.move_to(direction::down_right!())
///
///     let (x, y) = cursor.to_values();
///     assert!(x == 2 && y == 1);
/// }
/// ```
module grid::cursor;

use grid::{direction::{up, down, left, right}, point::{Self, Point}};
use std::string::String;
use sui::bcs::{Self, BCS};

const EOutOfBounds: u64 = 0;

/// A point on the grid, represented by its X and Y coordinates.
public struct Cursor(u16, u16) has copy, drop, store;

/// Get the X coordinate of the cursor.
public fun new(x: u16, y: u16): Cursor { Cursor(x, y) }

/// Get both coordinates of the cursor.
public fun to_values(c: &Cursor): (u16, u16) {
    let Cursor(x, y) = c;
    (*x, *y)
}

/// Construct a `Point` from a `Cursor`.
public fun to_point(c: &Cursor): Point { point::new(c.0, c.1) }

/// Convert a `Cursor` to a vector of two values.
public fun to_vector(c: &Cursor): vector<u16> { vector[c.0, c.1] }

/// Construct a `Cursor` from a `Point`.
public fun from_point(p: &Point): Cursor {
    let (x, y) = p.to_values();
    Cursor(x, y)
}

/// Reset the cursor to a given point.
public fun reset(c: &mut Cursor, x: u16, y: u16) {
    c.0 = x;
    c.1 = y;
}

/// Move cursor in a given direction. Aborts if the cursor is out of bounds.
public fun move_to(c: &mut Cursor, direction: u8) {
    let Cursor(x, y) = c;
    if (direction & up!() > 0) {
        assert!(*x > 0, EOutOfBounds);
        *x = *x - 1;
    } else if (direction & down!() > 0) {
        *x = *x + 1;
    };

    if (direction & left!() > 0) {
        assert!(*y > 0, EOutOfBounds);
        *y = *y - 1;
    } else if (direction & right!() > 0) {
        *y = *y + 1;
    };
}

/// Check if a cursor can move in a given direction. Checks 0-index bounds.
public fun can_move_to(c: &Cursor, direction: u8): bool {
    let Cursor(x, y) = c;
    let is_up = direction & up!() > 0;
    let is_left = direction & left!() > 0;
    (is_up && *x > 0 || !is_up) && (is_left && *y > 0 || !is_left)
}

// === Convenience & Compatibility ===

/// Parse bytes (encoded as BCS) into a point.
public fun from_bytes(bytes: vector<u8>): Cursor {
    from_bcs(&mut bcs::new(bytes))
}

/// Parse `BCS` bytes into a point. Useful when `Point` is a field of another
/// struct that is being deserialized from BCS.
public fun from_bcs(bcs: &mut BCS): Cursor {
    Cursor(bcs.peel_u16(), bcs.peel_u16())
}

/// Print a point as a string.
public fun to_string(p: &Cursor): String {
    let mut str = b"(".to_string();
    let Cursor(x, y) = *p;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b")");
    str
}
