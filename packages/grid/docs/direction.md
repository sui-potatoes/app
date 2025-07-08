
<a name="grid_direction"></a>

# Module `grid::direction`

The <code><a href="./direction.md#grid_direction">direction</a></code> module provides macros to check the relative positions of
points on a grid as well as constants for the directions. Currently, the
main consumer of this module is <code><a href="./cursor.md#grid_cursor">cursor</a></code>.

Grid axes are defined as follows:
- X-axis: vertical axis (top->down)
- Y-axis: horizontal axis (left->right)

Hence, the (0, 0) point is at the top-left corner of the grid.

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
```
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

Check if a point is above another point (decrease in X).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up">is_up</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up">is_up</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &gt; $x1 && $y0 == $y1
}
</code></pre>



</details>

<a name="grid_direction_is_down"></a>

## Macro function `is_down`

Check if a point is below another point (increase in X).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down">is_down</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down">is_down</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &lt; $x1 && $y0 == $y1
}
</code></pre>



</details>

<a name="grid_direction_is_left"></a>

## Macro function `is_left`

Check if a point is to the left of another point (decrease in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_left">is_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_left">is_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 &gt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_right"></a>

## Macro function `is_right`

Check if a point is to the right of another point (increase in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_right">is_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_right">is_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 &lt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_up_right"></a>

## Macro function `is_up_right`

Check if a point is up-right of another point (decrease in X, increase in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_right">is_up_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_right">is_up_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &gt; $x1 && $y0 &lt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_down_right"></a>

## Macro function `is_down_right`

Check if a point is down-right of another point (increase in X, increase in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_right">is_down_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_right">is_down_right</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &lt; $x1 && $y0 &lt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_down_left"></a>

## Macro function `is_down_left`

Check if a point is down-left of another point (increase in X, decrease in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_left">is_down_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_down_left">is_down_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &lt; $x1 && $y0 &gt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_up_left"></a>

## Macro function `is_up_left`

Check if a point is up-left of another point (decrease in X, decrease in Y).


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_left">is_up_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_up_left">is_up_left</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 &gt; $x1 && $y0 &gt; $y1
}
</code></pre>



</details>

<a name="grid_direction_is_equal"></a>

## Macro function `is_equal`

Check if a point is equal to another point.


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_equal">is_equal</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction_is_equal">is_equal</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): bool {
    $x0 == $x1 && $y0 == $y1
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

Get the inverse direction of a given direction.


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

Get the direction from point <code>(x0, y0)</code> to point <code>(x1, y1)</code>.
For convenience, takes any integer type, but <code>Grid</code> uses <code>u16</code>.

```rust
use grid::direction;


<a name="@[test]_1"></a>

### [test]

fun test_direction() {
let dir = direction::direction!(0, 0, 1, 0);
assert_eq!(dir, direction::right!());
}
```


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction">direction</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./direction.md#grid_direction">direction</a>&lt;$T: drop&gt;($x0: $T, $y0: $T, $x1: $T, $y1: $T): u8 {
    <b>let</b> diff_x = num_diff!($x0, $x1);
    <b>let</b> diff_y = num_diff!($y0, $y1);
    // same tile, one of the axis matches or one dominates
    <b>if</b> (diff_x == 0 && diff_y == 0) <b>return</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>let</b> x_direction = <b>if</b> ($x0 &lt; $x1) <a href="./direction.md#grid_direction_down">down</a>!()
    <b>else</b> <b>if</b> ($x0 &gt; $x1) <a href="./direction.md#grid_direction_up">up</a>!()
    <b>else</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>let</b> y_direction = <b>if</b> ($y0 &lt; $y1) <a href="./direction.md#grid_direction_right">right</a>!()
    <b>else</b> <b>if</b> ($y0 &gt; $y1) <a href="./direction.md#grid_direction_left">left</a>!()
    <b>else</b> <a href="./direction.md#grid_direction_none">none</a>!();
    <b>if</b> (x_direction == <a href="./direction.md#grid_direction_none">none</a>!() || diff_y &gt; diff_x) <b>return</b> y_direction;
    <b>if</b> (y_direction == <a href="./direction.md#grid_direction_none">none</a>!() || diff_x &gt; diff_y) <b>return</b> x_direction;
    x_direction | y_direction // diagonals
}
</code></pre>



</details>
