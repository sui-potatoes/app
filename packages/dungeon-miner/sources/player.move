// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::player {
    use std::string::{Self, String};
    use mine_dungeon::point::{Self, Point};

    // === Structs ===

    /// A move direction made by the player
    public enum Move has store, drop {
        Up,
        Down,
        Left,
        Right,
    }

    /// The inventory of the player
    public struct Inventory has store, drop {
        lifes: u8,
    }

    /// The player's state
    public struct Player has store, drop {
        // current player's position
        position: Point,
        // moves the players did
        moves: vector<Move>,
    }

    // === Public functions ===

    public fun new(): Player {
        Player { position: point::new(0, 0), moves: vector::empty() }
    }
}
