
<a name="identify_identify"></a>

# Module `identify::identify`

Identify is a library that provides a way to identify the type of a value at
runtime. It is using type-identification mechanism of dynamic fields to
identify the type of a value.


-  [Function `is_u8`](#identify_identify_is_u8)
-  [Function `is_u16`](#identify_identify_is_u16)
-  [Function `is_u32`](#identify_identify_is_u32)
-  [Function `is_u64`](#identify_identify_is_u64)
-  [Function `is_u128`](#identify_identify_is_u128)
-  [Function `is_u256`](#identify_identify_is_u256)
-  [Function `is_address`](#identify_identify_is_address)
-  [Function `is_bool`](#identify_identify_is_bool)
-  [Function `is_vector`](#identify_identify_is_vector)
-  [Function `is_type`](#identify_identify_is_type)
-  [Function `as_u8`](#identify_identify_as_u8)
-  [Function `as_u16`](#identify_identify_as_u16)
-  [Function `as_u32`](#identify_identify_as_u32)
-  [Function `as_u64`](#identify_identify_as_u64)
-  [Function `as_u128`](#identify_identify_as_u128)
-  [Function `as_u256`](#identify_identify_as_u256)
-  [Function `as_address`](#identify_identify_as_address)
-  [Function `as_bool`](#identify_identify_as_bool)
-  [Function `as_vector`](#identify_identify_as_vector)
-  [Function `as_type`](#identify_identify_as_type)
-  [Macro function `as_internal`](#identify_identify_as_internal)
-  [Macro function `type_bytes`](#identify_identify_type_bytes)


<pre><code><b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="identify_identify_is_u8"></a>

## Function `is_u8`

Check if the type <code>T</code> is a <code>u8</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u8">is_u8</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u8">is_u8</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u8" }
</code></pre>



</details>

<a name="identify_identify_is_u16"></a>

## Function `is_u16`

Check if the type <code>T</code> is a <code>u16</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u16">is_u16</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u16">is_u16</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u16" }
</code></pre>



</details>

<a name="identify_identify_is_u32"></a>

## Function `is_u32`

Check if the type <code>T</code> is a <code>u32</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u32">is_u32</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u32">is_u32</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u32" }
</code></pre>



</details>

<a name="identify_identify_is_u64"></a>

## Function `is_u64`

Check if the type <code>T</code> is a <code>u64</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u64">is_u64</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u64">is_u64</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u64" }
</code></pre>



</details>

<a name="identify_identify_is_u128"></a>

## Function `is_u128`

Check if the type <code>T</code> is a <code>u128</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u128">is_u128</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u128">is_u128</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u128" }
</code></pre>



</details>

<a name="identify_identify_is_u256"></a>

## Function `is_u256`

Check if the type <code>T</code> is a <code>u256</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u256">is_u256</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_u256">is_u256</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"u256" }
</code></pre>



</details>

<a name="identify_identify_is_address"></a>

## Function `is_address`

Check if the type <code>T</code> is a <code><b>address</b></code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_address">is_address</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_address">is_address</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"<b>address</b>" }
</code></pre>



</details>

<a name="identify_identify_is_bool"></a>

## Function `is_bool`

Check if the type <code>T</code> is a <code>bool</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_bool">is_bool</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_bool">is_bool</a>&lt;T&gt;(): bool { <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;() == b"bool" }
</code></pre>



</details>

<a name="identify_identify_is_vector"></a>

## Function `is_vector`

Check if the type <code>T</code> is a <code>vector</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_vector">is_vector</a>&lt;T&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_vector">is_vector</a>&lt;T&gt;(): bool {
    <b>let</b> tb = <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>!&lt;T&gt;();
    tb.length() &gt; 5 && vector[tb[0], tb[1], tb[2], tb[3], tb[4], tb[5]] == b"vector"
}
</code></pre>



</details>

<a name="identify_identify_is_type"></a>

## Function `is_type`

Compare type names of <code>T</code> and <code>E</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_type">is_type</a>&lt;T, E&gt;(): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_is_type">is_type</a>&lt;T, E&gt;(): bool {
    type_name::with_original_ids&lt;T&gt;() == type_name::with_original_ids&lt;E&gt;()
}
</code></pre>



</details>

<a name="identify_identify_as_u8"></a>

## Function `as_u8`

Identify generic input <code>v</code> as the <code>u8</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u8">as_u8</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u8">as_u8</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u8 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_u16"></a>

## Function `as_u16`

Identify generic input <code>v</code> as the <code>u16</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u16">as_u16</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u16">as_u16</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u16 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_u32"></a>

## Function `as_u32`

Identify generic input <code>v</code> as the <code>u32</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u32">as_u32</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u32
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u32">as_u32</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u32 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_u64"></a>

## Function `as_u64`

Identify generic input <code>v</code> as the <code>u64</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u64">as_u64</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u64">as_u64</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u64 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_u128"></a>

## Function `as_u128`

Identify generic input <code>v</code> as the <code>u128</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u128">as_u128</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u128
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u128">as_u128</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u128 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_u256"></a>

## Function `as_u256`

Identify generic input <code>v</code> as the <code>u256</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u256">as_u256</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): u256
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_u256">as_u256</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): u256 { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_address"></a>

## Function `as_address`

Identify generic input <code>v</code> as the <code><b>address</b></code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_address">as_address</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <b>address</b>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_address">as_address</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): <b>address</b> { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_bool"></a>

## Function `as_bool`

Identify generic input <code>v</code> as the <code>bool</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_bool">as_bool</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_bool">as_bool</a>&lt;T: store&gt;(v: T, ctx: &<b>mut</b> TxContext): bool { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_vector"></a>

## Function `as_vector`

Identify generic input <code>v</code> as the <code>vector</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_vector">as_vector</a>&lt;T: store, V: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): vector&lt;V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_vector">as_vector</a>&lt;T: store, V: store&gt;(v: T, ctx: &<b>mut</b> TxContext): vector&lt;V&gt; {
    <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx)
}
</code></pre>



</details>

<a name="identify_identify_as_type"></a>

## Function `as_type`

Identify generic input <code>v</code> as the <code>R</code> type.


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_type">as_type</a>&lt;T: store, R: store&gt;(v: T, ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): R
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./identify.md#identify_identify_as_type">as_type</a>&lt;T: store, R: store&gt;(v: T, ctx: &<b>mut</b> TxContext): R { <a href="./identify.md#identify_identify_as_internal">as_internal</a>!(v, ctx) }
</code></pre>



</details>

<a name="identify_identify_as_internal"></a>

## Macro function `as_internal`

Identify the input <code>$V</code> as the <code>$R</code> type.


<pre><code><b>macro</b> <b>fun</b> <a href="./identify.md#identify_identify_as_internal">as_internal</a>&lt;$V: store, $R&gt;($v: $V, $ctx: &<b>mut</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): $R
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./identify.md#identify_identify_as_internal">as_internal</a>&lt;$V: store, $R&gt;($v: $V, $ctx: &<b>mut</b> TxContext): $R {
    <b>let</b> <b>mut</b> id = object::new($ctx);
    df::add(&<b>mut</b> id, <b>true</b>, $v);
    <b>let</b> value: $R = df::remove(&<b>mut</b> id, <b>true</b>);
    id.delete();
    value
}
</code></pre>



</details>

<a name="identify_identify_type_bytes"></a>

## Macro function `type_bytes`

Internal utility to get the bytes of the <code>TypeName</code> for <code>$T</code>.


<pre><code><b>macro</b> <b>fun</b> <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>&lt;$T&gt;(): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./identify.md#identify_identify_type_bytes">type_bytes</a>&lt;$T&gt;(): vector&lt;u8&gt; {
    type_name::with_original_ids&lt;$T&gt;().into_string().into_bytes()
}
</code></pre>



</details>
