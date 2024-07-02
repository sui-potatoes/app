// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Rooms are the levels the players need to navigate through and escape from.

module mine_dungeon::game_master {
    public struct GameMaster has key {
        id: UID,
    }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(GameMaster { id: object::new(ctx) }, ctx.sender());
    }
}
