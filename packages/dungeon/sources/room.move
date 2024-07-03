// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module dungeon::room;

use std::string::{Self, String};
use dungeon::point::{Self, Point};

// === Structs ===

/// A layout with the elements for the room, empty/mine cells are the ones left 
public struct Room has store, drop {
    size: u64,
    // unique exit position
    exit: Point,
    // extra lifes positions
    lifes: vector<Point>,
    // could have more elements
}

// === Public functions ===

public fun new(size: u64): Room {
    Room {
        size,
        exit: point::new(size / 2, size),
        lifes: vector::empty(),
    }
}

public fun is_exit(room: &Room, point: Point): bool {
    room.exit == point
}

// === Public view functions ===

public fun size(room: &Room): u64 {
    room.size
}

