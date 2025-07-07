
<a name="grid_grid"></a>

# Module `grid::grid`

Defines a generic <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> type which stores a 2D grid of elements. The grid
provides guarantees that the elements are stored in a rectangular shape.

Additionally, the module provides functions to work with the grid, such as
getting the cols and rows, borrowing elements, and finding the shortest
path between two points using the Wave Algorithm.

Structure, printing and directions:
- the grid is a 2-dimensional vector of elements, with <code>x</code> coordinate being
the outer vector and the row number, and <code>y</code> coordinate being the inner vector
and the column number
- x=0 is the top of the grid, y=0 is the left side of the grid, with increase
in x going downwards and increase in y going to the right
- the grid is printed vertically, with the top left corner being the first
element and the bottom right corner being the last element
- the grid provides macro functions to check if a point is above, below, to
the left or to the right of another point


-  [Struct `Grid`](#grid_grid_Grid)
-  [Constants](#@Constants_0)
-  [Function `from_vector`](#grid_grid_from_vector)
-  [Function `from_vector_unchecked`](#grid_grid_from_vector_unchecked)
-  [Function `into_vector`](#grid_grid_into_vector)
-  [Function `rows`](#grid_grid_rows)
-  [Function `cols`](#grid_grid_cols)
-  [Function `inner`](#grid_grid_inner)
-  [Function `borrow`](#grid_grid_borrow)
-  [Function `borrow_mut`](#grid_grid_borrow_mut)
-  [Function `swap`](#grid_grid_swap)
-  [Function `borrow_point`](#grid_grid_borrow_point)
-  [Function `borrow_point_mut`](#grid_grid_borrow_point_mut)
-  [Macro function `manhattan_distance`](#grid_grid_manhattan_distance)
-  [Macro function `chebyshev_distance`](#grid_grid_chebyshev_distance)
-  [Macro function `tabulate`](#grid_grid_tabulate)
-  [Macro function `destroy`](#grid_grid_destroy)
-  [Macro function `do`](#grid_grid_do)
-  [Macro function `do_ref`](#grid_grid_do_ref)
-  [Macro function `traverse`](#grid_grid_traverse)
-  [Macro function `map`](#grid_grid_map)
-  [Macro function `map_ref`](#grid_grid_map_ref)
-  [Function `von_neumann`](#grid_grid_von_neumann)
-  [Macro function `von_neumann_count`](#grid_grid_von_neumann_count)
-  [Function `moore`](#grid_grid_moore)
-  [Macro function `moore_count`](#grid_grid_moore_count)
-  [Macro function `find_group`](#grid_grid_find_group)
-  [Macro function `trace`](#grid_grid_trace)
-  [Macro function `to_string`](#grid_grid_to_string)
-  [Macro function `from_bcs`](#grid_grid_from_bcs)


<pre><code><b>use</b> <a href="./point.md#grid_point">grid::point</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
</code></pre>



<a name="grid_grid_Grid"></a>

## Struct `Grid`

A generic 2D grid, each cell stores <code>T</code>.


<pre><code><b>public</b> <b>struct</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt; <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="grid_grid_EIncorrectLength"></a>



<pre><code><b>const</b> <a href="./grid.md#grid_grid_EIncorrectLength">EIncorrectLength</a>: u64 = 0;
</code></pre>



<a name="grid_grid_from_vector"></a>

## Function `from_vector`

Create a new grid from a vector of vectors. The inner vectors represent
rows of the grid. The function panics if the grid is empty or if the rows
have different lengths.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector">from_vector</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector">from_vector</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt; {
    <b>assert</b>!(<a href="./grid.md#grid_grid">grid</a>.length() &gt; 0, <a href="./grid.md#grid_grid_EIncorrectLength">EIncorrectLength</a>);
    <b>let</b> <a href="./grid.md#grid_grid_cols">cols</a> = <a href="./grid.md#grid_grid">grid</a>[0].length();
    <a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|row| <b>assert</b>!(row.length() == <a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIncorrectLength">EIncorrectLength</a>));
    <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a> }
}
</code></pre>



</details>

<a name="grid_grid_from_vector_unchecked"></a>

## Function `from_vector_unchecked`

Same as <code><a href="./grid.md#grid_grid_from_vector">from_vector</a></code> but doesn't check the lengths. May be used for optimal
performance when the grid is known to be correct.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt; {
    <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a> }
}
</code></pre>



</details>

<a name="grid_grid_into_vector"></a>

## Function `into_vector`

Unpack the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> into its underlying vector.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_into_vector">into_vector</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;): vector&lt;vector&lt;T&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_into_vector">into_vector</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): vector&lt;vector&lt;T&gt;&gt; {
    <b>let</b> <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a> } = <a href="./grid.md#grid_grid">grid</a>;
    <a href="./grid.md#grid_grid">grid</a>
}
</code></pre>



</details>

<a name="grid_grid_rows"></a>

## Function `rows`

Get the number of rows of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_rows">rows</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_rows">rows</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): u16 { g.<a href="./grid.md#grid_grid">grid</a>.length() <b>as</b> u16 }
</code></pre>



</details>

<a name="grid_grid_cols"></a>

## Function `cols`

Get the number of columns of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_cols">cols</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_cols">cols</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): u16 { g.<a href="./grid.md#grid_grid">grid</a>[0].length() <b>as</b> u16 }
</code></pre>



</details>

<a name="grid_grid_inner"></a>

## Function `inner`

Get a reference to the inner vector of the grid.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_inner">inner</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;): &vector&lt;vector&lt;T&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_inner">inner</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): &vector&lt;vector&lt;T&gt;&gt; { &g.<a href="./grid.md#grid_grid">grid</a> }
</code></pre>



</details>

<a name="grid_grid_borrow"></a>

## Function `borrow`

Get a reference to a cell in the grid.
```move
let value_ref = &grid[0, 0];
let copied_value = grid[0, 0];
```


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow">borrow</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, x: u16, y: u16): &T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow">borrow</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, x: u16, y: u16): &T { &g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64][y <b>as</b> u64] }
</code></pre>



</details>

<a name="grid_grid_borrow_mut"></a>

## Function `borrow_mut`

Borrow a mutable reference to a cell in the grid.
```move
let value_mut = &mut grid[0, 0];
```


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_mut">borrow_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, x: u16, y: u16): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_mut">borrow_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, x: u16, y: u16): &<b>mut</b> T {
    &<b>mut</b> g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64][y <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_swap"></a>

## Function `swap`

Swap an element in the grid with another element, returning the old element.
This is important for <code>T</code> types that don't have <code>drop</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap">swap</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, x: u16, y: u16, element: T): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap">swap</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, x: u16, y: u16, element: T): T {
    g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64].push_back(element);
    g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64].swap_remove(y <b>as</b> u64)
}
</code></pre>



</details>

<a name="grid_grid_borrow_point"></a>

## Function `borrow_point`

Get a reference to a cell in the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> at the given <code>Point</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_point">borrow_point</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): &T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_point">borrow_point</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: &Point): &T {
    <b>let</b> (x, y) = p.to_values();
    &g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64][y <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_borrow_point_mut"></a>

## Function `borrow_point_mut`

Get a mutable reference to a cell in the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> at the given <code>Point</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: &Point): &<b>mut</b> T {
    <b>let</b> (x, y) = p.to_values();
    &<b>mut</b> g.<a href="./grid.md#grid_grid">grid</a>[x <b>as</b> u64][y <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_manhattan_distance"></a>

## Macro function `manhattan_distance`

Get a Manhattan distance between two points. Manhattan distance is the
sum of the absolute differences of the x and y coordinates.

Example:
```rust
let distance = grid::manhattan_distance!(0, 0, 1, 2);

assert!(distance == 3);
```

See https://en.wikipedia.org/wiki/Taxicab_geometry for more information.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_manhattan_distance">manhattan_distance</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_manhattan_distance">manhattan_distance</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T {
    num_diff!($x0, $x1) + num_diff!($y0, $y1)
}
</code></pre>



</details>

<a name="grid_grid_chebyshev_distance"></a>

## Macro function `chebyshev_distance`

Get a Chebyshev distance between two points. Chebyshev distance is the
maximum of the absolute differences of the x and y coordinates.

Example:
```rust
let distance = grid::chebyshev_distance!(0, 0, 1, 2);

assert!(distance == 2);
```

See https://en.wikipedia.org/wiki/Chebyshev_distance for more information.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_chebyshev_distance">chebyshev_distance</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_chebyshev_distance">chebyshev_distance</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): $T {
    num_max!(num_diff!($x0, $x1), num_diff!($y0, $y1))
}
</code></pre>



</details>

<a name="grid_grid_tabulate"></a>

## Macro function `tabulate`

Create a grid of the specified size by applying the function <code>f</code> to each cell.
The function receives the x and y coordinates of the cell.

Example:
```rust
public enum Tile {
Empty,
// ...
}

let grid = grid::tabulate!(3, 3, |_x, _y| Tile::Empty);
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_tabulate">tabulate</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_rows">rows</a>: u16, $<a href="./grid.md#grid_grid_cols">cols</a>: u16, $f: |u16, u16| -&gt; $T): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_tabulate">tabulate</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_rows">rows</a>: u16, $<a href="./grid.md#grid_grid_cols">cols</a>: u16, $f: |u16, u16| -&gt; $T): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt; {
    <b>let</b> <a href="./grid.md#grid_grid_rows">rows</a> = $<a href="./grid.md#grid_grid_rows">rows</a> <b>as</b> u64;
    <b>let</b> <a href="./grid.md#grid_grid_cols">cols</a> = $<a href="./grid.md#grid_grid_cols">cols</a> <b>as</b> u64;
    <b>let</b> <a href="./grid.md#grid_grid">grid</a> = vector::tabulate!(<a href="./grid.md#grid_grid_rows">rows</a>, |x| vector::tabulate!(<a href="./grid.md#grid_grid_cols">cols</a>, |y| $f(x <b>as</b> u16, y <b>as</b> u16)));
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid">grid</a>)
}
</code></pre>



</details>

<a name="grid_grid_destroy"></a>

## Macro function `destroy`

Gracefully destroy the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> by consuming the elements in the passed function $f.
Goes in reverse order (bottom to top, right to left). Cheaper than <code><a href="./grid.md#grid_grid_do">do</a></code> because it
doesn't need to reverse the elements.

Example:
```rust
grid.destroy!(|tile| tile.destroy());
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_destroy">destroy</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_destroy">destroy</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_into_vector">into_vector</a>($<a href="./grid.md#grid_grid">grid</a>).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|row| row.<a href="./grid.md#grid_grid_destroy">destroy</a>!(|cell| $f(cell)));
}
</code></pre>



</details>

<a name="grid_grid_do"></a>

## Macro function `do`

Consume the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> by calling the function <code>f</code> for each element. Preserves the
order of elements (goes from top to bottom, left to right). If the order does not
matter, use <code><a href="./grid.md#grid_grid_destroy">destroy</a></code> instead.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do">do</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do">do</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_into_vector">into_vector</a>($<a href="./grid.md#grid_grid">grid</a>).<a href="./grid.md#grid_grid_do">do</a>!(|row| row.<a href="./grid.md#grid_grid_do">do</a>!(|cell| $f(cell)));
}
</code></pre>



</details>

<a name="grid_grid_do_ref"></a>

## Macro function `do_ref`

Apply the function <code>f</code> for each element of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.
The function receives a reference to the cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_ref">do_ref</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_ref">do_ref</a>&lt;$T, $R: drop&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_inner">inner</a>($<a href="./grid.md#grid_grid">grid</a>).<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|row| row.<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|cell| $f(cell)));
}
</code></pre>



</details>

<a name="grid_grid_traverse"></a>

## Macro function `traverse`

Traverse the grid, calling the function <code>f</code> for each cell. The function
receives the reference to the cell, the x and y coordinates of the cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_traverse">traverse</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T, (u16, u16)| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_traverse">traverse</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T, (u16, u16)| -&gt; $R) {
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <a href="./grid.md#grid_grid_rows">rows</a>.<a href="./grid.md#grid_grid_do">do</a>!(|x| <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|y| $f(&g[x, y], (x, y))));
}
</code></pre>



</details>

<a name="grid_grid_map"></a>

## Macro function `map`

Map the grid to a new grid by applying the function <code>f</code> to each cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map">map</a>&lt;$T, $U&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$U&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map">map</a>&lt;$T, $U&gt;($<a href="./grid.md#grid_grid">grid</a>: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$U&gt; {
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid_into_vector">into_vector</a>($<a href="./grid.md#grid_grid">grid</a>).<a href="./grid.md#grid_grid_map">map</a>!(|row| row.<a href="./grid.md#grid_grid_map">map</a>!(|cell| $f(cell))))
}
</code></pre>



</details>

<a name="grid_grid_map_ref"></a>

## Macro function `map_ref`

Map the grid to a new grid by applying the function <code>f</code> to each cell.
Callback <code>f</code> takes the reference to the cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map_ref">map_ref</a>&lt;$T, $U&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$U&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map_ref">map_ref</a>&lt;$T, $U&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$U&gt; {
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid_inner">inner</a>($<a href="./grid.md#grid_grid">grid</a>).<a href="./grid.md#grid_grid_map_ref">map_ref</a>!(|row| row.<a href="./grid.md#grid_grid_map_ref">map_ref</a>!(|cell| $f(cell))))
}
</code></pre>



</details>

<a name="grid_grid_von_neumann"></a>

## Function `von_neumann`

Get all von Neumann neighbors of a point, checking if the point is within
the bounds of the grid. The size parameter specifies the size of the neighborhood.

See <code>Point</code> for more information on the von Neumann neighborhood.
See https://en.wikipedia.org/wiki/Von_Neumann_neighborhood for more information.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann">von_neumann</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: <a href="./point.md#grid_point_Point">grid::point::Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann">von_neumann</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: Point, size: u16): vector&lt;Point&gt; {
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    p.<a href="./grid.md#grid_grid_von_neumann">von_neumann</a>(size).filter!(|<a href="./point.md#grid_point">point</a>| {
        <b>let</b> (x, y) = <a href="./point.md#grid_point">point</a>.to_values();
        x &lt; <a href="./grid.md#grid_grid_rows">rows</a> && y &lt; <a href="./grid.md#grid_grid_cols">cols</a>
    })
}
</code></pre>



</details>

<a name="grid_grid_von_neumann_count"></a>

## Macro function `von_neumann_count`

Count the number of Von Neumann neighbors of a point that pass the predicate $f.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_count">von_neumann_count</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $p: <a href="./point.md#grid_point_Point">grid::point::Point</a>, $size: u16, $f: |&$T| -&gt; bool): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_count">von_neumann_count</a>&lt;$T&gt;(
    $g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $p: Point,
    $size: u16,
    $f: |&$T| -&gt; bool,
): u8 {
    <b>let</b> p = $p;
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> count = 0u8;
    p.<a href="./grid.md#grid_grid_von_neumann">von_neumann</a>($size).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./point.md#grid_point">point</a>| {
        <b>let</b> (x1, y1) = <a href="./point.md#grid_point">point</a>.to_values();
        <b>if</b> (x1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || y1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
        <b>if</b> (!$f(&g[x1, y1])) <b>return</b>;
        count = count + 1;
    });
    count
}
</code></pre>



</details>

<a name="grid_grid_moore"></a>

## Function `moore`

Get all Moore neighbors of a <code>Point</code>, checking if the point is within the
bounds of the grid. The size parameter specifies the size of the neighborhood.

See <code>Point</code> for more information on the Moore neighborhood.
See https://en.wikipedia.org/wiki/Moore_neighborhood for more information.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_moore">moore</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: <a href="./point.md#grid_point_Point">grid::point::Point</a>, size: u16): vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_moore">moore</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: Point, size: u16): vector&lt;Point&gt; {
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    p.<a href="./grid.md#grid_grid_moore">moore</a>(size).filter!(|<a href="./point.md#grid_point">point</a>| {
        <b>let</b> (x, y) = <a href="./point.md#grid_point">point</a>.to_values();
        x &lt; <a href="./grid.md#grid_grid_rows">rows</a> && y &lt; <a href="./grid.md#grid_grid_cols">cols</a>
    })
}
</code></pre>



</details>

<a name="grid_grid_moore_count"></a>

## Macro function `moore_count`

Count the number of Moore neighbors of a point that pass the predicate $f.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_count">moore_count</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $p: <a href="./point.md#grid_point_Point">grid::point::Point</a>, $size: u16, $f: |&$T| -&gt; bool): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_count">moore_count</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $p: Point, $size: u16, $f: |&$T| -&gt; bool): u8 {
    <b>let</b> p = $p;
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> count = 0u8;
    p.<a href="./grid.md#grid_grid_moore">moore</a>($size).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./point.md#grid_point">point</a>| {
        <b>let</b> (x1, y1) = <a href="./point.md#grid_point">point</a>.to_values();
        <b>if</b> (x1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || y1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
        <b>if</b> (!$f(&g[x1, y1])) <b>return</b>;
        count = count + 1;
    });
    count
}
</code></pre>



</details>

<a name="grid_grid_find_group"></a>

## Macro function `find_group`

Finds a group of cells that satisfy the predicate <code>f</code> amongst the neighbors
of the given point. The function <code>n</code> is used to get the neighbors of the
current point. For Von Neumann neighborhood, use <code><a href="./grid.md#grid_grid_von_neumann">von_neumann</a></code> as the
function. For Moore neighborhood, use <code><a href="./grid.md#grid_grid_moore">moore</a></code> as the function.

Takes the <code>$n</code> function to get the neighbors of the current point. Expected
to be used with the <code><a href="./grid.md#grid_grid_von_neumann">von_neumann</a></code> and <code><a href="./grid.md#grid_grid_moore">moore</a></code> macros to get the neighbors.
However, it is possible to pass in a custom callback with exotic
configurations, eg. only return diagonal neighbors.

```move
// finds a group of cells with value 1 in von Neumann neighborhood
grid.find_group!(0, 2, |p| p.von_neumann(1), |el| *el == 1);

// finds a group of cells with value 1 in Moore neighborhood
grid.find_group!(0, 2, |p| p.moore(1), |el| *el == 1);

// custom neighborhood, only checks the neighbor to the right
grid.find_group!(0, 2, |p| vector[point::new(p.x(), p.y() + 1)], |el| *el == 1);
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_find_group">find_group</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $p: <a href="./point.md#grid_point_Point">grid::point::Point</a>, $n: |&<a href="./point.md#grid_point_Point">grid::point::Point</a>| -&gt; vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;, $f: |&$T| -&gt; bool): vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_find_group">find_group</a>&lt;$T&gt;(
    $<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $p: Point,
    $n: |&Point| -&gt; vector&lt;Point&gt;,
    $f: |&$T| -&gt; bool,
): vector&lt;Point&gt; {
    <b>let</b> p = $p;
    <b>let</b> <a href="./grid.md#grid_grid_map">map</a> = $<a href="./grid.md#grid_grid_map">map</a>;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> group = vector[];
    <b>let</b> <b>mut</b> visited = <a href="./grid.md#grid_grid_tabulate">tabulate</a>!(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>, |_, _| <b>false</b>);
    <b>if</b> (!$f(<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_borrow_point">borrow_point</a>(&p))) <b>return</b> group;
    group.push_back(p);
    *visited.<a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>(&p) = <b>true</b>;
    <b>let</b> <b>mut</b> queue = vector[p];
    <b>while</b> (queue.length() != 0) {
        $n(&queue.pop_back()).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|p| {
            <b>if</b> (!p.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) || *visited.<a href="./grid.md#grid_grid_borrow_point">borrow_point</a>(&p)) <b>return</b>;
            <b>if</b> ($f(<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_borrow_point">borrow_point</a>(&p))) {
                *visited.<a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>(&p) = <b>true</b>;
                group.push_back(p);
                queue.push_back(p);
            }
        });
    };
    group
}
</code></pre>



</details>

<a name="grid_grid_trace"></a>

## Macro function `trace`

Use Wave Algorithm to find the shortest path between two points. The function
<code>n</code> returns the neighbors of the current point. The function <code>f</code> is used to
check if the cell is passable - it takes two arguments: the current point
and the next point.

```move
// finds the shortest path between (0, 0) and (1, 4) with a limit of 6
grid.trace!(
point::new(0, 0),
point::new(1, 4),
|p| p.moore(1), // use moore neighborhood
|(prev_x, prev_y), (next_x, next_y)| cell == 0,
6,
);
```

TODO: consider using a A* algorithm for better performance.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_trace">trace</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $p0: <a href="./point.md#grid_point_Point">grid::point::Point</a>, $p1: <a href="./point.md#grid_point_Point">grid::point::Point</a>, $n: |&<a href="./point.md#grid_point_Point">grid::point::Point</a>| -&gt; vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;, $f: |(u16, u16), (u16, u16)| -&gt; bool, $limit: u16): <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;<a href="./point.md#grid_point_Point">grid::point::Point</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_trace">trace</a>&lt;$T&gt;(
    $<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $p0: Point,
    $p1: Point,
    $n: |&Point| -&gt; vector&lt;Point&gt;,
    $f: |(u16, u16), (u16, u16)| -&gt; bool, // whether the cell is passable
    $limit: u16,
): Option&lt;vector&lt;Point&gt;&gt; {
    <b>let</b> p0 = $p0;
    <b>let</b> p1 = $p1;
    <b>let</b> limit = $limit + 1; // we start from 1, not 0.
    <b>let</b> <a href="./grid.md#grid_grid_map">map</a> = $<a href="./grid.md#grid_grid_map">map</a>;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    // If the points are out of bounds, <b>return</b> none.
    <b>if</b> (!p0.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) || !p1.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>)) {
        <b>return</b> option::none()
    };
    // Surround the first element with 1s.
    <b>let</b> <b>mut</b> num = 1;
    <b>let</b> <b>mut</b> queue = vector[p0];
    <b>let</b> <b>mut</b> <a href="./grid.md#grid_grid">grid</a> = <a href="./grid.md#grid_grid_tabulate">tabulate</a>!(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>, |_, _| 0);
    *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>(&p0) = num;
    <b>let</b> <b>mut</b> found = <b>false</b>;
    'search: <b>while</b> (num &lt; limit && !queue.is_empty()) {
        num = num + 1;
        // Flush the queue, marking all cells around the current number.
        queue.<a href="./grid.md#grid_grid_destroy">destroy</a>!(|from| $n(&from).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|to| {
            // If we reached the destination, <b>break</b> the <b>loop</b>.
            <b>if</b> (to == p1) {
                *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>(&to) = num;
                found = <b>true</b>;
                <b>break</b> 'search
            };
            <b>let</b> (x0, y0) = from.into_values();
            <b>let</b> (x1, y1) = to.into_values();
            <b>if</b> (x1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || y1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
            // If we can't pass through the cell, skip it.
            <b>if</b> (!$f((x0, y0), (x1, y1))) <b>return</b>;
            // If the cell is empty, mark it with the current number.
            <b>if</b> (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_point">borrow_point</a>(&to) == 0) {
                *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_point_mut">borrow_point_mut</a>(&to) = num;
                queue.push_back(to);
            }
        }));
    };
    // If we never reached the destination within the limit, <b>return</b> none.
    <b>if</b> (!found) {
        <b>return</b> option::none()
    };
    // Reconstruct the path by going from the destination to the source.
    <b>let</b> <b>mut</b> path = vector[p1];
    <b>let</b> <b>mut</b> last_point = p1;
    'reconstruct: <b>while</b> (num &gt; 1) {
        num = num - 1;
        $n(&last_point).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|p| {
            <b>if</b> (p == p0) <b>break</b> 'reconstruct;
            <b>if</b> (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_point">borrow_point</a>(&p) == num) {
                path.push_back(p);
                last_point = p;
                <b>continue</b> 'reconstruct
            }
        });
    };
    path.reverse();
    option::some(path)
}
</code></pre>



</details>

<a name="grid_grid_to_string"></a>

## Macro function `to_string`

Print the grid to a string. Only works if <code>$T</code> has a <code>.<a href="./grid.md#grid_grid_to_string">to_string</a>()</code> method.

```rust
let grid = from_vector(vector[
vector[1, 2, 3],
vector[4, 5, 6],
vector[7, 8, 9u8],
]);

std::debug::print(&grid.to_string!())
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_to_string">to_string</a>&lt;$T&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_to_string">to_string</a>&lt;$T&gt;($<a href="./grid.md#grid_grid">grid</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;): String {
    <b>let</b> <a href="./grid.md#grid_grid">grid</a> = $<a href="./grid.md#grid_grid">grid</a>;
    <b>let</b> <b>mut</b> result = b"".<a href="./grid.md#grid_grid_to_string">to_string</a>();
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    // the layout is vertical, so we iterate over the <a href="./grid.md#grid_grid_rows">rows</a> first
    <a href="./grid.md#grid_grid_rows">rows</a>.<a href="./grid.md#grid_grid_do">do</a>!(|x| {
        result.append_utf8(b"|");
        <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|y| {
            result.append(<a href="./grid.md#grid_grid">grid</a>[x, y].<a href="./grid.md#grid_grid_to_string">to_string</a>());
            result.append_utf8(b"|");
        });
        result.append_utf8(b"\n");
    });
    result
}
</code></pre>



</details>

<a name="grid_grid_from_bcs"></a>

## Macro function `from_bcs`

Deserialize <code>BCS</code> into a grid. This macro is a helping hand in writing
custom deserializers.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_from_bcs">from_bcs</a>&lt;$T&gt;($bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>, $f: |&<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>| -&gt; $T): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_from_bcs">from_bcs</a>&lt;$T&gt;($bcs: &<b>mut</b> BCS, $f: |&<b>mut</b> BCS| -&gt; $T): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt; {
    <b>let</b> bcs = $bcs;
    <b>let</b> <a href="./grid.md#grid_grid">grid</a> = bcs.peel_vec!(|row| row.peel_vec!(|val| $f(val)));
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid">grid</a>)
}
</code></pre>



</details>
