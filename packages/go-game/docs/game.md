
<a name="go_game_game"></a>

# Module `go_game::game`



-  [Struct `GAME`](#go_game_game_GAME)
-  [Struct `PlayerSearchEvent`](#go_game_game_PlayerSearchEvent)
-  [Struct `Account`](#go_game_game_Account)
-  [Struct `Players`](#go_game_game_Players)
-  [Struct `Game`](#go_game_game_Game)
-  [Constants](#@Constants_0)
-  [Function `new_account`](#go_game_game_new_account)
-  [Function `keep`](#go_game_game_keep)
-  [Function `new`](#go_game_game_new)
-  [Function `make_public`](#go_game_game_make_public)
-  [Function `join`](#go_game_game_join)
-  [Function `play`](#go_game_game_play)
-  [Function `quit`](#go_game_game_quit)
-  [Function `wrap_up`](#go_game_game_wrap_up)
-  [Function `delete`](#go_game_game_delete)
-  [Function `board_state`](#go_game_game_board_state)
-  [Function `create_display`](#go_game_game_create_display)
-  [Function `prepare_display`](#go_game_game_prepare_display)


<pre><code><b>use</b> <a href="./go.md#go_game_go">go_game::go</a>;
<b>use</b> <a href="../../.doc-deps/grid/cell.md#grid_cell">grid::cell</a>;
<b>use</b> <a href="../../.doc-deps/grid/grid.md#grid_grid">grid::grid</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/internal.md#std_internal">std::internal</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u32.md#std_u32">std::u32</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../../.doc-deps/sui/derived_object.md#sui_derived_object">sui::derived_object</a>;
<b>use</b> <a href="../../.doc-deps/sui/display.md#sui_display">sui::display</a>;
<b>use</b> <a href="../../.doc-deps/sui/display_registry.md#sui_display_registry">sui::display_registry</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/package.md#sui_package">sui::package</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/types.md#sui_types">sui::types</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_set.md#sui_vec_set">sui::vec_set</a>;
</code></pre>



<a name="go_game_game_GAME"></a>

## Struct `GAME`

OTW for Display & Publisher.


<pre><code><b>public</b> <b>struct</b> <a href="./game.md#go_game_game_GAME">GAME</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
</dl>


</details>

<a name="go_game_game_PlayerSearchEvent"></a>

## Struct `PlayerSearchEvent`

An event emitted when a game is searched for players.


<pre><code><b>public</b> <b>struct</b> <a href="./game.md#go_game_game_PlayerSearchEvent">PlayerSearchEvent</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>game_id: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="go_game_game_Account"></a>

## Struct `Account`

An account in the game. Stores currently active games (can be more than
one at a time).


<pre><code><b>public</b> <b>struct</b> <a href="./game.md#go_game_game_Account">Account</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../.doc-deps/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>games: <a href="../../.doc-deps/sui/vec_set.md#sui_vec_set_VecSet">sui::vec_set::VecSet</a>&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="go_game_game_Players"></a>

## Struct `Players`

Stores


<pre><code><b>public</b> <b>struct</b> <a href="./game.md#go_game_game_Players">Players</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>1: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="go_game_game_Game"></a>

## Struct `Game`

A single instance of the game.


<pre><code><b>public</b> <b>struct</b> <a href="./game.md#go_game_game_Game">Game</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../.doc-deps/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>players: <a href="./game.md#go_game_game_Players">go_game::game::Players</a></code>
</dt>
<dd>
 The Players,
</dd>
<dt>
<code>board: <a href="./go.md#go_game_go_Board">go_game::go::Board</a></code>
</dt>
<dd>
 The game state.
</dd>
<dt>
<code>created_at: u64</code>
</dt>
<dd>
 The time the game was created.
</dd>
<dt>
<code>joined_at: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;u64&gt;</code>
</dt>
<dd>
 The time the second player joined the game.
</dd>
<dt>
<code>is_over: bool</code>
</dt>
<dd>
 Whether the game is over.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="go_game_game_EInvalidSize"></a>

The size of the board is invalid (not 9, 13, or 19)


<pre><code><b>const</b> <a href="./game.md#go_game_game_EInvalidSize">EInvalidSize</a>: u64 = 0;
</code></pre>



<a name="go_game_game_EGameFull"></a>

The game is full.


<pre><code><b>const</b> <a href="./game.md#go_game_game_EGameFull">EGameFull</a>: u64 = 1;
</code></pre>



<a name="go_game_game_ENotYourTurn"></a>

It is not the player's turn.


<pre><code><b>const</b> <a href="./game.md#go_game_game_ENotYourTurn">ENotYourTurn</a>: u64 = 2;
</code></pre>



<a name="go_game_game_ENotInGame"></a>

The player is not in the game.


<pre><code><b>const</b> <a href="./game.md#go_game_game_ENotInGame">ENotInGame</a>: u64 = 3;
</code></pre>



<a name="go_game_game_EQuitFirst"></a>

The other player hasn't quit the game.


<pre><code><b>const</b> <a href="./game.md#go_game_game_EQuitFirst">EQuitFirst</a>: u64 = 4;
</code></pre>



<a name="go_game_game_EGameStillRegistered"></a>

The game is still registered in the registry.


<pre><code><b>const</b> <a href="./game.md#go_game_game_EGameStillRegistered">EGameStillRegistered</a>: u64 = 5;
</code></pre>



<a name="go_game_game_EGameNotPublic"></a>

The game is not public.


<pre><code><b>const</b> <a href="./game.md#go_game_game_EGameNotPublic">EGameNotPublic</a>: u64 = 6;
</code></pre>



<a name="go_game_game_new_account"></a>

## Function `new_account`

Create a new account and send it to the sender.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new_account">new_account</a>(ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./game.md#go_game_game_Account">go_game::game::Account</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new_account">new_account</a>(ctx: &<b>mut</b> TxContext): <a href="./game.md#go_game_game_Account">Account</a> {
    <a href="./game.md#go_game_game_Account">Account</a> { id: object::new(ctx), games: vec_set::empty() }
}
</code></pre>



</details>

<a name="go_game_game_keep"></a>

## Function `keep`

Keep the Account at the sender's address.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_keep">keep</a>(acc: <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, ctx: &<a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_keep">keep</a>(acc: <a href="./game.md#go_game_game_Account">Account</a>, ctx: &TxContext) {
    transfer::transfer(acc, ctx.sender());
}
</code></pre>



</details>

<a name="go_game_game_new"></a>

## Function `new`

Start a new Game.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new">new</a>(acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, size: u8, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new">new</a>(acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>, size: u8, clock: &Clock, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(size == 9 || size == 13 || size == 19, <a href="./game.md#go_game_game_EInvalidSize">EInvalidSize</a>);
    <b>let</b> id = object::new(ctx);
    <b>let</b> board = <a href="./go.md#go_game_go_new">go::new</a>(size <b>as</b> u16);
    acc.games.insert(id.to_inner());
    transfer::share_object(<a href="./game.md#go_game_game_Game">Game</a> {
        id,
        board: <a href="./go.md#go_game_go_new">go::new</a>(size <b>as</b> u16),
        players: <a href="./game.md#go_game_game_Players">Players</a>(option::some(acc.id.to_inner()), option::none()),
        created_at: clock.timestamp_ms(),
        joined_at: option::none(),
        is_over: <b>false</b>,
    });
}
</code></pre>



</details>

<a name="go_game_game_make_public"></a>

## Function `make_public`

A game can be made public by the owner.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_make_public">make_public</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<a href="./game.md#go_game_game_Account">go_game::game::Account</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_make_public">make_public</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>, acc: &<a href="./game.md#go_game_game_Account">Account</a>, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(<a href="./game.md#go_game_game">game</a>.players.1.is_none(), <a href="./game.md#go_game_game_EGameFull">EGameFull</a>);
    <a href="../../.doc-deps/sui/event.md#sui_event_emit">sui::event::emit</a>(<a href="./game.md#go_game_game_PlayerSearchEvent">PlayerSearchEvent</a> { game_id: <a href="./game.md#go_game_game">game</a>.id.to_inner() });
}
</code></pre>



</details>

<a name="go_game_game_join"></a>

## Function `join`

Join an existing game. The game must not be full.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_join">join</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_join">join</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>, clock: &Clock, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = &<b>mut</b> <a href="./game.md#go_game_game">game</a>.players;
    <b>assert</b>!(p2.is_none(), <a href="./game.md#go_game_game_EGameFull">EGameFull</a>);
    // <b>if</b> this is my <a href="./game.md#go_game_game">game</a>, I can <a href="./game.md#go_game_game_join">join</a> it solo
    <b>if</b> (p1.is_some_and!(|p| p != acc.id.to_inner())) {
        acc.games.insert(<a href="./game.md#go_game_game">game</a>.id.to_inner());
    };
    <a href="./game.md#go_game_game">game</a>.joined_at = option::some(clock.timestamp_ms());
    p2.fill(acc.id.to_inner());
}
</code></pre>



</details>

<a name="go_game_game_play"></a>

## Function `play`



<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_play">play</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, cap: &<a href="./game.md#go_game_game_Account">go_game::game::Account</a>, x: u16, y: u16, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_play">play</a>(
    <a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>,
    cap: &<a href="./game.md#go_game_game_Account">Account</a>,
    x: u16,
    y: u16,
    clock: &Clock,
    ctx: &<b>mut</b> TxContext,
) {
    <b>assert</b>!(cap.games.contains(<a href="./game.md#go_game_game">game</a>.id.as_inner()), <a href="./game.md#go_game_game_ENotInGame">ENotInGame</a>);
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = &<a href="./game.md#go_game_game">game</a>.players;
    <b>let</b> is_p1 = p1.borrow() == cap.id.as_inner();
    <b>let</b> is_p2 = p2.borrow() == cap.id.as_inner();
    match (<a href="./game.md#go_game_game">game</a>.board.is_black_turn()) {
        <b>true</b> =&gt; <b>assert</b>!(is_p1, <a href="./game.md#go_game_game_ENotYourTurn">ENotYourTurn</a>),
        <b>false</b> =&gt; <b>assert</b>!(is_p2, <a href="./game.md#go_game_game_ENotYourTurn">ENotYourTurn</a>),
    };
    <a href="./game.md#go_game_game">game</a>.board.place(x, y);
}
</code></pre>



</details>

<a name="go_game_game_quit"></a>

## Function `quit`



<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_quit">quit</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_quit">quit</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>) {
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = &<b>mut</b> <a href="./game.md#go_game_game">game</a>.players;
    <b>if</b> (p2.is_some() && p2.borrow() == acc.id.as_inner()) {
        <b>let</b> _id = p2.extract();
        acc.games.remove(<a href="./game.md#go_game_game">game</a>.id.as_inner());
    };
    <b>if</b> (p1.is_some() && p1.borrow() == acc.id.as_inner()) {
        <b>let</b> _id = p1.extract();
        acc.games.remove(<a href="./game.md#go_game_game">game</a>.id.as_inner());
    };
    <a href="./game.md#go_game_game">game</a>.is_over = <b>true</b>;
}
</code></pre>



</details>

<a name="go_game_game_wrap_up"></a>

## Function `wrap_up`

Wrap up the game if the second player has left.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_wrap_up">wrap_up</a>(<a href="./game.md#go_game_game">game</a>: <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_wrap_up">wrap_up</a>(<a href="./game.md#go_game_game">game</a>: <a href="./game.md#go_game_game_Game">Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>, _ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./game.md#go_game_game_Game">Game</a> { id, players, .. } = <a href="./game.md#go_game_game">game</a>;
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = players;
    <b>let</b> my_id = acc.id.as_inner();
    // I am playing with myself, I can wrap up the <a href="./game.md#go_game_game">game</a>
    <b>if</b> (p1.is_some_and!(|p| p == my_id) && p2.is_some_and!(|p| p == my_id)) {
        acc.games.remove(id.as_inner());
        id.<a href="./game.md#go_game_game_delete">delete</a>();
        <b>return</b>
    };
    // one of the players must have left already
    <b>assert</b>!(p1.is_none() || p2.is_none(), <a href="./game.md#go_game_game_EQuitFirst">EQuitFirst</a>);
    <b>if</b> (p2.is_some()) acc.games.remove(id.as_inner());
    <b>if</b> (p1.is_some()) acc.games.remove(id.as_inner());
    id.<a href="./game.md#go_game_game_delete">delete</a>();
}
</code></pre>



</details>

<a name="go_game_game_delete"></a>

## Function `delete`

Delete the account. Has to leave all games first.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_delete">delete</a>(account: <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_delete">delete</a>(account: <a href="./game.md#go_game_game_Account">Account</a>, _ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./game.md#go_game_game_Account">Account</a> { id, games } = account;
    <b>assert</b>!(games.is_empty(), <a href="./game.md#go_game_game_EQuitFirst">EQuitFirst</a>);
    id.<a href="./game.md#go_game_game_delete">delete</a>();
}
</code></pre>



</details>

<a name="go_game_game_board_state"></a>

## Function `board_state`



<pre><code><b>fun</b> <a href="./game.md#go_game_game_board_state">board_state</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, x: u16, y: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./game.md#go_game_game_board_state">board_state</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>, x: u16, y: u16) {
    <a href="./game.md#go_game_game">game</a>.board.place(x, y);
}
</code></pre>



</details>

<a name="go_game_game_create_display"></a>

## Function `create_display`



<pre><code><b>entry</b> <b>fun</b> <a href="./game.md#go_game_game_create_display">create_display</a>(r: &<b>mut</b> <a href="../../.doc-deps/sui/display_registry.md#sui_display_registry_DisplayRegistry">sui::display_registry::DisplayRegistry</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="./game.md#go_game_game_create_display">create_display</a>(r: &<b>mut</b> DisplayRegistry, ctx: &<b>mut</b> TxContext) {
    <b>let</b> (<b>mut</b> d, cap) = r.<a href="./game.md#go_game_game_new">new</a>&lt;<a href="./game.md#go_game_game_Game">Game</a>&gt;(internal::permit(), ctx);
    d.set(&cap, "image_url", <a href="./game.md#go_game_game_prepare_display">prepare_display</a>());
    d.set(&cap, "name", "<a href="./game.md#go_game_game_Game">Game</a> Go Board #{id}");
    d.set(&cap, "description", "Board: {board.size}x{board.size}");
    d.set(&cap, "link", "https://potatoes.app/<a href="./go.md#go_game_go">go</a>/{id}");
    d.set(&cap, "project_url", "https://potatoes.app/");
    d.set(&cap, "creator", "Sui Potatoes (c)");
    d.share();
    transfer::public_transfer(cap, ctx.sender());
}
</code></pre>



</details>

<a name="go_game_game_prepare_display"></a>

## Function `prepare_display`



<pre><code><b>fun</b> <a href="./game.md#go_game_game_prepare_display">prepare_display</a>(): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./game.md#go_game_game_prepare_display">prepare_display</a>(): String {
    <b>let</b> <b>mut</b> header: String =
        "data:image/svg+xml,{'&lt;svg xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 198 198\"&gt;':url}";
    header.append_utf8("{'&lt;defs&gt;':url}");
    header.append_utf8("{'&lt;circle id=\"b\" fill=\"#000\" r=\"10\"/&gt;':url}");
    header.append_utf8("{'&lt;circle id=\"w\" fill=\"#fff\" stroke=\"#000\" r=\"10\"/&gt;':url}");
    header.append_utf8(
        "{'&lt;pattern id=\"g\" width=\"21\" height=\"21\" x=\"20\" y=\"20\" patternUnits=\"userSpaceOnUse\"&gt;&lt;path d=\"M 40 0 L 0 0 0 40\" fill=\"none\" stroke=\"gray\" stroke-width=\"0.8\"/&gt;&lt;/pattern&gt;':url}",
    );
    header.append_utf8("{'&lt;/defs&gt;':url}");
    header.append_utf8("{'&lt;rect fill=\"url(#g)\" width=\"198\" height=\"198\"/&gt;':url}");
    // now the <b>fun</b> part: <b>use</b> vector indexing
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
    header.append_utf8("{'&lt;/svg&gt;':url}");
    header
}
</code></pre>



</details>
