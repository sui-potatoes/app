
<a name="(commander=0x0)_rank"></a>

# Module `(commander=0x0)::rank`

Defines the ranking system for the game. Each Recruit gets assigned a rank,
normally starting with a <code>Rookie</code> and then getting promoted to higher ranks.

Traits:
- default
- from_bcs
- to_string


-  [Enum `Rank`](#(commander=0x0)_rank_Rank)
-  [Constants](#@Constants_0)
-  [Function `default`](#(commander=0x0)_rank_default)
-  [Function `rookie`](#(commander=0x0)_rank_rookie)
-  [Function `squaddie`](#(commander=0x0)_rank_squaddie)
-  [Function `corporal`](#(commander=0x0)_rank_corporal)
-  [Function `sergeant`](#(commander=0x0)_rank_sergeant)
-  [Function `lieutenant`](#(commander=0x0)_rank_lieutenant)
-  [Function `captain`](#(commander=0x0)_rank_captain)
-  [Function `major`](#(commander=0x0)_rank_major)
-  [Function `colonel`](#(commander=0x0)_rank_colonel)
-  [Function `rank_up`](#(commander=0x0)_rank_rank_up)
-  [Function `is_rookie`](#(commander=0x0)_rank_is_rookie)
-  [Function `is_squaddie`](#(commander=0x0)_rank_is_squaddie)
-  [Function `is_corporal`](#(commander=0x0)_rank_is_corporal)
-  [Function `is_sergeant`](#(commander=0x0)_rank_is_sergeant)
-  [Function `is_lieutenant`](#(commander=0x0)_rank_is_lieutenant)
-  [Function `is_captain`](#(commander=0x0)_rank_is_captain)
-  [Function `is_major`](#(commander=0x0)_rank_is_major)
-  [Function `is_colonel`](#(commander=0x0)_rank_is_colonel)
-  [Function `from_bytes`](#(commander=0x0)_rank_from_bytes)
-  [Function `from_bcs`](#(commander=0x0)_rank_from_bcs)
-  [Function `to_string`](#(commander=0x0)_rank_to_string)


<pre><code><b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="(commander=0x0)_rank_Rank"></a>

## Enum `Rank`

Defines all available ranks in the game.


<pre><code><b>public</b> <b>enum</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Rookie</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Squaddie</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Corporal</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Sergeant</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Lieutenant</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Captain</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Major</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Colonel</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(commander=0x0)_rank_EMaxRank"></a>



<pre><code><b>const</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_EMaxRank">EMaxRank</a>: u64 = 1;
</code></pre>



<a name="(commander=0x0)_rank_default"></a>

## Function `default`

Default rank for a new Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_default">default</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_default">default</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Rookie }
</code></pre>



</details>

<a name="(commander=0x0)_rank_rookie"></a>

## Function `rookie`

Create a new <code>Rookie</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_rookie">rookie</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_rookie">rookie</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Rookie }
</code></pre>



</details>

<a name="(commander=0x0)_rank_squaddie"></a>

## Function `squaddie`

Create a new <code>Squaddie</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_squaddie">squaddie</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_squaddie">squaddie</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Squaddie }
</code></pre>



</details>

<a name="(commander=0x0)_rank_corporal"></a>

## Function `corporal`

Create a new <code>Corporal</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_corporal">corporal</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_corporal">corporal</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Corporal }
</code></pre>



</details>

<a name="(commander=0x0)_rank_sergeant"></a>

## Function `sergeant`

Create a new <code>Sergeant</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_sergeant">sergeant</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_sergeant">sergeant</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Sergeant }
</code></pre>



</details>

<a name="(commander=0x0)_rank_lieutenant"></a>

## Function `lieutenant`

Create a new <code>Lieutenant</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_lieutenant">lieutenant</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_lieutenant">lieutenant</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Lieutenant }
</code></pre>



</details>

<a name="(commander=0x0)_rank_captain"></a>

## Function `captain`

Create a new <code>Captain</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_captain">captain</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_captain">captain</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Captain }
</code></pre>



</details>

<a name="(commander=0x0)_rank_major"></a>

## Function `major`

Create a new <code>Major</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_major">major</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_major">major</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Major }
</code></pre>



</details>

<a name="(commander=0x0)_rank_colonel"></a>

## Function `colonel`

Create a new <code>Colonel</code> rank.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_colonel">colonel</a>(): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_colonel">colonel</a>(): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> { Rank::Colonel }
</code></pre>



</details>

<a name="(commander=0x0)_rank_rank_up"></a>

## Function `rank_up`

Promotes the rank of the Recruit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_rank_up">rank_up</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_rank_up">rank_up</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<b>mut</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>) {
    *<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a> =
        match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
            Rank::Rookie =&gt; Rank::Squaddie,
            Rank::Squaddie =&gt; Rank::Corporal,
            Rank::Corporal =&gt; Rank::Sergeant,
            Rank::Sergeant =&gt; Rank::Lieutenant,
            Rank::Lieutenant =&gt; Rank::Captain,
            Rank::Captain =&gt; Rank::Major,
            Rank::Major =&gt; Rank::Colonel,
            Rank::Colonel =&gt; <b>abort</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_EMaxRank">EMaxRank</a>,
        }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_rookie"></a>

## Function `is_rookie`

Check if the rank is a <code>Rookie</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_rookie">is_rookie</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_rookie">is_rookie</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Rookie =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_squaddie"></a>

## Function `is_squaddie`

Check if the rank is a <code>Squaddie</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_squaddie">is_squaddie</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_squaddie">is_squaddie</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Squaddie =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_corporal"></a>

## Function `is_corporal`

Check if the rank is a <code>Corporal</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_corporal">is_corporal</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_corporal">is_corporal</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Corporal =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_sergeant"></a>

## Function `is_sergeant`

Check if the rank is a <code>Sergeant</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_sergeant">is_sergeant</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_sergeant">is_sergeant</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Sergeant =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_lieutenant"></a>

## Function `is_lieutenant`

Check if the rank is a <code>Lieutenant</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_lieutenant">is_lieutenant</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_lieutenant">is_lieutenant</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Lieutenant =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_captain"></a>

## Function `is_captain`

Check if the rank is a <code>Captain</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_captain">is_captain</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_captain">is_captain</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Captain =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_major"></a>

## Function `is_major`

Check if the rank is a <code>Major</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_major">is_major</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_major">is_major</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Major =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_is_colonel"></a>

## Function `is_colonel`

Check if the rank is a <code>Colonel</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_colonel">is_colonel</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_is_colonel">is_colonel</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): bool {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Colonel =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_from_bytes"></a>

## Function `from_bytes`

Deserialize bytes into a <code><a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> {
    <a href="../name_gen/rank.md#(commander=0x0)_rank_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_from_bcs"></a>

## Function `from_bcs`

Helper method to allow nested deserialization of <code><a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a></code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../dependencies/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a> {
    match (bcs.peel_u8()) {
        0 =&gt; Rank::Rookie,
        1 =&gt; Rank::Squaddie,
        2 =&gt; Rank::Corporal,
        3 =&gt; Rank::Sergeant,
        4 =&gt; Rank::Lieutenant,
        5 =&gt; Rank::Captain,
        6 =&gt; Rank::Major,
        7 =&gt; Rank::Colonel,
        _ =&gt; <b>abort</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_rank_to_string"></a>

## Function `to_string`

Convert the rank to a string. Very useful for debugging and logging.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_to_string">to_string</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">rank::Rank</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/rank.md#(commander=0x0)_rank_to_string">to_string</a>(<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>: &<a href="../name_gen/rank.md#(commander=0x0)_rank_Rank">Rank</a>): String {
    match (<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>) {
        Rank::Rookie =&gt; b"Rookie",
        Rank::Squaddie =&gt; b"Squaddie",
        Rank::Corporal =&gt; b"Corporal",
        Rank::Sergeant =&gt; b"Sergeant",
        Rank::Lieutenant =&gt; b"Lieutenant",
        Rank::Captain =&gt; b"Captain",
        Rank::Major =&gt; b"Major",
        Rank::Colonel =&gt; b"Colonel",
    }.<a href="../name_gen/rank.md#(commander=0x0)_rank_to_string">to_string</a>()
}
</code></pre>



</details>
