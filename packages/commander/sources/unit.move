// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Unit` component and its methods.
module commander::unit;

use commander::{action::{Self, Action}, param::{Self, Param}};
use std::string::String;
use sui::bcs;

/// A unit in the game. Units have health, action points, and can perform actions
/// such as moving and attacking. Units are placed on the `Game` and taken after
/// the match ends.
public struct Unit has copy, store, drop {
    /// A unique symbol representing the unit. For pretty-printing the map.
    symbol: String,
    /// The name of the unit. Purely cosmetic.
    name: String,
    /// The actions the unit can perform.
    actions: vector<Action>,
    /// The health parameter.
    health: Param,
    /// The action points (AP) parameter.
    ap: Param,
    /// We use this number to reset the unit's AP at the beginning of the turn.
    /// This way we avoid walking through the entire map to reset the AP of each
    /// unit.
    current_turn: u16,
}

/// Create a new `Unit` with the given parameters.
public fun new(symbol: String, name: String, actions: vector<Action>, health: u16, ap: u16): Unit {
    Unit { symbol, name, actions, health: param::new(health), ap: param::new(ap), current_turn: 0 }
}

/// Create a new "Sniper" `Unit`. Snipers have a powerful long-range attack and
/// can move a short distance. They have low health and high action points.
///
/// Stats:
/// - Health: 6
/// - Action Points: 10
/// - Actions:
///     * Move (2 AP)
///     * Shoot (8 DMG, 5 RNG, 5 AP)
///     * Wait (10 AP)
public fun sniper(): Unit {
    Unit {
        symbol: b"L".to_string(),
        name: b"Sniper".to_string(),
        actions: vector[
            // Move action, 2 AP per step
            action::new_move(b"Move".to_string(), 2),
            // Attack action, 5 AP, 5 max range, 8 damage
            action::new_attack(b"Shoot".to_string(), 5, 6, 8),
            // Wait action, MAX AP
            action::new_skip(b"Wait".to_string(), 1),
        ],
        health: param::new(6),
        ap: param::new(10),
        current_turn: 0,
    }
}

/// Create a new "Soldier" `Unit`. Soldiers have a medium-range attack and can
/// move a medium distance. They have medium health and action points.
///
/// Stats:
/// - Health: 10
/// - Action Points: 6
/// - Actions:
///     * Move (1 AP)
///     * Shoot (4 DMG, 4 RNG, 2 AP)
///     * Melee (5 DMG, 1 RNG, 3 AP)
///     * Wait (10 AP)
public fun soldier(): Unit {
    Unit {
        symbol: b"S".to_string(),
        name: b"Soldier".to_string(),
        actions: vector[
            // Move action, 1 AP per step
            action::new_move(b"Move".to_string(), 1),
            // Attack action, 2 AP, 4 max range, 4 damage
            action::new_attack(b"Shoot".to_string(), 2, 4, 4),
            // Melee attack action, 3 AP, 1 max range, 10 damage
            action::new_attack(b"Melee".to_string(), 3, 1, 5),
            // Wait action, MAX AP
            action::new_skip(b"Wait".to_string(), 1),
        ],
        health: param::new(10),
        ap: param::new(6),
        current_turn: 0,
    }
}

/// Create a new "Heavy" `Unit`. Heavies have a powerful short-range attack and
/// can move a short distance. They have high health and high cost of movement.
///
/// Stats:
/// - Health: 20
/// - Action Points: 6
/// - Actions:
///     * Move (2 AP)
///     * Shoot (8 DMG, 3 RNG, 2 AP)
///     * Melee (10 DMG, 1 RNG, 3 AP)
///     * Wait (10 AP)
public fun heavy(): Unit {
    Unit {
        symbol: b"H".to_string(),
        name: b"Heavy".to_string(),
        actions: vector[
            // Move action, 2 AP per step
            action::new_move(b"Move".to_string(), 2),
            // Attack action, 2 AP, 3 max range, 8 damage
            action::new_attack(b"Shoot".to_string(), 2, 3, 8),
            // Melee attack action, 3 AP, 1 max range, 10 damage
            action::new_attack(b"Melee".to_string(), 3, 1, 10),
            // Wait action, MAX AP
            action::new_skip(b"Wait".to_string(), 1),
        ],
        health: param::new(20),
        ap: param::new(6),
        current_turn: 0,
    }
}

/// Create a new "Barricade" `Unit`. Barricades are stationary units that can't
/// move or attack. They have high health and no action points.
///
/// Stats:
/// - Health: 100
/// - Action Points: 0
/// - Actions: None
/// - Symbol: "B"
public fun barricade(): Unit {
    Unit {
        symbol: b"B".to_string(),
        name: b"Barricade".to_string(),
        actions: vector[],
        health: param::new(100),
        ap: param::new(0),
        current_turn: 0,
    }
}

// === BCS ===

/// Deserialize a `Unit` from a byte array.
public fun from_bytes(bytes: vector<u8>): Unit {
    let mut bcs = bcs::new(bytes);
    let symbol = bcs.peel_vec!(|e| e.peel_u8()).to_string();
    let name = bcs.peel_vec!(|e| e.peel_u8()).to_string();
    let actions = bcs.peel_vec!(|bcs| action::from_bcs(bcs));
    let health = param::from_bcs(&mut bcs);
    let ap = param::from_bcs(&mut bcs);
    let current_turn = bcs.peel_u16();

    Unit { symbol, name, actions, health, ap, current_turn }
}

// === Turn System ===

/// Bump the turn counter.
public fun next_turn(unit: &mut Unit) {
    unit.current_turn = unit.current_turn + 1;
}

/// Get the current turn of the unit.
public fun current_turn(unit: &Unit): u16 { unit.current_turn }

// === Action System ===

/// Get the action at the given index.
public fun action(unit: &Unit, action_index: u16): Action {
    let idx = action_index as u64;
    assert!(idx < unit.actions.length());
    unit.actions[idx]
}

/// Get the action points (AP) of the unit.
public fun ap(unit: &Unit): &Param { &unit.ap }

/// Get the action points (AP) of the unit, mutably.
public fun ap_mut(unit: &mut Unit): &mut Param { &mut unit.ap }

/// Get the health of the unit.
public fun health(unit: &Unit): &Param { &unit.health }

/// Get the health of the unit, mutably.
public fun health_mut(unit: &mut Unit): &mut Param { &mut unit.health }

/// Get the symbol of the unit.
public fun symbol(unit: &Unit): String { unit.symbol }

/// Get the name of the unit.
public fun name(unit: &Unit): String { unit.name }

/// Used for pretty-printing the map. Returns the name of the unit.
public fun to_string(unit: &Unit): String { unit.name }
