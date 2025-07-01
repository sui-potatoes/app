
<a name="(svg=0x0)_shape"></a>

# Module `(svg=0x0)::shape`

Module: shapes


-  [Struct `Shape`](#(svg=0x0)_shape_Shape)
-  [Struct `Stop`](#(svg=0x0)_shape_Stop)
-  [Enum `ShapeType`](#(svg=0x0)_shape_ShapeType)
-  [Constants](#@Constants_0)
-  [Function `circle`](#(svg=0x0)_shape_circle)
-  [Function `ellipse`](#(svg=0x0)_shape_ellipse)
        -  [Description](#@Description_1)
-  [Function `filter`](#(svg=0x0)_shape_filter)
        -  [Description](#@Description_2)
        -  [Usage](#@Usage_3)
-  [Function `line`](#(svg=0x0)_shape_line)
        -  [Description](#@Description_4)
-  [Function `rect`](#(svg=0x0)_shape_rect)
        -  [Description](#@Description_5)
-  [Function `text`](#(svg=0x0)_shape_text)
        -  [Description](#@Description_6)
-  [Function `path`](#(svg=0x0)_shape_path)
        -  [Description](#@Description_7)
-  [Function `use_`](#(svg=0x0)_shape_use_)
        -  [Description](#@Description_8)
-  [Function `linear_gradient`](#(svg=0x0)_shape_linear_gradient)
        -  [Description](#@Description_9)
-  [Function `radial_gradient`](#(svg=0x0)_shape_radial_gradient)
        -  [Description](#@Description_10)
-  [Function `custom`](#(svg=0x0)_shape_custom)
        -  [Description](#@Description_11)
-  [Function `stop`](#(svg=0x0)_shape_stop)
-  [Function `add_stop`](#(svg=0x0)_shape_add_stop)
-  [Function `move_to`](#(svg=0x0)_shape_move_to)
-  [Function `name`](#(svg=0x0)_shape_name)
-  [Function `to_string`](#(svg=0x0)_shape_to_string)
-  [Function `attributes`](#(svg=0x0)_shape_attributes)
-  [Function `attributes_mut`](#(svg=0x0)_shape_attributes_mut)
-  [Function `set_attributes`](#(svg=0x0)_shape_set_attributes)
-  [Function `add_animation`](#(svg=0x0)_shape_add_animation)
-  [Function `animation_mut`](#(svg=0x0)_shape_animation_mut)
-  [Macro function `map_attributes`](#(svg=0x0)_shape_map_attributes)


<pre><code><b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point">point</a>;
<b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/print.md#(svg=0x0)_print">print</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
</code></pre>



<a name="(svg=0x0)_shape_Shape"></a>

## Struct `Shape`

SVG shape struct, contains a shape type and a set of attributes.


<pre><code><b>public</b> <b>struct</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_ShapeType">shape::ShapeType</a></code>
</dt>
<dd>
 The shape type, such as a circle, rectangle, or path.
</dd>
<dt>
<code><a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;</code>
</dt>
<dd>
 A set of attributes for the shape.
</dd>
<dt>
<code><a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>&gt;</code>
</dt>
<dd>
 An optional animation to apply to the shape.
</dd>
<dt>
<code>position: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a>&gt;</code>
</dt>
<dd>
 An optional position for the shape, changed in the <code><a href="../svg/shape.md#(svg=0x0)_shape_move_to">move_to</a></code> function.
</dd>
</dl>


</details>

<a name="(svg=0x0)_shape_Stop"></a>

## Struct `Stop`

A stop element for a gradient nodes (<code>linearGradient</code>, <code>radialGradient</code>).


<pre><code><b>public</b> <b>struct</b> <a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>offset: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
<dt>
<code>color: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(svg=0x0)_shape_ShapeType"></a>

## Enum `ShapeType`

SVG shape enum. Each variant represents a different shape, all of them
containing a set of attributes as a <code>VecMap</code>.


<pre><code><b>public</b> <b>enum</b> <a href="../svg/shape.md#(svg=0x0)_shape_ShapeType">ShapeType</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Circle</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Ellipse</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Filter</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>ForeignObject</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Line</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Image</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Polygon</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Polyline</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/point.md#(svg=0x0)_point_Point">point::Point</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Rect</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Text</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>TextWithTextPath</code>
</dt>
<dd>
 Text with text path shape, a text element with a string and a path.
 Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>&gt;&lt;textPath&gt;</code> (group)
 Own properties:
 - <code><a href="../svg/shape.md#(svg=0x0)_shape_text">text</a></code> - the text to display.
 - <code><a href="../svg/shape.md#(svg=0x0)_shape_path">path</a></code> - the path to follow.
 Inherited properties:
 - <code>x</code> - the x-coordinate of the text.
 - <code>y</code> - the y-coordinate of the text.
 See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/textPath
</dd>

<dl>
<dt>
<code><a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>href: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Path</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>1: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;u16&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Use</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>View</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: vector&lt;u16&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>LinearGradient</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>stops: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Stop">shape::Stop</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>RadialGradient</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>stops: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Stop">shape::Stop</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Custom</code>
</dt>
<dd>
</dd>

<dl>
<dt>
<code>0: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a></code>
</dt>
<dd>
</dd>
</dl>

</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="(svg=0x0)_shape_ENotImplemented"></a>

Abort code for the <code>NotImplemented</code> error.


<pre><code><b>const</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>: u64 = 264;
</code></pre>



<a name="(svg=0x0)_shape_circle"></a>

## Function `circle`

Create a new circle shape.
Circle shape, a circle with a center and a radius.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_circle">circle</a>&gt;</code>

Own properties:
- <code>r</code> - the radius of the circle.

Inherited properties:
- <code>cx</code> - the x-coordinate of the circle.
- <code>cy</code> - the y-coordinate of the circle.

Extended properties:
- <code>pathLength</code> - the total length of the path.
- <code>transform</code> - a transformation to apply to the circle.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/circle


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_circle">circle</a>(r: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_circle">circle</a>(r: u16): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Circle(r),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_ellipse"></a>

## Function `ellipse`

Create a new ellipse <code><a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a></code>.


<a name="@Description_1"></a>

#### Description


Ellipse shape, a circle that is stretched in one direction.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_ellipse">ellipse</a>&gt;</code>

Own properties:
- <code>pc</code> - the point of the center of the ellipse.
- <code>rx</code> - the radius of the ellipse in the x-axis.
- <code>ry</code> - the radius of the ellipse in the y-axis.

Inherited properties:
- <code>x</code> - the x-coordinate of the ellipse.
- <code>y</code> - the y-coordinate of the ellipse.

Extended properties:
- <code>pathLength</code> - the total length of the path.
- <code>transform</code> - a transformation to apply to the ellipse.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/ellipse

```rust
let cx = 1400;
let cy = 1400;
let rx = 100;
let ry = 50;

let ellipse = shape::ellipse(cx, cy, rx, ry);

ellipse.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_ellipse">ellipse</a>(cx: u16, cy: u16, rx: u16, ry: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_ellipse">ellipse</a>(cx: u16, cy: u16, rx: u16, ry: u16): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Ellipse(<a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(cx, cy), rx, ry),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_filter"></a>

## Function `filter`

Create a new filter element with the given id and a list of filter elements.


<a name="@Description_2"></a>

#### Description


Filter shape, a filter element that can be applied to other elements. Must
be used inside a <code>defs</code> container, contains an <code>id</code> and a list of filters
such as <code>feGaussianBlur</code>, <code>feColorMatrix</code>, and <code>feBlend</code>.

Element: <code>&lt;<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>&gt;</code>

Own properties:
- <code>id</code> - the id of the filter.
- <code>filters</code> - a list of filter elements.

Extended properties: none


<a name="@Usage_3"></a>

#### Usage


```rust
let filter = shape::filter(b"f1".to_string(), vector[
filter::gaussian_blur(5),
filter::color_matrix(b"grayscale"),
]);

let mut svg = svg::svg(vector[0, 0, 100, 100]);
svg.add_root(vector[filter]);
let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/filter.md#(svg=0x0)_filter">filter</a>(id: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, filters: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/filter.md#(svg=0x0)_filter_Filter">filter::Filter</a>&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/filter.md#(svg=0x0)_filter">filter</a>(id: String, filters: vector&lt;Filter&gt;): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Filter(id, filters),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_line"></a>

## Function `line`

Create a new line shape.


<a name="@Description_4"></a>

#### Description


Line shape, a line that connects two points, each point is a pair
of <code>x</code> and <code>y</code>.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_line">line</a>&gt;</code>

Own properties:
- p0 - the first point.
- p1 - the second point.

Extended properties:
- <code>pathLength</code> - the total length of the path.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/line


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_line">line</a>(x1: u16, y1: u16, x2: u16, y2: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_line">line</a>(x1: u16, y1: u16, x2: u16, y2: u16): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Line(<a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x1, y1), <a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x2, y2)),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_rect"></a>

## Function `rect`

Create a new rectangle shape.


<a name="@Description_5"></a>

#### Description


Rectangle shape, a rectangle with a position, width, and height.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_rect">rect</a>&gt;</code>

Own properties:
- <code>width</code> - the width of the rectangle.
- <code>height</code> - the height of the rectangle.

Extended properties:
- <code>rx</code> - the radius of the rectangle in the x-axis.
- <code>ry</code> - the radius of the rectangle in the y-axis.
- <code>pathLength</code> - the total length of the path.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/rect


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_rect">rect</a>(width: u16, height: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_rect">rect</a>(width: u16, height: u16): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Rect(width, height),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_text"></a>

## Function `text`

Create a new <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>&gt;</code> shape.


<a name="@Description_6"></a>

#### Description


Text shape, a text element with a string and a position.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>&gt;</code>

Own properties:
- <code><a href="../svg/shape.md#(svg=0x0)_shape_text">text</a></code> - the text to display.
- <code><a href="../svg/shape.md#(svg=0x0)_shape_path">path</a></code> - an optional <code>TextPath</code> element.

Inherited properties:
- <code>x</code> - the x-coordinate of the text.
- <code>y</code> - the y-coordinate of the text.

Extended properties:
- <code>dx</code> - the x-offset of the text.
- <code>dy</code> - the y-offset of the text.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>: String): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Text(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_path"></a>

## Function `path`

Create a new <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>&gt;</code> shape.


<a name="@Description_7"></a>

#### Description


Path shape, a shape defined by a path string. The path string is
a series of commands and coordinates. The <code>length</code> attribute is
optional and specifies the total length of the path.

Element: <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>&gt;</code>

Own properties:
- <code><a href="../svg/shape.md#(svg=0x0)_shape_path">path</a></code> - the path string.
- <code>length</code> - the total length of the path.

Inherited properties:
- <code>x</code> - the x-coordinate of the path.
- <code>y</code> - the y-coordinate of the path.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/path

```rust
let path_string = b"M 10 10 L 20 20".to_string();
let path = shape::path(path_string, option::none());

let mut svg = svg::svg(vector[0, 0, 100, 100]);
svg.add_root(vector[path]);

let str = svg.to_string();
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>(<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, length: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;u16&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>(<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>: String, length: Option&lt;u16&gt;): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Path(<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>, length),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_use_"></a>

## Function `use_`

Create a new <code>&lt;<b>use</b>&gt;</code> shape.


<a name="@Description_8"></a>

#### Description


Use shape, a reference to a shape defined elsewhere in the document.

Element: <code>&lt;<b>use</b>&gt;</code>

Own properties:
- <code>href</code> - the id of the shape to reference.

Inherited properties:
- <code>x</code> - the x-coordinate of the shape.
- <code>y</code> - the y-coordinate of the shape.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/use


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_use_">use_</a>(href: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_use_">use_</a>(href: String): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Use(href),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_linear_gradient"></a>

## Function `linear_gradient`

Create a new <code>&lt;linearGradient&gt;</code> shape.


<a name="@Description_9"></a>

#### Description


Part of the <code>defs</code> container, a shape that is not a standard SVG shape.

Element: <code>&lt;linearGradient&gt;</code>

Own properties:
- <code>stops</code> - a list of stop elements.

Inherited properties: none

Extended properties:
- <code>x1</code> - the x-coordinate of the start of the gradient.
- <code>y1</code> - the y-coordinate of the start of the gradient.
- <code>x2</code> - the x-coordinate of the end of the gradient.
- <code>y2</code> - the y-coordinate of the end of the gradient.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/linearGradient


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_linear_gradient">linear_gradient</a>(stops: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Stop">shape::Stop</a>&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_linear_gradient">linear_gradient</a>(stops: vector&lt;<a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a>&gt;): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::LinearGradient { stops },
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_radial_gradient"></a>

## Function `radial_gradient`

Create a new <code>&lt;radialGradient&gt;</code> shape.


<a name="@Description_10"></a>

#### Description


Part of the <code>defs</code> container, a shape that is not a standard SVG shape.
A radial gradient is a gradient that starts from a center point and
spreads out in all directions.

Element: <code>&lt;radialGradient&gt;</code>

Inherited properties: none

Own properties:
- <code>stops</code> - a list of stop elements.

Extended properties:
- <code>cx</code> - the x-coordinate of the center of the gradient.
- <code>cy</code> - the y-coordinate of the center of the gradient.
- <code>r</code> - the radius of the gradient.

See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/radialGradient


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_radial_gradient">radial_gradient</a>(stops: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Stop">shape::Stop</a>&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_radial_gradient">radial_gradient</a>(stops: vector&lt;<a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a>&gt;): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::RadialGradient { stops },
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_custom"></a>

## Function `custom`

Create a new custom shape.


<a name="@Description_11"></a>

#### Description


Custom string, allows for custom expressions passed as a string.

Own properties: none

Inherited properties: none

Extended properties: none


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_custom">custom</a>(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_custom">custom</a>(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>: String): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
        <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: ShapeType::Custom(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>),
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>: vec_map::empty(),
        <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: option::none(),
        position: option::none(),
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_stop"></a>

## Function `stop`

Create a new <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>&gt;</code> element for a gradient node (<code>linearGradient</code>, <code>radialGradient</code>).


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>(offset: vector&lt;u8&gt;, color: vector&lt;u8&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Stop">shape::Stop</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>(offset: vector&lt;u8&gt;, color: vector&lt;u8&gt;): <a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a> {
    <a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a> { offset: offset.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), color: color.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>() }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_add_stop"></a>

## Function `add_stop`

Adds a <code>&lt;<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>&gt;</code> element to a gradient.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_add_stop">add_stop</a>(gradient: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>, offset: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, color: <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_add_stop">add_stop</a>(gradient: &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>, offset: String, color: String) {
    <b>let</b> stops = match (&<b>mut</b> gradient.<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>) {
        ShapeType::LinearGradient { stops } =&gt; stops,
        ShapeType::RadialGradient { stops } =&gt; stops,
        _ =&gt; <b>abort</b>,
    };
    stops.push_back(<a href="../svg/shape.md#(svg=0x0)_shape_Stop">Stop</a> { offset, color });
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_move_to"></a>

## Function `move_to`

Move a shape, add <code>x</code> and <code>y</code> to the attributes of the shape.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_move_to">move_to</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_move_to">move_to</a>(<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>, x: u16, y: u16): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <b>let</b> shape_type = &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>;
    match (shape_type) {
        ShapeType::Circle(_) =&gt; {
            <b>let</b> (cx, cy) = <a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x, y).to_values();
            <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"cx".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), cx.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"cy".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), cy.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
        },
        ShapeType::Line(p0, p1) =&gt; {
            <b>let</b> (x1, y1) = p0.to_values();
            <b>let</b> (x2, y2) = p1.to_values();
            *p0 = <a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x, y);
            *p1 = <a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x + x2 - x1, y + y2 - y1);
        },
        ShapeType::Polygon(_points) =&gt; <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>,
        ShapeType::Polyline(_points) =&gt; <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>,
        ShapeType::Path(_path, _length) =&gt; {
            <b>let</b> <b>mut</b> value = b"translate(".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>();
            value.append(x.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            value.append(b", ".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            value.append(y.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            value.append(b")".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes_mut">attributes_mut</a>().insert(b"transform".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), value);
        },
        _ =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.position = option::some(<a href="../svg/point.md#(svg=0x0)_point_point">point::point</a>(x, y));
        },
    };
    <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_name"></a>

## Function `name`

Simplification to not create functions for each container invariant.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_name">name</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_name">name</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>): String {
    match (<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>) {
        ShapeType::Circle(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_circle">circle</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Ellipse(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_ellipse">ellipse</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Filter(..) =&gt; b"<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Line(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_line">line</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::LinearGradient { .. } =&gt; b"linearGradient".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Path(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Polygon(..) =&gt; <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>,
        ShapeType::Polyline(..) =&gt; <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>,
        ShapeType::RadialGradient { .. } =&gt; b"radialGradient".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Rect(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_rect">rect</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Text(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::TextWithTextPath { .. } =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Use(..) =&gt; b"<b>use</b>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        ShapeType::Custom(..) =&gt; b"<a href="../svg/shape.md#(svg=0x0)_shape_custom">custom</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
        _ =&gt; <b>abort</b>,
    }
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_to_string"></a>

## Function `to_string`

Print the shape as an <code>SVG</code> element.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(base_shape: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(base_shape: &<a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>): String {
    <b>let</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> { <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>, position, <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>, <a href="../svg/animation.md#(svg=0x0)_animation">animation</a> } = base_shape;
    <b>let</b> <b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = *<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>;
    position.do_ref!(|<a href="../svg/point.md#(svg=0x0)_point">point</a>| {
        <b>let</b> (x, y) = <a href="../svg/point.md#(svg=0x0)_point">point</a>.to_values();
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"x".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), x.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
        <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"y".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), y.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
    });
    <b>let</b> (<a href="../svg/shape.md#(svg=0x0)_shape_name">name</a>, <b>mut</b> contents) = match (<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>) {
        ShapeType::Circle(r) =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"r".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), (*r).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_circle">circle</a>", option::none())
        },
        ShapeType::Ellipse(center, rx, ry) =&gt; {
            <b>let</b> (cx, cy) = center.to_values();
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"cx".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), cx.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"cy".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), cy.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"rx".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), (*rx).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"ry".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), (*ry).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_ellipse">ellipse</a>", option::none())
        },
        ShapeType::Filter(id, filters) =&gt; {
            <b>let</b> filters = filters.map_ref!(|<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>| <a href="../svg/filter.md#(svg=0x0)_filter">filter</a>.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"id".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), *id);
            (b"<a href="../svg/filter.md#(svg=0x0)_filter">filter</a>", option::some(filters))
        },
        ShapeType::Line(p0, p1) =&gt; {
            <b>let</b> (x1, y1) = p0.to_values();
            <b>let</b> (x2, y2) = p1.to_values();
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"x1".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), x1.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"y1".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), y1.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"x2".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), x2.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"y2".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), y2.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_line">line</a>", option::none())
        },
        ShapeType::Polygon(_points) =&gt; {
            <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>
        },
        ShapeType::Polyline(_points) =&gt; {
            <b>abort</b> <a href="../svg/shape.md#(svg=0x0)_shape_ENotImplemented">ENotImplemented</a>
        },
        ShapeType::Rect(width, height) =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"width".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), (*width).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"height".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), (*height).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_rect">rect</a>", option::none())
        },
        ShapeType::Text(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>) =&gt; (b"<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>", option::some(vector[*<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>])),
        ShapeType::TextWithTextPath { <a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>, href } =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"href".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), *href);
            // <a href="../svg/print.md#(svg=0x0)_print">print</a> the textPath element <b>as</b> a string
            <b>let</b> text_path = <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(
                b"textPath".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
                <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>,
                option::some(vector[*<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>]),
            );
            // unset all <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> <b>for</b> the <a href="../svg/shape.md#(svg=0x0)_shape_text">text</a> element
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = vec_map::empty();
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>", option::some(vector[text_path]))
        },
        ShapeType::Use(href) =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"href".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), *href);
            (b"<b>use</b>", option::none())
        },
        ShapeType::Path(<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>, length) =&gt; {
            <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"d".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), *<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>);
            length.do_ref!(
                |value| <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(
                    b"length".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
                    (*value).<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(),
                ),
            );
            (b"<a href="../svg/shape.md#(svg=0x0)_shape_path">path</a>", option::none())
        },
        ShapeType::LinearGradient { stops } =&gt; {
            <b>let</b> stops = stops.map_ref!(|<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>| {
                <b>let</b> <b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = vec_map::empty();
                <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"offset".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>.offset);
                <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>-color".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>.color);
                <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(b"<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>, option::none())
            });
            (b"linearGradient", option::some(stops))
        },
        ShapeType::RadialGradient { stops } =&gt; {
            <b>let</b> stops = stops.map_ref!(|<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>| {
                <b>let</b> <b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = vec_map::empty();
                <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"offset".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>.offset);
                <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>.insert(b"<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>-color".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>.color);
                <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(b"<a href="../svg/shape.md#(svg=0x0)_shape_stop">stop</a>".<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>, option::none())
            });
            (b"radialGradient", option::some(stops))
        },
        ShapeType::Custom(<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>) =&gt; <b>return</b> *<a href="../svg/shape.md#(svg=0x0)_shape_text">text</a>,
        _ =&gt; <b>abort</b>,
    };
    <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>.do_ref!(|el| {
        contents = contents.map!(|<b>mut</b> contents| {
                contents.push_back(el.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>());
                contents
            }).or!(option::some(vector[el.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>()]));
    });
    <a href="../svg/print.md#(svg=0x0)_print_print">print::print</a>(<a href="../svg/shape.md#(svg=0x0)_shape_name">name</a>.<a href="../svg/shape.md#(svg=0x0)_shape_to_string">to_string</a>(), <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>, contents)
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_attributes"></a>

## Function `attributes`

Get a reference to the attributes of a shape.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>): &<a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>): &VecMap&lt;String, String&gt; {
    &<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_attributes_mut"></a>

## Function `attributes_mut`

Get a mutable reference to the attributes of a shape.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes_mut">attributes_mut</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>): &<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes_mut">attributes_mut</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>): &<b>mut</b> VecMap&lt;String, String&gt; {
    &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_set_attributes"></a>

## Function `set_attributes`

Set the attributes of a shape.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_set_attributes">set_attributes</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>, attrs: <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_set_attributes">set_attributes</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>, attrs: VecMap&lt;String, String&gt;) {
    <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = attrs;
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_add_animation"></a>

## Function `add_animation`

Add an attribute to a shape.

```rust
use svg::{animation, shape};

let mut shape = shape::rect(10, 10);
let animation = animation::set(b"5")
.attribute_name(b"r")
.duration(b"10s")
.repeat_count(b"indefinite");

shape.add_animation(animation);
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_add_animation">add_animation</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>, <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_add_animation">add_animation</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>, <a href="../svg/animation.md#(svg=0x0)_animation">animation</a>: Animation) {
    <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/animation.md#(svg=0x0)_animation">animation</a> = option::some(<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>);
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_animation_mut"></a>

## Function `animation_mut`

Get a mutable reference to the animation field.

```rust
use svg::{animation, shape};

let mut shape = shape::rect(10, 10);
let animation = animation::set(b"5")
.attribute_name(b"r")
.duration(b"10s")
.repeat_count(b"indefinite");

shape.add_animation(animation);
shape.animation_mut().extract(); // remove animation
```


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_animation_mut">animation_mut</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>): &<b>mut</b> <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation_Animation">animation::Animation</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_animation_mut">animation_mut</a>(<a href="../svg/shape.md#(svg=0x0)_shape">shape</a>: &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>): &<b>mut</b> Option&lt;Animation&gt; {
    &<b>mut</b> <a href="../svg/shape.md#(svg=0x0)_shape">shape</a>.<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>
}
</code></pre>



</details>

<a name="(svg=0x0)_shape_map_attributes"></a>

## Macro function `map_attributes`

Map over the attributes of the animation.

```rust
let mut animation = shape::circle(10).move_to(20, 20).map_attributes!(|attrs| {
attrs.insert(b"fill".to_string(), b"red".to_string());
attrs.insert(b"stroke".to_string(), b"black".to_string());
});
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_map_attributes">map_attributes</a>($self: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>, $f: |&<b>mut</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map_VecMap">sui::vec_map::VecMap</a>&lt;<a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>, <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>&gt;| -&gt; ()): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="../svg/shape.md#(svg=0x0)_shape_map_attributes">map_attributes</a>($self: <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a>, $f: |&<b>mut</b> VecMap&lt;String, String&gt;|): <a href="../svg/shape.md#(svg=0x0)_shape_Shape">Shape</a> {
    <b>let</b> <b>mut</b> self = $self;
    <b>let</b> <a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a> = self.<a href="../svg/shape.md#(svg=0x0)_shape_attributes_mut">attributes_mut</a>();
    $f(<a href="../svg/shape.md#(svg=0x0)_shape_attributes">attributes</a>);
    self
}
</code></pre>



</details>
