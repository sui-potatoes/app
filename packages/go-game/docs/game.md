
<a name="go_game_game"></a>

# Module `go_game::game`



-  [Struct `GAME`](#go_game_game_GAME)
-  [Struct `Account`](#go_game_game_Account)
-  [Struct `Players`](#go_game_game_Players)
-  [Struct `Game`](#go_game_game_Game)
-  [Constants](#@Constants_0)
-  [Function `new_account`](#go_game_game_new_account)
-  [Function `keep`](#go_game_game_keep)
-  [Function `new`](#go_game_game_new)
-  [Function `join`](#go_game_game_join)
-  [Function `play`](#go_game_game_play)
-  [Function `quit`](#go_game_game_quit)
-  [Function `wrap_up`](#go_game_game_wrap_up)
-  [Function `board_state`](#go_game_game_board_state)
-  [Function `init`](#go_game_game_init)


<pre><code><b>use</b> (codec=0x0)::base64;
<b>use</b> (codec=0x0)::urlencode;
<b>use</b> (grid=0x0)::cell;
<b>use</b> (grid=0x0)::grid;
<b>use</b> (svg=0x0)::animation;
<b>use</b> (svg=0x0)::container;
<b>use</b> (svg=0x0)::coordinate;
<b>use</b> (svg=0x0)::desc;
<b>use</b> (svg=0x0)::filter;
<b>use</b> (svg=0x0)::print;
<b>use</b> (svg=0x0)::shape;
<b>use</b> (svg=0x0)::svg;
<b>use</b> <a href="./go.md#go_game_go">go_game::go</a>;
<b>use</b> <a href="./render.md#go_game_render">go_game::render</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u32.md#std_u32">std::u32</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../../.doc-deps/sui/display.md#sui_display">sui::display</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
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
<code>image_blob: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 The players in the game.
 The SVG representation of the board.
 Updated on every move. Purely for demonstration purposes!
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


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new">new</a>(acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, size: u8, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_new">new</a>(acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>, size: u8, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(size == 9 || size == 13 || size == 19, <a href="./game.md#go_game_game_EInvalidSize">EInvalidSize</a>);
    <b>let</b> id = object::new(ctx);
    <b>let</b> board = <a href="./go.md#go_game_go_new">go::new</a>(size <b>as</b> u16);
    acc.games.insert(id.to_inner());
    transfer::share_object(<a href="./game.md#go_game_game_Game">Game</a> {
        id,
        board: <a href="./go.md#go_game_go_new">go::new</a>(size <b>as</b> u16),
        players: <a href="./game.md#go_game_game_Players">Players</a>(option::some(acc.id.to_inner()), option::none()),
        image_blob: board.to_svg().to_url(),
    });
}
</code></pre>



</details>

<a name="go_game_game_join"></a>

## Function `join`

Join an existing game. The game must not be full.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_join">join</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_join">join</a>(<a href="./game.md#go_game_game">game</a>: &<b>mut</b> <a href="./game.md#go_game_game_Game">Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = &<b>mut</b> <a href="./game.md#go_game_game">game</a>.players;
    <b>assert</b>!(p1.borrow() != acc.id.as_inner(), <a href="./game.md#go_game_game_EGameFull">EGameFull</a>);
    <b>assert</b>!(p2.is_none(), <a href="./game.md#go_game_game_EGameFull">EGameFull</a>);
    p2.fill(acc.id.to_inner());
    acc.games.insert(<a href="./game.md#go_game_game">game</a>.id.to_inner());
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
    <a href="./game.md#go_game_game">game</a>.image_blob = <a href="./game.md#go_game_game">game</a>.board.to_svg().to_url();
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
}
</code></pre>



</details>

<a name="go_game_game_wrap_up"></a>

## Function `wrap_up`

Wrap up the game if the second player has left.


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_wrap_up">wrap_up</a>(<a href="./game.md#go_game_game">game</a>: <a href="./game.md#go_game_game_Game">go_game::game::Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">go_game::game::Account</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./game.md#go_game_game_wrap_up">wrap_up</a>(<a href="./game.md#go_game_game">game</a>: <a href="./game.md#go_game_game_Game">Game</a>, acc: &<b>mut</b> <a href="./game.md#go_game_game_Account">Account</a>) {
    <b>let</b> <a href="./game.md#go_game_game_Game">Game</a> { id, board: _, players, image_blob: _ } = <a href="./game.md#go_game_game">game</a>;
    <b>let</b> <a href="./game.md#go_game_game_Players">Players</a>(p1, p2) = players;
    // one of the players must have left already
    <b>assert</b>!(p1.is_none() || p2.is_none(), <a href="./game.md#go_game_game_EQuitFirst">EQuitFirst</a>);
    <b>if</b> (p2.is_some()) acc.games.remove(id.as_inner());
    <b>if</b> (p1.is_some()) acc.games.remove(id.as_inner());
    id.delete();
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

<a name="go_game_game_init"></a>

## Function `init`



<pre><code><b>fun</b> <a href="./game.md#go_game_game_init">init</a>(otw: <a href="./game.md#go_game_game_GAME">go_game::game::GAME</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./game.md#go_game_game_init">init</a>(otw: <a href="./game.md#go_game_game_GAME">GAME</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> pub = package::claim(otw, ctx);
    <b>let</b> <b>mut</b> d = display::new&lt;<a href="./game.md#go_game_game_Game">Game</a>&gt;(&pub, ctx);
    d.add(
        b"image_url".to_string(),
        b"data:image/svg+xml;charset=utf8,{image_blob}".to_string(),
    );
    d.add(b"name".to_string(), b"Go <a href="./game.md#go_game_game_Game">Game</a> Board {id}".to_string());
    d.add(b"description".to_string(), b"{board.size}".to_string());
    d.add(b"link".to_string(), b"https://potatoes.app/<a href="./go.md#go_game_go">go</a>/{id}".to_string());
    d.add(b"project_url".to_string(), b"https://potatoes.app/".to_string());
    d.add(b"creator".to_string(), b"Sui Potatoes (c)".to_string());
    d.update_version();
    transfer::public_transfer(pub, ctx.sender());
    transfer::public_transfer(d, ctx.sender());
}
</code></pre>



</details>
