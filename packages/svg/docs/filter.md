
<a name="(svg=0x0)_filter"></a>

# Module `(svg=0x0)::filter`

Module: filter

Filters are the biggest enum in the SVG module, with 25 different types of
filters. To prevent verifier failure, we avoid using enums for the filter,
and instead rely on attributes with String-String pairs and a type attribute.


-  [Struct `Filter`](#(svg=0x0)_filter_Filter)
-  [Constants](#@Constants_0)
-  [Function `blend`](#(svg=0x0)_filter_blend)
-  [Function `color_matrix`](#(svg=0x0)_filter_color_matrix)
-  [Function `component_transfer`](#(svg=0x0)_filter_component_transfer)
-  [Function `composite`](#(svg=0x0)_filter_composite)
-  [Function `convolve_matrix`](#(svg=0x0)_filter_convolve_matrix)
-  [Function `diffuse_lighting`](#(svg=0x0)_filter_diffuse_lighting)
-  [Function `displacement_map`](#(svg=0x0)_filter_displacement_map)
-  [Function `distant_light`](#(svg=0x0)_filter_distant_light)
-  [Function `drop_shadow`](#(svg=0x0)_filter_drop_shadow)
-  [Function `flood`](#(svg=0x0)_filter_flood)
-  [Function `func_a`](#(svg=0x0)_filter_func_a)
-  [Function `func_b`](#(svg=0x0)_filter_func_b)
-  [Function `func_g`](#(svg=0x0)_filter_func_g)
-  [Function `func_r`](#(svg=0x0)_filter_func_r)
-  [Function `gaussian_blur`](#(svg=0x0)_filter_gaussian_blur)
-  [Function `image`](#(svg=0x0)_filter_image)
-  [Function `merge`](#(svg=0x0)_filter_merge)
-  [Function `merge_node`](#(svg=0x0)_filter_merge_node)
-  [Function `morphology`](#(svg=0x0)_filter_morphology)
-  [Function `offset`](#(svg=0x0)_filter_offset)
-  [Function `point_light`](#(svg=0x0)_filter_point_light)
-  [Function `specular_lighting`](#(svg=0x0)_filter_specular_lighting)
-  [Function `spot_light`](#(svg=0x0)_filter_spot_light)
-  [Function `tile`](#(svg=0x0)_filter_tile)
-  [Function `turbulence`](#(svg=0x0)_filter_turbulence)
-  [Function `attributes`](#(svg=0x0)_filter_attributes)
-  [Function `attributes_mut`](#(svg=0x0)_filter_attributes_mut)
-  [Macro function `map_attributes`](#(svg=0x0)_filter_map_attributes)
-  [Function `name`](#(svg=0x0)_filter_name)
-  [Function `to_string`](#(svg=0x0)_filter_to_string)


<pre><code><b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./print.md#(svg=0x0)_print">print</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_filter_Filter"></a>

## Struct `Filter`



<pre><code><b>public</b> <b>struct</b> <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>filter_type: u8</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(svg=0x0)_filter_TYPE_BLEND"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_BLEND">TYPE_BLEND</a>: u8 = 0;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_COLOR_MATRIX"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_COLOR_MATRIX">TYPE_COLOR_MATRIX</a>: u8 = 1;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_COMPONENT_TRANSFER"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_COMPONENT_TRANSFER">TYPE_COMPONENT_TRANSFER</a>: u8 = 2;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_COMPOSITE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_COMPOSITE">TYPE_COMPOSITE</a>: u8 = 3;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_CONVOLVE_MATRIX"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_CONVOLVE_MATRIX">TYPE_CONVOLVE_MATRIX</a>: u8 = 4;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_DIFFUSE_LIGHTING"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_DIFFUSE_LIGHTING">TYPE_DIFFUSE_LIGHTING</a>: u8 = 5;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_DISPLACEMENT_MAP"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_DISPLACEMENT_MAP">TYPE_DISPLACEMENT_MAP</a>: u8 = 6;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_DISTANT_LIGHT"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_DISTANT_LIGHT">TYPE_DISTANT_LIGHT</a>: u8 = 7;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_DROP_SHADOW"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_DROP_SHADOW">TYPE_DROP_SHADOW</a>: u8 = 8;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_FLOOD"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_FLOOD">TYPE_FLOOD</a>: u8 = 9;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_FUNC_A"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_A">TYPE_FUNC_A</a>: u8 = 10;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_FUNC_B"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_B">TYPE_FUNC_B</a>: u8 = 11;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_FUNC_G"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_G">TYPE_FUNC_G</a>: u8 = 12;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_FUNC_R"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_R">TYPE_FUNC_R</a>: u8 = 13;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_GAUSSIAN_BLUR"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_GAUSSIAN_BLUR">TYPE_GAUSSIAN_BLUR</a>: u8 = 14;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_IMAGE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_IMAGE">TYPE_IMAGE</a>: u8 = 15;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_MERGE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_MERGE">TYPE_MERGE</a>: u8 = 16;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_MERGE_NODE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_MERGE_NODE">TYPE_MERGE_NODE</a>: u8 = 17;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_MORPHOLOGY"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_MORPHOLOGY">TYPE_MORPHOLOGY</a>: u8 = 18;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_OFFSET"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_OFFSET">TYPE_OFFSET</a>: u8 = 19;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_POINT_LIGHT"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_POINT_LIGHT">TYPE_POINT_LIGHT</a>: u8 = 20;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_SPECULAR_LIGHTING"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_SPECULAR_LIGHTING">TYPE_SPECULAR_LIGHTING</a>: u8 = 21;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_SPOT_LIGHT"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_SPOT_LIGHT">TYPE_SPOT_LIGHT</a>: u8 = 22;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_TILE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_TILE">TYPE_TILE</a>: u8 = 23;
</code></pre>



<a name="(svg=0x0)_filter_TYPE_TURBULENCE"></a>



<pre><code><b>const</b> <a href="./filter.md#(svg=0x0)_filter_TYPE_TURBULENCE">TYPE_TURBULENCE</a>: u8 = 24;
</code></pre>



<a name="(svg=0x0)_filter_blend"></a>

## Function `blend`

Create a new blend filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_blend">blend</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, in2: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, mode: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_blend">blend</a>(in: String, in2: String, mode: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in2".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in2);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"mode".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), mode);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_BLEND">TYPE_BLEND</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_color_matrix"></a>

## Function `color_matrix`

Create a new color matrix filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_color_matrix">color_matrix</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, values: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_color_matrix">color_matrix</a>(in: String, type_: String, values: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"values".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), values);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_COLOR_MATRIX">TYPE_COLOR_MATRIX</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_component_transfer"></a>

## Function `component_transfer`

Create a new component transfer filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_component_transfer">component_transfer</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_component_transfer">component_transfer</a>(in: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_COMPONENT_TRANSFER">TYPE_COMPONENT_TRANSFER</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_composite"></a>

## Function `composite`

Create a new composite filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_composite">composite</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, in2: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, operator: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, k1: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, k2: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, k3: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, k4: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_composite">composite</a>(
    in: String,
    in2: String,
    operator: String,
    k1: String,
    k2: String,
    k3: String,
    k4: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in2".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in2);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"operator".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), operator);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"k1".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), k1);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"k2".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), k2);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"k3".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), k3);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"k4".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), k4);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_COMPOSITE">TYPE_COMPOSITE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_convolve_matrix"></a>

## Function `convolve_matrix`

Create a new convolve matrix filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_convolve_matrix">convolve_matrix</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, order: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, kernelMatrix: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, divisor: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, bias: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, targetX: u16, targetY: u16, edgeMode: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, kernelUnitLength: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, preserveAlpha: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_convolve_matrix">convolve_matrix</a>(
    in: String,
    order: String,
    kernelMatrix: String,
    divisor: String,
    bias: String,
    targetX: u16,
    targetY: u16,
    edgeMode: String,
    kernelUnitLength: String,
    preserveAlpha: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"order".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), order);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"kernelMatrix".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), kernelMatrix);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"divisor".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), divisor);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"bias".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), bias);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"targetX".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), targetX.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"targetY".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), targetY.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"edgeMode".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), edgeMode);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"kernelUnitLength".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), kernelUnitLength);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"preserveAlpha".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), preserveAlpha);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_CONVOLVE_MATRIX">TYPE_CONVOLVE_MATRIX</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_diffuse_lighting"></a>

## Function `diffuse_lighting`

Create a new diffuse lighting filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_diffuse_lighting">diffuse_lighting</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, surfaceScale: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, diffuseConstant: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, kernelUnitLength: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, color: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, light: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_diffuse_lighting">diffuse_lighting</a>(
    in: String,
    surfaceScale: String,
    diffuseConstant: String,
    kernelUnitLength: String,
    color: String,
    light: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"surfaceScale".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), surfaceScale);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"diffuseConstant".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), diffuseConstant);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"kernelUnitLength".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), kernelUnitLength);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"color".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), color);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"light".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), light);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_DIFFUSE_LIGHTING">TYPE_DIFFUSE_LIGHTING</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_displacement_map"></a>

## Function `displacement_map`

Create a new displacement map filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_displacement_map">displacement_map</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, in2: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, scale: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, xChannelSelector: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, yChannelSelector: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_displacement_map">displacement_map</a>(
    in: String,
    in2: String,
    scale: String,
    xChannelSelector: String,
    yChannelSelector: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in2".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in2);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"scale".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), scale);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"xChannelSelector".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), xChannelSelector);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"yChannelSelector".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), yChannelSelector);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_DISPLACEMENT_MAP">TYPE_DISPLACEMENT_MAP</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_distant_light"></a>

## Function `distant_light`

Create a new distant light filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_distant_light">distant_light</a>(azimuth: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, elevation: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_distant_light">distant_light</a>(azimuth: String, elevation: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"azimuth".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), azimuth);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"elevation".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), elevation);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_DISTANT_LIGHT">TYPE_DISTANT_LIGHT</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_drop_shadow"></a>

## Function `drop_shadow`

Create a new drop shadow filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_drop_shadow">drop_shadow</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, dx: u16, dy: u16, stdDeviation: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_drop_shadow">drop_shadow</a>(in: String, dx: u16, dy: u16, stdDeviation: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"dx".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), dx.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"dy".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), dy.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"stdDeviation".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), stdDeviation);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_DROP_SHADOW">TYPE_DROP_SHADOW</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_flood"></a>

## Function `flood`

Create a new flood filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_flood">flood</a>(color: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, opacity: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_flood">flood</a>(color: String, opacity: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"color".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), color);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"opacity".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), opacity);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_FLOOD">TYPE_FLOOD</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_func_a"></a>

## Function `func_a`

Create a new function A filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_a">func_a</a>(type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, tableValues: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, slope: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, intercept: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, amplitude: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, exponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_a">func_a</a>(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"tableValues".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), tableValues);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"slope".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), slope);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"intercept".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), intercept);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"amplitude".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), amplitude);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"exponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), exponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"<a href="./filter.md#(svg=0x0)_filter_offset">offset</a>".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_A">TYPE_FUNC_A</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_func_b"></a>

