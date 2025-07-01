// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Point` type and its methods. Point is a tuple-like struct that
/// holds two unsigned 16-bit integers, representing the x and y coordinates of
/// a point in 2D space.
module grid::point;

use std::{macros::{num_diff, num_max}, string::String};
use sui::bcs::{Self, BCS};

public use fun grid::cursor::from_point as Point.to_cursor;

/// A point in 2D space. A row (x) and a column (y).
public struct Point(u16, u16) has copy, drop, store;

/// Create a new `Point` at `(x, y)`.
public fun new(x: u16, y: u16): Point { Point(x, y) }

/// Create a `Point` from a vector of two values.
/// Ignores the rest of the values in the vector.
public fun from_vector(v: vector<u16>): Point {
    Point(v[0], v[1])
}

/// Get a tuple of two values from a `Point`.
public fun to_values(p: &Point): (u16, u16) { let Point(x, y) = p; (*x, *y) }

/// Unpack a `Point` into a tuple of two values.
public fun into_values(p: Point): (u16, u16) { let Point(x, y) = p; (x, y) }

/// Convert a `Point` to a vector of two values.
public fun to_vector(p: &Point): vector<u16> { vector[p.0, p.1] }

/// Get the `x` coordinate of a `Point`. On the `Grid`, this is the row.
public fun x(p: &Point): u16 { p.0 }

/// Get the `y` coordinate of a `Point`. On the `Grid`, this is the column.
public fun y(p: &Point): u16 { p.1 }

/// Returns whether the point is within the given bounds: `rows` and `cols`,
/// mapping to `height` (x) and `width` (y).
public fun is_within_bounds(p: &Point, rows: u16, cols: u16): bool {
    p.0 < rows && p.1 < cols
}

/// Get the Manhattan distance between two points. Manhattan distance is the
/// sum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```rust
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let range = p1.range(&p2);
///
/// assert!(range == 6);
/// ```
public fun manhattan_distance(p1: &Point, p2: &Point): u16 {
    num_diff!(p1.0, p2.0) + num_diff!(p1.1, p2.1)
}

/// Get the Chebyshev distance between two points. Chebyshev distance is the
/// maximum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```rust
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let range = p1.range(&p2);
///
/// assert!(range == 3);
/// ```
public fun chebyshev_distance(p1: &Point, p2: &Point): u16 {
    num_max!(num_diff!(p1.0, p2.0), num_diff!(p1.1, p2.1))
}

/// Get all von Neumann neighbors of a point within a given range. Von Neumann
/// neighborhood is a set of points that are adjacent to the given point. In 2D
/// space, it's the point to the left, right, up, and down from the given point.
///
/// The `size` parameter determines the range of the neighborhood. For example,
/// if `size` is 1, the function will return the immediate neighbors of the
/// point. If `size` is 2, the function will return the neighbors of the
/// neighbors, and so on.
///
/// Note: does not include the point itself!
/// ```
///     0 1 2 3 4
/// 0: | | |2| | |
/// 1: | |2|1|2| |
/// 2: |2|1|0|1|2|
/// 3: | |3|1|2| |
/// 4: | | |2| | |
/// ```
public fun von_neumann(p: &Point, size: u16): vector<Point> {
    if (size == 0) return vector[];

    let mut neighbors = vector[];
    let Point(x, y) = *p;

    size.do!(|i| {
        let i = i + 1;
        neighbors.push_back(Point(x + i, y));
        neighbors.push_back(Point(x, y + i));
        if (x >= i) neighbors.push_back(Point(x - i, y));
        if (y >= i) neighbors.push_back(Point(x, y - i));

        // add diagonals if i > 1
        if (i > 1) {
            let i = i - 1;
            neighbors.push_back(Point(x + i, y + i));
            if (x >= i) neighbors.push_back(Point(x - i, y + i));
            if (y >= i) neighbors.push_back(Point(x + i, y - i));
            if (x >= i && y >= i) neighbors.push_back(Point(x - i, y - i));
        }
    });

    neighbors
}

/// Get all Moore neighbors of a point. Moore neighborhood is a set of points
/// that are adjacent to the given point. In 2D space, it's the point to the
/// left, right, up, down, and diagonals from the given point.
///
/// The `size` parameter determines the range of the neighborhood. For example,
/// if `size` is 1, the function will return the immediate neighbors of the
/// point. If `size` is 2, the function will return the neighbors of the
/// neighbors, and so on.
///
/// Note: does not include the point itself!
/// ```
///    0 1 2 3 4
/// 0: |2|2|2|2|2|
/// 1: |2|1|1|1|2|
/// 2: |2|1|0|1|2|
/// 3: |2|1|1|1|2|
/// 4: |2|2|2|2|2|
/// ```
public fun moore(p: &Point, size: u16): vector<Point> {
    if (size == 0) return vector[];

    let mut neighbors = vector[];
    let Point(x, y) = *p;

    size.do!(|i| {
        let i = i + 1;
        neighbors.push_back(Point(x + i, y));
        neighbors.push_back(Point(x, y + i));

        if (x >= i) neighbors.push_back(Point(x - i, y));
        if (y >= i) neighbors.push_back(Point(x, y - i));

        // top left
        if (x >= i && y >= i) neighbors.push_back(Point(x - i, y - i));
        // top right
        if (x >= i) neighbors.push_back(Point(x - i, y + i));
        // bottom left
        if (y >= i) neighbors.push_back(Point(x + i, y - i));
        // bottom right
        neighbors.push_back(Point(x + i, y + i));
    });

    neighbors
}

// === Convenience & Compatibility ===

/// Compare two points. To be used in sorting macros. Returns less or equal,
/// based on the x coordinate (1st) and then the y coordinate (2nd).
public fun le(a: &Point, b: &Point): bool {
    (a.0 == b.0 && a.1 <= b.1) || a.0 < b.0
}

/// Serialize a `Point` into BCS bytes.
public fun to_bytes(p: &Point): vector<u8> {
    bcs::to_bytes(p)
}

/// Construct a `Point` from BCS bytes.
public fun from_bytes(bytes: vector<u8>): Point {
    from_bcs(&mut bcs::new(bytes))
}

/// Construct a `Point` from `BCS` bytes wrapped in a `BCS` struct.
/// Useful, when `Point` is a field of another struct that is being
/// deserialized from BCS.
public fun from_bcs(bcs: &mut BCS): Point {
    Point(bcs.peel_u16(), bcs.peel_u16())
}

/// Print a point as a `String`.
public fun to_string(p: &Point): String {
    let mut str = b"(".to_string();
    let Point(x, y) = *p;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b")");
    str
}
