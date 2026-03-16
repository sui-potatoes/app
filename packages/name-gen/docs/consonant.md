
<a name="name_gen_consonant"></a>

# Module `name_gen::consonant`



-  [Constants](#@Constants_0)
-  [Function `select`](#name_gen_consonant_select)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="name_gen_consonant_CONSONANTS"></a>



<pre><code><b>const</b> <a href="./consonant.md#name_gen_consonant_CONSONANTS">CONSONANTS</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[66], vector[66, 114], vector[67], vector[67, 114], vector[68], vector[70], vector[71], vector[72], vector[74], vector[74, 97, 100], vector[75], vector[75, 114], vector[76], vector[77], vector[78], vector[80], vector[80, 114], vector[81, 117], vector[82], vector[83], vector[83, 114], vector[83, 116], vector[83, 112], vector[84], vector[84, 114], vector[86], vector[87], vector[87, 114], vector[89], vector[90]];
</code></pre>



<a name="name_gen_consonant_POST_CONSONANT"></a>



<pre><code><b>const</b> <a href="./consonant.md#name_gen_consonant_POST_CONSONANT">POST_CONSONANT</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[97, 110, 115, 111, 110], vector[117, 114, 116, 111, 110], vector[111, 110, 105, 99], vector[97, 108, 108], vector[97, 99, 107, 101, 114], vector[97, 98, 97, 110], vector[97, 100, 101, 110], vector[97, 114, 107], vector[98, 114, 111, 117, 103, 104], vector[101, 121, 111, 117, 110], vector[101, 108, 108], vector[101, 108, 108, 105, 115], vector[101, 100, 101, 120], vector[101, 116, 109, 101, 114], vector[97, 116, 101, 115], vector[105, 100, 101, 109, 97, 110], vector[121, 108, 101, 114], vector[105, 108, 108, 121], vector[105, 108, 108, 105, 117, 109, 115, 111, 110], vector[111, 97, 110], vector[111, 115, 116, 111, 118], vector[111, 108, 111, 116, 111, 118], vector[111, 122, 104, 101, 110, 107, 111], vector[111, 115, 115], vector[111, 109, 109], vector[105, 107, 101, 114], vector[105, 107], vector[97, 108, 108, 105, 115, 116, 101, 114], vector[111, 110, 115, 111, 110], vector[111, 103, 97, 119, 97], vector[117, 108, 97, 110], vector[117, 114, 115, 111, 114]];
</code></pre>



<a name="name_gen_consonant_select"></a>

## Function `select`



<pre><code><b>public</b>(package) <b>fun</b> <a href="./consonant.md#name_gen_consonant_select">select</a>(num: u8, num_2: u8): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./consonant.md#name_gen_consonant_select">select</a>(num: u8, num_2: u8): String {
    <b>let</b> <a href="./consonant.md#name_gen_consonant">consonant</a> = (num % 30) <b>as</b> u64;
    <b>let</b> post_consonant = (num_2 % 30) <b>as</b> u64;
    <b>let</b> <b>mut</b> <a href="./last_name.md#name_gen_last_name">last_name</a> = <a href="./consonant.md#name_gen_consonant_CONSONANTS">CONSONANTS</a>[<a href="./consonant.md#name_gen_consonant">consonant</a>].to_string();
    <a href="./last_name.md#name_gen_last_name">last_name</a>.append_utf8(<a href="./consonant.md#name_gen_consonant_POST_CONSONANT">POST_CONSONANT</a>[post_consonant]);
    <a href="./last_name.md#name_gen_last_name">last_name</a>
}
</code></pre>



</details>
