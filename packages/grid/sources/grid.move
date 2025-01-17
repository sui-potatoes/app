// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines a generic `Grid` type which stores a 2D grid of elements. The grid
/// provides guarantees that the elements are stored in a rectangular shape.
///
/// Additionally, the module provides functions to work with the grid, such as
/// getting the width and height, borrowing elements, and finding the shortest
/// path between two points using the Wave Algorithm.
module grid::grid;

use grid::point::{Self, Point};
use std::string::String;

const EIncorrectVectorLength: u64 = 0;

/// A generic 2D grid, each cell stores `T`.
public struct Grid<T> has copy, drop, store {
    grid: vector<vector<T>>,
}

/// Create a new grid from a vector of vectors. The inner vectors represent
/// rows of the grid. The function panics if the grid is empty or if the rows
/// have different lengths.
public fun from_vector<T>(grid: vector<vector<T>>): Grid<T> {
    assert!(grid.length() > 0);
    let height = grid[0].length();
    grid.do_ref!(|row| assert!(row.length() == height, EIncorrectVectorLength));
    Grid { grid }
}

/// Same as `from_vector` but doesn't check the lengths. May be used for optimal
/// performance when the grid is known to be correct.
public fun from_vector_unchecked<T>(grid: vector<vector<T>>): Grid<T> {
    Grid { grid }
}

/// Get the width of the grid.
public fun width<T>(g: &Grid<T>): u16 { g.grid.length() as u16 }

/// Get the height of the grid.
public fun height<T>(g: &Grid<T>): u16 { g.grid[0].length() as u16 }

// === Indexing ===

/// Get a reference to the inner vector of the grid.
public fun inner<T>(g: &Grid<T>): &vector<vector<T>> { &g.grid }

#[syntax(index)]
/// Get a reference to a cell in the grid.
public fun borrow<T>(g: &Grid<T>, x: u16, y: u16): &T { &g.grid[x as u64][y as u64] }

#[syntax(index)]
/// Borrow a mutable reference to a cell in the grid.
public fun borrow_mut<T>(g: &mut Grid<T>, x: u16, y: u16): &mut T {
    &mut g.grid[x as u64][y as u64]
}

/// Swap an element in the grid with another element, returning the old element.
public fun swap<T>(g: &mut Grid<T>, x: u16, y: u16, element: T): T {
    g.grid[x as u64].insert(element, y as u64);
    g.grid[x as u64].remove(y as u64 + 1)
}

/// Get all von Neumann neighbours of a point, checking if the point is within
/// the bounds of the grid.
public fun von_neumann<T>(g: &Grid<T>, p: Point): vector<Point> {
    p.von_neumann().filter!(|point| point.x() < g.width() && point.y() < g.height())
}

// === Utils ===

/// Get a difference between two points, useful for calculating distances or
/// ranges for shooting, for example.
public fun range(x0: u16, y0: u16, x1: u16, y1: u16): u16 { x0.diff(x1) + y0.diff(y1) }

// === Macros ===

/// Create a grid of the specified size by applying the function `f` to each cell.
/// The function receives the x and y coordinates of the cell.
public macro fun tabulate<$T>($width: u16, $height: u16, $f: |u16, u16| -> $T): Grid<$T> {
    let width = $width as u64;
    let height = $height as u64;
    let grid = vector::tabulate!(width, |x| vector::tabulate!(height, |y| $f(x as u16, y as u16)));
    from_vector_unchecked(grid)
}

/// Finds a group of cells that satisfy the predicate `f`. The function receives
/// the cell at the current position, and returns whether the cell is part of the
/// group.
///
/// ```move
/// // finds a group of cells with value 1
/// grid.find_group!(0, 2, |el| *el == 1);
/// ```
public macro fun find_group<$T>(
    $map: &Grid<$T>,
    $x: u16,
    $y: u16,
    $f: |&$T| -> bool,
): vector<Point> {
    let (x, y) = ($x, $y);
    let map = $map;
    let (width, height) = (map.width(), map.height());
    let mut group = vector[];
    let mut visited = tabulate!(width, height, |_, _| false);

    if (!$f(&map[x, y])) return group;

    group.push_back(point::new(x, y));
    *&mut visited[x, y] = true;

    let mut queue = vector[point::new(x, y)];

    while (!queue.is_empty()) {
        let point = queue.pop_back();
        map.von_neumann(point).do!(|point| {
            let (x, y) = point.into_values();

            if (x >= width || y >= height || visited[x, y]) return;

            if ($f(&map[x, y])) {
                *&mut visited[x, y] = true;
                group.push_back(point);
                queue.push_back(point);
            }
        });
    };

    group
}