## Function `func_b`

Create a new function B filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_b">func_b</a>(type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, tableValues: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, slope: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, intercept: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, amplitude: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, exponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_b">func_b</a>(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"tableValues".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), tableValues);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"slope".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), slope);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"intercept".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), intercept);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"amplitude".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), amplitude);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"exponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), exponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"<a href="./filter.md#(svg=0x0)_filter_offset">offset</a>".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_B">TYPE_FUNC_B</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_func_g"></a>

## Function `func_g`

Create a new function G filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_g">func_g</a>(type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, tableValues: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, slope: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, intercept: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, amplitude: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, exponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_g">func_g</a>(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"tableValues".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), tableValues);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"slope".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), slope);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"intercept".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), intercept);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"amplitude".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), amplitude);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"exponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), exponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"<a href="./filter.md#(svg=0x0)_filter_offset">offset</a>".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_G">TYPE_FUNC_G</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_func_r"></a>

## Function `func_r`

Create a new function R filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_r">func_r</a>(type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, tableValues: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, slope: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, intercept: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, amplitude: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, exponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_func_r">func_r</a>(
    type_: String,
    tableValues: String,
    slope: String,
    intercept: String,
    amplitude: String,
    exponent: String,
    <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"tableValues".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), tableValues);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"slope".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), slope);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"intercept".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), intercept);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"amplitude".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), amplitude);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"exponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), exponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"<a href="./filter.md#(svg=0x0)_filter_offset">offset</a>".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_FUNC_R">TYPE_FUNC_R</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_gaussian_blur"></a>

