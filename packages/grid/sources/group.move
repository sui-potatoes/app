// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Point` type and its methods.
module grid::group;

use grid::point::{Self, Point};

/// A point in 2D space.
public struct Group(vector<Point>) has store, copy, drop;

/// Create a new point.
public fun new(points: vector<Point>): Group { Group(points) }

/// Convert a point to a tuple of two values.
public fun into_values(g: Group): vector<Point> { let Group(points) = g; points }

#[test]
fun test_group() {
    let group = new(vector[point::new(0, 0), point::new(1, 2)]);
    let values = group.into_values();

    assert!(values == vector[ point::new(0, 0), point::new(1, 2) ]);
}
