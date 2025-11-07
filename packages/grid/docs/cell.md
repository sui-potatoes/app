
<a name="grid_cell"></a>

# Module `grid::cell`

Defines the <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> type and its methods. Cell is a tuple-like struct that
holds two unsigned 16-bit integers, representing the row and column of a
cell in 2D space.


-  [Struct `Cell`](#grid_cell_Cell)
-  [Function `new`](#grid_cell_new)
-  [Function `from_vector`](#grid_cell_from_vector)
-  [Function `from_world`](#grid_cell_from_world)
-  [Function `to_values`](#grid_cell_to_values)
-  [Function `to_vector`](#grid_cell_to_vector)
-  [Function `to_world`](#grid_cell_to_world)
-  [Function `row`](#grid_cell_row)
-  [Function `col`](#grid_cell_col)
-  [Function `is_within_bounds`](#grid_cell_is_within_bounds)
-  [Function `manhattan_distance`](#grid_cell_manhattan_distance)
-  [Function `chebyshev_distance`](#grid_cell_chebyshev_distance)
-  [Function `euclidean_distance`](#grid_cell_euclidean_distance)
-  [Function `von_neumann_neighbors`](#grid_cell_von_neumann_neighbors)
-  [Function `moore_neighbors`](#grid_cell_moore_neighbors)
-  [Function `direction_to`](#grid_cell_direction_to)
-  [Function `le`](#grid_cell_le)
-  [Function `to_bytes`](#grid_cell_to_bytes)
-  [Function `from_bytes`](#grid_cell_from_bytes)
-  [Function `from_bcs`](#grid_cell_from_bcs)
-  [Function `to_string`](#grid_cell_to_string)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u32.md#std_u32">std::u32</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="grid_cell_Cell"></a>

## Struct `Cell`

A cell in 2D space. A row and a column.
Note: <code><a href="./cell.md#grid_cell_row">row</a></code> and <code>column</code> map to world coordinates <code>y</code> and <code>x</code> respectively.

```move
use grid::cell;

let cell = cell::new(2, 5);
assert!(cell.row() == 2);
assert!(cell.col() == 5);
```


<pre><code><b>public</b> <b>struct</b> <a href="./cell.md#grid_cell_Cell">Cell</a> <b>has</b> <b>copy</b>, drop, store
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

<a name="grid_cell_new"></a>

## Function `new`

Create a new <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> at <code>(<a href="./cell.md#grid_cell_row">row</a>, column)</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_new">new</a>(<a href="./cell.md#grid_cell_row">row</a>: u16, column: u16): <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_new">new</a>(<a href="./cell.md#grid_cell_row">row</a>: u16, column: u16): <a href="./cell.md#grid_cell_Cell">Cell</a> { <a href="./cell.md#grid_cell_Cell">Cell</a>(<a href="./cell.md#grid_cell_row">row</a>, column) }
</code></pre>



</details>

<a name="grid_cell_from_vector"></a>

## Function `from_vector`

Create a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> from a vector of two values.
Ignores the rest of the values in the vector.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_vector">from_vector</a>(v: vector&lt;u16&gt;): <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_vector">from_vector</a>(v: vector&lt;u16&gt;): <a href="./cell.md#grid_cell_Cell">Cell</a> { <a href="./cell.md#grid_cell_Cell">Cell</a>(v[0], v[1]) }
</code></pre>



</details>

<a name="grid_cell_from_world"></a>

## Function `from_world`

Create a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> from world coordinates <code>x</code> and <code>y</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_world">from_world</a>(x: u16, y: u16): <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_world">from_world</a>(x: u16, y: u16): <a href="./cell.md#grid_cell_Cell">Cell</a> { <a href="./cell.md#grid_cell_Cell">Cell</a>(y, x) }
</code></pre>



</details>

<a name="grid_cell_to_values"></a>

## Function `to_values`

Get a tuple of two values from a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_values">to_values</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_values">to_values</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): (u16, u16) { (c.0, c.1) }
</code></pre>



</details>

<a name="grid_cell_to_vector"></a>

## Function `to_vector`

Convert a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> to a vector of two values.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_vector">to_vector</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): vector&lt;u16&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_vector">to_vector</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): vector&lt;u16&gt; { vector[c.0, c.1] }
</code></pre>



</details>

<a name="grid_cell_to_world"></a>

## Function `to_world`

Convert a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> to world coordinates: (x, y) -> (column, row).


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_world">to_world</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_world">to_world</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): (u16, u16) { (c.1, c.0) }
</code></pre>



</details>

<a name="grid_cell_row"></a>

## Function `row`

Get the <code><a href="./cell.md#grid_cell_row">row</a></code> of a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code>. In world coordinates, this is the y coordinate.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_row">row</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_row">row</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u16 { c.0 }
</code></pre>



</details>

<a name="grid_cell_col"></a>

## Function `col`

Get the <code>column</code> of a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code>. In world coordinates, this is the x coordinate.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_col">col</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_col">col</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u16 { c.1 }
</code></pre>



</details>

<a name="grid_cell_is_within_bounds"></a>

## Function `is_within_bounds`

Returns whether the cell is within the given bounds: <code>rows</code> and <code>cols</code>,
mapping to <code>height</code> (row) and <code>width</code> (column).


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_is_within_bounds">is_within_bounds</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, rows: u16, cols: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_is_within_bounds">is_within_bounds</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>, rows: u16, cols: u16): bool {
    c.0 &lt; rows && c.1 &lt; cols
}
</code></pre>



</details>

<a name="grid_cell_manhattan_distance"></a>

## Function `manhattan_distance`

Get the L1 / Manhattan distance between two cells. Manhattan distance is the
sum of the absolute differences of the x and y coordinates.

Represents distance in 4-directional movement.

Example:
```move
let (c1, c2) = (new(1, 0), new(4, 3));
let range = c1.range(&c2);

assert!(range == 6);
```


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_manhattan_distance">manhattan_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_manhattan_distance">manhattan_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u16 {
    num_diff!(c1.0, c2.0) + num_diff!(c1.1, c2.1)
}
</code></pre>



</details>

<a name="grid_cell_chebyshev_distance"></a>

## Function `chebyshev_distance`

Get the L-Infinity / Chebyshev distance between two cells. Chebyshev distance
is the maximum of the absolute differences of the x and y coordinates.

Represents distance in 8-directional movement.
Also known as the "King" distance.

Example:
```move
let (c1, c2) = (new(1, 0), new(4, 3));
let range = c1.range(&c2);

assert!(range == 3);
```


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_chebyshev_distance">chebyshev_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_chebyshev_distance">chebyshev_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u16 {
    num_max!(num_diff!(c1.0, c2.0), num_diff!(c1.1, c2.1))
}
</code></pre>



</details>

<a name="grid_cell_euclidean_distance"></a>

## Function `euclidean_distance`

Get the Euclidean distance between two cells. Euclidean distance is the
square root of the sum of the squared differences of the x and y coordinates.
The value is rounded down to the nearest integer.

Example:
```move
let (c1, c2) = (new(1, 0), new(4, 3));
let distance = c1.euclidean_distance(&c2);

assert!(distance == 5);
```


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_euclidean_distance">euclidean_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_euclidean_distance">euclidean_distance</a>(c1: &<a href="./cell.md#grid_cell_Cell">Cell</a>, c2: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u16 {
    <b>let</b> dx = num_diff!(c1.0, c2.0) <b>as</b> u32;
    <b>let</b> dy = num_diff!(c1.1, c2.1) <b>as</b> u32;
    (dx * dx + dy * dy).sqrt() <b>as</b> u16
}
</code></pre>



</details>

<a name="grid_cell_von_neumann_neighbors"></a>

## Function `von_neumann_neighbors`

Get all neighbors of a cell within a given L1 / Chebyshev distance.

Example for distance=2:
```
0 1 2 3 4
0: | | |2| | |
1: | |2|1|2| |
2: |2|1|0|1|2|
3: | |3|1|2| |
4: | | |2| | |
```

Note: does not include the cell itself!


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_von_neumann_neighbors">von_neumann_neighbors</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_von_neumann_neighbors">von_neumann_neighbors</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">Cell</a>&gt; {
    <b>if</b> (distance == 0) <b>return</b> vector[];
    <b>let</b> <b>mut</b> neighbors = vector[];
    <b>let</b> <a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc) = *c;
    <b>if</b> (distance == 1) {
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc - 1, yc));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc - 1));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc + 1, yc));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc + 1));
        <b>return</b> neighbors
    };
    <b>if</b> (distance == 2) {
        <b>if</b> (xc &gt; 1) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc - 2, yc));
        <b>if</b> (yc &gt; 1) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc - 2));
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc - 1, yc));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc - 1));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc + 1, yc));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc + 1));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc + 2, yc));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc + 2));
        // do diagonals
        <b>if</b> (xc &gt; 0 && yc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc - 1, yc - 1));
        <b>if</b> (xc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc - 1, yc + 1));
        <b>if</b> (yc &gt; 0) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc + 1, yc - 1));
        neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(xc + 1, yc + 1));
        <b>return</b> neighbors
    };
    <b>let</b> (x0, y0) = (xc - distance.min(xc), yc - distance.min(yc));
    <b>let</b> (x1, y1) = (xc + distance, yc + distance);
    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        <b>if</b> (x == xc && y == yc) <b>return</b>;
        <b>let</b> l1_distance = num_diff!(x, xc) + num_diff!(y, yc);
        <b>if</b> (l1_distance &lt;= distance) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(x, y));
    }));
    neighbors
}
</code></pre>



