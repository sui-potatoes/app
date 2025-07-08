
<a name="go_game_go"></a>

# Module `go_game::go`

Implements the actual game of Go.


-  [Struct `Board`](#go_game_go_Board)
-  [Struct `Score`](#go_game_go_Score)
-  [Struct `Group`](#go_game_go_Group)
-  [Enum `Tile`](#go_game_go_Tile)
-  [Constants](#@Constants_0)
-  [Function `new`](#go_game_go_new)
-  [Function `place`](#go_game_go_place)
-  [Function `find_group`](#go_game_go_find_group)
-  [Function `is_group_surrounded`](#go_game_go_is_group_surrounded)
-  [Function `size`](#go_game_go_size)
-  [Function `grid`](#go_game_go_grid)
-  [Function `borrow`](#go_game_go_borrow)
-  [Function `is_black_turn`](#go_game_go_is_black_turn)
-  [Function `is_empty`](#go_game_go_is_empty)
-  [Function `is_black`](#go_game_go_is_black)
-  [Function `is_white`](#go_game_go_is_white)
-  [Function `tile_to_string`](#go_game_go_tile_to_string)
-  [Function `tile_to_number`](#go_game_go_tile_to_number)


<pre><code><b>use</b> (<a href="./go.md#go_game_go_grid">grid</a>=0x0)::<a href="./go.md#go_game_go_grid">grid</a>;
<b>use</b> (<a href="./go.md#go_game_go_grid">grid</a>=0x0)::point;
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



<a name="go_game_go_Board"></a>

## Struct `Board`

The game board.


<pre><code><b>public</b> <b>struct</b> <a href="./go.md#go_game_go_Board">Board</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./go.md#go_game_go_size">size</a>: u16</code>
</dt>
<dd>
 The size of the board.
</dd>
<dt>
<code><a href="./go.md#go_game_go_grid">grid</a>: (<a href="./go.md#go_game_go_grid">grid</a>=0x0)::grid::Grid&lt;<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>&gt;</code>
</dt>
<dd>
 The internal grid of the Game.
</dd>
<dt>
<code><a href="./go.md#go_game_go_is_black">is_black</a>: bool</code>
</dt>
<dd>
 The current player. <code><b>true</b></code> if black, <code><b>false</b></code> if white.
</dd>
<dt>
<code>score: <a href="./go.md#go_game_go_Score">go_game::go::Score</a></code>
</dt>
<dd>
 Captured stones.
</dd>
<dt>
<code>moves: vector&lt;(<a href="./go.md#go_game_go_grid">grid</a>=0x0)::point::Point&gt;</code>
</dt>
<dd>
 Stores history of moves.
</dd>
<dt>
<code>prev_states: vector&lt;(<a href="./go.md#go_game_go_grid">grid</a>=0x0)::grid::Grid&lt;<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>&gt;&gt;</code>
</dt>
<dd>
 Stores last 2 states to implement the ko rule.
</dd>
</dl>


</details>

<a name="go_game_go_Score"></a>

## Struct `Score`

The score of the game, black and white stones.


<pre><code><b>public</b> <b>struct</b> <a href="./go.md#go_game_go_Score">Score</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>black: u16</code>
</dt>
<dd>
</dd>
<dt>
<code>white: u16</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="go_game_go_Group"></a>

## Struct `Group`

A group of stones on the board. Tile marks the color of the group.
Empty tile returns an empty group.


<pre><code><b>public</b> <b>struct</b> <a href="./go.md#go_game_go_Group">Group</a> <b>has</b> <b>copy</b>, drop
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>0: <a href="./go.md#go_game_go_Tile">go_game::go::Tile</a></code>
</dt>
<dd>
</dd>
<dt>
<code>1: vector&lt;(<a href="./go.md#go_game_go_grid">grid</a>=0x0)::point::Point&gt;</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="go_game_go_Tile"></a>

## Enum `Tile`

A tile on the board. Implements a <code>to_string</code> method to allow printing.


<pre><code><b>public</b> <b>enum</b> <a href="./go.md#go_game_go_Tile">Tile</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Empty</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>Black</code>
</dt>
<dd>
</dd>
<dt>
Variant <code>White</code>
</dt>
<dd>
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="go_game_go_EInvalidMove"></a>

The move is invalid, the field is already occupied.


<pre><code><b>const</b> <a href="./go.md#go_game_go_EInvalidMove">EInvalidMove</a>: u64 = 1;
</code></pre>



<a name="go_game_go_ESuicideMove"></a>

The move is a suicide move.


<pre><code><b>const</b> <a href="./go.md#go_game_go_ESuicideMove">ESuicideMove</a>: u64 = 2;
</code></pre>



<a name="go_game_go_EKoRuleBroken"></a>

The move repeats previous state of the board.


<pre><code><b>const</b> <a href="./go.md#go_game_go_EKoRuleBroken">EKoRuleBroken</a>: u64 = 3;
</code></pre>



<a name="go_game_go_new"></a>

## Function `new`

Create a new <code><a href="./go.md#go_game_go_Board">Board</a></code> of the given <code><a href="./go.md#go_game_go_size">size</a></code>. Size can be <code>9</code>, <code>13</code>, or <code>19</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_new">new</a>(<a href="./go.md#go_game_go_size">size</a>: u16): <a href="./go.md#go_game_go_Board">go_game::go::Board</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_new">new</a>(<a href="./go.md#go_game_go_size">size</a>: u16): <a href="./go.md#go_game_go_Board">Board</a> {
    <a href="./go.md#go_game_go_Board">Board</a> {
        <a href="./go.md#go_game_go_size">size</a>,
        <a href="./go.md#go_game_go_grid">grid</a>: grid::tabulate!(<a href="./go.md#go_game_go_size">size</a>, <a href="./go.md#go_game_go_size">size</a>, |_, _| Tile::Empty),
        <a href="./go.md#go_game_go_is_black">is_black</a>: <b>true</b>,
        moves: vector[],
        score: <a href="./go.md#go_game_go_Score">Score</a> { black: 0, white: 0 },
        prev_states: vector[],
    }
}
</code></pre>



</details>

<a name="go_game_go_place"></a>

## Function `place`

Place a stone on the board at the given position.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_place">place</a>(board: &<b>mut</b> <a href="./go.md#go_game_go_Board">go_game::go::Board</a>, x: u16, y: u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_place">place</a>(board: &<b>mut</b> <a href="./go.md#go_game_go_Board">Board</a>, x: u16, y: u16) {
    <b>let</b> stone = <b>if</b> (board.<a href="./go.md#go_game_go_is_black">is_black</a>) Tile::Black <b>else</b> Tile::White;
    <b>assert</b>!(board.<a href="./go.md#go_game_go_grid">grid</a>.swap(x, y, stone) == Tile::Empty, <a href="./go.md#go_game_go_EInvalidMove">EInvalidMove</a>);
    // Check <b>for</b> suicide <b>move</b>: count neighbors of the point, <b>if</b> all of them are
    // opponent's stones, the <b>move</b> is suicide. However, <b>if</b> the surrounding group
    // is surrounded, the <b>move</b> is a capture.
    <b>let</b> (<b>mut</b> my_stones, <b>mut</b> enemy_stones) = (vector[], vector[]);
    <b>let</b> <b>mut</b> empty_num = 0;
    // Get all neighbors of the point. Split them into my stones and enemy stones.
    // All my stones which are neighbors, actually form a group. The only tricky
    // part is checking the enemy stones and their groups.
    point::new(x, y).von_neumann(1).destroy!(|p| {
        <b>let</b> (x, y) = p.into_values();
        <b>if</b> (x &gt;= board.<a href="./go.md#go_game_go_size">size</a> || y &gt;= board.<a href="./go.md#go_game_go_size">size</a>) <b>return</b>;
        match (board.<a href="./go.md#go_game_go_grid">grid</a>[x, y]) {
            Tile::Empty =&gt; (empty_num = empty_num + 1),
            t @ _ =&gt; <b>if</b> (t == stone) {
                my_stones.push_back(p);
            } <b>else</b> {
                enemy_stones.push_back(p);
            },
        }
    });
    // Now we need to get unique groups of enemy stones. It is possible that the
    // surrounding stones are connected to each other.
    <b>let</b> <b>mut</b> enemy_groups = vector[];
    enemy_stones.destroy!(|p| {
        enemy_groups
            // Check <b>if</b> the point is already in a group.
            .find_index!(|<a href="./go.md#go_game_go_Group">Group</a>(_, points)| points.contains(&p))
            .destroy_or!({ enemy_groups.push_back(board.<a href="./go.md#go_game_go_find_group">find_group</a>(p.x(), p.y())); 0 });
    });
    // Now we need to check <b>if</b> any of the enemy groups are surrounded.
    <b>let</b> surrounded_groups = enemy_groups.filter!(|g| board.<a href="./go.md#go_game_go_is_group_surrounded">is_group_surrounded</a>(g));
    // If any of the enemy groups are surrounded, we capture them.
    <b>if</b> (surrounded_groups.length() &gt; 0) {
        surrounded_groups.destroy!(|<a href="./go.md#go_game_go_Group">Group</a>(_, points)| {
            // Increase score by the number of stones in the group.
            <b>if</b> (board.<a href="./go.md#go_game_go_is_black">is_black</a>) board.score.black = points.length() <b>as</b> u16 + board.score.black
            <b>else</b> board.score.white = points.length() <b>as</b> u16 + board.score.white;
            // Remove the group from the board.
            points.destroy!(|p| board.<a href="./go.md#go_game_go_grid">grid</a>.swap(p.x(), p.y(), Tile::Empty));
        });
    } <b>else</b> <b>if</b> (empty_num == 0) {
        // If there are no empty neighbors, we need to check <b>if</b> the <b>move</b> is a
        // suicide by checking <b>if</b> the <a href="./go.md#go_game_go_new">new</a> group is surrounded.
        <b>assert</b>!(!board.<a href="./go.md#go_game_go_is_group_surrounded">is_group_surrounded</a>(&board.<a href="./go.md#go_game_go_find_group">find_group</a>(x, y)), <a href="./go.md#go_game_go_ESuicideMove">ESuicideMove</a>);
    };
    board
        .prev_states
        .find_index!(|history| history == &board.<a href="./go.md#go_game_go_grid">grid</a>)
        .is_some_and!(|_| <b>abort</b> <a href="./go.md#go_game_go_EKoRuleBroken">EKoRuleBroken</a>);
    <b>if</b> (board.prev_states.length() == 2) {
        board.prev_states.swap_remove(0);
    };
    // Add the <b>move</b> and the current state to the history.
    board.prev_states.push_back(<b>copy</b> board.<a href="./go.md#go_game_go_grid">grid</a>);
    board.moves.push_back(point::new(x, y));
    board.<a href="./go.md#go_game_go_is_black">is_black</a> = !board.<a href="./go.md#go_game_go_is_black">is_black</a>;
}
</code></pre>



</details>

<a name="go_game_go_find_group"></a>

## Function `find_group`

Find a group of stones on the board. Returns an empty group if the Tile is
empty, alternatively goes through Von Neumann neighbors and adds them to the
group if they are of the same color.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_find_group">find_group</a>(board: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>, x: u16, y: u16): <a href="./go.md#go_game_go_Group">go_game::go::Group</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_find_group">find_group</a>(board: &<a href="./go.md#go_game_go_Board">Board</a>, x: u16, y: u16): <a href="./go.md#go_game_go_Group">Group</a> {
    // Store the stone color or <b>return</b> an empty group <b>if</b> the field is empty.
    <b>let</b> stone = match (board.<a href="./go.md#go_game_go_grid">grid</a>[x, y]) {
        Tile::Empty =&gt; <b>return</b> <a href="./go.md#go_game_go_Group">Group</a>(Tile::Empty, vector[]),
        _ =&gt; board.<a href="./go.md#go_game_go_grid">grid</a>[x, y],
    };
    // Find the group of stones of the same color.
    <b>let</b> <b>mut</b> group = board
        .<a href="./go.md#go_game_go_grid">grid</a> // Go Game relies on the Von Neumann neighborhood.
        .<a href="./go.md#go_game_go_find_group">find_group</a>!(point::new(x, y), |p| p.von_neumann(1), |tile| tile == &stone);
    // Sort the group to make them comparable.
    group.insertion_sort_by!(|a, b| a.le(b));
    <a href="./go.md#go_game_go_Group">Group</a>(stone, group)
}
</code></pre>



</details>

<a name="go_game_go_is_group_surrounded"></a>

## Function `is_group_surrounded`

Checks if the group is surrounded.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_group_surrounded">is_group_surrounded</a>(board: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>, group: &<a href="./go.md#go_game_go_Group">go_game::go::Group</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_group_surrounded">is_group_surrounded</a>(board: &<a href="./go.md#go_game_go_Board">Board</a>, group: &<a href="./go.md#go_game_go_Group">Group</a>): bool {
    'search: {
        <b>let</b> <a href="./go.md#go_game_go_Group">Group</a>(_, points) = group;
        points.do_ref!(|p| {
            // To make a call whether a group is surrounded, we need to check
            // <b>for</b> a single empty field neighboring the group. If there isn't
            // one, the group is surrounded. That is, assuming that the group
            // is homogeneous and exhaustive.
            <b>let</b> count = board.<a href="./go.md#go_game_go_grid">grid</a>.von_neumann_count!(*p, 1, |t| t == &Tile::Empty);
            <b>if</b> (count &gt; 0) <b>return</b> 'search <b>false</b>;
        });
        <b>true</b>
    }
}
</code></pre>



</details>

<a name="go_game_go_size"></a>

## Function `size`

Get the size of the board.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_size">size</a>(b: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_size">size</a>(b: &<a href="./go.md#go_game_go_Board">Board</a>): u16 { b.<a href="./go.md#go_game_go_size">size</a> }
</code></pre>



</details>

<a name="go_game_go_grid"></a>

## Function `grid`

Get a reference to the inner <code>Grid</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_grid">grid</a>(b: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>): &(<a href="./go.md#go_game_go_grid">grid</a>=0x0)::grid::Grid&lt;<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_grid">grid</a>(b: &<a href="./go.md#go_game_go_Board">Board</a>): &Grid&lt;<a href="./go.md#go_game_go_Tile">Tile</a>&gt; { &b.<a href="./go.md#go_game_go_grid">grid</a> }
</code></pre>



</details>

<a name="go_game_go_borrow"></a>

## Function `borrow`

Borrow a tile


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_borrow">borrow</a>(b: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>, x: u16, y: u16): &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_borrow">borrow</a>(b: &<a href="./go.md#go_game_go_Board">Board</a>, x: u16, y: u16): &<a href="./go.md#go_game_go_Tile">Tile</a> { &b.<a href="./go.md#go_game_go_grid">grid</a>[x, y] }
</code></pre>



</details>

<a name="go_game_go_is_black_turn"></a>

## Function `is_black_turn`

Return true if the current turn is black.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_black_turn">is_black_turn</a>(b: &<a href="./go.md#go_game_go_Board">go_game::go::Board</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_black_turn">is_black_turn</a>(b: &<a href="./go.md#go_game_go_Board">Board</a>): bool { b.<a href="./go.md#go_game_go_is_black">is_black</a> }
</code></pre>



</details>

<a name="go_game_go_is_empty"></a>

## Function `is_empty`

Return true if the tile is empty.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_empty">is_empty</a>(t: &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_empty">is_empty</a>(t: &<a href="./go.md#go_game_go_Tile">Tile</a>): bool { t == &Tile::Empty }
</code></pre>



</details>

<a name="go_game_go_is_black"></a>

## Function `is_black`

Return true if the tile is black.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_black">is_black</a>(t: &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_black">is_black</a>(t: &<a href="./go.md#go_game_go_Tile">Tile</a>): bool { t == &Tile::Black }
</code></pre>



</details>

<a name="go_game_go_is_white"></a>

## Function `is_white`

Return true if the tile is white.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_white">is_white</a>(t: &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_is_white">is_white</a>(t: &<a href="./go.md#go_game_go_Tile">Tile</a>): bool { t == &Tile::White }
</code></pre>



</details>

<a name="go_game_go_tile_to_string"></a>

## Function `tile_to_string`

Convert a <code><a href="./go.md#go_game_go_Tile">Tile</a></code> to a <code>String</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_tile_to_string">tile_to_string</a>(t: &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_tile_to_string">tile_to_string</a>(t: &<a href="./go.md#go_game_go_Tile">Tile</a>): String {
    match (t) {
        Tile::Empty =&gt; b"_",
        Tile::Black =&gt; b"B",
        Tile::White =&gt; b"W",
    }.to_string()
}
</code></pre>



</details>

<a name="go_game_go_tile_to_number"></a>

## Function `tile_to_number`

Convert tile to <code>u8</code> representation.


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_tile_to_number">tile_to_number</a>(t: &<a href="./go.md#go_game_go_Tile">go_game::go::Tile</a>): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./go.md#go_game_go_tile_to_number">tile_to_number</a>(t: &<a href="./go.md#go_game_go_Tile">Tile</a>): u8 {
    match (t) {
        Tile::Empty =&gt; 0,
        Tile::Black =&gt; 1,
        Tile::White =&gt; 2,
    }
}
</code></pre>



</details>
