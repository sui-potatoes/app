
<a name="(commander=0x0)_weapon"></a>

# Module `(commander=0x0)::weapon`

Defines the Weapon - a piece of equipment that Recruits can use in battle.
Weapons have different stats and can be upgraded with additional modules.


-  [Struct `Weapon`](#(commander=0x0)_weapon_Weapon)
-  [Constants](#@Constants_0)
-  [Function `new`](#(commander=0x0)_weapon_new)
-  [Function `default`](#(commander=0x0)_weapon_default)
-  [Function `destroy`](#(commander=0x0)_weapon_destroy)
-  [Function `name`](#(commander=0x0)_weapon_name)
-  [Function `stats`](#(commander=0x0)_weapon_stats)
-  [Function `upgrades`](#(commander=0x0)_weapon_upgrades)
-  [Function `add_upgrade`](#(commander=0x0)_weapon_add_upgrade)
-  [Function `remove_upgrade`](#(commander=0x0)_weapon_remove_upgrade)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade">weapon_upgrade</a>;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="(commander=0x0)_weapon_Weapon"></a>

## Struct `Weapon`

Weapon is an equipment that Recruits can use in battle. Each weapon has its
own stats with a potential to be upgraded with additional modules.

Some weapons might be unique and have special abilities.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> <b>has</b> key, store
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
<code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 The name of the weapon. "Plasma Rifle", "Sniper Rifle", etc.
</dd>
<dt>
<code><a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a></code>
</dt>
<dd>
 The <code>Stats</code> of the weapon.
</dd>
<dt>
<code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>: vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>&gt;</code>
</dt>
<dd>
 The list of upgrades that the weapon has.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(commander=0x0)_weapon_ETooManyUpgrades"></a>

Attempt to attach too many upgrades to a weapon.


<pre><code><b>const</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_ETooManyUpgrades">ETooManyUpgrades</a>: u64 = 1;
</code></pre>



<a name="(commander=0x0)_weapon_ENoUpgrade"></a>

Attempt to remove an upgrade that does not exist.


<pre><code><b>const</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_ENoUpgrade">ENoUpgrade</a>: u64 = 2;
</code></pre>



<a name="(commander=0x0)_weapon_new"></a>

## Function `new`

Create a new <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code> with the provided parameters.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_new">new</a>(<a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_new">new</a>(<a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>: String, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: Stats, ctx: &<b>mut</b> TxContext): <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> {
    <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> { id: object::new(ctx), <a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>, <a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>: vector[] }
}
</code></pre>



</details>

<a name="(commander=0x0)_weapon_default"></a>

## Function `default`

Create a new default <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_default">default</a>(ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_default">default</a>(ctx: &<b>mut</b> TxContext): <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> {
    <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> {
        id: object::new(ctx),
        <a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>: b"Standard Issue Rifle".to_string(),
        <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: <a href="../name_gen/stats.md#(commander=0x0)_stats_default_weapon">stats::default_weapon</a>(),
        <a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_weapon_destroy"></a>

## Function `destroy`

Destroy the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_destroy">destroy</a>(<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_destroy">destroy</a>(<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>) {
    <b>let</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a> { id, .. } = <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>;
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_weapon_name"></a>

## Function `name`

Get the name of the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>(w: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a>(w: &<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>): String { w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_name">name</a> }
</code></pre>



</details>

<a name="(commander=0x0)_weapon_stats"></a>

## Function `stats`

Get the stats of the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(w: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>): &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(w: &<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>): &Stats { &w.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> }
</code></pre>



</details>

<a name="(commander=0x0)_weapon_upgrades"></a>

## Function `upgrades`

Get the upgrades of the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>(w: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>): &vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>(w: &<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>): &vector&lt;WeaponUpgrade&gt; { &w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a> }
</code></pre>



</details>

<a name="(commander=0x0)_weapon_add_upgrade"></a>

## Function `add_upgrade`

Add an upgrade to the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_add_upgrade">add_upgrade</a>(w: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>, upgrade: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_add_upgrade">add_upgrade</a>(w: &<b>mut</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>, upgrade: WeaponUpgrade) {
    <b>assert</b>!(w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>.length() &lt; 3, <a href="../name_gen/weapon.md#(commander=0x0)_weapon_ETooManyUpgrades">ETooManyUpgrades</a>);
    w.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> = w.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.add(upgrade.modifier());
    w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>.push_back(upgrade);
}
</code></pre>



</details>

<a name="(commander=0x0)_weapon_remove_upgrade"></a>

## Function `remove_upgrade`

Remove an upgrade from the <code><a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_remove_upgrade">remove_upgrade</a>(w: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>, upgrade_idx: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_remove_upgrade">remove_upgrade</a>(w: &<b>mut</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">Weapon</a>, upgrade_idx: u8): WeaponUpgrade {
    <b>assert</b>!(w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>.length() &gt; upgrade_idx <b>as</b> u64, <a href="../name_gen/weapon.md#(commander=0x0)_weapon_ENoUpgrade">ENoUpgrade</a>);
    <b>let</b> upgrade = w.<a href="../name_gen/weapon.md#(commander=0x0)_weapon_upgrades">upgrades</a>.remove(upgrade_idx <b>as</b> u64);
    w.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> = w.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.add(&upgrade.modifier().negate());
    upgrade
}
</code></pre>



</details>
