
<a name="(commander=0x0)_param"></a>

# Module `(commander=0x0)::param`

Defines the <code><a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a></code> component and its methods.

Traits:
- from_bcs
- to_string


-  [Struct `Param`](#(commander=0x0)_param_Param)
-  [Function `new`](#(commander=0x0)_param_new)
-  [Function `value`](#(commander=0x0)_param_value)
-  [Function `max_value`](#(commander=0x0)_param_max_value)
-  [Function `is_full`](#(commander=0x0)_param_is_full)
-  [Function `is_empty`](#(commander=0x0)_param_is_empty)
-  [Function `decrease`](#(commander=0x0)_param_decrease)
-  [Function `deplete`](#(commander=0x0)_param_deplete)
-  [Function `reset`](#(commander=0x0)_param_reset)
-  [Function `from_bytes`](#(commander=0x0)_param_from_bytes)
-  [Function `from_bcs`](#(commander=0x0)_param_from_bcs)
-  [Function `to_string`](#(commander=0x0)_param_to_string)


<pre><code><b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="(commander=0x0)_param_Param"></a>

## Struct `Param`

A parameter for a <code>Unit</code>. Parameters are used to define the state of a
<code>Unit</code> such as health, action points, and other stats. Parameters have a
value and a maximum value, and can be reset to the maximum value at the
start of each turn.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>: u16</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>: u16</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(commander=0x0)_param_new"></a>

## Function `new`

Create a new <code><a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a></code> a maximum value.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_new">new</a>(<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_new">new</a>(<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>: u16): <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> { <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> { <a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>: <a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>, <a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a> } }
</code></pre>



</details>

<a name="(commander=0x0)_param_value"></a>

## Function `value`

Get the current value of the parameter.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>): u16 { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> }
</code></pre>



</details>

<a name="(commander=0x0)_param_max_value"></a>

## Function `max_value`

Get the maximum value of the parameter.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>): u16 { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a> }
</code></pre>



</details>

<a name="(commander=0x0)_param_is_full"></a>

## Function `is_full`

Check if the parameter is full, i.e. the value is equal to the maximum value.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_is_full">is_full</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_is_full">is_full</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>): bool { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> == <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a> }
</code></pre>



</details>

<a name="(commander=0x0)_param_is_empty"></a>

## Function `is_empty`

Check if the parameter is empty, i.e. the value is 0.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_is_empty">is_empty</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_is_empty">is_empty</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>): bool { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> == 0 }
</code></pre>



</details>

<a name="(commander=0x0)_param_decrease"></a>

## Function `decrease`

Decrease the value of the parameter by a certain amount. The value cannot go
below 0.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_decrease">decrease</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>, amount: u16): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_decrease">decrease</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>, amount: u16): u16 {
    <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> = <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> - amount.min(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>);
    <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_param_deplete"></a>

## Function `deplete`

Deplete the value of the parameter to 0.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_deplete">deplete</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_deplete">deplete</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>) { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> = 0; }
</code></pre>



</details>

<a name="(commander=0x0)_param_reset"></a>

## Function `reset`

Reset the value of the parameter to the maximum value.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_reset">reset</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_reset">reset</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<b>mut</b> <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>) { <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a> = <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>; }
</code></pre>



</details>

<a name="(commander=0x0)_param_from_bytes"></a>

## Function `from_bytes`

Deserialize bytes into a <code><a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> {
    <b>let</b> <b>mut</b> bcs = bcs::new(bytes);
    <a href="../name_gen/param.md#(commander=0x0)_param_from_bcs">from_bcs</a>(&<b>mut</b> bcs)
}
</code></pre>



</details>

<a name="(commander=0x0)_param_from_bcs"></a>

## Function `from_bcs`

Helper method to allow nested deserialization of <code><a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a></code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../dependencies/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> {
    <a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a> {
        <a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>: bcs.peel_u16(),
        <a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>: bcs.peel_u16(),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_param_to_string"></a>

## Function `to_string`

Convert a parameter to a <code>String</code> representation.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_to_string">to_string</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param_Param">param::Param</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/param.md#(commander=0x0)_param_to_string">to_string</a>(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>: &<a href="../name_gen/param.md#(commander=0x0)_param_Param">Param</a>): String {
    <b>let</b> <b>mut</b> str = <a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_value">value</a>.<a href="../name_gen/param.md#(commander=0x0)_param_to_string">to_string</a>();
    str.append_utf8(b"/");
    str.append(<a href="../name_gen/param.md#(commander=0x0)_param">param</a>.<a href="../name_gen/param.md#(commander=0x0)_param_max_value">max_value</a>.<a href="../name_gen/param.md#(commander=0x0)_param_to_string">to_string</a>());
    str
}
</code></pre>



</details>
