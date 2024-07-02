// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::player {
    use std::string::{Self, String};
    use mine_dungeon::point::{Self, Point};

    // === Errors ===

    const EWrongMove: u64 = 0;

    // === Constants ===

    const UP: u64 = 0;
    const DOWN: u64 = 1;
    const RIGHT: u64 = 2;
    const LEFT: u64 = 3;

    // === Structs ===
    
    /// The inventory of the player
    public struct Inventory has store, drop {
        lifes: u8,
        // can add more bonuses here
    }

    /// The player's state
    public struct Player has store, drop {
        // current player's position 
        position: Point,
        // moves the players did
        moves: vector<u64>,
    }

    // === Public functions ===

    public fun new(size: u64): Player {
        Player {
            position: point::new(size / 2, 0),
            moves: vector::empty(),
        }
    }

    public fun make_move(player: &mut Player, dir: u64) {
        match (dir) {
            UP => move_up(player),
            DOWN => move_down(player),
            RIGHT => move_right(player),
            LEFT => move_left(player),
            _ => abort EWrongMove
        }
    }

    // === Public view functions ===

    public fun position(player: Player): Point {
        player.position
    }

    // === Private functions ===

    fun move_up(player: &mut Player) {
        player.position = point::new(player.position.x(), player.position.y() + 1);
        player.moves.push_back(UP);
    }

    fun move_down(player: &mut Player) {
        player.position = point::new(player.position.x(), player.position.y() - 1);
        player.moves.push_back(DOWN);
    }

    fun move_right(player: &mut Player) {
        player.position = point::new(player.position.x() + 1, player.position.y());
        player.moves.push_back(RIGHT);
    }

    fun move_left(player: &mut Player) {
        player.position = point::new(player.position.x() - 1, player.position.y());
        player.moves.push_back(LEFT);
    }
}
