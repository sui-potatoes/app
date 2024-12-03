// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Point` type and its methods.
module grid::point;

/// A point in 2D space.
public struct Point(u16, u16) has copy, drop, store;

/// Create a new point.
public fun new(x: u16, y: u16): Point { Point(x, y) }

/// Convert a point to a tuple of two values.
public fun into_values(p: Point): (u16, u16) { let Point(x, y) = p; (x, y) }

/// Get the x coordinate of a point.
public fun x(p: &Point): u16 { p.0 }

/// Get the y coordinate of a point.
public fun y(p: &Point): u16 { p.1 }

/// Get all von Neumann neighbours of a point. Von Neumann neighbourhood is a
/// set of points that are adjacent to the given point. In 2D space, it's the
/// point to the left, right, up, and down from the given point.
public fun von_neumann(p: &Point): vector<Point> {
    let Point(x, y) = *p;
    let mut neighbours = vector[Point(x + 1, y), Point(x, y + 1)];

    if (x > 0) neighbours.push_back(Point(x - 1, y));
    if (y > 0) neighbours.push_back(Point(x, y - 1));

    neighbours
}

#[test]
fun test_point() {
    let p = new(1, 2);
    assert!(p.x() == 1);
    assert!(p.y() == 2);

    let (x, y) = p.into_values();
    assert!(x == 1);
    assert!(y == 2);
}
