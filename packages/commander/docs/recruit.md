
<a name="(commander=0x0)_recruit"></a>

# Module `(commander=0x0)::recruit`

Defines the Recruit - an ownable unit in the game. Recruit contains all the
information about the unit, its rank, modifications, gear, stats and more.

Traits:
- default


-  [Struct `Metadata`](#(commander=0x0)_recruit_Metadata)
-  [Struct `Recruit`](#(commander=0x0)_recruit_Recruit)
-  [Struct `DogTag`](#(commander=0x0)_recruit_DogTag)
-  [Constants](#@Constants_0)
-  [Function `add_armor`](#(commander=0x0)_recruit_add_armor)
-  [Function `remove_armor`](#(commander=0x0)_recruit_remove_armor)
-  [Function `add_weapon`](#(commander=0x0)_recruit_add_weapon)
-  [Function `remove_weapon`](#(commander=0x0)_recruit_remove_weapon)
-  [Function `armor`](#(commander=0x0)_recruit_armor)
-  [Function `weapon`](#(commander=0x0)_recruit_weapon)
-  [Function `stats`](#(commander=0x0)_recruit_stats)
-  [Function `rank`](#(commander=0x0)_recruit_rank)
-  [Function `leader`](#(commander=0x0)_recruit_leader)
-  [Function `metadata`](#(commander=0x0)_recruit_metadata)
-  [Function `rank_up`](#(commander=0x0)_recruit_rank_up)
-  [Function `default`](#(commander=0x0)_recruit_default)
-  [Function `new`](#(commander=0x0)_recruit_new)
-  [Function `dismiss`](#(commander=0x0)_recruit_dismiss)
-  [Function `throw_away`](#(commander=0x0)_recruit_throw_away)
-  [Function `kill`](#(commander=0x0)_recruit_kill)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>;
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



<a name="(commander=0x0)_recruit_Metadata"></a>

## Struct `Metadata`

Recruit metadata, contains information about the Recruit that is not
directly related to the game mechanics.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">Metadata</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>name: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
<dt>
<code>backstory: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(commander=0x0)_recruit_Recruit"></a>

## Struct `Recruit`

Defines the Recruit - a unit in the game which users hire, train and send on
missions. As the Recruit gains experience, they can be promoted to higher
ranks and get access to better equipment and abilities.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> <b>has</b> key, store
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
<code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">recruit::Metadata</a></code>
</dt>
<dd>
 <code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">Metadata</a></code> of the Recruit.
</dd>
<dt>
<code><a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a></code>
</dt>
<dd>
 <code>Rank</code> of the Unit.
</dd>
<dt>
<code><a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a></code>
</dt>
<dd>
 <code>Stats</code> of the Unit.
</dd>
<dt>
<code><a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: <a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>&gt;</code>
</dt>
<dd>
 Weapon of the Unit. When not set, the Recruit uses the default weapon.
</dd>
<dt>
<code><a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: <a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>&gt;</code>
</dt>
<dd>
 Armor of the Unit. When not set, the Recruit uses the default armor.
</dd>
<dt>
<code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a>: <b>address</b></code>
</dt>
<dd>
 The address that hired the Recruit.
</dd>
</dl>


</details>

<a name="(commander=0x0)_recruit_DogTag"></a>

## Struct `DogTag`

DogTag is the only thing left after a Recruit dies in battle.
It contains the name and rank of the fallen soldier.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">DogTag</a> <b>has</b> key, store
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
<code><a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a></code>
</dt>
<dd>
 The rank of the fallen soldier.
</dd>
<dt>
<code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">recruit::Metadata</a></code>
</dt>
<dd>
 Metadata (including backstory) of the fallen recruit.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(commander=0x0)_recruit_EAlreadyHasWeapon"></a>

Attempt to equip a <code>Weapon</code> while a Recruit already it.


<pre><code><b>const</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_EAlreadyHasWeapon">EAlreadyHasWeapon</a>: u64 = 1;
</code></pre>



<a name="(commander=0x0)_recruit_ENoWeapon"></a>

Trying to remove a <code>Weapon</code> that does not exist.


<pre><code><b>const</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_ENoWeapon">ENoWeapon</a>: u64 = 2;
</code></pre>



<a name="(commander=0x0)_recruit_EAlreadyHasArmor"></a>

Attempt to equip an <code>Armor</code> while a Recruit already has one.


<pre><code><b>const</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_EAlreadyHasArmor">EAlreadyHasArmor</a>: u64 = 3;
</code></pre>



<a name="(commander=0x0)_recruit_ENoArmor"></a>

Trying to remove an <code>Armor</code> that does not exist.


<pre><code><b>const</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_ENoArmor">ENoArmor</a>: u64 = 4;
</code></pre>



<a name="(commander=0x0)_recruit_add_armor"></a>

## Function `add_armor`

Add an armor to the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_add_armor">add_armor</a>(r: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_add_armor">add_armor</a>(r: &<b>mut</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: Armor) {
    <b>assert</b>!(r.<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>.is_none(), <a href="../name_gen/recruit.md#(commander=0x0)_recruit_EAlreadyHasArmor">EAlreadyHasArmor</a>);
    r.<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>.fill(<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>);
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_remove_armor"></a>

## Function `remove_armor`

Remove the armor from the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_remove_armor">remove_armor</a>(r: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_remove_armor">remove_armor</a>(r: &<b>mut</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): Armor {
    <b>assert</b>!(r.<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>.is_some(), <a href="../name_gen/recruit.md#(commander=0x0)_recruit_ENoArmor">ENoArmor</a>);
    r.<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>.extract()
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_add_weapon"></a>

## Function `add_weapon`

Add a weapon to the Recruit.
Aborts if the Recruit already has a weapon.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_add_weapon">add_weapon</a>(r: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>, <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_add_weapon">add_weapon</a>(r: &<b>mut</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>, <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: Weapon) {
    <b>assert</b>!(r.<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.is_none(), <a href="../name_gen/recruit.md#(commander=0x0)_recruit_EAlreadyHasWeapon">EAlreadyHasWeapon</a>);
    r.<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.fill(<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>);
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_remove_weapon"></a>

## Function `remove_weapon`

Remove the weapon from the Recruit.
Aborts if the Recruit does not have a weapon.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_remove_weapon">remove_weapon</a>(r: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_remove_weapon">remove_weapon</a>(r: &<b>mut</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): Weapon {
    <b>assert</b>!(r.<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.is_some(), <a href="../name_gen/recruit.md#(commander=0x0)_recruit_ENoWeapon">ENoWeapon</a>);
    r.<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.extract()
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_armor"></a>

## Function `armor`

Get the armor of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): &<a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): &Option&lt;Armor&gt; { &r.<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_weapon"></a>

## Function `weapon`

Get the weapon of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): &<a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): &Option&lt;Weapon&gt; { &r.<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_stats"></a>

## Function `stats`

Get the stats of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): &Stats { &r.<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_rank"></a>

## Function `rank`

Get the rank of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): &Rank { &r.<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_leader"></a>

## Function `leader`

Get the address of the Recruit's leader.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): <b>address</b> { r.<a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_metadata"></a>

## Function `metadata`

Get the metadata of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>(r: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">recruit::Metadata</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>(r: &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): &<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">Metadata</a> { &r.<a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a> }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_rank_up"></a>

## Function `rank_up`

Promotes the rank of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_rank_up">rank_up</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_rank_up">rank_up</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: &<b>mut</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>) { <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>.<a href="../name_gen/recruit.md#(commander=0x0)_recruit_rank_up">rank_up</a>() }
</code></pre>



</details>

<a name="(commander=0x0)_recruit_default"></a>

## Function `default`

Create a new <code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a></code> with default values.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_default">default</a>(ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_default">default</a>(ctx: &<b>mut</b> TxContext): <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> {
    <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> {
        id: object::new(ctx),
        <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>: <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">Metadata</a> {
            name: b"John Doe".to_string(),
            backstory: b"A rookie soldier, ready to prove themselves.".to_string(),
        },
        <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: <a href="../name_gen/rank.md#(commander=0x0)_rank_default">rank::default</a>(),
        <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: <a href="../name_gen/stats.md#(commander=0x0)_stats_default">stats::default</a>(),
        <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: option::none(),
        <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: option::none(),
        <a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a>: ctx.sender(),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_new"></a>

## Function `new`

Create a new <code><a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a></code> with the given name and backstory.
TODOs:
- [ ] restrict who can submit new names and backstory. Right now anyone can
create a Recruit with any name and backstory.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_new">new</a>(name: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>, backstory: <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_new">new</a>(name: String, backstory: String, ctx: &<b>mut</b> TxContext): <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> {
    <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> {
        id: object::new(ctx),
        <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>: <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Metadata">Metadata</a> { name, backstory },
        <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: <a href="../name_gen/rank.md#(commander=0x0)_rank_rookie">rank::rookie</a>(),
        <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: <a href="../name_gen/stats.md#(commander=0x0)_stats_default">stats::default</a>(),
        <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>: option::none(),
        <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: option::none(),
        <a href="../name_gen/recruit.md#(commander=0x0)_recruit_leader">leader</a>: ctx.sender(),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_dismiss"></a>

## Function `dismiss`

Dismiss the Recruit, remove them forever from the game.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_dismiss">dismiss</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>): (<a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon_Weapon">weapon::Weapon</a>&gt;, <a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor_Armor">armor::Armor</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_dismiss">dismiss</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>): (Option&lt;Weapon&gt;, Option&lt;Armor&gt;) {
    <b>let</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> { id, <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>, .. } = <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>;
    id.delete();
    (<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>)
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_throw_away"></a>

## Function `throw_away`

Throw away the DogTag, destroy it and bury the memory.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_throw_away">throw_away</a>(dog_tag: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">recruit::DogTag</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_throw_away">throw_away</a>(dog_tag: <a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">DogTag</a>) {
    <b>let</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">DogTag</a> { id, .. } = dog_tag;
    id.delete();
}
</code></pre>



</details>

<a name="(commander=0x0)_recruit_kill"></a>

## Function `kill`

Kills the Recruit and returns the DogTag.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_kill">kill</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>, ctx: &<b>mut</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">recruit::DogTag</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_kill">kill</a>(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a>, ctx: &<b>mut</b> TxContext): <a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">DogTag</a> {
    <b>let</b> <a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">Recruit</a> { id, <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>, <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>, <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>, .. } = <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>;
    id.delete();
    // TODO: figure a way to leave the <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>
    <a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>.destroy!(|w| w.destroy());
    <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>.destroy!(|a| a.destroy());
    <a href="../name_gen/recruit.md#(commander=0x0)_recruit_DogTag">DogTag</a> { id: object::new(ctx), <a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>, <a href="../name_gen/recruit.md#(commander=0x0)_recruit_metadata">metadata</a> }
}
</code></pre>



</details>