## Function `gaussian_blur`

Create a new gaussian blur filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_gaussian_blur">gaussian_blur</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, stdDeviation: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_gaussian_blur">gaussian_blur</a>(in: String, stdDeviation: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"stdDeviation".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), stdDeviation);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_GAUSSIAN_BLUR">TYPE_GAUSSIAN_BLUR</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_image"></a>

## Function `image`

Create a new image filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_image">image</a>(href: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, result: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_image">image</a>(href: String, result: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"href".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), href);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"result".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), result);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_IMAGE">TYPE_IMAGE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_merge"></a>

## Function `merge`

Create a new merge filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_merge">merge</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_merge">merge</a>(in: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_MERGE">TYPE_MERGE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_merge_node"></a>

## Function `merge_node`

Create a new merge node filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_merge_node">merge_node</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_merge_node">merge_node</a>(in: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_MERGE_NODE">TYPE_MERGE_NODE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_morphology"></a>

## Function `morphology`

Create a new morphology filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_morphology">morphology</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, operator: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, radius: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_morphology">morphology</a>(in: String, operator: String, radius: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"operator".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), operator);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"radius".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), radius);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_MORPHOLOGY">TYPE_MORPHOLOGY</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_offset"></a>

## Function `offset`

Create a new offset filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, dx: u16, dy: u16): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_offset">offset</a>(in: String, dx: u16, dy: u16): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"dx".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), dx.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"dy".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), dy.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_OFFSET">TYPE_OFFSET</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_point_light"></a>

