/// Module: game
module game::game {
    use sui::transfer::Receiving;

    const ROCK: u8 = 0;
    const PAPER: u8 = 1;
    const SCISSORS: u8 = 2;

    const LOSS: u8 = 0;
    const WIN: u8 = 1;

    /// Can't start new or join a game if the player is already playing.
    const EAlreadyPlaying: u64 = 0;
    /// Can't join a game if it's already full.
    const EMatchFull: u64 = 1;
    /// Can't cancel a game if the player isn't playing.
    const ENotPlaying: u64 = 2;
    /// Can't cancel a game if it has already started.
    const EMatchAlreadyStarted: u64 = 3;
    /// Can't cancel a game if it's not the player's game.
    const ENotYourGame: u64 = 4;
    /// Can't commit to a move if the player is alone in the game.
    const EYouAreAlone: u64 = 5;
    /// Can't commit to a move if the player has already committed.
    const EAlreadyCommitted: u64 = 6;
    /// Can't reveal a move if the other player hasn't committed yet.
    const EWaitingForOtherPlayer: u64 = 7;
    /// Can't reveal a move if the commitment doesn't match the hash.
    const EInvalidReveal: u64 = 8;
    /// Can't reveal a move if the move is invalid.
    const EInvalidMove: u64 = 9;

    /// Account is non transferable and stores the information about the game
    /// currently being played.
    ///
    /// We may want to limit how many accounts can be created per address, but
    /// for simplicity's sake we don't require a registry.
    public struct Account has key {
        id: UID,
        /// Currently played game.
        current_match: Option<ID>,
        /// Total number of wins; everyone loves stats.
        wins: u32,
        /// Total number of losses.
        losses: u32,
    }

    /// Shared match.
    public struct Game has key {
        id: UID,
        /// The Account.id of the host.
        host: Player,
        /// Guest player, once joined.
        guest: Option<Player>,
        /// Parameters of the game.
        params: MatchParams,
        /// History of the match, stores the winner of each round.
        history: vector<ID>,
        /// Current round.
        round: u8,
    }

    /// Temporary information about the player.
    public struct Player has store, drop {
        /// ID of the player.
        id: ID,
        /// The commitment to the move, first submitted and then revealed on
        /// the round end. This is a hash of the move and a random nonce.
        commitment: Option<vector<u8>>,
        /// The revealed move, for the second player to use in result calculation.
        next_move: Option<u8>,
    }

    /// Parameters of the match.
    public struct MatchParams has store, drop {
        /// Number of rounds to play.
        rounds: u8,
    }

    /// Result of the match.
    public struct Result has key {
        id: UID,
        /// Result of the match. 0 - loss, 1 - win.
        result: u8,
    }

    // === Events ===

    /// New match has been created.
    public struct NewGame (ID, u8) has copy, drop;

    // === New Account ===

    entry fun new_account(ctx: &mut TxContext) {
        transfer::transfer(Account {
            id: object::new(ctx),
            current_match: option::none(),
            wins: 0,
            losses: 0,
        }, ctx.sender())
    }

    // === New / Join / Cancel ===

    /// Start a new game by creating a new match.
    entry fun new_game(acc: &mut Account, rounds: u8, ctx: &mut TxContext) {
        assert!(acc.current_match.is_none(), EAlreadyPlaying);
        let id = object::new(ctx);
        acc.current_match.fill(id.to_inner());

        sui::event::emit(NewGame(id.to_inner(), rounds));

        transfer::share_object(Game {
            id,
            host: Player {
                id: acc.id.to_inner(),
                commitment: option::none(),
                next_move: option::none(),
            },
            guest: option::none(),
            params: MatchParams { rounds },
            history: vector[],
            round: 0,
        })
    }

    /// Join an active match as a guest.
    entry fun join_game(acc: &mut Account, game: &mut Game) {
        assert!(acc.current_match.is_none(), EAlreadyPlaying);
        assert!(game.guest.is_none(), EMatchFull);

        acc.current_match.fill(game.id.to_inner());
        game.guest.fill(Player {
            id: acc.id.to_inner(),
            commitment: option::none(),
            next_move: option::none(),
        });
    }

    /// Cancel a game if it hasn't started yet.
    entry fun cancel_game(acc: &mut Account, game: Game) {
        assert!(acc.current_match.is_some(), ENotPlaying);
        assert!(game.guest.is_none(), EMatchAlreadyStarted);
        assert!(acc.current_match.borrow() == object::borrow_id(&game), ENotYourGame);

        let Game { id, host: _, guest: _, params: _, history: _, round: _ } = game;
        id.delete();

        acc.current_match.extract();
    }

