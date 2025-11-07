// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Cell` type and its methods. Cell is a tuple-like struct that
/// holds two unsigned 16-bit integers, representing the row and column of a
/// cell in 2D space.
module grid::cell;

use grid::direction;
use std::{macros::{num_diff, num_max}, string::String};
use sui::bcs::{Self, BCS};

public use fun grid::cursor::from_cell as Cell.to_cursor;

/// A cell in 2D space. A row and a column.
/// Note: `row` and `column` map to world coordinates `y` and `x` respectively.
///
/// ```move
/// use grid::cell;
///
/// let cell = cell::new(2, 5);
/// assert!(cell.row() == 2);
/// assert!(cell.col() == 5);
/// ```
public struct Cell(u16, u16) has copy, drop, store;

/// Create a new `Cell` at `(row, column)`.
public fun new(row: u16, column: u16): Cell { Cell(row, column) }

/// Create a `Cell` from a vector of two values.
/// Ignores the rest of the values in the vector.
public fun from_vector(v: vector<u16>): Cell { Cell(v[0], v[1]) }

/// Create a `Cell` from world coordinates `x` and `y`.
public fun from_world(x: u16, y: u16): Cell { Cell(y, x) }

/// Get a tuple of two values from a `Cell`.
public fun to_values(c: &Cell): (u16, u16) { (c.0, c.1) }

/// Convert a `Cell` to a vector of two values.
public fun to_vector(c: &Cell): vector<u16> { vector[c.0, c.1] }

/// Convert a `Cell` to world coordinates: (x, y) -> (column, row).
public fun to_world(c: &Cell): (u16, u16) { (c.1, c.0) }

/// Get the `row` of a `Cell`. In world coordinates, this is the y coordinate.
public fun row(c: &Cell): u16 { c.0 }

/// Alias for `col`.
public use fun col as Cell.column;

/// Get the `column` of a `Cell`. In world coordinates, this is the x coordinate.
public fun col(c: &Cell): u16 { c.1 }

/// Returns whether the cell is within the given bounds: `rows` and `cols`,
/// mapping to `height` (row) and `width` (column).
public fun is_within_bounds(c: &Cell, rows: u16, cols: u16): bool {
    c.0 < rows && c.1 < cols
}

/// Get the Taxicab L1 distance between two cells.
/// Alias for `manhattan_distance`.
public use fun manhattan_distance as Cell.l1_distance;

/// Get the L1 / Manhattan distance between two cells. Manhattan distance is the
/// sum of the absolute differences of the x and y coordinates.
///
/// Represents distance in 4-directional movement.
///
/// Example:
/// ```move
/// let (c1, c2) = (new(1, 0), new(4, 3));
/// let range = c1.range(&c2);
///
/// assert!(range == 6);
/// ```
public fun manhattan_distance(c1: &Cell, c2: &Cell): u16 {
    num_diff!(c1.0, c2.0) + num_diff!(c1.1, c2.1)
}

/// Get the L-Infinity distance between two cells.
/// Alias for `chebyshev_distance`.
public use fun chebyshev_distance as Cell.linf_distance;

/// Get the L-Infinity / Chebyshev distance between two cells. Chebyshev distance
/// is the maximum of the absolute differences of the x and y coordinates.
///
/// Represents distance in 8-directional movement.
/// Also known as the "King" distance.
///
/// Example:
/// ```move
/// let (c1, c2) = (new(1, 0), new(4, 3));
/// let range = c1.range(&c2);
///
/// assert!(range == 3);
/// ```
public fun chebyshev_distance(c1: &Cell, c2: &Cell): u16 {
    num_max!(num_diff!(c1.0, c2.0), num_diff!(c1.1, c2.1))
}

/// Get the Euclidean distance between two cells. Euclidean distance is the
/// square root of the sum of the squared differences of the x and y coordinates.
/// The value is rounded down to the nearest integer.
///
/// Example:
/// ```move
/// let (c1, c2) = (new(1, 0), new(4, 3));
/// let distance = c1.euclidean_distance(&c2);
///
/// assert!(distance == 5);
/// ```
public fun euclidean_distance(c1: &Cell, c2: &Cell): u16 {
    let dx = num_diff!(c1.0, c2.0) as u32;
    let dy = num_diff!(c1.1, c2.1) as u32;
    (dx * dx + dy * dy).sqrt() as u16
}

/// Alias for `von_neumann_neighbors`.
public use fun von_neumann_neighbors as Cell.manhattan_neighbors;

