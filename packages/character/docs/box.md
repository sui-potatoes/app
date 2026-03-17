
<a name="character_box"></a>

# Module `character::box`

A dynamic field storage which can store a single value or a single type.
Helps bypass Sui verifier limitations on the size of type layout when enums
are used in type definitions.


-  [Struct `Box`](#character_box_Box)
-  [Struct `Key`](#character_box_Key)
-  [Function `create`](#character_box_create)
-  [Function `inner`](#character_box_inner)
-  [Function `inner_mut`](#character_box_inner_mut)
-  [Function `destroy`](#character_box_destroy)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="character_box_Box"></a>

## Struct `Box`

A box that stores a single value or a single type.


<pre><code><b>public</b> <b>struct</b> <a href="./box.md#character_box_Box">Box</a>&lt;<b>phantom</b> T&gt; <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../.doc-deps/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="character_box_Key"></a>

## Struct `Key`



<pre><code><b>public</b> <b>struct</b> <a href="./box.md#character_box_Key">Key</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
</dl>


</details>

<a name="character_box_create"></a>

## Function `create`

Create a new box with the given value.


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_create">create</a>&lt;T: store&gt;(value: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="./box.md#character_box_Box">character::box::Box</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_create">create</a>&lt;T: store&gt;(value: T, ctx: &<b>mut</b> TxContext): <a href="./box.md#character_box_Box">Box</a>&lt;T&gt; {
    <b>let</b> <b>mut</b> id = object::new(ctx);
    df::add(&<b>mut</b> id, <a href="./box.md#character_box_Key">Key</a>(), value);
    <a href="./box.md#character_box_Box">Box</a> { id }
}
</code></pre>



</details>

<a name="character_box_inner"></a>

## Function `inner`

Get the value stored in the box.


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_inner">inner</a>&lt;T: store&gt;(<a href="./box.md#character_box">box</a>: &<a href="./box.md#character_box_Box">character::box::Box</a>&lt;T&gt;): &T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_inner">inner</a>&lt;T: store&gt;(<a href="./box.md#character_box">box</a>: &<a href="./box.md#character_box_Box">Box</a>&lt;T&gt;): &T { df::borrow(&<a href="./box.md#character_box">box</a>.id, <a href="./box.md#character_box_Key">Key</a>()) }
</code></pre>



</details>

<a name="character_box_inner_mut"></a>

## Function `inner_mut`

Get a mutable reference to the value stored in the box.


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_inner_mut">inner_mut</a>&lt;T: store&gt;(<a href="./box.md#character_box">box</a>: &<b>mut</b> <a href="./box.md#character_box_Box">character::box::Box</a>&lt;T&gt;): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_inner_mut">inner_mut</a>&lt;T: store&gt;(<a href="./box.md#character_box">box</a>: &<b>mut</b> <a href="./box.md#character_box_Box">Box</a>&lt;T&gt;): &<b>mut</b> T { df::borrow_mut(&<b>mut</b> <a href="./box.md#character_box">box</a>.id, <a href="./box.md#character_box_Key">Key</a>()) }
</code></pre>



</details>

<a name="character_box_destroy"></a>

## Function `destroy`

Destroy the box and return the value stored in it.


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_destroy">destroy</a>&lt;T: store&gt;(<a href="./box.md#character_box">box</a>: <a href="./box.md#character_box_Box">character::box::Box</a>&lt;T&gt;): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./box.md#character_box_destroy">destroy</a>&lt;T: store&gt;(<b>mut</b> <a href="./box.md#character_box">box</a>: <a href="./box.md#character_box_Box">Box</a>&lt;T&gt;): T {
    <b>let</b> value = df::remove(&<b>mut</b> <a href="./box.md#character_box">box</a>.id, <a href="./box.md#character_box_Key">Key</a>());
    <b>let</b> <a href="./box.md#character_box_Box">Box</a> { id } = <a href="./box.md#character_box">box</a>;
    id.delete();
    value
}
</code></pre>



</details>
