// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_const, unused_variable)]
module gogame::game {
    use gogame::go::{Self, Board};

    /// The size of the board is invalid (not 9, 13, or 19)
    const EInvalidSize: u64 = 0;
    /// The game is full.
    const EGameFull: u64 = 1;
    /// It is not the player's turn.
    const ENotYourTurn: u64 = 2;
    /// The player is not in the game.
    const ENotInGame: u64 = 3;

    public struct PlayerCap has key { id: UID, board_id: ID }

    /// A single instance of the game.
    public struct Game has key {
        id: UID,
        /// The game state.
        board: Board,
        // The players in the game.
        // players: vector<address>,
        // The players who have passed.
        // passed: vector<address>,
    }

    public fun new(size: u8, ctx: &mut TxContext) {
        assert!(size == 9 || size == 13 || size == 19, EInvalidSize);

        let id = object::new(ctx);

        transfer::transfer(
            PlayerCap {
                id: object::new(ctx),
                board_id: id.to_inner()
            },
            ctx.sender()
        );

        transfer::share_object(Game {
            id,
            board: go::new(size),
            // players: vector[ ctx.sender() ],
            // passed: vector[ ]
        });
    }

    public fun play(game: &mut Game, cap: &PlayerCap, x: u8, y: u8, ctx: &mut TxContext) {
        assert!(&game.id.to_inner() == &cap.board_id, ENotInGame);
        game.board.place(x, y);
    }

    #[allow(unused_function)]
    fun board_state(game: &mut Game, x: u8, y: u8): Board {
        game.board.place(x, y);
        game.board
    }
}
