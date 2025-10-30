
<a name="grid_point"></a>

# Module `grid::point`

Defines the <code><a href="./point.md#grid_point_Point">Point</a></code> type and its methods. Point is a tuple-like struct that
holds two unsigned 16-bit integers, representing the x and y coordinates of
a point in 2D space.


-  [Struct `Point`](#grid_point_Point)
-  [Function `new`](#grid_point_new)
-  [Function `from_vector`](#grid_point_from_vector)
-  [Function `to_values`](#grid_point_to_values)
-  [Function `into_values`](#grid_point_into_values)
-  [Function `to_vector`](#grid_point_to_vector)
-  [Function `x`](#grid_point_x)
-  [Function `y`](#grid_point_y)
-  [Function `is_within_bounds`](#grid_point_is_within_bounds)
-  [Function `manhattan_distance`](#grid_point_manhattan_distance)
-  [Function `chebyshev_distance`](#grid_point_chebyshev_distance)
-  [Function `euclidean_distance`](#grid_point_euclidean_distance)
-  [Function `von_neumann`](#grid_point_von_neumann)
-  [Function `moore`](#grid_point_moore)
-  [Function `le`](#grid_point_le)
-  [Function `to_bytes`](#grid_point_to_bytes)
-  [Function `from_bytes`](#grid_point_from_bytes)
-  [Function `from_bcs`](#grid_point_from_bcs)
-  [Function `to_string`](#grid_point_to_string)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="grid_point_Point"></a>

## Struct `Point`

A point in 2D space. A row (x) and a column (y).


<pre><code><b>public</b> <b>struct</b> <a href="./point.md#grid_point_Point">Point</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="grid_point_new"></a>

## Function `new`

Create a new <code><a href="./point.md#grid_point_Point">Point</a></code> at <code>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>)</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_new">new</a>(<a href="./point.md#grid_point_x">x</a>: u16, <a href="./point.md#grid_point_y">y</a>: u16): <a href="./point.md#grid_point_Point">grid::point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_new">new</a>(<a href="./point.md#grid_point_x">x</a>: u16, <a href="./point.md#grid_point_y">y</a>: u16): <a href="./point.md#grid_point_Point">Point</a> { <a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>) }
</code></pre>



</details>

<a name="grid_point_from_vector"></a>

## Function `from_vector`

Create a <code><a href="./point.md#grid_point_Point">Point</a></code> from a vector of two values.
Ignores the rest of the values in the vector.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_vector">from_vector</a>(v: vector&lt;u16&gt;): <a href="./point.md#grid_point_Point">grid::point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_vector">from_vector</a>(v: vector&lt;u16&gt;): <a href="./point.md#grid_point_Point">Point</a> {
    <a href="./point.md#grid_point_Point">Point</a>(v[0], v[1])
}
</code></pre>



</details>

<a name="grid_point_to_values"></a>

## Function `to_values`

Get a tuple of two values from a <code><a href="./point.md#grid_point_Point">Point</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_values">to_values</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_values">to_values</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): (u16, u16) { <b>let</b> <a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>) = p; (*<a href="./point.md#grid_point_x">x</a>, *<a href="./point.md#grid_point_y">y</a>) }
</code></pre>



</details>

<a name="grid_point_into_values"></a>

## Function `into_values`

Unpack a <code><a href="./point.md#grid_point_Point">Point</a></code> into a tuple of two values.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_into_values">into_values</a>(p: <a href="./point.md#grid_point_Point">grid::point::Point</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_into_values">into_values</a>(p: <a href="./point.md#grid_point_Point">Point</a>): (u16, u16) { <b>let</b> <a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>) = p; (<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>) }
</code></pre>



</details>

<a name="grid_point_to_vector"></a>

## Function `to_vector`

Convert a <code><a href="./point.md#grid_point_Point">Point</a></code> to a vector of two values.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_vector">to_vector</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): vector&lt;u16&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_vector">to_vector</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): vector&lt;u16&gt; { vector[p.0, p.1] }
</code></pre>



</details>

<a name="grid_point_x"></a>

## Function `x`

Get the <code><a href="./point.md#grid_point_x">x</a></code> coordinate of a <code><a href="./point.md#grid_point_Point">Point</a></code>. On the <code>Grid</code>, this is the row.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_x">x</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_x">x</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): u16 { p.0 }
</code></pre>



</details>

<a name="grid_point_y"></a>

## Function `y`

Get the <code><a href="./point.md#grid_point_y">y</a></code> coordinate of a <code><a href="./point.md#grid_point_Point">Point</a></code>. On the <code>Grid</code>, this is the column.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_y">y</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_y">y</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): u16 { p.1 }
</code></pre>



</details>

<a name="grid_point_is_within_bounds"></a>

## Function `is_within_bounds`

Returns whether the point is within the given bounds: <code>rows</code> and <code>cols</code>,
mapping to <code>height</code> (x) and <code>width</code> (y).


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_is_within_bounds">is_within_bounds</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, rows: u16, cols: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_is_within_bounds">is_within_bounds</a>(p: &<a href="./point.md#grid_point_Point">Point</a>, rows: u16, cols: u16): bool {
    p.0 &lt; rows && p.1 &lt; cols
}
</code></pre>



</details>

<a name="grid_point_manhattan_distance"></a>

## Function `manhattan_distance`

Get the Manhattan distance between two points. Manhattan distance is the
sum of the absolute differences of the x and y coordinates.

Example:
```move
let (p1, p2) = (new(1, 0), new(4, 3));
let range = p1.range(&p2);

assert!(range == 6);
```


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_manhattan_distance">manhattan_distance</a>(p1: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, p2: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_manhattan_distance">manhattan_distance</a>(p1: &<a href="./point.md#grid_point_Point">Point</a>, p2: &<a href="./point.md#grid_point_Point">Point</a>): u16 {
    num_diff!(p1.0, p2.0) + num_diff!(p1.1, p2.1)
}
</code></pre>



</details>

<a name="grid_point_chebyshev_distance"></a>

## Function `chebyshev_distance`

Get the Chebyshev distance between two points. Chebyshev distance is the
maximum of the absolute differences of the x and y coordinates.

Example:
```move
let (p1, p2) = (new(1, 0), new(4, 3));
let range = p1.range(&p2);

assert!(range == 3);
```


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_chebyshev_distance">chebyshev_distance</a>(p1: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, p2: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_chebyshev_distance">chebyshev_distance</a>(p1: &<a href="./point.md#grid_point_Point">Point</a>, p2: &<a href="./point.md#grid_point_Point">Point</a>): u16 {
    num_max!(num_diff!(p1.0, p2.0), num_diff!(p1.1, p2.1))
}
</code></pre>



</details>

<a name="grid_point_euclidean_distance"></a>

## Function `euclidean_distance`

Get the Euclidean distance between two points. Euclidean distance is the
square root of the sum of the squared differences of the x and y coordinates.

Example:
```move
let (p1, p2) = (new(1, 0), new(4, 3));
let distance = p1.euclidean_distance(&p2);

assert!(distance == 5);
```


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_euclidean_distance">euclidean_distance</a>(p1: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, p2: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_euclidean_distance">euclidean_distance</a>(p1: &<a href="./point.md#grid_point_Point">Point</a>, p2: &<a href="./point.md#grid_point_Point">Point</a>): u16 {
    <b>let</b> xd = num_diff!(p1.0, p2.0);
    <b>let</b> yd = num_diff!(p1.1, p2.1);
    (xd * xd + yd * yd).sqrt()
}
</code></pre>



</details>

<a name="grid_point_von_neumann"></a>

## Function `von_neumann`

Get all von Neumann neighbors of a point within a given range. Von Neumann
neighborhood is a set of points that are adjacent to the given point. In 2D
space, it's the point to the left, right, up, and down from the given point.

The <code>size</code> parameter determines the range of the neighborhood. For example,
if <code>size</code> is 1, the function will return the immediate neighbors of the
point. If <code>size</code> is 2, the function will return the neighbors of the
neighbors, and so on.

```
0 1 2 3 4
0: | | |2| | |
1: | |2|1|2| |
2: |2|1|0|1|2|
3: | |3|1|2| |
4: | | |2| | |
```

Note: does not include the point itself!


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_von_neumann">von_neumann</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_von_neumann">von_neumann</a>(p: &<a href="./point.md#grid_point_Point">Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">Point</a>&gt; {
    <b>if</b> (size == 0) <b>return</b> vector[];
    <b>let</b> <b>mut</b> neighbors = vector[];
    <b>let</b> <a href="./point.md#grid_point_Point">Point</a>(xc, yc) = *p;
    <b>if</b> (size == 1) {
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc - 1, yc));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc - 1));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc + 1, yc));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc + 1));
        <b>return</b> neighbors
    };
    <b>if</b> (size == 2) {
        <b>if</b> (xc &gt; 1) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc - 2, yc));
        <b>if</b> (yc &gt; 1) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc - 2));
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc - 1, yc));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc - 1));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc + 1, yc));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc + 1));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc + 2, yc));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc, yc + 2));
        // do diagonals
        <b>if</b> (xc &gt; 0 && yc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc - 1, yc - 1));
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc - 1, yc + 1));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc + 1, yc - 1));
        neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(xc + 1, yc + 1));
        <b>return</b> neighbors
    };
    <b>let</b> (x0, y0) = (xc - size.min(xc), yc - size.min(yc));
    <b>let</b> (x1, y1) = (xc + size, yc + size);
    x0.range_do_eq!(x1, |<a href="./point.md#grid_point_x">x</a>| y0.range_do_eq!(y1, |<a href="./point.md#grid_point_y">y</a>| {
        <b>if</b> (<a href="./point.md#grid_point_x">x</a> == xc && <a href="./point.md#grid_point_y">y</a> == yc) <b>return</b>;
        <b>let</b> distance = num_diff!(<a href="./point.md#grid_point_x">x</a>, xc) + num_diff!(<a href="./point.md#grid_point_y">y</a>, yc);
        <b>if</b> (distance &lt;= size) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>));
    }));
    neighbors
}
</code></pre>



