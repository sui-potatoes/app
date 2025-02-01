// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Stores the events that happen in the game, such as attacks, moves, etc.
module commander::event;

use sui::event;

/// An attack was performed by a unit.
public struct AttackEvent has copy, drop {
    game: ID,
    attacker: vector<u16>, // a pair of x, y coordinates
    target: vector<u16>, // a pair of x, y coordinates
    damage: u8,
    is_dodged: bool,
    is_missed: bool,
    is_crit: bool,
    is_kia: bool,
}

/// Unit moved along the path.
public struct MoveEvent has copy, drop {
    game: ID,
    path: vector<vector<u16>>,
}

/// Emit the attack event.
public fun emit_attack_event(
    game: ID,
    attacker: vector<u16>,
    target: vector<u16>,
    damage: u8,
    is_dodged: bool,
    is_missed: bool,
    is_crit: bool,
    is_kia: bool,
) {
    event::emit(AttackEvent {
        game,
        attacker,
        target,
        damage,
        is_dodged,
        is_missed,
        is_crit,
        is_kia,
    })
}

/// Emit the move event.
public fun emit_move_event(game: ID, path: vector<vector<u16>>) {
    event::emit(MoveEvent { game, path })
}
