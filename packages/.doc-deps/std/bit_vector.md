
<a name="std_bit_vector"></a>

# Module `std::bit_vector`



-  [Struct `BitVector`](#std_bit_vector_BitVector)
-  [Constants](#@Constants_0)
-  [Function `new`](#std_bit_vector_new)
-  [Function `set`](#std_bit_vector_set)
-  [Function `unset`](#std_bit_vector_unset)
-  [Function `shift_left`](#std_bit_vector_shift_left)
-  [Function `is_index_set`](#std_bit_vector_is_index_set)
-  [Function `length`](#std_bit_vector_length)
-  [Function `longest_set_sequence_starting_at`](#std_bit_vector_longest_set_sequence_starting_at)


<pre><code></code></pre>



<a name="std_bit_vector_BitVector"></a>

## Struct `BitVector`



<pre><code><b>public</b> <b>struct</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>: u64</code>
</dt>
<dd>
</dd>
<dt>
<code>bit_field: vector&lt;bool&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="std_bit_vector_EINDEX"></a>

The provided index is out of bounds


<pre><code><b>const</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_EINDEX">EINDEX</a>: u64 = 131072;
</code></pre>



<a name="std_bit_vector_ELENGTH"></a>

An invalid length of bitvector was given


<pre><code><b>const</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_ELENGTH">ELENGTH</a>: u64 = 131073;
</code></pre>



<a name="std_bit_vector_WORD_SIZE"></a>



<pre><code><b>const</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_WORD_SIZE">WORD_SIZE</a>: u64 = 1;
</code></pre>



<a name="std_bit_vector_MAX_SIZE"></a>

The maximum allowed bitvector size


<pre><code><b>const</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_MAX_SIZE">MAX_SIZE</a>: u64 = 1024;
</code></pre>



<a name="std_bit_vector_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_new">new</a>(<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>: u64): <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_new">new</a>(<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>: u64): <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a> {
    <b>assert</b>!(<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a> &gt; 0, <a href="../../dependencies/std/bit_vector.md#std_bit_vector_ELENGTH">ELENGTH</a>);
    <b>assert</b>!(<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a> &lt; <a href="../../dependencies/std/bit_vector.md#std_bit_vector_MAX_SIZE">MAX_SIZE</a>, <a href="../../dependencies/std/bit_vector.md#std_bit_vector_ELENGTH">ELENGTH</a>);
    <b>let</b> <b>mut</b> counter = 0;
    <b>let</b> <b>mut</b> bit_field = vector::empty();
    <b>while</b> (counter &lt; <a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>) {
        bit_field.push_back(<b>false</b>);
        counter = counter + 1;
    };
    <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a> {
        <a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>,
        bit_field,
    }
}
</code></pre>



</details>

<a name="std_bit_vector_set"></a>

## Function `set`

Set the bit at <code>bit_index</code> in the <code>bitvector</code> regardless of its previous state.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_set">set</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>, bit_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_set">set</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>, bit_index: u64) {
    <b>assert</b>!(bit_index &lt; bitvector.bit_field.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>(), <a href="../../dependencies/std/bit_vector.md#std_bit_vector_EINDEX">EINDEX</a>);
    <b>let</b> x = &<b>mut</b> bitvector.bit_field[bit_index];
    *x = <b>true</b>;
}
</code></pre>



</details>

<a name="std_bit_vector_unset"></a>

## Function `unset`

Unset the bit at <code>bit_index</code> in the <code>bitvector</code> regardless of its previous state.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_unset">unset</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>, bit_index: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_unset">unset</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>, bit_index: u64) {
    <b>assert</b>!(bit_index &lt; bitvector.bit_field.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>(), <a href="../../dependencies/std/bit_vector.md#std_bit_vector_EINDEX">EINDEX</a>);
    <b>let</b> x = &<b>mut</b> bitvector.bit_field[bit_index];
    *x = <b>false</b>;
}
</code></pre>



</details>

<a name="std_bit_vector_shift_left"></a>

## Function `shift_left`

Shift the <code>bitvector</code> left by <code>amount</code>. If <code>amount</code> is greater than the
bitvector's length the bitvector will be zeroed out.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_shift_left">shift_left</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>, amount: u64)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_shift_left">shift_left</a>(bitvector: &<b>mut</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>, amount: u64) {
    <b>if</b> (amount &gt;= bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>) {
        <b>let</b> len = bitvector.bit_field.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>();
        <b>let</b> <b>mut</b> i = 0;
        <b>while</b> (i &lt; len) {
            <b>let</b> elem = &<b>mut</b> bitvector.bit_field[i];
            *elem = <b>false</b>;
            i = i + 1;
        };
    } <b>else</b> {
        <b>let</b> <b>mut</b> i = amount;
        <b>while</b> (i &lt; bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>) {
            <b>if</b> (bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_is_index_set">is_index_set</a>(i)) bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_set">set</a>(i - amount)
            <b>else</b> bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_unset">unset</a>(i - amount);
            i = i + 1;
        };
        i = bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a> - amount;
        <b>while</b> (i &lt; bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>) {
            <a href="../../dependencies/std/bit_vector.md#std_bit_vector_unset">unset</a>(bitvector, i);
            i = i + 1;
        };
    }
}
</code></pre>



</details>

<a name="std_bit_vector_is_index_set"></a>

## Function `is_index_set`

Return the value of the bit at <code>bit_index</code> in the <code>bitvector</code>. <code><b>true</b></code>
represents "1" and <code><b>false</b></code> represents a 0


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_is_index_set">is_index_set</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>, bit_index: u64): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_is_index_set">is_index_set</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>, bit_index: u64): bool {
    <b>assert</b>!(bit_index &lt; bitvector.bit_field.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>(), <a href="../../dependencies/std/bit_vector.md#std_bit_vector_EINDEX">EINDEX</a>);
    bitvector.bit_field[bit_index]
}
</code></pre>



</details>

<a name="std_bit_vector_length"></a>

## Function `length`

Return the length (number of usable bits) of this bitvector


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>): u64 {
    bitvector.bit_field.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>()
}
</code></pre>



</details>

<a name="std_bit_vector_longest_set_sequence_starting_at"></a>

## Function `longest_set_sequence_starting_at`

Returns the length of the longest sequence of set bits starting at (and
including) <code>start_index</code> in the <code>bitvector</code>. If there is no such
sequence, then <code>0</code> is returned.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_longest_set_sequence_starting_at">longest_set_sequence_starting_at</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">std::bit_vector::BitVector</a>, start_index: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/std/bit_vector.md#std_bit_vector_longest_set_sequence_starting_at">longest_set_sequence_starting_at</a>(bitvector: &<a href="../../dependencies/std/bit_vector.md#std_bit_vector_BitVector">BitVector</a>, start_index: u64): u64 {
    <b>assert</b>!(start_index &lt; bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>, <a href="../../dependencies/std/bit_vector.md#std_bit_vector_EINDEX">EINDEX</a>);
    <b>let</b> <b>mut</b> index = start_index;
    // Find the greatest index in the vector such that all indices less than it are <a href="../../dependencies/std/bit_vector.md#std_bit_vector_set">set</a>.
    <b>while</b> (index &lt; bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_length">length</a>) {
        <b>if</b> (!bitvector.<a href="../../dependencies/std/bit_vector.md#std_bit_vector_is_index_set">is_index_set</a>(index)) <b>break</b>;
        index = index + 1;
    };
    index - start_index
}
</code></pre>



</details>
