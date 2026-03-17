
<a name="commander_armor"></a>

# Module `commander::armor`

Defines the Armor - an equipment that Recruits can wear in battle.


-  [Struct `Armor`](#commander_armor_Armor)
-  [Function `new`](#commander_armor_new)
-  [Function `default`](#commander_armor_default)
-  [Function `destroy`](#commander_armor_destroy)
-  [Function `name`](#commander_armor_name)
-  [Function `stats`](#commander_armor_stats)
-  [Function `to_string`](#commander_armor_to_string)


<pre><code><b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="commander_armor_Armor"></a>

## Struct `Armor`

Armor is a piece of equipment that Recruits can use in battle. Each armor has
its own stats, normally adding to the <code>defense</code> and <code>health</code> of the Recruit.

However, given reusability of <code>Stats</code>, it can augment other stats as well.


<pre><code><b>public</b> <b>struct</b> <a href="./armor.md#commander_armor_Armor">Armor</a> <b>has</b> key, store
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
<code><a href="./armor.md#commander_armor_name">name</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 The name of the armor. "Standard Armor", "Titanium Armor", etc.
</dd>
<dt>
<code><a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a></code>
</dt>
<dd>
 The <code>Stats</code> of the armor.
</dd>
</dl>


</details>

<a name="commander_armor_new"></a>

## Function `new`

Create a new <code><a href="./armor.md#commander_armor_Armor">Armor</a></code> with the provided parameters.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_new">new</a>(<a href="./armor.md#commander_armor_name">name</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_new">new</a>(<a href="./armor.md#commander_armor_name">name</a>: String, <a href="./stats.md#commander_stats">stats</a>: Stats, ctx: &<b>mut</b> TxContext): <a href="./armor.md#commander_armor_Armor">Armor</a> {
    <a href="./armor.md#commander_armor_Armor">Armor</a> { id: object::new(ctx), <a href="./armor.md#commander_armor_name">name</a>, <a href="./stats.md#commander_stats">stats</a> }
}
</code></pre>



</details>

<a name="commander_armor_default"></a>

## Function `default`

Create a new default <code><a href="./armor.md#commander_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_default">default</a>(ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_default">default</a>(ctx: &<b>mut</b> TxContext): <a href="./armor.md#commander_armor_Armor">Armor</a> {
    <a href="./armor.md#commander_armor_Armor">Armor</a> {
        id: object::new(ctx),
        <a href="./armor.md#commander_armor_name">name</a>: b"Standard <a href="./armor.md#commander_armor_Armor">Armor</a>".<a href="./armor.md#commander_armor_to_string">to_string</a>(),
        <a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_default_armor">stats::default_armor</a>(),
    }
}
</code></pre>



</details>

<a name="commander_armor_destroy"></a>

## Function `destroy`

Destroy the <code><a href="./armor.md#commander_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_destroy">destroy</a>(<a href="./armor.md#commander_armor">armor</a>: <a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_destroy">destroy</a>(<a href="./armor.md#commander_armor">armor</a>: <a href="./armor.md#commander_armor_Armor">Armor</a>) {
    <b>let</b> <a href="./armor.md#commander_armor_Armor">Armor</a> { id, .. } = <a href="./armor.md#commander_armor">armor</a>;
    id.delete();
}
</code></pre>



</details>

<a name="commander_armor_name"></a>

## Function `name`

Get the name of the <code><a href="./armor.md#commander_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_name">name</a>(a: &<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_name">name</a>(a: &<a href="./armor.md#commander_armor_Armor">Armor</a>): String { a.<a href="./armor.md#commander_armor_name">name</a> }
</code></pre>



</details>

<a name="commander_armor_stats"></a>

## Function `stats`

Get the stats of the <code><a href="./armor.md#commander_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(a: &<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>): &<a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(a: &<a href="./armor.md#commander_armor_Armor">Armor</a>): &Stats { &a.<a href="./stats.md#commander_stats">stats</a> }
</code></pre>



</details>

<a name="commander_armor_to_string"></a>

## Function `to_string`

Add an upgrade to the <code><a href="./armor.md#commander_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_to_string">to_string</a>(a: &<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor_to_string">to_string</a>(a: &<a href="./armor.md#commander_armor_Armor">Armor</a>): String { a.<a href="./armor.md#commander_armor_name">name</a> }
</code></pre>



</details>
