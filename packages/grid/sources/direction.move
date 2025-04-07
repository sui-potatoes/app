// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Direction module provides macros to check the relative positions of points
/// on a grid. Grid axiss are defined as follows:
/// - X-axis: vertical axis (top->down)
/// - Y-axis: horizontal axis (left->right)
///
/// Direction is packed as a bit field in a single byte.
/// - b00000000 - none
/// - b00000001 - up
/// - b00000010 - right
/// - b00000100 - down
/// - b00001000 - left
/// - b00000011 - up | right
/// - b00000101 - up | down
/// - b00001001 - up | left
/// - b00001100 - right | down
///
/// Directions can be combined using bitwise OR.
/// ```
/// use grid::direction;
///
/// #[test]
/// fun test_directions() {
///     let dir = direction::up!() | direction::right!();
///     assert_eq!(dir, direction::up_right!());
/// }
/// ```
module grid::direction;

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

/// Move cursor in a given direction.
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

// === Check Directions ===

/// Check if a point is above another point (decrease in X).
public macro fun is_up($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 > $x1 && $y0 == $y1 }

/// Check if a point is below another point (increase in X).
public macro fun is_down($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 < $x1 && $y0 == $y1 }

/// Check if a point is to the left of another point (decrease in Y).
public macro fun is_left($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 == $x1 && $y0 > $y1 }

/// Check if a point is to the right of another point (increase in Y).
public macro fun is_right($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 == $x1 && $y0 < $y1 }

/// Check if a point is up-right of another point (decrease in X, increase in Y).
public macro fun is_up_right($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool {
    $x0 > $x1 && $y0 < $y1
}

/// Check if a point is down-right of another point (increase in X, increase in Y).
public macro fun is_down_right($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool {
    $x0 < $x1 && $y0 < $y1
}

/// Check if a point is down-left of another point (increase in X, decrease in Y).
public macro fun is_down_left($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool {
    $x0 < $x1 && $y0 > $y1
}

/// Check if a point is up-left of another point (decrease in X, decrease in Y).
public macro fun is_up_left($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool {
    $x0 > $x1 && $y0 > $y1
}

/// Check if a point is on the same tile as another point.
public macro fun is_same_tile($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool {
    $x0 == $x1 && $y0 == $y1
}

// === Constants ===

/// Direction: up
public macro fun up(): u8 { 0 | 1 << 0 }

/// Direction: right
public macro fun right(): u8 { 0 | 1 << 1 }

/// Direction: down
public macro fun down(): u8 { 0 | 1 << 2 }

/// Direction: left
public macro fun left(): u8 { 0 | 1 << 3 }

/// Direction: up & right
public macro fun up_right(): u8 { 0 | 1 << 0 | 1 << 0 }

/// Direction: down & right
public macro fun down_right(): u8 { 0 | 1 << 2 | 1 << 1 }

/// Direction: down & left
public macro fun down_left(): u8 { 0 | 1 << 2 | 1 << 3 }

/// Direction: up & left
public macro fun up_left(): u8 { 0 | 1 << 0 | 1 << 3 }

/// Direction: none
public macro fun none(): u8 { 0 }

// === Determine Direction ===

/// Get the attack direction from point `(x0, y0)` to point `(x1, y1)`.
public macro fun direction($x0: u16, $y0: u16, $x1: u16, $y1: u16): u8 {
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

/// Converts a direction to its ASCII bytestring string representation.
public macro fun direction_to_bytes($direction: u8): vector<u8> {
    match ($direction) {
        0 => b"none",
        1 => b"up",
        2 => b"up_right",
        3 => b"right",
        4 => b"down_right",
        5 => b"down",
        6 => b"down_left",
        7 => b"left",
        8 => b"up_left",
        _ => abort,
    }
}
