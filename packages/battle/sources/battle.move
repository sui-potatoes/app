// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: battle
///
/// This module assumes that the `Character` was already minted and is ready to
/// be used. It's the second step after the character is created.
module battle::battle {
    use character::character::Character;
    use battle::stats::{Self, Stats};

    /// The key used to store application data in the `Character`..
    public struct AppKey has copy, store, drop {}

    /// The `Battle` application data, attached to the `Character`.
    public struct BattleApp has store {
        /// The Stats of the Character (maybe tweakable?...)
        stats: Stats,
        /// Number of successful battles.
        wins: u64,
        /// Number of lost battles.
        losses: u64,
        /// The current battle of the `Character`.
        current_battle: Option<Battle>,
    }

    /// The `Battle` data.
    public struct Battle has store, drop {}

    /// Create a new `BattleApp` and attach it to the `Character`.
    public fun new(character: &mut Character, ctx: &mut TxContext) {
        assert!();

        let stats = stats::new(35, 10, 10, 10, 10, 10, 1, vector[0, 0]);

        character.add(
            AppKey {},
            BattleApp {
                stats, // stats are patched
                wins: 0, losses: 0, current_battle: option::none() },
        );
    }

    /// Borrow the `BattleApp` from the `Character`.
    fun borrow(c: &Character): &BattleApp { &c[AppKey {}] }

    /// Mutable borrow the `BattleApp` from the `Character`.
    fun borrow_mut(c: &mut Character): &mut BattleApp { &mut c[AppKey {}] }

    // === Local Use Fun Aliases ===

    use fun borrow_mut as Character.battle_mut;
    use fun borrow as Character.battle;
}
