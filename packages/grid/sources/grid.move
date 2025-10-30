// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines a generic `Grid` type which stores a 2D grid of elements. The grid
/// provides guarantees that the elements are stored in a rectangular shape.
///
/// Additionally, the module provides functions to work with the grid, such as
/// getting the cols and rows, borrowing elements, and finding the shortest
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

use grid::point::Point;
use std::{macros::{num_diff, num_max}, string::String};
use sui::bcs::BCS;

/// Vector length is incorrect during initialization.
const EIncorrectLength: u64 = 0;

/// A generic 2D grid, each cell stores `T`.
public struct Grid<T> has copy, drop, store {
    grid: vector<vector<T>>,
}

/// Create a new grid from a vector of vectors. The inner vectors represent
/// rows of the grid. The function panics if the grid is empty or if the rows
/// have different lengths.
public fun from_vector<T>(grid: vector<vector<T>>): Grid<T> {
    assert!(grid.length() > 0, EIncorrectLength);
    let cols = grid[0].length();
    grid.do_ref!(|row| assert!(row.length() == cols, EIncorrectLength));
    Grid { grid }
}

/// Same as `from_vector` but doesn't check the lengths. May be used for optimal
/// performance when the grid is known to be correct.
public fun from_vector_unchecked<T>(grid: vector<vector<T>>): Grid<T> {
    Grid { grid }
}

/// Unpack the `Grid` into its underlying vector.
public fun into_vector<T>(grid: Grid<T>): vector<vector<T>> {
    let Grid { grid } = grid;
    grid
}

// === Accessors & Mutators ===

/// Alias for the `rows` function.
public use fun rows as Grid.height;

/// Get the number of rows of the `Grid`.
public fun rows<T>(g: &Grid<T>): u16 { g.grid.length() as u16 }

/// Alias for the `cols` function.
public use fun cols as Grid.width;

/// Get the number of columns of the `Grid`.
public fun cols<T>(g: &Grid<T>): u16 { g.grid[0].length() as u16 }

/// Get a reference to the inner vector of the grid.
public fun inner<T>(g: &Grid<T>): &vector<vector<T>> { &g.grid }

#[syntax(index)]
/// Get a reference to a cell in the grid.
/// ```move
/// let value_ref = &grid[0, 0];
/// let copied_value = grid[0, 0];
/// ```
public fun borrow<T>(g: &Grid<T>, x: u16, y: u16): &T { &g.grid[x as u64][y as u64] }

#[syntax(index)]
/// Borrow a mutable reference to a cell in the grid.
/// ```move
/// let value_mut = &mut grid[0, 0];
/// ```
public fun borrow_mut<T>(g: &mut Grid<T>, x: u16, y: u16): &mut T {
    &mut g.grid[x as u64][y as u64]
}

/// Swap an element in the grid with another element, returning the old element.
/// This is important for `T` types that don't have `drop`.
public fun swap<T>(g: &mut Grid<T>, x: u16, y: u16, element: T): T {
    g.grid[x as u64].push_back(element);
    g.grid[x as u64].swap_remove(y as u64)
}

/// Rotate the grid `times` * 90º degrees clockwise. Mutates the grid in place.
/// If `times` is greater than 3, it will be reduced to the equivalent rotation.
public fun rotate<T>(g: &mut Grid<T>, times: u8) {
    let times = times % 4;

    // no rotation
    if (times == 0) return;

    // first deal with times = 1, keep the grid value, only modify it
    // if we're only rotating 90º, we can perform swaps
    if (times == 1) {
        let Grid { grid: source } = g;
        let mut target = vector[];
        let (rows, cols) = (source.length(), source[0].length());
        source.pop_back().do!(|el| target.push_back(vector[el]));

        (rows - 1).do!(|_| {
            let mut row = source.pop_back();
            cols.do!(|i| target[cols - i - 1].push_back(row.pop_back()));
            row.destroy_empty();
        });

        target.do!(|row| source.push_back(row));
    };

    // 180º degrees rotation
    // mirror the grid diagonally, reverse the rows and columns
    if (times == 2) {
        g.grid.reverse();
        g.grid.do_mut!(|row| row.reverse());
    };

    // 270º degrees rotation
    if (times == 3) {
        let Grid { grid: source } = g;
        let (rows, cols) = (source.length(), source[0].length());
        let mut target = vector[];
        source.reverse();
        source.pop_back().do!(|el| target.push_back(vector[el]));

        (rows - 1).do!(|_| {
            let mut row = source.pop_back();
            cols.do!(|i| target[cols - i - 1].push_back(row.pop_back()));
            row.destroy_empty();
        });

        target.destroy!(|row| source.push_back(row));
    };
}