## Function `point_light`

Create a new point light filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_point_light">point_light</a>(x: u16, y: u16, z: u16): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_point_light">point_light</a>(x: u16, y: u16, z: u16): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"x".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), x.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"y".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), y.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"z".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), z.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_POINT_LIGHT">TYPE_POINT_LIGHT</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_specular_lighting"></a>

## Function `specular_lighting`

Create a new specular lighting filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_specular_lighting">specular_lighting</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, surfaceScale: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, specularConstant: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, specularExponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, kernelUnitLength: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, light: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_specular_lighting">specular_lighting</a>(
    in: String,
    surfaceScale: String,
    specularConstant: String,
    specularExponent: String,
    kernelUnitLength: String,
    light: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"surfaceScale".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), surfaceScale);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"specularConstant".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), specularConstant);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"specularExponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), specularExponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"kernelUnitLength".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), kernelUnitLength);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"light".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), light);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_SPECULAR_LIGHTING">TYPE_SPECULAR_LIGHTING</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_spot_light"></a>

## Function `spot_light`

Create a new spot light filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_spot_light">spot_light</a>(x: u16, y: u16, z: u16, pointsAtX: u16, pointsAtY: u16, pointsAtZ: u16, specularExponent: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, limitingConeAngle: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_spot_light">spot_light</a>(
    x: u16,
    y: u16,
    z: u16,
    pointsAtX: u16,
    pointsAtY: u16,
    pointsAtZ: u16,
    specularExponent: String,
    limitingConeAngle: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"x".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), x.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"y".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), y.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"z".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), z.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"pointsAtX".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), pointsAtX.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"pointsAtY".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), pointsAtY.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"pointsAtZ".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), pointsAtZ.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>());
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"specularExponent".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), specularExponent);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"limitingConeAngle".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), limitingConeAngle);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_SPOT_LIGHT">TYPE_SPOT_LIGHT</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_tile"></a>

## Function `tile`

Create a new tile filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_tile">tile</a>(in: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_tile">tile</a>(in: String): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"in".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), in);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_TILE">TYPE_TILE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_turbulence"></a>

## Function `turbulence`

Create a new turbulence filter.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_turbulence">turbulence</a>(baseFrequency: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, numOctaves: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, seed: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, stitchTiles: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, type_: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_turbulence">turbulence</a>(
    baseFrequency: String,
    numOctaves: String,
    seed: String,
    stitchTiles: String,
    type_: String,
): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = vec_map::empty();
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"baseFrequency".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), baseFrequency);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"numOctaves".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), numOctaves);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"seed".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), seed);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"stitchTiles".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), stitchTiles);
    <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>.insert(b"type".<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(), type_);
    <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> { filter_type: <a href="./filter.md#(svg=0x0)_filter_TYPE_TURBULENCE">TYPE_TURBULENCE</a>, <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> }
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_attributes"></a>

