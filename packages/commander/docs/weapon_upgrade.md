
<a name="commander_weapon_upgrade"></a>

# Module `commander::weapon_upgrade`

Defines the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code> - a module that can be attached to a <code>Weapon</code> to
modify its stats.


-  [Struct `WeaponUpgrade`](#commander_weapon_upgrade_WeaponUpgrade)
-  [Function `new`](#commander_weapon_upgrade_new)
-  [Function `name`](#commander_weapon_upgrade_name)
-  [Function `tier`](#commander_weapon_upgrade_tier)
-  [Function `modifier`](#commander_weapon_upgrade_modifier)
-  [Function `destroy`](#commander_weapon_upgrade_destroy)
-  [Function `to_string`](#commander_weapon_upgrade_to_string)


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
</code></pre>



<a name="commander_weapon_upgrade_WeaponUpgrade"></a>

## Struct `WeaponUpgrade`

<code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code> is a primitive which represents an upgrade module for a
<code>Weapon</code>. Upgrades are identified by their name, and can be applied to a
<code>Weapon</code> to modify its stats.


<pre><code><b>public</b> <b>struct</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>: u8</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="commander_weapon_upgrade_new"></a>

## Function `new`

Create a new <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code> with the provided parameters.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_new">new</a>(<a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>: u8, <a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>): <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_new">new</a>(<a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>: String, <a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>: u8, <a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a>: Stats): <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a> {
    <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a> { <a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>, <a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>, <a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a> }
}
</code></pre>



</details>

<a name="commander_weapon_upgrade_name"></a>

## Function `name`

Get the name of the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a>): String { u.<a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a> }
</code></pre>



</details>

<a name="commander_weapon_upgrade_tier"></a>

## Function `tier`

Get the tier of the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a>): u8 { u.<a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a> }
</code></pre>



</details>

<a name="commander_weapon_upgrade_modifier"></a>

## Function `modifier`

Get the modifier of the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>): &<a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a>): &Stats { &u.<a href="./weapon_upgrade.md#commander_weapon_upgrade_modifier">modifier</a> }
</code></pre>



</details>

<a name="commander_weapon_upgrade_destroy"></a>

## Function `destroy`

Destroy the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_destroy">destroy</a>(u: <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_destroy">destroy</a>(u: <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a>) { <b>let</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a> { .. } = u; }
</code></pre>



</details>

<a name="commander_weapon_upgrade_to_string"></a>

## Function `to_string`

Print the <code><a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a></code> as a string.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_to_string">to_string</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">commander::weapon_upgrade::WeaponUpgrade</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade_to_string">to_string</a>(u: &<a href="./weapon_upgrade.md#commander_weapon_upgrade_WeaponUpgrade">WeaponUpgrade</a>): String {
    <b>let</b> <b>mut</b> str = u.<a href="./weapon_upgrade.md#commander_weapon_upgrade_name">name</a>;
    str.append_utf8(b" (Tier ");
    str.append(u.<a href="./weapon_upgrade.md#commander_weapon_upgrade_tier">tier</a>.<a href="./weapon_upgrade.md#commander_weapon_upgrade_to_string">to_string</a>());
    str.append_utf8(b")");
    str
}
</code></pre>



</details>
