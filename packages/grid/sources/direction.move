// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Direction module provides macros to check the relative positions of points
/// on a grid. Additionally, it provides a `Cursor` struct to represent a cursor
/// on a grid which can be moved using the `move_to` function.
///
/// Grid axes are defined as follows:
/// - X-axis: vertical axis (top->down)
/// - Y-axis: horizontal axis (left->right)
///
/// Direction is packed as a bit field in a single byte.
/// - `b00000000` - none - 0
/// - `b00000001` - up - 1
/// - `b00000010` - right - 2
/// - `b00000100` - down - 4
/// - `b00001000` - left - 8
/// - `b00000011` - up | right - 3
/// - `b00000110` - right | down - 6
/// - `b00001100` - down | left - 12
/// - `b00001001` - up | left - 9
/// Directions can be combined using bitwise OR or checked using bitwise AND.
/// ```
/// use grid::direction;
///
/// #[test]
/// fun test_directions() {
///     let dir = direction::up!() | direction::right!();
///     assert_eq!(dir, direction::up_right!());
///
///     let is_left = direction::up_left!() & direction::left!() > 0;
///     assert!(is_left);
/// }
/// ```
///
/// The `Cursor` struct represents a point on the grid, and can be used to move
/// a point in a given direction.
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
module grid::direction;

use grid::point::{Self, Point};
use std::macros::{num_min, num_diff};

const EOutOfBounds: u64 = 0;

/// A point on the grid, represented by its X and Y coordinates.
public struct Cursor(u16, u16) has copy, drop, store;

/// Get the X coordinate of the cursor.
public fun new_cursor(x: u16, y: u16): Cursor { Cursor(x, y) }

public use fun cursor_to_values as Cursor.to_values;

/// Get both coordinates of the cursor.
public fun cursor_to_values(c: &Cursor): (u16, u16) {
    let Cursor(x, y) = c;
    (*x, *y)
}

public use fun cursor_to_point as Cursor.to_point;

/// Construct a `Point` from a `Cursor`.
public fun cursor_to_point(c: &Cursor): Point {
    point::new(c.0, c.1)
}

/// Construct a `Cursor` from a `Point`.
public fun cursor_from_point(p: &Point): Cursor {
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

// === Check Directions ===

/// Check if a point is above another point (decrease in X).
public macro fun is_up<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 > $x1 && $y0 == $y1
}

/// Check if a point is below another point (increase in X).
public macro fun is_down<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 < $x1 && $y0 == $y1
}

/// Check if a point is to the left of another point (decrease in Y).
public macro fun is_left<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 > $y1
}

/// Check if a point is to the right of another point (increase in Y).
public macro fun is_right<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 < $y1
}

/// Check if a point is up-right of another point (decrease in X, increase in Y).
public macro fun is_up_right<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 > $x1 && $y0 < $y1
}

/// Check if a point is down-right of another point (increase in X, increase in Y).
public macro fun is_down_right<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 < $x1 && $y0 < $y1
}

/// Check if a point is down-left of another point (increase in X, decrease in Y).
public macro fun is_down_left<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 < $x1 && $y0 > $y1
}

/// Check if a point is up-left of another point (decrease in X, decrease in Y).
public macro fun is_up_left<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 > $x1 && $y0 > $y1
}

/// Check if a point is on the same tile as another point.
public macro fun is_same_tile<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 == $y1
}

// === Constants ===

/// Direction: up
public macro fun up(): u8 { 1 << 0 }

/// Direction: right
public macro fun right(): u8 { 1 << 1 }

/// Direction: down
public macro fun down(): u8 { 1 << 2 }

/// Direction: left
public macro fun left(): u8 { 1 << 3 }

/// Direction: up & right
public macro fun up_right(): u8 { up!() | right!() }

/// Direction: down & right
public macro fun down_right(): u8 { down!() | right!() }

/// Direction: down & left
public macro fun down_left(): u8 { down!() | left!() }

/// Direction: up & left
public macro fun up_left(): u8 { up!() | left!() }

/// Direction: none
public macro fun none(): u8 { 0 }

/// Get the inverse direction of a given direction.
public macro fun inverse($direction: u8): u8 {
    match ($direction) {
        1 => down!(),
        2 => left!(),
        4 => up!(),
        8 => right!(),
        3 => down!() | left!(),
        9 => down!() | right!(),
        6 => up!() | left!(),
        12 => up!() | right!(),
        _ => abort,
    }
}
// === Determine Direction ===

/// Get the attack direction from point `(x0, y0)` to point `(x1, y1)`.
/// For convenience, takes any integer type, but `Grid` uses `u16`.
public macro fun direction<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): u8 {
    let diff_x = num_diff!($x0, $x1);
    let diff_y = num_diff!($y0, $y1);

    // same tile, one of the axis matches or one dominates
    if (diff_x == 0 && diff_y == 0) return none!();

    let x_direction = if ($x0 < $x1) down!()
    else if ($x0 > $x1) up!()
    else none!();

    let y_direction = if ($y0 < $y1) right!()
    else if ($y0 > $y1) left!()
    else none!();

    if (x_direction == none!() || diff_y > diff_x) return y_direction;
    if (y_direction == none!() || diff_x > diff_y) return x_direction;

    x_direction | y_direction // diagonals
}
