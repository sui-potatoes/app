
<a name="grid_cursor"></a>

# Module `grid::cursor`

The <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> struct represents a movable point on the grid, and can be used
to trace paths, use the <code><a href="./direction.md#grid_direction">direction</a></code> API and get coordinates for the current
position.

```move
use grid::direction;
use grid::cursor;


<a name="@[test]_0"></a>

## [test]

fun test_cursor() {
let mut cursor = cursor::new(0, 0);
cursor.move_to(direction::down!());
cursor.move_to(direction::down!() | direction::right!());

let (x, y) = cursor.to_values();
assert!(x == 2 && y == 1);
}
```

The <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> struct is tightly coupled with the <code><a href="./direction.md#grid_direction">direction</a></code> module. Refer to
the <code><a href="./direction.md#grid_direction">direction</a></code> module for more information.


-  [[test]](#@[test]_0)
-  [Struct `Cursor`](#grid_cursor_Cursor)
-  [Constants](#@Constants_1)
-  [Function `new`](#grid_cursor_new)
-  [Function `to_values`](#grid_cursor_to_values)
-  [Function `to_point`](#grid_cursor_to_point)
-  [Function `to_vector`](#grid_cursor_to_vector)
-  [Function `from_point`](#grid_cursor_from_point)
-  [Function `reset`](#grid_cursor_reset)
-  [Function `move_to`](#grid_cursor_move_to)
-  [Function `move_back`](#grid_cursor_move_back)
-  [Function `can_move_to`](#grid_cursor_can_move_to)
-  [Function `from_bytes`](#grid_cursor_from_bytes)
-  [Function `from_bcs`](#grid_cursor_from_bcs)
-  [Function `to_string`](#grid_cursor_to_string)


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



<a name="grid_cursor_Cursor"></a>

## Struct `Cursor`

Cursor is similar to a <code>Point</code> as it stores the coordinates, but also tracks
directions where it was moved, so it could be moved back.


<pre><code><b>public</b> <b>struct</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a> <b>has</b> <b>copy</b>, drop, store
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
<dt>
<code>2: vector&lt;u8&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_1"></a>

## Constants


<a name="grid_cursor_EOutOfBounds"></a>

Trying to move out of bounds.


<pre><code><b>const</b> <a href="./cursor.md#grid_cursor_EOutOfBounds">EOutOfBounds</a>: u64 = 0;
</code></pre>



<a name="grid_cursor_ENoHistory"></a>

Trying to move back when there is no history.


<pre><code><b>const</b> <a href="./cursor.md#grid_cursor_ENoHistory">ENoHistory</a>: u64 = 1;
</code></pre>



<a name="grid_cursor_new"></a>

## Function `new`

Get the X coordinate of the cursor.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_new">new</a>(x: u16, y: u16): <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_new">new</a>(x: u16, y: u16): <a href="./cursor.md#grid_cursor_Cursor">Cursor</a> { <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, vector[]) }
</code></pre>



</details>

<a name="grid_cursor_to_values"></a>

## Function `to_values`

Get both coordinates of the cursor.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_values">to_values</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_values">to_values</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">Cursor</a>): (u16, u16) {
    <b>let</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, _) = c;
    (*x, *y)
}
</code></pre>



</details>

<a name="grid_cursor_to_point"></a>

## Function `to_point`

Construct a <code>Point</code> from a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code>.

```rust
use grid::cursor;
use grid::point;

let cursor = cursor::new(1, 2);
assert!(cursor.to_point() == point::new(1, 2));
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_point">to_point</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>): <a href="./point.md#grid_point_Point">grid::point::Point</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_point">to_point</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">Cursor</a>): Point { <a href="./point.md#grid_point_new">point::new</a>(c.0, c.1) }
</code></pre>



</details>

<a name="grid_cursor_to_vector"></a>

## Function `to_vector`

Convert a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> to a vector of two values.
```rust
use grid::cursor;

let cursor = cursor::new(1, 2);
assert!(cursor.to_vector() == vector[1, 2]); // (x, y)
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_vector">to_vector</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>): vector&lt;u16&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_vector">to_vector</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">Cursor</a>): vector&lt;u16&gt; { vector[c.0, c.1] }
</code></pre>



</details>

<a name="grid_cursor_from_point"></a>

## Function `from_point`

Construct a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> from a <code>Point</code>. Alias: <code>Point.to_cursor</code>.

```rust
use grid::cursor;
use grid::point;

let cursor = point::new(1, 2).to_cursor();
assert!(cursor == cursor::new(1, 2));
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_point">from_point</a>(p: &<a href="./point.md#grid_point_Point">grid::point::Point</a>): <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_point">from_point</a>(p: &Point): <a href="./cursor.md#grid_cursor_Cursor">Cursor</a> {
    <b>let</b> (x, y) = p.<a href="./cursor.md#grid_cursor_to_values">to_values</a>();
    <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, vector[])
}
</code></pre>



</details>

<a name="grid_cursor_reset"></a>

## Function `reset`

Reset the <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> to a given point, clears the history.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_reset">reset</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>, x: u16, y: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_reset">reset</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>, x: u16, y: u16) {
    c.0 = x;
    c.1 = y;
    c.2 = vector[]; // resets history!
}
</code></pre>



</details>

<a name="grid_cursor_move_to"></a>

## Function `move_to`

Move <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> in a given direction. Aborts if the <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> is out of bounds.
Stores the direction in the history.

```rust
use grid::cursor;
use grid::direction;

let mut cursor = cursor::new(0, 0);
cursor.move_to(direction::down!());
cursor.move_to(direction::right!() | direction::down!());
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_move_to">move_to</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>, <a href="./direction.md#grid_direction">direction</a>: u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_move_to">move_to</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>, <a href="./direction.md#grid_direction">direction</a>: u8) {
    <b>let</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, path) = c;
    <b>if</b> (<a href="./direction.md#grid_direction">direction</a> & up!() &gt; 0) {
        <b>assert</b>!(*x &gt; 0, <a href="./cursor.md#grid_cursor_EOutOfBounds">EOutOfBounds</a>);
        *x = *x - 1;
    } <b>else</b> <b>if</b> (<a href="./direction.md#grid_direction">direction</a> & down!() &gt; 0) {
        *x = *x + 1;
    };
    <b>if</b> (<a href="./direction.md#grid_direction">direction</a> & left!() &gt; 0) {
        <b>assert</b>!(*y &gt; 0, <a href="./cursor.md#grid_cursor_EOutOfBounds">EOutOfBounds</a>);
        *y = *y - 1;
    } <b>else</b> <b>if</b> (<a href="./direction.md#grid_direction">direction</a> & right!() &gt; 0) {
        *y = *y + 1;
    };
    path.push_back(<a href="./direction.md#grid_direction">direction</a>);
}
</code></pre>



</details>

<a name="grid_cursor_move_back"></a>

## Function `move_back`

Move the <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> back to the previous position. Aborts if there is no history.

```rust
use grid::cursor;
use grid::direction;

let mut cursor = cursor::new(0, 0);
cursor.move_to(direction::down!());
assert!(cursor.to_vector() == vector[1, 0]);

cursor.move_back(); // return to the initial position
assert!(cursor.to_vector() == vector[0, 0]);
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_move_back">move_back</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_move_back">move_back</a>(c: &<b>mut</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>) {
    <b>assert</b>!(c.2.length() &gt; 0, <a href="./cursor.md#grid_cursor_ENoHistory">ENoHistory</a>);
    <b>let</b> <a href="./direction.md#grid_direction">direction</a> = <a href="./direction.md#grid_direction_inverse">direction::inverse</a>!(c.2.pop_back());
    c.<a href="./cursor.md#grid_cursor_move_to">move_to</a>(<a href="./direction.md#grid_direction">direction</a>); // perform <b>move</b>
    c.2.pop_back(); // hacky: remove the <a href="./direction.md#grid_direction">direction</a> we just added
}
</code></pre>



</details>

<a name="grid_cursor_can_move_to"></a>

## Function `can_move_to`

Check if a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> can move in a given direction. Checks 0-index bounds.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_can_move_to">can_move_to</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>, <a href="./direction.md#grid_direction">direction</a>: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_can_move_to">can_move_to</a>(c: &<a href="./cursor.md#grid_cursor_Cursor">Cursor</a>, <a href="./direction.md#grid_direction">direction</a>: u8): bool {
    <b>let</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, _) = c;
    <b>let</b> is_up = <a href="./direction.md#grid_direction">direction</a> & up!() &gt; 0;
    <b>let</b> is_left = <a href="./direction.md#grid_direction">direction</a> & left!() &gt; 0;
    (is_up && *x &gt; 0 || !is_up) && (is_left && *y &gt; 0 || !is_left)
}
</code></pre>



</details>

<a name="grid_cursor_from_bytes"></a>

## Function `from_bytes`

Parse bytes (encoded as BCS) into a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./cursor.md#grid_cursor_Cursor">Cursor</a> {
    <a href="./cursor.md#grid_cursor_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="grid_cursor_from_bcs"></a>

## Function `from_bcs`

Parse <code>BCS</code> bytes into a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code>. Useful when <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> is a field of another
struct that is being deserialized from BCS.


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): <a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="./cursor.md#grid_cursor_Cursor">Cursor</a> {
    <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(bcs.peel_u16(), bcs.peel_u16(), bcs.peel_vec!(|bcs| bcs.peel_u8()))
}
</code></pre>



</details>

<a name="grid_cursor_to_string"></a>

## Function `to_string`

Print a <code><a href="./cursor.md#grid_cursor_Cursor">Cursor</a></code> as a string.

```rust
use grid::cursor;

let cursor = cursor::new(1, 2);
assert!(cursor.to_string() == b"(1, 2)".to_string());
```


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_string">to_string</a>(p: &<a href="./cursor.md#grid_cursor_Cursor">grid::cursor::Cursor</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./cursor.md#grid_cursor_to_string">to_string</a>(p: &<a href="./cursor.md#grid_cursor_Cursor">Cursor</a>): String {
    <b>let</b> <b>mut</b> str = b"(".<a href="./cursor.md#grid_cursor_to_string">to_string</a>();
    <b>let</b> <a href="./cursor.md#grid_cursor_Cursor">Cursor</a>(x, y, _) = *p;
    str.append(x.<a href="./cursor.md#grid_cursor_to_string">to_string</a>());
    str.append_utf8(b", ");
    str.append(y.<a href="./cursor.md#grid_cursor_to_string">to_string</a>());
    str.append_utf8(b")");
    str
}
</code></pre>



</details>