// === Accessors: Point ===

/// Get a reference to a cell in the `Grid` at the given `Point`.
public fun borrow_point<T>(g: &Grid<T>, p: &Point): &T {
    let (x, y) = p.to_values();
    &g.grid[x as u64][y as u64]
}

/// Get a mutable reference to a cell in the `Grid` at the given `Point`.
public fun borrow_point_mut<T>(g: &mut Grid<T>, p: &Point): &mut T {
    let (x, y) = p.to_values();
    &mut g.grid[x as u64][y as u64]
}

// === Macros: Utility ===

/// Get a Manhattan distance between two points. Manhattan distance is the
/// sum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```rust
/// let distance = grid::manhattan_distance!(0, 0, 1, 2);
///
/// assert!(distance == 3);
/// ```
///
/// See https://en.wikipedia.org/wiki/Taxicab_geometry for more information.
public macro fun manhattan_distance<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T {
    num_diff!($x0, $x1) + num_diff!($y0, $y1)
}

/// Get a Chebyshev distance between two points. Chebyshev distance is the
/// maximum of the absolute differences of the x and y coordinates.
///
/// Example:
/// ```rust
/// let distance = grid::chebyshev_distance!(0, 0, 1, 2);
///
/// assert!(distance == 2);
/// ```
///
/// See https://en.wikipedia.org/wiki/Chebyshev_distance for more information.
public macro fun chebyshev_distance<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T {
    num_max!(num_diff!($x0, $x1), num_diff!($y0, $y1))
}

