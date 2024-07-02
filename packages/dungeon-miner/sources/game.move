// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The game module contains the main game logic.
module mine_dungeon::game {
    // === Imports ===

    use sui::{
        table::{Self, Table},
        vec_map::{Self, VecMap}
    };

    // === Errors ===

    // === Constants ===

    // === Structs ===

    public struct Registry has key {
        id: UID,
        users: Table<address, address>
    }

    public struct Coordinate has store (u64, u64)

    public struct RoomConfig has store {
        size: u64,
        level: u8,
        difficulty: u64,
    }

    public struct Game has key {
        id: UID,
        level: u8,
        config: VecMap<u8, RoomConfig>
    }   

    // === Method Aliases ===

    // === Public-Mutative Functions ===

    // === Public-View Functions ===

    // === Admin Functions ===

    // === Public-Package Functions ===

    // === Private Functions ===

    // === Test Functions ===
}