// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Player object stores the Player's credits.
module commander::player;

/// Non-transferable player object.
public struct Player has key {
    id: UID,
    /// Credits the player has for completing objectives and missions.
    credits: u64,
    /// The ID of the active game. There can be only one active game per player.
    active_game: Option<ID>,
}

/// Create a new `Player` object.
public fun new(ctx: &mut TxContext): Player {
    Player {
        id: object::new(ctx),
        credits: 0,
        active_game: option::none(),
    }
}

/// Keep the `Player` object in the context.
public fun keep(player: Player, ctx: &mut TxContext) {
    transfer::transfer(player, ctx.sender());
}

public use fun player_address as Player.address;

/// Get the ID of the `Player` object.
public fun player_address(p: &Player): address { p.id.to_address() }

/// Get the ID of the `Player` object.
public fun id(p: &Player): ID { p.id.to_inner() }

/// Get the credits of the `Player` object.
public fun credits(p: &Player): u64 { p.credits }

/// Get the active game of the `Player` object.
public fun active_game(p: &Player): Option<ID> { p.active_game }