</details>

<a name="grid_cell_moore_neighbors"></a>

## Function `moore_neighbors`

Get all <code><a href="./cell.md#grid_cell_Cell">Cell</a></code>s within the given L-Infinity distance. Also known as Moore
neighborhood.
Does not include the starting <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> c.

Example for distance=2:
```
0 1 2 3 4
0: |2|2|2|2|2|
1: |2|1|1|1|2|
2: |2|1|0|1|2|
3: |2|1|1|1|2|
4: |2|2|2|2|2|
```


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_moore_neighbors">moore_neighbors</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_moore_neighbors">moore_neighbors</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">Cell</a>&gt; {
    <b>if</b> (distance == 0) <b>return</b> vector[];
    <b>let</b> <b>mut</b> neighbors = vector[];
    <b>let</b> <a href="./cell.md#grid_cell_Cell">Cell</a>(xc, yc) = *c;
    <b>let</b> (x0, y0) = (xc - distance.min(xc), yc - distance.min(yc));
    <b>let</b> (x1, y1) = (xc + distance, yc + distance);
    x0.range_do_eq!(x1, |x| y0.range_do_eq!(y1, |y| {
        <b>if</b> (x != xc || y != yc) neighbors.push_back(<a href="./cell.md#grid_cell_Cell">Cell</a>(x, y));
    }));
    neighbors
}
</code></pre>



