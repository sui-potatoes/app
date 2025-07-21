// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The `direction` module provides macros to check the relative positions of
/// points on a grid as well as constants for the directions. Currently, the
/// main consumer of this module is `cursor`.
///
/// Grid axes are defined as follows:
/// - X-axis: vertical axis (top->down)
/// - Y-axis: horizontal axis (left->right)
///
/// Hence, the (0, 0) point is at the top-left corner of the grid.
///
/// Direction is packed as a bit field in a single byte. Diagonals are represented
/// as a combination of two orthogonal directions. For example, `up_right!()` is
/// `up!() | right!()`.
///
/// - `b00000000` - none - 0
/// - `b00000001` - up - 1
/// - `b00000010` - right - 2
/// - `b00000100` - down - 4
/// - `b00001000` - left - 8
/// - `b00000011` - up | right - 3
/// - `b00000110` - right | down - 6
/// - `b00001100` - down | left - 12
/// - `b00001001` - up | left - 9
///
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
module grid::direction;

use std::macros::{num_min, num_diff};

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

/// Check if a point is equal to another point.
public macro fun is_equal<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
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

/// Direction: up | right
/// Can be represented as `up!() | right!()`.
public macro fun up_right(): u8 { up!() | right!() }

/// Direction: down | right
/// Can be represented as `down!() | right!()`.
public macro fun down_right(): u8 { down!() | right!() }

/// Direction: down | left
/// Can be represented as `down!() | left!()`.
public macro fun down_left(): u8 { down!() | left!() }

/// Direction: up | left
/// Can be represented as `up!() | left!()`.
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

/// Get the direction from point `(x0, y0)` to point `(x1, y1)`.
/// For convenience, takes any integer type, but `Grid` uses `u16`.
///
/// ```rust
/// use grid::direction;
///
/// #[test]
/// fun test_direction() {
///     let dir = direction::direction!(0, 0, 1, 0);
///     assert_eq!(dir, direction::right!());
/// }
/// ```
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
