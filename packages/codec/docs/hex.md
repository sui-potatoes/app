
<a name="codec_hex"></a>

# Module `codec::hex`

Proxies Base16 encoding library from the Sui Framework, but does it for
strings instead of bytes.


<a name="@Example_0"></a>

#### Example

```rust
use codec::hex;

let encoded = hex::encode(b"hello, potato!");
let decoded = hex::decode(encoded);

assert!(encoded == b"68656c6c6f2c20706f7461746f".to_string());
assert!(decoded == b"hello, potato!");
```


        -  [Example](#@Example_0)
-  [Function `encode`](#codec_hex_encode)
-  [Function `decode`](#codec_hex_decode)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="codec_hex_encode"></a>

## Function `encode`

Encode a string to hex format.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/hex.md#codec_hex_encode">encode</a>(bytes: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/hex.md#codec_hex_encode">encode</a>(bytes: vector&lt;u8&gt;): String {
    <a href="../codec/hex.md#codec_hex_encode">hex::encode</a>(bytes).to_string()
}
</code></pre>



</details>

<a name="codec_hex_decode"></a>

## Function `decode`

Decode a hex-encoded string.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/hex.md#codec_hex_decode">decode</a>(string: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/hex.md#codec_hex_decode">decode</a>(string: String): vector&lt;u8&gt; {
    <a href="../codec/hex.md#codec_hex_decode">hex::decode</a>(string.into_bytes())
}
</code></pre>



</details>
