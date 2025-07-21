// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The `Cursor` struct represents a movable point on the grid, and can be used
/// to trace paths, use the `direction` API and get coordinates for the current
/// position.
///
/// ```move
/// use grid::direction;
/// use grid::cursor;
///
/// #[test]
/// fun test_cursor() {
///     let mut cursor = cursor::new(0, 0);
///     cursor.move_to(direction::down!());
///     cursor.move_to(direction::down!() | direction::right!());
///
///     let (x, y) = cursor.to_values();
///     assert!(x == 2 && y == 1);
/// }
/// ```
///
/// The `Cursor` struct is tightly coupled with the `direction` module. Refer to
/// the `direction` module for more information.
module grid::cursor;

use grid::{direction::{Self, up, down, left, right}, point::{Self, Point}};
use std::string::String;
use sui::bcs::{Self, BCS};

/// Trying to move out of bounds.
const EOutOfBounds: u64 = 0;
/// Trying to move back when there is no history.
const ENoHistory: u64 = 1;

/// Cursor is similar to a `Point` as it stores the coordinates, but also tracks
/// directions where it was moved, so it could be moved back.
public struct Cursor(u16, u16, vector<u8>) has copy, drop, store;

/// Get the X coordinate of the cursor.
public fun new(x: u16, y: u16): Cursor { Cursor(x, y, vector[]) }

/// Get both coordinates of the cursor.
public fun to_values(c: &Cursor): (u16, u16) {
    let Cursor(x, y, _) = c;
    (*x, *y)
}

/// Construct a `Point` from a `Cursor`.
///
/// ```rust
/// use grid::cursor;
/// use grid::point;
///
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_point() == point::new(1, 2));
/// ```
public fun to_point(c: &Cursor): Point { point::new(c.0, c.1) }

/// Convert a `Cursor` to a vector of two values.
/// ```rust
/// use grid::cursor;
///
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_vector() == vector[1, 2]); // (x, y)
/// ```
public fun to_vector(c: &Cursor): vector<u16> { vector[c.0, c.1] }

/// Construct a `Cursor` from a `Point`. Alias: `Point.to_cursor`.
///
/// ```rust
/// use grid::cursor;
/// use grid::point;
///
/// let cursor = point::new(1, 2).to_cursor();
/// assert!(cursor == cursor::new(1, 2));
/// ```
public fun from_point(p: &Point): Cursor {
    let (x, y) = p.to_values();
    Cursor(x, y, vector[])
}

/// Reset the `Cursor` to a given point, clears the history.
public fun reset(c: &mut Cursor, x: u16, y: u16) {
    c.0 = x;
    c.1 = y;
    c.2 = vector[]; // resets history!
}

/// Move `Cursor` in a given direction. Aborts if the `Cursor` is out of bounds.
/// Stores the direction in the history.
///
/// ```rust
/// use grid::cursor;
/// use grid::direction;
///
/// let mut cursor = cursor::new(0, 0);
/// cursor.move_to(direction::down!());
/// cursor.move_to(direction::right!() | direction::down!());
/// ```
public fun move_to(c: &mut Cursor, direction: u8) {
    let Cursor(x, y, path) = c;
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

    path.push_back(direction);
}

/// Move the `Cursor` back to the previous position. Aborts if there is no history.
///
/// ```rust
/// use grid::cursor;
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
    let Cursor(x, y, _) = c;
    let is_up = direction & up!() > 0;
    let is_left = direction & left!() > 0;
    (is_up && *x > 0 || !is_up) && (is_left && *y > 0 || !is_left)
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
/// ```rust
/// use grid::cursor;
///
/// let cursor = cursor::new(1, 2);
/// assert!(cursor.to_string() == b"(1, 2)".to_string());
/// ```
public fun to_string(p: &Cursor): String {
    let mut str = b"(".to_string();
    let Cursor(x, y, _) = *p;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b")");
    str
}
