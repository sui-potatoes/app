
<a name="grid_macros"></a>

# Module `grid::macros`

General utility macros for the Grid package. The macros used to be <code><b>public</b></code>
in the <code><b>move</b>-stdlib</code>, but then the visibility was changed to <code><b>public</b>(package)</code>.


-  [Macro function `num_max`](#grid_macros_num_max)
-  [Macro function `num_min`](#grid_macros_num_min)
-  [Macro function `num_diff`](#grid_macros_num_diff)


<pre><code></code></pre>



<a name="grid_macros_num_max"></a>

## Macro function `num_max`



<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_max">num_max</a>&lt;$T&gt;($x: $T, $y: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_max">num_max</a>&lt;$T&gt;($x: $T, $y: $T): $T {
    <b>let</b> x = $x;
    <b>let</b> y = $y;
    <b>if</b> (x &gt; y) x <b>else</b> y
}
</code></pre>



</details>

<a name="grid_macros_num_min"></a>

## Macro function `num_min`



<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_min">num_min</a>&lt;$T&gt;($x: $T, $y: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_min">num_min</a>&lt;$T&gt;($x: $T, $y: $T): $T {
    <b>let</b> x = $x;
    <b>let</b> y = $y;
    <b>if</b> (x &lt; y) x <b>else</b> y
}
</code></pre>



</details>

<a name="grid_macros_num_diff"></a>

## Macro function `num_diff`



<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_diff">num_diff</a>&lt;$T&gt;($x: $T, $y: $T): $T
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>macro</b> <b>fun</b> <a href="./macros.md#grid_macros_num_diff">num_diff</a>&lt;$T&gt;($x: $T, $y: $T): $T {
    <b>let</b> x = $x;
    <b>let</b> y = $y;
    <b>if</b> (x &gt; y) x - y <b>else</b> y - x
}
</code></pre>



</details>
