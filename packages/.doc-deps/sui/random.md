
<a name="sui_random"></a>

# Module `sui::random`

This module provides functionality for generating secure randomness.


-  [Struct `Random`](#sui_random_Random)
-  [Struct `RandomInner`](#sui_random_RandomInner)
-  [Struct `RandomGenerator`](#sui_random_RandomGenerator)
-  [Constants](#@Constants_0)
-  [Function `create`](#sui_random_create)
-  [Function `load_inner_mut`](#sui_random_load_inner_mut)
-  [Function `load_inner`](#sui_random_load_inner)
-  [Function `update_randomness_state`](#sui_random_update_randomness_state)
-  [Function `new_generator`](#sui_random_new_generator)
-  [Function `derive_next_block`](#sui_random_derive_next_block)
-  [Function `generate_bytes`](#sui_random_generate_bytes)
-  [Macro function `uint_from_bytes`](#sui_random_uint_from_bytes)
-  [Function `generate_u256`](#sui_random_generate_u256)
-  [Function `generate_u128`](#sui_random_generate_u128)
-  [Function `generate_u64`](#sui_random_generate_u64)
-  [Function `generate_u32`](#sui_random_generate_u32)
-  [Function `generate_u16`](#sui_random_generate_u16)
-  [Function `generate_u8`](#sui_random_generate_u8)
-  [Function `generate_bool`](#sui_random_generate_bool)
-  [Macro function `uint_in_range`](#sui_random_uint_in_range)
-  [Function `generate_u128_in_range`](#sui_random_generate_u128_in_range)
-  [Function `generate_u64_in_range`](#sui_random_generate_u64_in_range)
-  [Function `generate_u32_in_range`](#sui_random_generate_u32_in_range)
-  [Function `generate_u16_in_range`](#sui_random_generate_u16_in_range)
-  [Function `generate_u8_in_range`](#sui_random_generate_u8_in_range)
-  [Function `shuffle`](#sui_random_shuffle)


<pre><code><b>use</b> <a href="../../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../dependencies/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../dependencies/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../dependencies/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../dependencies/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../dependencies/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="sui_random_Random"></a>

## Struct `Random`

Singleton shared object which stores the global randomness state.
The actual state is stored in a versioned inner field.


<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui/random.md#sui_random_Random">Random</a> <b>has</b> key
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
<dt>
<code>inner: <a href="../../dependencies/sui/versioned.md#sui_versioned_Versioned">sui::versioned::Versioned</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_random_RandomInner"></a>

## Struct `RandomInner`



<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>version: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>epoch: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>randomness_round: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>random_bytes: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_random_RandomGenerator"></a>

## Struct `RandomGenerator`

Unique randomness generator, derived from the global randomness.


<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>seed: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>counter: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>buffer: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="sui_random_ENotSystemAddress"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_ENotSystemAddress">ENotSystemAddress</a>: u64 = 0;
</code></pre>



<a name="sui_random_EWrongInnerVersion"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_EWrongInnerVersion">EWrongInnerVersion</a>: u64 = 1;
</code></pre>



<a name="sui_random_EInvalidRandomnessUpdate"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_EInvalidRandomnessUpdate">EInvalidRandomnessUpdate</a>: u64 = 2;
</code></pre>



<a name="sui_random_EInvalidRange"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_EInvalidRange">EInvalidRange</a>: u64 = 3;
</code></pre>



<a name="sui_random_EInvalidLength"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_EInvalidLength">EInvalidLength</a>: u64 = 4;
</code></pre>



<a name="sui_random_CURRENT_VERSION"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_CURRENT_VERSION">CURRENT_VERSION</a>: u64 = 1;
</code></pre>



<a name="sui_random_RAND_OUTPUT_LEN"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_RAND_OUTPUT_LEN">RAND_OUTPUT_LEN</a>: u16 = 32;
</code></pre>



<a name="sui_random_U16_MAX"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/random.md#sui_random_U16_MAX">U16_MAX</a>: u64 = 65535;
</code></pre>



<a name="sui_random_create"></a>

## Function `create`

Create and share the Random object. This function is called exactly once, when
the Random object is first created.
Can only be called by genesis or change_epoch transactions.


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_create">create</a>(ctx: &<b>mut</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_create">create</a>(ctx: &<b>mut</b> TxContext) {
    <b>assert</b>!(ctx.sender() == @0x0, <a href="../../dependencies/sui/random.md#sui_random_ENotSystemAddress">ENotSystemAddress</a>);
    <b>let</b> version = <a href="../../dependencies/sui/random.md#sui_random_CURRENT_VERSION">CURRENT_VERSION</a>;
    <b>let</b> inner = <a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> {
        version,
        epoch: ctx.epoch(),
        randomness_round: 0,
        random_bytes: vector[],
    };
    <b>let</b> self = <a href="../../dependencies/sui/random.md#sui_random_Random">Random</a> {
        id: object::randomness_state(),
        inner: versioned::create(version, inner, ctx),
    };
    transfer::share_object(self);
}
</code></pre>



</details>

<a name="sui_random_load_inner_mut"></a>

## Function `load_inner_mut`



<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_load_inner_mut">load_inner_mut</a>(self: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>): &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomInner">sui::random::RandomInner</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_load_inner_mut">load_inner_mut</a>(self: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_Random">Random</a>): &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> {
    <b>let</b> version = versioned::version(&self.inner);
    // Replace this with a lazy update function when we add a new version of the inner object.
    <b>assert</b>!(version == <a href="../../dependencies/sui/random.md#sui_random_CURRENT_VERSION">CURRENT_VERSION</a>, <a href="../../dependencies/sui/random.md#sui_random_EWrongInnerVersion">EWrongInnerVersion</a>);
    <b>let</b> inner: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> = self.inner.load_value_mut();
    <b>assert</b>!(inner.version == version, <a href="../../dependencies/sui/random.md#sui_random_EWrongInnerVersion">EWrongInnerVersion</a>);
    inner
}
</code></pre>



</details>

<a name="sui_random_load_inner"></a>

## Function `load_inner`



<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_load_inner">load_inner</a>(self: &<a href="../../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>): &<a href="../../dependencies/sui/random.md#sui_random_RandomInner">sui::random::RandomInner</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_load_inner">load_inner</a>(self: &<a href="../../dependencies/sui/random.md#sui_random_Random">Random</a>): &<a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> {
    <b>let</b> version = self.inner.version();
    // Replace this with a lazy update function when we add a new version of the inner object.
    <b>assert</b>!(version == <a href="../../dependencies/sui/random.md#sui_random_CURRENT_VERSION">CURRENT_VERSION</a>, <a href="../../dependencies/sui/random.md#sui_random_EWrongInnerVersion">EWrongInnerVersion</a>);
    <b>let</b> inner: &<a href="../../dependencies/sui/random.md#sui_random_RandomInner">RandomInner</a> = self.inner.load_value();
    <b>assert</b>!(inner.version == version, <a href="../../dependencies/sui/random.md#sui_random_EWrongInnerVersion">EWrongInnerVersion</a>);
    inner
}
</code></pre>



</details>

<a name="sui_random_update_randomness_state"></a>

## Function `update_randomness_state`

Record new randomness. Called when executing the RandomnessStateUpdate system
transaction.


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_update_randomness_state">update_randomness_state</a>(self: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>, new_round: u64, new_bytes: vector&lt;u8&gt;, ctx: &<a href="../../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_update_randomness_state">update_randomness_state</a>(
    self: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_Random">Random</a>,
    new_round: u64,
    new_bytes: vector&lt;u8&gt;,
    ctx: &TxContext,
) {
    // Validator will make a special system call with sender set <b>as</b> 0x0.
    <b>assert</b>!(ctx.sender() == @0x0, <a href="../../dependencies/sui/random.md#sui_random_ENotSystemAddress">ENotSystemAddress</a>);
    // Randomness should only be incremented.
    <b>let</b> epoch = ctx.epoch();
    <b>let</b> inner = self.<a href="../../dependencies/sui/random.md#sui_random_load_inner_mut">load_inner_mut</a>();
    <b>if</b> (inner.randomness_round == 0 && inner.epoch == 0 && inner.random_bytes.is_empty()) {
        // First update should be <b>for</b> round zero.
        <b>assert</b>!(new_round == 0, <a href="../../dependencies/sui/random.md#sui_random_EInvalidRandomnessUpdate">EInvalidRandomnessUpdate</a>);
    } <b>else</b> {
        // Subsequent updates should either increase epoch or increment randomness_round.
        // Note that epoch may increase by more than 1 <b>if</b> an epoch is completed without
        // randomness ever being generated in that epoch.
        <b>assert</b>!(
            (epoch &gt; inner.epoch && new_round == 0) ||
                    (new_round == inner.randomness_round + 1),
            <a href="../../dependencies/sui/random.md#sui_random_EInvalidRandomnessUpdate">EInvalidRandomnessUpdate</a>,
        );
    };
    inner.epoch = ctx.epoch();
    inner.randomness_round = new_round;
    inner.random_bytes = new_bytes;
}
</code></pre>



</details>

<a name="sui_random_new_generator"></a>

## Function `new_generator`

Create a generator. Can be used to derive up to MAX_U16 * 32 random bytes.

Using randomness can be error-prone if you don't observe the subtleties in its correct use, for example, randomness
dependent code might be exploitable to attacks that carefully set the gas budget
in a way that breaks security. For more information, see:
https://docs.sui.io/guides/developer/advanced/randomness-onchain


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_new_generator">new_generator</a>(r: &<a href="../../dependencies/sui/random.md#sui_random_Random">sui::random::Random</a>, ctx: &<b>mut</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_new_generator">new_generator</a>(r: &<a href="../../dependencies/sui/random.md#sui_random_Random">Random</a>, ctx: &<b>mut</b> TxContext): <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a> {
    <b>let</b> inner = r.<a href="../../dependencies/sui/random.md#sui_random_load_inner">load_inner</a>();
    <b>let</b> seed = hmac_sha3_256(
        &inner.random_bytes,
        &ctx.fresh_object_address().to_bytes(),
    );
    <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a> { seed, counter: 0, buffer: vector[] }
}
</code></pre>



</details>

<a name="sui_random_derive_next_block"></a>

## Function `derive_next_block`

Get the next block of 32 random bytes.


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_derive_next_block">derive_next_block</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_derive_next_block">derive_next_block</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): vector&lt;u8&gt; {
    g.counter = g.counter + 1;
    hmac_sha3_256(&g.seed, &bcs::to_bytes(&g.counter))
}
</code></pre>



</details>

<a name="sui_random_generate_bytes"></a>

## Function `generate_bytes`

Generate n random bytes.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_bytes">generate_bytes</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, num_of_bytes: u16): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_bytes">generate_bytes</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, num_of_bytes: u16): vector&lt;u8&gt; {
    <b>let</b> <b>mut</b> result = vector[];
    // Append <a href="../../dependencies/sui/random.md#sui_random_RAND_OUTPUT_LEN">RAND_OUTPUT_LEN</a> size buffers directly without going through the generator's buffer.
    <b>let</b> num_of_blocks = num_of_bytes / <a href="../../dependencies/sui/random.md#sui_random_RAND_OUTPUT_LEN">RAND_OUTPUT_LEN</a>;
    num_of_blocks.do!(|_| result.append(g.<a href="../../dependencies/sui/random.md#sui_random_derive_next_block">derive_next_block</a>()));
    // Fill the generator's buffer <b>if</b> needed.
    <b>let</b> num_of_bytes = num_of_bytes <b>as</b> u64;
    <b>let</b> remaining = num_of_bytes - result.length();
    <b>if</b> (g.buffer.length() &lt; remaining) {
        <b>let</b> next_block = g.<a href="../../dependencies/sui/random.md#sui_random_derive_next_block">derive_next_block</a>();
        g.buffer.append(next_block);
    };
    // Take remaining bytes from the generator's buffer.
    remaining.do!(|_| result.push_back(g.buffer.pop_back()));
    result
}
</code></pre>



</details>

<a name="sui_random_uint_from_bytes"></a>

## Macro function `uint_from_bytes`



<pre><code><b>macro</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>&lt;$T: drop&gt;($g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, $num_of_bytes: u8): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>&lt;$T: drop&gt;($g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, $num_of_bytes: u8): $T {
    <b>let</b> g = $g;
    <b>let</b> num_of_bytes = $num_of_bytes;
    <b>if</b> (g.buffer.length() &lt; num_of_bytes <b>as</b> u64) {
        <b>let</b> next_block = g.<a href="../../dependencies/sui/random.md#sui_random_derive_next_block">derive_next_block</a>();
        g.buffer.append(next_block);
    };
    // TODO: why regression test fails <b>if</b> we <b>use</b> $T instead of u256
    <b>let</b> <b>mut</b> result: u256 = 0;
    num_of_bytes.do!(|_| {
        <b>let</b> byte = g.buffer.pop_back() <b>as</b> u256;
        result = (result &lt;&lt; 8) + byte;
    });
    result <b>as</b> $T
}
</code></pre>



</details>

<a name="sui_random_generate_u256"></a>

## Function `generate_u256`

Generate a u256.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u256">generate_u256</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u256">generate_u256</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u256 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 32)
}
</code></pre>



</details>

<a name="sui_random_generate_u128"></a>

## Function `generate_u128`

Generate a u128.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u128">generate_u128</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u128">generate_u128</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u128 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 16)
}
</code></pre>



</details>

<a name="sui_random_generate_u64"></a>

## Function `generate_u64`

Generate a u64.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u64">generate_u64</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u64">generate_u64</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u64 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 8)
}
</code></pre>



</details>

<a name="sui_random_generate_u32"></a>

## Function `generate_u32`

Generate a u32.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u32">generate_u32</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u32
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u32">generate_u32</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u32 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 4)
}
</code></pre>



</details>

<a name="sui_random_generate_u16"></a>

## Function `generate_u16`

Generate a u16.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u16">generate_u16</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u16">generate_u16</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u16 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 2)
}
</code></pre>



</details>

<a name="sui_random_generate_u8"></a>

## Function `generate_u8`

Generate a u8.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u8">generate_u8</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u8">generate_u8</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): u8 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 1)
}
</code></pre>



</details>

<a name="sui_random_generate_bool"></a>

## Function `generate_bool`

Generate a boolean.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_bool">generate_bool</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_bool">generate_bool</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>): bool {
    (<a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!(g, 1) & 1) == 1
}
</code></pre>



</details>

<a name="sui_random_uint_in_range"></a>

## Macro function `uint_in_range`

Helper macro to generate a random uint in [min, max] using a random number with num_of_bytes bytes.
Assumes that the caller verified the inputs, and uses num_of_bytes to control the bias (e.g., 8 bytes larger
than the actual type used by the caller function to limit the bias by 2^{-64}).


<pre><code><b>macro</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>&lt;$T: drop&gt;($g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, $min: $T, $max: $T, $num_of_bytes: u8): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>&lt;$T: drop&gt;(
    $g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>,
    $min: $T,
    $max: $T,
    $num_of_bytes: u8,
): $T {
    <b>let</b> min = $min;
    <b>let</b> max = $max;
    <b>assert</b>!(min &lt;= max, <a href="../../dependencies/sui/random.md#sui_random_EInvalidRange">EInvalidRange</a>);
    <b>if</b> (min == max) <b>return</b> min;
    // Pick a random number in [0, max - min] by generating a random number that is larger than max-min, and taking
    // the modulo of the random number by the range size. Then add the min to the result to get a number in
    // [min, max].
    <b>let</b> range_size = (max - min) <b>as</b> u256 + 1;
    <b>let</b> rand = <a href="../../dependencies/sui/random.md#sui_random_uint_from_bytes">uint_from_bytes</a>!($g, $num_of_bytes);
    min + (rand % range_size <b>as</b> $T)
}
</code></pre>



</details>

<a name="sui_random_generate_u128_in_range"></a>

## Function `generate_u128_in_range`

Generate a random u128 in [min, max] (with a bias of 2^{-64}).


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u128_in_range">generate_u128_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, min: u128, max: u128): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u128_in_range">generate_u128_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, min: u128, max: u128): u128 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>!(g, min, max, 24)
}
</code></pre>



</details>

<a name="sui_random_generate_u64_in_range"></a>

## Function `generate_u64_in_range`



<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u64_in_range">generate_u64_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, min: u64, max: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u64_in_range">generate_u64_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, min: u64, max: u64): u64 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>!(g, min, max, 16)
}
</code></pre>



</details>

<a name="sui_random_generate_u32_in_range"></a>

## Function `generate_u32_in_range`

Generate a random u32 in [min, max] (with a bias of 2^{-64}).


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u32_in_range">generate_u32_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, min: u32, max: u32): u32
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u32_in_range">generate_u32_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, min: u32, max: u32): u32 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>!(g, min, max, 12)
}
</code></pre>



</details>

<a name="sui_random_generate_u16_in_range"></a>

## Function `generate_u16_in_range`

Generate a random u16 in [min, max] (with a bias of 2^{-64}).


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u16_in_range">generate_u16_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, min: u16, max: u16): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u16_in_range">generate_u16_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, min: u16, max: u16): u16 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>!(g, min, max, 10)
}
</code></pre>



