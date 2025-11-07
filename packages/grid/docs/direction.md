
<a name="grid_direction"></a>

# Module `grid::direction`

The <code><a href="./direction.md#grid_direction">direction</a></code> module provides macros to check the relative positions of
cells on a grid as well as constants for the directions. Currently, the
main consumer of this module is <code><a href="./cursor.md#grid_cursor">cursor</a></code>.

Grid axes are defined as follows:
- X-axis: horizontal axis (left->right)
- Y-axis: vertical axis (top->down)

Hence, the (0, 0) cell is at the top-left corner of the grid.

Direction is packed as a bit field in a single byte. Diagonals are represented
as a combination of two orthogonal directions. For example, <code><a href="./direction.md#grid_direction_up_right">up_right</a>!()</code> is
<code><a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_right">right</a>!()</code>.

- <code>b00000000</code> - none - 0
- <code>b00000001</code> - up - 1
- <code>b00000010</code> - right - 2
- <code>b00000100</code> - down - 4
- <code>b00001000</code> - left - 8
- <code>b00000011</code> - up | right - 3
- <code>b00000110</code> - right | down - 6
- <code>b00001100</code> - down | left - 12
- <code>b00001001</code> - up | left - 9

Directions can be combined using bitwise OR or checked using bitwise AND.
```move
use grid::direction;


<a name="@[test]_0"></a>

## [test]

fun test_directions() {
let dir = direction::up!() | direction::right!();
assert_eq!(dir, direction::up_right!());

let is_left = direction::up_left!() & direction::left!() > 0;
assert!(is_left);
}
```


