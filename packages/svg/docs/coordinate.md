
<a name="(svg=0x0)_coordinate"></a>

# Module `(svg=0x0)::coordinate`

This module defines a point in 2D space, it should not be used directly, but
is extensively used in the SVG library.


-  [Struct `Coordinate`](#(svg=0x0)_coordinate_Coordinate)
-  [Function `new`](#(svg=0x0)_coordinate_new)
-  [Function `move_to`](#(svg=0x0)_coordinate_move_to)
-  [Function `to_values`](#(svg=0x0)_coordinate_to_values)


<pre><code></code></pre>



<a name="(svg=0x0)_coordinate_Coordinate"></a>

## Struct `Coordinate`

Point struct, represents a point in 2D space.


<pre><code><b>public</b> <b>struct</b> <a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">Coordinate</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="(svg=0x0)_coordinate_new"></a>

## Function `new`

Create a new point.


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_new">new</a>(x: u16, y: u16): (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">coordinate::Coordinate</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_new">new</a>(x: u16, y: u16): <a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">Coordinate</a> { <a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">Coordinate</a>(x, y) }
</code></pre>



</details>

<a name="(svg=0x0)_coordinate_move_to"></a>

## Function `move_to`

Move a point to a new location. Recreates the point with the new x and y.


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_move_to">move_to</a>(point: &<b>mut</b> (<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">coordinate::Coordinate</a>, x: u16, y: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_move_to">move_to</a>(point: &<b>mut</b> <a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">Coordinate</a>, x: u16, y: u16) {
    point.0 = x;
    point.1 = y;
}
</code></pre>



</details>

<a name="(svg=0x0)_coordinate_to_values"></a>

## Function `to_values`

Get the x and y values of a point.


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_to_values">to_values</a>(point: &(<a href="./svg.md#(svg=0x0)_svg">svg</a>=0x0)::<a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">coordinate::Coordinate</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./coordinate.md#(svg=0x0)_coordinate_to_values">to_values</a>(point: &<a href="./coordinate.md#(svg=0x0)_coordinate_Coordinate">Coordinate</a>): (u16, u16) { (point.0, point.1) }
</code></pre>



</details>