</details>

<a name="grid_point_moore"></a>

## Function `moore`

Get all Moore neighbors of a point. Moore neighborhood is a set of points
that are adjacent to the given point. In 2D space, it's the point to the
left, right, up, down, and diagonals from the given point.

The <code>size</code> parameter determines the range of the neighborhood. For example,
if <code>size</code> is 1, the function will return the immediate neighbors of the
point. If <code>size</code> is 2, the function will return the neighbors of the
neighbors, and so on.

Note: does not include the point itself!
```
0 1 2 3 4
0: |2|2|2|2|2|
1: |2|1|1|1|2|
2: |2|1|0|1|2|
3: |2|1|1|1|2|
4: |2|2|2|2|2|
```


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_moore">moore</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_moore">moore</a>(p: &<a href="./point.md#grid_point_Point">Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">Point</a>&gt; {
    <b>if</b> (size == 0) <b>return</b> vector[];
    <b>let</b> <b>mut</b> neighbors = vector[];
    <b>let</b> <a href="./point.md#grid_point_Point">Point</a>(xc, yc) = *p;
    <b>let</b> (x0, y0) = (xc - size.min(xc), yc - size.min(yc));
    <b>let</b> (x1, y1) = (xc + size, yc + size);
    x0.range_do_eq!(x1, |<a href="./point.md#grid_point_x">x</a>| y0.range_do_eq!(y1, |<a href="./point.md#grid_point_y">y</a>| {
        <b>if</b> (<a href="./point.md#grid_point_x">x</a> != xc || <a href="./point.md#grid_point_y">y</a> != yc) neighbors.push_back(<a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>));
    }));
    neighbors
}
</code></pre>



