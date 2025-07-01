
<a name="name_gen_name_gen"></a>

# Module `name_gen::name_gen`

Cyberpunk Name Generator - a "stateless" solution for generating names,
based on the <code>random</code> module.


<a name="@Usage_0"></a>

### Usage

This package provides utility functions which must be integrated directly
into an application's Move codebase, due to the use of <code>RandomGenerator</code>.


<a name="@Example_1"></a>

### Example

```
module my_package::hero;

use std::string::String;
use sui::random::Random;
use name_gen::name_gen;

/// Some object to hold the name.
public struct Hero has key, store { id: UID, name: String }

/// The function MUST be an <code><b>entry</b></code> function for <code>Random</code> to work.
/// See https://docs.sui.io/guides/developer/advanced/randomness-onchain
entry fun new_hero(rng: &Random, ctx: &mut TxContext) {
let mut gen = rng.new_generator(ctx); // acquire generator instance
let name = name_gen::new_male_name(&mut gen); // also <code><a href="./name_gen.md#name_gen_name_gen_new_female_name">new_female_name</a></code>
transfer::transfer(Hero {
id: object::new(ctx),
name
}, ctx.sender());
}
```


-  [Usage](#@Usage_0)
-  [Example](#@Example_1)
-  [Constants](#@Constants_2)
-  [Function `new_male_name`](#name_gen_name_gen_new_male_name)
-  [Function `new_female_name`](#name_gen_name_gen_new_female_name)


<pre><code><b>use</b> <a href="./consonant.md#name_gen_consonant">name_gen::consonant</a>;
<b>use</b> <a href="./female.md#name_gen_female">name_gen::female</a>;
<b>use</b> <a href="./last_name.md#name_gen_last_name">name_gen::last_name</a>;
<b>use</b> <a href="./male.md#name_gen_male">name_gen::male</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
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



<a name="@Constants_2"></a>

## Constants


<a name="name_gen_name_gen_MALE_LIMIT"></a>



<pre><code><b>const</b> <a href="./name_gen.md#name_gen_name_gen_MALE_LIMIT">MALE_LIMIT</a>: u16 = 343;
</code></pre>



<a name="name_gen_name_gen_FEMALE_LIMIT"></a>



<pre><code><b>const</b> <a href="./name_gen.md#name_gen_name_gen_FEMALE_LIMIT">FEMALE_LIMIT</a>: u16 = 341;
</code></pre>



<a name="name_gen_name_gen_LAST_NAME_LIMIT"></a>



<pre><code><b>const</b> <a href="./name_gen.md#name_gen_name_gen_LAST_NAME_LIMIT">LAST_NAME_LIMIT</a>: u16 = 1481;
</code></pre>



<a name="name_gen_name_gen_CONSONANT"></a>



<pre><code><b>const</b> <a href="./name_gen.md#name_gen_name_gen_CONSONANT">CONSONANT</a>: u8 = 30;
</code></pre>



<a name="name_gen_name_gen_POST_CONSONANT"></a>



<pre><code><b>const</b> <a href="./name_gen.md#name_gen_name_gen_POST_CONSONANT">POST_CONSONANT</a>: u8 = 30;
</code></pre>



<a name="name_gen_name_gen_new_male_name"></a>

## Function `new_male_name`

This function must be used as a part of a <code>Random</code> entry function call.


<pre><code><b>public</b> <b>fun</b> <a href="./name_gen.md#name_gen_name_gen_new_male_name">new_male_name</a>(g: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./name_gen.md#name_gen_name_gen_new_male_name">new_male_name</a>(g: &<b>mut</b> RandomGenerator): String {
    <b>let</b> <b>mut</b> res = b"".to_string();
    <b>let</b> name = <a href="./male.md#name_gen_male_select">name_gen::male::select</a>(g.generate_u16_in_range(0, <a href="./name_gen.md#name_gen_name_gen_MALE_LIMIT">MALE_LIMIT</a>));
    // whether to <b>use</b> <a href="./consonant.md#name_gen_consonant">consonant</a>
    <b>let</b> <a href="./last_name.md#name_gen_last_name">last_name</a> = <b>if</b> (g.generate_bool()) {
        <a href="./consonant.md#name_gen_consonant_select">name_gen::consonant::select</a>(
            g.generate_u8_in_range(0, <a href="./name_gen.md#name_gen_name_gen_CONSONANT">CONSONANT</a>),
            g.generate_u8_in_range(0, <a href="./name_gen.md#name_gen_name_gen_POST_CONSONANT">POST_CONSONANT</a>),
        )
    } <b>else</b> {
        <a href="./last_name.md#name_gen_last_name_select">name_gen::last_name::select</a>(g.generate_u16_in_range(0, <a href="./name_gen.md#name_gen_name_gen_LAST_NAME_LIMIT">LAST_NAME_LIMIT</a>))
    };
    res.append(name);
    res.append_utf8(b" ");
    res.append(<a href="./last_name.md#name_gen_last_name">last_name</a>);
    res
}
</code></pre>



</details>

<a name="name_gen_name_gen_new_female_name"></a>

## Function `new_female_name`

This function must be used as a part of a <code>Random</code> entry function call.


<pre><code><b>public</b> <b>fun</b> <a href="./name_gen.md#name_gen_name_gen_new_female_name">new_female_name</a>(g: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./name_gen.md#name_gen_name_gen_new_female_name">new_female_name</a>(g: &<b>mut</b> RandomGenerator): String {
    <b>let</b> <b>mut</b> res = b"".to_string();
    <b>let</b> name = <a href="./female.md#name_gen_female_select">name_gen::female::select</a>(g.generate_u16_in_range(0, <a href="./name_gen.md#name_gen_name_gen_FEMALE_LIMIT">FEMALE_LIMIT</a>));
    // whether to <b>use</b> <a href="./consonant.md#name_gen_consonant">consonant</a>
    <b>let</b> <a href="./last_name.md#name_gen_last_name">last_name</a> = <b>if</b> (g.generate_bool()) {
        <a href="./consonant.md#name_gen_consonant_select">name_gen::consonant::select</a>(
            g.generate_u8_in_range(0, <a href="./name_gen.md#name_gen_name_gen_CONSONANT">CONSONANT</a>),
            g.generate_u8_in_range(0, <a href="./name_gen.md#name_gen_name_gen_POST_CONSONANT">POST_CONSONANT</a>),
        )
    } <b>else</b> {
        <a href="./last_name.md#name_gen_last_name_select">name_gen::last_name::select</a>(g.generate_u16_in_range(0, <a href="./name_gen.md#name_gen_name_gen_LAST_NAME_LIMIT">LAST_NAME_LIMIT</a>))
    };
    res.append(name);
    res.append_utf8(b" ");
    res.append(<a href="./last_name.md#name_gen_last_name">last_name</a>);
    res
}
</code></pre>



</details>
