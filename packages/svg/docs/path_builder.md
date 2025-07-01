
<a name="(svg=0x0)_path_builder"></a>

# Module `(svg=0x0)::path_builder`

Builder for SVG paths. Should be optimized or used once for a setup, rather
than building paths on every step (unless absolutely necessary).


-  [Struct `Path`](#(svg=0x0)_path_builder_Path)
-  [Enum `Command`](#(svg=0x0)_path_builder_Command)
-  [Function `new`](#(svg=0x0)_path_builder_new)
-  [Function `move_to`](#(svg=0x0)_path_builder_move_to)
-  [Function `line_to`](#(svg=0x0)_path_builder_line_to)
-  [Function `horizontal_line_to`](#(svg=0x0)_path_builder_horizontal_line_to)
-  [Function `vertical_line_to`](#(svg=0x0)_path_builder_vertical_line_to)
-  [Function `close_path`](#(svg=0x0)_path_builder_close_path)
-  [Function `curve_to`](#(svg=0x0)_path_builder_curve_to)
-  [Function `smooth_curve_to`](#(svg=0x0)_path_builder_smooth_curve_to)
-  [Function `quadratic_bezier_curve_to`](#(svg=0x0)_path_builder_quadratic_bezier_curve_to)
-  [Function `smooth_quadratic_bezier_curve_to`](#(svg=0x0)_path_builder_smooth_quadratic_bezier_curve_to)
-  [Function `elliptical_arc`](#(svg=0x0)_path_builder_elliptical_arc)
-  [Function `build`](#(svg=0x0)_path_builder_build)
-  [Function `to_string`](#(svg=0x0)_path_builder_to_string)
-  [Function `command_to_string`](#(svg=0x0)_path_builder_command_to_string)


<pre><code><b>use</b> (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/animation.md#(svg=0x0)_animation">animation</a>;
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



<a name="(svg=0x0)_path_builder_Path"></a>

## Struct `Path`

The builder for the SVG path attribute.


<pre><code><b>public</b> <b>struct</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>contents: vector&lt;(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Command">path_builder::Command</a>&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(svg=0x0)_path_builder_Command"></a>

## Enum `Command`

The commands that can be used to build a path.


<pre><code><b>public</b> <b>enum</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Command">Command</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>MoveTo</code>
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
Variant <code>LineTo</code>
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
Variant <code>HorizontalLineTo</code>
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
Variant <code>VerticalLineTo</code>
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
Variant <code>ClosePath</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>CurveTo</code>
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


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>3: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>4: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>5: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>SmoothCurveTo</code>
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


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>3: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>QuadraticBezierCurveTo</code>
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


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>3: u16</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>SmoothQuadraticBezierCurveTo</code>
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
Variant <code>EllipticalArc</code>
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


<dl>
<dt>
<code>2: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>3: bool</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>4: bool</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>5: u16</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>6: u16</code>
</dt>
<dd>
</dd>
</dl>

</dl>


</details>

<a name="(svg=0x0)_path_builder_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_new">new</a>(): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_new">new</a>(): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> { contents: vector[] }
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_move_to"></a>

## Function `move_to`

Adds the <code>M x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_move_to">move_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_move_to">move_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::MoveTo(x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_line_to"></a>

## Function `line_to`

Adds the <code>L x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_line_to">line_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_line_to">line_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::LineTo(x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_horizontal_line_to"></a>

## Function `horizontal_line_to`

Adds the <code>H x</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_horizontal_line_to">horizontal_line_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_horizontal_line_to">horizontal_line_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::HorizontalLineTo(x));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_vertical_line_to"></a>

## Function `vertical_line_to`

Adds the <code>V y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_vertical_line_to">vertical_line_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_vertical_line_to">vertical_line_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::VerticalLineTo(y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_close_path"></a>

## Function `close_path`

Adds the <code>Z</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_close_path">close_path</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_close_path">close_path</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::ClosePath);
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_curve_to"></a>

## Function `curve_to`

Adds the <code>C x1 y1 x2 y2 x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_curve_to">curve_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x1: u16, y1: u16, x2: u16, y2: u16, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_curve_to">curve_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x1: u16, y1: u16, x2: u16, y2: u16, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::CurveTo(x1, y1, x2, y2, x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_smooth_curve_to"></a>

## Function `smooth_curve_to`

Adds the <code>S x2 y2 x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_smooth_curve_to">smooth_curve_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x2: u16, y2: u16, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_smooth_curve_to">smooth_curve_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x2: u16, y2: u16, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::SmoothCurveTo(x2, y2, x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_quadratic_bezier_curve_to"></a>

## Function `quadratic_bezier_curve_to`

Adds the <code>Q x1 y1 x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_quadratic_bezier_curve_to">quadratic_bezier_curve_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x1: u16, y1: u16, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_quadratic_bezier_curve_to">quadratic_bezier_curve_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x1: u16, y1: u16, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::QuadraticBezierCurveTo(x1, y1, x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_smooth_quadratic_bezier_curve_to"></a>

## Function `smooth_quadratic_bezier_curve_to`

Adds the <code>T x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_smooth_quadratic_bezier_curve_to">smooth_quadratic_bezier_curve_to</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_smooth_quadratic_bezier_curve_to">smooth_quadratic_bezier_curve_to</a>(<b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, x: u16, y: u16): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path.contents.push_back(Command::SmoothQuadraticBezierCurveTo(x, y));
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_elliptical_arc"></a>

## Function `elliptical_arc`

Adds the <code>A rx ry x_axis_rotation large_arc_flag sweep_flag x y</code> command to the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_elliptical_arc">elliptical_arc</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, rx: u16, ry: u16, x_axis_rotation: u16, large_arc_flag: bool, sweep_flag: bool, x: u16, y: u16): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_elliptical_arc">elliptical_arc</a>(
    <b>mut</b> path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>,
    rx: u16,
    ry: u16,
    x_axis_rotation: u16,
    large_arc_flag: bool,
    sweep_flag: bool,
    x: u16,
    y: u16,
): <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a> {
    path
        .contents
        .push_back(
            Command::EllipticalArc(rx, ry, x_axis_rotation, large_arc_flag, sweep_flag, x, y),
        );
    path
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_build"></a>

## Function `build`

Builds a <code>Shape</code> from the path.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_build">build</a>(path: (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>, length: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;u16&gt;): (<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/shape.md#(svg=0x0)_shape_Shape">shape::Shape</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_build">build</a>(path: <a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>, length: Option&lt;u16&gt;): Shape {
    <a href="../svg/shape.md#(svg=0x0)_shape_path">shape::path</a>(path.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>(), length)
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_to_string"></a>

## Function `to_string`

Converts a path into a <code>String</code> that can be used as an SVG path attribute.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>(path: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">path_builder::Path</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>(path: &<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Path">Path</a>): String {
    path.contents.fold!(b"".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>(), |<b>mut</b> acc, cmd| { acc.append(cmd.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>()); acc })
}
</code></pre>



</details>

<a name="(svg=0x0)_path_builder_command_to_string"></a>

## Function `command_to_string`

Converts a command to a string.


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_command_to_string">command_to_string</a>(cmd: &(<a href="../svg/svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Command">path_builder::Command</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../svg/path_builder.md#(svg=0x0)_path_builder_command_to_string">command_to_string</a>(cmd: &<a href="../svg/path_builder.md#(svg=0x0)_path_builder_Command">Command</a>): String {
    match (*cmd) {
        Command::MoveTo(x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"M".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::LineTo(x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"L".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::HorizontalLineTo(x) =&gt; {
            <b>let</b> <b>mut</b> res = b"H".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::VerticalLineTo(y) =&gt; {
            <b>let</b> <b>mut</b> res = b"V".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::ClosePath =&gt; b"Z".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>(),
        Command::CurveTo(x1, y1, x2, y2, x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"C".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x1.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y1.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x2.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y2.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::SmoothCurveTo(x2, y2, x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"S".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x2.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y2.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::QuadraticBezierCurveTo(x1, y1, x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"Q".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x1.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y1.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::SmoothQuadraticBezierCurveTo(x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"T".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
        Command::EllipticalArc(rx, ry, x_axis_rotation, large_arc_flag, sweep_flag, x, y) =&gt; {
            <b>let</b> <b>mut</b> res = b"A".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>();
            res.append(rx.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(ry.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x_axis_rotation.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(<b>if</b> (large_arc_flag) {
                b"1"
            } <b>else</b> {
                b"0"
            }.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(<b>if</b> (sweep_flag) {
                b"1"
            } <b>else</b> {
                b"0"
            }.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(x.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(b",".<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res.append(y.<a href="../svg/path_builder.md#(svg=0x0)_path_builder_to_string">to_string</a>());
            res
        },
    }
}
</code></pre>



</details>