</details>

<a name="sui_random_generate_u8_in_range"></a>

## Function `generate_u8_in_range`

Generate a random u8 in [min, max] (with a bias of 2^{-64}).


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u8_in_range">generate_u8_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, min: u8, max: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_generate_u8_in_range">generate_u8_in_range</a>(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, min: u8, max: u8): u8 {
    <a href="../../dependencies/sui/random.md#sui_random_uint_in_range">uint_in_range</a>!(g, min, max, 9)
}
</code></pre>



</details>

<a name="sui_random_shuffle"></a>

## Function `shuffle`

Shuffle a vector using the random generator (Fisher–Yates/Knuth shuffle).


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_shuffle">shuffle</a>&lt;T&gt;(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, v: &<b>mut</b> vector&lt;T&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/random.md#sui_random_shuffle">shuffle</a>&lt;T&gt;(g: &<b>mut</b> <a href="../../dependencies/sui/random.md#sui_random_RandomGenerator">RandomGenerator</a>, v: &<b>mut</b> vector&lt;T&gt;) {
    <b>let</b> n = v.length();
    <b>if</b> (n == 0) <b>return</b>;
    <b>assert</b>!(n &lt;= <a href="../../dependencies/sui/random.md#sui_random_U16_MAX">U16_MAX</a>, <a href="../../dependencies/sui/random.md#sui_random_EInvalidLength">EInvalidLength</a>);
    <b>let</b> n = n <b>as</b> u16;
    <b>let</b> end = n - 1;
    end.do!(|i| {
        <b>let</b> j = g.<a href="../../dependencies/sui/random.md#sui_random_generate_u16_in_range">generate_u16_in_range</a>(i, end);
        v.swap(i <b>as</b> u64, j <b>as</b> u64);
    });
}
</code></pre>



</details>
