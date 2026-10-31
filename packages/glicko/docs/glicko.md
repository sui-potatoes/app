
<a name="glicko_glicko"></a>

# Module `glicko::glicko`

Glicko rating on <code><a href="../../.doc-deps/std/uq64_64.md#std_uq64_64">std::uq64_64</a></code> fixed-point arithmetic.

Every player carries a <code><a href="./glicko.md#glicko_glicko_rating">rating</a></code> and a <code><a href="./glicko.md#glicko_glicko_deviation">deviation</a></code> (RD). The deviation is the
uncertainty of the rating: newcomers start at <code><a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a></code>, converge
towards <code><a href="./glicko.md#glicko_glicko_MIN_DEVIATION">MIN_DEVIATION</a></code> as they play and drift back up while inactive. The
size of a single update is scaled by both players' deviations, so new
players converge fast while established ratings stay stable.

Pure library: no objects, no storage. Keep <code><a href="./glicko.md#glicko_glicko_Rating">Rating</a></code> values wherever the
application sees fit and call <code><a href="./glicko.md#glicko_glicko_compute">compute</a></code> once after every game to get both
players' new ratings.

Square roots use a seeded Newton iteration instead of the bit-by-bit
<code><a href="./glicko.md#glicko_glicko_sqrt">sqrt</a></code> of the integer modules: the seeds are always within a few tens of
percent of the result, so five steps reach fixed-point precision at a
fraction of the cost.

Reference: Glickman, M. E. "The Glicko system" (1995), with a rating period
of a single game and the inactivity constant <code>c</code> applied per day.

Traits:
- default


