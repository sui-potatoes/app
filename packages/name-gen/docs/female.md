
<a name="name_gen_female"></a>

# Module `name_gen::female`



-  [Constants](#@Constants_0)
-  [Function `select`](#name_gen_female_select)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="@Constants_0"></a>

## Constants


<a name="name_gen_female_BUCKET_0"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_0">BUCKET_0</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 101, 108, 97], vector[65, 100, 105], vector[65, 104, 110], vector[65, 110, 97], vector[65, 110, 100, 114, 111, 109, 101, 100, 97], vector[65, 110, 110, 105, 97], vector[65, 110, 100, 114, 97], vector[65, 112, 111, 99, 104], vector[65, 105], vector[65, 105, 109, 105]];
</code></pre>



<a name="name_gen_female_BUCKET_1"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_1">BUCKET_1</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 114, 105, 101, 115], vector[65, 115, 116, 97], vector[65, 115, 116, 114, 97], vector[65, 115, 116, 114, 105, 97], vector[65, 116, 115, 117], vector[65, 118, 97], vector[65, 118, 97, 108, 111, 110], vector[65, 117, 114, 111, 114, 97], vector[65, 118, 101, 115], vector[65, 121, 108, 111]];
</code></pre>



<a name="name_gen_female_BUCKET_2"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_2">BUCKET_2</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 100, 97], vector[65, 100, 100, 121], vector[65, 104, 32, 67, 121], vector[65, 104, 32, 75, 117, 109], vector[65, 104, 32, 76, 97, 109], vector[65, 105, 103, 117, 111], vector[65, 107, 105], vector[65, 107, 105, 107, 111], vector[65, 107, 105, 110, 97], vector[65, 107, 105, 114, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_3"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_3">BUCKET_3</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 108, 101, 120, 97], vector[65, 108, 112, 104, 97], vector[65, 108, 118, 97], vector[65, 109, 105], vector[65, 109, 97, 114, 101, 116, 116, 111], vector[65, 109, 97, 114, 97, 116, 115, 117], vector[65, 109, 97, 114, 116, 101, 114, 97, 115, 117], vector[65, 109, 97, 121, 97], vector[65, 109, 105, 100, 97], vector[65, 109, 105, 100, 97, 108, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_4"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_4">BUCKET_4</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 109, 105, 103, 97], vector[65, 110, 103, 101, 108], vector[65, 110, 105], vector[65, 110], vector[65, 110, 110], vector[65, 110, 103, 101, 108, 97], vector[65, 110, 105, 116, 97], vector[65, 108, 105, 116, 97], vector[65, 110, 110, 97], vector[65, 110, 116, 105, 107, 121, 116, 104, 101, 114, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_5"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_5">BUCKET_5</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[65, 112, 111, 103, 101, 101], vector[65, 115, 97], vector[65, 115, 97, 109, 105], vector[65, 118, 97], vector[65, 121, 97, 107, 97], vector[65, 121, 97, 107, 111], vector[65, 121, 99, 101, 101], vector[65, 121, 118, 101, 101], vector[65, 122, 101, 114, 116, 121], vector[66, 97, 111]];
</code></pre>



<a name="name_gen_female_BUCKET_6"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_6">BUCKET_6</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[66, 101, 101, 112], vector[66, 101, 116, 116, 121], vector[66, 101, 116], vector[66, 105, 116], vector[66, 105, 121, 117], vector[66, 105, 106, 117], vector[66, 108, 121, 116, 104, 101], vector[66, 105, 114, 100, 105, 101], vector[66, 108, 111, 111, 109], vector[66, 117, 110, 107, 111]];
</code></pre>



<a name="name_gen_female_BUCKET_7"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_7">BUCKET_7</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 97, 109], vector[67, 97, 109, 101, 114, 111, 110], vector[67, 97, 110, 100, 101, 108, 97], vector[67, 97, 112, 105], vector[67, 97, 116], vector[67, 97, 108, 108, 105], vector[67, 97, 108, 108, 97], vector[67, 97, 108, 121, 112, 115, 111], vector[67, 97, 115, 101], vector[67, 97, 115, 115]];
</code></pre>



<a name="name_gen_female_BUCKET_8"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_8">BUCKET_8</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 101, 114, 101, 115], vector[67, 108, 97, 114, 101], vector[67, 97, 116, 97, 108, 105, 110, 97], vector[67, 111, 114, 111, 110, 97], vector[67, 108, 101, 111], vector[67, 108, 101, 97], vector[67, 111, 115, 109, 105, 110, 97], vector[67, 111, 115, 109, 105, 97], vector[67, 111, 115, 105, 109, 97], vector[67, 97, 116, 104, 111, 100, 101]];
</code></pre>



<a name="name_gen_female_BUCKET_9"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_9">BUCKET_9</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 101, 101, 100, 101, 101], vector[67, 101, 110, 116, 114, 97], vector[67, 104, 97, 115, 115, 105, 115], vector[67, 104, 97, 110, 103], vector[67, 104, 97, 110, 103, 99, 104, 97, 110, 103], vector[67, 104, 97, 110, 103, 121, 105, 110, 103], vector[67, 104, 105, 107, 97], vector[67, 104, 105, 107, 97, 107, 111], vector[67, 104, 105, 110, 97], vector[67, 104, 105, 122, 111]];
</code></pre>



<a name="name_gen_female_BUCKET_10"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_10">BUCKET_10</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[67, 104, 105, 122, 117], vector[67, 104, 121, 110, 97], vector[67, 104, 111], vector[67, 104, 117], vector[67, 104, 121, 117], vector[67, 111, 109, 109, 97], vector[67, 111, 111, 107, 105, 101], vector[67, 111, 114, 100, 121], vector[67, 114, 121, 115, 116, 97, 108], vector[67, 121, 98, 101, 114, 110, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_11"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_11">BUCKET_11</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[68, 97, 105, 115, 121], vector[68, 97, 105, 121, 117], vector[68, 101, 99, 105], vector[68, 101, 101, 118, 101, 101], vector[68, 101, 110], vector[68, 101, 108, 112, 104, 105, 110, 101], vector[68, 101, 108, 112, 104, 105, 110, 97], vector[68, 111, 116], vector[68, 111, 110, 103], vector[68, 111, 110, 103, 109, 101, 105]];
</code></pre>



<a name="name_gen_female_BUCKET_12"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_12">BUCKET_12</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[68, 121, 110, 97], vector[69, 105, 115, 97], vector[69, 108, 115, 97], vector[69, 108, 108, 105, 111], vector[69, 109], vector[69, 109, 98, 101, 114], vector[69, 109, 105, 107, 111], vector[69, 109, 105, 108, 121], vector[69, 108, 101, 99, 116, 114, 97], vector[69, 112, 111, 120, 121]];
</code></pre>



<a name="name_gen_female_BUCKET_13"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_13">BUCKET_13</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[69, 118, 101], vector[69, 118, 101, 108, 121, 110], vector[69, 120, 97], vector[70, 97, 110, 103], vector[70, 97, 110, 103, 116, 97, 115, 116, 105, 99], vector[70, 97, 110, 103, 115], vector[70, 114, 97, 110, 99, 101, 115], vector[70, 97, 114, 114, 97, 104], vector[70, 97, 119, 107, 101], vector[70, 97, 108, 105, 100, 97, 101]];
</code></pre>



<a name="name_gen_female_BUCKET_14"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_14">BUCKET_14</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[70, 114, 101, 121, 97], vector[70, 114, 101, 121, 115, 97], vector[70, 114, 111, 115, 116], vector[70, 117, 116, 117, 114, 97], vector[71, 97, 109, 109, 97], vector[71, 97, 98, 114, 105, 101, 108, 108, 97], vector[71, 97, 105], vector[71, 101, 114, 116, 121], vector[71, 101, 114, 105], vector[71, 101, 110, 101, 115, 105, 115]];
</code></pre>



<a name="name_gen_female_BUCKET_15"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_15">BUCKET_15</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[71, 101, 110, 101, 118, 97], vector[71, 101, 110, 106, 105], vector[71, 101, 118, 105, 101], vector[71, 114, 97, 122, 101], vector[71, 105, 101, 108, 108, 101], vector[71, 111, 108, 100, 97], vector[71, 114, 97, 99, 101], vector[72, 97, 108, 111], vector[72, 97, 99, 107], vector[72, 97, 120]];
</code></pre>



<a name="name_gen_female_BUCKET_16"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_16">BUCKET_16</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[72, 97, 118, 101, 110], vector[72, 101, 108, 118, 101, 116, 105, 99, 97], vector[72, 105, 110, 103, 101], vector[72, 117, 110], vector[72, 101, 108], vector[72, 101, 100, 121], vector[72, 111, 110, 103], vector[72, 117, 97], vector[72, 117, 105, 108, 97, 110, 103], vector[73, 100, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_17"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_17">BUCKET_17</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[73, 110, 102, 105, 110, 105, 116, 121], vector[73, 111], vector[73, 114, 105, 115], vector[74, 97, 110], vector[74, 97, 110, 101, 116], vector[74, 97, 103, 111], vector[74, 97, 121], vector[74, 97, 118, 97], vector[74, 117, 110, 111], vector[74, 101, 97, 110]];
</code></pre>



<a name="name_gen_female_BUCKET_18"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_18">BUCKET_18</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[74, 101, 114, 105], vector[74, 105, 97], vector[74, 105, 97, 111], vector[74, 105, 110, 120], vector[74, 111, 108, 105, 101, 116], vector[74, 111, 105], vector[74, 111, 121], vector[74, 117, 97, 110], vector[75, 97, 116, 117, 115, 104, 97], vector[75, 97, 116, 104, 108, 101, 101, 110]];
</code></pre>



<a name="name_gen_female_BUCKET_19"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_19">BUCKET_19</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[75, 97, 121], vector[75, 97, 116, 101], vector[75, 97, 108, 97], vector[75, 97, 108, 101], vector[75, 97, 105], vector[75, 105, 98, 105], vector[75, 105, 114, 97], vector[75, 105, 107, 97], vector[75, 105, 121, 111, 107, 111], vector[76, 97, 110]];
</code></pre>



<a name="name_gen_female_BUCKET_20"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_20">BUCKET_20</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[76, 97, 114, 97], vector[76, 97, 117, 114, 97], vector[76, 97, 114, 112], vector[76, 101, 103, 97, 99, 121], vector[76, 101, 108, 97], vector[76, 101, 101, 108, 111, 111], vector[76, 101, 120, 105, 101], vector[76, 117, 110, 97], vector[76, 117, 110, 97, 114], vector[76, 117, 118]];
</code></pre>



<a name="name_gen_female_BUCKET_21"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_21">BUCKET_21</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[76, 97, 105, 110], vector[76, 105, 98, 98, 121], vector[76, 105, 101, 110], vector[76, 97, 100, 121], vector[76, 117, 99, 105, 97], vector[76, 117, 120], vector[76, 105, 108, 108, 121], vector[76, 105, 108, 108, 105, 120], vector[76, 105, 110], vector[76, 105, 117]];
</code></pre>



<a name="name_gen_female_BUCKET_22"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_22">BUCKET_22</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[76, 97, 121, 97], vector[76, 111, 111], vector[76, 111, 111, 116], vector[76, 111], vector[76, 121, 110, 120], vector[76, 105, 110, 107], vector[76, 105, 110, 103], vector[76, 121, 110, 110], vector[77, 97, 101], vector[77, 97, 105]];
</code></pre>



<a name="name_gen_female_BUCKET_23"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_23">BUCKET_23</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[77, 97, 121], vector[77, 97, 114, 108, 121, 110], vector[77, 97, 103, 100, 97], vector[77, 101, 100, 105, 97], vector[77, 97, 114, 105, 97], vector[77, 97, 114, 105, 101, 116, 116, 101], vector[77, 101, 108, 105, 115, 115, 97], vector[77, 101, 116, 97], vector[77, 105, 99, 97], vector[77, 105, 108, 108, 105]];
</code></pre>



<a name="name_gen_female_BUCKET_24"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_24">BUCKET_24</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[77, 105, 109], vector[77, 111, 108, 108, 121], vector[77, 97, 121, 98, 101, 108, 108, 105, 110, 101], vector[77, 111, 97, 110, 110, 97], vector[77, 111, 115, 101, 108, 108, 97], vector[77, 111, 120, 105, 101], vector[78, 105, 107, 111, 108, 97], vector[78, 105, 107, 107, 105], vector[78, 105, 110, 103], vector[78, 117, 105]];
</code></pre>



<a name="name_gen_female_BUCKET_25"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_25">BUCKET_25</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[78, 101, 118, 101], vector[78, 111, 118, 97], vector[78, 111, 111, 110, 97], vector[78, 121, 97], vector[78, 121, 120], vector[79, 114, 105], vector[79, 114, 105, 97], vector[79, 114, 105, 97, 110, 97], vector[79, 114, 103, 97, 110, 105, 97], vector[79, 114, 105, 111, 110]];
</code></pre>



<a name="name_gen_female_BUCKET_26"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_26">BUCKET_26</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[79, 115, 115, 111, 110], vector[80, 97, 114, 105, 116, 121], vector[80, 97, 114, 97, 100, 111, 120], vector[80, 97, 114, 114, 105, 115], vector[80, 105, 110, 101], vector[80, 105, 112], vector[80, 114, 105, 115], vector[80, 114, 105, 115, 115, 121], vector[80, 101, 114, 105, 103, 101, 101], vector[80, 101, 114, 108]];
</code></pre>



<a name="name_gen_female_BUCKET_27"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_27">BUCKET_27</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[80, 105, 120, 105, 101], vector[80, 108, 97, 115, 109, 97], vector[80, 108, 105, 110, 107], vector[80, 111, 108, 121], vector[80, 101, 97, 99, 104], vector[80, 114, 111, 120, 121], vector[81, 119, 101, 114, 116, 121], vector[81, 117, 101, 101, 110], vector[82, 97, 100, 105, 117, 115], vector[82, 97, 122, 101]];
</code></pre>



<a name="name_gen_female_BUCKET_28"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_28">BUCKET_28</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[82, 101, 120, 120], vector[82, 111, 120, 120, 121], vector[82, 105, 112, 108, 101, 121], vector[82, 105, 110, 97], vector[82, 111, 98, 101, 114, 116, 97], vector[82, 97, 100, 105, 97], vector[82, 97, 105, 110], vector[82, 101, 102, 117, 114, 98], vector[82, 101, 108, 97, 121], vector[82, 111, 115, 101, 116, 116, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_29"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_29">BUCKET_29</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[82, 111, 115, 105, 101], vector[82, 117, 98, 121], vector[82, 117, 98, 105], vector[82, 117, 116, 104], vector[82, 117, 115, 116], vector[83, 97, 109, 115, 117, 110, 103], vector[83, 97, 116, 97], vector[83, 97, 114, 97], vector[83, 105, 108, 105, 99, 97], vector[83, 105, 109, 117, 108, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_30"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_30">BUCKET_30</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[83, 104, 97, 121], vector[83, 104, 97, 121, 108, 101, 97], vector[83, 111, 112, 104, 105, 101], vector[83, 111, 110, 121], vector[83, 112, 114, 105, 116, 101], vector[83, 116, 97, 114], vector[83, 121, 110, 101, 114, 103, 121], vector[84, 97, 111], vector[84, 97, 102, 102, 105], vector[84, 101, 109, 112, 108, 97, 116, 101]];
</code></pre>



<a name="name_gen_female_BUCKET_31"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_31">BUCKET_31</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[84, 101, 114, 97], vector[84, 101, 116, 114, 97], vector[84, 105, 102, 102], vector[84, 105, 108, 100, 101], vector[84, 105, 110, 103], vector[84, 111, 110, 105], vector[84, 114, 105, 110, 105, 116, 121], vector[84, 114, 105, 110, 105, 116, 105], vector[84, 114, 105, 110, 105], vector[84, 114, 105, 110, 110, 121]];
</code></pre>



<a name="name_gen_female_BUCKET_32"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_32">BUCKET_32</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[85, 109, 97], vector[85, 110, 97], vector[86, 97, 115, 97], vector[86, 101, 101, 107, 97, 121], vector[86, 101, 114, 111, 110, 105, 99, 97], vector[86, 105, 114, 97], vector[87, 105, 108, 108, 97, 109, 101, 116, 116, 101], vector[87, 105, 110, 105, 102, 114, 101, 100], vector[89, 111, 116, 116, 97], vector[90, 101, 116, 116, 97]];
</code></pre>



<a name="name_gen_female_BUCKET_33"></a>



<pre><code><b>const</b> <a href="./female.md#name_gen_female_BUCKET_33">BUCKET_33</a>: vector&lt;vector&lt;u8&gt;&gt; = vector[vector[90, 105, 110, 99], vector[90, 104, 111, 114, 97]];
</code></pre>



<a name="name_gen_female_select"></a>

## Function `select`



<pre><code><b>public</b>(package) <b>fun</b> <a href="./female.md#name_gen_female_select">select</a>(num: u16): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./female.md#name_gen_female_select">select</a>(num: u16): String {
    <b>let</b> bucket_idx = num % 34;
    <b>let</b> bucket = match (bucket_idx) {
        0 =&gt; <a href="./female.md#name_gen_female_BUCKET_0">BUCKET_0</a>,
        1 =&gt; <a href="./female.md#name_gen_female_BUCKET_1">BUCKET_1</a>,
        2 =&gt; <a href="./female.md#name_gen_female_BUCKET_2">BUCKET_2</a>,
        3 =&gt; <a href="./female.md#name_gen_female_BUCKET_3">BUCKET_3</a>,
        4 =&gt; <a href="./female.md#name_gen_female_BUCKET_4">BUCKET_4</a>,
        5 =&gt; <a href="./female.md#name_gen_female_BUCKET_5">BUCKET_5</a>,
        6 =&gt; <a href="./female.md#name_gen_female_BUCKET_6">BUCKET_6</a>,
        7 =&gt; <a href="./female.md#name_gen_female_BUCKET_7">BUCKET_7</a>,
        8 =&gt; <a href="./female.md#name_gen_female_BUCKET_8">BUCKET_8</a>,
        9 =&gt; <a href="./female.md#name_gen_female_BUCKET_9">BUCKET_9</a>,
        10 =&gt; <a href="./female.md#name_gen_female_BUCKET_10">BUCKET_10</a>,
        11 =&gt; <a href="./female.md#name_gen_female_BUCKET_11">BUCKET_11</a>,
        12 =&gt; <a href="./female.md#name_gen_female_BUCKET_12">BUCKET_12</a>,
        13 =&gt; <a href="./female.md#name_gen_female_BUCKET_13">BUCKET_13</a>,
        14 =&gt; <a href="./female.md#name_gen_female_BUCKET_14">BUCKET_14</a>,
        15 =&gt; <a href="./female.md#name_gen_female_BUCKET_15">BUCKET_15</a>,
        16 =&gt; <a href="./female.md#name_gen_female_BUCKET_16">BUCKET_16</a>,
        17 =&gt; <a href="./female.md#name_gen_female_BUCKET_17">BUCKET_17</a>,
        18 =&gt; <a href="./female.md#name_gen_female_BUCKET_18">BUCKET_18</a>,
        19 =&gt; <a href="./female.md#name_gen_female_BUCKET_19">BUCKET_19</a>,
        20 =&gt; <a href="./female.md#name_gen_female_BUCKET_20">BUCKET_20</a>,
        21 =&gt; <a href="./female.md#name_gen_female_BUCKET_21">BUCKET_21</a>,
        22 =&gt; <a href="./female.md#name_gen_female_BUCKET_22">BUCKET_22</a>,
        23 =&gt; <a href="./female.md#name_gen_female_BUCKET_23">BUCKET_23</a>,
        24 =&gt; <a href="./female.md#name_gen_female_BUCKET_24">BUCKET_24</a>,
        25 =&gt; <a href="./female.md#name_gen_female_BUCKET_25">BUCKET_25</a>,
        26 =&gt; <a href="./female.md#name_gen_female_BUCKET_26">BUCKET_26</a>,
        27 =&gt; <a href="./female.md#name_gen_female_BUCKET_27">BUCKET_27</a>,
        28 =&gt; <a href="./female.md#name_gen_female_BUCKET_28">BUCKET_28</a>,
        29 =&gt; <a href="./female.md#name_gen_female_BUCKET_29">BUCKET_29</a>,
        30 =&gt; <a href="./female.md#name_gen_female_BUCKET_30">BUCKET_30</a>,
        31 =&gt; <a href="./female.md#name_gen_female_BUCKET_31">BUCKET_31</a>,
        32 =&gt; <a href="./female.md#name_gen_female_BUCKET_32">BUCKET_32</a>,
        33 =&gt; <a href="./female.md#name_gen_female_BUCKET_33">BUCKET_33</a>,
        _ =&gt; <b>abort</b>,
    };
    <b>let</b> index = (num <b>as</b> u64 % bucket.length());
    bucket[index].to_string()
}
</code></pre>



</details>
