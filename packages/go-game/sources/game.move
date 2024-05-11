// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

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

    /// A single instance of the game.
    public struct Game has key {
        id: UID,
        /// The game state.
        board: Board,
        /// The players in the game.
        players: vector<address>,
        /// The players who have passed.
        passed: vector<address>,
    }

    public fun new(size: u8, ctx: &mut TxContext) {
        assert!(size == 9 || size == 13 || size == 19, EInvalidSize);

        transfer::share_object(Game {
            id: object::new(ctx),
            board: go::new(size),
            players: vector[ ctx.sender() ],
            passed: vector[ ]
        });
    }

    public fun join_game(game: &mut Game, ctx: &mut TxContext) {
        assert!(game.players.length() < 2, EGameFull);
        game.players.push_back(ctx.sender());
    }

    public fun play(game: &mut Game, x: u8, y: u8, ctx: &mut TxContext) {
        let current_player = game.players.pop_back();
        assert!(current_player == ctx.sender(), ENotYourTurn);
        assert!(game.passed.length() < 2, 1);
        go::place(&mut game.board, x, y);
        game.players.insert(current_player, 0);
    }

    public fun pass(game: &mut Game, ctx: &mut TxContext) {
        assert!(game.players.contains(&ctx.sender()), ENotInGame);
        assert!(game.passed.length() < 2, 1);
        game.players.swap(0, 1);
        game.passed.push_back(ctx.sender());
    }
}
