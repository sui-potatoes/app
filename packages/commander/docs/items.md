
<a name="(commander=0x0)_items"></a>

# Module `(commander=0x0)::items`

Contains all definitions for items that can be used by <code>Recruits</code>.


-  [Function `armor`](#(commander=0x0)_items_armor)
-  [Function `rifle`](#(commander=0x0)_items_rifle)
-  [Function `scope`](#(commander=0x0)_items_scope)
-  [Function `laser_sight`](#(commander=0x0)_items_laser_sight)
-  [Function `stock`](#(commander=0x0)_items_stock)
-  [Function `expanded_clip`](#(commander=0x0)_items_expanded_clip)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>;
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



<a name="(commander=0x0)_items_armor"></a>

## Function `armor`

Creates a new <code>Armor</code> with the given tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(tier: u8, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(tier: u8, ctx: &<b>mut</b> TxContext): Armor {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // +1 ARM, +10% DODGE
        1 =&gt; (b"Light Armor", vector[0, 0, 0, 1, 10]),
        // +2 ARM
        2 =&gt; (b"Medium Armor", vector[0, 0, 0, 2, 0]),
        // -1 MOB, +1 HP, +3 ARM, -10% DODGE
        3 =&gt; (b"Heavy Armor", vector[128 + 1, 0, 1, 3, 128 + 10]),
        _ =&gt; <b>abort</b>,
    };
    <a href="../name_gen/armor.md#(commander=0x0)_armor_new">armor::new</a>(name.to_string(), <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(bf::pack_u8!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>)), ctx)
}
</code></pre>



</details>

<a name="(commander=0x0)_items_rifle"></a>

## Function `rifle`

Creates a new rifle with the given tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_rifle">rifle</a>(tier: u8, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_rifle">rifle</a>(tier: u8, ctx: &<b>mut</b> TxContext): Weapon {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // 4 DMG, 2 SPREAD, +10% CRIT, 1 AREA, 4 RANGE, 3 AMMO
        1 =&gt; (b"Standard Rifle", 0x03_04_00_01_01_0A_0A_02_04 &lt;&lt; (6 * 8)),
        // 5 DMG, 1 SPREAD, +20% CRIT, 1 AREA, 5 RANGE, 3 AMMO
        2 =&gt; (b"Sharpshooter Rifle", 0x03_05_00_01_01_14_14_01_05 &lt;&lt; (6 * 8)),
        // 6 DMG, 1 SPREAD, +30% CRIT, 1 AREA, 5 RANGE, 3 AMMO
        3 =&gt; (b"Plasma Rifle", 0x03_05_00_01_01_1E_1E_01_06 &lt;&lt; (6 * 8)),
        _ =&gt; <b>abort</b>,
    };
    <a href="../name_gen/weapon.md#(commander=0x0)_weapon_new">weapon::new</a>(name.to_string(), <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>), ctx)
}
</code></pre>



</details>

<a name="(commander=0x0)_items_scope"></a>

## Function `scope`

Adds <code>5-15%</code> to the <code>aim</code> stat of the <code>Weapon</code> depending on the tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_scope">scope</a>(tier: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_scope">scope</a>(tier: u8): WeaponUpgrade {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // +5 AIM
        1 =&gt; (b"Basic Scope", 0x05 &lt;&lt; (1 * 8)),
        // +10 AIM
        2 =&gt; (b"Advanced Scope", 0x0A &lt;&lt; (1 * 8)),
        // +15 AIM
        3 =&gt; (b"Superior Scope", 0x0F &lt;&lt; (1 * 8)),
        _ =&gt; <b>abort</b>,
    };
    upgrade::new(name.to_string(), tier, <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>))
}
</code></pre>



</details>

<a name="(commander=0x0)_items_laser_sight"></a>

## Function `laser_sight`

Adds <code>5-15%</code> to the <code>crit_chance</code> stat of the <code>Weapon</code> depending on the tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_laser_sight">laser_sight</a>(tier: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_laser_sight">laser_sight</a>(tier: u8): WeaponUpgrade {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // +5 CRIT
        1 =&gt; (b"Basic Laser Sight", 0x05 &lt;&lt; (9 * 8)),
        // +10 CRIT
        2 =&gt; (b"Advanced Laser Sight", 0x0A &lt;&lt; (9 * 8)),
        // +15 CRIT
        3 =&gt; (b"Sniper Laser Sight", 0x0F &lt;&lt; (9 * 8)),
        _ =&gt; <b>abort</b>,
    };
    upgrade::new(name.to_string(), tier, <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>))
}
</code></pre>



</details>

<a name="(commander=0x0)_items_stock"></a>

## Function `stock`

Adds 1-3 to <code>range</code> stat of the <code>Weapon</code> depending on the tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_stock">stock</a>(tier: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_stock">stock</a>(tier: u8): WeaponUpgrade {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // +1 RANGE
        1 =&gt; (b"Basic Stock", 0x01 &lt;&lt; (13 * 8)),
        // +2 RANGE
        2 =&gt; (b"Advanced Stock", 0x02 &lt;&lt; (13 * 8)),
        // +3 RANGE
        3 =&gt; (b"Sniper Stock", 0x03 &lt;&lt; (13 * 8)),
        _ =&gt; <b>abort</b>,
    };
    upgrade::new(name.to_string(), tier, <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>))
}
</code></pre>



</details>

<a name="(commander=0x0)_items_expanded_clip"></a>

## Function `expanded_clip`

Expanded clip increases the <code>ammo</code> stat by 1-3 depending on the tier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_expanded_clip">expanded_clip</a>(tier: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade_WeaponUpgrade">weapon_upgrade::WeaponUpgrade</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/items.md#(commander=0x0)_items_expanded_clip">expanded_clip</a>(tier: u8): WeaponUpgrade {
    <b>let</b> (name, <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>) = match (tier) {
        // +1 AMMO
        1 =&gt; (b"Basic Expanded Clip", 0x01 &lt;&lt; (14 * 8)),
        // +2 AMMO
        2 =&gt; (b"Advanced Expanded Clip", 0x02 &lt;&lt; (14 * 8)),
        // +3 AMMO
        3 =&gt; (b"Superior Expanded Clip", 0x03 &lt;&lt; (14 * 8)),
        _ =&gt; <b>abort</b>,
    };
    upgrade::new(name.to_string(), tier, <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">stats::new_unchecked</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>))
}
</code></pre>



</details>
