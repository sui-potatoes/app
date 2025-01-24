// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Point` type and its methods.
module grid::point;

/// Error code for not implemented functions.
const ENotImplemented: u64 = 264;

/// A point in 2D space.
public struct Point(u16, u16) has copy, drop, store;

/// Create a new point.
public fun new(x: u16, y: u16): Point { Point(x, y) }

/// Create a point from a vector of two values.
public macro fun from_vector($v: vector<u16>): Point {
    let v = $v;
    let y = v.pop_back();
    let x = v.pop_back();
    new(x, y)
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
public fun range(p1: &Point, p2: &Point): u16 { p1.0.diff(p2.0) + p1.0.diff(p2.0) }

/// Get all von Neumann neighbours of a point. Von Neumann neighbourhood is a
/// set of points that are adjacent to the given point. In 2D space, it's the
/// point to the left, right, up, and down from the given point.
///
/// Note: does not include the point itself.
///
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

    let mut neighbours = vector[];
    let Point(x, y) = *p;

    size.do!(|i| {
        let i = i + 1;
        neighbours.push_back(Point(x + i, y));
        neighbours.push_back(Point(x, y + i));
        if (x >= i) neighbours.push_back(Point(x - i, y));
        if (y >= i) neighbours.push_back(Point(x, y - i));

        // add diagonals if i > 1
        if (i > 1) {
            let i = i - 1;
            neighbours.push_back(Point(x + i, y + i));
            if (x >= i) neighbours.push_back(Point(x - i, y + i));
            if (y >= i) neighbours.push_back(Point(x + i, y - i));
            if (x >= i && y >= i) neighbours.push_back(Point(x - i, y - i));
        }
    });

    neighbours
}

/// Get all Moore neighbours of a point. Moore neighbourhood is a set of points
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
public fun moore(_p: &Point, _size: u16): vector<Point> {
    abort ENotImplemented
}

#[test]
fun test_point() {
    let p = new(1, 2);
    assert!(p.x() == 1);
    assert!(p.y() == 2);

    let (_, _) = p.to_values();
    let (x, y) = p.into_values();
    assert!(x == 1);
    assert!(y == 2);
}

#[test]
fun test_von_neumann() {
    let p = new(1, 1);
    assert!(p.von_neumann(0) == vector[]);

    let n = p.von_neumann(1);
    assert!(n.contains(&new(1, 0)));
    assert!(n.contains(&new(0, 1)));
    assert!(n.contains(&new(2, 1)));
    assert!(n.contains(&new(1, 2)));
    assert!(n.length() == 4);

    //     0 1 2 3 4
    // 0: | | |2| | |
    // 1: | |2|1|2| |
    // 2: |2|1|0|1|2|
    // 3: | |3|1|2| |
    // 4: | | |2| | |

    let n = new(2, 2).von_neumann(2);
    assert!(n.contains(&new(0, 2))); // 0
    assert!(n.contains(&new(1, 1))); // 1
    assert!(n.contains(&new(1, 2))); // 1
    assert!(n.contains(&new(1, 3))); // 1
    assert!(n.contains(&new(2, 0))); // 2
    assert!(n.contains(&new(2, 1))); // 2
    assert!(n.contains(&new(2, 3))); // 2
    assert!(n.contains(&new(2, 4))); // 2
    assert!(n.contains(&new(3, 1))); // 3
    assert!(n.contains(&new(3, 2))); // 3
    assert!(n.contains(&new(3, 3))); // 3
    assert!(n.contains(&new(4, 2))); // 4
    assert!(n.length() == 12);
}

#[test, expected_failure]
fun test_moore() {
    let p = new(1, 1);
    assert!(p.moore(0) == vector[]);

    //     0 1 2
    // 0: |2|2|2|
    // 1: |2|1|2|
    // 2: |2|2|2|
    let n = p.moore(1);
    assert!(n.contains(&new(0, 0)));
    assert!(n.contains(&new(0, 1)));
    assert!(n.contains(&new(0, 2)));
    assert!(n.contains(&new(1, 0)));
    assert!(n.contains(&new(1, 2)));
    assert!(n.contains(&new(2, 0)));
    assert!(n.contains(&new(2, 1)));
    assert!(n.contains(&new(2, 2)));
    assert!(n.length() == 8);

    //    0 1 2 3 4
    // 0: |2|2|2|2|2|
    // 1: |2|1|1|1|2|
    // 2: |2|1|0|1|2|
    // 3: |2|1|1|1|2|
    // 4: |2|2|2|2|2|

    let n = new(2, 2).moore(2);
    assert!(n.contains(&new(0, 0))); // 2
    assert!(n.contains(&new(0, 1))); // 2
    assert!(n.contains(&new(0, 2))); // 2
    assert!(n.contains(&new(0, 3))); // 2
    assert!(n.contains(&new(0, 4))); // 2
    assert!(n.contains(&new(1, 0))); // 2
    assert!(n.contains(&new(1, 1))); // 1
    assert!(n.contains(&new(1, 2))); // 1
    assert!(n.contains(&new(1, 3))); // 1
    assert!(n.contains(&new(1, 4))); // 2
    assert!(n.contains(&new(2, 0))); // 2
    assert!(n.contains(&new(2, 1))); // 1
    assert!(n.contains(&new(2, 2))); // 0
    assert!(n.contains(&new(2, 3))); // 1
    assert!(n.length() == 14);
}
