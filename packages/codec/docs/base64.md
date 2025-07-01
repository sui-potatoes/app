
<a name="codec_base64"></a>

# Module `codec::base64`

Implements Base64 encoding.
See [RFC 4648; Section 4](https://datatracker.ietf.org/doc/html/rfc4648#section-4) for more details.


<a name="@Example_0"></a>

#### Example

```rust
use codec::base64;

let encoded = base64::encode(b"hello, potato!");
let decoded = base64::decode(encoded);

assert!(encoded == b"aGVsbG8sIHBvdGF0byE=".to_string());
assert!(decoded == b"hello, potato!");
```


        -  [Example](#@Example_0)
-  [Constants](#@Constants_1)
-  [Function `encode`](#codec_base64_encode)
-  [Function `decode`](#codec_base64_decode)
-  [Macro function `encode_impl`](#codec_base64_encode_impl)
-  [Macro function `decode_impl`](#codec_base64_decode_impl)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="codec_base64_EIllegalCharacter"></a>

Error code for illegal character.


<pre><code><b>const</b> <a href="../codec/base64.md#codec_base64_EIllegalCharacter">EIllegalCharacter</a>: u64 = 0;
</code></pre>



<a name="codec_base64_EIncorrectNumberOfCharacters"></a>

Error code for incorrect number of characters.


<pre><code><b>const</b> <a href="../codec/base64.md#codec_base64_EIncorrectNumberOfCharacters">EIncorrectNumberOfCharacters</a>: u64 = 1;
</code></pre>



<a name="codec_base64_KEYS"></a>

Dictionary for base64 encoding.


<pre><code><b>const</b> <a href="../codec/base64.md#codec_base64_KEYS">KEYS</a>: vector&lt;u8&gt; = vector[65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 43, 47, 61];
</code></pre>



<a name="codec_base64_encode"></a>

## Function `encode`

Encode the <code>bytes</code> into base64 String.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_encode">encode</a>(bytes: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_encode">encode</a>(bytes: vector&lt;u8&gt;): String {
    <a href="../codec/base64.md#codec_base64_encode_impl">encode_impl</a>!(bytes, <a href="../codec/base64.md#codec_base64_KEYS">KEYS</a>, <b>false</b>)
}
</code></pre>



</details>

<a name="codec_base64_decode"></a>

## Function `decode`

Decode the base64 <code>str</code>.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_decode">decode</a>(str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_decode">decode</a>(str: String): vector&lt;u8&gt; {
    <a href="../codec/base64.md#codec_base64_decode_impl">decode_impl</a>!(str, <a href="../codec/base64.md#codec_base64_KEYS">KEYS</a>, <b>false</b>)
}
</code></pre>



</details>

<a name="codec_base64_encode_impl"></a>

## Macro function `encode_impl`

Internal macro for base64-based encodings, allows to use different dictionaries
and control padding.


<pre><code><b>public</b>(package) <b>macro</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_encode_impl">encode_impl</a>($bytes: vector&lt;u8&gt;, $dictionary: vector&lt;u8&gt;, $url_safe: bool): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>macro</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_encode_impl">encode_impl</a>(
    $bytes: vector&lt;u8&gt;,
    $dictionary: vector&lt;u8&gt;,
    $url_safe: bool,
): String {
    <b>let</b> <b>mut</b> bytes = $bytes;
    <b>let</b> keys = $dictionary;
    <b>let</b> <b>mut</b> res = vector[];
    <b>let</b> <b>mut</b> len = bytes.length();
    bytes.reverse();
    <b>while</b> (len &gt; 0) {
        <b>let</b> <b>mut</b> count = 1;
        <b>let</b> b1 = bytes.pop_back();
        <b>let</b> b2 = <b>if</b> (len &gt; 1) { count = count + 1; bytes.pop_back() } <b>else</b> 0;
        <b>let</b> b3 = <b>if</b> (len &gt; 2) { count = count + 1; bytes.pop_back() } <b>else</b> 0;
        <b>let</b> c1 = b1 &gt;&gt; 2;
        <b>let</b> c2 = ((b1 & 3) &lt;&lt; 4) | (b2 &gt;&gt; 4);
        <b>let</b> c3 = <b>if</b> (count &lt; 2) 64 <b>else</b> ((b2 & 15) &lt;&lt; 2) | (b3 &gt;&gt; 6);
        <b>let</b> c4 = <b>if</b> (count &lt; 3) 64 <b>else</b> b3 & 63;
        res.push_back(keys[c1 <b>as</b> u64]);
        res.push_back(keys[c2 <b>as</b> u64]);
        <b>if</b> (!$url_safe || c3 != 64) res.push_back(keys[c3 <b>as</b> u64]);
        <b>if</b> (!$url_safe || c4 != 64) res.push_back(keys[c4 <b>as</b> u64]);
        len = len - count;
    };
    res.to_string()
}
</code></pre>



</details>

<a name="codec_base64_decode_impl"></a>

## Macro function `decode_impl`

Internal macro for base64-based decodings, allows to use different dictionaries
and control padding (for url-safe encoding).


<pre><code><b>public</b>(package) <b>macro</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_decode_impl">decode_impl</a>($str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, $dictionary: vector&lt;u8&gt;, $url_safe: bool): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>macro</b> <b>fun</b> <a href="../codec/base64.md#codec_base64_decode_impl">decode_impl</a>(
    $str: String,
    $dictionary: vector&lt;u8&gt;,
    $url_safe: bool,
): vector&lt;u8&gt; {
    <b>let</b> keys = $dictionary;
    <b>let</b> str = $str;
    <b>let</b> <b>mut</b> res = vector[];
    // Ensure the length is a multiple of 4.
    <b>if</b> (!$url_safe) <b>assert</b>!(str.length() % 4 == 0, 1);
    <b>let</b> <b>mut</b> buffer = 0u32;
    <b>let</b> <b>mut</b> bits_collected = 0;
    str.into_bytes().do!(|byte| {
        <b>if</b> (byte == 61) <b>return</b>; // ascii <b>for</b> '='
        <b>let</b> (res1, val) = keys.index_of(&byte);
        <b>assert</b>!(res1, 0);
        buffer = (buffer &lt;&lt; 6) | (val <b>as</b> u32);
        bits_collected = bits_collected + 6;
        <b>if</b> (bits_collected &gt;= 8) {
            bits_collected = bits_collected - 8;
            <b>let</b> byte = (buffer &gt;&gt; bits_collected) & 0xFF;
            res.push_back(byte <b>as</b> u8);
        }
    });
    res
}
</code></pre>



</details>