/// Use Wave Algorithm to find the shortest path between two points.
///
/// ```move
/// // finds the shortest path between (0, 0) and (1, 4) with a limit of 6
/// grid.trace!(0, 0, 1, 4, 6, |cell| cell == 0);
/// ```
///
/// TODO: consider using a A* algorithm for better performance.
public macro fun trace<$T>(
    $map: &Grid<$T>,
    $x0: u16,
    $y0: u16,
    $x1: u16,
    $y1: u16,
    $limit: u16,
    $f: |u16, u16, u16, u16| -> bool, // whether the cell is passable
): Option<vector<Point>> {
    let (x0, y0) = ($x0, $y0);
    let (x1, y1) = ($x1, $y1);
    let limit = 1 + $limit;

    // if the difference between A and B is greater than the limit, return none
    if (range(x0, y0, x1, y1) > limit) {
        return option::none()
    };

    let map = $map;
    let (width, height) = (map.width(), map.height());

    // if the points are out of bounds, return none
    if (x0 >= width || y0 >= height || x1 >= width || y1 >= height) {
        return option::none()
    };

    // surround the first element with 1s
    let mut num = 1;
    let mut queue = vector[point::new(x0, y0)];
    let mut grid = tabulate!(width, height, |_, _| 0);

    *&mut grid[x0, y0] = num;

    'search: while (num < limit && !queue.is_empty()) {
        num = num + 1;

        // flush the queue, marking all cells around the current number
        queue.destroy!(|source| grid.von_neumann(source).destroy!(|point| {
            let (x0, y0) = source.into_values();
            let (x, y) = point.into_values();

            // if we reached the destination, break the loop
            if (x == x1 && y == y1) {
                *&mut grid[x, y] = num;
                break 'search
            };

            // if we can't pass through the cell, skip it
            if (!$f(x0, y0, x, y)) return;

            // if the cell is empty, mark it with the current number
            if (grid[x, y] == 0) {
                *&mut grid[x, y] = num;
                queue.push_back(point);
            }
        }));
    };

    // we never reached the destination within the limit
    if (grid[x1, y1] == 0) {
        return option::none()
    };

    // reconstruct the path by going from the destination to the source
    let mut last_point = point::new(x1, y1);
    let mut path = vector[last_point];
    let mut num = grid[x1, y1];

    'reconstruct: while (num > 1) {
        num = num - 1;
        grid.von_neumann(last_point).destroy!(|point| {
            let (x, y) = point.into_values();
            if (x == x0 && y == y0) break 'reconstruct;
            if (grid[x, y] == num) {
                path.push_back(point::new(x, y));
                last_point = point;
                continue 'reconstruct
            }
        });
    };

    path.reverse();
    option::some(path)
}

/// Print the grid to a string. Only works if `$T` has a `.to_string()` method.
public macro fun to_string<$T>($grid: &Grid<$T>): String {
    let grid = $grid;
    let mut result = b"\n".to_string();
    let (width, height) = (grid.width(), grid.height());

    // the layout is vertical, so we iterate over the height first
    height.do!(|y| {
        result.append_utf8(b"|");
        width.do!(|x| {
            result.append(grid[x, y].to_string());
            result.append_utf8(b"|");
        });
        result.append_utf8(b"\n");
    });

    result
}

#[test_only]
/// Test-only function to print the grid to the console.
public macro fun debug<$T>($grid: &Grid<$T>) {
    std::debug::print(&to_string!($grid));
}

#[test]
fun test_borrows() {
    let mut grid = Grid { grid: vector[vector[0]] };
    assert!(grid[0, 0] == 0);
    *&mut grid[0, 0] = 1;
    assert!(grid[0, 0] == 1);
}

#[test]
fun test_path_tracing() {
    let grid = Grid {
        grid: vector[
            vector[1, 0, 0, 0, 0],
            vector[0, 0, 0, 0, 2],
            vector[0, 0, 0, 0, 0],
            vector[0, 0, 0, 0, 0], // 9 is a wall
            vector[0, 0, 0, 0, 0],
        ],
    };

    // we can only
    let path = trace!(&grid, 0, 0, 1, 4, 6, |_, _, x, y| grid[x, y] == &0);

    assert!(path.is_some());
    assert!(path.borrow().length() == 5);
    assert!(path.borrow()[4] == point::new(1, 4));

    let grid = Grid {
        grid: vector[
            vector[0, 1, 0, 0, 0],
            vector[0, 0, 0, 0, 0],
            vector[4, 4, 0, 0, 0],
            vector[2, 4, 0, 0, 0], // 9 is a wall
            vector[0, 0, 0, 0, 0],
        ],
    };

    let path = trace!(&grid, 0, 1, 3, 0, 10, |_, _, x, y| grid[x, y] == &0);

    assert!(path.is_some());
}

#[test]
fun test_find_group() {
    let grid = Grid {
        grid: vector[
            vector[0, 0, 1, 0, 0],
            vector[0, 0, 1, 0, 2],
            vector[0, 0, 1, 0, 0],
            vector[1, 0, 1, 0, 0],
            vector[0, 1, 1, 0, 0],
        ],
    };

    let group = grid.find_group!(0, 2, |el| *el == 1);
    assert!(group.length() == 6);
}
