
<a name="commander_replay"></a>

# Module `commander::replay`

Allows saving replays of games.


-  [Struct `Replay`](#commander_replay_Replay)
-  [Function `new`](#commander_replay_new)
-  [Function `delete`](#commander_replay_delete)


<pre><code><b>use</b> <a href="./history.md#commander_history">commander::history</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="commander_replay_Replay"></a>

## Struct `Replay`

Stores a replay of a game.


<pre><code><b>public</b> <b>struct</b> <a href="./replay.md#commander_replay_Replay">Replay</a> <b>has</b> key, store
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
<code>preset_id: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
 ID of the <code>Preset</code> object (or <code>@0-1</code> for demos).
 Allows fetching the Map and recreating the Game.
</dd>
<dt>
<code><a href="./history.md#commander_history">history</a>: <a href="./history.md#commander_history_History">commander::history::History</a></code>
</dt>
<dd>
 The history of the game.
</dd>
</dl>


</details>

<a name="commander_replay_new"></a>

## Function `new`

Create a new <code><a href="./replay.md#commander_replay_Replay">Replay</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./replay.md#commander_replay_new">new</a>(preset_id: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>, <a href="./history.md#commander_history">history</a>: <a href="./history.md#commander_history_History">commander::history::History</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./replay.md#commander_replay_Replay">commander::replay::Replay</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./replay.md#commander_replay_new">new</a>(preset_id: ID, <a href="./history.md#commander_history">history</a>: History, ctx: &<b>mut</b> TxContext): <a href="./replay.md#commander_replay_Replay">Replay</a> {
    <a href="./replay.md#commander_replay_Replay">Replay</a> { id: object::new(ctx), preset_id, <a href="./history.md#commander_history">history</a> }
}
</code></pre>



</details>

<a name="commander_replay_delete"></a>

## Function `delete`

Delete a saved <code><a href="./replay.md#commander_replay_Replay">Replay</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./replay.md#commander_replay_delete">delete</a>(<a href="./replay.md#commander_replay">replay</a>: <a href="./replay.md#commander_replay_Replay">commander::replay::Replay</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./replay.md#commander_replay_delete">delete</a>(<a href="./replay.md#commander_replay">replay</a>: <a href="./replay.md#commander_replay_Replay">Replay</a>) {
    <b>let</b> <a href="./replay.md#commander_replay_Replay">Replay</a> { id, .. } = <a href="./replay.md#commander_replay">replay</a>;
    id.<a href="./replay.md#commander_replay_delete">delete</a>();
}
</code></pre>



</details>
