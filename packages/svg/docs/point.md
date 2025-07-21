
<a name="(svg=0x0)_point"></a>

# Module `(svg=0x0)::point`

This module defines a point in 2D space, it should not be used directly, but
is extensively used in the SVG library.


-  [Struct `Point`](#(svg=0x0)_point_Point)
-  [Function `point`](#(svg=0x0)_point_point)
-  [Function `move_to`](#(svg=0x0)_point_move_to)
-  [Function `to_values`](#(svg=0x0)_point_to_values)


<pre><code></code></pre>



<a name="(svg=0x0)_point_Point"></a>

## Struct `Point`

Point struct, represents a point in 2D space.


<pre><code><b>public</b> <b>struct</b> <a href="./point.md#(svg=0x0)_point_Point">Point</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>1: u16</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="(svg=0x0)_point_point"></a>

## Function `point`

Create a new point.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point">point</a>(x: u16, y: u16): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./point.md#(svg=0x0)_point_Point">point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point">point</a>(x: u16, y: u16): <a href="./point.md#(svg=0x0)_point_Point">Point</a> { <a href="./point.md#(svg=0x0)_point_Point">Point</a>(x, y) }
</code></pre>



</details>

<a name="(svg=0x0)_point_move_to"></a>

## Function `move_to`

Move a point to a new location. Recreates the point with the new x and y.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point_move_to">move_to</a>(<a href="./point.md#(svg=0x0)_point">point</a>: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./point.md#(svg=0x0)_point_Point">point::Point</a>, x: u16, y: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point_move_to">move_to</a>(<a href="./point.md#(svg=0x0)_point">point</a>: &<b>mut</b> <a href="./point.md#(svg=0x0)_point_Point">Point</a>, x: u16, y: u16) {
    <a href="./point.md#(svg=0x0)_point">point</a>.0 = x;
    <a href="./point.md#(svg=0x0)_point">point</a>.1 = y;
}
</code></pre>



</details>

<a name="(svg=0x0)_point_to_values"></a>

## Function `to_values`

Get the x and y values of a point.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point_to_values">to_values</a>(<a href="./point.md#(svg=0x0)_point">point</a>: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./point.md#(svg=0x0)_point_Point">point::Point</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#(svg=0x0)_point_to_values">to_values</a>(<a href="./point.md#(svg=0x0)_point">point</a>: &<a href="./point.md#(svg=0x0)_point_Point">Point</a>): (u16, u16) { (<a href="./point.md#(svg=0x0)_point">point</a>.0, <a href="./point.md#(svg=0x0)_point">point</a>.1) }
</code></pre>



</details>
