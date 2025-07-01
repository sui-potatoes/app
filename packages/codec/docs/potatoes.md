
<a name="codec_potatoes"></a>

# Module `codec::potatoes`

This encoding scheme is a twist on the classic HEX encoding, but instead of
using the standard HEX characters, it uses each of the 6 letters in the
"potatoes" word to represent each byte in Base16 past 9.


<a name="@Example_0"></a>

#### Example

```rust
use codec::potatoes;

let encoded = potatoes::encode(b"hello, potato!");
let decoded = potatoes::decode(encoded);

assert!(encoded == b"68656t6t6s2t20706s7461746s21".to_string());
assert!(decoded == b"hello, potato!");
```


        -  [Example](#@Example_0)
-  [Constants](#@Constants_1)
-  [Function `encode`](#codec_potatoes_encode)
-  [Function `decode`](#codec_potatoes_decode)
-  [Macro function `decode_byte`](#codec_potatoes_decode_byte)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_1"></a>

## Constants


<a name="codec_potatoes_EIncorrectNumberOfCharacters"></a>

Error code for incorrect number of characters.


<pre><code><b>const</b> <a href="../codec/potatoes.md#codec_potatoes_EIncorrectNumberOfCharacters">EIncorrectNumberOfCharacters</a>: u64 = 0;
</code></pre>



<a name="codec_potatoes_CHARACTER_SET"></a>

Each byte is encoded to one of these sub-characters.
Similar to the HEX encoding, but uses the word "POTAES" instead of "ABCDEF".


<pre><code><b>const</b> <a href="../codec/potatoes.md#codec_potatoes_CHARACTER_SET">CHARACTER_SET</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[48, 48], vector[48, 49], vector[48, 50], vector[48, 51], vector[48, 52], vector[48, 53], vector[48, 54], vector[48, 55], vector[48, 56], vector[48, 57], vector[48, 112], vector[48, 111], vector[48, 116], vector[48, 97], vector[48, 101], vector[48, 115], vector[49, 48], vector[49, 49], vector[49, 50], vector[49, 51], vector[49, 52], vector[49, 53], vector[49, 54], vector[49, 55], vector[49, 56], vector[49, 57], vector[49, 112], vector[49, 111], vector[49, 116], vector[49, 97], vector[49, 101], vector[49, 115], vector[50, 48], vector[50, 49], vector[50, 50], vector[50, 51], vector[50, 52], vector[50, 53], vector[50, 54], vector[50, 55], vector[50, 56], vector[50, 57], vector[50, 112], vector[50, 111], vector[50, 116], vector[50, 97], vector[50, 101], vector[50, 115], vector[51, 48], vector[51, 49], vector[51, 50], vector[51, 51], vector[51, 52], vector[51, 53], vector[51, 54], vector[51, 55], vector[51, 56], vector[51, 57], vector[51, 112], vector[51, 111], vector[51, 116], vector[51, 97], vector[51, 101], vector[51, 115], vector[52, 48], vector[52, 49], vector[52, 50], vector[52, 51], vector[52, 52], vector[52, 53], vector[52, 54], vector[52, 55], vector[52, 56], vector[52, 57], vector[52, 112], vector[52, 111], vector[52, 116], vector[52, 97], vector[52, 101], vector[52, 115], vector[53, 48], vector[53, 49], vector[53, 50], vector[53, 51], vector[53, 52], vector[53, 53], vector[53, 54], vector[53, 55], vector[53, 56], vector[53, 57], vector[53, 112], vector[53, 111], vector[53, 116], vector[53, 97], vector[53, 101], vector[53, 115], vector[54, 48], vector[54, 49], vector[54, 50], vector[54, 51], vector[54, 52], vector[54, 53], vector[54, 54], vector[54, 55], vector[54, 56], vector[54, 57], vector[54, 112], vector[54, 111], vector[54, 116], vector[54, 97], vector[54, 101], vector[54, 115], vector[55, 48], vector[55, 49], vector[55, 50], vector[55, 51], vector[55, 52], vector[55, 53], vector[55, 54], vector[55, 55], vector[55, 56], vector[55, 57], vector[55, 112], vector[55, 111], vector[55, 116], vector[55, 97], vector[55, 101], vector[55, 115], vector[56, 48], vector[56, 49], vector[56, 50], vector[56, 51], vector[56, 52], vector[56, 53], vector[56, 54], vector[56, 55], vector[56, 56], vector[56, 57], vector[56, 112], vector[56, 111], vector[56, 116], vector[56, 97], vector[56, 101], vector[56, 115], vector[57, 48], vector[57, 49], vector[57, 50], vector[57, 51], vector[57, 52], vector[57, 53], vector[57, 54], vector[57, 55], vector[57, 56], vector[57, 57], vector[57, 112], vector[57, 111], vector[57, 116], vector[57, 97], vector[57, 101], vector[57, 115], vector[112, 48], vector[112, 49], vector[112, 50], vector[112, 51], vector[112, 52], vector[112, 53], vector[112, 54], vector[112, 55], vector[112, 56], vector[112, 57], vector[112, 112], vector[112, 111], vector[112, 116], vector[112, 97], vector[112, 101], vector[112, 115], vector[111, 48], vector[111, 49], vector[111, 50], vector[111, 51], vector[111, 52], vector[111, 53], vector[111, 54], vector[111, 55], vector[111, 56], vector[111, 57], vector[111, 112], vector[111, 111], vector[111, 116], vector[111, 97], vector[111, 101], vector[111, 115], vector[116, 48], vector[116, 49], vector[116, 50], vector[116, 51], vector[116, 52], vector[116, 53], vector[116, 54], vector[116, 55], vector[116, 56], vector[116, 57], vector[116, 112], vector[116, 111], vector[116, 116], vector[116, 97], vector[116, 101], vector[116, 115], vector[97, 48], vector[97, 49], vector[97, 50], vector[97, 51], vector[97, 52], vector[97, 53], vector[97, 54], vector[97, 55], vector[97, 56], vector[97, 57], vector[97, 112], vector[97, 111], vector[97, 116], vector[97, 97], vector[97, 101], vector[97, 115], vector[101, 48], vector[101, 49], vector[101, 50], vector[101, 51], vector[101, 52], vector[101, 53], vector[101, 54], vector[101, 55], vector[101, 56], vector[101, 57], vector[101, 112], vector[101, 111], vector[101, 116], vector[101, 97], vector[101, 101], vector[101, 115], vector[115, 48], vector[115, 49], vector[115, 50], vector[115, 51], vector[115, 52], vector[115, 53], vector[115, 54], vector[115, 55], vector[115, 56], vector[115, 57], vector[115, 112], vector[115, 111], vector[115, 116], vector[115, 97], vector[115, 101], vector[115, 115]];
</code></pre>



<a name="codec_potatoes_encode"></a>

## Function `encode`

Now let's play with the encoding and decoding functions.


<pre><code><b>public</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_encode">encode</a>(bytes: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_encode">encode</a>(bytes: vector&lt;u8&gt;): String {
    <b>let</b> chars = <a href="../codec/potatoes.md#codec_potatoes_CHARACTER_SET">CHARACTER_SET</a>;
    <b>let</b> result = bytes.fold!(vector[], |<b>mut</b> acc, b| {
        acc.append(chars[b <b>as</b> u64]);
        acc
    });
    result.to_string()
}
</code></pre>



</details>

<a name="codec_potatoes_decode"></a>

## Function `decode`

Decode a potato-encoded string.
A,B,C,D,E,F is encoded as P,O,T,A,E,S


<pre><code><b>public</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_decode">decode</a>(str: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_decode">decode</a>(str: String): vector&lt;u8&gt; {
    <b>let</b> bytes = str.into_bytes();
    <b>let</b> (<b>mut</b> i, <b>mut</b> r, l) = (0, vector[], bytes.length());
    <b>assert</b>!(l % 2 == 0, <a href="../codec/potatoes.md#codec_potatoes_EIncorrectNumberOfCharacters">EIncorrectNumberOfCharacters</a>);
    <b>while</b> (i &lt; l) {
        <b>let</b> decimal = <a href="../codec/potatoes.md#codec_potatoes_decode_byte">decode_byte</a>!(bytes[i]) * 16 + <a href="../codec/potatoes.md#codec_potatoes_decode_byte">decode_byte</a>!(bytes[i + 1]);
        r.push_back(decimal);
        i = i + 2;
    };
    r
}
</code></pre>



</details>

<a name="codec_potatoes_decode_byte"></a>

## Macro function `decode_byte`



<pre><code><b>macro</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_decode_byte">decode_byte</a>($byte: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../codec/potatoes.md#codec_potatoes_decode_byte">decode_byte</a>($byte: u8): u8 {
    <b>let</b> byte = $byte;
    <b>if</b> (48 &lt;= byte && byte &lt; 58) byte - 48 // 0 .. 9
    <b>else</b> <b>if</b> (byte == 112 || byte == 80) 10 // p or P
    <b>else</b> <b>if</b> (byte == 111 || byte == 79) 11 // o or O
    <b>else</b> <b>if</b> (byte == 116 || byte == 84) 12 // t or T
    <b>else</b> <b>if</b> (byte == 97 || byte == 65) 13 // a or A
    <b>else</b> <b>if</b> (byte == 101 || byte == 69) 14 // e or E
    <b>else</b> <b>if</b> (byte == 115 || byte == 83) 15 // s or S
    <b>else</b> <b>abort</b> 1
}
</code></pre>



</details>