/// Get the Euclidean distance between two points. Euclidean distance is the
/// square root of the sum of the squared differences of the x and y coordinates.
///
/// Note: use with caution on `u8` and `u16` types, as the macro does not upscale
/// intermediate values automatically. Perform upscaling manually before using the
/// macro if necessary.
///
/// Example:
/// ```rust
/// let distance = grid::euclidean_distance!(0, 0, 1, 2);
///
/// assert_eq!(distance, 2);
/// ```
///
/// See https://en.wikipedia.org/wiki/Euclidean_distance for more information.
public macro fun euclidean_distance<$T: drop>($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T {
    let xd = num_diff!($x0, $x1);
    let yd = num_diff!($y0, $y1);

    (xd * xd + yd * yd).sqrt()
}

// === Macros: Grid ===

/// Create a grid of the specified size by applying the function `f` to each cell.
/// The function receives the x and y coordinates of the cell.
///
/// Example:
/// ```rust
/// public enum Tile {
///   Empty,
///   // ...
/// }
///
/// let grid = grid::tabulate!(3, 3, |_x, _y| Tile::Empty);
/// ```
public macro fun tabulate<$U: drop, $T>($rows: $U, $cols: $U, $f: |u16, u16| -> $T): Grid<$T> {
    let rows = $rows as u64;
    let cols = $cols as u64;
    let grid = vector::tabulate!(rows, |x| vector::tabulate!(cols, |y| $f(x as u16, y as u16)));
    from_vector_unchecked(grid)
}

/// Gracefully destroy the `Grid` by consuming the elements in the passed function $f.
/// Goes in reverse order (bottom to top, right to left). Cheaper than `do` because it
/// doesn't need to reverse the elements.
///
/// Example:
/// ```rust
/// grid.destroy!(|tile| tile.destroy());
/// ```
public macro fun destroy<$T, $R: drop>($grid: Grid<$T>, $f: |$T| -> $R) {
    into_vector($grid).destroy!(|row| row.destroy!(|cell| $f(cell)));
}

/// Consume the `Grid` by calling the function `f` for each element. Preserves the
/// order of elements (goes from top to bottom, left to right). If the order does not
/// matter, use `destroy` instead.
public macro fun do<$T, $R: drop>($grid: Grid<$T>, $f: |$T| -> $R) {
    into_vector($grid).do!(|row| row.do!(|cell| $f(cell)));
}

/// Apply the function `f` for each element of the `Grid`.
/// The function receives a reference to the cell.
public macro fun do_ref<$T, $R: drop>($grid: &Grid<$T>, $f: |&$T| -> $R) {
    inner($grid).do_ref!(|row| row.do_ref!(|cell| $f(cell)));
}

/// Apply the function `f` for each element of the `Grid`. The function receives
/// a mutable reference to the cell.
public macro fun do_mut<$T, $R: drop>($grid: &mut Grid<$T>, $f: |&mut $T| -> $R) {
    let grid = $grid;
    let (rows, cols) = (grid.rows(), grid.cols());
    rows.do!(|row| cols.do!(|col| $f(&mut grid[row, col])));
}

/// Traverse the grid, calling the function `f` for each cell. The function
/// receives the reference to the cell, the x and y coordinates of the cell.
///
/// Example:
/// ```rust
/// grid.traverse!(|cell, (x, y)| {
///     // do something with the cell and the coordinates
/// });
/// ```
public macro fun traverse<$T, $R: drop>($g: &Grid<$T>, $f: |&$T, (u16, u16)| -> $R) {
    let g = $g;
    let (rows, cols) = (g.rows(), g.cols());
    rows.do!(|x| cols.do!(|y| $f(&g[x, y], (x, y))));
}

/// Map the grid to a new grid by applying the function `f` to each cell.
public macro fun map<$T, $U>($grid: Grid<$T>, $f: |$T| -> $U): Grid<$U> {
    from_vector_unchecked(into_vector($grid).map!(|row| row.map!(|cell| $f(cell))))
}

/// Map the grid to a new grid by applying the function `f` to each cell.
/// Callback `f` takes the reference to the cell.
public macro fun map_ref<$T, $U>($grid: &Grid<$T>, $f: |&$T| -> $U): Grid<$U> {
    from_vector_unchecked(inner($grid).map_ref!(|row| row.map_ref!(|cell| $f(cell))))
}

/// Get all von Neumann neighbors of a point, checking if the point is within
/// the bounds of the grid. The size parameter specifies the size of the neighborhood.
///
/// See `Point` for more information on the von Neumann neighborhood.
/// See https://en.wikipedia.org/wiki/Von_Neumann_neighborhood for more information.
public fun von_neumann<T>(g: &Grid<T>, p: Point, size: u16): vector<Point> {
    let (rows, cols) = (g.rows(), g.cols());
    p.von_neumann(size).filter!(|point| {
        let (x, y) = point.to_values();
        x < rows && y < cols
    })
}

/// Count the number of Von Neumann neighbors of a point that satisfy the predicate $f.
///
/// Example:
/// ```rust
/// let count = grid.von_neumann_count!(0, 2, 1, |el| *el == 1);
///
/// assert!(count == 1);
/// ```
public macro fun von_neumann_count<$T>(
    $g: &Grid<$T>,
    $p: Point,
    $size: u16,
    $f: |&$T| -> bool,
): u8 {
    let p = $p;
    let g = $g;
    let (rows, cols) = (g.rows(), g.cols());
    let mut count = 0u8;

    p.von_neumann($size).destroy!(|point| {
        let (x1, y1) = point.to_values();
        if (x1 >= rows || y1 >= cols) return;
        if (!$f(&g[x1, y1])) return;

        count = count + 1;
    });

    count
}

/// Get all Moore neighbors of a `Point`, checking if the point is within the
/// bounds of the grid. The size parameter specifies the size of the neighborhood.
///
/// See `Point` for more information on the Moore neighborhood.
/// See https://en.wikipedia.org/wiki/Moore_neighborhood for more information.
///
/// Example:
/// ```rust
/// let neighbors = grid.moore!(0, 2, 1);
/// neighbors.destroy!(|p| std::debug::print(&p.to_string!()));
/// ```
public fun moore<T>(g: &Grid<T>, p: Point, size: u16): vector<Point> {
    let (rows, cols) = (g.rows(), g.cols());
    p.moore(size).filter!(|point| {
        let (x, y) = point.to_values();
        x < rows && y < cols
    })
}

/// Count the number of Moore neighbors of a point that pass the predicate $f.
///
/// Example:
/// ```rust
/// let count = grid.moore_count!(0, 2, 1, |el| *el == 1);
/// std::debug::print(&count); // result varies based on the Grid
/// ```
public macro fun moore_count<$T>($g: &Grid<$T>, $p: Point, $size: u16, $f: |&$T| -> bool): u8 {
    let p = $p;
    let g = $g;
    let (rows, cols) = (g.rows(), g.cols());
    let mut count = 0u8;

    p.moore($size).destroy!(|point| {
        let (x1, y1) = point.to_values();
        if (x1 >= rows || y1 >= cols) return;
        if (!$f(&g[x1, y1])) return;

        count = count + 1;
    });

    count
}

/// Finds a group of cells that satisfy the predicate `f` amongst the neighbors
/// of the given point. The function `n` is used to get the neighbors of the
/// current point. For Von Neumann neighborhood, use `von_neumann` as the
/// function. For Moore neighborhood, use `moore` as the function.
///
/// Takes the `$n` function to get the neighbors of the current point. Expected
/// to be used with the `von_neumann` and `moore` macros to get the neighbors.
/// However, it is possible to pass in a custom callback with exotic
/// configurations, eg. only return diagonal neighbors.
///
/// ```rust
/// // finds a group of cells with value 1 in von Neumann neighborhood
/// grid.find_group!(0, 2, |p| p.von_neumann(1), |el| *el == 1);
///
/// // finds a group of cells with value 1 in Moore neighborhood
/// grid.find_group!(0, 2, |p| p.moore(1), |el| *el == 1);
///
/// // custom neighborhood, only checks the neighbor to the right
/// grid.find_group!(0, 2, |p| vector[point::new(p.x(), p.y() + 1)], |el| *el == 1);
/// ```
public macro fun find_group<$T>(
    $map: &Grid<$T>,
    $p: Point,
    $n: |&Point| -> vector<Point>,
    $f: |&$T| -> bool,
): vector<Point> {
    let p = $p;
    let map = $map;
    let (rows, cols) = (map.rows(), map.cols());
    let mut group = vector[];
    let mut visited = tabulate!(rows, cols, |_, _| false);

    if (!$f(map.borrow_point(&p))) return group;

    group.push_back(p);
    *visited.borrow_point_mut(&p) = true;

    let mut queue = vector[p];

    while (queue.length() != 0) {
        $n(&queue.pop_back()).destroy!(|p| {
            if (!p.is_within_bounds(rows, cols) || *visited.borrow_point(&p)) return;
            if ($f(map.borrow_point(&p))) {
                *visited.borrow_point_mut(&p) = true;
                group.push_back(p);
                queue.push_back(p);
            }
        });
    };

    group
}

/// Use Wave Algorithm to find the shortest path between two points. The function
/// `n` returns the neighbors of the current point. The function `f` is used to
/// check if the cell is passable - it takes two arguments: the current point
/// and the next point.
///
/// ```rust
/// // finds the shortest path between (0, 0) and (1, 4) with a limit of 6
/// grid.trace!(
///     point::new(0, 0),
///     point::new(1, 4),
///     |p| p.moore(1), // use moore neighborhood
///     |(prev_x, prev_y), (next_x, next_y)| cell == 0,
///     6,
/// );
/// ```
///
/// Transition to the last tile must match the predicate `f`.
public macro fun trace<$T>(
    $map: &Grid<$T>,
    $p0: Point,
    $p1: Point,
    $n: |&Point| -> vector<Point>,
    $f: |(u16, u16), (u16, u16)| -> bool, // whether the cell is passable
    $limit: u16,
): Option<vector<Point>> {
    let p0 = $p0;
    let p1 = $p1;
    let limit = $limit + 1; // we start from 1, not 0.

    let map = $map;
    let (rows, cols) = (map.rows(), map.cols());

    // If the points are out of bounds, return none.
    if (!p0.is_within_bounds(rows, cols) || !p1.is_within_bounds(rows, cols)) {
        return option::none()
    };

    // Surround the first element with 1s.
    let mut num = 1;
    let mut queue = vector[p0];
    let mut grid = tabulate!(rows, cols, |_, _| 0);

    *grid.borrow_point_mut(&p0) = num;

    let mut found = false;
    'search: while (num < limit && !queue.is_empty()) {
        num = num + 1;

        // Flush the queue, marking all cells around the current number.
        queue.destroy!(|from| $n(&from).destroy!(|to| {
            let (x0, y0) = from.into_values();
            let (x1, y1) = to.into_values();
            if (x1 >= rows || y1 >= cols) return;

            // If we can't pass through the cell, skip it.
            if (!$f((x0, y0), (x1, y1))) return;

            // If we reached the destination, break the loop.
            if (to == p1) {
                *grid.borrow_point_mut(&to) = num;
                found = true;
                break 'search
            };

            // If the cell is empty, mark it with the current number.
            if (grid.borrow_point(&to) == 0) {
                *grid.borrow_point_mut(&to) = num;
                queue.push_back(to);
            }
        }));
    };

    // If we never reached the destination within the limit, return none.
    if (!found) {
        return option::none()
    };

    // Reconstruct the path by going from the destination to the source.
    let mut path = vector[p1];
    let mut last_point = p1;

    'reconstruct: while (num > 1) {
        num = num - 1;
        $n(&last_point).destroy!(|p| {
            if (p == p0) break 'reconstruct;
            if (grid.borrow_point(&p) == num) {
                path.push_back(p);
                last_point = p;
                continue 'reconstruct
            }
        });
    };

    path.reverse();
    option::some(path)
}

// === Macros: Compatibility ===

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
    let (rows, cols) = (grid.rows(), grid.cols());

    // the layout is vertical, so we iterate over the rows first
    rows.do!(|x| {
        result.append_utf8(b"|");
        cols.do!(|y| {
            result.append(grid[x, y].to_string());
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
    let mut str = b"\n".to_string();
    str.append(to_string!($grid));
    std::debug::print(&str);
}
