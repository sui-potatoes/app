
<a name="sui_linked_table"></a>

# Module `sui::linked_table`

Similar to <code><a href="../../dependencies/sui/table.md#sui_table">sui::table</a></code> but the values are linked together, allowing for ordered insertion and
removal


-  [Struct `LinkedTable`](#sui_linked_table_LinkedTable)
-  [Struct `Node`](#sui_linked_table_Node)
-  [Constants](#@Constants_0)
-  [Function `new`](#sui_linked_table_new)
-  [Function `front`](#sui_linked_table_front)
-  [Function `back`](#sui_linked_table_back)
-  [Function `push_front`](#sui_linked_table_push_front)
-  [Function `push_back`](#sui_linked_table_push_back)
-  [Function `borrow`](#sui_linked_table_borrow)
-  [Function `borrow_mut`](#sui_linked_table_borrow_mut)
-  [Function `prev`](#sui_linked_table_prev)
-  [Function `next`](#sui_linked_table_next)
-  [Function `remove`](#sui_linked_table_remove)
-  [Function `pop_front`](#sui_linked_table_pop_front)
-  [Function `pop_back`](#sui_linked_table_pop_back)
-  [Function `contains`](#sui_linked_table_contains)
-  [Function `length`](#sui_linked_table_length)
-  [Function `is_empty`](#sui_linked_table_is_empty)
-  [Function `destroy_empty`](#sui_linked_table_destroy_empty)
-  [Function `drop`](#sui_linked_table_drop)


<pre><code><b>use</b> <a href="../../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="sui_linked_table_LinkedTable"></a>

## Struct `LinkedTable`



<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, <b>phantom</b> V: store&gt; <b>has</b> key, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>id: <a href="../../dependencies/sui/object.md#sui_object_UID">sui::object::UID</a></code>
</dt>
<dd>
 the ID of this table
</dd>
<dt>
<code>size: u64</code>
</dt>
<dd>
 the number of key-value pairs in the table
</dd>
<dt>
<code>head: <a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 the front of the table, i.e. the key of the first entry
</dd>
<dt>
<code>tail: <a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 the back of the table, i.e. the key of the last entry
</dd>
</dl>


</details>

<a name="sui_linked_table_Node"></a>

## Struct `Node`



<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt; <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>: <a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 the previous key
</dd>
<dt>
<code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>: <a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;</code>
</dt>
<dd>
 the next key
</dd>
<dt>
<code>value: V</code>
</dt>
<dd>
 the value being stored
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="sui_linked_table_ETableNotEmpty"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableNotEmpty">ETableNotEmpty</a>: u64 = 0;
</code></pre>



<a name="sui_linked_table_ETableIsEmpty"></a>



<pre><code><b>const</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableIsEmpty">ETableIsEmpty</a>: u64 = 1;
</code></pre>



<a name="sui_linked_table_new"></a>

## Function `new`

Creates a new, empty table


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_new">new</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(ctx: &<b>mut</b> <a href="../../dependencies/sui/tx_context.md#sui_tx_context_TxContext">sui::tx_context::TxContext</a>): <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_new">new</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(ctx: &<b>mut</b> TxContext): <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt; {
    <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a> {
        id: object::new(ctx),
        size: 0,
        head: option::none(),
        tail: option::none(),
    }
}
</code></pre>



</details>

<a name="sui_linked_table_front"></a>

## Function `front`

Returns the key for the first element in the table, or None if the table is empty


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_front">front</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): &<a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_front">front</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): &Option&lt;K&gt; {
    &table.head
}
</code></pre>



</details>

<a name="sui_linked_table_back"></a>

## Function `back`

Returns the key for the last element in the table, or None if the table is empty


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_back">back</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): &<a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_back">back</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): &Option&lt;K&gt; {
    &table.tail
}
</code></pre>



</details>

<a name="sui_linked_table_push_front"></a>

## Function `push_front`

Inserts a key-value pair at the front of the table, i.e. the newly inserted pair will be
the first element in the table
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldAlreadyExists">sui::dynamic_field::EFieldAlreadyExists</a></code> if the table already has an entry with
that key <code>k: K</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_push_front">push_front</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_push_front">push_front</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(
    table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;,
    k: K,
    value: V,
) {
    <b>let</b> old_head = table.head.swap_or_fill(k);
    <b>if</b> (table.tail.is_none()) table.tail.fill(k);
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a> = option::none();
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a> = <b>if</b> (old_head.is_some()) {
        <b>let</b> old_head_k = old_head.destroy_some();
        field::borrow_mut&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&<b>mut</b> table.id, old_head_k).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a> = option::some(k);
        option::some(old_head_k)
    } <b>else</b> {
        option::none()
    };
    field::add(&<b>mut</b> table.id, k, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a> { <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>, value });
    table.size = table.size + 1;
}
</code></pre>



</details>

<a name="sui_linked_table_push_back"></a>

## Function `push_back`

Inserts a key-value pair at the back of the table, i.e. the newly inserted pair will be
the last element in the table
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldAlreadyExists">sui::dynamic_field::EFieldAlreadyExists</a></code> if the table already has an entry with
that key <code>k: K</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_push_back">push_back</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K, value: V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_push_back">push_back</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(
    table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;,
    k: K,
    value: V,
) {
    <b>if</b> (table.head.is_none()) table.head.fill(k);
    <b>let</b> old_tail = table.tail.swap_or_fill(k);
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a> = <b>if</b> (old_tail.is_some()) {
        <b>let</b> old_tail_k = old_tail.destroy_some();
        field::borrow_mut&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&<b>mut</b> table.id, old_tail_k).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a> = option::some(k);
        option::some(old_tail_k)
    } <b>else</b> {
        option::none()
    };
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a> = option::none();
    field::add(&<b>mut</b> table.id, k, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a> { <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>, value });
    table.size = table.size + 1;
}
</code></pre>



</details>

<a name="sui_linked_table_borrow"></a>

## Function `borrow`

Immutable borrows the value associated with the key in the table <code>table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code>.
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldDoesNotExist">sui::dynamic_field::EFieldDoesNotExist</a></code> if the table does not have an entry with
that key <code>k: K</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): &V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;, k: K): &V {
    &field::borrow&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&table.id, k).value
}
</code></pre>



</details>

<a name="sui_linked_table_borrow_mut"></a>

## Function `borrow_mut`

Mutably borrows the value associated with the key in the table <code>table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code>.
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldDoesNotExist">sui::dynamic_field::EFieldDoesNotExist</a></code> if the table does not have an entry with
that key <code>k: K</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow_mut">borrow_mut</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): &<b>mut</b> V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow_mut">borrow_mut</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(
    table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;,
    k: K,
): &<b>mut</b> V {
    &<b>mut</b> field::borrow_mut&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&<b>mut</b> table.id, k).value
}
</code></pre>



</details>

<a name="sui_linked_table_prev"></a>

## Function `prev`

Borrows the key for the previous entry of the specified key <code>k: K</code> in the table
<code>table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code>. Returns None if the entry does not have a predecessor.
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldDoesNotExist">sui::dynamic_field::EFieldDoesNotExist</a></code> if the table does not have an entry with
that key <code>k: K</code>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): &<a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;, k: K): &Option&lt;K&gt; {
    &field::borrow&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&table.id, k).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>
}
</code></pre>



</details>

<a name="sui_linked_table_next"></a>

## Function `next`

Borrows the key for the next entry of the specified key <code>k: K</code> in the table
<code>table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code>. Returns None if the entry does not have a predecessor.
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldDoesNotExist">sui::dynamic_field::EFieldDoesNotExist</a></code> if the table does not have an entry with
that key <code>k: K</code>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): &<a href="../../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;K&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;, k: K): &Option&lt;K&gt; {
    &field::borrow&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&table.id, k).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>
}
</code></pre>



</details>

<a name="sui_linked_table_remove"></a>

## Function `remove`

Removes the key-value pair in the table <code>table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code> and returns the value.
This splices the element out of the ordering.
Aborts with <code><a href="../../dependencies/sui/dynamic_field.md#sui_dynamic_field_EFieldDoesNotExist">sui::dynamic_field::EFieldDoesNotExist</a></code> if the table does not have an entry with
that key <code>k: K</code>. Note: this is also what happens when the table is empty.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_remove">remove</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): V
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_remove">remove</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;, k: K): V {
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt; { <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>, value } = field::remove(&<b>mut</b> table.id, k);
    table.size = table.size - 1;
    <b>if</b> (<a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>.is_some()) {
        field::borrow_mut&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&<b>mut</b> table.id, *<a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>()).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a> = <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>
    };
    <b>if</b> (<a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>.is_some()) {
        field::borrow_mut&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&<b>mut</b> table.id, *<a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>()).<a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a> = <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>
    };
    <b>if</b> (table.head.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>() == &k) table.head = <a href="../../dependencies/sui/linked_table.md#sui_linked_table_next">next</a>;
    <b>if</b> (table.tail.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>() == &k) table.tail = <a href="../../dependencies/sui/linked_table.md#sui_linked_table_prev">prev</a>;
    value
}
</code></pre>



</details>

<a name="sui_linked_table_pop_front"></a>

## Function `pop_front`

Removes the front of the table <code>table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code> and returns the value.
Aborts with <code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableIsEmpty">ETableIsEmpty</a></code> if the table is empty


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_pop_front">pop_front</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): (K, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_pop_front">pop_front</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): (K, V) {
    <b>assert</b>!(table.head.is_some(), <a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableIsEmpty">ETableIsEmpty</a>);
    <b>let</b> head = *table.head.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>();
    (head, table.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_remove">remove</a>(head))
}
</code></pre>



</details>

<a name="sui_linked_table_pop_back"></a>

## Function `pop_back`

Removes the back of the table <code>table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code> and returns the value.
Aborts with <code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableIsEmpty">ETableIsEmpty</a></code> if the table is empty


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_pop_back">pop_back</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): (K, V)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_pop_back">pop_back</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<b>mut</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): (K, V) {
    <b>assert</b>!(table.tail.is_some(), <a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableIsEmpty">ETableIsEmpty</a>);
    <b>let</b> tail = *table.tail.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_borrow">borrow</a>();
    (tail, table.<a href="../../dependencies/sui/linked_table.md#sui_linked_table_remove">remove</a>(tail))
}
</code></pre>



</details>

<a name="sui_linked_table_contains"></a>

## Function `contains`

Returns true iff there is a value associated with the key <code>k: K</code> in table
<code>table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;</code>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_contains">contains</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;, k: K): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_contains">contains</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;, k: K): bool {
    field::exists_with_type&lt;K, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_Node">Node</a>&lt;K, V&gt;&gt;(&table.id, k)
}
</code></pre>



</details>

<a name="sui_linked_table_length"></a>

## Function `length`

Returns the size of the table, the number of key-value pairs


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_length">length</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_length">length</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): u64 {
    table.size
}
</code></pre>



</details>

<a name="sui_linked_table_is_empty"></a>

## Function `is_empty`

Returns true iff the table is empty (if <code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_length">length</a></code> returns <code>0</code>)


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_is_empty">is_empty</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_is_empty">is_empty</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: &<a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;): bool {
    table.size == 0
}
</code></pre>



</details>

<a name="sui_linked_table_destroy_empty"></a>

## Function `destroy_empty`

Destroys an empty table
Aborts with <code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableNotEmpty">ETableNotEmpty</a></code> if the table still contains values


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_destroy_empty">destroy_empty</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: store&gt;(table: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_destroy_empty">destroy_empty</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: store&gt;(table: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;) {
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a> { id, size, head: _, tail: _ } = table;
    <b>assert</b>!(size == 0, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_ETableNotEmpty">ETableNotEmpty</a>);
    id.delete()
}
</code></pre>



</details>

<a name="sui_linked_table_drop"></a>

## Function `drop`

Drop a possibly non-empty table.
Usable only if the value type <code>V</code> has the <code><a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a></code> ability


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>&lt;K: <b>copy</b>, <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store, V: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>, store&gt;(table: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">sui::linked_table::LinkedTable</a>&lt;K, V&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a>&lt;K: <b>copy</b> + <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store, V: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_drop">drop</a> + store&gt;(table: <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a>&lt;K, V&gt;) {
    <b>let</b> <a href="../../dependencies/sui/linked_table.md#sui_linked_table_LinkedTable">LinkedTable</a> { id, size: _, head: _, tail: _ } = table;
    id.delete()
}
</code></pre>



</details>
