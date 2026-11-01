
<a name="codec_urlencode"></a>

# Module `codec::urlencode`

Implements URL encoding and decoding.
Can operate on UTF8 strings, encoding only ASCII characters.


<a name="@Example_0"></a>

#### Example

```rust
use codec::urlencode;

let encoded = urlencode::encode("hello, potato!");
let decoded = urlencode::decode(encoded);

assert!(encoded == "hello%2C%20potato%21");
assert!(decoded == "hello, potato!");
```


        -  [Example](#@Example_0)
-  [Function `encode`](#codec_urlencode_encode)
-  [Function `decode`](#codec_urlencode_decode)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="codec_urlencode_encode"></a>

## Function `encode`

Encode a string into URL format. Supports non-printable characters, takes
a vector of bytes as input. This function is safe to use with UTF8 strings.


<pre><code><b>public</b> <b>fun</b> <a href="./urlencode.md#codec_urlencode_encode">encode</a>(string: vector&lt;u8&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./urlencode.md#codec_urlencode_encode">encode</a>(string: vector&lt;u8&gt;): String {
    <b>let</b> <b>mut</b> res = vector[];
    string.do!(|c| {
        // 32 = space
        <b>if</b> (c == char::space!()) {
            res.push_back(char::percent!()); // %
            res.push_back(char::two!()); // 2
            res.push_back(char::zero!()); // 0
        } <b>else</b> <b>if</b> (
            (c &lt; char::zero!() || c &gt; char::nine!())
            && (c &lt; char::A!() || c &gt; char::Z!())
            && (c &lt; char::a!() || c &gt; char::z!())
        ) {
            res.push_back(char::percent!()); // %
            res.push_back((c / 16) + <b>if</b> (c / 16 &lt; 10) char::zero!() <b>else</b> char::seven!());
            res.push_back((c % 16) + <b>if</b> (c % 16 &lt; 10) char::zero!() <b>else</b> char::seven!());
        } <b>else</b> {
            res.push_back(c);
        }
    });
    res.to_string()
}
</code></pre>



</details>

<a name="codec_urlencode_decode"></a>

## Function `decode`

Decode a URL-encoded string.
Supports legacy <code>+</code> encoding for spaces.


<pre><code><b>public</b> <b>fun</b> <a href="./urlencode.md#codec_urlencode_decode">decode</a>(s: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./urlencode.md#codec_urlencode_decode">decode</a>(s: String): vector&lt;u8&gt; {
    <b>let</b> <b>mut</b> res = vector[];
    <b>let</b> <b>mut</b> bytes = s.into_bytes();
    <b>let</b> <b>mut</b> len = bytes.length();
    bytes.reverse();
    <b>while</b> (len &gt; 0) {
        match (bytes.pop_back()) {
            // plus "+"
            43 =&gt; {
                len = len - 1;
                res.push_back(32)
            },
            // percent "%"
            37 =&gt; {
                len = len - 3;
                <b>let</b> a = bytes.pop_back();
                <b>let</b> b = bytes.pop_back();
                <b>let</b> a = <b>if</b> (a &gt;= char::A!()) a - char::seven!() <b>else</b> a - char::zero!();
                <b>let</b> b = <b>if</b> (b &gt;= char::A!()) b - char::seven!() <b>else</b> b - char::zero!();
                res.push_back(a * 16 + b)
            },
            // regular ASCII character
            c @ _ =&gt; {
                len = len - 1;
                res.push_back(c)
            },
        }
    };
    res
}
</code></pre>



</details>