-  [[test]](#@[test]_0)
-  [Macro function `is_up`](#grid_direction_is_up)
-  [Macro function `is_down`](#grid_direction_is_down)
-  [Macro function `is_left`](#grid_direction_is_left)
-  [Macro function `is_right`](#grid_direction_is_right)
-  [Macro function `is_up_right`](#grid_direction_is_up_right)
-  [Macro function `is_down_right`](#grid_direction_is_down_right)
-  [Macro function `is_down_left`](#grid_direction_is_down_left)
-  [Macro function `is_up_left`](#grid_direction_is_up_left)
-  [Macro function `is_equal`](#grid_direction_is_equal)
-  [Macro function `is_direction_valid`](#grid_direction_is_direction_valid)
-  [Macro function `is_direction_vertical`](#grid_direction_is_direction_vertical)
-  [Macro function `is_direction_horizontal`](#grid_direction_is_direction_horizontal)
-  [Macro function `is_direction_diagonal`](#grid_direction_is_direction_diagonal)
-  [Macro function `up`](#grid_direction_up)
-  [Macro function `right`](#grid_direction_right)
-  [Macro function `down`](#grid_direction_down)
-  [Macro function `left`](#grid_direction_left)
-  [Macro function `up_right`](#grid_direction_up_right)
-  [Macro function `down_right`](#grid_direction_down_right)
-  [Macro function `down_left`](#grid_direction_down_left)
-  [Macro function `up_left`](#grid_direction_up_left)
-  [Macro function `none`](#grid_direction_none)
-  [Macro function `inverse`](#grid_direction_inverse)
-  [Macro function `direction`](#grid_direction_direction)
    -  [[test]](#@[test]_1)


<pre><code></code></pre>



<a name="grid_direction_is_up"></a>

## Macro function `is_up`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is up.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up">is_up</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up">is_up</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &gt; $row1 && $col0 == $col1
}
</code></pre>



</details>

<a name="grid_direction_is_down"></a>

## Macro function `is_down`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is down.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down">is_down</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down">is_down</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &lt; $row1 && $col0 == $col1
}
</code></pre>



</details>

<a name="grid_direction_is_left"></a>

## Macro function `is_left`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is left.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_left">is_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_left">is_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 &gt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_right"></a>

## Macro function `is_right`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is right.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_right">is_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_right">is_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 &lt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_up_right"></a>

## Macro function `is_up_right`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is up-right.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_right">is_up_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_right">is_up_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &gt; $row1 && $col0 &lt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_down_right"></a>

## Macro function `is_down_right`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is down-right.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_right">is_down_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_right">is_down_right</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &lt; $row1 && $col0 &lt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_down_left"></a>

## Macro function `is_down_left`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is down-left.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_left">is_down_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_left">is_down_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &gt; $row1 && $col0 &lt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_up_left"></a>

## Macro function `is_up_left`

Check if direction from <code>Cell0</code> to <code>Cell1</code> is up-left.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_left">is_up_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_left">is_up_left</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 &gt; $row1 && $col0 &gt; $col1
}
</code></pre>



</details>

<a name="grid_direction_is_equal"></a>

## Macro function `is_equal`

Check if position of <code>Cell0</code> to <code>Cell1</code> is the same.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_equal">is_equal</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_equal">is_equal</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): bool {
    $row0 == $row1 && $col0 == $col1
}
</code></pre>



</details>

<a name="grid_direction_is_direction_valid"></a>

## Macro function `is_direction_valid`

Validate <code>u8</code> direction input.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_valid">is_direction_valid</a>($d: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_valid">is_direction_valid</a>($d: u8): bool {
    <b>if</b> ($d & <a href="./direction.md#grid_direction_up">up</a>!() &gt; 0 && $d & <a href="./direction.md#grid_direction_down">down</a>!() &gt; 0) <b>return</b> <b>false</b>
    <b>else</b> <b>if</b> ($d & <a href="./direction.md#grid_direction_left">left</a>!() &gt; 0 && $d & <a href="./direction.md#grid_direction_right">right</a>!() &gt; 0) <b>return</b> <b>false</b>
    <b>else</b> <b>true</b>
}
</code></pre>



</details>

<a name="grid_direction_is_direction_vertical"></a>

## Macro function `is_direction_vertical`

Check whether given <code>u8</code> direction is vertical: up or down.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_vertical">is_direction_vertical</a>($d: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_vertical">is_direction_vertical</a>($d: u8): bool {
    $d == <a href="./direction.md#grid_direction_up">up</a>!() || $d == <a href="./direction.md#grid_direction_down">down</a>!()
}
</code></pre>



</details>

<a name="grid_direction_is_direction_horizontal"></a>

## Macro function `is_direction_horizontal`

Check whether given <code>u8</code> direction is horizontal: left or right.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_horizontal">is_direction_horizontal</a>($d: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_horizontal">is_direction_horizontal</a>($d: u8): bool {
    $d == <a href="./direction.md#grid_direction_left">left</a>!() || $d == <a href="./direction.md#grid_direction_right">right</a>!()
}
</code></pre>



</details>

<a name="grid_direction_is_direction_diagonal"></a>

## Macro function `is_direction_diagonal`

Check whether given <code>u8</code> direction is diagonal.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_diagonal">is_direction_diagonal</a>($d: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_direction_diagonal">is_direction_diagonal</a>($d: u8): bool {
    $d == <a href="./direction.md#grid_direction_up_right">up_right</a>!() || $d == <a href="./direction.md#grid_direction_up_left">up_left</a>!() || $d == <a href="./direction.md#grid_direction_down_right">down_right</a>!() || $d == <a href="./direction.md#grid_direction_down_left">down_left</a>!()
}
</code></pre>



</details>

<a name="grid_direction_up"></a>

## Macro function `up`

Direction: up


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up">up</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up">up</a>(): u8 { 1 &lt;&lt; 0 }
</code></pre>



</details>

<a name="grid_direction_right"></a>

## Macro function `right`

Direction: right


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_right">right</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_right">right</a>(): u8 { 1 &lt;&lt; 1 }
</code></pre>



</details>

<a name="grid_direction_down"></a>

## Macro function `down`

Direction: down


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down">down</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down">down</a>(): u8 { 1 &lt;&lt; 2 }
</code></pre>



</details>

<a name="grid_direction_left"></a>

## Macro function `left`

Direction: left


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_left">left</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_left">left</a>(): u8 { 1 &lt;&lt; 3 }
</code></pre>



</details>

<a name="grid_direction_up_right"></a>

## Macro function `up_right`

Direction: up | right
Can be represented as <code><a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_right">right</a>!()</code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up_right">up_right</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up_right">up_right</a>(): u8 { <a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_right">right</a>!() }
</code></pre>



</details>

<a name="grid_direction_down_right"></a>

## Macro function `down_right`

Direction: down | right
Can be represented as <code><a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_right">right</a>!()</code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down_right">down_right</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down_right">down_right</a>(): u8 { <a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_right">right</a>!() }
</code></pre>



</details>

<a name="grid_direction_down_left"></a>

## Macro function `down_left`

Direction: down | left
Can be represented as <code><a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_left">left</a>!()</code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down_left">down_left</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_down_left">down_left</a>(): u8 { <a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_left">left</a>!() }
</code></pre>



</details>

<a name="grid_direction_up_left"></a>

## Macro function `up_left`

Direction: up | left
Can be represented as <code><a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_left">left</a>!()</code>.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up_left">up_left</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_up_left">up_left</a>(): u8 { <a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_left">left</a>!() }
</code></pre>



</details>

<a name="grid_direction_none"></a>

## Macro function `none`

Direction: none


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_none">none</a>(): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_none">none</a>(): u8 { 0 }
</code></pre>



</details>

<a name="grid_direction_inverse"></a>

## Macro function `inverse`

Get the inverse of a given direction.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_inverse">inverse</a>($<a href="./direction.md#grid_direction">direction</a>: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_inverse">inverse</a>($<a href="./direction.md#grid_direction">direction</a>: u8): u8 {
    match ($<a href="./direction.md#grid_direction">direction</a>) {
        1 =&gt; <a href="./direction.md#grid_direction_down">down</a>!(),
        2 =&gt; <a href="./direction.md#grid_direction_left">left</a>!(),
        4 =&gt; <a href="./direction.md#grid_direction_up">up</a>!(),
        8 =&gt; <a href="./direction.md#grid_direction_right">right</a>!(),
        3 =&gt; <a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_left">left</a>!(),
        9 =&gt; <a href="./direction.md#grid_direction_down">down</a>!() | <a href="./direction.md#grid_direction_right">right</a>!(),
        6 =&gt; <a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_left">left</a>!(),
        12 =&gt; <a href="./direction.md#grid_direction_up">up</a>!() | <a href="./direction.md#grid_direction_right">right</a>!(),
        _ =&gt; <b>abort</b>,
    }
}
</code></pre>



</details>

<a name="grid_direction_direction"></a>

## Macro function `direction`

Get the direction from cell <code>(x0, y0)</code> to cell <code>(x1, y1)</code>.
For convenience, takes any integer type, but <code>Grid</code> uses <code>u16</code>.

```move
use grid::direction;


<a name="@[test]_1"></a>

### [test]

fun test_direction() {
let dir = direction::direction!(0, 0, 1, 0);
assert_eq!(dir, direction::right!());
}
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction">direction</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction">direction</a>&lt;$T: drop&gt;($row0: $T, $col0: $T, $row1: $T, $col1: $T): u8 {
    <b>let</b> diff_x = num_diff!($row0, $row1);
    <b>let</b> diff_y = num_diff!($col0, $col1);
    // same tile, one of the axis matches or one dominates
    <b>if</b> (diff_x == 0 && diff_y == 0) <b>return</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>let</b> horizontal_direction = <b>if</b> ($row0 &lt; $row1) <a href="./direction.md#grid_direction_down">down</a>!()
    <b>else</b> <b>if</b> ($row0 &gt; $row1) <a href="./direction.md#grid_direction_up">up</a>!()
    <b>else</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>let</b> vertical_direction = <b>if</b> ($col0 &lt; $col1) <a href="./direction.md#grid_direction_right">right</a>!()
    <b>else</b> <b>if</b> ($col0 &gt; $col1) <a href="./direction.md#grid_direction_left">left</a>!()
    <b>else</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>if</b> (horizontal_direction == <a href="./direction.md#grid_direction_none">none</a>!() || diff_y &gt; diff_x) <b>return</b> vertical_direction;
    <b>if</b> (vertical_direction == <a href="./direction.md#grid_direction_none">none</a>!() || diff_x &gt; diff_y) <b>return</b> horizontal_direction;
    horizontal_direction | vertical_direction // diagonals
}
</code></pre>



</details>