    // === Commit / Reveal ===

    /// Commit to a move for the current round.
    entry fun commit_move(acc: &Account, game: &mut Game, commitment: vector<u8>) {
        assert!(acc.current_match.borrow() == object::borrow_id(game), ENotYourGame);
        assert!(game.guest.is_some(), EYouAreAlone);

        let (player) = if (acc.id.to_inner() == game.host.id) {
            &mut game.host
        } else {
            game.guest.borrow_mut()
        };

        assert!(player.commitment.is_none(), EAlreadyCommitted);

        player.commitment.fill(commitment);
    }

    #[allow(lint(share_owned))]
    /// Reveal the move for the current round.
    entry fun reveal_move(
        acc: &mut Account, game: &mut Game, move_: u8, nonce: vector<u8>, ctx: &mut TxContext
    ) {
        assert!(move_ < 3, EInvalidMove);
        assert!(acc.current_match.borrow() == object::borrow_id(game), ENotYourGame);
        assert!(game.guest.is_some(), EYouAreAlone);

        let (player, other) = if (acc.id.to_inner() == game.host.id) {
            (&mut game.host, game.guest.borrow_mut())
        } else {
            (game.guest.borrow_mut(), &mut game.host)
        };

        assert!(player.commitment.is_some(), EAlreadyCommitted);
        assert!(other.commitment.is_some(), EWaitingForOtherPlayer);
        assert!(hash_move(move_, nonce) == player.commitment.borrow(), EInvalidReveal);

        player.commitment.extract();  // clear the commitment
        player.next_move.fill(move_); // store the revealed move

        // If both players have revealed their moves, calculate the result.
        if (other.next_move.is_some()) {
            let (player_move, other_move) = (
                player.next_move.extract(),
                other.next_move.extract()
            );

            let result = if (player_move == other_move) {
                @0x0.to_id()  // draw
            } else if (player_move == ROCK && other_move == SCISSORS ||
                       player_move == PAPER && other_move == ROCK ||
                       player_move == SCISSORS && other_move == PAPER) {
                player.id
            } else {
                other.id
            };

            game.history.push_back(result);

            // if its a draw, then we don't increment the round
            if (result.to_address() != @0x0) {
                game.round = game.round + 1;
            };

            // if the game is over, clear the match
            if (game.round == game.params.rounds) {

                // TODO: game calculation & cleanup

                // calculate the scores
                // let (mut host_score, mut guest_score) = (0, 0);
                // while (history.length() > 0) {
                //     let winner = history.pop_back();
                //     if (winner == host.id) {
                //         host_score = host_score + 1;
                //     } else if (winner == guest.borrow().id) {
                //         guest_score = guest_score + 1;
                //     }
                // };

                // let Game{
                //     id, host, guest, params: _, mut history, round: _
                // } = game;
                // id.delete();

                // // I am the host: update the scores + send the result to the guest
                // if (acc.id.to_inner() == host.id) {
                //     let result = if (host_score > guest_score) {
                //         acc.wins = acc.wins + 1;
                //         LOSS
                //     } else {
                //         acc.losses = acc.losses + 1;
                //         WIN
                //     };

                //     transfer::transfer(Result {
                //         id: object::new(ctx),
                //         result
                //     }, guest.borrow().id.to_address());
                // }
                // // I am the guest: update the scores + send the result to the host
                // else {
                //     let result = if (guest_score > host_score) {
                //         acc.wins = acc.wins + 1;
                //         LOSS
                //     } else {
                //         acc.losses = acc.losses + 1;
                //         WIN
                //     };

                //     transfer::transfer(Result {
                //         id: object::new(ctx),
                //         result
                //     }, host.id.to_address());
                // };

                // acc.current_match.extract(); // clear the current match
            }
        }
    }

    /// Accept the result of the match, update the scores and allow playing again.
    entry fun accept_result(acc: &mut Account, result: Receiving<Result>) {
        let Result { id, result } = transfer::receive(&mut acc.id, result);
        id.delete();
        if (result == WIN) {
            acc.wins = acc.wins + 1;
        } else {
            acc.losses = acc.losses + 1;
        };
        acc.current_match.extract();
    }

    /// Returns the hash of the move and the nonce; used for checking the revealed move.
    fun hash_move(move_: u8, nonce: vector<u8>): vector<u8> {
        let mut data = vector[];
        data.push_back(move_);
        data.append(nonce);
        sui::hash::blake2b256(&data)
    }

    #[test]
    fun test_the_game() {
        use sui::test_scenario;


    }
}
