// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The `direction` module provides macros to check the relative positions of
/// cells on a grid as well as constants for the directions. Currently, the
/// main consumer of this module is `cursor`.
///
/// Grid axes are defined as follows:
/// - X-axis: horizontal axis (left->right)
/// - Y-axis: vertical axis (top->down)
///
/// Hence, the (0, 0) cell is at the top-left corner of the grid.
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
/// ```move
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

/// Check if direction from `Cell0` to `Cell1` is up.
public macro fun is_up<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 > $row1 && $col0 == $col1
}

/// Check if direction from `Cell0` to `Cell1` is down.
public macro fun is_down<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 < $row1 && $col0 == $col1
}

/// Check if direction from `Cell0` to `Cell1` is left.
public macro fun is_left<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 > $col1
}

/// Check if direction from `Cell0` to `Cell1` is right.
public macro fun is_right<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 < $col1
}

/// Check if direction from `Cell0` to `Cell1` is up-right.
public macro fun is_up_right<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 > $row1 && $col0 < $col1
}

/// Check if direction from `Cell0` to `Cell1` is down-right.
public macro fun is_down_right<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 < $row1 && $col0 < $col1
}

/// Check if direction from `Cell0` to `Cell1` is down-left.
public macro fun is_down_left<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 > $row1 && $col0 < $col1
}

/// Check if direction from `Cell0` to `Cell1` is up-left.
public macro fun is_up_left<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 > $row1 && $col0 > $col1
}

/// Check if position of `Cell0` to `Cell1` is the same.
public macro fun is_equal<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 == $col1
}

// === Direction Checks ===

/// Validate `u8` direction input.
public macro fun is_direction_valid($d: u8): bool {
    if ($d & up!() > 0 && $d & down!() > 0) return false
    else if ($d & left!() > 0 && $d & right!() > 0) return false
    else true
}

/// Check whether given `u8` direction is vertical: up or down.
public macro fun is_direction_vertical($d: u8): bool { $d == up!() || $d == down!() }

/// Check whether given `u8` direction is horizontal: left or right.
public macro fun is_direction_horizontal($d: u8): bool { $d == left!() || $d == right!() }

/// Check whether given `u8` direction is diagonal.
public macro fun is_direction_diagonal($d: u8): bool {
    $d == up_right!() || $d == up_left!() || $d == down_right!() || $d == down_left!()
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

/// Get the inverse of a given direction.
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

/// Get the direction from cell `(x0, y0)` to cell `(x1, y1)`.
/// For convenience, takes any integer type, but `Grid` uses `u16`.
///
/// ```move
/// use grid::direction;
///
/// #[test]
/// fun test_direction() {
///     let dir = direction::direction!(0, 0, 1, 0);
///     assert_eq!(dir, direction::right!());
/// }
/// ```
public macro fun direction<$T: drop>($row0: $T, $col0: $T, $row1: $T, $col1: $T): u8 {
    let diff_x = num_diff!($row0, $row1);
    let diff_y = num_diff!($col0, $col1);

    // same tile, one of the axis matches or one dominates
    if (diff_x == 0 && diff_y == 0) return none!();

    let horizontal_direction = if ($row0 < $row1) down!()
    else if ($row0 > $row1) up!()
    else none!();

    let vertical_direction = if ($col0 < $col1) right!()
    else if ($col0 > $col1) left!()
    else none!();

    if (horizontal_direction == none!() || diff_y > diff_x) return vertical_direction;
    if (vertical_direction == none!() || diff_x > diff_y) return horizontal_direction;

    horizontal_direction | vertical_direction // diagonals
}