</details>

<a name="grid_point_le"></a>

## Function `le`

Compare two points. To be used in sorting macros. Returns less or equal,
based on the <code><a href="./point.md#grid_point_x">x</a></code> coordinate (1st) and then the <code><a href="./point.md#grid_point_y">y</a></code> coordinate (2nd).


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_le">le</a>(a: &<a href="./point.md#grid_point_Point">grid::point::Point</a>, b: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_le">le</a>(a: &<a href="./point.md#grid_point_Point">Point</a>, b: &<a href="./point.md#grid_point_Point">Point</a>): bool {
    (a.0 == b.0 && a.1 &lt;= b.1) || a.0 &lt; b.0
}
</code></pre>



</details>

<a name="grid_point_to_bytes"></a>

## Function `to_bytes`

Serialize a <code><a href="./point.md#grid_point_Point">Point</a></code> into BCS bytes.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_bytes">to_bytes</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_bytes">to_bytes</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): vector&lt;u8&gt; {
    bcs::to_bytes(p)
}
</code></pre>



</details>

<a name="grid_point_from_bytes"></a>

## Function `from_bytes`

Construct a <code><a href="./point.md#grid_point_Point">Point</a></code> from BCS bytes.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./point.md#grid_point_Point">grid::point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./point.md#grid_point_Point">Point</a> {
    <a href="./point.md#grid_point_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="grid_point_from_bcs"></a>

## Function `from_bcs`

Construct a <code><a href="./point.md#grid_point_Point">Point</a></code> from <code>BCS</code> bytes wrapped in a <code>BCS</code> struct.
Useful, when <code><a href="./point.md#grid_point_Point">Point</a></code> is a field of another struct that is being
deserialized from BCS.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): <a href="./point.md#grid_point_Point">grid::point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="./point.md#grid_point_Point">Point</a> {
    <a href="./point.md#grid_point_Point">Point</a>(bcs.peel_u16(), bcs.peel_u16())
}
</code></pre>



</details>

<a name="grid_point_to_string"></a>

## Function `to_string`

Print a point as a <code>String</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_string">to_string</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./point.md#grid_point_to_string">to_string</a>(p: &<a href="./point.md#grid_point_Point">Point</a>): String {
    <b>let</b> <b>mut</b> str = b"(".<a href="./point.md#grid_point_to_string">to_string</a>();
    <b>let</b> <a href="./point.md#grid_point_Point">Point</a>(<a href="./point.md#grid_point_x">x</a>, <a href="./point.md#grid_point_y">y</a>) = *p;
    str.append(<a href="./point.md#grid_point_x">x</a>.<a href="./point.md#grid_point_to_string">to_string</a>());
    str.append_utf8(b", ");
    str.append(<a href="./point.md#grid_point_y">y</a>.<a href="./point.md#grid_point_to_string">to_string</a>());
    str.append_utf8(b")");
    str
}
</code></pre>



</details>