/// Get all neighbors of a cell within a given L1 / Chebyshev distance.
///
/// Example for distance=2:
/// ```
///     0 1 2 3 4
/// 0: | | |2| | |
/// 1: | |2|1|2| |
/// 2: |2|1|0|1|2|
/// 3: | |3|1|2| |
/// 4: | | |2| | |
/// ```
///
/// Note: does not include the cell itself!
public fun von_neumann_neighbors(c: &Cell, distance: u16): vector<Cell> {
    if (distance == 0) return vector[];

    let mut neighbors = vector[];
    let Cell(xc, yc) = *c;

    if (distance == 1) {
        if (xc > 0) neighbors.push_back(Cell(xc - 1, yc));
        if (yc > 0) neighbors.push_back(Cell(xc, yc - 1));
        neighbors.push_back(Cell(xc + 1, yc));
        neighbors.push_back(Cell(xc, yc + 1));
        return neighbors
    };

    if (distance == 2) {
        if (xc > 1) neighbors.push_back(Cell(xc - 2, yc));
        if (yc > 1) neighbors.push_back(Cell(xc, yc - 2));
        if (xc > 0) neighbors.push_back(Cell(xc - 1, yc));
        if (yc > 0) neighbors.push_back(Cell(xc, yc - 1));
        neighbors.push_back(Cell(xc + 1, yc));
        neighbors.push_back(Cell(xc, yc + 1));
        neighbors.push_back(Cell(xc + 2, yc));
        neighbors.push_back(Cell(xc, yc + 2));

        // do diagonals
        if (xc > 0 && yc > 0) neighbors.push_back(Cell(xc - 1, yc - 1));
        if (xc > 0) neighbors.push_back(Cell(xc - 1, yc + 1));
        if (yc > 0) neighbors.push_back(Cell(xc + 1, yc - 1));
        neighbors.push_back(Cell(xc + 1, yc + 1));

        return neighbors
    };

    let (x0, y0) = (xc - distance.min(xc), yc - distance.min(yc));
    let (x1, y1) = (xc + distance, yc + distance);

    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        if (x == xc && y == yc) return;
        let l1_distance = num_diff!(x, xc) + num_diff!(y, yc);
        if (l1_distance <= distance) neighbors.push_back(Cell(x, y));
    }));

    neighbors
}

/// Alias for `moore_neighbors`.
public use fun moore_neighbors as Cell.chebyshev_neighbors;

/// Get all `Cell`s within the given L-Infinity distance. Also known as Moore
/// neighborhood.
/// Does not include the starting `Cell` c.
///
/// Example for distance=2:
/// ```
///    0 1 2 3 4
/// 0: |2|2|2|2|2|
/// 1: |2|1|1|1|2|
/// 2: |2|1|0|1|2|
/// 3: |2|1|1|1|2|
/// 4: |2|2|2|2|2|
/// ```
public fun moore_neighbors(c: &Cell, distance: u16): vector<Cell> {
    if (distance == 0) return vector[];

    let mut neighbors = vector[];
    let Cell(xc, yc) = *c;

    let (x0, y0) = (xc - distance.min(xc), yc - distance.min(yc));
    let (x1, y1) = (xc + distance, yc + distance);

    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        if (x != xc || y != yc) neighbors.push_back(Cell(x, y));
    }));

    neighbors
}

// === Direction API ===

/// Get the relative direction of `c1` to `c0`.
///
/// Example:
/// ```move
/// use grid::cell;
/// use grid::direction;
///
/// let c0 = cell::new(0, 0);
/// let c1 = cell::new(2, 0);
/// let c2 = cell::new(2, 2);
///
/// // direction from `c0` to `c1` is `down`
/// assert!(c0.direction_to(&c1) & direction::down!() > 0);
///
/// // direction from `c0` to `c2` is `down-right`
/// assert!(c0.direction_to(&c2) & direction::down_right!() > 0);
/// ```
public fun direction_to(c0: &Cell, c1: &Cell): u8 {
    direction::direction!(c0.0, c0.1, c1.0, c1.1)
}

// === Convenience & Compatibility ===

/// Compare two cells. To be used in sorting macros. Returns less or equal,
/// based on the `x` coordinate (1st) and then the `y` coordinate (2nd).
public fun le(a: &Cell, b: &Cell): bool {
    (a.0 == b.0 && a.1 <= b.1) || a.0 < b.0
}

/// Serialize a `Cell` into BCS bytes.
public fun to_bytes(c: &Cell): vector<u8> {
    bcs::to_bytes(c)
}

/// Construct a `Cell` from BCS bytes.
public fun from_bytes(bytes: vector<u8>): Cell {
    from_bcs(&mut bcs::new(bytes))
}

/// Construct a `Cell` from `BCS` bytes wrapped in a `BCS` struct.
/// Useful, when `Cell` is a field of another struct that is being
/// deserialized from BCS.
public fun from_bcs(bcs: &mut BCS): Cell {
    Cell(bcs.peel_u16(), bcs.peel_u16())
}

/// Print a `Cell` as a `String`.
public fun to_string(c: &Cell): String {
    let mut str = b"[".to_string();
    let Cell(x, y) = *c;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b"]");
    str
}
