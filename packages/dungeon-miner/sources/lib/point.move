// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Point is a type representing a point in a 2D grid (x, y)

module mine_dungeon::point {
    public struct Point(u64, u64) has store, copy, drop;

    public fun new(x: u64, y: u64): Point {
        Point(x, y)
    }

    public fun x(self: Point): u64 { self.0 }

    public fun y(self: Point): u64 { self.1 }
}
