
<a name="commander_unit"></a>

# Module `commander::unit`

Unit is a representation of the <code>Recruit</code> in the game. It copies most of the
fields of the <code>Recruit</code> into a "digestible" form for the <code>Map</code>. Units are
placed on the <code>Map</code> directly and linked to their corresponding <code>Recruit</code>s
via the <code><b>address</b></code> -> <code>UID</code>.

Traits:
- from_bcs
- to_string


-  [Struct `Unit`](#commander_unit_Unit)
-  [Constants](#@Constants_0)
-  [Function `attack_params`](#commander_unit_attack_params)
-  [Function `try_reset_ap`](#commander_unit_try_reset_ap)
-  [Function `perform_move`](#commander_unit_perform_move)
-  [Function `perform_reload`](#commander_unit_perform_reload)
-  [Function `perform_grenade`](#commander_unit_perform_grenade)
-  [Function `perform_attack`](#commander_unit_perform_attack)
-  [Function `apply_damage`](#commander_unit_apply_damage)
-  [Function `from_recruit`](#commander_unit_from_recruit)
-  [Function `destroy`](#commander_unit_destroy)
-  [Function `recruit_id`](#commander_unit_recruit_id)
-  [Function `hp`](#commander_unit_hp)
-  [Function `ap`](#commander_unit_ap)
-  [Function `ammo`](#commander_unit_ammo)
-  [Function `grenade_used`](#commander_unit_grenade_used)
-  [Function `stats`](#commander_unit_stats)
-  [Function `from_bytes`](#commander_unit_from_bytes)
-  [Function `from_bcs`](#commander_unit_from_bcs)
-  [Function `to_string`](#commander_unit_to_string)


<pre><code><b>use</b> <a href="./armor.md#commander_armor">commander::armor</a>;
<b>use</b> <a href="./param.md#commander_param">commander::param</a>;
<b>use</b> <a href="./rank.md#commander_rank">commander::rank</a>;
<b>use</b> <a href="./recruit.md#commander_recruit">commander::recruit</a>;
<b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="./weapon.md#commander_weapon">commander::weapon</a>;
<b>use</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade">commander::weapon_upgrade</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/random.md#sui_random">sui::random</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="commander_unit_Unit"></a>

## Struct `Unit`

A single <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> on the <code>Map</code>.


<pre><code><b>public</b> <b>struct</b> <a href="./unit.md#commander_unit_Unit">Unit</a> <b>has</b> <b>copy</b>, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./recruit.md#commander_recruit">recruit</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
 The <code>ID</code> of the <code>Recruit</code>.
</dd>
<dt>
<code><a href="./unit.md#commander_unit_ap">ap</a>: <a href="./param.md#commander_param_Param">commander::param::Param</a></code>
</dt>
<dd>
 Number of actions the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> can perform in a single turn. Resets at the
 beginning of each turn. A single action takes 1 point, options vary from
 moving, attacking, using abilities, etc.
</dd>
<dt>
<code><a href="./unit.md#commander_unit_hp">hp</a>: <a href="./param.md#commander_param_Param">commander::param::Param</a></code>
</dt>
<dd>
 The HP of the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>.
</dd>
<dt>
<code><a href="./unit.md#commander_unit_ammo">ammo</a>: <a href="./param.md#commander_param_Param">commander::param::Param</a></code>
</dt>
<dd>
 The ammo of the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>.
</dd>
<dt>
<code><a href="./unit.md#commander_unit_grenade_used">grenade_used</a>: bool</code>
</dt>
<dd>
 If the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> has used a grenade in the encounter.
</dd>
<dt>
<code><a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a></code>
</dt>
<dd>
 Stats of the <code>Recruit</code>.
</dd>
<dt>
<code>last_turn: u16</code>
</dt>
<dd>
 The last turn the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> has performed an action.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="commander_unit_ERangeExceeded"></a>

Trying to attack a target that is out of range.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_ERangeExceeded">ERangeExceeded</a>: u64 = 1;
</code></pre>



<a name="commander_unit_EOutOfAmmo"></a>

Trying to attack with no ammo.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_EOutOfAmmo">EOutOfAmmo</a>: u64 = 2;
</code></pre>



<a name="commander_unit_ENoAP"></a>

No AP left to perform an action.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_ENoAP">ENoAP</a>: u64 = 3;
</code></pre>



<a name="commander_unit_EFullAmmo"></a>

Trying to reload at full clip capacity.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_EFullAmmo">EFullAmmo</a>: u64 = 4;
</code></pre>



<a name="commander_unit_MAX_RANGE_OFFSET"></a>

Weapon range can be exceeded by this value with aim penalty.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_MAX_RANGE_OFFSET">MAX_RANGE_OFFSET</a>: u8 = 3;
</code></pre>



<a name="commander_unit_DISTANCE_BONUS"></a>

If distance is less than range, the aim bonus is applied for each tile.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_DISTANCE_BONUS">DISTANCE_BONUS</a>: u8 = 5;
</code></pre>



<a name="commander_unit_DISTANCE_PENALTY"></a>

If distance is greater than range, the aim penalty is applied for each tile.


<pre><code><b>const</b> <a href="./unit.md#commander_unit_DISTANCE_PENALTY">DISTANCE_PENALTY</a>: u8 = 10;
</code></pre>



<a name="commander_unit_attack_params"></a>

## Function `attack_params`

Get the attack parameters of the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>: damage and aim.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_attack_params">attack_params</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_attack_params">attack_params</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): (u16, u16) {
    (<a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.damage() <b>as</b> u16, <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.aim() <b>as</b> u16)
}
</code></pre>



</details>

<a name="commander_unit_try_reset_ap"></a>

## Function `try_reset_ap`

Reset the AP of the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> to the default value if the turn is over.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_try_reset_ap">try_reset_ap</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>, turn: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_try_reset_ap">try_reset_ap</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>, turn: u16) {
    <b>if</b> (<a href="./unit.md#commander_unit">unit</a>.last_turn &lt; turn) <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.reset();
    <a href="./unit.md#commander_unit">unit</a>.last_turn = turn;
}
</code></pre>



</details>

<a name="commander_unit_perform_move"></a>

## Function `perform_move`

Get the HP of the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_move">perform_move</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>, distance: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_move">perform_move</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>, distance: u8) {
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.mobility() &gt;= distance, <a href="./unit.md#commander_unit_ERangeExceeded">ERangeExceeded</a>);
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.value() &gt; 0, <a href="./unit.md#commander_unit_ENoAP">ENoAP</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.decrease(1);
}
</code></pre>



</details>

<a name="commander_unit_perform_reload"></a>

## Function `perform_reload`

Reload <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s weapon. It costs 1 AP.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_reload">perform_reload</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_reload">perform_reload</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>) {
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.value() &gt; 0, <a href="./unit.md#commander_unit_ENoAP">ENoAP</a>);
    <b>assert</b>!(!<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>.is_full(), <a href="./unit.md#commander_unit_EFullAmmo">EFullAmmo</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.decrease(1);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>.reset();
}
</code></pre>



</details>

<a name="commander_unit_perform_grenade"></a>

## Function `perform_grenade`

Throw a grenade if there's one in the inventory. It costs 1 AP.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_grenade">perform_grenade</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_grenade">perform_grenade</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>) {
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.value() &gt; 0, <a href="./unit.md#commander_unit_ENoAP">ENoAP</a>);
    <b>assert</b>!(!<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_grenade_used">grenade_used</a>, <a href="./unit.md#commander_unit_EOutOfAmmo">EOutOfAmmo</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.decrease(1);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_grenade_used">grenade_used</a> = <b>true</b>;
}
</code></pre>



</details>

<a name="commander_unit_perform_attack"></a>

## Function `perform_attack`

The <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> performs an attack on another <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>. The attack is calculated
from the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s stats and returns the damage dealt. It does not include
the target's armor or dodge, which should be calculated separately.

Notes:
- Crit chance is currently hardcoded to 10%.
- Crit damage is 50% higher than the base damage.
- Regular attack can be + or - 10% of the base damage - random.
- The attack fully depletes the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s AP.

Returns: (is_hit, is_critical, is_plus_one, damage, hit_chance)

Rng security:
- this function is more expensive in the happy path, so the gas limit attack
is less likely to be successful


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_attack">perform_attack</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>, rng: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, range: u8, target_defense: u8): (bool, bool, bool, u8, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_perform_attack">perform_attack</a>(
    <a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>,
    rng: &<b>mut</b> RandomGenerator,
    range: u8,
    target_defense: u8,
): (bool, bool, bool, u8, u8) {
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.value() &gt; 0, <a href="./unit.md#commander_unit_ENoAP">ENoAP</a>);
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>.value() &gt; 0, <a href="./unit.md#commander_unit_EOutOfAmmo">EOutOfAmmo</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.deplete();
    <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>.decrease(1);
    <b>let</b> crit_chance = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.crit_chance();
    <b>let</b> dmg_stat = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.damage();
    <b>let</b> eff_range = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.range();
    <b>let</b> aim_stat = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.aim();
    <b>let</b> spread = <a href="./unit.md#commander_unit_MAX_RANGE_OFFSET">MAX_RANGE_OFFSET</a>;
    <b>assert</b>!(eff_range + spread &gt;= range, <a href="./unit.md#commander_unit_ERangeExceeded">ERangeExceeded</a>);
    // aim stat is affected by the range
    <b>let</b> hit_chance = <b>if</b> (eff_range == range) {
        aim_stat
    } <b>else</b> <b>if</b> (eff_range &gt; range) {
        (aim_stat + <a href="./unit.md#commander_unit_DISTANCE_BONUS">DISTANCE_BONUS</a> * (eff_range - range)).min(100)
    } <b>else</b> {
        aim_stat - (<a href="./unit.md#commander_unit_DISTANCE_PENALTY">DISTANCE_PENALTY</a> * (range - eff_range)).min(aim_stat)
    };
    // adjust the hit chance by the target's defense, avoid underflow
    <b>let</b> hit_chance = hit_chance - hit_chance.min(target_defense);
    <b>let</b> is_hit = rng.generate_u8_in_range(0, 99) &lt; hit_chance;
    <b>if</b> (!is_hit) <b>return</b> (<b>false</b>, <b>false</b>, <b>false</b>, 0, hit_chance);
    <b>let</b> spread = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.spread();
    <b>let</b> is_critical = rng.generate_u8_in_range(0, 99) &lt; crit_chance;
    <b>let</b> damage = match (rng.generate_bool()) {
        <b>true</b> =&gt; dmg_stat + rng.generate_u8_in_range(0, spread),
        <b>false</b> =&gt; dmg_stat - rng.generate_u8_in_range(0, spread),
    };
    <b>let</b> is_plus_one = rng.generate_u8_in_range(0, 99) &lt; <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.plus_one();
    <b>let</b> damage = <b>if</b> (is_plus_one) damage + 1 <b>else</b> damage;
    <b>let</b> damage = <b>if</b> (is_critical) damage + (dmg_stat / 2) <b>else</b> damage;
    (<b>true</b>, is_plus_one, is_critical, damage, hit_chance)
}
</code></pre>



</details>

<a name="commander_unit_apply_damage"></a>

## Function `apply_damage`

Apply damage to unit, can be dodged (shot) or not (explosive).

Returns: (is_dodged, damage applied, is_kia),


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_apply_damage">apply_damage</a>(<a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>, rng: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, damage: u8, can_dodge: bool): (bool, u8, bool)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_apply_damage">apply_damage</a>(
    <a href="./unit.md#commander_unit">unit</a>: &<b>mut</b> <a href="./unit.md#commander_unit_Unit">Unit</a>,
    rng: &<b>mut</b> RandomGenerator,
    damage: u8,
    can_dodge: bool,
): (bool, u8, bool) {
    <b>let</b> dodge_stat = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.dodge();
    <b>let</b> armor_stat = <a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a>.<a href="./armor.md#commander_armor">armor</a>();
    <b>let</b> damage = <b>if</b> (armor_stat &gt;= damage) 1 <b>else</b> damage - armor_stat;
    // <b>if</b> attack can be dodged, spin the wheel and see <b>if</b> the <a href="./unit.md#commander_unit">unit</a> dodges
    <b>let</b> rng = rng.generate_u8_in_range(0, 99);
    <b>if</b> (can_dodge && rng &lt; dodge_stat) {
        <b>return</b> (<b>true</b>, 0, <b>false</b>)
    };
    <b>let</b> hp_left = <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_hp">hp</a>.decrease(damage <b>as</b> u16);
    (<b>false</b>, damage, hp_left == 0)
}
</code></pre>



</details>

<a name="commander_unit_from_recruit"></a>

## Function `from_recruit`

Creates a new <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> - an in-game representation of a <code>Recruit</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_from_recruit">from_recruit</a>(<a href="./recruit.md#commander_recruit">recruit</a>: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>): <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_from_recruit">from_recruit</a>(<a href="./recruit.md#commander_recruit">recruit</a>: &Recruit): <a href="./unit.md#commander_unit_Unit">Unit</a> {
    <b>let</b> <a href="./stats.md#commander_stats">stats</a> = *<a href="./recruit.md#commander_recruit">recruit</a>.<a href="./stats.md#commander_stats">stats</a>();
    <b>let</b> <b>mut</b> armor_stats = <a href="./stats.md#commander_stats_default_armor">stats::default_armor</a>();
    <b>let</b> <b>mut</b> weapon_stats = <a href="./stats.md#commander_stats_default_weapon">stats::default_weapon</a>();
    <a href="./recruit.md#commander_recruit">recruit</a>.<a href="./weapon.md#commander_weapon">weapon</a>().do_ref!(|w| weapon_stats = *w.<a href="./stats.md#commander_stats">stats</a>());
    <a href="./recruit.md#commander_recruit">recruit</a>.<a href="./armor.md#commander_armor">armor</a>().do_ref!(|a| armor_stats = *a.<a href="./stats.md#commander_stats">stats</a>());
    <b>let</b> <a href="./stats.md#commander_stats">stats</a> = <a href="./stats.md#commander_stats">stats</a>.add(&weapon_stats.add(&armor_stats));
    <a href="./unit.md#commander_unit_Unit">Unit</a> {
        <a href="./recruit.md#commander_recruit">recruit</a>: object::id(<a href="./recruit.md#commander_recruit">recruit</a>),
        <a href="./unit.md#commander_unit_ap">ap</a>: <a href="./param.md#commander_param_new">param::new</a>(2),
        <a href="./unit.md#commander_unit_hp">hp</a>: <a href="./param.md#commander_param_new">param::new</a>(<a href="./stats.md#commander_stats">stats</a>.health() <b>as</b> u16),
        <a href="./unit.md#commander_unit_ammo">ammo</a>: <a href="./param.md#commander_param_new">param::new</a>(<a href="./stats.md#commander_stats">stats</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>() <b>as</b> u16),
        <a href="./unit.md#commander_unit_grenade_used">grenade_used</a>: <b>false</b>,
        <a href="./stats.md#commander_stats">stats</a>,
        last_turn: 0,
    }
}
</code></pre>



</details>

<a name="commander_unit_destroy"></a>

## Function `destroy`

Destroy the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> struct. KIA.
Returns the <code>ID</code> of the <code>Recruit</code> for easier tracking and "elimination" of
the <code>Recruit</code> from the game.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_destroy">destroy</a>(<a href="./unit.md#commander_unit">unit</a>: <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_destroy">destroy</a>(<a href="./unit.md#commander_unit">unit</a>: <a href="./unit.md#commander_unit_Unit">Unit</a>): ID {
    <b>let</b> <a href="./unit.md#commander_unit_Unit">Unit</a> { <a href="./recruit.md#commander_recruit">recruit</a>, .. } = <a href="./unit.md#commander_unit">unit</a>;
    <a href="./recruit.md#commander_recruit">recruit</a>
}
</code></pre>



</details>

<a name="commander_unit_recruit_id"></a>

## Function `recruit_id`

Get the <code>Recruit</code>'s ID from the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_recruit_id">recruit_id</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_recruit_id">recruit_id</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): ID { <a href="./unit.md#commander_unit">unit</a>.<a href="./recruit.md#commander_recruit">recruit</a> }
</code></pre>



</details>

<a name="commander_unit_hp"></a>

## Function `hp`

Get the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s HP.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_hp">hp</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_hp">hp</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): u16 { <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_hp">hp</a>.value() }
</code></pre>



</details>

<a name="commander_unit_ap"></a>

## Function `ap`

Get the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s AP.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_ap">ap</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_ap">ap</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): u16 { <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ap">ap</a>.value() }
</code></pre>



</details>

<a name="commander_unit_ammo"></a>

## Function `ammo`

Get the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s ammo.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_ammo">ammo</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_ammo">ammo</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): u16 { <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_ammo">ammo</a>.value() }
</code></pre>



</details>

<a name="commander_unit_grenade_used"></a>

## Function `grenade_used`

Get whether a grenade was used.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_grenade_used">grenade_used</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_grenade_used">grenade_used</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): bool { <a href="./unit.md#commander_unit">unit</a>.<a href="./unit.md#commander_unit_grenade_used">grenade_used</a> }
</code></pre>



</details>

<a name="commander_unit_stats"></a>

## Function `stats`

Get the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>'s stats.


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): &<a href="./stats.md#commander_stats_Stats">commander::stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./stats.md#commander_stats">stats</a>(<a href="./unit.md#commander_unit">unit</a>: &<a href="./unit.md#commander_unit_Unit">Unit</a>): &Stats { &<a href="./unit.md#commander_unit">unit</a>.<a href="./stats.md#commander_stats">stats</a> }
</code></pre>



</details>

<a name="commander_unit_from_bytes"></a>

## Function `from_bytes`

Deserialize bytes into a <code>Rank</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./unit.md#commander_unit_Unit">Unit</a> {
    <a href="./unit.md#commander_unit_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="commander_unit_from_bcs"></a>

## Function `from_bcs`

Helper method to allow nested deserialization of <code><a href="./unit.md#commander_unit_Unit">Unit</a></code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./unit.md#commander_unit_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): <a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./unit.md#commander_unit_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="./unit.md#commander_unit_Unit">Unit</a> {
    <a href="./unit.md#commander_unit_Unit">Unit</a> {
        <a href="./recruit.md#commander_recruit">recruit</a>: bcs.peel_address().to_id(),
        <a href="./unit.md#commander_unit_ap">ap</a>: <a href="./param.md#commander_param_from_bcs">param::from_bcs</a>(bcs),
        <a href="./unit.md#commander_unit_hp">hp</a>: <a href="./param.md#commander_param_from_bcs">param::from_bcs</a>(bcs),
        <a href="./unit.md#commander_unit_ammo">ammo</a>: <a href="./param.md#commander_param_from_bcs">param::from_bcs</a>(bcs),
        <a href="./unit.md#commander_unit_grenade_used">grenade_used</a>: bcs.peel_bool(),
        <a href="./stats.md#commander_stats">stats</a>: <a href="./stats.md#commander_stats_from_bcs">stats::from_bcs</a>(bcs),
        last_turn: bcs.peel_u16(),
    }
}
</code></pre>



</details>

<a name="commander_unit_to_string"></a>

## Function `to_string`

Print the <code><a href="./unit.md#commander_unit_Unit">Unit</a></code> as a <code>String</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_to_string">to_string</a>(_unit: &<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit_to_string">to_string</a>(_unit: &<a href="./unit.md#commander_unit_Unit">Unit</a>): String { b"<a href="./unit.md#commander_unit_Unit">Unit</a>".<a href="./unit.md#commander_unit_to_string">to_string</a>() }
</code></pre>



</details>
