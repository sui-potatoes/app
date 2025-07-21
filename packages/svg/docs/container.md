
<a name="(svg=0x0)_container"></a>

# Module `(svg=0x0)::container`

Module: container


-  [Struct `Container`](#(svg=0x0)_container_Container)
-  [Constants](#@Constants_0)
-  [Function `root`](#(svg=0x0)_container_root)
        -  [Description](#@Description_1)
        -  [Usage](#@Usage_2)
-  [Function `a`](#(svg=0x0)_container_a)
        -  [Description](#@Description_3)
        -  [Usage](#@Usage_4)
-  [Function `defs`](#(svg=0x0)_container_defs)
        -  [Description](#@Description_5)
        -  [Usage](#@Usage_6)
-  [Function `g`](#(svg=0x0)_container_g)
        -  [Description](#@Description_7)
        -  [Usage](#@Usage_8)
-  [Function `marker`](#(svg=0x0)_container_marker)
        -  [Description](#@Description_9)
        -  [Usage](#@Usage_10)
-  [Function `mask`](#(svg=0x0)_container_mask)
        -  [Description](#@Description_11)
-  [Function `symbol`](#(svg=0x0)_container_symbol)
        -  [Description](#@Description_12)
-  [Function `clip_path`](#(svg=0x0)_container_clip_path)
        -  [Description](#@Description_13)
        -  [Usage](#@Usage_14)
-  [Function `move_to`](#(svg=0x0)_container_move_to)
-  [Function `add`](#(svg=0x0)_container_add)
-  [Function `animation_mut`](#(svg=0x0)_container_animation_mut)
-  [Function `attributes_mut`](#(svg=0x0)_container_attributes_mut)
-  [Macro function `map_attributes`](#(svg=0x0)_container_map_attributes)
-  [Function `name`](#(svg=0x0)_container_name)
-  [Function `to_string`](#(svg=0x0)_container_to_string)


<pre><code><b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./animation.md#(svg=0x0)_animation">animation</a>;
<b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./coordinate.md#(svg=0x0)_coordinate">coordinate</a>;
<b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc">desc</a>;
<b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./filter.md#(svg=0x0)_filter">filter</a>;
<b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./print.md#(svg=0x0)_print">print</a>;
<b>use</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape">shape</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_container_Container"></a>

## Struct `Container`

Represents an SVG container, which contains shapes. All of the containers
support <code>Shape</code>s placed inside them, and most of them support attributes,
which will be rendered as XML attributes in the SVG output.

Containers are created via one of:
- <code><a href="./container.md#(svg=0x0)_container_root">container::root</a></code> - no container, just a list of shapes.
- <code><a href="./container.md#(svg=0x0)_container_a">container::a</a></code> - hyperlink container, <code>&lt;<a href="./container.md#(svg=0x0)_container_a">a</a>&gt;</code>.
- <code><a href="./container.md#(svg=0x0)_container_defs">container::defs</a></code> - definition container, <code>&lt;<a href="./container.md#(svg=0x0)_container_defs">defs</a>&gt;</code>, to be used for reusable shapes.
- <code><a href="./container.md#(svg=0x0)_container_g">container::g</a></code> - group container, <code>&lt;<a href="./container.md#(svg=0x0)_container_g">g</a>&gt;</code>, to group shapes.
- <code><a href="./container.md#(svg=0x0)_container_marker">container::marker</a></code> - marker container, <code>&lt;<a href="./container.md#(svg=0x0)_container_marker">marker</a>&gt;</code>, to define a marker symbol.
- <code><a href="./container.md#(svg=0x0)_container_symbol">container::symbol</a></code> - symbol container, <code>&lt;<a href="./container.md#(svg=0x0)_container_symbol">symbol</a>&gt;</code>, to define a reusable graphic.


<pre><code><b>public</b> <b>struct</b> <a href="./container.md#(svg=0x0)_container_Container">Container</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./container.md#(svg=0x0)_container">container</a>: u8</code>
</dt>
<dd>
 Uses <code>u8</code> instead of <code>ContainerType</code> to avoid verifier conflict on type
 signatures being too large.
</dd>
<dt>
<code>shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code>attributes: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./animation.md#(svg=0x0)_animation">animation</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>&gt;</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./desc.md#(svg=0x0)_desc">desc</a>: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./desc.md#(svg=0x0)_desc_Desc">desc::Desc</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(svg=0x0)_container_TYPE_ROOT"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_ROOT">TYPE_ROOT</a>: u8 = 0;
</code></pre>



<a name="(svg=0x0)_container_TYPE_A"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_A">TYPE_A</a>: u8 = 1;
</code></pre>



<a name="(svg=0x0)_container_TYPE_DEFS"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_DEFS">TYPE_DEFS</a>: u8 = 2;
</code></pre>



<a name="(svg=0x0)_container_TYPE_G"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_G">TYPE_G</a>: u8 = 3;
</code></pre>



<a name="(svg=0x0)_container_TYPE_MARKER"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_MARKER">TYPE_MARKER</a>: u8 = 4;
</code></pre>



<a name="(svg=0x0)_container_TYPE_CLIP_PATH"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_CLIP_PATH">TYPE_CLIP_PATH</a>: u8 = 5;
</code></pre>



<a name="(svg=0x0)_container_TYPE_SYMBOL"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_SYMBOL">TYPE_SYMBOL</a>: u8 = 6;
</code></pre>



<a name="(svg=0x0)_container_TYPE_MASK"></a>



<pre><code><b>const</b> <a href="./container.md#(svg=0x0)_container_TYPE_MASK">TYPE_MASK</a>: u8 = 7;
</code></pre>



<a name="(svg=0x0)_container_root"></a>

## Function `root`

Create a new root container, no container, just a list of shapes.


<a name="@Description_1"></a>

#### Description


Used to place shapes directly in the root of the SVG.


<a name="@Usage_2"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);

svg.add_root(vector[
shape::circle(5),
shape::ellipse(30, 30, 10, 5),
]);

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_root">root</a>(shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_root">root</a>(shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_ROOT">TYPE_ROOT</a>,
        shapes,
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_a"></a>

## Function `a`

Create a new hyperlink container.


<a name="@Description_3"></a>

#### Description


Hyperlink container, <code>&lt;<a href="./container.md#(svg=0x0)_container_a">a</a>&gt;</code>. Must be initialized with an <code>href</code>.

- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_a">a</a>&gt;</code>.
- Own properties: <code>href</code>.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a).


<a name="@Usage_4"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);
let link = container::a(b"https://example.com".to_string(), vector[
shape::circle(5),
]);

svg.add(link); // or svg.a(vector[ /* ... */ ]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_a">a</a>(href: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_a">a</a>(href: String, shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <b>let</b> <b>mut</b> attributes = vec_map::empty();
    <b>if</b> (href.length() &gt; 0) {
        attributes.insert(b"href".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(), href);
    };
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_A">TYPE_A</a>,
        shapes,
        attributes,
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_defs"></a>

## Function `defs`

Create a new <code>Defs</code> container.


<a name="@Description_5"></a>

#### Description


A <code>&lt;<a href="./container.md#(svg=0x0)_container_defs">defs</a>&gt;</code> container, to be used for reusable shapes. It's like a
dictionary of shapes.

- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_defs">defs</a>&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/defs).


<a name="@Usage_6"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);
let defs = container::defs(vector[
shape::circle(5),
shape::ellipse(30, 30, 10, 5),
]);

svg.add(defs); // or svg.add_defs(vector[ /* ... */ ]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_defs">defs</a>(shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_defs">defs</a>(shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_DEFS">TYPE_DEFS</a>,
        shapes,
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_g"></a>

## Function `g`

Create a new <code>G</code> container.


<a name="@Description_7"></a>

#### Description


Group container, <code>&lt;<a href="./container.md#(svg=0x0)_container_g">g</a>&gt;</code>, to group shapes and apply transformations to groups
of elements.

- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_g">g</a>&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/g).


<a name="@Usage_8"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);

// Create a group of shapes.
let mut group = container::g(vector[
shape::circle(5),
shape::ellipse(30, 30, 10, 5),
]);

group.attributes_mut().insert(b"fill".to_string(), b"red".to_string());

svg.add(group); // // or svg.add_g(vector[ /* ... */ ]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_g">g</a>(shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_g">g</a>(shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_G">TYPE_G</a>,
        shapes,
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_marker"></a>

## Function `marker`

Create a new <code>_Marker</code> container.


<a name="@Description_9"></a>

#### Description

Marker container, <code>&lt;<a href="./container.md#(svg=0x0)_container_marker">marker</a>&gt;</code>, to define a marker symbol.
- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_marker">marker</a>&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/marker).


<a name="@Usage_10"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);
let marker = container::marker(vector[
shape::circle(5),
shape::ellipse(30, 30, 10, 5),
]);

svg.add(marker); // or svg.marker(vector[ /* ... */ ]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_marker">marker</a>(id: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, _shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_marker">marker</a>(id: String, _shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <b>let</b> <b>mut</b> attributes = vec_map::empty();
    attributes.insert(b"id".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(), id);
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_MARKER">TYPE_MARKER</a>,
        shapes: vector[],
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_mask"></a>

## Function `mask`

Create a new <code>Mask</code> container.


<a name="@Description_11"></a>

#### Description

Mask container, <code>&lt;<a href="./container.md#(svg=0x0)_container_mask">mask</a>&gt;</code>, to define a mask.
- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_mask">mask</a>&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/mask).


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_mask">mask</a>(id: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, _shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_mask">mask</a>(id: String, _shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <b>let</b> <b>mut</b> attributes = vec_map::empty();
    attributes.insert(b"id".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(), id);
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_MASK">TYPE_MASK</a>,
        shapes: vector[],
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_symbol"></a>

## Function `symbol`

Create a new <code>Symbol</code> container.


<a name="@Description_12"></a>

#### Description

Symbol container, <code>&lt;<a href="./container.md#(svg=0x0)_container_symbol">symbol</a>&gt;</code>, to define a reusable graphic.
- Element: <code>&lt;<a href="./container.md#(svg=0x0)_container_symbol">symbol</a>&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/symbol).


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_symbol">symbol</a>(id: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, _shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_symbol">symbol</a>(id: String, _shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <b>let</b> <b>mut</b> attributes = vec_map::empty();
    attributes.insert(b"id".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(), id);
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_SYMBOL">TYPE_SYMBOL</a>,
        shapes: vector[],
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_clip_path"></a>

## Function `clip_path`

Create a new <code>ClipPath</code> container.


<a name="@Description_13"></a>

#### Description

ClipPath container, <code>&lt;clipPath&gt;</code>, to define a clipping path.
- Element: <code>&lt;clipPath&gt;</code>.
- Own properties: None.
- Extended properties: None.

See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/clipPath).


<a name="@Usage_14"></a>

#### Usage


```rust
let mut svg = svg::svg(vector[0, 0, 100, 100]);
let clip_path = container::clip_path(vector[
shape::circle(5),
]);
svg.add(clip_path); // or svg.clip_path(vector[ /* ... */ ]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_clip_path">clip_path</a>(shapes: vector&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>&gt;): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_clip_path">clip_path</a>(shapes: vector&lt;Shape&gt;): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
        <a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_TYPE_CLIP_PATH">TYPE_CLIP_PATH</a>,
        shapes,
        attributes: vec_map::empty(),
        <a href="./animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        <a href="./desc.md#(svg=0x0)_desc">desc</a>: vector[],
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_move_to"></a>

## Function `move_to`

Move a container, keep the interface consistent with shapes.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_move_to">move_to</a>(<a href="./container.md#(svg=0x0)_container">container</a>: (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>, x: u16, y: u16): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_move_to">move_to</a>(<a href="./container.md#(svg=0x0)_container">container</a>: <a href="./container.md#(svg=0x0)_container_Container">Container</a>, x: u16, y: u16): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <a href="./container.md#(svg=0x0)_container">container</a>.<a href="./container.md#(svg=0x0)_container_map_attributes">map_attributes</a>!(|attributes| {
        <b>let</b> x_key = b"x".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>();
        <b>let</b> y_key = b"y".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>();
        <b>if</b> (attributes.contains(&x_key)) {
            attributes.remove(&x_key);
        };
        <b>if</b> (attributes.contains(&y_key)) {
            attributes.remove(&y_key);
        };
        attributes.insert(x_key, x.<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>());
        attributes.insert(y_key, y.<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>());
    })
}
</code></pre>



</details>

<a name="(svg=0x0)_container_add"></a>

## Function `add`

Add a shape to a container.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_add">add</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>, <a href="./shape.md#(svg=0x0)_shape">shape</a>: (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_add">add</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> <a href="./container.md#(svg=0x0)_container_Container">Container</a>, <a href="./shape.md#(svg=0x0)_shape">shape</a>: Shape) {
    <a href="./container.md#(svg=0x0)_container">container</a>.shapes.push_back(<a href="./shape.md#(svg=0x0)_shape">shape</a>);
}
</code></pre>



</details>

<a name="(svg=0x0)_container_animation_mut"></a>

## Function `animation_mut`

Access Option with <code>Animation</code>, fill, extract and so on.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_animation_mut">animation_mut</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>): &<b>mut</b> <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_animation_mut">animation_mut</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> <a href="./container.md#(svg=0x0)_container_Container">Container</a>): &<b>mut</b> Option&lt;Animation&gt; {
    &<b>mut</b> <a href="./container.md#(svg=0x0)_container">container</a>.<a href="./animation.md#(svg=0x0)_animation">animation</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_container_attributes_mut"></a>

## Function `attributes_mut`

Get a mutable reference to the attributes of a container.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_attributes_mut">attributes_mut</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>): &<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_attributes_mut">attributes_mut</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<b>mut</b> <a href="./container.md#(svg=0x0)_container_Container">Container</a>): &<b>mut</b> VecMap&lt;String, String&gt; {
    &<b>mut</b> <a href="./container.md#(svg=0x0)_container">container</a>.attributes
}
</code></pre>



</details>

<a name="(svg=0x0)_container_map_attributes"></a>

## Macro function `map_attributes`

Map attributes of the <code><a href="./container.md#(svg=0x0)_container_Container">Container</a></code>.

```rust
let mut container = container::g(vector[
shape::circle(5).move_to(10, 10),
shape::ellipse(30, 30, 10, 5),
]).map_attributes!(|attrs| {
attrs.insert(b"fill".to_string(), b"red".to_string());
attrs.insert(b"stroke".to_string(), b"black".to_string());
});
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_map_attributes">map_attributes</a>($self: (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>, $f: |&<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;| -&gt; ()): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_map_attributes">map_attributes</a>($self: <a href="./container.md#(svg=0x0)_container_Container">Container</a>, $f: |&<b>mut</b> VecMap&lt;String, String&gt;|): <a href="./container.md#(svg=0x0)_container_Container">Container</a> {
    <b>let</b> <b>mut</b> self = $self;
    <b>let</b> attributes = self.<a href="./container.md#(svg=0x0)_container_attributes_mut">attributes_mut</a>();
    $f(attributes);
    self
}
</code></pre>



</details>

<a name="(svg=0x0)_container_name"></a>

## Function `name`

Simplification to not create functions for each container invariant.

TODO: replace with constants in the future release, when compiler bug is fixed.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_name">name</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_name">name</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<a href="./container.md#(svg=0x0)_container_Container">Container</a>): String {
    match (&<a href="./container.md#(svg=0x0)_container">container</a>.<a href="./container.md#(svg=0x0)_container">container</a>) {
        0 =&gt; b"".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        1 =&gt; b"<a href="./container.md#(svg=0x0)_container_a">a</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        2 =&gt; b"<a href="./container.md#(svg=0x0)_container_defs">defs</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        3 =&gt; b"<a href="./container.md#(svg=0x0)_container_g">g</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        4 =&gt; b"<a href="./container.md#(svg=0x0)_container_marker">marker</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        5 =&gt; b"clipPath".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        6 =&gt; b"<a href="./container.md#(svg=0x0)_container_symbol">symbol</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        7 =&gt; b"<a href="./container.md#(svg=0x0)_container_mask">mask</a>".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(),
        _ =&gt; <b>abort</b>,
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_container_to_string"></a>

## Function `to_string`

Print the container as an <code>SVG</code> element.


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./container.md#(svg=0x0)_container_Container">container::Container</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(<a href="./container.md#(svg=0x0)_container">container</a>: &<a href="./container.md#(svg=0x0)_container_Container">Container</a>): String {
    <b>if</b> (<a href="./container.md#(svg=0x0)_container">container</a>.<a href="./container.md#(svg=0x0)_container">container</a> == <a href="./container.md#(svg=0x0)_container_TYPE_ROOT">TYPE_ROOT</a>) {
        <b>return</b> <a href="./container.md#(svg=0x0)_container">container</a>.shapes.fold!(b"".<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>(), |<b>mut</b> acc, <a href="./shape.md#(svg=0x0)_shape">shape</a>| {
            acc.append(<a href="./shape.md#(svg=0x0)_shape">shape</a>.<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>());
            acc
        })
    };
    <b>let</b> <b>mut</b> contents = <a href="./container.md#(svg=0x0)_container">container</a>.shapes.map!(|<a href="./shape.md#(svg=0x0)_shape">shape</a>| <a href="./shape.md#(svg=0x0)_shape">shape</a>.<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>());
    <a href="./container.md#(svg=0x0)_container">container</a>.<a href="./animation.md#(svg=0x0)_animation">animation</a>.do_ref!(|<a href="./animation.md#(svg=0x0)_animation">animation</a>| contents.push_back(<a href="./animation.md#(svg=0x0)_animation">animation</a>.<a href="./container.md#(svg=0x0)_container_to_string">to_string</a>()));
    <a href="./print.md#(svg=0x0)_print_print">print::print</a>(
        <a href="./container.md#(svg=0x0)_container">container</a>.<a href="./container.md#(svg=0x0)_container_name">name</a>(),
        <a href="./container.md#(svg=0x0)_container">container</a>.attributes,
        option::some(contents),
    )
}
</code></pre>



</details>
