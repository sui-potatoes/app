
<a name="commander_recruit"></a>

# Module `commander::recruit`

Defines the Recruit - an ownable unit in the game. Recruit contains all the
information about the unit, its rank, modifications, gear, stats and more.

Traits:
- default


-  [Struct `Metadata`](#commander_recruit_Metadata)
-  [Struct `Recruit`](#commander_recruit_Recruit)
-  [Struct `DogTag`](#commander_recruit_DogTag)
-  [Constants](#@Constants_0)
-  [Function `add_armor`](#commander_recruit_add_armor)
-  [Function `remove_armor`](#commander_recruit_remove_armor)
-  [Function `add_weapon`](#commander_recruit_add_weapon)
-  [Function `remove_weapon`](#commander_recruit_remove_weapon)
-  [Function `armor`](#commander_recruit_armor)
-  [Function `weapon`](#commander_recruit_weapon)
-  [Function `stats`](#commander_recruit_stats)
-  [Function `rank`](#commander_recruit_rank)
-  [Function `leader`](#commander_recruit_leader)
-  [Function `metadata`](#commander_recruit_metadata)
-  [Function `rank_up`](#commander_recruit_rank_up)
-  [Function `default`](#commander_recruit_default)
-  [Function `new`](#commander_recruit_new)
-  [Function `dismiss`](#commander_recruit_dismiss)
-  [Function `throw_away`](#commander_recruit_throw_away)
-  [Function `kill`](#commander_recruit_kill)


<pre><code><b>use</b> <a href="./armor.md#commander_armor">commander::armor</a>;
<b>use</b> <a href="./rank.md#commander_rank">commander::rank</a>;
<b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="./weapon.md#commander_weapon">commander::weapon</a>;
<b>use</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade">commander::weapon_upgrade</a>;
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



<a name="commander_recruit_Metadata"></a>

## Struct `Metadata`

Recruit metadata, contains information about the Recruit that is not
directly related to the game mechanics.


<pre><code><b>public</b> <b>struct</b> <a href="./recruit.md#commander_recruit_Metadata">Metadata</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
<dt>
<code>backstory: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="commander_recruit_Recruit"></a>

## Struct `Recruit`

Defines the Recruit - a unit in the game which users hire, train and send on
missions. As the Recruit gains experience, they can be promoted to higher
ranks and get access to better equipment and abilities.


<pre><code><b>public</b> <b>struct</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> <b>has</b> key, store
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
<code><a href="./recruit.md#commander_recruit_metadata">metadata</a>: <a href="./recruit.md#commander_recruit_Metadata">commander::recruit::Metadata</a></code>
</dt>
<dd>
 <code><a href="./recruit.md#commander_recruit_Metadata">Metadata</a></code> of the Recruit.
</dd>
<dt>
<code><a href="./rank.md#commander_rank">rank</a>: <a href="./rank.md#commander_rank_Rank">commander::rank::Rank</a></code>
</dt>
<dd>
 <code>Rank</code> of the Unit.
</dd>
<dt>
<code><a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a></code>
</dt>
<dd>
 <code>Stats</code> of the Unit.
</dd>
<dt>
<code><a href="./weapon.md#commander_weapon">weapon</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./weapon.md#commander_weapon_Weapon">commander::weapon::Weapon</a>&gt;</code>
</dt>
<dd>
 Weapon of the Unit. When not set, the Recruit uses the default weapon.
</dd>
<dt>
<code><a href="./armor.md#commander_armor">armor</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>&gt;</code>
</dt>
<dd>
 Armor of the Unit. When not set, the Recruit uses the default armor.
</dd>
<dt>
<code><a href="./recruit.md#commander_recruit_leader">leader</a>: <b>address</b></code>
</dt>
<dd>
 The address that hired the Recruit.
</dd>
</dl>


</details>

<a name="commander_recruit_DogTag"></a>

## Struct `DogTag`

DogTag is the only thing left after a Recruit dies in battle.
It contains the name and rank of the fallen soldier.


<pre><code><b>public</b> <b>struct</b> <a href="./recruit.md#commander_recruit_DogTag">DogTag</a> <b>has</b> key, store
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
<code><a href="./rank.md#commander_rank">rank</a>: <a href="./rank.md#commander_rank_Rank">commander::rank::Rank</a></code>
</dt>
<dd>
 The rank of the fallen soldier.
</dd>
<dt>
<code><a href="./recruit.md#commander_recruit_metadata">metadata</a>: <a href="./recruit.md#commander_recruit_Metadata">commander::recruit::Metadata</a></code>
</dt>
<dd>
 Metadata (including backstory) of the fallen recruit.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="commander_recruit_EAlreadyHasWeapon"></a>

Attempt to equip a <code>Weapon</code> while a Recruit already it.


<pre><code><b>const</b> <a href="./recruit.md#commander_recruit_EAlreadyHasWeapon">EAlreadyHasWeapon</a>: u64 = 1;
</code></pre>



<a name="commander_recruit_ENoWeapon"></a>

Trying to remove a <code>Weapon</code> that does not exist.


<pre><code><b>const</b> <a href="./recruit.md#commander_recruit_ENoWeapon">ENoWeapon</a>: u64 = 2;
</code></pre>



<a name="commander_recruit_EAlreadyHasArmor"></a>

Attempt to equip an <code>Armor</code> while a Recruit already has one.


<pre><code><b>const</b> <a href="./recruit.md#commander_recruit_EAlreadyHasArmor">EAlreadyHasArmor</a>: u64 = 3;
</code></pre>



<a name="commander_recruit_ENoArmor"></a>

Trying to remove an <code>Armor</code> that does not exist.


<pre><code><b>const</b> <a href="./recruit.md#commander_recruit_ENoArmor">ENoArmor</a>: u64 = 4;
</code></pre>



<a name="commander_recruit_add_armor"></a>

## Function `add_armor`

Add an armor to the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_add_armor">add_armor</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>, <a href="./armor.md#commander_armor">armor</a>: <a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_add_armor">add_armor</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>, <a href="./armor.md#commander_armor">armor</a>: Armor) {
    <b>assert</b>!(r.<a href="./armor.md#commander_armor">armor</a>.is_none(), <a href="./recruit.md#commander_recruit_EAlreadyHasArmor">EAlreadyHasArmor</a>);
    r.<a href="./armor.md#commander_armor">armor</a>.fill(<a href="./armor.md#commander_armor">armor</a>);
}
</code></pre>



</details>

<a name="commander_recruit_remove_armor"></a>

## Function `remove_armor`

Remove the armor from the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_remove_armor">remove_armor</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): <a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_remove_armor">remove_armor</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): Armor {
    <b>assert</b>!(r.<a href="./armor.md#commander_armor">armor</a>.is_some(), <a href="./recruit.md#commander_recruit_ENoArmor">ENoArmor</a>);
    r.<a href="./armor.md#commander_armor">armor</a>.extract()
}
</code></pre>



</details>

<a name="commander_recruit_add_weapon"></a>

## Function `add_weapon`

Add a weapon to the Recruit.
Aborts if the Recruit already has a weapon.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_add_weapon">add_weapon</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>, <a href="./weapon.md#commander_weapon">weapon</a>: <a href="./weapon.md#commander_weapon_Weapon">commander::weapon::Weapon</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_add_weapon">add_weapon</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>, <a href="./weapon.md#commander_weapon">weapon</a>: Weapon) {
    <b>assert</b>!(r.<a href="./weapon.md#commander_weapon">weapon</a>.is_none(), <a href="./recruit.md#commander_recruit_EAlreadyHasWeapon">EAlreadyHasWeapon</a>);
    r.<a href="./weapon.md#commander_weapon">weapon</a>.fill(<a href="./weapon.md#commander_weapon">weapon</a>);
}
</code></pre>



</details>

<a name="commander_recruit_remove_weapon"></a>

## Function `remove_weapon`

Remove the weapon from the Recruit.
Aborts if the Recruit does not have a weapon.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_remove_weapon">remove_weapon</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): <a href="./weapon.md#commander_weapon_Weapon">commander::weapon::Weapon</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_remove_weapon">remove_weapon</a>(r: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): Weapon {
    <b>assert</b>!(r.<a href="./weapon.md#commander_weapon">weapon</a>.is_some(), <a href="./recruit.md#commander_recruit_ENoWeapon">ENoWeapon</a>);
    r.<a href="./weapon.md#commander_weapon">weapon</a>.extract()
}
</code></pre>



</details>

<a name="commander_recruit_armor"></a>

## Function `armor`

Get the armor of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor">armor</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): &<a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./armor.md#commander_armor">armor</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): &Option&lt;Armor&gt; { &r.<a href="./armor.md#commander_armor">armor</a> }
</code></pre>



</details>

<a name="commander_recruit_weapon"></a>

## Function `weapon`

Get the weapon of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./weapon.md#commander_weapon">weapon</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): &<a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./weapon.md#commander_weapon_Weapon">commander::weapon::Weapon</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./weapon.md#commander_weapon">weapon</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): &Option&lt;Weapon&gt; { &r.<a href="./weapon.md#commander_weapon">weapon</a> }
</code></pre>



</details>

<a name="commander_recruit_stats"></a>

## Function `stats`

Get the stats of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): &<a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): &Stats { &r.<a href="./stats.md#commander_stats">stats</a> }
</code></pre>



</details>

<a name="commander_recruit_rank"></a>

## Function `rank`

Get the rank of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./rank.md#commander_rank">rank</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): &<a href="./rank.md#commander_rank_Rank">commander::rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./rank.md#commander_rank">rank</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): &Rank { &r.<a href="./rank.md#commander_rank">rank</a> }
</code></pre>



</details>

<a name="commander_recruit_leader"></a>

## Function `leader`

Get the address of the Recruit's leader.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_leader">leader</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_leader">leader</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): <b>address</b> { r.<a href="./recruit.md#commander_recruit_leader">leader</a> }
</code></pre>



</details>

<a name="commander_recruit_metadata"></a>

## Function `metadata`

Get the metadata of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_metadata">metadata</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): &<a href="./recruit.md#commander_recruit_Metadata">commander::recruit::Metadata</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_metadata">metadata</a>(r: &<a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): &<a href="./recruit.md#commander_recruit_Metadata">Metadata</a> { &r.<a href="./recruit.md#commander_recruit_metadata">metadata</a> }
</code></pre>



</details>

<a name="commander_recruit_rank_up"></a>

## Function `rank_up`

Promotes the rank of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_rank_up">rank_up</a>(<a href="./recruit.md#commander_recruit">recruit</a>: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_rank_up">rank_up</a>(<a href="./recruit.md#commander_recruit">recruit</a>: &<b>mut</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>) { <a href="./recruit.md#commander_recruit">recruit</a>.<a href="./rank.md#commander_rank">rank</a>.<a href="./recruit.md#commander_recruit_rank_up">rank_up</a>() }
</code></pre>



</details>

<a name="commander_recruit_default"></a>

## Function `default`

Create a new <code><a href="./recruit.md#commander_recruit_Recruit">Recruit</a></code> with default values.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_default">default</a>(ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_default">default</a>(ctx: &<b>mut</b> TxContext): <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> {
    <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> {
        id: object::new(ctx),
        <a href="./recruit.md#commander_recruit_metadata">metadata</a>: <a href="./recruit.md#commander_recruit_Metadata">Metadata</a> {
            name: b"John Doe".to_string(),
            backstory: b"A rookie soldier, ready to prove themselves.".to_string(),
        },
        <a href="./rank.md#commander_rank">rank</a>: <a href="./rank.md#commander_rank_default">rank::default</a>(),
        <a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_default">stats::default</a>(),
        <a href="./weapon.md#commander_weapon">weapon</a>: option::none(),
        <a href="./armor.md#commander_armor">armor</a>: option::none(),
        <a href="./recruit.md#commander_recruit_leader">leader</a>: ctx.sender(),
    }
}
</code></pre>



</details>

<a name="commander_recruit_new"></a>

## Function `new`

Create a new <code><a href="./recruit.md#commander_recruit_Recruit">Recruit</a></code> with the given name and backstory.
TODOs:
- [ ] restrict who can submit new names and backstory. Right now anyone can
create a Recruit with any name and backstory.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_new">new</a>(name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, backstory: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_new">new</a>(name: String, backstory: String, ctx: &<b>mut</b> TxContext): <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> {
    <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> {
        id: object::new(ctx),
        <a href="./recruit.md#commander_recruit_metadata">metadata</a>: <a href="./recruit.md#commander_recruit_Metadata">Metadata</a> { name, backstory },
        <a href="./rank.md#commander_rank">rank</a>: <a href="./rank.md#commander_rank_rookie">rank::rookie</a>(),
        <a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_default">stats::default</a>(),
        <a href="./weapon.md#commander_weapon">weapon</a>: option::none(),
        <a href="./armor.md#commander_armor">armor</a>: option::none(),
        <a href="./recruit.md#commander_recruit_leader">leader</a>: ctx.sender(),
    }
}
</code></pre>



</details>

<a name="commander_recruit_dismiss"></a>

## Function `dismiss`

Dismiss the Recruit, remove them forever from the game.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_dismiss">dismiss</a>(<a href="./recruit.md#commander_recruit">recruit</a>: <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): (<a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./weapon.md#commander_weapon_Weapon">commander::weapon::Weapon</a>&gt;, <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./armor.md#commander_armor_Armor">commander::armor::Armor</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_dismiss">dismiss</a>(<a href="./recruit.md#commander_recruit">recruit</a>: <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>): (Option&lt;Weapon&gt;, Option&lt;Armor&gt;) {
    <b>let</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> { id, <a href="./weapon.md#commander_weapon">weapon</a>, <a href="./armor.md#commander_armor">armor</a>, .. } = <a href="./recruit.md#commander_recruit">recruit</a>;
    id.delete();
    (<a href="./weapon.md#commander_weapon">weapon</a>, <a href="./armor.md#commander_armor">armor</a>)
}
</code></pre>



</details>

<a name="commander_recruit_throw_away"></a>

## Function `throw_away`

Throw away the DogTag, destroy it and bury the memory.


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_throw_away">throw_away</a>(dog_tag: <a href="./recruit.md#commander_recruit_DogTag">commander::recruit::DogTag</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./recruit.md#commander_recruit_throw_away">throw_away</a>(dog_tag: <a href="./recruit.md#commander_recruit_DogTag">DogTag</a>) {
    <b>let</b> <a href="./recruit.md#commander_recruit_DogTag">DogTag</a> { id, .. } = dog_tag;
    id.delete();
}
</code></pre>



</details>

<a name="commander_recruit_kill"></a>

## Function `kill`

Kills the Recruit and returns the DogTag.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./recruit.md#commander_recruit_kill">kill</a>(<a href="./recruit.md#commander_recruit">recruit</a>: <a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./recruit.md#commander_recruit_DogTag">commander::recruit::DogTag</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./recruit.md#commander_recruit_kill">kill</a>(<a href="./recruit.md#commander_recruit">recruit</a>: <a href="./recruit.md#commander_recruit_Recruit">Recruit</a>, ctx: &<b>mut</b> TxContext): <a href="./recruit.md#commander_recruit_DogTag">DogTag</a> {
    <b>let</b> <a href="./recruit.md#commander_recruit_Recruit">Recruit</a> { id, <a href="./rank.md#commander_rank">rank</a>, <a href="./weapon.md#commander_weapon">weapon</a>, <a href="./recruit.md#commander_recruit_metadata">metadata</a>, <a href="./armor.md#commander_armor">armor</a>, .. } = <a href="./recruit.md#commander_recruit">recruit</a>;
    id.delete();
    // TODO: figure a way to leave the <a href="./weapon.md#commander_weapon">weapon</a>
    <a href="./weapon.md#commander_weapon">weapon</a>.destroy!(|w| w.destroy());
    <a href="./armor.md#commander_armor">armor</a>.destroy!(|a| a.destroy());
    <a href="./recruit.md#commander_recruit_DogTag">DogTag</a> { id: object::new(ctx), <a href="./rank.md#commander_rank">rank</a>, <a href="./recruit.md#commander_recruit_metadata">metadata</a> }
}
</code></pre>



</details>
