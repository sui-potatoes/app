
<a name="commander_commander"></a>

# Module `commander::commander`

The frontend module for the Commander game. Defines the <code><a href="./commander.md#commander_commander_Commander">Commander</a></code> object,
which is used to store recent games, their metadata and the map presets.

Additionally, handles the interaction between players, such as hosting a
game, joining it, canceling a game, etc.


-  [Struct `Commander`](#commander_commander_Commander)
-  [Struct `Preset`](#commander_commander_Preset)
-  [Struct `Host`](#commander_commander_Host)
-  [Struct `Game`](#commander_commander_Game)
-  [Constants](#@Constants_0)
-  [Function `publish_map`](#commander_commander_publish_map)
-  [Function `delete_map`](#commander_commander_delete_map)
-  [Function `host_game`](#commander_commander_host_game)
-  [Function `join_game`](#commander_commander_join_game)
-  [Function `new_game`](#commander_commander_new_game)
-  [Function `register_game`](#commander_commander_register_game)
-  [Function `destroy_game`](#commander_commander_destroy_game)
-  [Function `place_recruit`](#commander_commander_place_recruit)
-  [Function `move_unit`](#commander_commander_move_unit)
-  [Function `perform_reload`](#commander_commander_perform_reload)
-  [Function `perform_grenade`](#commander_commander_perform_grenade)
-  [Function `perform_attack`](#commander_commander_perform_attack)
-  [Function `next_turn`](#commander_commander_next_turn)
-  [Function `share`](#commander_commander_share)
-  [Function `turn`](#commander_commander_turn)
-  [Function `init`](#commander_commander_init)


<pre><code><b>use</b> <a href="./armor.md#commander_armor">commander::armor</a>;
<b>use</b> <a href="./history.md#commander_history">commander::history</a>;
<b>use</b> <a href="./map.md#commander_map">commander::map</a>;
<b>use</b> <a href="./param.md#commander_param">commander::param</a>;
<b>use</b> <a href="./rank.md#commander_rank">commander::rank</a>;
<b>use</b> <a href="./recruit.md#commander_recruit">commander::recruit</a>;
<b>use</b> <a href="./replay.md#commander_replay">commander::replay</a>;
<b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="./unit.md#commander_unit">commander::unit</a>;
<b>use</b> <a href="./weapon.md#commander_weapon">commander::weapon</a>;
<b>use</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade">commander::weapon_upgrade</a>;
<b>use</b> <a href="../../.doc-deps/grid/cell.md#grid_cell">grid::cell</a>;
<b>use</b> <a href="../../.doc-deps/grid/cursor.md#grid_cursor">grid::cursor</a>;
<b>use</b> <a href="../../.doc-deps/grid/grid.md#grid_grid">grid::grid</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u32.md#std_u32">std::u32</a>;
<b>use</b> <a href="../../.doc-deps/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_object_field.md#sui_dynamic_object_field">sui::dynamic_object_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/object_table.md#sui_object_table">sui::object_table</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/random.md#sui_random">sui::random</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="commander_commander_Commander"></a>

## Struct `Commander`

The main object of the game, controls the game state, configuration and
serves as the registry for all users and their recruits.


<pre><code><b>public</b> <b>struct</b> <a href="./commander.md#commander_commander_Commander">Commander</a> <b>has</b> key
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
<code>games: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>, u64&gt;</code>
</dt>
<dd>
 List of the 10 most recent games.
</dd>
</dl>


</details>

<a name="commander_commander_Preset"></a>

## Struct `Preset`

A preset is a map that is required to start a new game.


<pre><code><b>public</b> <b>struct</b> <a href="./commander.md#commander_commander_Preset">Preset</a> <b>has</b> key
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
<code><a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_Map">commander::map::Map</a></code>
</dt>
<dd>
 The map that will be cloned and used for the new game.
</dd>
<dt>
<code>name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 The name of the preset, purely for display purposes.
</dd>
<dt>
<code>positions: vector&lt;vector&lt;u8&gt;&gt;</code>
</dt>
<dd>
 Stores the spawn positions of recruits.
</dd>
<dt>
<code>author: <b>address</b></code>
</dt>
<dd>
 The author of the preset.
</dd>
<dt>
<code>popularity: u64</code>
</dt>
<dd>
 Popularity score.
</dd>
</dl>


</details>

<a name="commander_commander_Host"></a>

## Struct `Host`

Host is an object created to mark a hosted game. An account joining a hosted
game will consume this object and create a new <code><a href="./commander.md#commander_commander_Game">Game</a></code> with it.


<pre><code><b>public</b> <b>struct</b> <a href="./commander.md#commander_commander_Host">Host</a> <b>has</b> key
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
<code>game_id: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
<dt>
<code>timestamp_ms: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>host: <b>address</b></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="commander_commander_Game"></a>

## Struct `Game`

A single instance of the game. A <code><a href="./commander.md#commander_commander_Game">Game</a></code> object is created when a new game is
started, it contains the Map and the


<pre><code><b>public</b> <b>struct</b> <a href="./commander.md#commander_commander_Game">Game</a> <b>has</b> key
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
<code><a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_Map">commander::map::Map</a></code>
</dt>
<dd>
</dd>
<dt>
<code>players: vector&lt;<b>address</b>&gt;</code>
</dt>
<dd>
 The players in the game.
</dd>
<dt>
<code>positions: vector&lt;vector&lt;u8&gt;&gt;</code>
</dt>
<dd>
 The spawn positions of recruits.
</dd>
<dt>
<code><a href="./history.md#commander_history">history</a>: <a href="./history.md#commander_history_History">commander::history::History</a></code>
</dt>
<dd>
 History of the game.
</dd>
<dt>
<code>recruits: <a href="../../.doc-deps/sui/object_table.md#sui_object_table_ObjectTable">sui::object_table::ObjectTable</a>&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>, <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>&gt;</code>
</dt>
<dd>
 Temporarily stores recruits for the duration of the game.
 If recruits are KIA, they're "killed" upon removal from this table.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="commander_commander_ENotAuthor"></a>



<pre><code><b>const</b> <a href="./commander.md#commander_commander_ENotAuthor">ENotAuthor</a>: u64 = 0;
</code></pre>



<a name="commander_commander_ENotPlayer"></a>



<pre><code><b>const</b> <a href="./commander.md#commander_commander_ENotPlayer">ENotPlayer</a>: u64 = 1;
</code></pre>



<a name="commander_commander_EInvalidGame"></a>



<pre><code><b>const</b> <a href="./commander.md#commander_commander_EInvalidGame">EInvalidGame</a>: u64 = 2;
</code></pre>



<a name="commander_commander_ENotYourRecruit"></a>



<pre><code><b>const</b> <a href="./commander.md#commander_commander_ENotYourRecruit">ENotYourRecruit</a>: u64 = 3;
</code></pre>



<a name="commander_commander_ENoPositions"></a>



<pre><code><b>const</b> <a href="./commander.md#commander_commander_ENoPositions">ENoPositions</a>: u64 = 4;
</code></pre>



<a name="commander_commander_PUBLIC_GAMES_LIMIT"></a>

Stack limit of public games in the <code><a href="./commander.md#commander_commander_Commander">Commander</a></code> object.


<pre><code><b>const</b> <a href="./commander.md#commander_commander_PUBLIC_GAMES_LIMIT">PUBLIC_GAMES_LIMIT</a>: u64 = 20;
</code></pre>



<a name="commander_commander_publish_map"></a>

## Function `publish_map`

Register a new <code>Map</code> so it can be played.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_publish_map">publish_map</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_publish_map">publish_map</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>, name: String, bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <b>mut</b> bcs = bcs::new(bytes);
    <b>let</b> <b>mut</b> <a href="./map.md#commander_map">map</a> = <a href="./map.md#commander_map_from_bcs">map::from_bcs</a>(&<b>mut</b> bcs);
    <b>let</b> positions = bcs.peel_vec!(|bcs| bcs.peel_vec!(|bcs| bcs.peel_u8()));
    <b>let</b> id = object::new(ctx);
    <a href="./map.md#commander_map">map</a>.set_id(id.to_inner());
    transfer::transfer(
        <a href="./commander.md#commander_commander_Preset">Preset</a> { id, name, <a href="./map.md#commander_map">map</a>, positions, author: ctx.sender(), popularity: 0 },
        cmd.id.to_address(),
    );
}
</code></pre>



</details>

<a name="commander_commander_delete_map"></a>

## Function `delete_map`

Delete a map from the <code><a href="./commander.md#commander_commander_Commander">Commander</a></code> object. Can only be done by the author.
Once a <code><a href="./commander.md#commander_commander_Preset">Preset</a></code> is deleted, it makes <code>Replay</code>s of the game using that map invalid.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_delete_map">delete_map</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, preset: <a href="../../.doc-deps/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;<a href="./commander.md#commander_commander_Preset">commander::commander::Preset</a>&gt;, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_delete_map">delete_map</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>, preset: Receiving&lt;<a href="./commander.md#commander_commander_Preset">Preset</a>&gt;, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./commander.md#commander_commander_Preset">Preset</a> { id, <a href="./map.md#commander_map">map</a>, author, .. } = transfer::receive(&<b>mut</b> cmd.id, preset);
    <b>assert</b>!(author == ctx.sender(), <a href="./commander.md#commander_commander_ENotAuthor">ENotAuthor</a>);
    <a href="./map.md#commander_map">map</a>.destroy();
    id.delete();
}
</code></pre>



</details>

<a name="commander_commander_host_game"></a>

## Function `host_game`

Host a new game.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_host_game">host_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, preset: <a href="../../.doc-deps/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;<a href="./commander.md#commander_commander_Preset">commander::commander::Preset</a>&gt;, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_host_game">host_game</a>(
    cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>,
    clock: &Clock,
    preset: Receiving&lt;<a href="./commander.md#commander_commander_Preset">Preset</a>&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="./commander.md#commander_commander_Game">Game</a> {
    <b>let</b> <b>mut</b> preset = transfer::receive(&<b>mut</b> cmd.id, preset);
    preset.popularity = preset.popularity + 1; // increment popularity
    <b>let</b> name = preset.name;
    <b>let</b> <a href="./map.md#commander_map">map</a> = preset.<a href="./map.md#commander_map">map</a>.clone();
    <b>let</b> positions = preset.positions;
    <b>let</b> cmd_address = cmd.id.to_address();
    <b>let</b> timestamp_ms = clock.timestamp_ms();
    <b>let</b> id = object::new(ctx);
    transfer::transfer(preset, cmd_address);
    transfer::transfer(
        <a href="./commander.md#commander_commander_Host">Host</a> {
            id: object::new(ctx),
            game_id: id.to_inner(),
            name,
            timestamp_ms,
            host: ctx.sender(),
        },
        cmd_address,
    );
    <a href="./commander.md#commander_commander_Game">Game</a> {
        id,
        <a href="./map.md#commander_map">map</a>,
        positions,
        <a href="./history.md#commander_history">history</a>: <a href="./history.md#commander_history_empty">history::empty</a>(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
    }
}
</code></pre>



</details>

<a name="commander_commander_join_game"></a>

## Function `join_game`

Join a hosted game.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_join_game">join_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, host: <a href="../../.doc-deps/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;<a href="./commander.md#commander_commander_Host">commander::commander::Host</a>&gt;, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_join_game">join_game</a>(
    cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>,
    game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>,
    host: Receiving&lt;<a href="./commander.md#commander_commander_Host">Host</a>&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="./commander.md#commander_commander_Host">Host</a> { id, game_id, .. } = transfer::receive(&<b>mut</b> cmd.id, host);
    <b>assert</b>!(game_id == game.id.to_inner(), <a href="./commander.md#commander_commander_EInvalidGame">EInvalidGame</a>);
    game.players.push_back(ctx.sender());
    id.delete();
}
</code></pre>



</details>

<a name="commander_commander_new_game"></a>

## Function `new_game`

Start a new game with a custom map passed directly as a byte array.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_new_game">new_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, preset: <a href="../../.doc-deps/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;<a href="./commander.md#commander_commander_Preset">commander::commander::Preset</a>&gt;, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_new_game">new_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>, preset: Receiving&lt;<a href="./commander.md#commander_commander_Preset">Preset</a>&gt;, ctx: &<b>mut</b> TxContext): <a href="./commander.md#commander_commander_Game">Game</a> {
    <b>let</b> <b>mut</b> preset = transfer::receive(&<b>mut</b> cmd.id, preset);
    <b>let</b> <a href="./map.md#commander_map">map</a> = preset.<a href="./map.md#commander_map">map</a>.clone();
    <b>let</b> positions = preset.positions;
    preset.popularity = preset.popularity + 1; // increment popularity
    transfer::transfer(preset, cmd.id.to_address()); // transfer back
    <a href="./commander.md#commander_commander_Game">Game</a> {
        <a href="./map.md#commander_map">map</a>,
        id: object::new(ctx),
        <a href="./history.md#commander_history">history</a>: <a href="./history.md#commander_history_empty">history::empty</a>(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
        positions,
    }
}
</code></pre>



</details>

<a name="commander_commander_register_game"></a>

## Function `register_game`

Create a new public game, allowing anyone to spectate.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_register_game">register_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, clock: &<a href="../../.doc-deps/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, game: &<a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_register_game">register_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>, clock: &Clock, game: &<a href="./commander.md#commander_commander_Game">Game</a>, _ctx: &<b>mut</b> TxContext) {
    <b>if</b> (cmd.games.length() == <a href="./commander.md#commander_commander_PUBLIC_GAMES_LIMIT">PUBLIC_GAMES_LIMIT</a>) {
        // remove the oldest game, given that the VecMap is following the insertion order
        <b>let</b> (_, _) = cmd.games.remove_entry_by_idx(0);
    };
    cmd.games.insert(game.id.to_inner(), clock.timestamp_ms());
}
</code></pre>



</details>

<a name="commander_commander_destroy_game"></a>

## Function `destroy_game`

Destroy a game object, remove it from the registry's most recent if present.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_destroy_game">destroy_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">commander::commander::Commander</a>, game: <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, save_replay: bool, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_destroy_game">destroy_game</a>(cmd: &<b>mut</b> <a href="./commander.md#commander_commander_Commander">Commander</a>, game: <a href="./commander.md#commander_commander_Game">Game</a>, save_replay: bool, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="./commander.md#commander_commander_Game">Game</a> { id, <a href="./map.md#commander_map">map</a>, <b>mut</b> recruits, <a href="./history.md#commander_history">history</a>, players, .. } = game;
    <b>let</b> preset_id = <a href="./map.md#commander_map">map</a>.id();
    <a href="./map.md#commander_map">map</a>.destroy().do!(|<a href="./unit.md#commander_unit">unit</a>| transfer::public_transfer(recruits.remove(<a href="./unit.md#commander_unit">unit</a>), ctx.sender()));
    // only the players can destroy the game, no garbage collection
    <b>assert</b>!(players.any!(|player| player == ctx.sender()), <a href="./commander.md#commander_commander_ENotPlayer">ENotPlayer</a>);
    <b>if</b> (cmd.games.contains(id.as_inner())) { cmd.games.remove(id.as_inner()); };
    recruits.destroy_empty();
    // save the <a href="./replay.md#commander_replay">replay</a> <b>if</b> the flag is set
    <b>if</b> (save_replay) {
        transfer::public_transfer(<a href="./replay.md#commander_replay_new">replay::new</a>(preset_id, <a href="./history.md#commander_history">history</a>, ctx), ctx.sender());
    };
    id.delete();
}
</code></pre>



</details>

<a name="commander_commander_place_recruit"></a>

## Function `place_recruit`

Place a Recruit on the map, store it in the <code><a href="./commander.md#commander_commander_Game">Game</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_place_recruit">place_recruit</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, <a href="./recruit.md#commander_recruit">recruit</a>: <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_place_recruit">place_recruit</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>, <a href="./recruit.md#commander_recruit">recruit</a>: Recruit, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(<a href="./recruit.md#commander_recruit">recruit</a>.leader() == ctx.sender(), <a href="./commander.md#commander_commander_ENotYourRecruit">ENotYourRecruit</a>); // make sure the sender owns the <a href="./recruit.md#commander_recruit">recruit</a>
    <b>assert</b>!(game.positions.length() &gt; 0, <a href="./commander.md#commander_commander_ENoPositions">ENoPositions</a>);
    <b>let</b> position = game.positions.pop_back();
    <b>let</b> <a href="./history.md#commander_history">history</a> = game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_place_recruit">place_recruit</a>(&<a href="./recruit.md#commander_recruit">recruit</a>, position[0] <b>as</b> u16, position[1] <b>as</b> u16);
    game.recruits.add(object::id(&<a href="./recruit.md#commander_recruit">recruit</a>), <a href="./recruit.md#commander_recruit">recruit</a>);
    game.<a href="./history.md#commander_history">history</a>.add(<a href="./history.md#commander_history">history</a>);
}
</code></pre>



</details>

<a name="commander_commander_move_unit"></a>

## Function `move_unit`

Move a unit along the path, the first point is the current position of the unit.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_move_unit">move_unit</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, path: vector&lt;u8&gt;, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_move_unit">move_unit</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>, path: vector&lt;u8&gt;, _ctx: &<b>mut</b> TxContext) {
    game.<a href="./history.md#commander_history">history</a>.add(game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_move_unit">move_unit</a>(path))
}
</code></pre>



</details>

<a name="commander_commander_perform_reload"></a>

## Function `perform_reload`

Perform a reload action, replenishing ammo.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_reload">perform_reload</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, x: u16, y: u16, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_reload">perform_reload</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>, x: u16, y: u16, _ctx: &<b>mut</b> TxContext) {
    game.<a href="./history.md#commander_history">history</a>.add(game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_perform_reload">perform_reload</a>(x, y))
}
</code></pre>



</details>

<a name="commander_commander_perform_grenade"></a>

## Function `perform_grenade`

Perform a grenade throw action.


<pre><code><b>entry</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_grenade">perform_grenade</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, rng: &<a href="../../.doc-deps/sui/random.md#sui_random_Random">sui::random::Random</a>, x0: u16, y0: u16, x1: u16, y1: u16, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_grenade">perform_grenade</a>(
    game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <b>mut</b> rng = rng.new_generator(ctx);
    <b>let</b> <a href="./history.md#commander_history">history</a> = game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_perform_grenade">perform_grenade</a>(&<b>mut</b> rng, x0, y0, x1, y1);
    <a href="./history.md#commander_history_list_kia">history::list_kia</a>(&<a href="./history.md#commander_history">history</a>).do!(|id| {
        <b>let</b> <a href="./recruit.md#commander_recruit">recruit</a> = game.recruits.remove(id);
        <b>let</b> leader = <a href="./recruit.md#commander_recruit">recruit</a>.leader();
        transfer::public_transfer(<a href="./recruit.md#commander_recruit">recruit</a>.kill(ctx), leader);
    });
    game.<a href="./history.md#commander_history">history</a>.append(<a href="./history.md#commander_history">history</a>)
}
</code></pre>



</details>

<a name="commander_commander_perform_attack"></a>

## Function `perform_attack`

Perform an attack action.


<pre><code><b>entry</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_attack">perform_attack</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>, rng: &<a href="../../.doc-deps/sui/random.md#sui_random_Random">sui::random::Random</a>, x0: u16, y0: u16, x1: u16, y1: u16, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="./commander.md#commander_commander_perform_attack">perform_attack</a>(
    game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <b>mut</b> rng = rng.new_generator(ctx);
    <b>let</b> <a href="./history.md#commander_history">history</a> = game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_perform_attack">perform_attack</a>(&<b>mut</b> rng, x0, y0, x1, y1);
    <a href="./history.md#commander_history_list_kia">history::list_kia</a>(&<a href="./history.md#commander_history">history</a>).do!(|id| {
        <b>if</b> (id.to_address() == @0) <b>return</b>; // skip empty addresses
        <b>let</b> <a href="./recruit.md#commander_recruit">recruit</a> = game.recruits.remove(id);
        <b>let</b> leader = <a href="./recruit.md#commander_recruit">recruit</a>.leader();
        transfer::public_transfer(<a href="./recruit.md#commander_recruit">recruit</a>.kill(ctx), leader);
    });
    game.<a href="./history.md#commander_history">history</a>.append(<a href="./history.md#commander_history">history</a>)
}
</code></pre>



</details>

<a name="commander_commander_next_turn"></a>

## Function `next_turn`

Switch to the next turn.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_next_turn">next_turn</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_next_turn">next_turn</a>(game: &<b>mut</b> <a href="./commander.md#commander_commander_Game">Game</a>) {
    game.<a href="./history.md#commander_history">history</a>.add(game.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_next_turn">next_turn</a>());
}
</code></pre>



</details>

<a name="commander_commander_share"></a>

## Function `share`

Share the <code>key</code>-only object after placing Recruits on the map.


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_share">share</a>(game: <a href="./commander.md#commander_commander_Game">commander::commander::Game</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./commander.md#commander_commander_share">share</a>(game: <a href="./commander.md#commander_commander_Game">Game</a>) {
    transfer::share_object(game)
}
</code></pre>



</details>

<a name="commander_commander_turn"></a>

## Function `turn`

Get the current turn of the game.


<pre><code><b>fun</b> <a href="./commander.md#commander_commander_turn">turn</a>(self: &<a href="./commander.md#commander_commander_Game">commander::commander::Game</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander.md#commander_commander_turn">turn</a>(self: &<a href="./commander.md#commander_commander_Game">Game</a>): u16 { self.<a href="./map.md#commander_map">map</a>.<a href="./commander.md#commander_commander_turn">turn</a>() }
</code></pre>



</details>

<a name="commander_commander_init"></a>

## Function `init`

On publish, share the <code><a href="./commander.md#commander_commander_Commander">Commander</a></code> object with map presets. Demos have reserved IDs 0 and 1.


<pre><code><b>fun</b> <a href="./commander.md#commander_commander_init">init</a>(ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./commander.md#commander_commander_init">init</a>(ctx: &<b>mut</b> TxContext) {
    <b>let</b> id = object::new(ctx);
    <b>let</b> id_address = id.to_address();
    // prettier-ignore
    transfer::transfer({
        <b>let</b> id = object::new(ctx);
        <a href="./commander.md#commander_commander_Preset">Preset</a> {
            <a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_demo_1">map::demo_1</a>(id.to_inner()),
            name: b"Demo 1".to_string(),
            positions: vector[vector[0, 3], vector[6, 5]],
            popularity: 0,
            author: @0,
            id,
        }
    }, id_address);
    // prettier-ignore
    transfer::transfer({
        <b>let</b> id = object::new(ctx);
        <a href="./commander.md#commander_commander_Preset">Preset</a> {
            <a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_demo_2">map::demo_2</a>(id.to_inner()),
            name: b"Demo 2".to_string(),
            positions: vector[vector[8, 2], vector[7, 6], vector[1, 2], vector[1, 7]],
            author: @0,
            popularity: 0,
            id,
        }
    }, id_address);
    transfer::share_object(<a href="./commander.md#commander_commander_Commander">Commander</a> { id, games: vec_map::empty() });
}
</code></pre>



</details>
