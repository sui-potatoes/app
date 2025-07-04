
<a name="sui_types"></a>

# Module `sui::types`

Sui types helpers and utilities


-  [Function `is_one_time_witness`](#sui_types_is_one_time_witness)


<pre><code></code></pre>



<a name="sui_types_is_one_time_witness"></a>

## Function `is_one_time_witness`

Tests if the argument type is a one-time witness, that is a type with only one instantiation
across the entire code base.


<pre><code><b>public</b> <b>fun</b> <a href="../../dependencies/sui/types.md#sui_types_is_one_time_witness">is_one_time_witness</a>&lt;T: drop&gt;(_: &T): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>native</b> <b>fun</b> <a href="../../dependencies/sui/types.md#sui_types_is_one_time_witness">is_one_time_witness</a>&lt;T: drop&gt;(_: &T): bool;
</code></pre>



</details>
