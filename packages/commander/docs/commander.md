
<a name="(commander=0x0)_commander"></a>

# Module `(commander=0x0)::commander`

The frontend module for the Commander game. Defines the <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a></code> object,
which is used to store recent games, their metadata and the map presets.

Additionally, handles the interaction between players, such as hosting a
game, joining it, canceling a game, etc.


-  [Struct `Commander`](#(commander=0x0)_commander_Commander)
-  [Struct `Preset`](#(commander=0x0)_commander_Preset)
-  [Struct `Host`](#(commander=0x0)_commander_Host)
-  [Struct `Game`](#(commander=0x0)_commander_Game)
-  [Constants](#@Constants_0)
-  [Function `publish_map`](#(commander=0x0)_commander_publish_map)
-  [Function `delete_map`](#(commander=0x0)_commander_delete_map)
-  [Function `host_game`](#(commander=0x0)_commander_host_game)
-  [Function `join_game`](#(commander=0x0)_commander_join_game)
-  [Function `new_game`](#(commander=0x0)_commander_new_game)
-  [Function `register_game`](#(commander=0x0)_commander_register_game)
-  [Function `destroy_game`](#(commander=0x0)_commander_destroy_game)
-  [Function `place_recruit`](#(commander=0x0)_commander_place_recruit)
-  [Function `move_unit`](#(commander=0x0)_commander_move_unit)
-  [Function `perform_reload`](#(commander=0x0)_commander_perform_reload)
-  [Function `perform_grenade`](#(commander=0x0)_commander_perform_grenade)
-  [Function `perform_attack`](#(commander=0x0)_commander_perform_attack)
-  [Function `next_turn`](#(commander=0x0)_commander_next_turn)
-  [Function `share`](#(commander=0x0)_commander_share)
-  [Function `turn`](#(commander=0x0)_commander_turn)
-  [Function `init`](#(commander=0x0)_commander_init)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history">history</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map">map</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param">param</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/replay.md#(commander=0x0)_replay">replay</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade">weapon_upgrade</a>;
<b>use</b> (grid=0x0)::cursor;
<b>use</b> (grid=0x0)::grid;
<b>use</b> (grid=0x0)::point;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../dependencies/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/clock.md#sui_clock">sui::clock</a>;
<b>use</b> <a href="../dependencies/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../dependencies/sui/dynamic_object_field.md#sui_dynamic_object_field">sui::dynamic_object_field</a>;
<b>use</b> <a href="../dependencies/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/object_table.md#sui_object_table">sui::object_table</a>;
<b>use</b> <a href="../dependencies/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../dependencies/sui/random.md#sui_random">sui::random</a>;
<b>use</b> <a href="../dependencies/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../dependencies/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../dependencies/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="(commander=0x0)_commander_Commander"></a>

## Struct `Commander`

The main object of the game, controls the game state, configuration and
serves as the registry for all users and their recruits.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>games: <a href="../dependencies/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>, u64&gt;</code>
</dt>
<dd>
 List of the 10 most recent games.
</dd>
</dl>


</details>

<a name="(commander=0x0)_commander_Preset"></a>

## Struct `Preset`

A preset is a map that is required to start a new game.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code><a href="../name_gen/map.md#(commander=0x0)_map">map</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a></code>
</dt>
<dd>
 The map that will be cloned and used for the new game.
</dd>
<dt>
<code>name: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
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

<a name="(commander=0x0)_commander_Host"></a>

## Struct `Host`

Host is an object created to mark a hosted game. An account joining a hosted
game will consume this object and create a new <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a></code> with it.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Host">Host</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>game_id: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>name: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
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

<a name="(commander=0x0)_commander_Game"></a>

## Struct `Game`

A single instance of the game. A <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a></code> object is created when a new game is
started, it contains the Map and the


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code><a href="../name_gen/map.md#(commander=0x0)_map">map</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a></code>
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
<code><a href="../name_gen/history.md#(commander=0x0)_history">history</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a></code>
</dt>
<dd>
 History of the game.
</dd>
<dt>
<code>recruits: <a href="../dependencies/sui/object_table.md#sui_object_table_ObjectTable">sui::object_table::ObjectTable</a>&lt;<a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>, (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>&gt;</code>
</dt>
<dd>
 Temporarily stores recruits for the duration of the game.
 If recruits are KIA, they're "killed" upon removal from this table.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(commander=0x0)_commander_ENotAuthor"></a>



<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotAuthor">ENotAuthor</a>: u64 = 0;
</code></pre>



<a name="(commander=0x0)_commander_ENotPlayer"></a>



<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotPlayer">ENotPlayer</a>: u64 = 1;
</code></pre>



<a name="(commander=0x0)_commander_EInvalidGame"></a>



<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_EInvalidGame">EInvalidGame</a>: u64 = 2;
</code></pre>



<a name="(commander=0x0)_commander_ENotYourRecruit"></a>



<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotYourRecruit">ENotYourRecruit</a>: u64 = 3;
</code></pre>



<a name="(commander=0x0)_commander_ENoPositions"></a>



<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_ENoPositions">ENoPositions</a>: u64 = 4;
</code></pre>



<a name="(commander=0x0)_commander_PUBLIC_GAMES_LIMIT"></a>

Stack limit of public games in the <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a></code> object.


<pre><code><b>const</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_PUBLIC_GAMES_LIMIT">PUBLIC_GAMES_LIMIT</a>: u64 = 20;
</code></pre>



<a name="(commander=0x0)_commander_publish_map"></a>

## Function `publish_map`

Register a new <code>Map</code> so it can be played.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_publish_map">publish_map</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, name: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>, bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_publish_map">publish_map</a>(cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>, name: String, bytes: vector&lt;u8&gt;, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <b>mut</b> bcs = bcs::new(bytes);
    <b>let</b> <b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a> = <a href="../name_gen/map.md#(commander=0x0)_map_from_bcs">map::from_bcs</a>(&<b>mut</b> bcs);
    <b>let</b> positions = bcs.peel_vec!(|bcs| bcs.peel_vec!(|bcs| bcs.peel_u8()));
    <b>let</b> id = object::new(ctx);
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.set_id(id.to_inner());
    transfer::transfer(
        <a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a> { id, name, <a href="../name_gen/map.md#(commander=0x0)_map">map</a>, positions, author: ctx.sender(), popularity: 0 },
        cmd.id.to_address(),
    );
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_delete_map"></a>

## Function `delete_map`

Delete a map from the <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a></code> object. Can only be done by the author.
Once a <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a></code> is deleted, it makes <code>Replay</code>s of the game using that map invalid.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_delete_map">delete_map</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, preset: <a href="../dependencies/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Preset&gt;, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_delete_map">delete_map</a>(cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>, preset: Receiving&lt;<a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a>&gt;, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a> { id, <a href="../name_gen/map.md#(commander=0x0)_map">map</a>, author, .. } = transfer::receive(&<b>mut</b> cmd.id, preset);
    <b>assert</b>!(author == ctx.sender(), <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotAuthor">ENotAuthor</a>);
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.destroy();
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_host_game"></a>

## Function `host_game`

Host a new game.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_host_game">host_game</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, clock: &<a href="../dependencies/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, preset: <a href="../dependencies/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Preset&gt;, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_host_game">host_game</a>(
    cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>,
    clock: &Clock,
    preset: Receiving&lt;<a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a>&gt;,
    ctx: &<b>mut</b> TxContext,
): <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> {
    <b>let</b> <b>mut</b> preset = transfer::receive(&<b>mut</b> cmd.id, preset);
    preset.popularity = preset.popularity + 1; // increment popularity
    <b>let</b> name = preset.name;
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a> = preset.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.clone();
    <b>let</b> positions = preset.positions;
    <b>let</b> cmd_address = cmd.id.to_address();
    <b>let</b> timestamp_ms = clock.timestamp_ms();
    <b>let</b> id = object::new(ctx);
    transfer::transfer(preset, cmd_address);
    transfer::transfer(
        <a href="../name_gen/commander.md#(commander=0x0)_commander_Host">Host</a> {
            id: object::new(ctx),
            game_id: id.to_inner(),
            name,
            timestamp_ms,
            host: ctx.sender(),
        },
        cmd_address,
    );
    <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> {
        id,
        <a href="../name_gen/map.md#(commander=0x0)_map">map</a>,
        positions,
        <a href="../name_gen/history.md#(commander=0x0)_history">history</a>: <a href="../name_gen/history.md#(commander=0x0)_history_empty">history::empty</a>(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_join_game"></a>

## Function `join_game`

Join a hosted game.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_join_game">join_game</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, host: <a href="../dependencies/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Host&gt;, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_join_game">join_game</a>(
    cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>,
    game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>,
    host: Receiving&lt;<a href="../name_gen/commander.md#(commander=0x0)_commander_Host">Host</a>&gt;,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Host">Host</a> { id, game_id, .. } = transfer::receive(&<b>mut</b> cmd.id, host);
    <b>assert</b>!(game_id == game.id.to_inner(), <a href="../name_gen/commander.md#(commander=0x0)_commander_EInvalidGame">EInvalidGame</a>);
    game.players.push_back(ctx.sender());
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_new_game"></a>

## Function `new_game`

Start a new game with a custom map passed directly as a byte array.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_new_game">new_game</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, preset: <a href="../dependencies/sui/transfer.md#sui_transfer_Receiving">sui::transfer::Receiving</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Preset&gt;, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_new_game">new_game</a>(cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>, preset: Receiving&lt;<a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a>&gt;, ctx: &<b>mut</b> TxContext): <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> {
    <b>let</b> <b>mut</b> preset = transfer::receive(&<b>mut</b> cmd.id, preset);
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a> = preset.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.clone();
    <b>let</b> positions = preset.positions;
    preset.popularity = preset.popularity + 1; // increment popularity
    transfer::transfer(preset, cmd.id.to_address()); // transfer back
    <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> {
        <a href="../name_gen/map.md#(commander=0x0)_map">map</a>,
        id: object::new(ctx),
        <a href="../name_gen/history.md#(commander=0x0)_history">history</a>: <a href="../name_gen/history.md#(commander=0x0)_history_empty">history::empty</a>(),
        recruits: object_table::new(ctx),
        players: vector[ctx.sender()],
        positions,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_register_game"></a>

## Function `register_game`

Create a new public game, allowing anyone to spectate.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_register_game">register_game</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, clock: &<a href="../dependencies/sui/clock.md#sui_clock_Clock">sui::clock::Clock</a>, game: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, _ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_register_game">register_game</a>(cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>, clock: &Clock, game: &<a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>, _ctx: &<b>mut</b> TxContext) {
    <b>if</b> (cmd.games.size() == <a href="../name_gen/commander.md#(commander=0x0)_commander_PUBLIC_GAMES_LIMIT">PUBLIC_GAMES_LIMIT</a>) {
        // remove the oldest game, given that the VecMap is following the insertion order
        <b>let</b> (_, _) = cmd.games.remove_entry_by_idx(0);
    };
    cmd.games.insert(game.id.to_inner(), clock.timestamp_ms());
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_destroy_game"></a>

## Function `destroy_game`

Destroy a game object, remove it from the registry's most recent if present.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_destroy_game">destroy_game</a>(cmd: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Commander, game: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, save_replay: bool, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_destroy_game">destroy_game</a>(cmd: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a>, game: <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>, save_replay: bool, ctx: &<b>mut</b> TxContext) {
    <b>let</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a> { id, <a href="../name_gen/map.md#(commander=0x0)_map">map</a>, <b>mut</b> recruits, <a href="../name_gen/history.md#(commander=0x0)_history">history</a>, players, .. } = game;
    <b>let</b> preset_id = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.id();
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.destroy().do!(|<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>| transfer::public_transfer(recruits.remove(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>), ctx.sender()));
    // only the players can destroy the game, no garbage collection
    <b>assert</b>!(players.any!(|player| player == ctx.sender()), <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotPlayer">ENotPlayer</a>);
    <b>if</b> (cmd.games.contains(id.as_inner())) { cmd.games.remove(id.as_inner()); };
    recruits.destroy_empty();
    // save the <a href="../name_gen/replay.md#(commander=0x0)_replay">replay</a> <b>if</b> the flag is set
    <b>if</b> (save_replay) {
        transfer::public_transfer(<a href="../name_gen/replay.md#(commander=0x0)_replay_new">replay::new</a>(preset_id, <a href="../name_gen/history.md#(commander=0x0)_history">history</a>, ctx), ctx.sender());
    };
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_place_recruit"></a>

## Function `place_recruit`

Place a Recruit on the map, store it in the <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_place_recruit">place_recruit</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_place_recruit">place_recruit</a>(game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>, <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: Recruit, ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.leader() == ctx.sender(), <a href="../name_gen/commander.md#(commander=0x0)_commander_ENotYourRecruit">ENotYourRecruit</a>); // make sure the sender owns the <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>
    <b>assert</b>!(game.positions.length() &gt; 0, <a href="../name_gen/commander.md#(commander=0x0)_commander_ENoPositions">ENoPositions</a>);
    <b>let</b> position = game.positions.pop_back();
    <b>let</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a> = game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_place_recruit">place_recruit</a>(&<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>, position[0] <b>as</b> u16, position[1] <b>as</b> u16);
    game.recruits.add(object::id(&<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>), <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>);
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.add(<a href="../name_gen/history.md#(commander=0x0)_history">history</a>);
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_move_unit"></a>

## Function `move_unit`

Move a unit along the path, the first point is the current position of the unit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_move_unit">move_unit</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, path: vector&lt;u8&gt;, _ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_move_unit">move_unit</a>(game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>, path: vector&lt;u8&gt;, _ctx: &<b>mut</b> TxContext) {
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.add(game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_move_unit">move_unit</a>(path))
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_perform_reload"></a>

## Function `perform_reload`

Perform a reload action, replenishing ammo.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_reload">perform_reload</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, x: u16, y: u16, _ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_reload">perform_reload</a>(game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>, x: u16, y: u16, _ctx: &<b>mut</b> TxContext) {
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.add(game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_perform_reload">perform_reload</a>(x, y))
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_perform_grenade"></a>

## Function `perform_grenade`

Perform a grenade throw action.


<pre><code><b>entry</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_grenade">perform_grenade</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, rng: &<a href="../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>, x0: u16, y0: u16, x1: u16, y1: u16, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_grenade">perform_grenade</a>(
    game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <b>mut</b> rng = rng.new_generator(ctx);
    <b>let</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a> = game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_perform_grenade">perform_grenade</a>(&<b>mut</b> rng, x0, y0, x1, y1);
    <a href="../name_gen/history.md#(commander=0x0)_history_list_kia">history::list_kia</a>(&<a href="../name_gen/history.md#(commander=0x0)_history">history</a>).do!(|id| {
        <b>let</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a> = game.recruits.remove(id);
        <b>let</b> leader = <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.leader();
        transfer::public_transfer(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.kill(ctx), leader);
    });
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.append(<a href="../name_gen/history.md#(commander=0x0)_history">history</a>)
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_perform_attack"></a>

## Function `perform_attack`

Perform an attack action.


<pre><code><b>entry</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_attack">perform_attack</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game, rng: &<a href="../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>, x0: u16, y0: u16, x1: u16, y1: u16, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>entry</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_perform_attack">perform_attack</a>(
    game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>,
    rng: &Random,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    ctx: &<b>mut</b> TxContext,
) {
    <b>let</b> <b>mut</b> rng = rng.new_generator(ctx);
    <b>let</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a> = game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_perform_attack">perform_attack</a>(&<b>mut</b> rng, x0, y0, x1, y1);
    <a href="../name_gen/history.md#(commander=0x0)_history_list_kia">history::list_kia</a>(&<a href="../name_gen/history.md#(commander=0x0)_history">history</a>).do!(|id| {
        <b>if</b> (id.to_address() == @0) <b>return</b>; // skip empty addresses
        <b>let</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a> = game.recruits.remove(id);
        <b>let</b> leader = <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.leader();
        transfer::public_transfer(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.kill(ctx), leader);
    });
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.append(<a href="../name_gen/history.md#(commander=0x0)_history">history</a>)
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_next_turn"></a>

## Function `next_turn`

Switch to the next turn.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_next_turn">next_turn</a>(game: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_next_turn">next_turn</a>(game: &<b>mut</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>) {
    game.<a href="../name_gen/history.md#(commander=0x0)_history">history</a>.add(game.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_next_turn">next_turn</a>());
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_share"></a>

## Function `share`

Share the <code>key</code>-only object after placing Recruits on the map.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_share">share</a>(game: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_share">share</a>(game: <a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>) {
    transfer::share_object(game)
}
</code></pre>



</details>

<a name="(commander=0x0)_commander_turn"></a>

## Function `turn`

Get the current turn of the game.


<pre><code><b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_turn">turn</a>(self: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::commander::Game): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_turn">turn</a>(self: &<a href="../name_gen/commander.md#(commander=0x0)_commander_Game">Game</a>): u16 { self.<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/commander.md#(commander=0x0)_commander_turn">turn</a>() }
</code></pre>



</details>

<a name="(commander=0x0)_commander_init"></a>

## Function `init`

On publish, share the <code><a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a></code> object with map presets. Demos have reserved IDs 0 and 1.


<pre><code><b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_init">init</a>(ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../name_gen/commander.md#(commander=0x0)_commander_init">init</a>(ctx: &<b>mut</b> TxContext) {
    <b>let</b> id = object::new(ctx);
    <b>let</b> id_address = id.to_address();
    // prettier-ignore
    transfer::transfer({
        <b>let</b> id = object::new(ctx);
        <a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a> {
            <a href="../name_gen/map.md#(commander=0x0)_map">map</a>: <a href="../name_gen/map.md#(commander=0x0)_map_demo_1">map::demo_1</a>(id.to_inner()),
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
        <a href="../name_gen/commander.md#(commander=0x0)_commander_Preset">Preset</a> {
            <a href="../name_gen/map.md#(commander=0x0)_map">map</a>: <a href="../name_gen/map.md#(commander=0x0)_map_demo_2">map::demo_2</a>(id.to_inner()),
            name: b"Demo 2".to_string(),
            positions: vector[vector[8, 2], vector[7, 6], vector[1, 2], vector[1, 7]],
            author: @0,
            popularity: 0,
            id,
        }
    }, id_address);
    transfer::share_object(<a href="../name_gen/commander.md#(commander=0x0)_commander_Commander">Commander</a> { id, games: vec_map::empty() });
}
</code></pre>



</details>
