
<a name="(format=0x0)_format"></a>

# Module `(format=0x0)::format`

Implementation of the <code><a href="./format.md#(format=0x0)_format">format</a>!</code> macro in Move. Fills the template with the
given values, using the <code>{}</code> syntax.


-  [Constants](#@Constants_0)
-  [Function `format`](#(format=0x0)_format_format)
-  [Macro function `dbg`](#(format=0x0)_format_dbg)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="(format=0x0)_format_EIndicesLengthMismatch"></a>



<pre><code><b>const</b> <a href="./format.md#(format=0x0)_format_EIndicesLengthMismatch">EIndicesLengthMismatch</a>: u64 = 0;
</code></pre>



<a name="(format=0x0)_format_format"></a>

## Function `format`

Format a string with the given values. Similar to <code><a href="./format.md#(format=0x0)_format">format</a>!</code> in Rust.

Example:
```
let result = format(b"Hello, {}! It's good to see you, {}!", vector[
b"John".to_string(),
b"Jane".to_string(),
]);

assert!(result == b"Hello, John! It's good to see you, Jane!".to_string());
```


<pre><code><b>public</b> <b>fun</b> <a href="./format.md#(format=0x0)_format">format</a>(template: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, values: vector&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./format.md#(format=0x0)_format">format</a>(template: String, values: vector&lt;String&gt;): String {
    <b>let</b> (t, v) = (template, values);
    <b>let</b> <b>mut</b> indices = vector[];
    <b>let</b> len = t.length();
    <b>let</b> v_len = v.length();
    <b>let</b> bytes = t.as_bytes();
    // early <b>return</b> <b>if</b> the values are empty
    <b>if</b> (v_len == 0) <b>return</b> template;
    // push all the indices of the braces, so we can reference them
    // their number must match the length of `v`
    0u64.range_do!(
        len - 1,
        |i| <b>if</b> (bytes[i] == char::left_brace!() && bytes[i + 1] == char::right_brace!()) {
            indices.push_back(i);
        },
    );
    // enforce the <b>invariant</b>
    <b>assert</b>!(v_len == indices.length(), <a href="./format.md#(format=0x0)_format_EIndicesLengthMismatch">EIndicesLengthMismatch</a>);
    // now construct the string `s`
    <b>let</b> t = t;
    <b>let</b> <b>mut</b> s = b"".to_string();
    <b>let</b> <b>mut</b> offset = 0;
    // iterate over the indices, and concat substrings
    indices.length().do!(|i| {
        s.append(t.substring(offset, indices[i]));
        s.append(v[i]);
        offset = indices[i] + 2;
    });
    s
}
</code></pre>



</details>

<a name="(format=0x0)_format_dbg"></a>

## Macro function `dbg`

Test-only function to print the values to the stdout. Inner call to
<code>debug::print</code> cannot be published.

Named <code><a href="./format.md#(format=0x0)_format_dbg">dbg</a></code> to make it shorter (compared to <code><a href="./format.md#(format=0x0)_format">format</a></code>).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./format.md#(format=0x0)_format_dbg">dbg</a>($template: vector&lt;u8&gt;, $values: vector&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./format.md#(format=0x0)_format_dbg">dbg</a>($template: vector&lt;u8&gt;, $values: vector&lt;String&gt;) {
    <b>let</b> t = $template;
    <a href="../../.doc-deps/std/debug.md#std_debug_print">std::debug::print</a>(&<a href="./format.md#(format=0x0)_format">format</a>(t.to_string(), $values));
}
</code></pre>



</details>