-  [Struct `Rating`](#glicko_glicko_Rating)
-  [Enum `Score`](#glicko_glicko_Score)
-  [Constants](#@Constants_0)
-  [Function `default`](#glicko_glicko_default)
-  [Function `new`](#glicko_glicko_new)
-  [Function `win`](#glicko_glicko_win)
-  [Function `draw`](#glicko_glicko_draw)
-  [Function `loss`](#glicko_glicko_loss)
-  [Function `rating`](#glicko_glicko_rating)
-  [Function `deviation`](#glicko_glicko_deviation)
-  [Function `games`](#glicko_glicko_games)
-  [Function `last_played_ms`](#glicko_glicko_last_played_ms)
-  [Function `current_deviation`](#glicko_glicko_current_deviation)
-  [Function `expected_score`](#glicko_glicko_expected_score)
-  [Function `compute`](#glicko_glicko_compute)
-  [Function `compute_one`](#glicko_glicko_compute_one)
-  [Function `g`](#glicko_glicko_g)
-  [Function `expected`](#glicko_glicko_expected)
-  [Function `sqrt`](#glicko_glicko_sqrt)
-  [Function `round`](#glicko_glicko_round)


<pre><code><b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/u64.md#std_u64">std::u64</a>;
<b>use</b> <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64">std::uq64_64</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
</code></pre>



<a name="glicko_glicko_Rating"></a>

## Struct `Rating`

Rating of a single player.


<pre><code><b>public</b> <b>struct</b> <a href="./glicko.md#glicko_glicko_Rating">Rating</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./glicko.md#glicko_glicko_rating">rating</a>: u64</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./glicko.md#glicko_glicko_deviation">deviation</a>: u64</code>
</dt>
<dd>
</dd>
<dt>
<code><a href="./glicko.md#glicko_glicko_games">games</a>: u64</code>
</dt>
<dd>
 Number of rated games played.
</dd>
<dt>
<code><a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>: u64</code>
</dt>
<dd>
 Timestamp of the last rated game, used for inactivity growth.
</dd>
</dl>


</details>

<a name="glicko_glicko_Score"></a>

## Enum `Score`

Result of a game from the perspective of the first player passed to
<code><a href="./glicko.md#glicko_glicko_compute">compute</a></code>.


<pre><code><b>public</b> <b>enum</b> <a href="./glicko.md#glicko_glicko_Score">Score</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Win</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Draw</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Loss</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="glicko_glicko_ONE_RAW"></a>

<code>1</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_ONE_RAW">ONE_RAW</a>: u128 = 18446744073709551616;
</code></pre>



<a name="glicko_glicko_HALF_RAW"></a>

<code>1 / 2</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_HALF_RAW">HALF_RAW</a>: u128 = 9223372036854775808;
</code></pre>



<a name="glicko_glicko_Q_RAW"></a>

<code>q = ln(10) / 400</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_Q_RAW">Q_RAW</a>: u128 = 106187994795999673;
</code></pre>



<a name="glicko_glicko_Q2_RAW"></a>

<code>q^2</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_Q2_RAW">Q2_RAW</a>: u128 = 611267234680495;
</code></pre>



<a name="glicko_glicko_G_COEF_RAW"></a>

<code>3 * q^2 / pi^2</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_G_COEF_RAW">G_COEF_RAW</a>: u128 = 185802959218819;
</code></pre>



<a name="glicko_glicko_G_SEED_RAW"></a>

<code>5 / 4</code>: Newton seed for <code><a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(1 + 3 * q^2 * RD^2 / pi^2)</code>, which lies in
<code>[1.0045, 1.4946]</code> for every valid deviation.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_G_SEED_RAW">G_SEED_RAW</a>: u128 = 23058430092136939520;
</code></pre>



<a name="glicko_glicko_SQRT_STEPS"></a>

Newton steps per square root. Quadratic convergence from the seeds used here
leaves an error far below <code>2^-64</code> after five.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_SQRT_STEPS">SQRT_STEPS</a>: u64 = 5;
</code></pre>



<a name="glicko_glicko_E6"></a>

Denominator of the <code><a href="./glicko.md#glicko_glicko_E_TABLE">E_TABLE</a></code> entries.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_E6">E6</a>: u128 = 1000000;
</code></pre>



<a name="glicko_glicko_E_STEP_E2"></a>

Distance between <code><a href="./glicko.md#glicko_glicko_E_TABLE">E_TABLE</a></code> entries, in hundredths of a rating point.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_E_STEP_E2">E_STEP_E2</a>: u128 = 2500;
</code></pre>



<a name="glicko_glicko_E_TABLE"></a>

<code>E(d) = 1 / (1 + 10^(-d / 400))</code> for <code>d = 0, 25, 50, ..., 2000</code>, in
millionths. Values past the end of the table are clamped to the last entry.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_E_TABLE">E_TABLE</a>: vector&lt;u32&gt; = vector[500000, 535916, 571463, 606288, 640065, 672510, 703385, 732507, 759747, 785027, 808318, 829633, 849020, 866557, 882338, 896477, 909091, 920305, 930242, 939022, 946760, 953565, 959537, 964769, 969347, 973346, 976836, 979878, 982528, 984834, 986840, 988584, 990099, 991415, 992557, 993548, 994408, 995154, 995801, 996362, 996848, 997269, 997634, 997951, 998225, 998462, 998668, 998847, 999001, 999135, 999251, 999351, 999438, 999513, 999578, 999635, 999684, 999726, 999763, 999795, 999822, 999846, 999867, 999885, 999900, 999913, 999925, 999935, 999944, 999951, 999958, 999963, 999968, 999973, 999976, 999979, 999982, 999985, 999987, 999988, 999990];
</code></pre>



<a name="glicko_glicko_DEFAULT_RATING"></a>

Rating of a player who has never played.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_DEFAULT_RATING">DEFAULT_RATING</a>: u64 = 1500;
</code></pre>



<a name="glicko_glicko_MAX_DEVIATION"></a>

Deviation of a player who has never played; also the upper bound.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>: u64 = 350;
</code></pre>



<a name="glicko_glicko_MIN_DEVIATION"></a>

Lower bound of the deviation, keeps established ratings movable.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_MIN_DEVIATION">MIN_DEVIATION</a>: u64 = 30;
</code></pre>



<a name="glicko_glicko_C2_PER_DAY"></a>

<code>c^2</code>: growth of <code><a href="./glicko.md#glicko_glicko_deviation">deviation</a>^2</code> per day of inactivity. A fully converged
player returns to <code><a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a></code> after roughly 100 days without games.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_C2_PER_DAY">C2_PER_DAY</a>: u64 = 1200;
</code></pre>



<a name="glicko_glicko_MS_PER_DAY"></a>



<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_MS_PER_DAY">MS_PER_DAY</a>: u64 = 86400000;
</code></pre>



<a name="glicko_glicko_EInvalidDeviation"></a>

Deviation passed to <code><a href="./glicko.md#glicko_glicko_new">new</a></code> is outside <code>[<a href="./glicko.md#glicko_glicko_MIN_DEVIATION">MIN_DEVIATION</a>, <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>]</code>.


<pre><code><b>const</b> <a href="./glicko.md#glicko_glicko_EInvalidDeviation">EInvalidDeviation</a>: u64 = 0;
</code></pre>



<a name="glicko_glicko_default"></a>

## Function `default`

Rating of a player who has never played.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_default">default</a>(): <a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_default">default</a>(): <a href="./glicko.md#glicko_glicko_Rating">Rating</a> {
    <a href="./glicko.md#glicko_glicko_Rating">Rating</a> { <a href="./glicko.md#glicko_glicko_rating">rating</a>: <a href="./glicko.md#glicko_glicko_DEFAULT_RATING">DEFAULT_RATING</a>, <a href="./glicko.md#glicko_glicko_deviation">deviation</a>: <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>, <a href="./glicko.md#glicko_glicko_games">games</a>: 0, <a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>: 0 }
}
</code></pre>



</details>

<a name="glicko_glicko_new"></a>

## Function `new`

Create a <code><a href="./glicko.md#glicko_glicko_Rating">Rating</a></code> with explicit values and no history.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_new">new</a>(<a href="./glicko.md#glicko_glicko_rating">rating</a>: u64, <a href="./glicko.md#glicko_glicko_deviation">deviation</a>: u64): <a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_new">new</a>(<a href="./glicko.md#glicko_glicko_rating">rating</a>: u64, <a href="./glicko.md#glicko_glicko_deviation">deviation</a>: u64): <a href="./glicko.md#glicko_glicko_Rating">Rating</a> {
    <b>assert</b>!(<a href="./glicko.md#glicko_glicko_deviation">deviation</a> &gt;= <a href="./glicko.md#glicko_glicko_MIN_DEVIATION">MIN_DEVIATION</a> && <a href="./glicko.md#glicko_glicko_deviation">deviation</a> &lt;= <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>, <a href="./glicko.md#glicko_glicko_EInvalidDeviation">EInvalidDeviation</a>);
    <a href="./glicko.md#glicko_glicko_Rating">Rating</a> { <a href="./glicko.md#glicko_glicko_rating">rating</a>, <a href="./glicko.md#glicko_glicko_deviation">deviation</a>, <a href="./glicko.md#glicko_glicko_games">games</a>: 0, <a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>: 0 }
}
</code></pre>



</details>

<a name="glicko_glicko_win"></a>

## Function `win`

Score of the winning side.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_win">win</a>(): <a href="./glicko.md#glicko_glicko_Score">glicko::glicko::Score</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_win">win</a>(): <a href="./glicko.md#glicko_glicko_Score">Score</a> { Score::Win }
</code></pre>



</details>

<a name="glicko_glicko_draw"></a>

## Function `draw`

Score of either side in a draw.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_draw">draw</a>(): <a href="./glicko.md#glicko_glicko_Score">glicko::glicko::Score</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_draw">draw</a>(): <a href="./glicko.md#glicko_glicko_Score">Score</a> { Score::Draw }
</code></pre>



</details>

<a name="glicko_glicko_loss"></a>

## Function `loss`

Score of the losing side.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_loss">loss</a>(): <a href="./glicko.md#glicko_glicko_Score">glicko::glicko::Score</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_loss">loss</a>(): <a href="./glicko.md#glicko_glicko_Score">Score</a> { Score::Loss }
</code></pre>



</details>

<a name="glicko_glicko_rating"></a>

## Function `rating`

Rating in points.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_rating">rating</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_rating">rating</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>): u64 { r.<a href="./glicko.md#glicko_glicko_rating">rating</a> }
</code></pre>



</details>

<a name="glicko_glicko_deviation"></a>

## Function `deviation`

Rating deviation as stored, without inactivity growth. See <code><a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_deviation">deviation</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_deviation">deviation</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>): u64 { r.<a href="./glicko.md#glicko_glicko_deviation">deviation</a> }
</code></pre>



</details>

<a name="glicko_glicko_games"></a>

## Function `games`

Number of rated games played.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_games">games</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_games">games</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>): u64 { r.<a href="./glicko.md#glicko_glicko_games">games</a> }
</code></pre>



</details>

<a name="glicko_glicko_last_played_ms"></a>

## Function `last_played_ms`

Timestamp of the last rated game, <code>0</code> if none.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>): u64 { r.<a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a> }
</code></pre>



</details>

<a name="glicko_glicko_current_deviation"></a>

## Function `current_deviation`

Deviation adjusted for the time passed since the last game:
<code>min(<a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(RD^2 + c^2 * days), <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>)</code>. Unchanged within a day.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, now_ms: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a>(r: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, now_ms: u64): u64 {
    <b>if</b> (now_ms &lt;= r.<a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>) <b>return</b> r.<a href="./glicko.md#glicko_glicko_deviation">deviation</a>;
    <b>let</b> days = (now_ms - r.<a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>) / <a href="./glicko.md#glicko_glicko_MS_PER_DAY">MS_PER_DAY</a>;
    <b>if</b> (days == 0) <b>return</b> r.<a href="./glicko.md#glicko_glicko_deviation">deviation</a>;
    <b>let</b> rd = r.<a href="./glicko.md#glicko_glicko_deviation">deviation</a>;
    <b>let</b> growth = <a href="./glicko.md#glicko_glicko_C2_PER_DAY">C2_PER_DAY</a> * days;
    <b>let</b> n = rd * rd + growth;
    <b>if</b> (n &gt;= <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a> * <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>) <b>return</b> <a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>;
    // Integer Newton from `RD + growth / 2RD`, the first-order estimate of the
    // root and an upper bound of it (capped by the maximum, also an upper
    // bound). From above, `y &lt;- (y + n / y) / 2` descends monotonically and
    // stops at `floor(<a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(n))`.
    <b>let</b> <b>mut</b> y = (rd + growth / (2 * rd)).min(<a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>);
    <b>loop</b> {
        <b>let</b> next = (y + n / y) / 2;
        <b>if</b> (next &gt;= y) <b>return</b> y;
        y = next;
    }
}
</code></pre>



</details>

<a name="glicko_glicko_expected_score"></a>

## Function `expected_score`

Expected score of <code>player</code> against <code>opponent</code>, in millionths.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_expected_score">expected_score</a>(player: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, opponent: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, now_ms: u64): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_expected_score">expected_score</a>(player: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, opponent: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, now_ms: u64): u64 {
    <b>let</b> <a href="./glicko.md#glicko_glicko_g">g</a> = <a href="./glicko.md#glicko_glicko_g">g</a>(opponent.<a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a>(now_ms));
    uq64_64::int_mul(<a href="./glicko.md#glicko_glicko_E6">E6</a>, <a href="./glicko.md#glicko_glicko_expected">expected</a>(<a href="./glicko.md#glicko_glicko_g">g</a>, player.<a href="./glicko.md#glicko_glicko_rating">rating</a>, opponent.<a href="./glicko.md#glicko_glicko_rating">rating</a>)) <b>as</b> u64
}
</code></pre>



</details>

<a name="glicko_glicko_compute"></a>

## Function `compute`

Compute both ratings after a single game between <code>a</code> and <code>b</code>, with <code>score</code>
from <code>a</code>'s perspective. Pure: the inputs are the pre-game values, neither is
modified, and both results derive from the pre-game values as Glicko
requires. Returns <code>(a', b')</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_compute">compute</a>(a: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, b: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, score: <a href="./glicko.md#glicko_glicko_Score">glicko::glicko::Score</a>, now_ms: u64): (<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, <a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./glicko.md#glicko_glicko_compute">compute</a>(a: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, b: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, score: <a href="./glicko.md#glicko_glicko_Score">Score</a>, now_ms: u64): (<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, <a href="./glicko.md#glicko_glicko_Rating">Rating</a>) {
    <b>let</b> opposite = match (score) {
        Score::Win =&gt; Score::Loss,
        Score::Draw =&gt; Score::Draw,
        Score::Loss =&gt; Score::Win,
    };
    (<a href="./glicko.md#glicko_glicko_compute_one">compute_one</a>(a, b, score, now_ms), <a href="./glicko.md#glicko_glicko_compute_one">compute_one</a>(b, a, opposite, now_ms))
}
</code></pre>



</details>

<a name="glicko_glicko_compute_one"></a>

## Function `compute_one`

Rating of <code>player</code> after a single game against <code>opponent</code>.


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_compute_one">compute_one</a>(player: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, opponent: &<a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>, score: <a href="./glicko.md#glicko_glicko_Score">glicko::glicko::Score</a>, now_ms: u64): <a href="./glicko.md#glicko_glicko_Rating">glicko::glicko::Rating</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_compute_one">compute_one</a>(player: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, opponent: &<a href="./glicko.md#glicko_glicko_Rating">Rating</a>, score: <a href="./glicko.md#glicko_glicko_Score">Score</a>, now_ms: u64): <a href="./glicko.md#glicko_glicko_Rating">Rating</a> {
    <b>let</b> rd = player.<a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a>(now_ms);
    <b>let</b> <a href="./glicko.md#glicko_glicko_g">g</a> = <a href="./glicko.md#glicko_glicko_g">g</a>(opponent.<a href="./glicko.md#glicko_glicko_current_deviation">current_deviation</a>(now_ms));
    <b>let</b> e = <a href="./glicko.md#glicko_glicko_expected">expected</a>(<a href="./glicko.md#glicko_glicko_g">g</a>, player.<a href="./glicko.md#glicko_glicko_rating">rating</a>, opponent.<a href="./glicko.md#glicko_glicko_rating">rating</a>);
    <b>let</b> one = uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_ONE_RAW">ONE_RAW</a>);
    <b>let</b> s = match (score) {
        Score::Win =&gt; one,
        Score::Draw =&gt; uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_HALF_RAW">HALF_RAW</a>),
        Score::Loss =&gt; uq64_64::from_raw(0),
    };
    // A = 1 / RD^2 + q^2 * <a href="./glicko.md#glicko_glicko_g">g</a>^2 * E * (1 - E)
    <b>let</b> rd2 = (rd <b>as</b> u128) * (rd <b>as</b> u128);
    <b>let</b> q2 = uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_Q2_RAW">Q2_RAW</a>);
    <b>let</b> a = uq64_64::from_quotient(1, rd2).add(q2.mul(<a href="./glicko.md#glicko_glicko_g">g</a>).mul(<a href="./glicko.md#glicko_glicko_g">g</a>).mul(e).mul(one.sub(e)));
    // |r' - r| = q * <a href="./glicko.md#glicko_glicko_g">g</a> * |s - E| / A
    <b>let</b> is_gain = s.ge(e);
    <b>let</b> diff = <b>if</b> (is_gain) s.sub(e) <b>else</b> e.sub(s);
    <b>let</b> delta = <a href="./glicko.md#glicko_glicko_round">round</a>(uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_Q_RAW">Q_RAW</a>).mul(<a href="./glicko.md#glicko_glicko_g">g</a>).mul(diff).div(a));
    // RD' = <a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(1 / A); it never exceeds RD and stays above 0.7 RD, so RD
    // seeds the Newton iteration
    <b>let</b> rd_next = <a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(one.div(a), uq64_64::from_int(rd));
    <b>let</b> <a href="./glicko.md#glicko_glicko_deviation">deviation</a> = <a href="./glicko.md#glicko_glicko_round">round</a>(rd_next).max(<a href="./glicko.md#glicko_glicko_MIN_DEVIATION">MIN_DEVIATION</a>).min(<a href="./glicko.md#glicko_glicko_MAX_DEVIATION">MAX_DEVIATION</a>);
    <a href="./glicko.md#glicko_glicko_Rating">Rating</a> {
        <a href="./glicko.md#glicko_glicko_rating">rating</a>: <b>if</b> (is_gain) player.<a href="./glicko.md#glicko_glicko_rating">rating</a> + delta <b>else</b> player.<a href="./glicko.md#glicko_glicko_rating">rating</a> - delta.min(player.<a href="./glicko.md#glicko_glicko_rating">rating</a>),
        <a href="./glicko.md#glicko_glicko_deviation">deviation</a>,
        <a href="./glicko.md#glicko_glicko_games">games</a>: player.<a href="./glicko.md#glicko_glicko_games">games</a> + 1,
        <a href="./glicko.md#glicko_glicko_last_played_ms">last_played_ms</a>: now_ms,
    }
}
</code></pre>



</details>

<a name="glicko_glicko_g"></a>

## Function `g`

<code><a href="./glicko.md#glicko_glicko_g">g</a>(RD) = 1 / <a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(1 + 3 * q^2 * RD^2 / pi^2)</code>.


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_g">g</a>(<a href="./glicko.md#glicko_glicko_deviation">deviation</a>: u64): <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_g">g</a>(<a href="./glicko.md#glicko_glicko_deviation">deviation</a>: u64): UQ64_64 {
    <b>let</b> one = uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_ONE_RAW">ONE_RAW</a>);
    <b>let</b> rd2 = uq64_64::from_int(<a href="./glicko.md#glicko_glicko_deviation">deviation</a> * <a href="./glicko.md#glicko_glicko_deviation">deviation</a>);
    <b>let</b> n = one.add(uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_G_COEF_RAW">G_COEF_RAW</a>).mul(rd2));
    one.div(<a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(n, uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_G_SEED_RAW">G_SEED_RAW</a>)))
}
</code></pre>



</details>

<a name="glicko_glicko_expected"></a>

## Function `expected`

<code>E = 1 / (1 + 10^(-<a href="./glicko.md#glicko_glicko_g">g</a> * (r - r_j) / 400))</code>. Uses the symmetry
<code>E(-d) = 1 - E(d)</code> and linear interpolation over <code><a href="./glicko.md#glicko_glicko_E_TABLE">E_TABLE</a></code>.


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_expected">expected</a>(<a href="./glicko.md#glicko_glicko_g">g</a>: <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>, <a href="./glicko.md#glicko_glicko_rating">rating</a>: u64, opponent: u64): <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_expected">expected</a>(<a href="./glicko.md#glicko_glicko_g">g</a>: UQ64_64, <a href="./glicko.md#glicko_glicko_rating">rating</a>: u64, opponent: u64): UQ64_64 {
    <b>let</b> (diff, is_higher) = <b>if</b> (<a href="./glicko.md#glicko_glicko_rating">rating</a> &gt;= opponent) {
        ((<a href="./glicko.md#glicko_glicko_rating">rating</a> - opponent) <b>as</b> u128, <b>true</b>)
    } <b>else</b> {
        ((opponent - <a href="./glicko.md#glicko_glicko_rating">rating</a>) <b>as</b> u128, <b>false</b>)
    };
    // effective difference in hundredths of a point
    <b>let</b> d_e2 = uq64_64::int_mul(diff * 100, <a href="./glicko.md#glicko_glicko_g">g</a>);
    <b>let</b> table = <a href="./glicko.md#glicko_glicko_E_TABLE">E_TABLE</a>;
    <b>let</b> last = table.length() - 1;
    <b>let</b> idx = (d_e2 / <a href="./glicko.md#glicko_glicko_E_STEP_E2">E_STEP_E2</a>) <b>as</b> u64;
    <b>let</b> e_e6 = <b>if</b> (idx &gt;= last) table[last] <b>as</b> u128
    <b>else</b> {
        <b>let</b> (lo, hi) = (table[idx] <b>as</b> u128, table[idx + 1] <b>as</b> u128);
        lo + (hi - lo) * (d_e2 % <a href="./glicko.md#glicko_glicko_E_STEP_E2">E_STEP_E2</a>) / <a href="./glicko.md#glicko_glicko_E_STEP_E2">E_STEP_E2</a>
    };
    <b>let</b> e = uq64_64::from_quotient(e_e6, <a href="./glicko.md#glicko_glicko_E6">E6</a>);
    <b>if</b> (is_higher) e <b>else</b> uq64_64::from_raw(<a href="./glicko.md#glicko_glicko_ONE_RAW">ONE_RAW</a>).sub(e)
}
</code></pre>



</details>

<a name="glicko_glicko_sqrt"></a>

## Function `sqrt`

Square root by Newton's method, <code>y &lt;- (y + x / y) / 2</code>, starting from
<code>seed</code>. Callers pass a seed within a few tens of percent of the result.


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(x: <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>, seed: <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>): <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_sqrt">sqrt</a>(x: UQ64_64, seed: UQ64_64): UQ64_64 {
    <b>let</b> <b>mut</b> y = seed;
    <a href="./glicko.md#glicko_glicko_SQRT_STEPS">SQRT_STEPS</a>.do!(|_| y = uq64_64::from_raw((y.to_raw() + x.div(y).to_raw()) &gt;&gt; 1));
    y
}
</code></pre>



</details>

<a name="glicko_glicko_round"></a>

## Function `round`

Round to the nearest integer.


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_round">round</a>(x: <a href="../../.doc-deps/std/uq64_64.md#std_uq64_64_UQ64_64">std::uq64_64::UQ64_64</a>): u64
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./glicko.md#glicko_glicko_round">round</a>(x: UQ64_64): u64 {
    uq64_64::from_raw(x.to_raw() + <a href="./glicko.md#glicko_glicko_HALF_RAW">HALF_RAW</a>).to_int()
}
</code></pre>



</details>
