// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Point` type and its methods. Point is a tuple-like struct that
/// holds two unsigned 16-bit integers, representing the x and y coordinates of
/// a point in 2D space.
module grid::point;

use std::string::String;
use sui::bcs::{Self, BCS};

/// Error code for not implemented functions.
const ENotImplemented: u64 = 264;

/// A point in 2D space.
public struct Point(u16, u16) has copy, drop, store;

/// Create a new point.
public fun new(x: u16, y: u16): Point { Point(x, y) }

/// Create a point from a vector of two values.
public macro fun from_vector($v: vector<u16>): Point {
    let v = $v;
    new(v[0], v[1])
}

/// Get a tuple of two values from a point.
public fun to_values(p: &Point): (u16, u16) { let Point(x, y) = p; (*x, *y) }

/// Convert a point to a tuple of two values.
public fun into_values(p: Point): (u16, u16) { let Point(x, y) = p; (x, y) }

/// Get the x coordinate of a point.
public fun x(p: &Point): u16 { p.0 }

/// Get the y coordinate of a point.
public fun y(p: &Point): u16 { p.1 }

/// Get the Manhattan distance between two points.
///
/// Example:
/// ```rust
/// let (p1, p2) = (new(1, 0), new(4, 3));
/// let range = p1.range(&p2);
///
/// assert!(range == 6);
/// ```
public fun range(p1: &Point, p2: &Point): u16 { p1.0.diff(p2.0) + p1.0.diff(p2.0) }

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

// === Convenience & Compatibility ===

/// Parse bytes (encoded as BCS) into a point.
public fun from_bytes(bytes: vector<u8>): Point {
    from_bcs(&mut bcs::new(bytes))
}

/// Parse `BCS` bytes into a point. Useful when `Point` is a field of another
/// struct that is being deserialized from BCS.
public fun from_bcs(bcs: &mut BCS): Point {
    Point(bcs.peel_u16(), bcs.peel_u16())
}

/// Print a point as a string.
public fun to_string(p: &Point): String {
    let mut str = b"(".to_string();
    let Point(x, y) = *p;
    str.append(x.to_string());
    str.append_utf8(b", ");
    str.append(y.to_string());
    str.append_utf8(b")");
    str
}

#[allow(unused_function)]
/// Get all Moore neighbors of a point. Moore neighborhood is a set of points
/// that are adjacent to the given point. In 2D space, it's the point to the
/// left, right, up, down, and diagonals from the given point.
///
/// ```
///    0 1 2 3 4
/// 0: |2|2|2|2|2|
/// 1: |2|1|1|1|2|
/// 2: |2|1|0|1|2|
/// 3: |2|1|1|1|2|
/// 4: |2|2|2|2|2|
/// ```
fun moore(_p: &Point, _size: u16): vector<Point> {
    abort ENotImplemented
}
