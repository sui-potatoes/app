
<a name="sui_dynamic_object_field"></a>

# Module `sui::dynamic_object_field`

Similar to <code><a href="../sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a></code>, this module allows for the access of dynamic fields. But
unlike, <code><a href="../sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a></code> the values bound to these dynamic fields _must_ be objects
themselves. This allows for the objects to still exist within in storage, which may be important
for external tools. The difference is otherwise not observable from within Move.


-  [Struct `Wrapper`](#sui_dynamic_object_field_Wrapper)
-  [Function `add`](#sui_dynamic_object_field_add)
-  [Function `borrow`](#sui_dynamic_object_field_borrow)
-  [Function `borrow_mut`](#sui_dynamic_object_field_borrow_mut)
-  [Function `remove`](#sui_dynamic_object_field_remove)
-  [Function `exists_`](#sui_dynamic_object_field_exists_)
-  [Function `exists_with_type`](#sui_dynamic_object_field_exists_with_type)
-  [Function `id`](#sui_dynamic_object_field_id)
-  [Function `internal_add`](#sui_dynamic_object_field_internal_add)
-  [Function `internal_borrow`](#sui_dynamic_object_field_internal_borrow)
-  [Function `internal_borrow_mut`](#sui_dynamic_object_field_internal_borrow_mut)
-  [Function `internal_remove`](#sui_dynamic_object_field_internal_remove)
-  [Function `internal_exists_with_type`](#sui_dynamic_object_field_internal_exists_with_type)
-  [Macro function `add_impl`](#sui_dynamic_object_field_add_impl)
-  [Macro function `borrow_impl`](#sui_dynamic_object_field_borrow_impl)
-  [Macro function `borrow_mut_impl`](#sui_dynamic_object_field_borrow_mut_impl)
-  [Macro function `remove_impl`](#sui_dynamic_object_field_remove_impl)
-  [Macro function `exists_with_type_impl`](#sui_dynamic_object_field_exists_with_type_impl)


<pre><code><b>use</b> <a href="../std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
</code></pre>



<a name="sui_dynamic_object_field_Wrapper"></a>

## Struct `Wrapper`



<pre><code><b>public</b> <b>struct</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;Name&gt; <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>name: Name</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="sui_dynamic_object_field_add"></a>

## Function `add`

Adds a dynamic object field to the object <code>object: &<b>mut</b> UID</code> at field specified by <code>name: Name</code>.
Aborts with <code>EFieldAlreadyExists</code> if the object already has that field with that name.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add">add</a>&lt;Name: <b>copy</b>, drop, store, Value: key, store&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name, value: Value)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add">add</a>&lt;Name: <b>copy</b> + drop + store, Value: key + store&gt;(
    // we <b>use</b> &<b>mut</b> UID in several spots <b>for</b> access control
    object: &<b>mut</b> UID,
    name: Name,
    value: Value,
) {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add_impl">add_impl</a>!(object, name, value)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_borrow"></a>

## Function `borrow`

Immutably borrows the <code>object</code>s dynamic object field with the name specified by <code>name: Name</code>.
Aborts with <code>EFieldDoesNotExist</code> if the object does not have a field with that name.
Aborts with <code>EFieldTypeMismatch</code> if the field exists, but the value object does not have the
specified type.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow">borrow</a>&lt;Name: <b>copy</b>, drop, store, Value: key, store&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): &Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow">borrow</a>&lt;Name: <b>copy</b> + drop + store, Value: key + store&gt;(object: &UID, name: Name): &Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_impl">borrow_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_borrow_mut"></a>

## Function `borrow_mut`

Mutably borrows the <code>object</code>s dynamic object field with the name specified by <code>name: Name</code>.
Aborts with <code>EFieldDoesNotExist</code> if the object does not have a field with that name.
Aborts with <code>EFieldTypeMismatch</code> if the field exists, but the value object does not have the
specified type.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut">borrow_mut</a>&lt;Name: <b>copy</b>, drop, store, Value: key, store&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): &<b>mut</b> Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut">borrow_mut</a>&lt;Name: <b>copy</b> + drop + store, Value: key + store&gt;(
    object: &<b>mut</b> UID,
    name: Name,
): &<b>mut</b> Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut_impl">borrow_mut_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_remove"></a>

## Function `remove`

Removes the <code>object</code>s dynamic object field with the name specified by <code>name: Name</code> and returns
the bound object.
Aborts with <code>EFieldDoesNotExist</code> if the object does not have a field with that name.
Aborts with <code>EFieldTypeMismatch</code> if the field exists, but the value object does not have the
specified type.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove">remove</a>&lt;Name: <b>copy</b>, drop, store, Value: key, store&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove">remove</a>&lt;Name: <b>copy</b> + drop + store, Value: key + store&gt;(
    object: &<b>mut</b> UID,
    name: Name,
): Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove_impl">remove_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_exists_"></a>

## Function `exists_`

Returns true if and only if the <code>object</code> has a dynamic object field with the name specified by
<code>name: Name</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_">exists_</a>&lt;Name: <b>copy</b>, drop, store&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_">exists_</a>&lt;Name: <b>copy</b> + drop + store&gt;(object: &UID, name: Name): bool {
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    field::exists_with_type&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;Name&gt;, ID&gt;(object, key)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_exists_with_type"></a>

## Function `exists_with_type`

Returns true if and only if the <code>object</code> has a dynamic field with the name specified by
<code>name: Name</code> with an assigned value of type <code>Value</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type">exists_with_type</a>&lt;Name: <b>copy</b>, drop, store, Value: key, store&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type">exists_with_type</a>&lt;Name: <b>copy</b> + drop + store, Value: key + store&gt;(
    object: &UID,
    name: Name,
): bool {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type_impl">exists_with_type_impl</a>!&lt;_, Value&gt;(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_id"></a>

## Function `id`

Returns the ID of the object associated with the dynamic object field
Returns none otherwise


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_id">id</a>&lt;Name: <b>copy</b>, drop, store&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): <a href="../std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="../sui/object.md#sui_object_ID">sui::object::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_id">id</a>&lt;Name: <b>copy</b> + drop + store&gt;(object: &UID, name: Name): Option&lt;ID&gt; {
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>if</b> (!field::exists_with_type&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;Name&gt;, ID&gt;(object, key)) <b>return</b> option::none();
    <b>let</b> (_field, value_addr) = field::field_info&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;Name&gt;&gt;(object, key);
    option::some(value_addr.to_id())
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_internal_add"></a>

## Function `internal_add`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_add">internal_add</a>&lt;Name: <b>copy</b>, drop, store, Value: key&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name, value: Value)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_add">internal_add</a>&lt;Name: <b>copy</b> + drop + store, Value: key&gt;(
    // we <b>use</b> &<b>mut</b> UID in several spots <b>for</b> access control
    object: &<b>mut</b> UID,
    name: Name,
    value: Value,
) {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add_impl">add_impl</a>!(object, name, value)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_internal_borrow"></a>

## Function `internal_borrow`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_borrow">internal_borrow</a>&lt;Name: <b>copy</b>, drop, store, Value: key&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): &Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_borrow">internal_borrow</a>&lt;Name: <b>copy</b> + drop + store, Value: key&gt;(
    object: &UID,
    name: Name,
): &Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_impl">borrow_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_internal_borrow_mut"></a>

## Function `internal_borrow_mut`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_borrow_mut">internal_borrow_mut</a>&lt;Name: <b>copy</b>, drop, store, Value: key&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): &<b>mut</b> Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_borrow_mut">internal_borrow_mut</a>&lt;Name: <b>copy</b> + drop + store, Value: key&gt;(
    object: &<b>mut</b> UID,
    name: Name,
): &<b>mut</b> Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut_impl">borrow_mut_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_internal_remove"></a>

## Function `internal_remove`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_remove">internal_remove</a>&lt;Name: <b>copy</b>, drop, store, Value: key&gt;(object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_remove">internal_remove</a>&lt;Name: <b>copy</b> + drop + store, Value: key&gt;(
    object: &<b>mut</b> UID,
    name: Name,
): Value {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove_impl">remove_impl</a>!(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_internal_exists_with_type"></a>

## Function `internal_exists_with_type`



<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_exists_with_type">internal_exists_with_type</a>&lt;Name: <b>copy</b>, drop, store, Value: key&gt;(object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, name: Name): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_internal_exists_with_type">internal_exists_with_type</a>&lt;Name: <b>copy</b> + drop + store, Value: key&gt;(
    object: &UID,
    name: Name,
): bool {
    <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type_impl">exists_with_type_impl</a>!&lt;_, Value&gt;(object, name)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_add_impl"></a>

## Macro function `add_impl`



<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add_impl">add_impl</a>&lt;$Name: <b>copy</b>, drop, store, $Value: key&gt;($object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, $name: $Name, $value: $Value)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_add_impl">add_impl</a>&lt;$Name: <b>copy</b> + drop + store, $Value: key&gt;(
    // we <b>use</b> &<b>mut</b> UID in several spots <b>for</b> access control
    $object: &<b>mut</b> UID,
    $name: $Name,
    $value: $Value,
) {
    <b>let</b> object = $object;
    <b>let</b> name = $name;
    <b>let</b> value = $value;
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>let</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_id">id</a> = object::id(&value);
    field::add(object, key, <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_id">id</a>);
    <b>let</b> (field, _) = field::field_info&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;&gt;(object, key);
    add_child_object(field.to_address(), value);
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_borrow_impl"></a>

## Macro function `borrow_impl`



<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_impl">borrow_impl</a>&lt;$Name: <b>copy</b>, drop, store, $Value: key&gt;($object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, $name: $Name): &$Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_impl">borrow_impl</a>&lt;$Name: <b>copy</b> + drop + store, $Value: key&gt;(
    $object: &UID,
    $name: $Name,
): &$Value {
    <b>let</b> object = $object;
    <b>let</b> name = $name;
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>let</b> (field, value_id) = field::field_info&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;&gt;(object, key);
    borrow_child_object&lt;$Value&gt;(field, value_id)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_borrow_mut_impl"></a>

## Macro function `borrow_mut_impl`



<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut_impl">borrow_mut_impl</a>&lt;$Name: <b>copy</b>, drop, store, $Value: key&gt;($object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, $name: $Name): &<b>mut</b> $Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_borrow_mut_impl">borrow_mut_impl</a>&lt;$Name: <b>copy</b> + drop + store, $Value: key&gt;(
    $object: &<b>mut</b> UID,
    $name: $Name,
): &<b>mut</b> $Value {
    <b>let</b> object = $object;
    <b>let</b> name = $name;
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>let</b> (field, value_id) = field::field_info_mut&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;&gt;(object, key);
    borrow_child_object_mut&lt;$Value&gt;(field, value_id)
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_remove_impl"></a>

## Macro function `remove_impl`



<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove_impl">remove_impl</a>&lt;$Name: <b>copy</b>, drop, store, $Value: key&gt;($object: &<b>mut</b> <a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, $name: $Name): $Value
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_remove_impl">remove_impl</a>&lt;$Name: <b>copy</b> + drop + store, $Value: key&gt;(
    $object: &<b>mut</b> UID,
    $name: $Name,
): $Value {
    <b>let</b> object = $object;
    <b>let</b> name = $name;
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>let</b> (field, value_id) = field::field_info&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;&gt;(object, key);
    <b>let</b> value = remove_child_object&lt;$Value&gt;(field.to_address(), value_id);
    field::remove&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;, ID&gt;(object, key);
    value
}
</code></pre>



</details>

<a name="sui_dynamic_object_field_exists_with_type_impl"></a>

## Macro function `exists_with_type_impl`



<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type_impl">exists_with_type_impl</a>&lt;$Name: <b>copy</b>, drop, store, $Value: key&gt;($object: &<a href="../sui/object.md#sui_object_UID">sui::object::UID</a>, $name: $Name): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_exists_with_type_impl">exists_with_type_impl</a>&lt;$Name: <b>copy</b> + drop + store, $Value: key&gt;(
    $object: &UID,
    $name: $Name,
): bool {
    <b>let</b> object = $object;
    <b>let</b> name = $name;
    <b>let</b> key = <a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a> { name };
    <b>if</b> (!field::exists_with_type&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;, ID&gt;(object, key)) <b>return</b> <b>false</b>;
    <b>let</b> (field, value_id) = field::field_info&lt;<a href="../sui/dynamic_object_field.md#sui_dynamic_object_field_Wrapper">Wrapper</a>&lt;$Name&gt;&gt;(object, key);
    field::has_child_object_with_ty&lt;$Value&gt;(field.to_address(), value_id)
}
</code></pre>



</details>
