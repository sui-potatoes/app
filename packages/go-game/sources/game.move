// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_const, unused_variable)]
module go_game::game;

use go_game::go::{Self, Board};
use std::string::String;
use sui::{clock::Clock, display_registry::DisplayRegistry, vec_set::{Self, VecSet}};

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
/// The game is still registered in the registry.
const EGameStillRegistered: u64 = 5;
/// The game is not public.
const EGameNotPublic: u64 = 6;

/// OTW for Display & Publisher.
public struct GAME has drop {}

/// An event emitted when a game is searched for players.
public struct PlayerSearchEvent has copy, drop {
    game_id: ID,
}

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
    /// The time the game was created.
    created_at: u64,
    /// The time the second player joined the game.
    joined_at: Option<u64>,
    /// Whether the game is over.
    is_over: bool,
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
        created_at: clock.timestamp_ms(),
        joined_at: option::none(),
        is_over: false,
    });
}

/// A game can be made public by the owner.
public fun make_public(game: &mut Game, acc: &Account, ctx: &mut TxContext) {
    assert!(game.players.1.is_none(), EGameFull);
    sui::event::emit(PlayerSearchEvent { game_id: game.id.to_inner() });
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

    game.is_over = true;
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

entry fun create_display(r: &mut DisplayRegistry, ctx: &mut TxContext) {
    let (mut d, cap) = r.new<Game>(internal::permit(), ctx);
    d.set(&cap, "image_url", prepare_display());
    d.set(&cap, "name", "Game Go Board #{id}");
    d.set(&cap, "description", "Board: {board.size}x{board.size}");
    d.set(&cap, "link", "https://potatoes.app/go/{id}");
    d.set(&cap, "project_url", "https://potatoes.app/");
    d.set(&cap, "creator", "Sui Potatoes (c)");
    d.share();

    transfer::public_transfer(cap, ctx.sender());
}

fun prepare_display(): String {
    let mut header: String =
        "data:image/svg+xml,{'<svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 198 198\">':url}";
    header.append_utf8("{'<defs>':url}");
    header.append_utf8("{'<circle id=\"b\" fill=\"#000\" r=\"10\"/>':url}");
    header.append_utf8("{'<circle id=\"w\" fill=\"#fff\" stroke=\"#000\" r=\"10\"/>':url}");
    header.append_utf8(
        "{'<pattern id=\"g\" width=\"21\" height=\"21\" x=\"20\" y=\"20\" patternUnits=\"userSpaceOnUse\"><path d=\"M 40 0 L 0 0 0 40\" fill=\"none\" stroke=\"gray\" stroke-width=\"0.8\"/></pattern>':url}",
    );
    header.append_utf8("{'</defs>':url}");
    header.append_utf8("{'<rect fill=\"url(#g)\" width=\"198\" height=\"198\"/>':url}");

    // now the fun part: use vector indexing
    header.append_utf8("{board.rendered_rows[0u8]:url}");
    header.append_utf8("{board.rendered_rows[1u8]:url}");
    header.append_utf8("{board.rendered_rows[2u8]:url}");
    header.append_utf8("{board.rendered_rows[3u8]:url}");
    header.append_utf8("{board.rendered_rows[4u8]:url}");
    header.append_utf8("{board.rendered_rows[5u8]:url}");
    header.append_utf8("{board.rendered_rows[6u8]:url}");
    header.append_utf8("{board.rendered_rows[7u8]:url}");
    header.append_utf8("{board.rendered_rows[8u8]:url}");
    header.append_utf8("{board.rendered_rows[9u8] | '':url}");
    header.append_utf8("{board.rendered_rows[10u8] | '':url}");
    header.append_utf8("{board.rendered_rows[11u8] | '':url}");
    header.append_utf8("{board.rendered_rows[12u8] | '':url}");
    header.append_utf8("{board.rendered_rows[13u8] | '':url}");
    header.append_utf8("{board.rendered_rows[14u8] | '':url}");
    header.append_utf8("{board.rendered_rows[15u8] | '':url}");
    header.append_utf8("{board.rendered_rows[16u8] | '':url}");
    header.append_utf8("{board.rendered_rows[17u8] | '':url}");
    header.append_utf8("{board.rendered_rows[18u8] | '':url}");
    header.append_utf8("{'</svg>':url}");
    header
}

#[test]
fun t() {
    std::debug::print(&prepare_display());
}

/*
<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 198 198'>
<defs>
<circle id='b' fill='#000' r='10'/>
<circle id='w' fill='#fff' stroke='#000' r='10'/>
<pattern id='g' width='21' height='21' x='20' y='20' patternUnits='userSpaceOnUse'>
<path d='M 40 0 L 0 0 0 40' fill='none' stroke='gray' stroke-width='0.8'/>
</pattern>
</defs>
<rect fill='url(#g)' width='198' height='198'/>
</svg>
*/
