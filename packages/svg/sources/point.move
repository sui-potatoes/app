// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// This module defines a point in 2D space, it should not be used directly, but
/// is extensively used in the SVG library.
module svg::point;

/// Point struct, represents a point in 2D space.
public struct Point(u16, u16) has copy, drop, store;

/// Create a new point.
public fun point(x: u16, y: u16): Point { Point(x, y) }

/// Move a point to a new location. Recreates the point with the new x and y.
public fun move_to(point: &mut Point, x: u16, y: u16) {
    point.0 = x;
    point.1 = y;
}

/// Get the x and y values of a point.
public fun to_values(point: &Point): (u16, u16) { (point.0, point.1) }
