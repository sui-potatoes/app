
<a name="codec_base64url"></a>

# Module `codec::base64url`

Modification of the base64 encoding which uses <code>-</code> and <code>_</code> instead of <code>+</code>
and <code>/</code>, and does not use padding.

See [RFC 4648; section 5](https://datatracker.ietf.org/doc/html/rfc4648#section-5)
for more details.


<a name="@Example_0"></a>

#### Example

```rust
use codec::base64url;

let encoded = base64url::encode(b"hello, potato!");
let decoded = base64url::decode(encoded);

assert!(encoded == b"aGVsbG8sIHBvdGF0byE".to_string());
assert!(decoded == b"hello, potato!");
```


        -  [Example](#@Example_0)
-  [Constants](#@Constants_1)
-  [Function `encode`](#codec_base64url_encode)
-  [Function `decode`](#codec_base64url_decode)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="codec_base64url_EIllegalCharacter"></a>

Error code for illegal character.


<pre><code><b>const</b> <a href="../codec/base64url.md#codec_base64url_EIllegalCharacter">EIllegalCharacter</a>: u64 = 0;
</code></pre>



<a name="codec_base64url_KEYS"></a>

Base64url keys


<pre><code><b>const</b> <a href="../codec/base64url.md#codec_base64url_KEYS">KEYS</a>: vector&lt;u8&gt; = vector[65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 45, 95];
</code></pre>



<a name="codec_base64url_encode"></a>

## Function `encode`

Encode the <code>bytes</code> into base64url String.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64url.md#codec_base64url_encode">encode</a>(bytes: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64url.md#codec_base64url_encode">encode</a>(bytes: vector&lt;u8&gt;): String {
    <a href="../codec/base64.md#codec_base64_encode_impl">base64::encode_impl</a>!(bytes, <a href="../codec/base64url.md#codec_base64url_KEYS">KEYS</a>, <b>true</b>)
}
</code></pre>



</details>

<a name="codec_base64url_decode"></a>

## Function `decode`

Decode the base64url <code>str</code> into bytes.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64url.md#codec_base64url_decode">decode</a>(str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/base64url.md#codec_base64url_decode">decode</a>(str: String): vector&lt;u8&gt; {
    <a href="../codec/base64.md#codec_base64_decode_impl">base64::decode_impl</a>!(str, <a href="../codec/base64url.md#codec_base64url_KEYS">KEYS</a>, <b>true</b>)
}
</code></pre>



</details>
