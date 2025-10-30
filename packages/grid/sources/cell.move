// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Cell` type and its methods. Cell is a tuple-like struct that
/// holds two unsigned 16-bit integers, representing the row and column of a
/// cell in 2D space.
module grid::cell;

use std::{macros::{num_diff, num_max}, string::String};
use sui::bcs::{Self, BCS};

public use fun grid::cursor::from_cell as Cell.to_cursor;

/// A cell in 2D space. A row and a column.
public struct Cell(u16, u16) has copy, drop, store;

/// Create a new `Cell` at `(row, column)`.
public fun new(row: u16, column: u16): Cell { Cell(row, column) }

/// Create a `Cell` from a vector of two values.
/// Ignores the rest of the values in the vector.
public fun from_vector(v: vector<u16>): Cell {
    Cell(v[0], v[1])
}

/// Get a tuple of two values from a `Cell`.
public fun to_values(p: &Cell): (u16, u16) { let Cell(row, column) = p; (*row, *column) }

/// Unpack a `Cell` into a tuple of two values.
public fun into_values(p: Cell): (u16, u16) { let Cell(row, column) = p; (row, column) }

/// Convert a `Cell` to a vector of two values.
public fun to_vector(p: &Cell): vector<u16> { vector[p.0, p.1] }

/// Convert a `Cell` to world coordinates: (x, y) -> (column, row).
public fun to_world(p: &Cell): (u16, u16) { (p.1, p.0) }

/// Get the `row` of a `Cell`. In world coordinates, this is the y coordinate.
public fun row(p: &Cell): u16 { p.0 }

/// Get the `column` of a `Cell`. In world coordinates, this is the x coordinate.
public fun col(p: &Cell): u16 { p.1 }

/// Returns whether the cell is within the given bounds: `rows` and `cols`,
/// mapping to `height` (row) and `width` (column).
public fun is_within_bounds(p: &Cell, rows: u16, cols: u16): bool {
    p.0 < rows && p.1 < cols
}

/// Get the Manhattan distance between two cells. Manhattan distance is the
/// sum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```move
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let range = p1.range(&p2);
///
/// assert!(range == 6);
/// ```
public fun manhattan_distance(p1: &Cell, p2: &Cell): u16 {
    num_diff!(p1.0, p2.0) + num_diff!(p1.1, p2.1)
}

/// Get the Chebyshev distance between two cells. Chebyshev distance is the
/// maximum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```move
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let range = p1.range(&p2);
///
/// assert!(range == 3);
/// ```
public fun chebyshev_distance(p1: &Cell, p2: &Cell): u16 {
    num_max!(num_diff!(p1.0, p2.0), num_diff!(p1.1, p2.1))
}

/// Get the Euclidean distance between two cells. Euclidean distance is the
/// square root of the sum of the squared differences of the x and y coordinates.
///
/// Example:
/// ```move
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let distance = p1.euclidean_distance(&p2);
///
/// assert!(distance == 5);
/// ```
public fun euclidean_distance(p1: &Cell, p2: &Cell): u16 {
    let xd = num_diff!(p1.0, p2.0);
    let yd = num_diff!(p1.1, p2.1);
    (xd * xd + yd * yd).sqrt()
}

/// Get all von Neumann neighbors of a cell within a given range. Von Neumann
/// neighborhood is a set of cells that are adjacent to the given cell. In 2D
/// space, it's the cell to the left, right, up, and down from the given cell.
///
/// The `size` parameter determines the range of the neighborhood. For example,
/// if `size` is 1, the function will return the immediate neighbors of the
/// cell. If `size` is 2, the function will return the neighbors of the
/// neighbors, and so on.
///
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
public fun von_neumann(p: &Cell, size: u16): vector<Cell> {
    if (size == 0) return vector[];

    let mut neighbors = vector[];
    let Cell(xc, yc) = *p;

    if (size == 1) {
        if (xc > 0) neighbors.push_back(Cell(xc - 1, yc));
        if (yc > 0) neighbors.push_back(Cell(xc, yc - 1));
        neighbors.push_back(Cell(xc + 1, yc));
        neighbors.push_back(Cell(xc, yc + 1));
        return neighbors
    };

    if (size == 2) {
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

    let (x0, y0) = (xc - size.min(xc), yc - size.min(yc));
    let (x1, y1) = (xc + size, yc + size);

    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        if (x == xc && y == yc) return;
        let distance = num_diff!(x, xc) + num_diff!(y, yc);
        if (distance <= size) neighbors.push_back(Cell(x, y));
    }));

    neighbors
}

/// Get all Moore neighbors of a cell. Moore neighborhood is a set of cells
/// that are adjacent to the given cell. In 2D space, it's the cell to the
/// left, right, up, down, and diagonals from the given cell.
///
/// The `size` parameter determines the range of the neighborhood. For example,
/// if `size` is 1, the function will return the immediate neighbors of the
/// cell. If `size` is 2, the function will return the neighbors of the
/// neighbors, and so on.
///
/// Note: does not include the cell itself!
/// ```
///    0 1 2 3 4
/// 0: |2|2|2|2|2|
/// 1: |2|1|1|1|2|
/// 2: |2|1|0|1|2|
/// 3: |2|1|1|1|2|
/// 4: |2|2|2|2|2|
/// ```
public fun moore(p: &Cell, size: u16): vector<Cell> {
    if (size == 0) return vector[];

    let mut neighbors = vector[];
    let Cell(xc, yc) = *p;

    let (x0, y0) = (xc - size.min(xc), yc - size.min(yc));
    let (x1, y1) = (xc + size, yc + size);

    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        if (x != xc || y != yc) neighbors.push_back(Cell(x, y));
    }));

    neighbors
}

// === Convenience & Compatibility ===

/// Compare two cells. To be used in sorting macros. Returns less or equal,
/// based on the `x` coordinate (1st) and then the `y` coordinate (2nd).
public fun le(a: &Cell, b: &Cell): bool {
    (a.0 == b.0 && a.1 <= b.1) || a.0 < b.0
}

/// Serialize a `Cell` into BCS bytes.
public fun to_bytes(p: &Cell): vector<u8> {
    bcs::to_bytes(p)
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
public fun to_string(p: &Cell): String {
    let mut str = b"[".to_string();
    let Cell(x, y) = *p;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b"]");
    str
}
