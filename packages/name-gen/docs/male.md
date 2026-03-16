
<a name="name_gen_male"></a>

# Module `name_gen::male`



-  [Constants](#@Constants_0)
-  [Function `select`](#name_gen_male_select)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="name_gen_male_BUCKET_0"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_0">BUCKET_0</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 98, 100, 117, 108], vector[65, 100, 105], vector[65, 117, 100, 105], vector[65, 103, 110, 101, 114], vector[65, 106, 97, 120], vector[65, 108, 97, 110], vector[65, 108, 121, 110], vector[65, 108, 116], vector[65, 108, 116, 111, 110], vector[65, 108, 116, 97, 105, 114]];
</code></pre>



<a name="name_gen_male_BUCKET_1"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_1">BUCKET_1</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 109, 112], vector[65, 112, 112, 108, 101], vector[65, 110, 100, 111, 110], vector[65, 110, 100, 121], vector[65, 110, 100, 114, 101, 119], vector[65, 110, 103], vector[65, 112, 112], vector[65, 114, 97, 120], vector[65, 114, 97, 107, 97, 110], vector[65, 107, 105, 114, 97]];
</code></pre>



<a name="name_gen_male_BUCKET_2"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_2">BUCKET_2</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 107, 105, 104, 101, 114, 111], vector[65, 107, 105, 104, 105, 107, 111], vector[65, 114, 105, 110], vector[65, 114, 112], vector[65, 115, 104], vector[65, 116, 115, 117, 115, 104, 105], vector[65, 116, 116, 111], vector[65, 117, 100, 105, 111], vector[65, 118, 105], vector[65, 120, 105, 115]];
</code></pre>



<a name="name_gen_male_BUCKET_3"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_3">BUCKET_3</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[66, 97, 116, 99, 104], vector[66, 97, 117, 100], vector[66, 97, 108, 117, 110], vector[66, 101, 97, 114], vector[66, 101, 110], vector[66, 101, 101, 112], vector[66, 105, 99], vector[66, 105, 110, 103], vector[66, 105, 116], vector[66, 108, 97, 100, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_4"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_4">BUCKET_4</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[66, 111, 97, 114, 100], vector[66, 111, 98], vector[66, 111, 111, 116], vector[66, 111, 116], vector[66, 111, 116, 97, 110], vector[66, 111, 120], vector[66, 117, 100, 100, 121], vector[66, 117, 103], vector[66, 117, 115], vector[66, 105, 102, 102]];
</code></pre>



<a name="name_gen_male_BUCKET_5"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_5">BUCKET_5</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[66, 105, 102, 102, 111], vector[66, 105, 103, 117, 110], vector[66, 105, 110, 103, 119, 101, 110], vector[66, 111], vector[66, 114, 121, 97, 110, 116], vector[66, 121, 116, 101], vector[67, 97, 109], vector[67, 97, 112], vector[67, 97, 115], vector[67, 97, 115, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_6"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_6">BUCKET_6</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 97, 100, 105, 117, 109], vector[67, 97, 100, 109, 105, 117, 109], vector[67, 97, 101, 108], vector[67, 97, 112], vector[67, 101, 108, 108], vector[67, 101, 114, 109, 101, 116], vector[67, 104, 97, 114, 108, 101, 115], vector[67, 104, 105, 112], vector[67, 104, 111, 110, 103, 108, 105, 110], vector[67, 104, 101, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_7"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_7">BUCKET_7</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 104, 111, 105], vector[67, 105, 112, 104, 101, 114], vector[67, 108, 97, 117, 100, 101], vector[67, 108, 105, 102, 102, 111, 114, 100], vector[67, 108, 111, 117, 100], vector[67, 108, 105, 99, 107], vector[67, 108, 105, 112], vector[67, 111, 100, 101, 99], vector[67, 111, 100, 101], vector[67, 111, 99, 111]];
</code></pre>



<a name="name_gen_male_BUCKET_8"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_8">BUCKET_8</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 111, 105, 108], vector[67, 111, 114, 100], vector[67, 114, 97, 115, 104], vector[67, 114, 111, 110], vector[67, 114, 121, 112, 116, 111], vector[67, 121, 98, 101, 114], vector[67, 121, 98, 111], vector[67, 121, 114, 105, 120], vector[67, 121, 107, 101], vector[67, 121, 107, 111]];
</code></pre>



<a name="name_gen_male_BUCKET_9"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_9">BUCKET_9</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[68, 97, 101, 109, 111, 110], vector[68, 97, 105], vector[68, 97, 114, 121, 108], vector[68, 97, 115, 104], vector[68, 97, 118, 105, 100], vector[68, 101, 103, 97, 117, 115, 115], vector[68, 101, 108], vector[68, 101, 108, 108], vector[68, 101, 108, 117, 110], vector[68, 101, 108, 98, 111, 121]];
</code></pre>



<a name="name_gen_male_BUCKET_10"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_10">BUCKET_10</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[68, 101, 109, 105, 110, 103], vector[68, 105, 103, 105, 116], vector[68, 105, 114, 107], vector[68, 105, 111, 100, 101], vector[68, 105, 110, 103], vector[68, 105, 110, 103, 100, 111, 110, 103], vector[68, 105, 110, 103, 98, 97, 110, 103], vector[68, 111, 110, 117, 116], vector[68, 111, 99, 107], vector[68, 111, 110, 107]];
</code></pre>



<a name="name_gen_male_BUCKET_11"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_11">BUCKET_11</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[68, 111, 110, 103], vector[68, 111, 109], vector[68, 111, 109, 100, 111, 109], vector[68, 111, 109, 109, 121], vector[68, 121, 107, 101, 114], vector[68, 111, 108, 108, 97, 114], vector[68, 121, 110, 101], vector[69, 100, 103, 97, 114], vector[69, 114, 114, 111, 114], vector[69, 110, 108, 97, 105]];
</code></pre>



<a name="name_gen_male_BUCKET_12"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_12">BUCKET_12</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[69, 110, 111], vector[69, 105, 107, 111], vector[69, 108, 100, 111, 110], vector[70, 97, 120], vector[70, 97], vector[70, 97, 105], vector[70, 97, 114], vector[70, 97, 114, 119, 97, 110, 103], vector[70, 108, 97, 115, 104], vector[70, 114, 97, 103]];
</code></pre>



<a name="name_gen_male_BUCKET_13"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_13">BUCKET_13</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[70, 114, 97, 103, 109, 101, 105, 115, 116, 101, 114], vector[70, 114, 97, 103, 109, 97, 110], vector[70, 117], vector[71, 97, 110], vector[71, 97, 102, 102], vector[71, 97, 102, 102, 97], vector[71, 97, 102, 102, 97, 99, 97, 107, 101], vector[71, 108, 105, 116, 99, 104], vector[71, 108, 105, 116, 99, 104, 109, 97, 110], vector[71, 108, 101, 110, 106, 97, 109, 105, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_14"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_14">BUCKET_14</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[71, 101, 110, 103, 104, 105, 115], vector[71, 111, 114, 116], vector[71, 114, 97, 109], vector[71, 114, 101, 112], vector[71, 114, 105, 100], vector[71, 114, 105, 116], vector[71, 117, 97, 110, 103], vector[71, 117, 111, 108, 105, 97, 110, 103], vector[71, 117, 111, 119, 101, 105], vector[71, 117, 111, 122, 104, 105]];
</code></pre>



<a name="name_gen_male_BUCKET_15"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_15">BUCKET_15</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[71, 117, 121], vector[71, 117, 121, 98, 114, 117, 115, 104], vector[72, 97, 105], vector[72, 97, 110], vector[72, 97, 110, 115], vector[72, 97, 110, 110, 105, 98, 97, 108], vector[72, 97, 115, 104], vector[72, 101, 99, 116, 111], vector[72, 117, 98], vector[72, 117, 100]];
</code></pre>



<a name="name_gen_male_BUCKET_16"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_16">BUCKET_16</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[72, 111], vector[72, 111, 104, 111], vector[72, 111, 110, 103], vector[72, 111, 119, 105, 101], vector[72, 111, 119, 105, 110], vector[72, 117], vector[72, 117, 105], vector[72, 117, 110, 103], vector[73, 115, 97, 97, 99], vector[73, 110, 100, 105, 103, 111]];
</code></pre>



<a name="name_gen_male_BUCKET_17"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_17">BUCKET_17</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[74, 97, 99, 107], vector[74, 97, 120], vector[74, 97, 110, 107], vector[74, 97, 110, 103, 111], vector[74, 105, 110, 120], vector[74, 105, 97, 110, 103], vector[74, 105, 110], vector[74, 105, 110, 103], vector[74, 105, 110, 103, 104, 97, 105], vector[74, 111, 104, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_18"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_18">BUCKET_18</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[74, 111, 104, 110, 106, 111, 104, 110], vector[74, 111, 106, 111], vector[74, 111, 104, 110, 110, 121], vector[82, 111, 110, 115, 101, 97, 108], vector[83, 105, 108, 105, 99, 111, 110], vector[83, 112, 105, 100, 101, 114], vector[83, 112, 105, 122, 122, 111], vector[83, 116, 114, 111, 98, 101], vector[75, 97, 105, 115, 101, 114], vector[75, 97, 105, 122, 101, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_19"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_19">BUCKET_19</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[75, 97, 110, 101, 100, 97], vector[75, 97, 110, 103], vector[75, 105, 108, 111], vector[75, 114, 105, 122], vector[75, 121], vector[75, 121, 108, 101], vector[75, 121, 108, 111], vector[75, 97, 100, 101], vector[75, 110, 111, 120], vector[75, 105, 114, 111, 110, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_20"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_20">BUCKET_20</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[75, 105, 100], vector[75, 101, 105], vector[76, 97, 110], vector[76, 108, 97, 110], vector[76, 97, 114, 114, 121], vector[76, 101, 111], vector[76, 101, 101], vector[76, 101, 111, 110], vector[76, 101, 111, 110, 97, 114, 100], vector[76, 101, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_21"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_21">BUCKET_21</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[76, 101, 110, 110, 121], vector[76, 101, 111, 110, 97, 114, 100, 111], vector[76, 105, 110, 107], vector[76, 105, 116, 104, 105, 117, 109], vector[76, 105], vector[76, 105, 110, 103], vector[76, 111], vector[76, 111, 99, 107], vector[76, 111, 111, 116], vector[76, 121, 110, 120]];
</code></pre>



<a name="name_gen_male_BUCKET_22"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_22">BUCKET_22</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[76, 121, 110, 107], vector[77, 97, 99], vector[77, 97, 115, 97, 114, 117], vector[77, 97, 115, 97, 116, 111], vector[77, 97, 115, 111, 116, 111], vector[77, 97, 115, 97, 108, 97], vector[77, 105, 99], vector[77, 105, 107, 101], vector[77, 105, 108, 101, 115], vector[77, 105, 110, 103]];
</code></pre>



<a name="name_gen_male_BUCKET_23"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_23">BUCKET_23</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[77, 105, 110, 103, 108, 105], vector[77, 105, 110, 122, 104, 101], vector[77, 46, 77], vector[77, 111, 100], vector[77, 111, 114, 116, 105, 109, 101, 114], vector[77, 121, 108, 97, 114], vector[78, 97, 110, 111], vector[78, 97, 110, 100, 101, 122], vector[78, 97, 116, 101], vector[78, 101, 111]];
</code></pre>



<a name="name_gen_male_BUCKET_24"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_24">BUCKET_24</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[78, 101, 111, 110], vector[78, 111, 118, 97], vector[78, 111, 107, 105, 97], vector[78, 105, 97, 110, 100, 101, 114], vector[78, 105, 107, 101], vector[78, 101, 122, 117], vector[78, 117, 116], vector[79, 98, 101, 114, 111, 110], vector[79, 110, 121, 120], vector[79, 114, 105, 111, 110]];
</code></pre>



<a name="name_gen_male_BUCKET_25"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_25">BUCKET_25</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[79, 115, 115, 111, 110], vector[79, 116, 116, 111], vector[80, 97, 116, 99, 104], vector[80, 104, 97, 115, 101], vector[80, 97, 114, 97, 100, 111, 120], vector[80, 104, 111, 101, 110, 105, 120], vector[80, 105, 110, 101], vector[80, 105, 101, 122, 111], vector[80, 105, 110, 103], vector[80, 105, 110, 103, 117]];
</code></pre>



<a name="name_gen_male_BUCKET_26"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_26">BUCKET_26</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[80, 108, 117, 116, 111, 110], vector[80, 114, 111, 116, 111], vector[80, 101, 110, 103], vector[80, 117, 108, 115, 101], vector[81, 117, 97, 100], vector[81, 117, 97, 105, 108], vector[81, 117, 97, 100, 101], vector[81, 117, 97, 105, 100], vector[81, 117, 97, 110], vector[82, 97, 99, 107]];
</code></pre>



<a name="name_gen_male_BUCKET_27"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_27">BUCKET_27</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[82, 97, 100, 105, 97, 110], vector[82, 97, 100, 105, 117, 115], vector[82, 97, 121], vector[82, 97, 122, 101], vector[82, 101, 120, 120], vector[82, 101, 110], vector[82, 101, 110, 115, 104, 117], vector[82, 111, 98, 98, 121], vector[82, 111, 109], vector[82, 105, 99, 107]];
</code></pre>



<a name="name_gen_male_BUCKET_28"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_28">BUCKET_28</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[82, 105, 107], vector[82, 105, 112], vector[82, 111, 110], vector[82, 111, 117, 116, 101, 114], vector[82, 111, 121], vector[82, 121, 101], vector[82, 121, 111], vector[82, 121, 117, 107], vector[82, 117], vector[82, 117, 115, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_29"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_29">BUCKET_29</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[82, 117, 115, 104], vector[82, 111, 99, 107, 101, 116], vector[82, 121, 107, 101, 114], vector[83, 107, 105, 112], vector[83, 108, 97, 103], vector[83, 111, 110, 110, 121], vector[83, 104, 101, 110], vector[83, 116, 97, 99, 107], vector[83, 116, 101, 112, 104, 101, 110], vector[83, 121, 107, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_30"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_30">BUCKET_30</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[83, 105, 107, 101], vector[83, 114, 105, 107, 101], vector[83, 105, 107, 101], vector[83, 116, 114, 121, 107, 101, 114], vector[83, 117, 112, 101, 114, 104, 97, 110, 115], vector[83, 121, 110, 99, 104], vector[83, 121, 110, 99, 104, 114, 111], vector[84, 97, 103], vector[84, 97, 102, 102], vector[84, 97, 102, 102, 121]];
</code></pre>



<a name="name_gen_male_BUCKET_31"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_31">BUCKET_31</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[84, 101, 116, 115, 117, 111], vector[84, 104, 114, 101, 97, 100], vector[84, 104, 111, 109, 97, 115], vector[84, 104, 117, 110, 107], vector[84, 104, 121, 114, 105, 115, 116, 111, 114], vector[84, 114, 97, 99, 107], vector[84, 114, 111, 121], vector[84, 117, 112, 108, 101], vector[84, 117, 114, 98, 111], vector[84, 117, 114, 98, 111, 116, 97, 120]];
</code></pre>



<a name="name_gen_male_BUCKET_32"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_32">BUCKET_32</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[86, 97, 120], vector[86, 97, 120, 101, 110], vector[86, 101, 99, 116, 111, 114], vector[86, 101, 114, 105, 122, 111, 110], vector[86, 111, 120, 101, 108], vector[87, 101, 98], vector[87, 101, 100, 103, 101], vector[87, 105, 114, 101], vector[89, 117, 107, 105, 109, 97, 115, 97], vector[89, 111, 115, 117, 107, 101]];
</code></pre>



<a name="name_gen_male_BUCKET_33"></a>



<pre><code><b>const</b> <a href="./male.md#name_gen_male_BUCKET_33">BUCKET_33</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[90, 101, 114, 111], vector[90, 105, 110, 99], vector[90, 105, 112, 112, 111], vector[90, 101, 100], vector[90, 105, 112]];
</code></pre>



<a name="name_gen_male_select"></a>

## Function `select`



<pre><code><b>public</b>(package) <b>fun</b> <a href="./male.md#name_gen_male_select">select</a>(num: u16): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./male.md#name_gen_male_select">select</a>(num: u16): String {
    <b>let</b> bucket_idx = num % 34;
    <b>let</b> bucket = match (bucket_idx) {
        0 =&gt; <a href="./male.md#name_gen_male_BUCKET_0">BUCKET_0</a>,
        1 =&gt; <a href="./male.md#name_gen_male_BUCKET_1">BUCKET_1</a>,
        2 =&gt; <a href="./male.md#name_gen_male_BUCKET_2">BUCKET_2</a>,
        3 =&gt; <a href="./male.md#name_gen_male_BUCKET_3">BUCKET_3</a>,
        4 =&gt; <a href="./male.md#name_gen_male_BUCKET_4">BUCKET_4</a>,
        5 =&gt; <a href="./male.md#name_gen_male_BUCKET_5">BUCKET_5</a>,
        6 =&gt; <a href="./male.md#name_gen_male_BUCKET_6">BUCKET_6</a>,
        7 =&gt; <a href="./male.md#name_gen_male_BUCKET_7">BUCKET_7</a>,
        8 =&gt; <a href="./male.md#name_gen_male_BUCKET_8">BUCKET_8</a>,
        9 =&gt; <a href="./male.md#name_gen_male_BUCKET_9">BUCKET_9</a>,
        10 =&gt; <a href="./male.md#name_gen_male_BUCKET_10">BUCKET_10</a>,
        11 =&gt; <a href="./male.md#name_gen_male_BUCKET_11">BUCKET_11</a>,
        12 =&gt; <a href="./male.md#name_gen_male_BUCKET_12">BUCKET_12</a>,
        13 =&gt; <a href="./male.md#name_gen_male_BUCKET_13">BUCKET_13</a>,
        14 =&gt; <a href="./male.md#name_gen_male_BUCKET_14">BUCKET_14</a>,
        15 =&gt; <a href="./male.md#name_gen_male_BUCKET_15">BUCKET_15</a>,
        16 =&gt; <a href="./male.md#name_gen_male_BUCKET_16">BUCKET_16</a>,
        17 =&gt; <a href="./male.md#name_gen_male_BUCKET_17">BUCKET_17</a>,
        18 =&gt; <a href="./male.md#name_gen_male_BUCKET_18">BUCKET_18</a>,
        19 =&gt; <a href="./male.md#name_gen_male_BUCKET_19">BUCKET_19</a>,
        20 =&gt; <a href="./male.md#name_gen_male_BUCKET_20">BUCKET_20</a>,
        21 =&gt; <a href="./male.md#name_gen_male_BUCKET_21">BUCKET_21</a>,
        22 =&gt; <a href="./male.md#name_gen_male_BUCKET_22">BUCKET_22</a>,
        23 =&gt; <a href="./male.md#name_gen_male_BUCKET_23">BUCKET_23</a>,
        24 =&gt; <a href="./male.md#name_gen_male_BUCKET_24">BUCKET_24</a>,
        25 =&gt; <a href="./male.md#name_gen_male_BUCKET_25">BUCKET_25</a>,
        26 =&gt; <a href="./male.md#name_gen_male_BUCKET_26">BUCKET_26</a>,
        27 =&gt; <a href="./male.md#name_gen_male_BUCKET_27">BUCKET_27</a>,
        28 =&gt; <a href="./male.md#name_gen_male_BUCKET_28">BUCKET_28</a>,
        29 =&gt; <a href="./male.md#name_gen_male_BUCKET_29">BUCKET_29</a>,
        30 =&gt; <a href="./male.md#name_gen_male_BUCKET_30">BUCKET_30</a>,
        31 =&gt; <a href="./male.md#name_gen_male_BUCKET_31">BUCKET_31</a>,
        32 =&gt; <a href="./male.md#name_gen_male_BUCKET_32">BUCKET_32</a>,
        33 =&gt; <a href="./male.md#name_gen_male_BUCKET_33">BUCKET_33</a>,
        _ =&gt; <b>abort</b>,
    };
    <b>let</b> index = (num <b>as</b> u64 % bucket.length());
    bucket[index].to_string()
}
</code></pre>



</details>
