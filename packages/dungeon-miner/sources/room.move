// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::room {
    use std::string::{Self, String};

    // === Structs ===

    /// An element's position (player or other), simply a pair of coordinates.
    public struct Point(u8, u8) has store, copy, drop;

    /// A move direction made by the player
    public enum Move has store, drop {
        Up,
        Down,
        Left,
        Right,
    }
    
    /// A layout with the elements for the room, empty/mine cells are the ones left 
    /// It is stored as a dynamic field for more flexibility (later upgrades)
    public struct Layout has store, drop {
        // unique exit position
        exit: Point,
        // extra lifes positions
        lifes: vector<Point>,
        // could have more elements
    }  
    

    /// The inventory of the player, dynamic fields allow for future upgrades and transfers between rooms
    public struct Inventory has store, drop {
        lifes: u8,
        // can add more bonuses here
    }

    /// The level's state, it holds the layout as a dynamic field
    public struct Room has store, drop {
        // current player's position 
        position: Point,
        // moves the players did
        moves: vector<Move>,
        // bonuses collected by the player and transferred from room to room
        inventory: Option<Inventory>,
        // DF: layout
        // DF: inventory
    }

    // === Public functions ===

    // public fun new(): Room {

    // }

    // === Public view functions ===

    /// simple df key (struct name) for retrieving Layout on frontend 
    public fun layout_key(): String {
        string::utf8(b"Layout")
    }

    /// simple df key (struct name) for retrieving Inventory on frontend 
    public fun inventory_key(): String {
        string::utf8(b"Inventory")
    }
}
