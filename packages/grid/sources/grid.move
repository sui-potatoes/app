// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines a generic `Grid` type which stores a 2D grid of elements. The grid
/// provides guarantees that the elements are stored in a rectangular shape.
///
/// Additionally, the module provides functions to work with the grid, such as
/// getting the width and height, borrowing elements, and finding the shortest
/// path between two points using the Wave Algorithm.
///
/// Structure, printing and directions:
/// - the grid is a 2-dimensional vector of elements, with `x` coordinate being
/// the outer vector and the row number, and `y` coordinate being the inner vector
/// and the column number
/// - x=0 is the top of the grid, y=0 is the left side of the grid, with increase
/// in x going downwards and increase in y going to the right
/// - the grid is printed vertically, with the top left corner being the first
/// element and the bottom right corner being the last element
/// - the grid provides macro functions to check if a point is above, below, to
/// the left or to the right of another point
module grid::grid;

use grid::point::{Self, Point};
use std::{macros, string::String};
use sui::bcs::BCS;

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
/// This is important for `T` types that don't have `drop`.
public fun swap<T>(g: &mut Grid<T>, x: u16, y: u16, element: T): T {
    g.grid[x as u64].push_back(element);
    g.grid[x as u64].swap_remove(y as u64)
}

// === Macros ===

/// Check if a point is above another point (decrease in X).
public macro fun is_up($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 > $x1 && $y0 == $y1 }

/// Check if a point is below another point (increase in X).
public macro fun is_down($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 < $x1 && $y0 == $y1 }

/// Check if a point is to the left of another point (decrease in Y).
public macro fun is_left($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 == $x1 && $y0 > $y1 }

/// Check if a point is to the right of another point (increase in Y).
public macro fun is_right($x0: u16, $y0: u16, $x1: u16, $y1: u16): bool { $x0 == $x1 && $y0 < $y1 }

/// Get a Manhattan distance between two points. Useful for calculating distances
/// or ranges for ranged attacks or walking, for example.
public macro fun range($x0: u16, $y0: u16, $x1: u16, $y1: u16): u16 {
    macros::num_diff!($x0, $x1) + macros::num_diff!($y0, $y1)
}

/// Get all von Neumann neighbours of a point, checking if the point is within
/// the bounds of the grid. The size parameter specifies the size of the neighbourhood.
///
/// See `Point` for more information on the von Neumann neighbourhood.
public macro fun von_neumann<$T>($g: &Grid<$T>, $p: Point, $size: u16): vector<Point> {
    let p = $p;
    let g = $g;
    let (width, height) = (g.width(), g.height());
    p.von_neumann($size).filter!(|point| {
        let (x, y) = point.to_values();
        x < width && y < height
    })
}

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

    while (queue.length() != 0) {
        let point = queue.pop_back();
        map.von_neumann!(point, 1).do!(|point| {
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
/// grid.trace!(0, 0, 1, 4, 6, |prev_x, prev_y, next_x, next_y| cell == 0);
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
    if (range!(x0, y0, x1, y1) > limit) {
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
        queue.destroy!(|source| grid.von_neumann!(source, 1).destroy!(|point| {
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
        grid.von_neumann!(last_point, 1).destroy!(|point| {
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
///
/// ```rust
/// let grid = from_vector(vector[
///     vector[1, 2, 3],
///     vector[4, 5, 6],
///     vector[7, 8, 9u8],
/// ]);
///
/// std::debug::print(&grid.to_string!())
/// ```
public macro fun to_string<$T>($grid: &Grid<$T>): String {
    let grid = $grid;
    let mut result = b"".to_string();
    let (width, height) = (grid.width(), grid.height());

    // the layout is vertical, so we iterate over the height first
    width.do!(|y| {
        result.append_utf8(b"|");
        height.do!(|x| {
            result.append(grid[y, x].to_string());
            result.append_utf8(b"|");
        });
        result.append_utf8(b"\n");
    });

    result
}

/// Deserialize `BCS` into a grid. This macro is a helping hand in writing
/// custom deserializers.
public macro fun from_bcs<$T>($bcs: &mut BCS, $f: |&mut BCS| -> $T): Grid<$T> {
    let bcs = $bcs;
    let grid = bcs.peel_vec!(|row| row.peel_vec!(|val| $f(val)));
    from_vector_unchecked(grid)
}

#[test_only]
/// Test-only function to print the grid to the console.
public macro fun debug<$T>($grid: &Grid<$T>) {
    std::debug::print(&to_string!($grid));
}
