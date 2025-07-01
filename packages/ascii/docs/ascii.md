
<a name="ascii_ascii"></a>

# Module `ascii::ascii`

Defines common ASCII utilities, including checks for printable and control
characters.

For checks on individual characters, see <code><a href="../ascii/char.md#ascii_char">ascii::char</a></code> and <code><a href="../ascii/control.md#ascii_control">ascii::control</a></code>.
While this module provides checks for bytes, its calls can be performed on
<code>String</code> or <code>vector&lt;u8&gt;</code> directly. See example below.

```rust
use ascii::char;
use ascii::ascii;

// Check if bytes are printable.
ascii::is_bytes_printable(b"Hello, world!");
b"Hello, world!".all!(|c| char::is_printable!(*c)); // alternative!

// Check if bytes are control characters.
ascii::is_bytes_control(b"\x00\x01");
b"\x00\x01".all!(|c| control::is_control!(*c)); // alternative!

// Check if bytes are extended characters.
ascii::is_bytes_extended(b"\xFA");
b"\xFA".all!(|c| extended::is_extended!(*c)); // alternative!
```


-  [Function `is_ascii`](#ascii_ascii_is_ascii)
-  [Function `is_bytes_printable`](#ascii_ascii_is_bytes_printable)
-  [Function `is_bytes_control`](#ascii_ascii_is_bytes_control)
-  [Function `is_bytes_extended`](#ascii_ascii_is_bytes_extended)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="ascii_ascii_is_ascii"></a>

## Function `is_ascii`

Check if a <code>String</code> is ASCII.


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_ascii">is_ascii</a>(s: &<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_ascii">is_ascii</a>(s: &String): bool {
    s.as_bytes().all!(|c| *c &gt;= 32 && *c &lt;= 127)
}
</code></pre>



</details>

<a name="ascii_ascii_is_bytes_printable"></a>

## Function `is_bytes_printable`

Check if bytes are printable.


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_printable">is_bytes_printable</a>(bytes: &vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_printable">is_bytes_printable</a>(bytes: &vector&lt;u8&gt;): bool {
    bytes.all!(|c| <a href="../ascii/char.md#ascii_char_is_printable">char::is_printable</a>!(*c))
}
</code></pre>



</details>

<a name="ascii_ascii_is_bytes_control"></a>

## Function `is_bytes_control`

Check if bytes are control characters.


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_control">is_bytes_control</a>(bytes: &vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_control">is_bytes_control</a>(bytes: &vector&lt;u8&gt;): bool {
    bytes.all!(|c| <a href="../ascii/control.md#ascii_control_is_control">control::is_control</a>!(*c))
}
</code></pre>



</details>

<a name="ascii_ascii_is_bytes_extended"></a>

## Function `is_bytes_extended`

Check if bytes are extended characters.


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_extended">is_bytes_extended</a>(bytes: &vector&lt;u8&gt;): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../ascii/ascii.md#ascii_ascii_is_bytes_extended">is_bytes_extended</a>(bytes: &vector&lt;u8&gt;): bool {
    bytes.all!(|c| <a href="../ascii/extended.md#ascii_extended_is_extended">extended::is_extended</a>!(*c))
}
</code></pre>



</details>
