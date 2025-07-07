
<a name="(commander=0x0)_history"></a>

# Module `(commander=0x0)::history`

Stores history of a single Game relaxing the need for event queries and
providing a single point of truth.

It replaces events API, providing all key game events in an easy to read
minimalistic representation.


-  [Struct `History`](#(commander=0x0)_history_History)
-  [Struct `HistoryUpdated`](#(commander=0x0)_history_HistoryUpdated)
-  [Enum `Record`](#(commander=0x0)_history_Record)
-  [Function `empty`](#(commander=0x0)_history_empty)
-  [Function `add`](#(commander=0x0)_history_add)
-  [Function `append`](#(commander=0x0)_history_append)
-  [Function `length`](#(commander=0x0)_history_length)
-  [Function `new_recruit_placed`](#(commander=0x0)_history_new_recruit_placed)
-  [Function `new_attack`](#(commander=0x0)_history_new_attack)
-  [Function `new_dodged`](#(commander=0x0)_history_new_dodged)
-  [Function `new_miss`](#(commander=0x0)_history_new_miss)
-  [Function `new_critical_hit`](#(commander=0x0)_history_new_critical_hit)
-  [Function `new_damage`](#(commander=0x0)_history_new_damage)
-  [Function `new_kia`](#(commander=0x0)_history_new_kia)
-  [Function `new_grenade`](#(commander=0x0)_history_new_grenade)
-  [Function `new_move`](#(commander=0x0)_history_new_move)
-  [Function `new_next_turn`](#(commander=0x0)_history_new_next_turn)
-  [Function `new_reload`](#(commander=0x0)_history_new_reload)
-  [Function `inner`](#(commander=0x0)_history_inner)
-  [Function `list_kia`](#(commander=0x0)_history_list_kia)
-  [Function `from_bytes`](#(commander=0x0)_history_from_bytes)
-  [Function `from_bcs`](#(commander=0x0)_history_from_bcs)


<pre><code><b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
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



<a name="(commander=0x0)_history_History"></a>

## Struct `History`

Stores history of actions.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(commander=0x0)_history_HistoryUpdated"></a>

## Struct `HistoryUpdated`

Event that marks an update in <code><a href="../name_gen/history.md#(commander=0x0)_history_History">History</a></code> for tx sender.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/history.md#(commander=0x0)_history_HistoryUpdated">HistoryUpdated</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(commander=0x0)_history_Record"></a>

## Enum `Record`

A single record in the history.


<pre><code><b>public</b> <b>enum</b> <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Reload</code>
</dt>
<dd>
 Block header for attack action.
</dd>

<dl>
<dt>
<code>0: vector&lt;u16&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>NextTurn</code>
</dt>
<dd>
 Next turn action.
</dd>

<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Move</code>
</dt>
<dd>
 Block header for move action.
</dd>

<dl>
<dt>
<code>0: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Attack</code>
</dt>
<dd>
 Block header for attack action.
</dd>

<dl>
<dt>
<code>origin: vector&lt;u16&gt;</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>target: vector&lt;u16&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>RecruitPlaced</code>
</dt>
<dd>
 Recruit is placed on the map.
</dd>

<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Damage</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: u8</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Miss</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Explosion</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>CriticalHit</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: u8</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Grenade</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>UnitKIA</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Dodged</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(commander=0x0)_history_empty"></a>

## Function `empty`

Create empty history.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_empty">empty</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_empty">empty</a>(): <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a> { <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>(vector[]) }
</code></pre>



</details>

<a name="(commander=0x0)_history_add"></a>

## Function `add`

Add a single record.
WARNING: if you're adding multiple record in the same transaction,
use <code><a href="../name_gen/history.md#(commander=0x0)_history_append">append</a></code> to emit a single event!


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_add">add</a>(h: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>, record: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_add">add</a>(h: &<b>mut</b> <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>, record: <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a>) {
    <b>let</b> <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>(<a href="../name_gen/history.md#(commander=0x0)_history">history</a>) = h;
    event::emit(<a href="../name_gen/history.md#(commander=0x0)_history_HistoryUpdated">HistoryUpdated</a>(vector[record]));
    <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(record);
}
</code></pre>



</details>

<a name="(commander=0x0)_history_append"></a>

## Function `append`

Add a new <code><a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a></code> to the <code><a href="../name_gen/history.md#(commander=0x0)_history_History">History</a></code> log.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_append">append</a>(h: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>, records: vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_append">append</a>(h: &<b>mut</b> <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>, records: vector&lt;<a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a>&gt;) {
    <b>let</b> <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>(<a href="../name_gen/history.md#(commander=0x0)_history">history</a>) = h;
    event::emit(<a href="../name_gen/history.md#(commander=0x0)_history_HistoryUpdated">HistoryUpdated</a>(records));
    <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.<a href="../name_gen/history.md#(commander=0x0)_history_append">append</a>(records);
}
</code></pre>



</details>

<a name="(commander=0x0)_history_length"></a>

## Function `length`

Get the length of the <code><a href="../name_gen/history.md#(commander=0x0)_history_History">History</a></code> log.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_length">length</a>(h: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_length">length</a>(h: &<a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>): u64 { h.0.<a href="../name_gen/history.md#(commander=0x0)_history_length">length</a>() }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_recruit_placed"></a>

## Function `new_recruit_placed`

Create new <code>Record::RecruitPlaced</code>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_recruit_placed">new_recruit_placed</a>(x: u16, y: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_recruit_placed">new_recruit_placed</a>(x: u16, y: u16): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::RecruitPlaced(x, y) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_attack"></a>

## Function `new_attack`

Create new <code>Record::Attack</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_attack">new_attack</a>(origin: vector&lt;u16&gt;, target: vector&lt;u16&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_attack">new_attack</a>(origin: vector&lt;u16&gt;, target: vector&lt;u16&gt;): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> {
    Record::Attack { origin, target }
}
</code></pre>



</details>

<a name="(commander=0x0)_history_new_dodged"></a>

## Function `new_dodged`

Create new <code>Record::Dodged</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_dodged">new_dodged</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_dodged">new_dodged</a>(): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Dodged }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_miss"></a>

## Function `new_miss`

Create new <code>Record::Missed</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_miss">new_miss</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_miss">new_miss</a>(): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Miss }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_critical_hit"></a>

## Function `new_critical_hit`

Create new <code>Record::CriticalHit</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_critical_hit">new_critical_hit</a>(dmg: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_critical_hit">new_critical_hit</a>(dmg: u8): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::CriticalHit(dmg) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_damage"></a>

## Function `new_damage`

Create new <code>Record::Damage</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_damage">new_damage</a>(dmg: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_damage">new_damage</a>(dmg: u8): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Damage(dmg) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_kia"></a>

## Function `new_kia`

Create new <code>Record::UnitKIA</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_kia">new_kia</a>(id: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_kia">new_kia</a>(id: ID): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::UnitKIA(id) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_grenade"></a>

## Function `new_grenade`

Create new <code>Record::Grenade</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_grenade">new_grenade</a>(r: u16, x: u16, y: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_grenade">new_grenade</a>(r: u16, x: u16, y: u16): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Grenade(r, x, y) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_move"></a>

## Function `new_move`

Create new <code>Record::Move</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_move">new_move</a>(steps: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_move">new_move</a>(steps: vector&lt;u8&gt;): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Move(steps) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_next_turn"></a>

## Function `new_next_turn`

Create new <code>Record::NextTurn</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_next_turn">new_next_turn</a>(turn: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_next_turn">new_next_turn</a>(turn: u16): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::NextTurn(turn) }
</code></pre>



</details>

<a name="(commander=0x0)_history_new_reload"></a>

## Function `new_reload`

Create new <code>Record::Reload</code> history record.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_reload">new_reload</a>(x: u16, y: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_reload">new_reload</a>(x: u16, y: u16): <a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a> { Record::Reload(vector[x, y]) }
</code></pre>



</details>

<a name="(commander=0x0)_history_inner"></a>

## Function `inner`

Read inner records vector.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_inner">inner</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>): &vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_inner">inner</a>(r: &<a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>): &vector&lt;<a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a>&gt; { &r.0 }
</code></pre>



</details>

<a name="(commander=0x0)_history_list_kia"></a>

## Function `list_kia`

List all <code>Record::UnitKIA</code> records.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_list_kia">list_kia</a>(r: &vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;): vector&lt;<a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_list_kia">list_kia</a>(r: &vector&lt;<a href="../name_gen/history.md#(commander=0x0)_history_Record">Record</a>&gt;): vector&lt;ID&gt; {
    <b>let</b> <b>mut</b> kias = vector[];
    r.do_ref!(
        |e| match (e) {
            Record::UnitKIA(id) =&gt; kias.push_back(*id),
            _ =&gt; (),
        },
    );
    kias
}
</code></pre>



</details>

<a name="(commander=0x0)_history_from_bytes"></a>

## Function `from_bytes`

Deserialize <code><a href="../name_gen/history.md#(commander=0x0)_history_History">History</a></code> from bytes.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a> {
    <a href="../name_gen/history.md#(commander=0x0)_history_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="(commander=0x0)_history_from_bcs"></a>

## Function `from_bcs`

Serialize <code><a href="../name_gen/history.md#(commander=0x0)_history_History">History</a></code> to bytes.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../dependencies/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_History">history::History</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/history.md#(commander=0x0)_history_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a> {
    <b>let</b> records = bcs.peel_vec!(|bcs| {
        match (bcs.peel_enum_tag()) {
            0 =&gt; Record::Reload(bcs.peel_vec!(|bcs| bcs.peel_u16())),
            1 =&gt; Record::NextTurn(bcs.peel_u16()),
            2 =&gt; Record::Move(bcs.peel_vec!(|bcs| bcs.peel_u8())),
            3 =&gt; Record::Attack {
                origin: bcs.peel_vec!(|bcs| bcs.peel_u16()),
                target: bcs.peel_vec!(|bcs| bcs.peel_u16()),
            },
            4 =&gt; Record::RecruitPlaced(bcs.peel_u16(), bcs.peel_u16()),
            5 =&gt; Record::Damage(bcs.peel_u8()),
            6 =&gt; Record::Miss,
            7 =&gt; Record::Explosion,
            8 =&gt; Record::CriticalHit(bcs.peel_u8()),
            9 =&gt; Record::Grenade(bcs.peel_u16(), bcs.peel_u16(), bcs.peel_u16()),
            10 =&gt; Record::UnitKIA(bcs.peel_address().to_id()),
            11 =&gt; Record::Dodged,
            _ =&gt; <b>abort</b>,
        }
    });
    <a href="../name_gen/history.md#(commander=0x0)_history_History">History</a>(records)
}
</code></pre>



</details>
