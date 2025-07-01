
<a name="(svg=0x0)_svg"></a>

# Module `(svg=0x0)::svg`

Module: svg


-  [Struct `Svg`](#(svg=0x0)_svg_Svg)
-  [Function `svg`](#(svg=0x0)_svg_svg)
-  [Function `add`](#(svg=0x0)_svg_add)
-  [Function `add_root`](#(svg=0x0)_svg_add_root)
        -  [Usage](#@Usage_0)
-  [Function `add_a`](#(svg=0x0)_svg_add_a)
        -  [Usage](#@Usage_1)
-  [Function `add_g`](#(svg=0x0)_svg_add_g)
        -  [Usage](#@Usage_2)
-  [Function `add_defs`](#(svg=0x0)_svg_add_defs)
        -  [Usage](#@Usage_3)
-  [Function `add_clip_path`](#(svg=0x0)_svg_add_clip_path)
        -  [Usage](#@Usage_4)
-  [Function `attributes_mut`](#(svg=0x0)_svg_attributes_mut)
        -  [Usage](#@Usage_5)
-  [Function `to_string`](#(svg=0x0)_svg_to_string)
        -  [Usage](#@Usage_6)
-  [Function `to_data_uri`](#(svg=0x0)_svg_to_data_uri)
-  [Function `to_url`](#(svg=0x0)_svg_to_url)


<pre><code><b>use</b> (codec=0x0)::base64;
<b>use</b> (codec=0x0)::urlencode;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/container.md#(svg=0x0)_container">container</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/desc.md#(svg=0x0)_desc">desc</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point">point</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/print.md#(svg=0x0)_print">print</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_svg_Svg"></a>

## Struct `Svg`

The base SVG element.


<pre><code><b>public</b> <b>struct</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>view_box: vector&lt;u16&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>elements: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/container.md#(svg=0x0)_container_Container">container::Container</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>attributes: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(svg=0x0)_svg_svg"></a>

## Function `svg`

Create a new <code>&lt;<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>&gt;</code> element with the given view box. View box is optional,
but if provided, it must have 4 elements.

```rust
let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_root(vector[ shape::circle(5).move_to(10, 10) ]);
svg.to_string(); // to print as a string
svg.debug(); // to print in the console in tests
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>(view_box: vector&lt;u16&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>(view_box: vector&lt;u16&gt;): <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <b>assert</b>!(view_box.length() == 4 || view_box.length() == 0);
    <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> { view_box, elements: vector[], attributes: vec_map::empty() }
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add"></a>

## Function `add`

Adds any <code>Container</code> to the <code><a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a></code>, if container is created manually. Alternatively,
to add a group container or place elements in the "root", use <code>root</code> or <code>g</code> functions.

```rust
use svg::{shape, svg};

let container = container::g(vector[
shape::circle(5).move_to(10, 10),
shape::ellipse(30, 30, 10, 5),
]);
let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add(container);
svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, element: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/container.md#(svg=0x0)_container_Container">container::Container</a>): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, element: Container): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.elements.push_back(element);
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add_root"></a>

## Function `add_root`

Place <code>Shape</code>s directly in the root of the SVG.


<a name="@Usage_0"></a>

#### Usage

```rust
use svg::{shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_root(vector[
shape::circle(5).move_to(10, 10),
shape::square(30, 30).move_to(20, 20),
]);
svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_root">add_root</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, shapes: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_root">add_root</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, shapes: vector&lt;Shape&gt;): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_root">container::root</a>(shapes))
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add_a"></a>

## Function `add_a`

Create a <code>&lt;a&gt;</code> (hyperlink) container and place <code>Shape</code>s in it.

Shortcut for <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_a">container::a</a>(shapes))</code>.


<a name="@Usage_1"></a>

#### Usage

```rust
use svg::{shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_a(vector[
shape::circle(5).move_to(10, 10),
shape::ellipse(30, 30, 10, 5),
]);

svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_a">add_a</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, link: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, shapes: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_a">add_a</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, link: String, shapes: vector&lt;Shape&gt;): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_a">container::a</a>(link, shapes))
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add_g"></a>

## Function `add_g`

Create a <code>&lt;g&gt;</code> (group) container and place <code>Shape</code>s in it.

Shortcut for <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_g">container::g</a>(shapes))</code>.


<a name="@Usage_2"></a>

#### Usage

```rust
use svg::{shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_g(vector[
shape::circle(5).move_to(10, 10),
shape::ellipse(30, 30, 10, 5),
]);
svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_g">add_g</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, shapes: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_g">add_g</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, shapes: vector&lt;Shape&gt;): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_g">container::g</a>(shapes))
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add_defs"></a>

## Function `add_defs`

Create a <code>&lt;defs&gt;</code> container and place <code>Shape</code>s in it.

Shortcut for <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_defs">container::defs</a>(shapes))</code>.


<a name="@Usage_3"></a>

#### Usage

```rust
use svg::{shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_defs(vector[
shape::linear_gradient(vector[
shape::stop(b"10%", b"gold"),
shape::stop(b"90%", b"red"),
]).map_attributes!(|attrs| {
attrs.insert(b"id".to_string(), b"grad1".to_string());
}),
]);
svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_defs">add_defs</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, shapes: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_defs">add_defs</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, shapes: vector&lt;Shape&gt;): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_defs">container::defs</a>(shapes))
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_add_clip_path"></a>

## Function `add_clip_path`

Create a <code>&lt;clipPath&gt;</code> container and place <code>Shape</code>s in it.

Shortcut for <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_clip_path">container::clip_path</a>(shapes))</code>.


<a name="@Usage_4"></a>

#### Usage

```rust
use svg::{shape, svg};
let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_clip_path(vector[
shape::circle(5),
]);
svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_clip_path">add_clip_path</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg, shapes: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_add_clip_path">add_clip_path</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>, shapes: vector&lt;Shape&gt;): &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a> {
    <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_add">add</a>(<a href="../svg/container.md#(svg=0x0)_container_clip_path">container::clip_path</a>(shapes))
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_attributes_mut"></a>

## Function `attributes_mut`

Get mutable access to the attributes of the SVG. This is useful for adding
custom attributes directly to the <code>&lt;<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>&gt;</code> element.


<a name="@Usage_5"></a>

#### Usage

```rust
use svg::svg;

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.attributes_mut().insert(
b"width".to_string(),
b"10000".to_string()
);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_attributes_mut">attributes_mut</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg): &<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_attributes_mut">attributes_mut</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>): &<b>mut</b> VecMap&lt;String, String&gt; {
    &<b>mut</b> <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.attributes
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_to_string"></a>

## Function `to_string`

Print the SVG element as a <code>String</code>.


<a name="@Usage_6"></a>

#### Usage

```rust
use svg::{shape, svg};

let mut svg = svg::svg(vector[0, 0, 200, 200]);
svg.add_root(vector[ shape::circle(5).move_to(10, 10) ]);
let printed = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>): String {
    <b>let</b> <b>mut</b> attributes = vec_map::empty();
    attributes.insert(b"xmlns".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(), b"http://www.w3.org/2000/<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>());
    <b>let</b> length = <a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.view_box.length();
    <b>if</b> (length == 4) {
        <b>let</b> <b>mut</b> view_box = b"".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>();
        length.do!(|index| {
            view_box.append(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.view_box[index].<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>());
            <b>if</b> (index &lt; 3) view_box.append(b" ".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>());
        });
        attributes.insert(b"viewBox".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(), view_box);
    };
    <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(
        b"<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(),
        attributes,
        option::some(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.elements.map_ref!(|element| element.<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>())),
    )
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_to_data_uri"></a>

## Function `to_data_uri`

Convert the SVG element to a base64-encoded data URI.

Outputs: <code>data:image/<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>+xml;base64,PHN2Zz4KPC9zdmc+</code>.

**If you need a URL-encoded data URI, use <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_to_url">to_url</a>()</code>**


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_data_uri">to_data_uri</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_data_uri">to_data_uri</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>): String {
    <b>let</b> <b>mut</b> result = b"data:image/<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>+xml;base64,".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>();
    result.append(base64::encode(<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>).into_bytes()));
    result
}
</code></pre>



</details>

<a name="(svg=0x0)_svg_to_url"></a>

## Function `to_url`

Convert the SVG element to a url-encoded data URI.

Outputs: <code>data:image/<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>+xml,%3Csvg%3E%3C%2Fsvg%3E</code>.

**If you need a base64-encoded data URI, use <code><a href="../svg/svg.md#(svg=0x0)_svg">svg</a>.<a href="../svg/svg.md#(svg=0x0)_svg_to_data_uri">to_data_uri</a>()</code>**


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_url">to_url</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::svg::Svg): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/svg.md#(svg=0x0)_svg_to_url">to_url</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>: &<a href="../svg/svg.md#(svg=0x0)_svg_Svg">Svg</a>): String {
    <b>let</b> <b>mut</b> result = b"data:image/<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>+xml,".<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>();
    result.append(urlencode::encode(<a href="../svg/svg.md#(svg=0x0)_svg_to_string">to_string</a>(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>).into_bytes()));
    result
}
</code></pre>



</details>
