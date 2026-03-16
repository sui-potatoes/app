// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_const, unused_variable)]
module go_game::game;

use go_game::go::{Self, Board};
use std::string::String;
use sui::{clock::Clock, display, package, vec_set::{Self, VecSet}};

use fun go_game::render::svg as Board.to_svg;

/// The size of the board is invalid (not 9, 13, or 19)
const EInvalidSize: u64 = 0;
/// The game is full.
const EGameFull: u64 = 1;
/// It is not the player's turn.
const ENotYourTurn: u64 = 2;
/// The player is not in the game.
const ENotInGame: u64 = 3;
/// The other player hasn't quit the game.
const EQuitFirst: u64 = 4;

/// OTW for Display & Publisher.
public struct GAME has drop {}

/// An account in the game. Stores currently active games (can be more than
/// one at a time).
public struct Account has key {
    id: UID,
    games: VecSet<ID>,
}

/// Stores
public struct Players(Option<ID>, Option<ID>) has drop, store;

/// A single instance of the game.
public struct Game has key {
    id: UID,
    /// The Players,
    players: Players,
    /// The game state.
    board: Board,
    /// The players in the game.
    /// The SVG representation of the board.
    /// Updated on every move. Purely for demonstration purposes!
    image_blob: String,
    /// The time the game was created.
    created_at: u64,
    /// The time the second player joined the game.
    joined_at: Option<u64>,
}

/// Create a new account and send it to the sender.
public fun new_account(ctx: &mut TxContext): Account {
    Account { id: object::new(ctx), games: vec_set::empty() }
}

/// Keep the Account at the sender's address.
public fun keep(acc: Account, ctx: &TxContext) {
    transfer::transfer(acc, ctx.sender());
}

/// Start a new Game.
public fun new(acc: &mut Account, size: u8, clock: &Clock, ctx: &mut TxContext) {
    assert!(size == 9 || size == 13 || size == 19, EInvalidSize);

    let id = object::new(ctx);
    let board = go::new(size as u16);

    acc.games.insert(id.to_inner());

    transfer::share_object(Game {
        id,
        board: go::new(size as u16),
        players: Players(option::some(acc.id.to_inner()), option::none()),
        image_blob: board.to_svg().to_url(),
        created_at: clock.timestamp_ms(),
        joined_at: option::none(),
    });
}

/// Join an existing game. The game must not be full.
public fun join(game: &mut Game, acc: &mut Account, clock: &Clock, ctx: &mut TxContext) {
    let Players(p1, p2) = &mut game.players;

    assert!(p2.is_none(), EGameFull);

    // if this is my game, I can join it solo
    if (p1.is_some_and!(|p| p != acc.id.to_inner())) {
        acc.games.insert(game.id.to_inner());
    };

    game.joined_at = option::some(clock.timestamp_ms());
    p2.fill(acc.id.to_inner());
}

///
public fun play(
    game: &mut Game,
    cap: &Account,
    x: u16,
    y: u16,
    clock: &Clock,
    ctx: &mut TxContext,
) {
    assert!(cap.games.contains(game.id.as_inner()), ENotInGame);
    let Players(p1, p2) = &game.players;
    let is_p1 = p1.borrow() == cap.id.as_inner();
    let is_p2 = p2.borrow() == cap.id.as_inner();

    match (game.board.is_black_turn()) {
        true => assert!(is_p1, ENotYourTurn),
        false => assert!(is_p2, ENotYourTurn),
    };

    game.board.place(x, y);
    game.image_blob = game.board.to_svg().to_url();
}

public fun quit(game: &mut Game, acc: &mut Account) {
    let Players(p1, p2) = &mut game.players;

    if (p2.is_some() && p2.borrow() == acc.id.as_inner()) {
        let _id = p2.extract();
        acc.games.remove(game.id.as_inner());
    };

    if (p1.is_some() && p1.borrow() == acc.id.as_inner()) {
        let _id = p1.extract();
        acc.games.remove(game.id.as_inner());
    };
}

/// Wrap up the game if the second player has left.
public fun wrap_up(game: Game, acc: &mut Account, _ctx: &mut TxContext) {
    let Game { id, players, .. } = game;
    let Players(p1, p2) = players;
    let my_id = acc.id.as_inner();

    // I am playing with myself, I can wrap up the game
    if (p1.is_some_and!(|p| p == my_id) && p2.is_some_and!(|p| p == my_id)) {
        acc.games.remove(id.as_inner());
        id.delete();
        return
    };

    // one of the players must have left already
    assert!(p1.is_none() || p2.is_none(), EQuitFirst);

    if (p2.is_some()) acc.games.remove(id.as_inner());
    if (p1.is_some()) acc.games.remove(id.as_inner());

    id.delete();
}

/// Delete the account. Has to leave all games first.
public fun delete(account: Account, _ctx: &mut TxContext) {
    let Account { id, games } = account;
    assert!(games.is_empty(), EQuitFirst);
    id.delete();
}

#[allow(unused_function)]
fun board_state(game: &mut Game, x: u16, y: u16) {
    game.board.place(x, y);
}

///
fun init(otw: GAME, ctx: &mut TxContext) {
    let pub = package::claim(otw, ctx);
    let mut d = display::new<Game>(&pub, ctx);

    d.add(
        b"image_url".to_string(),
        b"data:image/svg+xml;charset=utf8,{image_blob}".to_string(),
    );
    d.add(b"name".to_string(), b"Go Game Board {id}".to_string());
    d.add(b"description".to_string(), b"{board.size}".to_string());
    d.add(b"link".to_string(), b"https://potatoes.app/go/{id}".to_string());
    d.add(b"project_url".to_string(), b"https://potatoes.app/".to_string());
    d.add(b"creator".to_string(), b"Sui Potatoes (c)".to_string());
    d.update_version();

    transfer::public_transfer(pub, ctx.sender());
    transfer::public_transfer(d, ctx.sender());
}
