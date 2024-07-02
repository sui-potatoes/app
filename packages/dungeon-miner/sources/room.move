// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::room {
    use std::string::{Self, String};
    use mine_dungeon::point::Point;

    // === Structs ===
    
    /// A layout with the elements for the room, empty/mine cells are the ones left 
    public struct Room has store, drop {
        // unique exit position
        exit: Point,
        // extra lifes positions
        lifes: vector<Point>,
        // could have more elements
    }

    // === Public functions ===

    // public fun new(): Room {

    // }
}
