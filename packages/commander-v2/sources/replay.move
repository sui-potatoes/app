// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Allows saving replays of games.
module commander::replay;

use commander::history::History;

/// Stores a replay of a game.
public struct Replay has key, store {
    id: UID,
    /// ID of the `Preset` object (or `@0-1` for demos).
    /// Allows fetching the Map and recreating the Game.
    preset_id: ID,
    /// The history of the game.
    history: History,
}

/// Create a new `Replay`.
public fun new(preset_id: ID, history: History, ctx: &mut TxContext): Replay {
    Replay { id: object::new(ctx), preset_id, history }
}

/// Delete a saved `Replay`.
public fun delete(replay: Replay) {
    let Replay { id, .. } = replay;
    id.delete();
}
