
<a name="codec_hex"></a>

# Module `codec::hex`

Implements base16 (hex) encoding and decoding.


<a name="@Example_0"></a>

#### Example

```rust
use codec::hex;

let encoded = hex::encode("hello, potato!");
let decoded = hex::decode(encoded);

assert!(encoded == "68656c6c6f2c20706f7461746f");
assert!(decoded == "hello, potato!");
```


        -  [Example](#@Example_0)
-  [Constants](#@Constants_1)
-  [Function `encode`](#codec_hex_encode)
-  [Function `decode`](#codec_hex_decode)
-  [Function `decode_byte`](#codec_hex_decode_byte)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="codec_hex_EIncorrectNumberOfCharacters"></a>



<pre><code><b>const</b> <a href="./hex.md#codec_hex_EIncorrectNumberOfCharacters">EIncorrectNumberOfCharacters</a>: u64 = 0;
</code></pre>



<a name="codec_hex_ENotValidHexCharacter"></a>



<pre><code><b>const</b> <a href="./hex.md#codec_hex_ENotValidHexCharacter">ENotValidHexCharacter</a>: u64 = 1;
</code></pre>



<a name="codec_hex_CHARACTER_SET"></a>

Each byte is encoded to one of these sub-characters.


<pre><code><b>const</b> <a href="./hex.md#codec_hex_CHARACTER_SET">CHARACTER_SET</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[48, 48], vector[48, 49], vector[48, 50], vector[48, 51], vector[48, 52], vector[48, 53], vector[48, 54], vector[48, 55], vector[48, 56], vector[48, 57], vector[48, 97], vector[48, 98], vector[48, 99], vector[48, 100], vector[48, 101], vector[48, 102], vector[49, 48], vector[49, 49], vector[49, 50], vector[49, 51], vector[49, 52], vector[49, 53], vector[49, 54], vector[49, 55], vector[49, 56], vector[49, 57], vector[49, 97], vector[49, 98], vector[49, 99], vector[49, 100], vector[49, 101], vector[49, 102], vector[50, 48], vector[50, 49], vector[50, 50], vector[50, 51], vector[50, 52], vector[50, 53], vector[50, 54], vector[50, 55], vector[50, 56], vector[50, 57], vector[50, 97], vector[50, 98], vector[50, 99], vector[50, 100], vector[50, 101], vector[50, 102], vector[51, 48], vector[51, 49], vector[51, 50], vector[51, 51], vector[51, 52], vector[51, 53], vector[51, 54], vector[51, 55], vector[51, 56], vector[51, 57], vector[51, 97], vector[51, 98], vector[51, 99], vector[51, 100], vector[51, 101], vector[51, 102], vector[52, 48], vector[52, 49], vector[52, 50], vector[52, 51], vector[52, 52], vector[52, 53], vector[52, 54], vector[52, 55], vector[52, 56], vector[52, 57], vector[52, 97], vector[52, 98], vector[52, 99], vector[52, 100], vector[52, 101], vector[52, 102], vector[53, 48], vector[53, 49], vector[53, 50], vector[53, 51], vector[53, 52], vector[53, 53], vector[53, 54], vector[53, 55], vector[53, 56], vector[53, 57], vector[53, 97], vector[53, 98], vector[53, 99], vector[53, 100], vector[53, 101], vector[53, 102], vector[54, 48], vector[54, 49], vector[54, 50], vector[54, 51], vector[54, 52], vector[54, 53], vector[54, 54], vector[54, 55], vector[54, 56], vector[54, 57], vector[54, 97], vector[54, 98], vector[54, 99], vector[54, 100], vector[54, 101], vector[54, 102], vector[55, 48], vector[55, 49], vector[55, 50], vector[55, 51], vector[55, 52], vector[55, 53], vector[55, 54], vector[55, 55], vector[55, 56], vector[55, 57], vector[55, 97], vector[55, 98], vector[55, 99], vector[55, 100], vector[55, 101], vector[55, 102], vector[56, 48], vector[56, 49], vector[56, 50], vector[56, 51], vector[56, 52], vector[56, 53], vector[56, 54], vector[56, 55], vector[56, 56], vector[56, 57], vector[56, 97], vector[56, 98], vector[56, 99], vector[56, 100], vector[56, 101], vector[56, 102], vector[57, 48], vector[57, 49], vector[57, 50], vector[57, 51], vector[57, 52], vector[57, 53], vector[57, 54], vector[57, 55], vector[57, 56], vector[57, 57], vector[57, 97], vector[57, 98], vector[57, 99], vector[57, 100], vector[57, 101], vector[57, 102], vector[97, 48], vector[97, 49], vector[97, 50], vector[97, 51], vector[97, 52], vector[97, 53], vector[97, 54], vector[97, 55], vector[97, 56], vector[97, 57], vector[97, 97], vector[97, 98], vector[97, 99], vector[97, 100], vector[97, 101], vector[97, 102], vector[98, 48], vector[98, 49], vector[98, 50], vector[98, 51], vector[98, 52], vector[98, 53], vector[98, 54], vector[98, 55], vector[98, 56], vector[98, 57], vector[98, 97], vector[98, 98], vector[98, 99], vector[98, 100], vector[98, 101], vector[98, 102], vector[99, 48], vector[99, 49], vector[99, 50], vector[99, 51], vector[99, 52], vector[99, 53], vector[99, 54], vector[99, 55], vector[99, 56], vector[99, 57], vector[99, 97], vector[99, 98], vector[99, 99], vector[99, 100], vector[99, 101], vector[99, 102], vector[100, 48], vector[100, 49], vector[100, 50], vector[100, 51], vector[100, 52], vector[100, 53], vector[100, 54], vector[100, 55], vector[100, 56], vector[100, 57], vector[100, 97], vector[100, 98], vector[100, 99], vector[100, 100], vector[100, 101], vector[100, 102], vector[101, 48], vector[101, 49], vector[101, 50], vector[101, 51], vector[101, 52], vector[101, 53], vector[101, 54], vector[101, 55], vector[101, 56], vector[101, 57], vector[101, 97], vector[101, 98], vector[101, 99], vector[101, 100], vector[101, 101], vector[101, 102], vector[102, 48], vector[102, 49], vector[102, 50], vector[102, 51], vector[102, 52], vector[102, 53], vector[102, 54], vector[102, 55], vector[102, 56], vector[102, 57], vector[102, 97], vector[102, 98], vector[102, 99], vector[102, 100], vector[102, 101], vector[102, 102]];
</code></pre>



<a name="codec_hex_encode"></a>

## Function `encode`

Encode a string to hex format.


<pre><code><b>public</b> <b>fun</b> <a href="./hex.md#codec_hex_encode">encode</a>(bytes: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./hex.md#codec_hex_encode">encode</a>(bytes: vector&lt;u8&gt;): String {
    <b>let</b> chars = <a href="./hex.md#codec_hex_CHARACTER_SET">CHARACTER_SET</a>;
    <b>let</b> <b>mut</b> r = vector[];
    bytes.length().do!(|i| r.append(chars[bytes[i] <b>as</b> u64]));
    r.to_string()
}
</code></pre>



</details>

<a name="codec_hex_decode"></a>

## Function `decode`

Decode a hex-encoded string.


<pre><code><b>public</b> <b>fun</b> <a href="./hex.md#codec_hex_decode">decode</a>(str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./hex.md#codec_hex_decode">decode</a>(str: String): vector&lt;u8&gt; {
    <b>let</b> bytes = str.into_bytes();
    <b>let</b> (<b>mut</b> i, <b>mut</b> r, l) = (0, vector[], bytes.length());
    <b>assert</b>!(l % 2 == 0, <a href="./hex.md#codec_hex_EIncorrectNumberOfCharacters">EIncorrectNumberOfCharacters</a>);
    <b>while</b> (i &lt; l) {
        <b>let</b> decimal = <a href="./hex.md#codec_hex_decode_byte">decode_byte</a>(bytes[i]) * 16 + <a href="./hex.md#codec_hex_decode_byte">decode_byte</a>(bytes[i + 1]);
        r.push_back(decimal);
        i = i + 2;
    };
    r
}
</code></pre>



</details>

<a name="codec_hex_decode_byte"></a>

## Function `decode_byte`



<pre><code><b>fun</b> <a href="./hex.md#codec_hex_decode_byte">decode_byte</a>(byte: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./hex.md#codec_hex_decode_byte">decode_byte</a>(byte: u8): u8 {
    // <b>let</b> byte = $byte;
    <b>if</b> (char::zero!() &lt;= byte && byte &lt;= char::nine!()) byte - char::zero!()
    <b>else</b> <b>if</b> (char::A!() &lt;= byte && byte &lt;= char::F!()) 10 + byte - char::A!()
    <b>else</b> <b>if</b> (char::a!() &lt;= byte && byte &lt;= char::f!()) 10 + byte - char::a!()
    <b>else</b> <b>abort</b> <a href="./hex.md#codec_hex_ENotValidHexCharacter">ENotValidHexCharacter</a>
}
</code></pre>



</details>
