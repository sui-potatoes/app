
<a name="character_character"></a>

# Module `character::character`

Module: character

Character is a fully on-chain inscribed piece of pixel art. While the main
application of the module is to serve and manage the character art and minting
process (unrestricted right now), it is also implemented in a <code>Bag</code>-like manner
to allow other applications be built on top of it.

The API of <code><a href="./character.md#character_character_add">add</a></code>, <code>get</code>, <code>get_mut</code>, and <code><a href="./character.md#character_character_remove">remove</a></code> functions is provided to
store and retrieve application data in the <code><a href="./character.md#character_character_Character">Character</a></code> object. The data is
attached as a dynamic field.

Read more about it in the Move Book:
https://move-book.com/programmability/dynamic-fields.html

As a cherry on top <code><a href="./character.md#character_character_Character">Character</a></code> also supports index syntax for its dynamic
fields. So you can use it like this:
```move
let field: AppData = &character[ApplicationKey {}];
```


-  [Struct `Builder`](#character_character_Builder)
-  [Struct `CHARACTER`](#character_character_CHARACTER)
-  [Struct `Props`](#character_character_Props)
-  [Struct `Character`](#character_character_Character)
-  [Constants](#@Constants_0)
-  [Function `new`](#character_character_new)
-  [Function `update_image`](#character_character_update_image)
-  [Function `add`](#character_character_add)
-  [Function `borrow`](#character_character_borrow)
-  [Function `borrow_mut`](#character_character_borrow_mut)
-  [Function `remove`](#character_character_remove)
-  [Function `body_type`](#character_character_body_type)
-  [Function `hair_type`](#character_character_hair_type)
-  [Function `eyes_color`](#character_character_eyes_color)
-  [Function `hair_color`](#character_character_hair_color)
-  [Function `trousers_color`](#character_character_trousers_color)
-  [Function `skin_color`](#character_character_skin_color)
-  [Function `base_color`](#character_character_base_color)
-  [Function `accent_color`](#character_character_accent_color)
-  [Function `palette`](#character_character_palette)
-  [Function `init`](#character_character_init)
-  [Function `set_initial_assets`](#character_character_set_initial_assets)
-  [Function `set_display`](#character_character_set_display)
-  [Function `build_pure_svg`](#character_character_build_pure_svg)
-  [Function `build_character_base`](#character_character_build_character_base)
-  [Function `replace`](#character_character_replace)


<pre><code><b>use</b> <a href="../../.doc-deps/codec/base64.md#codec_base64">codec::base64</a>;
<b>use</b> <a href="../../.doc-deps/codec/urlencode.md#codec_urlencode">codec::urlencode</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/display.md#sui_display">sui::display</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/package.md#sui_package">sui::package</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/types.md#sui_types">sui::types</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/svg/animation.md#svg_animation">svg::animation</a>;
<b>use</b> <a href="../../.doc-deps/svg/container.md#svg_container">svg::container</a>;
<b>use</b> <a href="../../.doc-deps/svg/coordinate.md#svg_coordinate">svg::coordinate</a>;
<b>use</b> <a href="../../.doc-deps/svg/desc.md#svg_desc">svg::desc</a>;
<b>use</b> <a href="../../.doc-deps/svg/filter.md#svg_filter">svg::filter</a>;
<b>use</b> <a href="../../.doc-deps/svg/print.md#svg_print">svg::print</a>;
<b>use</b> <a href="../../.doc-deps/svg/shape.md#svg_shape">svg::shape</a>;
<b>use</b> <a href="../../.doc-deps/svg/svg.md#svg_svg">svg::svg</a>;
</code></pre>



<a name="character_character_Builder"></a>

## Struct `Builder`

The Builder object which stores configurations under names.
Intentionally avoids using dynamic fields to keep the implementation
minimal.

Please, note that by using static fields of the struct, the implementation
is limited to the max object size (256KB). If you need to store more data,
you should reimplement it to use a <code>Bag</code> and store body parts as dynamic
fields.


<pre><code><b>public</b> <b>struct</b> <a href="./character.md#character_character_Builder">Builder</a> <b>has</b> key
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
<code>body: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/svg/container.md#svg_container_Container">svg::container::Container</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>hair: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/svg/container.md#svg_container_Container">svg::container::Container</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>colors: vector&lt;vector&lt;u8&gt;&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="character_character_CHARACTER"></a>

## Struct `CHARACTER`

The OTW for the application.


<pre><code><b>public</b> <b>struct</b> <a href="./character.md#character_character_CHARACTER">CHARACTER</a> <b>has</b> drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
</dl>


</details>

<a name="character_character_Props"></a>

## Struct `Props`

The builder for the image of a Character, can use available shapes and
colors from the game object.


<pre><code><b>public</b> <b>struct</b> <a href="./character.md#character_character_Props">Props</a> <b>has</b> drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./character.md#character_character_body_type">body_type</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Body type.
</dd>
<dt>
<code><a href="./character.md#character_character_hair_type">hair_type</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Hair type.
</dd>
<dt>
<code>body: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Urlencoded Body parts.
</dd>
<dt>
<code>hair: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Urlencoded Hair parts.
</dd>
<dt>
<code><a href="./character.md#character_character_hair_color">hair_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Hair color, a HEX string.
</dd>
<dt>
<code><a href="./character.md#character_character_eyes_color">eyes_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Eyes color, a HEX string.
</dd>
<dt>
<code><a href="./character.md#character_character_trousers_color">trousers_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Trousers color, a HEX string.
</dd>
<dt>
<code><a href="./character.md#character_character_skin_color">skin_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Skin color, a HEX string.
</dd>
<dt>
<code><a href="./character.md#character_character_base_color">base_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Base color, a HEX string.
</dd>
<dt>
<code><a href="./character.md#character_character_accent_color">accent_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
 Accent color, a HEX string.
</dd>
</dl>


</details>

<a name="character_character_Character"></a>

## Struct `Character`

A character in the game.


<pre><code><b>public</b> <b>struct</b> <a href="./character.md#character_character_Character">Character</a> <b>has</b> key, store
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
<code>image: <a href="./character.md#character_character_Props">character::character::Props</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="character_character_EWrongBody"></a>

The body type is not found in the <code><a href="./character.md#character_character_Builder">Builder</a></code>.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongBody">EWrongBody</a>: u64 = 1;
</code></pre>



<a name="character_character_EWrongHair"></a>

The hair type is not found in the <code><a href="./character.md#character_character_Builder">Builder</a></code>.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongHair">EWrongHair</a>: u64 = 2;
</code></pre>



<a name="character_character_EWrongEyesColor"></a>

Eyes color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongEyesColor">EWrongEyesColor</a>: u64 = 3;
</code></pre>



<a name="character_character_EWrongTrousersColor"></a>

Trousers color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongTrousersColor">EWrongTrousersColor</a>: u64 = 4;
</code></pre>



<a name="character_character_EWrongSkinColor"></a>

Skin color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongSkinColor">EWrongSkinColor</a>: u64 = 5;
</code></pre>



<a name="character_character_EWrongBaseColor"></a>

Base color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongBaseColor">EWrongBaseColor</a>: u64 = 6;
</code></pre>



<a name="character_character_EWrongAccentColor"></a>

Accent color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongAccentColor">EWrongAccentColor</a>: u64 = 7;
</code></pre>



<a name="character_character_EWrongHairColor"></a>

Hair color must be in the allowed palette.


<pre><code><b>const</b> <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>: u64 = 8;
</code></pre>



<a name="character_character_EIncorrectDynamicField"></a>

Application key cannot be a primitive type.


<pre><code><b>const</b> <a href="./character.md#character_character_EIncorrectDynamicField">EIncorrectDynamicField</a>: u64 = 9;
</code></pre>



<a name="character_character_HAIR"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_HAIR">HAIR</a>: vector&lt;u8&gt; = vector[104];
</code></pre>



<a name="character_character_BODY"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_BODY">BODY</a>: vector&lt;u8&gt; = vector[98];
</code></pre>



<a name="character_character_EYES"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_EYES">EYES</a>: vector&lt;u8&gt; = vector[101];
</code></pre>



<a name="character_character_LEGS"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_LEGS">LEGS</a>: vector&lt;u8&gt; = vector[108];
</code></pre>



<a name="character_character_SKIN"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_SKIN">SKIN</a>: vector&lt;u8&gt; = vector[115];
</code></pre>



<a name="character_character_ACCENT"></a>



<pre><code><b>const</b> <a href="./character.md#character_character_ACCENT">ACCENT</a>: vector&lt;u8&gt; = vector[97];
</code></pre>



<a name="character_character_PALETTE"></a>

EDG 32 palette. Classic 32 color palette.


<pre><code><b>const</b> <a href="./character.md#character_character_PALETTE">PALETTE</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[98, 101, 52, 97, 50, 102], vector[100, 55, 55, 54, 52, 51], vector[101, 97, 100, 52, 97, 97], vector[101, 52, 97, 54, 55, 50], vector[98, 56, 54, 102, 53, 48], vector[55, 51, 51, 101, 51, 57], vector[51, 101, 50, 55, 51, 49], vector[97, 50, 50, 54, 51, 51], vector[101, 52, 51, 98, 52, 52], vector[102, 55, 55, 54, 50, 50], vector[102, 101, 97, 101, 51, 52], vector[102, 101, 101, 55, 54, 49], vector[54, 51, 99, 55, 52, 100], vector[51, 101, 56, 57, 52, 56], vector[50, 54, 53, 99, 52, 50], vector[49, 57, 51, 99, 51, 101], vector[49, 50, 52, 101, 56, 57], vector[48, 48, 57, 57, 100, 98], vector[50, 99, 101, 56, 102, 53], vector[102, 102, 102, 102, 102, 102], vector[99, 48, 99, 98, 100, 99], vector[56, 98, 57, 98, 98, 52], vector[53, 97, 54, 57, 56, 56], vector[51, 97, 52, 52, 54, 54], vector[50, 54, 50, 98, 52, 52], vector[49, 56, 49, 52, 50, 53], vector[102, 102, 48, 48, 52, 52], vector[54, 56, 51, 56, 54, 99], vector[98, 53, 53, 48, 56, 56], vector[102, 54, 55, 53, 55, 97], vector[101, 56, 98, 55, 57, 54], vector[99, 50, 56, 53, 54, 57]];
</code></pre>



<a name="character_character_PX"></a>

Size of a single pixel in the Character


<pre><code><b>const</b> <a href="./character.md#character_character_PX">PX</a>: u16 = 20;
</code></pre>



<a name="character_character_new"></a>

## Function `new`

Create a new character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_new">new</a>(b: &<b>mut</b> <a href="./character.md#character_character_Builder">character::character::Builder</a>, <a href="./character.md#character_character_body_type">body_type</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_hair_type">hair_type</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_eyes_color">eyes_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_hair_color">hair_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_trousers_color">trousers_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_skin_color">skin_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_base_color">base_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./character.md#character_character_accent_color">accent_color</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./character.md#character_character_Character">character::character::Character</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_new">new</a>(
    b: &<b>mut</b> <a href="./character.md#character_character_Builder">Builder</a>,
    <a href="./character.md#character_character_body_type">body_type</a>: String,
    <a href="./character.md#character_character_hair_type">hair_type</a>: String,
    <a href="./character.md#character_character_eyes_color">eyes_color</a>: String,
    <a href="./character.md#character_character_hair_color">hair_color</a>: String,
    <a href="./character.md#character_character_trousers_color">trousers_color</a>: String,
    <a href="./character.md#character_character_skin_color">skin_color</a>: String,
    <a href="./character.md#character_character_base_color">base_color</a>: String,
    <a href="./character.md#character_character_accent_color">accent_color</a>: String,
    ctx: &<b>mut</b> TxContext,
): <a href="./character.md#character_character_Character">Character</a> {
    <b>assert</b>!(b.body.contains(&<a href="./character.md#character_character_body_type">body_type</a>), <a href="./character.md#character_character_EWrongBody">EWrongBody</a>);
    <b>assert</b>!(b.hair.contains(&<a href="./character.md#character_character_hair_type">hair_type</a>), <a href="./character.md#character_character_EWrongHair">EWrongHair</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_hair_color">hair_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_eyes_color">eyes_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongEyesColor">EWrongEyesColor</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_trousers_color">trousers_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongTrousersColor">EWrongTrousersColor</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_skin_color">skin_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongSkinColor">EWrongSkinColor</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_base_color">base_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongBaseColor">EWrongBaseColor</a>);
    <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_accent_color">accent_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongAccentColor">EWrongAccentColor</a>);
    <b>let</b> image = <a href="./character.md#character_character_Props">Props</a> {
        body: urlencode::encode(b.body[&<a href="./character.md#character_character_body_type">body_type</a>].to_string().into_bytes()),
        hair: urlencode::encode(b.hair[&<a href="./character.md#character_character_hair_type">hair_type</a>].to_string().into_bytes()),
        <a href="./character.md#character_character_body_type">body_type</a>,
        <a href="./character.md#character_character_hair_type">hair_type</a>,
        <a href="./character.md#character_character_eyes_color">eyes_color</a>,
        <a href="./character.md#character_character_hair_color">hair_color</a>,
        <a href="./character.md#character_character_trousers_color">trousers_color</a>,
        <a href="./character.md#character_character_skin_color">skin_color</a>,
        <a href="./character.md#character_character_base_color">base_color</a>,
        <a href="./character.md#character_character_accent_color">accent_color</a>,
    };
    <a href="./character.md#character_character_Character">Character</a> { id: object::new(ctx), image }
}
</code></pre>



</details>

<a name="character_character_update_image"></a>

## Function `update_image`

Edit the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_update_image">update_image</a>(b: &<b>mut</b> <a href="./character.md#character_character_Builder">character::character::Builder</a>, c: &<b>mut</b> <a href="./character.md#character_character_Character">character::character::Character</a>, <a href="./character.md#character_character_body_type">body_type</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_hair_type">hair_type</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_eyes_color">eyes_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_hair_color">hair_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_trousers_color">trousers_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_skin_color">skin_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_base_color">base_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, <a href="./character.md#character_character_accent_color">accent_color</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, _ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_update_image">update_image</a>(
    b: &<b>mut</b> <a href="./character.md#character_character_Builder">Builder</a>,
    c: &<b>mut</b> <a href="./character.md#character_character_Character">Character</a>,
    <a href="./character.md#character_character_body_type">body_type</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_hair_type">hair_type</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_eyes_color">eyes_color</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_hair_color">hair_color</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_trousers_color">trousers_color</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_skin_color">skin_color</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_base_color">base_color</a>: Option&lt;String&gt;,
    <a href="./character.md#character_character_accent_color">accent_color</a>: Option&lt;String&gt;,
    _ctx: &<b>mut</b> TxContext,
) {
    <a href="./character.md#character_character_body_type">body_type</a>.do!(|<a href="./character.md#character_character_body_type">body_type</a>| {
        <b>assert</b>!(b.body.contains(&<a href="./character.md#character_character_body_type">body_type</a>), <a href="./character.md#character_character_EWrongBody">EWrongBody</a>);
        c.image.body = urlencode::encode(b.body[&<a href="./character.md#character_character_body_type">body_type</a>].to_string().into_bytes());
        c.image.<a href="./character.md#character_character_body_type">body_type</a> = <a href="./character.md#character_character_body_type">body_type</a>;
    });
    <a href="./character.md#character_character_hair_type">hair_type</a>.do!(|<a href="./character.md#character_character_hair_type">hair_type</a>| {
        <b>assert</b>!(b.hair.contains(&<a href="./character.md#character_character_hair_type">hair_type</a>), <a href="./character.md#character_character_EWrongHair">EWrongHair</a>);
        c.image.hair = urlencode::encode(b.hair[&<a href="./character.md#character_character_hair_type">hair_type</a>].to_string().into_bytes());
        c.image.<a href="./character.md#character_character_hair_type">hair_type</a> = <a href="./character.md#character_character_hair_type">hair_type</a>;
    });
    <a href="./character.md#character_character_hair_color">hair_color</a>.do!(|<a href="./character.md#character_character_hair_color">hair_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_hair_color">hair_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_hair_color">hair_color</a> = <a href="./character.md#character_character_hair_color">hair_color</a>;
    });
    <a href="./character.md#character_character_eyes_color">eyes_color</a>.do!(|<a href="./character.md#character_character_eyes_color">eyes_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_eyes_color">eyes_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_eyes_color">eyes_color</a> = <a href="./character.md#character_character_eyes_color">eyes_color</a>;
    });
    <a href="./character.md#character_character_trousers_color">trousers_color</a>.do!(|<a href="./character.md#character_character_trousers_color">trousers_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_trousers_color">trousers_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_trousers_color">trousers_color</a> = <a href="./character.md#character_character_trousers_color">trousers_color</a>;
    });
    <a href="./character.md#character_character_skin_color">skin_color</a>.do!(|<a href="./character.md#character_character_skin_color">skin_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_skin_color">skin_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_skin_color">skin_color</a> = <a href="./character.md#character_character_skin_color">skin_color</a>;
    });
    <a href="./character.md#character_character_base_color">base_color</a>.do!(|<a href="./character.md#character_character_base_color">base_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_base_color">base_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_base_color">base_color</a> = <a href="./character.md#character_character_base_color">base_color</a>;
    });
    <a href="./character.md#character_character_accent_color">accent_color</a>.do!(|<a href="./character.md#character_character_accent_color">accent_color</a>| {
        <b>assert</b>!(b.colors.contains(<a href="./character.md#character_character_accent_color">accent_color</a>.as_bytes()), <a href="./character.md#character_character_EWrongHairColor">EWrongHairColor</a>);
        c.image.<a href="./character.md#character_character_accent_color">accent_color</a> = <a href="./character.md#character_character_accent_color">accent_color</a>;
    });
}
</code></pre>



</details>

<a name="character_character_add"></a>

## Function `add`

Add a dynamic field to the character.

We make sure that the Key is not a primitive type to enforce the usage of custom
types for dynamic fields. This is a necessary step in preventing incorrect
implementation of the dynamic fields in this setting.

TODO: a stricter check would be to check against the <code>0x1</code> and <code>0x2</code> origin
of the type, but we can leave it for now.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_add">add</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">character::character::Character</a>, key: K, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_add">add</a>&lt;K: store + <b>copy</b> + drop, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">Character</a>, key: K, value: V) {
    <b>assert</b>!(!type_name::with_defining_ids&lt;K&gt;().is_primitive(), <a href="./character.md#character_character_EIncorrectDynamicField">EIncorrectDynamicField</a>);
    df::add(&<b>mut</b> c.id, key, value)
}
</code></pre>



</details>

<a name="character_character_borrow"></a>

## Function `borrow`

Borrow a dynamic field of the <code><a href="./character.md#character_character_Character">Character</a></code>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_borrow">borrow</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(c: &<a href="./character.md#character_character_Character">character::character::Character</a>, key: K): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_borrow">borrow</a>&lt;K: store + <b>copy</b> + drop, V: store&gt;(c: &<a href="./character.md#character_character_Character">Character</a>, key: K): &V {
    df::borrow(&c.id, key)
}
</code></pre>



</details>

<a name="character_character_borrow_mut"></a>

## Function `borrow_mut`

Borrow a dynamic field of the <code><a href="./character.md#character_character_Character">Character</a></code> mutably


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_borrow_mut">borrow_mut</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">character::character::Character</a>, key: K): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_borrow_mut">borrow_mut</a>&lt;K: store + <b>copy</b> + drop, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">Character</a>, key: K): &<b>mut</b> V {
    df::borrow_mut(&<b>mut</b> c.id, key)
}
</code></pre>



</details>

<a name="character_character_remove"></a>

## Function `remove`

Remove a dynamic field from the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_remove">remove</a>&lt;K: <b>copy</b>, drop, store, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">character::character::Character</a>, key: K): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_remove">remove</a>&lt;K: store + <b>copy</b> + drop, V: store&gt;(c: &<b>mut</b> <a href="./character.md#character_character_Character">Character</a>, key: K): V {
    df::remove(&<b>mut</b> c.id, key)
}
</code></pre>



</details>

<a name="character_character_body_type"></a>

## Function `body_type`

Get the body type of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_body_type">body_type</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_body_type">body_type</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_body_type">body_type</a> }
</code></pre>



</details>

<a name="character_character_hair_type"></a>

## Function `hair_type`

Get the hair type of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_hair_type">hair_type</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_hair_type">hair_type</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_hair_type">hair_type</a> }
</code></pre>



</details>

<a name="character_character_eyes_color"></a>

## Function `eyes_color`

Get the eyes color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_eyes_color">eyes_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_eyes_color">eyes_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_eyes_color">eyes_color</a> }
</code></pre>



</details>

<a name="character_character_hair_color"></a>

## Function `hair_color`

Get the hair color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_hair_color">hair_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_hair_color">hair_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_hair_color">hair_color</a> }
</code></pre>



</details>

<a name="character_character_trousers_color"></a>

## Function `trousers_color`

Get the pants color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_trousers_color">trousers_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_trousers_color">trousers_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_trousers_color">trousers_color</a> }
</code></pre>



</details>

<a name="character_character_skin_color"></a>

## Function `skin_color`

Get the skin color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_skin_color">skin_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_skin_color">skin_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_skin_color">skin_color</a> }
</code></pre>



</details>

<a name="character_character_base_color"></a>

## Function `base_color`

Get the base color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_base_color">base_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_base_color">base_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_base_color">base_color</a> }
</code></pre>



</details>

<a name="character_character_accent_color"></a>

## Function `accent_color`

Get the accent color of the character.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_accent_color">accent_color</a>(c: &<a href="./character.md#character_character_Character">character::character::Character</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_accent_color">accent_color</a>(c: &<a href="./character.md#character_character_Character">Character</a>): String { c.image.<a href="./character.md#character_character_accent_color">accent_color</a> }
</code></pre>



</details>

<a name="character_character_palette"></a>

## Function `palette`

Returns vector of available colors for the application.


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_palette">palette</a>(): vector&lt;vector&lt;u8&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./character.md#character_character_palette">palette</a>(): vector&lt;vector&lt;u8&gt;&gt; { <a href="./character.md#character_character_PALETTE">PALETTE</a> }
</code></pre>



</details>

<a name="character_character_init"></a>

## Function `init`

Create Display for the Character type.


<pre><code><b>fun</b> <a href="./character.md#character_character_init">init</a>(otw: <a href="./character.md#character_character_CHARACTER">character::character::CHARACTER</a>, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_init">init</a>(otw: <a href="./character.md#character_character_CHARACTER">CHARACTER</a>, ctx: &<b>mut</b> TxContext) {
    <b>let</b> publisher = package::claim(otw, ctx);
    <b>let</b> <b>mut</b> display = display::new&lt;<a href="./character.md#character_character_Character">Character</a>&gt;(&publisher, ctx);
    <b>let</b> <b>mut</b> builder = <a href="./character.md#character_character_Builder">Builder</a> {
        id: object::new(ctx),
        body: vec_map::empty(),
        hair: vec_map::empty(),
        colors: <a href="./character.md#character_character_PALETTE">PALETTE</a>,
    };
    builder.<a href="./character.md#character_character_set_initial_assets">set_initial_assets</a>();
    <a href="./character.md#character_character_set_display">set_display</a>(&<b>mut</b> display);
    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
    transfer::share_object(builder);
}
</code></pre>



</details>

<a name="character_character_set_initial_assets"></a>

## Function `set_initial_assets`

Set the initial assets for the character.


<pre><code><b>fun</b> <a href="./character.md#character_character_set_initial_assets">set_initial_assets</a>(builder: &<b>mut</b> <a href="./character.md#character_character_Builder">character::character::Builder</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_set_initial_assets">set_initial_assets</a>(builder: &<b>mut</b> <a href="./character.md#character_character_Builder">Builder</a>) {
    // hair: punk
    // <b>let</b> px = 20;
    <b>let</b> <b>mut</b> punk = container::g(vector[
        shape::rect(3 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(2 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 0),
    ]);
    add_class!(&<b>mut</b> punk, <a href="./character.md#character_character_HAIR">HAIR</a>);
    builder.hair.insert(b"punk".to_string(), punk);
    // hair: flat
    <b>let</b> <b>mut</b> flat = shape::rect(3 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>);
    add_class!(&<b>mut</b> flat, <a href="./character.md#character_character_HAIR">HAIR</a>);
    builder.hair.insert(b"flat".to_string(), container::root(vector[flat]));
    // hair: bang
    <b>let</b> <b>mut</b> bang = container::g(vector[
        shape::rect(3 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(80, <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(6 * <a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> bang, <a href="./character.md#character_character_HAIR">HAIR</a>);
    builder.hair.insert(b"bang".to_string(), bang);
    // hair: wind
    <b>let</b> <b>mut</b> wind = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(3 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(4 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(2 * <a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>).move_to(7 * <a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(9 * <a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> wind, <a href="./character.md#character_character_HAIR">HAIR</a>);
    builder.hair.insert(b"wind".to_string(), wind);
    // body: blazer
    <b>let</b> <b>mut</b> blazer = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(6 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(5 * <a href="./character.md#character_character_PX">PX</a>, 6 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(3 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(7 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> blazer, <a href="./character.md#character_character_BODY">BODY</a>);
    builder.body.insert(b"blazer".to_string(), blazer);
    // body: office
    <b>let</b> <b>mut</b> office = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>).move_to(3 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>).move_to(5 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>).move_to(7 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> office, <a href="./character.md#character_character_ACCENT">ACCENT</a>);
    builder.body.insert(b"office".to_string(), office);
    // body: tshirt
    <b>let</b> <b>mut</b> tshirt = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(3 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(7 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> tshirt, <a href="./character.md#character_character_BODY">BODY</a>);
    builder.body.insert(b"tshirt".to_string(), tshirt);
}
</code></pre>



</details>

<a name="character_character_set_display"></a>

## Function `set_display`

Display setup


<pre><code><b>fun</b> <a href="./character.md#character_character_set_display">set_display</a>(d: &<b>mut</b> <a href="../../.doc-deps/sui/display.md#sui_display_Display">sui::display::Display</a>&lt;<a href="./character.md#character_character_Character">character::character::Character</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_set_display">set_display</a>(d: &<b>mut</b> Display&lt;<a href="./character.md#character_character_Character">Character</a>&gt;) {
    <b>let</b> <b>mut</b> image_url = b"data:image/svg+xml;charset=utf8,".to_string();
    image_url.append(urlencode::encode(<a href="./character.md#character_character_build_character_base">build_character_base</a>().into_bytes()));
    d.<a href="./character.md#character_character_add">add</a>(b"image_url".to_string(), image_url);
    d.<a href="./character.md#character_character_add">add</a>(b"name".to_string(), b"Brave <a href="./character.md#character_character_Character">Character</a>!".to_string());
    d.<a href="./character.md#character_character_add">add</a>(b"description".to_string(), b"How wild can you go?".to_string());
    d.<a href="./character.md#character_character_add">add</a>(b"link".to_string(), b"https://potatoes.app/<a href="./character.md#character_character">character</a>/{id}".to_string());
    d.<a href="./character.md#character_character_add">add</a>(b"project_url".to_string(), b"https://potatoes.app/".to_string());
    d.<a href="./character.md#character_character_add">add</a>(b"creator".to_string(), b"Sui Potatoes (c)".to_string());
    d.update_version();
}
</code></pre>



</details>

<a name="character_character_build_pure_svg"></a>

## Function `build_pure_svg`



<pre><code><b>fun</b> <a href="./character.md#character_character_build_pure_svg">build_pure_svg</a>(): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_build_pure_svg">build_pure_svg</a>(): String {
    <b>let</b> <b>mut</b> body = shape::rect(3 * <a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>);
    add_class!(&<b>mut</b> body, <a href="./character.md#character_character_BODY">BODY</a>);
    <b>let</b> <b>mut</b> head = shape::rect(3 * <a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 2 * <a href="./character.md#character_character_PX">PX</a>);
    add_class!(&<b>mut</b> head, <a href="./character.md#character_character_SKIN">SKIN</a>);
    <b>let</b> <b>mut</b> eyes = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(6 * <a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> eyes, <a href="./character.md#character_character_EYES">EYES</a>);
    <b>let</b> <b>mut</b> legs = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(4 * <a href="./character.md#character_character_PX">PX</a>, 8 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, <a href="./character.md#character_character_PX">PX</a>).move_to(5 * <a href="./character.md#character_character_PX">PX</a>, 8 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(6 * <a href="./character.md#character_character_PX">PX</a>, 8 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> legs, <a href="./character.md#character_character_LEGS">LEGS</a>);
    <b>let</b> <b>mut</b> hands = container::g(vector[
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(3 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
        shape::rect(<a href="./character.md#character_character_PX">PX</a>, 3 * <a href="./character.md#character_character_PX">PX</a>).move_to(7 * <a href="./character.md#character_character_PX">PX</a>, 5 * <a href="./character.md#character_character_PX">PX</a>),
    ]);
    add_class!(&<b>mut</b> hands, <a href="./character.md#character_character_SKIN">SKIN</a>);
    // New SVG with the viewbox.
    <b>let</b> <b>mut</b> svg = <a href="../../.doc-deps/svg/svg.md#svg_svg">svg::svg</a>(vector[0, 0, 11 * <a href="./character.md#character_character_PX">PX</a>, 12 * <a href="./character.md#character_character_PX">PX</a>]);
    <b>let</b> styles = shape::custom(b"&lt;style&gt;.s{fill:#<a href="./character.md#character_character_SKIN">SKIN</a>} .e{fill:#<a href="./character.md#character_character_EYES">EYES</a>} .h{fill:#<a href="./character.md#character_character_HAIR">HAIR</a>} .l{fill:#PANTS} .b{fill:#<a href="./character.md#character_character_BODY">BODY</a>} .a{fill:#<a href="./character.md#character_character_ACCENT">ACCENT</a>}&lt;/style&gt;".to_string());
    svg.add_root(vector[styles, body, head]);
    svg.<a href="./character.md#character_character_add">add</a>(eyes);
    svg.<a href="./character.md#character_character_add">add</a>(legs);
    svg.<a href="./character.md#character_character_add">add</a>(hands);
    svg.add_root(vector[shape::custom(b"TEMPLATE".to_string())]); // template
    svg.to_string()
}
</code></pre>



</details>

<a name="character_character_build_character_base"></a>

## Function `build_character_base`

Builds the base character SVG template, used in the <code>Display</code> in the
<code><a href="./character.md#character_character_init">init</a></code> (<code><a href="./character.md#character_character_set_display">set_display</a></code>) function.


<pre><code><b>fun</b> <a href="./character.md#character_character_build_character_base">build_character_base</a>(): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_build_character_base">build_character_base</a>(): String {
    <b>let</b> template = <a href="./character.md#character_character_build_pure_svg">build_pure_svg</a>();
    // then run replacement script with the following values
    // <a href="./character.md#character_character_HAIR">HAIR</a> -&gt; {image.<a href="./character.md#character_character_hair_color">hair_color</a>}
    // <a href="./character.md#character_character_EYES">EYES</a> -&gt; {image.<a href="./character.md#character_character_eyes_color">eyes_color</a>}w
    // PANTS -&gt; {image.pants_color}
    // <a href="./character.md#character_character_SKIN">SKIN</a> -&gt; {image.<a href="./character.md#character_character_skin_color">skin_color</a>}
    // <a href="./character.md#character_character_BODY">BODY</a> -&gt; {image.<a href="./character.md#character_character_base_color">base_color</a>}
    // <a href="./character.md#character_character_ACCENT">ACCENT</a> -&gt; {image.<a href="./character.md#character_character_accent_color">accent_color</a>}
    // ideally <b>let</b>'s just write the template with Move...
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(template, b"<a href="./character.md#character_character_SKIN">SKIN</a>".to_string(), b"{image.<a href="./character.md#character_character_skin_color">skin_color</a>}".to_string());
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(template, b"<a href="./character.md#character_character_EYES">EYES</a>".to_string(), b"{image.<a href="./character.md#character_character_eyes_color">eyes_color</a>}".to_string());
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(template, b"<a href="./character.md#character_character_HAIR">HAIR</a>".to_string(), b"{image.<a href="./character.md#character_character_hair_color">hair_color</a>}".to_string());
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(template, b"PANTS".to_string(), b"{image.pants_color}".to_string());
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(template, b"<a href="./character.md#character_character_BODY">BODY</a>".to_string(), b"{image.<a href="./character.md#character_character_base_color">base_color</a>}".to_string());
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(
        template,
        b"<a href="./character.md#character_character_ACCENT">ACCENT</a>".to_string(),
        b"{image.<a href="./character.md#character_character_accent_color">accent_color</a>}".to_string(),
    );
    <b>let</b> template = <a href="./character.md#character_character_replace">replace</a>(
        template,
        b"TEMPLATE".to_string(),
        b"{image.hair}{image.body}".to_string(),
    );
    template
}
</code></pre>



</details>

<a name="character_character_replace"></a>

## Function `replace`



<pre><code><b>fun</b> <a href="./character.md#character_character_replace">replace</a>(str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, from: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, to: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./character.md#character_character_replace">replace</a>(str: String, from: String, to: String): String {
    <b>let</b> pos = str.index_of(&from);
    <b>let</b> str = {
        <b>let</b> <b>mut</b> lhs = str.substring(0, pos);
        <b>let</b> rhs = str.substring(pos + from.length(), str.length());
        lhs.append(to);
        lhs.append(rhs);
        lhs
    };
    str
}
</code></pre>



</details>
