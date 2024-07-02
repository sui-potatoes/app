// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::room {

    // === Structs ===

    public enum Cell has store, drop {
        // exit of the room to complete the level
        Exit,
        // probably an empty but can be revealed into a mine
        Empty,
        // gives an extra life 
        Life,
        // can add more cells later
    }    
    
    // A player's move on the board, simply a pair of coordinates.
    public struct Point(u8, u8) has store, copy, drop;

    // level state
    public struct Room has store, drop {
        // the state of the map / grid
        grid: vector<vector<Cell>>,
        //
        moves: vector<Point>,
        // bonuses collected by the player and transferred from room to room
        inventory: Option<Inventory>,
    }

    public struct Inventory has store, drop {
        lifes: u8,
        // can add more bonuses here
    }
}