</details>

<a name="grid_cell_direction_to"></a>

## Function `direction_to`

Get the relative direction of <code>c1</code> to <code>c0</code>.

Example:
```move
use grid::cell;
use grid::direction;

let c0 = cell::new(0, 0);
let c1 = cell::new(2, 0);
let c2 = cell::new(2, 2);

// direction from <code>c0</code> to <code>c1</code> is <code>down</code>
assert!(c0.direction_to(&c1) & direction::down!() > 0);

// direction from <code>c0</code> to <code>c2</code> is <code>down-right</code>
assert!(c0.direction_to(&c2) & direction::down_right!() > 0);
```


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_direction_to">direction_to</a>(c0: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, c1: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_direction_to">direction_to</a>(c0: &<a href="./cell.md#grid_cell_Cell">Cell</a>, c1: &<a href="./cell.md#grid_cell_Cell">Cell</a>): u8 {
    <a href="./direction.md#grid_direction_direction">direction::direction</a>!(c0.0, c0.1, c1.0, c1.1)
}
</code></pre>



</details>

<a name="grid_cell_le"></a>

## Function `le`

Compare two cells. To be used in sorting macros. Returns less or equal,
based on the <code>x</code> coordinate (1st) and then the <code>y</code> coordinate (2nd).


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_le">le</a>(a: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, b: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_le">le</a>(a: &<a href="./cell.md#grid_cell_Cell">Cell</a>, b: &<a href="./cell.md#grid_cell_Cell">Cell</a>): bool {
    (a.0 == b.0 && a.1 &lt;= b.1) || a.0 &lt; b.0
}
</code></pre>



</details>

<a name="grid_cell_to_bytes"></a>

## Function `to_bytes`

Serialize a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> into BCS bytes.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_bytes">to_bytes</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): vector&lt;u8&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_bytes">to_bytes</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): vector&lt;u8&gt; {
    bcs::to_bytes(c)
}
</code></pre>



</details>

<a name="grid_cell_from_bytes"></a>

## Function `from_bytes`

Construct a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> from BCS bytes.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./cell.md#grid_cell_Cell">Cell</a> {
    <a href="./cell.md#grid_cell_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="grid_cell_from_bcs"></a>

## Function `from_bcs`

Construct a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> from <code>BCS</code> bytes wrapped in a <code>BCS</code> struct.
Useful, when <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> is a field of another struct that is being
deserialized from BCS.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="./cell.md#grid_cell_Cell">Cell</a> {
    <a href="./cell.md#grid_cell_Cell">Cell</a>(bcs.peel_u16(), bcs.peel_u16())
}
</code></pre>



</details>

<a name="grid_cell_to_string"></a>

## Function `to_string`

Print a <code><a href="./cell.md#grid_cell_Cell">Cell</a></code> as a <code>String</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_string">to_string</a>(c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cell.md#grid_cell_to_string">to_string</a>(c: &<a href="./cell.md#grid_cell_Cell">Cell</a>): String {
    <b>let</b> <b>mut</b> str = b"[".<a href="./cell.md#grid_cell_to_string">to_string</a>();
    <b>let</b> <a href="./cell.md#grid_cell_Cell">Cell</a>(x, y) = *c;
    str.append(x.<a href="./cell.md#grid_cell_to_string">to_string</a>());
    str.append_utf8(b", ");
    str.append(y.<a href="./cell.md#grid_cell_to_string">to_string</a>());
    str.append_utf8(b"]");
    str
}
</code></pre>



</details>
