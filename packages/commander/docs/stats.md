
<a name="(commander=0x0)_stats"></a>

# Module `(commander=0x0)::stats`

Universal stats for Recruits and their equipment, and for <code>Unit</code>s.

Stats are built in a way that allows easy modification, negation and
addition. Recruit stats are distributed in their equipment, and during the
conversion to <code>Unit</code> (pre-battle), the stats are combined into a single
<code><a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a></code> value.


-  [Struct `Stats`](#(commander=0x0)_stats_Stats)
-  [Constants](#@Constants_0)
-  [Function `new`](#(commander=0x0)_stats_new)
-  [Function `new_unchecked`](#(commander=0x0)_stats_new_unchecked)
-  [Function `negate`](#(commander=0x0)_stats_negate)
-  [Function `default`](#(commander=0x0)_stats_default)
-  [Function `default_weapon`](#(commander=0x0)_stats_default_weapon)
-  [Function `default_armor`](#(commander=0x0)_stats_default_armor)
-  [Function `mobility`](#(commander=0x0)_stats_mobility)
-  [Function `aim`](#(commander=0x0)_stats_aim)
-  [Function `health`](#(commander=0x0)_stats_health)
-  [Function `armor`](#(commander=0x0)_stats_armor)
-  [Function `dodge`](#(commander=0x0)_stats_dodge)
-  [Function `defense`](#(commander=0x0)_stats_defense)
-  [Function `damage`](#(commander=0x0)_stats_damage)
-  [Function `spread`](#(commander=0x0)_stats_spread)
-  [Function `plus_one`](#(commander=0x0)_stats_plus_one)
-  [Function `crit_chance`](#(commander=0x0)_stats_crit_chance)
-  [Function `can_be_dodged`](#(commander=0x0)_stats_can_be_dodged)
-  [Function `area_size`](#(commander=0x0)_stats_area_size)
-  [Function `env_damage`](#(commander=0x0)_stats_env_damage)
-  [Function `range`](#(commander=0x0)_stats_range)
-  [Function `ammo`](#(commander=0x0)_stats_ammo)
-  [Function `inner`](#(commander=0x0)_stats_inner)
-  [Function `add`](#(commander=0x0)_stats_add)
-  [Function `to_string`](#(commander=0x0)_stats_to_string)
-  [Function `from_bytes`](#(commander=0x0)_stats_from_bytes)
-  [Function `from_bcs`](#(commander=0x0)_stats_from_bcs)


<pre><code><b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="(commander=0x0)_stats_Stats"></a>

## Struct `Stats`

The <code><a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a></code> struct is a single uint value that stores all the stats of
a <code>Recruit</code> in a single value. It uses bit manipulation to store the values
at the right positions.

16 values in a single u128 (in order):
- mobility
- aim
- health
- armor
- dodge
- defense (natural + cover bonus)
- damage
- spread
- plus_one (extra damage)
- crit_chance
- can_be_dodged
- area_size
- env_damage
- range
- ammo
- xxx (one u8 value is unused)


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: u128</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(commander=0x0)_stats_SIGN_VALUE"></a>

Capped at 7 bits. Max value for signed 8-bit integers.


<pre><code><b>const</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_SIGN_VALUE">SIGN_VALUE</a>: u8 = 128;
</code></pre>



<a name="(commander=0x0)_stats_NUM_PARAMS"></a>

Number of bitmap encoded parameters.


<pre><code><b>const</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_NUM_PARAMS">NUM_PARAMS</a>: u8 = 15;
</code></pre>



<a name="(commander=0x0)_stats_ENotImplemented"></a>

Error code for not implemented functions.


<pre><code><b>const</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_ENotImplemented">ENotImplemented</a>: u64 = 264;
</code></pre>



<a name="(commander=0x0)_stats_new"></a>

## Function `new`

Create a new <code>BitStats</code> struct with the given values.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_new">new</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a>: u8, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a>: u8): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_new">new</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a>: u8, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>: u8, <a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a>: u8): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(bf::pack_u8!(vector[<a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a>, <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a>]))
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_new_unchecked"></a>

## Function `new_unchecked`

Create a new <code><a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a></code> struct with the given unchecked value.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">new_unchecked</a>(v: u128): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_new_unchecked">new_unchecked</a>(v: u128): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> { <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(v) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_negate"></a>

## Function `negate`

Negates the modifier values. Creates a new <code>Modifier</code> which, when applied to
the <code>WeaponStats</code>, will negate the effects of the original modifier.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_negate">negate</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_negate">negate</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    <b>let</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> = <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0;
    <b>let</b> sign = <a href="../name_gen/stats.md#(commander=0x0)_stats_SIGN_VALUE">SIGN_VALUE</a>;
    <b>let</b> negated = bf::unpack_u8!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_NUM_PARAMS">NUM_PARAMS</a>).<a href="../name_gen/map.md#(commander=0x0)_map">map</a>!(|value| {
        <b>if</b> (value &gt; sign) value - sign <b>else</b> value + sign
    });
    <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(bf::pack_u8!(negated))
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_default"></a>

## Function `default`

Default stats for a Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default">default</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default">default</a>(): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> { <a href="../name_gen/stats.md#(commander=0x0)_stats_new">new</a>(7, 65, 10, 0, 0) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_default_weapon"></a>

## Function `default_weapon`

Default stats for a Weapon.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default_weapon">default_weapon</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default_weapon">default_weapon</a>(): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    // reverse:
    // 6-14 -&gt; <a href="../name_gen/stats.md#(commander=0x0)_stats_damage">damage</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_spread">spread</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_plus_one">plus_one</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_crit_chance">crit_chance</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_can_be_dodged">can_be_dodged</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_area_size">area_size</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_env_damage">env_damage</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_range">range</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_ammo">ammo</a>
    <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(0x03_04_00_01_01_00_00_02_04 &lt;&lt; (6 * 8))
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_default_armor"></a>

## Function `default_armor`

Default stats for an Armor.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default_armor">default_armor</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_default_armor">default_armor</a>(): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> { <a href="../name_gen/stats.md#(commander=0x0)_stats_new">new</a>(0, 0, 0, 0, 0) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_mobility"></a>

## Function `mobility`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_mobility">mobility</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 0) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_aim"></a>

## Function `aim`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_aim">aim</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 1) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_health"></a>

## Function `health`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_health">health</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 2) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_armor"></a>

## Function `armor`

Get the <code><a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 3) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_dodge"></a>

## Function `dodge`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_dodge">dodge</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 4) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_defense"></a>

## Function `defense`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_defense">defense</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_defense">defense</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_defense">defense</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 5) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_damage"></a>

## Function `damage`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_damage">damage</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_damage">damage</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_damage">damage</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 6) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_spread"></a>

## Function `spread`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_spread">spread</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_spread">spread</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_spread">spread</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 7) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_plus_one"></a>

## Function `plus_one`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_plus_one">plus_one</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_plus_one">plus_one</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_plus_one">plus_one</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 8) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_crit_chance"></a>

## Function `crit_chance`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_crit_chance">crit_chance</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_crit_chance">crit_chance</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_crit_chance">crit_chance</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 9) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_can_be_dodged"></a>

## Function `can_be_dodged`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_can_be_dodged">can_be_dodged</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_can_be_dodged">can_be_dodged</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_can_be_dodged">can_be_dodged</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 10) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_area_size"></a>

## Function `area_size`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_area_size">area_size</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_area_size">area_size</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_area_size">area_size</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 11) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_env_damage"></a>

## Function `env_damage`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_env_damage">env_damage</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_env_damage">env_damage</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_env_damage">env_damage</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 12) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_range"></a>

## Function `range`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_range">range</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_range">range</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_range">range</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 13) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_ammo"></a>

## Function `ammo`

Get the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_ammo">ammo</a></code> stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_ammo">ammo</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_ammo">ammo</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u8 { bf::read_u8_at_offset!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0, 14) }
</code></pre>



</details>

<a name="(commander=0x0)_stats_inner"></a>

## Function `inner`

Get the inner <code>u128</code> value of the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a></code>. Can be used for performance
optimizations and macros.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_inner">inner</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_inner">inner</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): u128 { <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0 }
</code></pre>



</details>

<a name="(commander=0x0)_stats_add"></a>

## Function `add`

Apply the modifier to the stats and return the modified value. Each value in
the <code>Modifier</code> can be positive or negative (the first sign bit is used), and
the value (0-127) is added or subtracted from the base stats.

The result can never overflow the base stats, and the values are capped at
the maximum values for each stat.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_add">add</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>, modifier: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_add">add</a>(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>, modifier: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    <b>let</b> <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a> = <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>.0;
    <b>let</b> modifier = modifier.0;
    <b>let</b> sign = <a href="../name_gen/stats.md#(commander=0x0)_stats_SIGN_VALUE">SIGN_VALUE</a>;
    <b>let</b> <b>mut</b> stat_values = bf::unpack_u8!(<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>, <a href="../name_gen/stats.md#(commander=0x0)_stats_NUM_PARAMS">NUM_PARAMS</a>);
    <b>let</b> modifier_values = bf::unpack_u8!(modifier, <a href="../name_gen/stats.md#(commander=0x0)_stats_NUM_PARAMS">NUM_PARAMS</a>);
    // version is not modified, the rest of the values are modified
    // based on the signed values of the modifier
    (<a href="../name_gen/stats.md#(commander=0x0)_stats_NUM_PARAMS">NUM_PARAMS</a> <b>as</b> u64).do!(|i| {
        <b>let</b> modifier = modifier_values[i];
        <b>let</b> value = stat_values[i];
        // skip 0 and -0 values
        <b>if</b> (modifier == 0 || modifier == sign) <b>return</b>;
        <b>let</b> new_value = <b>if</b> (modifier &gt; sign) {
            value - num_min!(modifier - sign, value)
        } <b>else</b> {
            // cannot overflow (127 is the max <b>for</b> modifier, below we cap values)
            value + modifier
        };
        *&<b>mut</b> stat_values[i] = num_min!(new_value, <a href="../name_gen/stats.md#(commander=0x0)_stats_SIGN_VALUE">SIGN_VALUE</a> - 1);
    });
    <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(bf::pack_u8!(stat_values))
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_to_string"></a>

## Function `to_string`

Print the <code><a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a></code> as a string.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_to_string">to_string</a>(_stats: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_to_string">to_string</a>(_stats: &<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>): String {
    <b>abort</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_ENotImplemented">ENotImplemented</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_from_bytes"></a>

## Function `from_bytes`

Deserialize bytes into a <code>Rank</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    <a href="../name_gen/stats.md#(commander=0x0)_stats_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="(commander=0x0)_stats_from_bcs"></a>

## Function `from_bcs`

Helper method to allow nested deserialization of <code>Rank</code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../dependencies/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">stats::Stats</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/stats.md#(commander=0x0)_stats_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a> {
    <a href="../name_gen/stats.md#(commander=0x0)_stats_Stats">Stats</a>(bcs.peel_u128())
}
</code></pre>



</details>
