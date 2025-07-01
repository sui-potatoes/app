
<a name="bit_field_bit_field"></a>

# Module `bit_field::bit_field`



-  [Macro function `pack_bool`](#bit_field_bit_field_pack_bool)
-  [Macro function `pack_u8`](#bit_field_bit_field_pack_u8)
-  [Macro function `pack_u16`](#bit_field_bit_field_pack_u16)
-  [Macro function `pack_u32`](#bit_field_bit_field_pack_u32)
-  [Macro function `pack_u64`](#bit_field_bit_field_pack_u64)
-  [Macro function `unpack_bool`](#bit_field_bit_field_unpack_bool)
-  [Macro function `unpack_u8`](#bit_field_bit_field_unpack_u8)
-  [Macro function `unpack_u16`](#bit_field_bit_field_unpack_u16)
-  [Macro function `unpack_u32`](#bit_field_bit_field_unpack_u32)
-  [Macro function `unpack_u64`](#bit_field_bit_field_unpack_u64)
-  [Macro function `read_bool_at_offset`](#bit_field_bit_field_read_bool_at_offset)
-  [Macro function `read_u8_at_offset`](#bit_field_bit_field_read_u8_at_offset)
-  [Macro function `read_u16_at_offset`](#bit_field_bit_field_read_u16_at_offset)
-  [Macro function `read_u32_at_offset`](#bit_field_bit_field_read_u32_at_offset)
-  [Macro function `read_u64_at_offset`](#bit_field_bit_field_read_u64_at_offset)


<pre><code></code></pre>



<a name="bit_field_bit_field_pack_bool"></a>

## Macro function `pack_bool`

Pack a vector of <code>bool</code> into an unsigned integer.
Unlike other pack functions, this one shifts bit by bit.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_bool">pack_bool</a>&lt;$T&gt;($values: vector&lt;bool&gt;): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_bool">pack_bool</a>&lt;$T&gt;($values: vector&lt;bool&gt;): $T {
    <b>let</b> <b>mut</b> values = $values;
    <b>let</b> <b>mut</b> v: $T = 0;
    <b>let</b> (<b>mut</b> i, len) = (0, values.length() <b>as</b> u8);
    values.reverse();
    <b>while</b> (i &lt; len) {
        v = v | (<b>if</b> (values.pop_back()) 1 <b>else</b> 0 <b>as</b> $T) &lt;&lt; i;
        i = i + 1;
    };
    v
}
</code></pre>



</details>

<a name="bit_field_bit_field_pack_u8"></a>

## Macro function `pack_u8`

Pack a vector of <code>u8</code> into an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u8">pack_u8</a>&lt;$T&gt;($values: vector&lt;u8&gt;): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u8">pack_u8</a>&lt;$T&gt;($values: vector&lt;u8&gt;): $T {
    <b>let</b> <b>mut</b> values = $values;
    <b>let</b> <b>mut</b> v: $T = 0;
    <b>let</b> (<b>mut</b> i, len) = (0, values.length() <b>as</b> u8);
    values.reverse();
    <b>while</b> (i &lt; len) {
        v = v | (values.pop_back() <b>as</b> $T) &lt;&lt; (8 * i);
        i = i + 1;
    };
    v
}
</code></pre>



</details>

<a name="bit_field_bit_field_pack_u16"></a>

## Macro function `pack_u16`

Pack a vector of <code>u16</code> into an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u16">pack_u16</a>&lt;$T&gt;($values: vector&lt;u16&gt;): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u16">pack_u16</a>&lt;$T&gt;($values: vector&lt;u16&gt;): $T {
    <b>let</b> <b>mut</b> values = $values;
    <b>let</b> <b>mut</b> v: $T = 0;
    <b>let</b> (<b>mut</b> i, len) = (0, values.length() <b>as</b> u8);
    values.reverse();
    <b>while</b> (i &lt; len) {
        v = v | (values.pop_back() <b>as</b> $T) &lt;&lt; (16 * i);
        i = i + 1;
    };
    v
}
</code></pre>



</details>

<a name="bit_field_bit_field_pack_u32"></a>

## Macro function `pack_u32`

Pack a vector of <code>u32</code> into an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u32">pack_u32</a>&lt;$T&gt;($values: vector&lt;u32&gt;): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u32">pack_u32</a>&lt;$T&gt;($values: vector&lt;u32&gt;): $T {
    <b>let</b> <b>mut</b> values = $values;
    <b>let</b> <b>mut</b> v: $T = 0;
    <b>let</b> (<b>mut</b> i, len) = (0, values.length() <b>as</b> u8);
    values.reverse();
    <b>while</b> (i &lt; len) {
        v = v | (values.pop_back() <b>as</b> $T) &lt;&lt; (32 * i);
        i = i + 1;
    };
    v
}
</code></pre>



</details>

<a name="bit_field_bit_field_pack_u64"></a>

## Macro function `pack_u64`

Pack a vector of <code>u64</code> into an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u64">pack_u64</a>&lt;$T&gt;($values: vector&lt;u64&gt;): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_pack_u64">pack_u64</a>&lt;$T&gt;($values: vector&lt;u64&gt;): $T {
    <b>let</b> <b>mut</b> values = $values;
    <b>let</b> <b>mut</b> v: $T = 0;
    <b>let</b> (<b>mut</b> i, len) = (0, values.length() <b>as</b> u8);
    values.reverse();
    <b>while</b> (i &lt; len) {
        v = v | (values.pop_back() <b>as</b> $T) &lt;&lt; (64 * i);
        i = i + 1;
    };
    v
}
</code></pre>



</details>

<a name="bit_field_bit_field_unpack_bool"></a>

## Macro function `unpack_bool`

Unpack a vector of <code>bool</code> from an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_bool">unpack_bool</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;bool&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_bool">unpack_bool</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;bool&gt; {
    vector::tabulate!($size <b>as</b> u64, |i| (($v &gt;&gt; (i <b>as</b> u8)) & 1) == 1)
}
</code></pre>



</details>

<a name="bit_field_bit_field_unpack_u8"></a>

## Macro function `unpack_u8`

Unpack a vector of <code>u8</code> from an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u8">unpack_u8</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u8">unpack_u8</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u8&gt; {
    vector::tabulate!($size <b>as</b> u64, |i| ($v &gt;&gt; 8 * (i <b>as</b> u8) & 0xFF) <b>as</b> u8)
}
</code></pre>



</details>

<a name="bit_field_bit_field_unpack_u16"></a>

## Macro function `unpack_u16`

Unpack a vector of <code>u16</code> from an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u16">unpack_u16</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u16&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u16">unpack_u16</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u16&gt; {
    vector::tabulate!($size <b>as</b> u64, |i| ($v &gt;&gt; 16 * (i <b>as</b> u8) & 0xFFFF) <b>as</b> u16)
}
</code></pre>



</details>

<a name="bit_field_bit_field_unpack_u32"></a>

## Macro function `unpack_u32`

Unpack a vector of <code>u32</code> from an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u32">unpack_u32</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u32&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u32">unpack_u32</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u32&gt; {
    vector::tabulate!($size <b>as</b> u64, |i| ($v &gt;&gt; 32 * (i <b>as</b> u8) & 0xFFFFFFFF) <b>as</b> u32)
}
</code></pre>



</details>

<a name="bit_field_bit_field_unpack_u64"></a>

## Macro function `unpack_u64`

Unpack a vector of <code>u64</code> from an unsigned integer.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u64">unpack_u64</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u64&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_unpack_u64">unpack_u64</a>&lt;$T&gt;($v: $T, $size: u8): vector&lt;u64&gt; {
    vector::tabulate!($size <b>as</b> u64, |i| ($v &gt;&gt; 64 * (i <b>as</b> u8) & 0xFFFFFFFFFFFFFFFF) <b>as</b> u64)
}
</code></pre>



</details>

<a name="bit_field_bit_field_read_bool_at_offset"></a>

## Macro function `read_bool_at_offset`

Read a <code>bool</code> value at a specific offset.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_bool_at_offset">read_bool_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_bool_at_offset">read_bool_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): bool {
    (($v &gt;&gt; $offset) & 1) == 1
}
</code></pre>



</details>

<a name="bit_field_bit_field_read_u8_at_offset"></a>

## Macro function `read_u8_at_offset`

Read a <code>u8</code> value at a specific offset.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u8_at_offset">read_u8_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u8_at_offset">read_u8_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u8 {
    ($v &gt;&gt; 8 * $offset & 0xFF) <b>as</b> u8
}
</code></pre>



</details>

<a name="bit_field_bit_field_read_u16_at_offset"></a>

## Macro function `read_u16_at_offset`

Read a <code>u16</code> value at a specific offset.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u16_at_offset">read_u16_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u16_at_offset">read_u16_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u16 {
    ($v &gt;&gt; 16 * $offset & 0xFFFF) <b>as</b> u16
}
</code></pre>



</details>

<a name="bit_field_bit_field_read_u32_at_offset"></a>

## Macro function `read_u32_at_offset`

Read a <code>u32</code> value at a specific offset.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u32_at_offset">read_u32_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u32
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u32_at_offset">read_u32_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u32 {
    ($v &gt;&gt; 32 * $offset & 0xFFFFFFFF) <b>as</b> u32
}
</code></pre>



</details>

<a name="bit_field_bit_field_read_u64_at_offset"></a>

## Macro function `read_u64_at_offset`

Read a <code>u64</code> value at a specific offset.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u64_at_offset">read_u64_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../bit_field/bit_field.md#bit_field_bit_field_read_u64_at_offset">read_u64_at_offset</a>&lt;$T&gt;($v: $T, $offset: u8): u64 {
    ($v &gt;&gt; 64 * $offset & 0xFFFFFFFFFFFFFFFF) <b>as</b> u64
}
</code></pre>



</details>
