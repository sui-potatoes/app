
<a name="(svg=0x0)_print"></a>

# Module `(svg=0x0)::print`

Implements tag printing for any XML elements. This is a base utility used by
most of the types in this library.


-  [Function `print`](#(svg=0x0)_print_print)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_print_print"></a>

## Function `print`

Prints a generic SVG element, with attributes and elements. Rarely should be
used directly, given that each type in this library has its own <code>to_string</code>.

In case custom XML elements are needed for <code>Custom(String)</code> nodes, here is
an example of usage:

```rust
// for double tags <code>&lt;a&gt;Link contents&lt;/a&gt;</code>
let printed = svg::print::print(
b"a".to_string(), // element name
vec_map::empty(), // VecMap of attributes
option::some(vector[ b"Link contents".to_string() ]), // Option<vector<String>> of elements
);

// for single tag <code>&lt;br /&gt;</code>
let printed = svg::print::print(
b"br".to_string(), // element name
vec_map::empty(), // VecMap of attributes
option::none(), // empty option for single tags
);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/print.md#(svg=0x0)_print">print</a>(name: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, attributes: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;, elements: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/print.md#(svg=0x0)_print">print</a>(
    name: String,
    attributes: VecMap&lt;String, String&gt;,
    elements: Option&lt;vector&lt;String&gt;&gt;,
): String {
    <b>let</b> <b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg">svg</a> = b"&lt;".to_string();
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(name);
    <b>let</b> (keys, values) = attributes.into_keys_values();
    <b>let</b> length = keys.length();
    <b>if</b> (length &gt; 0) <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b" ".to_string());
    length.do!(|i| {
        <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(keys[i]);
        <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b"='".to_string());
        <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(values[i]);
        <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(<b>if</b> (i &lt; length - 1) { b"' " } <b>else</b> { b"'" }.to_string());
    });
    <b>if</b> (elements.is_none()) {
        <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b"/&gt;".to_string());
        <b>return</b> <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>
    };
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b"&gt;".to_string());
    elements.do!(|vec| vec.do!(|el| <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(el)));
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b"&lt;/".to_string());
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(name);
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.append(b"&gt;".to_string());
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>
}
</code></pre>



</details>
