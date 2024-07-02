// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// The game module contains the main game logic.
module mine_dungeon::game {
    use sui::{table::{Self, Table}};

    use mine_dungeon::{game_master::GameMaster};

    // === Errors ===

    const EOneGamePerPlayer: u64 = 0;
    const EInvalidDifficultyScalar: u64 = 1;

    // === Constants ===

    const INITIAL_DIFFICULTY_SCALAR: u64 = 20_000;
    const MAX_DIFFICULTY_SCALAR: u64 = 1_000_000;

    // === Structs ===

    public struct Registry has key {
        id: UID,
        users: Table<address, address>,
        difficulty_scalar: u64,
    }

    public struct Game has key {
        id: UID,
        level: u8,
        difficulty_scalar: u64,
    }

    // === Public Mutative Function ===

    fun init(ctx: &mut TxContext) {
        transfer::share_object(Registry {
            id: object::new(ctx),
            users: table::new(ctx),
            difficulty_scalar: INITIAL_DIFFICULTY_SCALAR,
        });
    }

    public fun new(registry: &mut Registry, ctx: &mut TxContext) {
        assert!(!registry.users.contains(ctx.sender()), EOneGamePerPlayer);

        transfer::transfer(
            Game { id: object::new(ctx), level: 0, difficulty_scalar: registry.difficulty_scalar },
            ctx.sender(),
        )
    }

    // === Admin Only Function ===

    public fun set_difficulty_scalar(self: &mut Registry, _: &GameMaster, difficulty_scalar: u64) {
        assert!(MAX_DIFFICULTY_SCALAR >= difficulty_scalar, EInvalidDifficultyScalar);
        
        self.difficulty_scalar = difficulty_scalar;
    }

    // === Package Only Function ===

    public(package) fun level(self: &Game): u8 {
        self.level
    }

    public(package) fun difficulty_scalar(self: &Game): u64 {
        self.difficulty_scalar
    }

    public(package) fun win(self: &mut Game) {
        self.level = self.level + 1;
    }
}
