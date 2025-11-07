
<a name="grid_grid"></a>

# Module `grid::grid`

Defines a generic <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> type which stores a 2D grid of elements. The grid
provides guarantees that the elements are stored in a rectangular shape.

Additionally, the module provides functions to work with the grid, such as
getting the cols and rows, borrowing elements, and finding the shortest
path between two cells using the Wave Algorithm, as well as rotating and
traversing the grid.


<a name="@Implementation_notes_0"></a>

### Implementation notes



<a name="@Coordinate_system_1"></a>

#### Coordinate system


Instead of using world coordinates indexing (x, y), the grid takes a neutral
approach of using <code>row</code> and <code>column</code>, which is a reversed indexing of world
coordinates: (y, x) -> (row, column).

Similarly, the <code>Cell</code> type stores row and column - (y, x) in world
coordinates.


<a name="@Index_type_2"></a>

#### Index type


The grid uses <code>u16</code> as the index type for two main reasons:
- vector length limit
- object size limit

Using a different type would not bring any benefits to the implementation.


    -  [Implementation notes](#@Implementation_notes_0)
        -  [Coordinate system](#@Coordinate_system_1)
        -  [Index type](#@Index_type_2)
-  [Struct `Grid`](#grid_grid_Grid)
-  [Constants](#@Constants_3)
-  [Function `from_vector`](#grid_grid_from_vector)
-  [Function `from_vector_unchecked`](#grid_grid_from_vector_unchecked)
-  [Function `into_vector`](#grid_grid_into_vector)
-  [Function `rows`](#grid_grid_rows)
-  [Function `cols`](#grid_grid_cols)
-  [Function `inner`](#grid_grid_inner)
-  [Function `borrow`](#grid_grid_borrow)
-  [Function `borrow_mut`](#grid_grid_borrow_mut)
-  [Function `swap`](#grid_grid_swap)
-  [Function `rotate`](#grid_grid_rotate)
-  [Function `borrow_cell`](#grid_grid_borrow_cell)
-  [Function `borrow_cell_mut`](#grid_grid_borrow_cell_mut)
-  [Function `swap_cell`](#grid_grid_swap_cell)
-  [Macro function `manhattan_distance`](#grid_grid_manhattan_distance)
-  [Macro function `chebyshev_distance`](#grid_grid_chebyshev_distance)
-  [Macro function `euclidean_distance`](#grid_grid_euclidean_distance)
-  [Macro function `tabulate`](#grid_grid_tabulate)
-  [Macro function `destroy`](#grid_grid_destroy)
-  [Macro function `do`](#grid_grid_do)
-  [Macro function `do_ref`](#grid_grid_do_ref)
-  [Macro function `do_mut`](#grid_grid_do_mut)
-  [Macro function `traverse`](#grid_grid_traverse)
-  [Macro function `map`](#grid_grid_map)
-  [Macro function `map_ref`](#grid_grid_map_ref)
-  [Function `von_neumann_neighbors`](#grid_grid_von_neumann_neighbors)
-  [Macro function `von_neumann_neighbors_count`](#grid_grid_von_neumann_neighbors_count)
-  [Function `moore_neighbors`](#grid_grid_moore_neighbors)
-  [Macro function `moore_neighbors_count`](#grid_grid_moore_neighbors_count)
-  [Macro function `find_group`](#grid_grid_find_group)
-  [Macro function `trace_path`](#grid_grid_trace_path)
-  [Macro function `to_string`](#grid_grid_to_string)
-  [Macro function `from_bcs`](#grid_grid_from_bcs)


<pre><code><b>use</b> <a href="./cell.md#grid_cell">grid::cell</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
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
<dt>
<code><a href="./grid.md#grid_grid_rows">rows</a>: u16</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./grid.md#grid_grid_cols">cols</a>: u16</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_3"></a>

## Constants


<a name="grid_grid_EIncorrectLength"></a>

Vector length is incorrect during initialization.


<pre><code><b>const</b> <a href="./grid.md#grid_grid_EIncorrectLength">EIncorrectLength</a>: u64 = 0;
</code></pre>



<a name="grid_grid_EIndexOutOfBounds"></a>



<pre><code><b>const</b> <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>: u64 = 1;
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
    <b>let</b> <a href="./grid.md#grid_grid_rows">rows</a> = <a href="./grid.md#grid_grid">grid</a>.length() <b>as</b> u16;
    <b>let</b> <a href="./grid.md#grid_grid_cols">cols</a> = <a href="./grid.md#grid_grid">grid</a>[0].length();
    <a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|row| <b>assert</b>!(row.length() == <a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIncorrectLength">EIncorrectLength</a>));
    <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a>, <a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>: <a href="./grid.md#grid_grid_cols">cols</a> <b>as</b> u16 }
}
</code></pre>



</details>

<a name="grid_grid_from_vector_unchecked"></a>

## Function `from_vector_unchecked`

Same as <code><a href="./grid.md#grid_grid_from_vector">from_vector</a></code> but doesn't check the lengths. May be used for optimal
performance when the grid is known to be correct.

Caution: an invalid <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> will cause unexpected failures in some operations.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>&lt;T&gt;(<a href="./grid.md#grid_grid">grid</a>: vector&lt;vector&lt;T&gt;&gt;): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt; {
    <a href="./grid.md#grid_grid_Grid">Grid</a> {
        <a href="./grid.md#grid_grid_rows">rows</a>: <a href="./grid.md#grid_grid">grid</a>.length() <b>as</b> u16,
        <a href="./grid.md#grid_grid_cols">cols</a>: <a href="./grid.md#grid_grid">grid</a>[0].length() <b>as</b> u16,
        <a href="./grid.md#grid_grid">grid</a>,
    }
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
    <b>let</b> <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a>, .. } = <a href="./grid.md#grid_grid">grid</a>;
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


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_rows">rows</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): u16 { g.<a href="./grid.md#grid_grid_rows">rows</a> }
</code></pre>



</details>

<a name="grid_grid_cols"></a>

## Function `cols`

Get the number of columns of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_cols">cols</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_cols">cols</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;): u16 { g.<a href="./grid.md#grid_grid_cols">cols</a> }
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


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow">borrow</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, row: u16, col: u16): &T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow">borrow</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, row: u16, col: u16): &T {
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    &g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64][col <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_borrow_mut"></a>

## Function `borrow_mut`

Borrow a mutable reference to a cell in the grid.
```move
let value_mut = &mut grid[0, 0];
```


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_mut">borrow_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, row: u16, col: u16): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_mut">borrow_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, row: u16, col: u16): &<b>mut</b> T {
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    &<b>mut</b> g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64][col <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_swap"></a>

## Function `swap`

Swap an element in the grid with another element, returning the old element.
This is important for <code>T</code> types that don't have <code>drop</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap">swap</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, row: u16, col: u16, element: T): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap">swap</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, row: u16, col: u16, element: T): T {
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64].push_back(element);
    g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64].swap_remove(col <b>as</b> u64)
}
</code></pre>



</details>

<a name="grid_grid_rotate"></a>

## Function `rotate`

Rotate the grid <code>times</code> * 90º degrees clockwise. Mutates the grid in place.
If <code>times</code> is greater than 3, it will be reduced to the equivalent rotation.

```move
let mut grid = grid::from_vector(vector[
vector[1, 2, 3],
vector[4, 5, 6],
vector[7, 8, 9],
]);

grid.rotate(1); // 90º
assert_eq!(grid.into_vector(), vector[
vector[7, 4, 1],
vector[8, 5, 2],
vector[9, 6, 3],
]);
```


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_rotate">rotate</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, times: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_rotate">rotate</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, times: u8) {
    <b>let</b> times = times % 4;
    // No rotation.
    <b>if</b> (times == 0) <b>return</b>;
    // 90º rotation.
    <b>if</b> (times == 1) {
        <b>let</b> <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a>: source, <a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a> } = g;
        <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (*<a href="./grid.md#grid_grid_rows">rows</a> <b>as</b> u64, *<a href="./grid.md#grid_grid_cols">cols</a> <b>as</b> u64);
        <b>let</b> <b>mut</b> target = vector[];
        source.pop_back().<a href="./grid.md#grid_grid_do">do</a>!(|el| target.push_back(vector[el]));
        (<a href="./grid.md#grid_grid_rows">rows</a> - 1).<a href="./grid.md#grid_grid_do">do</a>!(|_| {
            <b>let</b> <b>mut</b> row = source.pop_back();
            <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|i| target[(<a href="./grid.md#grid_grid_cols">cols</a> - i - 1)].push_back(row.pop_back()));
            row.destroy_empty();
        });
        target.<a href="./grid.md#grid_grid_do">do</a>!(|row| source.push_back(row));
    };
    // 180º rotation.
    <b>if</b> (times == 2) {
        g.<a href="./grid.md#grid_grid">grid</a>.reverse();
        g.<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_do_mut">do_mut</a>!(|row| row.reverse());
    };
    // 270º rotation.
    <b>if</b> (times == 3) {
        <b>let</b> <a href="./grid.md#grid_grid_Grid">Grid</a> { <a href="./grid.md#grid_grid">grid</a>: source, <a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a> } = g;
        <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (*<a href="./grid.md#grid_grid_rows">rows</a> <b>as</b> u64, *<a href="./grid.md#grid_grid_cols">cols</a> <b>as</b> u64);
        <b>let</b> <b>mut</b> target = vector[];
        source.reverse();
        source.pop_back().<a href="./grid.md#grid_grid_do">do</a>!(|el| target.push_back(vector[el]));
        (<a href="./grid.md#grid_grid_rows">rows</a> - 1).<a href="./grid.md#grid_grid_do">do</a>!(|_| {
            <b>let</b> <b>mut</b> row = source.pop_back();
            <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|i| target[<a href="./grid.md#grid_grid_cols">cols</a> - i - 1].push_back(row.pop_back()));
            row.destroy_empty();
        });
        target.<a href="./grid.md#grid_grid_destroy">destroy</a>!(|row| source.push_back(row));
    };
}
</code></pre>



</details>

<a name="grid_grid_borrow_cell"></a>

## Function `borrow_cell`

Get a reference to a cell in the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> at the given <code>Cell</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): &T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, c: &Cell): &T {
    <b>let</b> (row, col) = c.to_values();
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    &g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64][col <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_borrow_cell_mut"></a>

## Function `borrow_cell_mut`

Get a mutable reference to a cell in the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> at the given <code>Cell</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>): &<b>mut</b> T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, c: &Cell): &<b>mut</b> T {
    <b>let</b> (row, col) = c.to_values();
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    &<b>mut</b> g.<a href="./grid.md#grid_grid">grid</a>[row <b>as</b> u64][col <b>as</b> u64]
}
</code></pre>



</details>

<a name="grid_grid_swap_cell"></a>

## Function `swap_cell`

Swap the value at the given <code>Cell</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap_cell">swap_cell</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, c: &<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, v: T): T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_swap_cell">swap_cell</a>&lt;T&gt;(g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, c: &Cell, v: T): T {
    <b>let</b> (row, col) = c.to_values();
    <b>assert</b>!(row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>, <a href="./grid.md#grid_grid_EIndexOutOfBounds">EIndexOutOfBounds</a>);
    g.<a href="./grid.md#grid_grid_swap">swap</a>(row, col, v)
}
</code></pre>



</details>

<a name="grid_grid_manhattan_distance"></a>

## Macro function `manhattan_distance`

Get an L1 / Manhattan distance between two cells. Manhattan distance is the
sum of the absolute differences of the x and y coordinates.

Example:
```move
let distance = grid::manhattan_distance!(0, 0, 1, 2);

assert!(distance == 3);
```

See https://en.wikipedia.org/wiki/Taxicab_geometry for more information.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_manhattan_distance">manhattan_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_manhattan_distance">manhattan_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T {
    num_diff!($row0, $row1) + num_diff!($col0, $col1)
}
</code></pre>



</details>

<a name="grid_grid_chebyshev_distance"></a>

## Macro function `chebyshev_distance`

Get an L-Infinity / Chebyshev distance between two cells. Also known as "King"
distance.
The distance is the maximum of dx and dy.

Example:
```move
let distance = grid::chebyshev_distance!(0, 0, 1, 2);

assert!(distance == 2);
```

See https://en.wikipedia.org/wiki/Chebyshev_distance for more information.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_chebyshev_distance">chebyshev_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_chebyshev_distance">chebyshev_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T {
    num_max!(num_diff!($row0, $row1), num_diff!($col0, $col1))
}
</code></pre>



</details>

<a name="grid_grid_euclidean_distance"></a>

## Macro function `euclidean_distance`

Get the Euclidean distance between two cells. Euclidean distance is the
square root of the sum of the squared differences of the x and y coordinates.

Note: use with caution on <code>u8</code> and <code>u16</code> types, as the macro does not upscale
intermediate values automatically. Perform upscaling manually before using the
macro if necessary.

Example:
```move
let distance = grid::euclidean_distance!(0, 0, 1, 2);

assert_eq!(distance, 2);
```

See https://en.wikipedia.org/wiki/Euclidean_distance for more information.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_euclidean_distance">euclidean_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_euclidean_distance">euclidean_distance</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): $T {
    <b>let</b> xd = num_diff!($row0, $row1);
    <b>let</b> yd = num_diff!($col0, $col1);
    (xd * xd + yd * yd).sqrt()
}
</code></pre>



</details>

<a name="grid_grid_tabulate"></a>

## Macro function `tabulate`

Create a grid of the specified size by applying the function <code>f</code> to each cell.
The function receives the row and column coordinates of the cell.

Example:
```move
public enum Tile {
Empty,
// ...
}

let grid = grid::tabulate!(3, 3, |_x, _y| Tile::Empty);
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_tabulate">tabulate</a>&lt;$U: drop, $T&gt;($<a href="./grid.md#grid_grid_rows">rows</a>: $U, $<a href="./grid.md#grid_grid_cols">cols</a>: $U, $f: |u16, u16| -&gt; $T): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_tabulate">tabulate</a>&lt;$U: drop, $T&gt;($<a href="./grid.md#grid_grid_rows">rows</a>: $U, $<a href="./grid.md#grid_grid_cols">cols</a>: $U, $f: |u16, u16| -&gt; $T): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt; {
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
```move
grid.destroy!(|tile| tile.destroy());
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_destroy">destroy</a>&lt;$T, $R: drop&gt;($g: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_destroy">destroy</a>&lt;$T, $R: drop&gt;($g: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_into_vector">into_vector</a>($g).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|row| row.<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./cell.md#grid_cell">cell</a>| $f(<a href="./cell.md#grid_cell">cell</a>)));
}
</code></pre>



</details>

<a name="grid_grid_do"></a>

## Macro function `do`

Consume the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> by calling the function <code>f</code> for each element. Preserves the
order of elements (goes from top to bottom, left to right). If the order does not
matter, use <code><a href="./grid.md#grid_grid_destroy">destroy</a></code> macro instead.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do">do</a>&lt;$T, $R: drop&gt;($g: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do">do</a>&lt;$T, $R: drop&gt;($g: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_into_vector">into_vector</a>($g).<a href="./grid.md#grid_grid_do">do</a>!(|row| row.<a href="./grid.md#grid_grid_do">do</a>!(|<a href="./cell.md#grid_cell">cell</a>| $f(<a href="./cell.md#grid_cell">cell</a>)));
}
</code></pre>



</details>

<a name="grid_grid_do_ref"></a>

## Macro function `do_ref`

Apply the function <code>f</code> to a reference of each element of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_ref">do_ref</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_ref">do_ref</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $R) {
    <a href="./grid.md#grid_grid_inner">inner</a>($g).<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|row| row.<a href="./grid.md#grid_grid_do_ref">do_ref</a>!(|<a href="./cell.md#grid_cell">cell</a>| $f(<a href="./cell.md#grid_cell">cell</a>)));
}
</code></pre>



</details>

<a name="grid_grid_do_mut"></a>

## Macro function `do_mut`

Apply the function <code>f</code> to a mutable reference of each element of the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_mut">do_mut</a>&lt;$T, $R: drop&gt;($g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&<b>mut</b> $T| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_do_mut">do_mut</a>&lt;$T, $R: drop&gt;($g: &<b>mut</b> <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&<b>mut</b> $T| -&gt; $R) {
    <b>let</b> <a href="./grid.md#grid_grid">grid</a> = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    <a href="./grid.md#grid_grid_rows">rows</a>.<a href="./grid.md#grid_grid_do">do</a>!(|row| <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|col| $f(&<b>mut</b> <a href="./grid.md#grid_grid">grid</a>[row, col])));
}
</code></pre>



</details>

<a name="grid_grid_traverse"></a>

## Macro function `traverse`

Traverse the grid, calling the function <code>f</code> for each cell. The function
receives the reference to the cell, the row and column of the cell.

Example:
```move
grid.traverse!(|cell, (row, col)| {
// do something with the cell and the coordinates
});
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_traverse">traverse</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T, (u16, u16)| -&gt; $R)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_traverse">traverse</a>&lt;$T, $R: drop&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T, (u16, u16)| -&gt; $R) {
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <a href="./grid.md#grid_grid_rows">rows</a>.<a href="./grid.md#grid_grid_do">do</a>!(|row| <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|col| $f(&g[row, col], (row, col))));
}
</code></pre>



</details>

<a name="grid_grid_map"></a>

## Macro function `map`

Map the <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> to a new <code><a href="./grid.md#grid_grid_Grid">Grid</a></code> by applying the function <code>f</code> to each cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map">map</a>&lt;$T, $U&gt;($g: <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$U&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map">map</a>&lt;$T, $U&gt;($g: <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$U&gt; {
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid_into_vector">into_vector</a>($g).<a href="./grid.md#grid_grid_map">map</a>!(|row| row.<a href="./grid.md#grid_grid_map">map</a>!(|<a href="./cell.md#grid_cell">cell</a>| $f(<a href="./cell.md#grid_cell">cell</a>))))
}
</code></pre>



</details>

<a name="grid_grid_map_ref"></a>

## Macro function `map_ref`

Map the grid to a new grid by applying the function <code>f</code> to each cell.
Callback <code>f</code> takes the reference to the cell.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map_ref">map_ref</a>&lt;$T, $U&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$U&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_map_ref">map_ref</a>&lt;$T, $U&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;, $f: |&$T| -&gt; $U): <a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$U&gt; {
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid_inner">inner</a>($g).<a href="./grid.md#grid_grid_map_ref">map_ref</a>!(|row| row.<a href="./grid.md#grid_grid_map_ref">map_ref</a>!(|<a href="./cell.md#grid_cell">cell</a>| $f(<a href="./cell.md#grid_cell">cell</a>))))
}
</code></pre>



</details>

<a name="grid_grid_von_neumann_neighbors"></a>

## Function `von_neumann_neighbors`

Get all cells in the L1 <code>distance</code> of the given cell (also known as von Neumann
neighborhood). Returned cells are guaranteed to be within the bounds of the grid.

See <code>Cell</code> for more information on the von Neumann neighborhood.
See https://en.wikipedia.org/wiki/Von_Neumann_neighborhood for more information.


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_neighbors">von_neumann_neighbors</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_neighbors">von_neumann_neighbors</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: Cell, distance: u16): vector&lt;Cell&gt; {
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    p.<a href="./grid.md#grid_grid_von_neumann_neighbors">von_neumann_neighbors</a>(distance).filter!(|<a href="./cell.md#grid_cell">cell</a>| {
        <b>let</b> (row, col) = <a href="./cell.md#grid_cell">cell</a>.to_values();
        row &lt; <a href="./grid.md#grid_grid_rows">rows</a> && col &lt; <a href="./grid.md#grid_grid_cols">cols</a>
    })
}
</code></pre>



</details>

<a name="grid_grid_von_neumann_neighbors_count"></a>

## Macro function `von_neumann_neighbors_count`

Count the number cells that satisfy the predicate <code>$f</code> in the L1 distance
of the given cell (also known as von Neumann neighborhood).

Example:
```move
let count = grid.von_neumann_count!(0, 2, 1, |el| *el == 1);

assert!(count == 1);
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_neighbors_count">von_neumann_neighbors_count</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $c: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, $distance: u16, $f: |&$T| -&gt; bool): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_von_neumann_neighbors_count">von_neumann_neighbors_count</a>&lt;$T&gt;(
    $g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $c: Cell,
    $distance: u16,
    $f: |&$T| -&gt; bool,
): u8 {
    <b>let</b> p = $c;
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> count = 0u8;
    p.<a href="./grid.md#grid_grid_von_neumann_neighbors">von_neumann_neighbors</a>($distance).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./cell.md#grid_cell">cell</a>| {
        <b>let</b> (row1, col1) = <a href="./cell.md#grid_cell">cell</a>.to_values();
        <b>if</b> (row1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || col1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
        <b>if</b> (!$f(&g[row1, col1])) <b>return</b>;
        count = count + 1;
    });
    count
}
</code></pre>



</details>

<a name="grid_grid_moore_neighbors"></a>

## Function `moore_neighbors`

Get all cells in the L-Infinity <code>distance</code> of the given cell (also known as
Moore neighborhood). Returned cells are guaranteed to be within the bounds
of the grid.

See <code>Cell</code> for more information on the Moore neighborhood.
See https://en.wikipedia.org/wiki/Moore_neighborhood for more information.

Example:
```move
let neighbors = grid.moore_neighbors(0, 2, 1);
neighbors.destroy!(|p| std::debug::print(&p.to_string!()));
```


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_neighbors">moore_neighbors</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;T&gt;, p: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, distance: u16): vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_neighbors">moore_neighbors</a>&lt;T&gt;(g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;T&gt;, p: Cell, distance: u16): vector&lt;Cell&gt; {
    p.<a href="./grid.md#grid_grid_moore_neighbors">moore_neighbors</a>(distance).filter!(|<a href="./cell.md#grid_cell">cell</a>| {
        <b>let</b> (row, col) = <a href="./cell.md#grid_cell">cell</a>.to_values();
        row &lt; g.<a href="./grid.md#grid_grid_rows">rows</a> && col &lt; g.<a href="./grid.md#grid_grid_cols">cols</a>
    })
}
</code></pre>



</details>

<a name="grid_grid_moore_neighbors_count"></a>

## Macro function `moore_neighbors_count`

Count the number of Moore neighbors of a cell that pass the predicate $f.

Example:
```move
let count = grid.moore_neighbors_count!(0, 2, 1, |el| *el == 1);
std::debug::print(&count); // result varies based on the Grid
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_neighbors_count">moore_neighbors_count</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $c: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, $distance: u16, $f: |&$T| -&gt; bool): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_moore_neighbors_count">moore_neighbors_count</a>&lt;$T&gt;(
    $g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $c: Cell,
    $distance: u16,
    $f: |&$T| -&gt; bool,
): u8 {
    <b>let</b> p = $c;
    <b>let</b> g = $g;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (g.<a href="./grid.md#grid_grid_rows">rows</a>(), g.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> count = 0u8;
    p.<a href="./grid.md#grid_grid_moore_neighbors">moore_neighbors</a>($distance).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./cell.md#grid_cell">cell</a>| {
        <b>let</b> (row1, col1) = <a href="./cell.md#grid_cell">cell</a>.to_values();
        <b>if</b> (row1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || col1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
        <b>if</b> (!$f(&g[row1, col1])) <b>return</b>;
        count = count + 1;
    });
    count
}
</code></pre>



</details>

<a name="grid_grid_find_group"></a>

## Macro function `find_group`

Finds a group of cells that satisfy the predicate <code>f</code> amongst the neighbors
of the given cell. The function <code>n</code> is used to get the neighbors of the
current cell. For Von Neumann neighborhood, use <code>von_neumann</code> as the
function. For Moore neighborhood, use <code>moore</code> as the function.

Takes the <code>$n</code> function to get the neighbors of the current cell. Expected
to be used with the <code>von_neumann</code> and <code>moore</code> macros to get the neighbors.
However, it is possible to pass in a custom callback with exotic
configurations, eg. only return diagonal neighbors.

```move
// finds a group of cells with value 1 in von Neumann neighborhood
grid.find_group!(0, 2, |p| p.von_neumann_neighbors(1), |el| *el == 1);

// finds a group of cells with value 1 in Moore neighborhood
grid.find_group!(0, 2, |p| p.moore_neighbors(1), |el| *el == 1);

// custom neighborhood, only checks the neighbor to the right
grid.find_group!(0, 2, |p| vector[cell::new(p.x(), p.y() + 1)], |el| *el == 1);
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_find_group">find_group</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $c: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, $n: |&<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>| -&gt; vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;, $f: |&$T| -&gt; bool): vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_find_group">find_group</a>&lt;$T&gt;(
    $<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $c: Cell,
    $n: |&Cell| -&gt; vector&lt;Cell&gt;,
    $f: |&$T| -&gt; bool,
): vector&lt;Cell&gt; {
    <b>let</b> c = $c;
    <b>let</b> <a href="./grid.md#grid_grid_map">map</a> = $<a href="./grid.md#grid_grid_map">map</a>;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    <b>let</b> <b>mut</b> group = vector[];
    <b>let</b> <b>mut</b> visited = <a href="./grid.md#grid_grid_tabulate">tabulate</a>!(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>, |_, _| <b>false</b>);
    <b>if</b> (!$f(<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>(&c))) <b>return</b> group;
    group.push_back(c);
    *visited.<a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>(&c) = <b>true</b>;
    <b>let</b> <b>mut</b> queue = vector[c];
    <b>while</b> (queue.length() != 0) {
        $n(&queue.pop_back()).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|c| {
            <b>if</b> (!c.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) || *visited.<a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>(&c)) <b>return</b>;
            <b>if</b> ($f(<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>(&c))) {
                *visited.<a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>(&c) = <b>true</b>;
                group.push_back(c);
                queue.push_back(c);
            }
        });
    };
    group
}
</code></pre>



</details>

<a name="grid_grid_trace_path"></a>

## Macro function `trace_path`

Use Wave Algorithm to find the shortest path between two cells. The function
<code>n</code> returns the neighbors of the current cell. The function <code>f</code> is used to
check if the cell is passable - it takes two arguments: the current cell
and the next cell.

```move
// finds the shortest path between (0, 0) and (1, 4) with a limit of 6
grid.trace_path!(
cell::new(0, 0),
cell::new(1, 4),
|p| p.moore_neighbors(1), // use moore neighborhood
|(prev_row, prev_col), (next_row, next_col)| cell == 0,
6,
);
```

Transition to the last tile must match the predicate <code>f</code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_trace_path">trace_path</a>&lt;$T&gt;($<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;, $c0: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, $c1: <a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>, $n: |&<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>| -&gt; vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;, $f: |(u16, u16), (u16, u16)| -&gt; bool, $limit: u16): <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;<a href="./cell.md#grid_cell_Cell">grid::cell::Cell</a>&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_trace_path">trace_path</a>&lt;$T&gt;(
    $<a href="./grid.md#grid_grid_map">map</a>: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;,
    $c0: Cell,
    $c1: Cell,
    $n: |&Cell| -&gt; vector&lt;Cell&gt;,
    $f: |(u16, u16), (u16, u16)| -&gt; bool, // whether the <a href="./cell.md#grid_cell">cell</a> is passable
    $limit: u16,
): Option&lt;vector&lt;Cell&gt;&gt; {
    <b>let</b> c0 = $c0;
    <b>let</b> c1 = $c1;
    <b>let</b> limit = $limit + 1; // we start from 1, not 0.
    <b>let</b> <a href="./grid.md#grid_grid_map">map</a> = $<a href="./grid.md#grid_grid_map">map</a>;
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid_map">map</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    // If the cells are out of bounds, <b>return</b> none.
    <b>if</b> (!c0.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) || !c1.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>)) {
        <b>return</b> option::none()
    };
    // Surround the first element with 1s.
    <b>let</b> <b>mut</b> num = 1;
    <b>let</b> <b>mut</b> queue = vector[c0];
    <b>let</b> <b>mut</b> <a href="./grid.md#grid_grid">grid</a> = <a href="./grid.md#grid_grid_tabulate">tabulate</a>!(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>, |_, _| 0);
    *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>(&c0) = num;
    <b>let</b> <b>mut</b> found = <b>false</b>;
    'search: <b>while</b> (num &lt; limit && !queue.is_empty()) {
        num = num + 1;
        // Flush the queue, marking all cells around the current number.
        queue.<a href="./grid.md#grid_grid_destroy">destroy</a>!(|from| $n(&from).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|to| {
            <b>let</b> (row0, col0) = from.to_values();
            <b>let</b> (row1, col1) = to.to_values();
            <b>if</b> (row1 &gt;= <a href="./grid.md#grid_grid_rows">rows</a> || col1 &gt;= <a href="./grid.md#grid_grid_cols">cols</a>) <b>return</b>;
            // If we can't pass through the <a href="./cell.md#grid_cell">cell</a>, skip it.
            <b>if</b> (!$f((row0, col0), (row1, col1))) <b>return</b>;
            // If we reached the destination, <b>break</b> the <b>loop</b>.
            <b>if</b> (to == c1) {
                *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>(&to) = num;
                found = <b>true</b>;
                <b>break</b> 'search
            };
            // If the <a href="./cell.md#grid_cell">cell</a> is empty, mark it with the current number.
            <b>if</b> (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>(&to) == 0) {
                *<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_cell_mut">borrow_cell_mut</a>(&to) = num;
                queue.push_back(to);
            };
        }));
    };
    // If we never reached the destination within the limit, <b>return</b> none.
    <b>if</b> (!found) {
        <b>return</b> option::none()
    };
    // Reconstruct the path by going from the destination to the source.
    <b>let</b> <b>mut</b> path = vector[c1];
    <b>let</b> <b>mut</b> last_cell = c1;
    'reconstruct: <b>while</b> (num &gt; 1) {
        num = num - 1;
        $n(&last_cell).<a href="./grid.md#grid_grid_destroy">destroy</a>!(|<a href="./cell.md#grid_cell">cell</a>| {
            <b>if</b> (<a href="./cell.md#grid_cell">cell</a> == c0) <b>break</b> 'reconstruct;
            <b>if</b> (!<a href="./cell.md#grid_cell">cell</a>.is_within_bounds(<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>)) <b>return</b>;
            <b>if</b> (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_borrow_cell">borrow_cell</a>(&<a href="./cell.md#grid_cell">cell</a>) == num) {
                path.push_back(<a href="./cell.md#grid_cell">cell</a>);
                last_cell = <a href="./cell.md#grid_cell">cell</a>;
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

```move
let grid = from_vector(vector[
vector[1, 2, 3],
vector[4, 5, 6],
vector[7, 8, 9u8],
]);

std::debug::print(&grid.to_string!())
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_to_string">to_string</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;$T&gt;): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./grid.md#grid_grid_to_string">to_string</a>&lt;$T&gt;($g: &<a href="./grid.md#grid_grid_Grid">Grid</a>&lt;$T&gt;): String {
    <b>let</b> <a href="./grid.md#grid_grid">grid</a> = $g;
    <b>let</b> <b>mut</b> result = b"".<a href="./grid.md#grid_grid_to_string">to_string</a>();
    <b>let</b> (<a href="./grid.md#grid_grid_rows">rows</a>, <a href="./grid.md#grid_grid_cols">cols</a>) = (<a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_rows">rows</a>(), <a href="./grid.md#grid_grid">grid</a>.<a href="./grid.md#grid_grid_cols">cols</a>());
    // the layout is vertical, so we iterate over the <a href="./grid.md#grid_grid_rows">rows</a> first
    <a href="./grid.md#grid_grid_rows">rows</a>.<a href="./grid.md#grid_grid_do">do</a>!(|row| {
        result.append_utf8(b"|");
        <a href="./grid.md#grid_grid_cols">cols</a>.<a href="./grid.md#grid_grid_do">do</a>!(|col| {
            result.append(<a href="./grid.md#grid_grid">grid</a>[row, col].<a href="./grid.md#grid_grid_to_string">to_string</a>());
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
    <b>let</b> _rows = bcs.peel_u16();
    <b>let</b> _cols = bcs.peel_u16();
    <a href="./grid.md#grid_grid_from_vector_unchecked">from_vector_unchecked</a>(<a href="./grid.md#grid_grid">grid</a>)
}
</code></pre>



</details>
