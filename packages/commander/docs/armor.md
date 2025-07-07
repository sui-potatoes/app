
<a name="(commander=0x0)_armor"></a>

# Module `(commander=0x0)::armor`

Defines the Armor - an equipment that Recruits can wear in battle.


-  [Struct `Armor`](#(commander=0x0)_armor_Armor)
-  [Function `new`](#(commander=0x0)_armor_new)
-  [Function `default`](#(commander=0x0)_armor_default)
-  [Function `destroy`](#(commander=0x0)_armor_destroy)
-  [Function `name`](#(commander=0x0)_armor_name)
-  [Function `stats`](#(commander=0x0)_armor_stats)
-  [Function `to_string`](#(commander=0x0)_armor_to_string)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="(commander=0x0)_armor_Armor"></a>

## Struct `Armor`

Armor is a piece of equipment that Recruits can use in battle. Each armor has
its own stats, normally adding to the <code>defense</code> and <code>health</code> of the Recruit.

However, given reusability of <code>Stats</code>, it can augment other stats as well.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> <b>has</b> key, store
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
<code><a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 The name of the armor. "Standard Armor", "Titanium Armor", etc.
</dd>
<dt>
<code><a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a></code>
</dt>
<dd>
 The <code>Stats</code> of the armor.
</dd>
</dl>


</details>

<a name="(commander=0x0)_armor_new"></a>

## Function `new`

Create a new <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code> with the provided parameters.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_new">new</a>(<a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_new">new</a>(<a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>: String, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: Stats, ctx: &<b>mut</b> TxContext): <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> {
    <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> { id: object::new(ctx), <a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> }
}
</code></pre>



</details>

<a name="(commander=0x0)_armor_default"></a>

## Function `default`

Create a new default <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_default">default</a>(ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_default">default</a>(ctx: &<b>mut</b> TxContext): <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> {
    <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> {
        id: object::new(ctx),
        <a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>: b"Standard <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a>".<a href="../name_gen/armor.md#(commander=0x0)_armor_to_string">to_string</a>(),
        <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: <a href="../name_gen/stats.md#(commander=0x0)_stats_default_armor">stats::default_armor</a>(),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_armor_destroy"></a>

## Function `destroy`

Destroy the <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_destroy">destroy</a>(<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_destroy">destroy</a>(<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a>) {
    <b>let</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a> { id, .. } = <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_armor_name"></a>

## Function `name`

Get the name of the <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>(a: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a>(a: &<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a>): String { a.<a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a> }
</code></pre>



</details>

<a name="(commander=0x0)_armor_stats"></a>

## Function `stats`

Get the stats of the <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(a: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>): &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(a: &<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a>): &Stats { &a.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> }
</code></pre>



</details>

<a name="(commander=0x0)_armor_to_string"></a>

## Function `to_string`

Add an upgrade to the <code><a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_to_string">to_string</a>(a: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor_to_string">to_string</a>(a: &<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">Armor</a>): String { a.<a href="../name_gen/armor.md#(commander=0x0)_armor_name">name</a> }
</code></pre>



</details>
