
<a name="(commander=0x0)_replay"></a>

# Module `(commander=0x0)::replay`

Allows saving replays of games.


-  [Struct `Replay`](#(commander=0x0)_replay_Replay)
-  [Function `new`](#(commander=0x0)_replay_new)
-  [Function `delete`](#(commander=0x0)_replay_delete)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history">history</a>;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="(commander=0x0)_replay_Replay"></a>

## Struct `Replay`

Stores a replay of a game.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a> <b>has</b> key, store
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
<code>preset_id: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
 ID of the <code>Preset</code> object (or <code>@0-1</code> for demos).
 Allows fetching the Map and recreating the Game.
</dd>
<dt>
<code><a href="../name_gen/history.md#(commander=0x0)_history">history</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a></code>
</dt>
<dd>
 The history of the game.
</dd>
</dl>


</details>

<a name="(commander=0x0)_replay_new"></a>

## Function `new`

Create a new <code><a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_new">new</a>(preset_id: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>, <a href="../name_gen/history.md#(commander=0x0)_history">history</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">replay::Replay</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_new">new</a>(preset_id: ID, <a href="../name_gen/history.md#(commander=0x0)_history">history</a>: History, ctx: &<b>mut</b> TxContext): <a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a> {
    <a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a> { id: object::new(ctx), preset_id, <a href="../name_gen/history.md#(commander=0x0)_history">history</a> }
}
</code></pre>



</details>

<a name="(commander=0x0)_replay_delete"></a>

## Function `delete`

Delete a saved <code><a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_delete">delete</a>(<a href="../name_gen/replay.md#(commander=0x0)_replay">replay</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">replay::Replay</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_delete">delete</a>(<a href="../name_gen/replay.md#(commander=0x0)_replay">replay</a>: <a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a>) {
    <b>let</b> <a href="../name_gen/replay.md#(commander=0x0)_replay_Replay">Replay</a> { id, .. } = <a href="../name_gen/replay.md#(commander=0x0)_replay">replay</a>;
    id.<a href="../name_gen/replay.md#(commander=0x0)_replay_delete">delete</a>();
}
</code></pre>



</details>
