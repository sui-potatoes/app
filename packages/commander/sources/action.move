// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the `Action` component and its methods.
module commander::action;

use std::string::String;
use sui::bcs::{Self, BCS};

#[error]
const EUnknownEnumVariant: vector<u8> = b"Unknown enum variant in BCS bytes";

#[error]
const ENotAttackAction: vector<u8> = b"Action is not an attack action";

/// A unit action. Actions can be performed by units and cost action points.
/// Each action has a name, cost, and type with action-specific data.
public struct Action has copy, store, drop {
    /// The name of the action. Purely cosmetic.
    name: String,
    /// The cost of the action in Action Points (AP).
    cost: u16,
    /// The type of the action, contains action-specific data.
    inner: ActionType,
}

/// Global action types that can be performed by units. A single unit can have
/// multiple actions, including the same action multiple times.
public enum ActionType has copy, store, drop {
    /// Perform an attack on a target within a certain range (depends on the
    /// unit type).
    Attack { max_range: u16, damage: u16 },
    /// Move the unit to a target location within walking distance.
    Move,
    /// Wait for the next turn.
    Skip,
}

/// Create a new `Skip` action with a name and cost.
public fun new_skip(name: String, cost: u16): Action {
    Action { name, cost, inner: ActionType::Skip }
}

/// Create a new `Move` action with a name, cost, and maximum range.
public fun new_move(name: String, cost: u16): Action {
    Action { name, cost, inner: ActionType::Move }
}

/// Create a new `Attack` action with a name, cost, maximum range, and damage.
/// The unit must be within the maximum range to perform the attack.
public fun new_attack(name: String, cost: u16, max_range: u16, damage: u16): Action {
    Action { name, cost, inner: ActionType::Attack { max_range, damage } }
}

/// Check if an action is an attack action.
public fun is_attack(action: &Action): bool {
    match (action.inner) {
        ActionType::Attack { .. } => true,
        _ => false,
    }
}

/// Check if an action is a move action.
public fun is_move(action: &Action): bool {
    match (action.inner) {
        ActionType::Move => true,
        _ => false,
    }
}

/// Check if an action is a skip action.
public fun is_skip(action: &Action): bool {
    match (action.inner) {
        ActionType::Skip => true,
        _ => false,
    }
}

/// Get the cost of an action in Action Points (AP).
public fun cost(action: &Action): u16 { action.cost }

/// Get the name of an action.
public fun name(action: &Action): String { action.name }

/// Returns `(max_range, damage)` for an attack action. Aborts if the action is not an attack.
public fun attack_params(action: &Action): (u16, u16) {
    match (action.inner) {
        ActionType::Attack { max_range, damage } => (max_range, damage),
        _ => abort ENotAttackAction,
    }
}

/// Deserialize BCS bytes into an action.
public fun from_bytes(data: vector<u8>): Action {
    let mut bcs = bcs::new(data);
    from_bcs(&mut bcs)
}

/// Helper method to allow `bcs::peel_vec!` in `Unit` deserialization.
public(package) fun from_bcs(bcs: &mut BCS): Action {
    let name = bcs.peel_vec!(|e| e.peel_u8()).to_string();
    let cost = bcs.peel_u16();
    let inner = match (bcs.peel_u8()) {
        0 => ActionType::Attack {
            max_range: bcs.peel_u16(),
            damage: bcs.peel_u16(),
        },
        1 => ActionType::Move,
        2 => ActionType::Skip,
        _ => abort EUnknownEnumVariant,
    };

    Action { name, cost, inner }
}

/// Convert an action to a `String` representation.
public fun to_string(action: &Action): String {
    let mut str = action.name;
    str.append_utf8(b" (");
    str.append(action.cost.to_string());
    str.append_utf8(b" AP)");
    str
}