## Function `attributes`

Get a reference to the attributes of a shape.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>): &<a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &<a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a>): &VecMap&lt;String, String&gt; {
    &<a href="./shape.md#(svg=0x0)_shape">shape</a>.<a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_attributes_mut"></a>

## Function `attributes_mut`

Get a mutable reference to the attributes of a shape.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_attributes_mut">attributes_mut</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>): &<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_attributes_mut">attributes_mut</a>(<a href="./shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a>): &<b>mut</b> VecMap&lt;String, String&gt; {
    &<b>mut</b> <a href="./shape.md#(svg=0x0)_shape">shape</a>.<a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_map_attributes"></a>

## Macro function `map_attributes`

Map over the attributes of the animation.

```rust
let mut animation = shape::circle(10).move_to(20, 20).map_attributes!(|attrs| {
attrs.insert(b"fill".to_string(), b"red".to_string());
attrs.insert(b"stroke".to_string(), b"black".to_string());
});
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_map_attributes">map_attributes</a>($self: (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>, $f: |&<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;| -&gt; ()): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_map_attributes">map_attributes</a>($self: <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a>, $f: |&<b>mut</b> VecMap&lt;String, String&gt;|): <a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a> {
    <b>let</b> <b>mut</b> self = $self;
    <b>let</b> <a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a> = self.<a href="./filter.md#(svg=0x0)_filter_attributes_mut">attributes_mut</a>();
    $f(<a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>);
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_name"></a>

## Function `name`

Get the name of a filter.

TODO: replace with constants when compiler bug is fixed.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_name">name</a>(<a href="./filter.md#(svg=0x0)_filter">filter</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_name">name</a>(<a href="./filter.md#(svg=0x0)_filter">filter</a>: &<a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a>): String {
    match (<a href="./filter.md#(svg=0x0)_filter">filter</a>.filter_type) {
        0 =&gt; b"feBlend",
        1 =&gt; b"feColorMatrix",
        2 =&gt; b"feComponentTransfer",
        3 =&gt; b"feComposite",
        4 =&gt; b"feConvolveMatrix",
        5 =&gt; b"feDiffuseLighting",
        6 =&gt; b"feDisplacementMap",
        7 =&gt; b"feDistantLight",
        8 =&gt; b"feDropShadow",
        9 =&gt; b"feFlood",
        10 =&gt; b"feFuncA",
        11 =&gt; b"feFuncB",
        12 =&gt; b"feFuncG",
        13 =&gt; b"feFuncR",
        14 =&gt; b"feGaussianBlur",
        15 =&gt; b"feImage",
        16 =&gt; b"feMerge",
        17 =&gt; b"feMergeNode",
        18 =&gt; b"feMorphology",
        19 =&gt; b"feOffset",
        20 =&gt; b"fePointLight",
        21 =&gt; b"feSpecularLighting",
        22 =&gt; b"feSpotLight",
        23 =&gt; b"feTile",
        24 =&gt; b"feTurbulence",
        _ =&gt; <b>abort</b>,
    }.<a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>()
}
</code></pre>



</details>

<a name="(svg=0x0)_filter_to_string"></a>

## Function `to_string`

Print the filter element as a string.


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(<a href="./filter.md#(svg=0x0)_filter">filter</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./filter.md#(svg=0x0)_filter_to_string">to_string</a>(<a href="./filter.md#(svg=0x0)_filter">filter</a>: &<a href="./filter.md#(svg=0x0)_filter_Filter">Filter</a>): String {
    <a href="./print.md#(svg=0x0)_print_print">print::print</a>(<a href="./filter.md#(svg=0x0)_filter">filter</a>.<a href="./filter.md#(svg=0x0)_filter_name">name</a>(), <a href="./filter.md#(svg=0x0)_filter">filter</a>.<a href="./filter.md#(svg=0x0)_filter_attributes">attributes</a>, option::none())
}
</code></pre>



</details>
