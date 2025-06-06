// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements Conway's game of life using grid.
module grid::life;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
use std::string::String;

/// Rules:
/// 1. Any cell with fewer than 2 live neighbors dies (under population).
/// 2. Any live cell with 2 or 3 live neighbors lives on.
/// 3. Any live cell with more than three live neighbors dies (overpopulation).
/// 4. Any dead cell with exactly three live neighbors becomes a live cell.
public struct Life has key, store {
    id: UID,
    /// Each cell is represented as a boolean value.
    grid: Grid<Cell>,
    /// Keep track of live cells to avoid traversing the grid.
    live_cells: vector<Point>,
}

/// Represents the game state. We use the wrapper type to implement `to_string`,
/// for debug printing.
public struct Cell(bool) has copy, drop, store;

/// Create a new instance of the `Game`.
public fun new(width: u16, height: u16, ctx: &mut TxContext): Life {
    Life {
        id: object::new(ctx),
        grid: grid::tabulate!(width, height, |_, _| Cell(false)),
        live_cells: vector[],
    }
}

/// Place a live cell on the grid at (x, y).
public fun place(l: &mut Life, x: u16, y: u16) {
    l.live_cells.push_back(point::new(x, y));
    let _ = l.grid.swap(x, y, Cell(true));
}

/// Perform a single tick of the game, calculate the next state.
public fun tick(l: &mut Life) {
    // Keep track of visited cells. Using `Grid` instead of `vec_set`-likes
    // significantly improves performance by avoiding `contains` loops.
    let mut visited = grid::tabulate!(l.grid.width(), l.grid.height(), |_, _| false);
    let mut live_cells = vector[];
    let mut dead_cells = vector[];
    let mut to_check = vector[];

    // first check current live cells;
    l.live_cells.do_ref!(|p| {
        l.grid.moore!(*p, 1).destroy!(|p| {
            if (*visited.borrow_point(&p)) return;
            *visited.borrow_point_mut(&p) = true;
            to_check.push_back(p);
        });
    });

    to_check.destroy!(|p| {
        let is_live = l.grid.borrow_point(&p).0;
        let count = l.grid.moore_count!(p, 1, |v| v.0);

        if (is_live && (count < 2 || count > 3)) dead_cells.push_back(p)
        else if (!is_live && count == 3) live_cells.push_back(p)
        else if (is_live && (count == 2 || count == 3)) live_cells.push_back(p)
    });

    l.live_cells = live_cells;

    live_cells.destroy!(|p| {
        *&mut l.grid.borrow_point_mut(&p).0 = true;
    });

    dead_cells.destroy!(|p| {
        *&mut l.grid.borrow_point_mut(&p).0 = false;
    });
}

public use fun cell_to_string as Cell.to_string;

/// Implement `to_string` so that the Grid can be printed.
public fun cell_to_string(c: &Cell): String {
    if (c.0) b"•" else { b"_" }.to_string()
}

#[test]
fun test_game_of_life_bar_swap() {
    let ctx = &mut tx_context::dummy();
    let mut life = new(3, 3, ctx);

    life.place(0, 1);
    life.place(1, 1);
    life.place(2, 1);

    life.tick();
    life.tick();

    let Life { id, .. } = life;
    id.delete();
}

#[test]
fun test_game_of_life_square() {
    let ctx = &mut tx_context::dummy();
    let mut life = new(3, 3, ctx);

    life.place(0, 0);
    life.place(0, 1);
    life.place(1, 0);
    life.place(1, 1);

    // |•|•|_|
    // |•|•|_|
    // |_|_|_|
    life.tick();

    // |•|•|_|
    // |•|•|_|
    // |_|_|•|
    life.place(2, 2);

    // |•|•|_|
    // |•|_|•|
    // |_|•|_|
    life.tick();

    let Life { id, .. } = life;
    id.delete();
}

#[test]
fun test_game_of_life_glider() {
    let ctx = &mut tx_context::dummy();
    let mut life = new(8, 8, ctx);

    // building a simple glider
    // |•|_|_|_|_|_|_|_|_|_|
    // |_|•|•|_|_|_|_|_|_|_|
    // |•|•|_|_|_|_|_|_|_|_|
    // |_|_|_|_|_|_|_|_|_|_|
    life.place(0, 0);
    life.place(2, 0);
    life.place(2, 1);
    life.place(1, 1);
    life.place(1, 2);
    life.place(1, 1);

    // moving it
    // |_|•|_|_|_|_|_|_|_|_|
    // |_|_|•|_|_|_|_|_|_|_|
    // |•|•|•|_|_|_|_|_|_|_|
    // |_|_|_|_|_|_|_|_|_|_|
    life.tick();

    // do 10 more ticks, see how it moves
    10u8.do!(|_| {
        life.tick();
        // life.grid.debug!();
    });

    let Life { id, .. } = life;
    id.delete();
}
