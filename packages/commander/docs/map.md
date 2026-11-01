
<a name="commander_map"></a>

# Module `commander::map`

Defines the game <code><a href="./map.md#commander_map_Map">Map</a></code> - a grid of tiles where the game takes place. Map is
the most important component of the game, which provides direct access to
the stored data and objects and is used by game logic.

Traits:
- from_bcs
- to_string


-  [Struct `Tile`](#commander_map_Tile)
-  [Struct `Map`](#commander_map_Map)
-  [Enum `TileType`](#commander_map_TileType)
-  [Constants](#@Constants_0)
-  [Function `new`](#commander_map_new)
-  [Function `default`](#commander_map_default)
-  [Function `destroy`](#commander_map_destroy)
-  [Function `id`](#commander_map_id)
-  [Function `set_id`](#commander_map_set_id)
-  [Function `clone`](#commander_map_clone)
-  [Function `place_recruit`](#commander_map_place_recruit)
-  [Function `next_turn`](#commander_map_next_turn)
-  [Function `perform_reload`](#commander_map_perform_reload)
-  [Function `move_unit`](#commander_map_move_unit)
-  [Function `perform_attack`](#commander_map_perform_attack)
-  [Function `cover_bonus`](#commander_map_cover_bonus)
-  [Macro function `tile_cover`](#commander_map_tile_cover)
-  [Function `perform_grenade`](#commander_map_perform_grenade)
-  [Function `explode`](#commander_map_explode)
-  [Function `turn`](#commander_map_turn)
-  [Function `size`](#commander_map_size)
-  [Function `unit`](#commander_map_unit)
-  [Function `tile_has_unit`](#commander_map_tile_has_unit)
-  [Function `is_tile_cover`](#commander_map_is_tile_cover)
-  [Function `is_tile_empty`](#commander_map_is_tile_empty)
-  [Function `is_tile_unwalkable`](#commander_map_is_tile_unwalkable)
-  [Function `is_tile_wall`](#commander_map_is_tile_wall)
-  [Function `is_tile_walkable`](#commander_map_is_tile_walkable)
-  [Macro function `is_wall`](#commander_map_is_wall)
-  [Macro function `is_walkable`](#commander_map_is_walkable)
-  [Macro function `side_cover`](#commander_map_side_cover)
-  [Macro function `is_edge_high_cover`](#commander_map_is_edge_high_cover)
-  [Function `tile_to_string`](#commander_map_tile_to_string)
-  [Function `check_path`](#commander_map_check_path)
-  [Function `line_of_sight`](#commander_map_line_of_sight)
-  [Function `line_of_throw`](#commander_map_line_of_throw)
-  [Function `trace_line`](#commander_map_trace_line)
-  [Function `step_blocks`](#commander_map_step_blocks)
-  [Function `demo_1`](#commander_map_demo_1)
-  [Function `demo_2`](#commander_map_demo_2)
-  [Function `from_bytes`](#commander_map_from_bytes)
-  [Function `from_bcs`](#commander_map_from_bcs)
-  [Function `to_string`](#commander_map_to_string)


<pre><code><b>use</b> <a href="./armor.md#commander_armor">commander::armor</a>;
<b>use</b> <a href="./history.md#commander_history">commander::history</a>;
<b>use</b> <a href="./param.md#commander_param">commander::param</a>;
<b>use</b> <a href="./rank.md#commander_rank">commander::rank</a>;
<b>use</b> <a href="./recruit.md#commander_recruit">commander::recruit</a>;
<b>use</b> <a href="./stats.md#commander_stats">commander::stats</a>;
<b>use</b> <a href="./unit.md#commander_unit">commander::unit</a>;
<b>use</b> <a href="./weapon.md#commander_weapon">commander::weapon</a>;
<b>use</b> <a href="./weapon_upgrade.md#commander_weapon_upgrade">commander::weapon_upgrade</a>;
<b>use</b> <a href="../../.doc-deps/format/format.md#format_format">format::format</a>;
<b>use</b> <a href="../../.doc-deps/grid/cell.md#grid_cell">grid::cell</a>;
<b>use</b> <a href="../../.doc-deps/grid/cursor.md#grid_cursor">grid::cursor</a>;
<b>use</b> <a href="../../.doc-deps/grid/grid.md#grid_grid">grid::grid</a>;
<b>use</b> <a href="../../.doc-deps/std/address.md#std_address">std::address</a>;
<b>use</b> <a href="../../.doc-deps/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../../.doc-deps/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../../.doc-deps/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../../.doc-deps/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../../.doc-deps/std/type_name.md#std_type_name">std::type_name</a>;
<b>use</b> <a href="../../.doc-deps/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../../.doc-deps/std/u32.md#std_u32">std::u32</a>;
<b>use</b> <a href="../../.doc-deps/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../../.doc-deps/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator.md#sui_accumulator">sui::accumulator</a>;
<b>use</b> <a href="../../.doc-deps/sui/accumulator_settlement.md#sui_accumulator_settlement">sui::accumulator_settlement</a>;
<b>use</b> <a href="../../.doc-deps/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../../.doc-deps/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../../.doc-deps/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../../.doc-deps/sui/hash.md#sui_hash">sui::hash</a>;
<b>use</b> <a href="../../.doc-deps/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../../.doc-deps/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../../.doc-deps/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../../.doc-deps/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../../.doc-deps/sui/random.md#sui_random">sui::random</a>;
<b>use</b> <a href="../../.doc-deps/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../../.doc-deps/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../../.doc-deps/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../../.doc-deps/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="commander_map_Tile"></a>

## Struct `Tile`

Defines a single Tile in the game <code><a href="./map.md#commander_map_Map">Map</a></code>. Tiles can be empty, provide cover
or be unwalkable. Additionally, a unit standing on a tile effectively makes
it unwalkable.


<pre><code><b>public</b> <b>struct</b> <a href="./map.md#commander_map_Tile">Tile</a> <b>has</b> <b>copy</b>, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tile_type: <a href="./map.md#commander_map_TileType">commander::map::TileType</a></code>
</dt>
<dd>
 The type of the tile.
</dd>
<dt>
<code><a href="./unit.md#commander_unit">unit</a>: <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>&gt;</code>
</dt>
<dd>
 The position of the tile on the map.
</dd>
</dl>


</details>

<a name="commander_map_Map"></a>

## Struct `Map`

Defines the game Map - a grid of tiles where the game takes place.


<pre><code><b>public</b> <b>struct</b> <a href="./map.md#commander_map_Map">Map</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
 The unique identifier of the map.
</dd>
<dt>
<code>grid: <a href="../../.doc-deps/grid/grid.md#grid_grid_Grid">grid::grid::Grid</a>&lt;<a href="./map.md#commander_map_Tile">commander::map::Tile</a>&gt;</code>
</dt>
<dd>
 The grid of tiles.
</dd>
<dt>
<code><a href="./map.md#commander_map_turn">turn</a>: u16</code>
</dt>
<dd>
 The current turn number.
</dd>
</dl>


</details>

<a name="commander_map_TileType"></a>

## Enum `TileType`

A type of the <code><a href="./map.md#commander_map_Tile">Tile</a></code>.


<pre><code><b>public</b> <b>enum</b> <a href="./map.md#commander_map_TileType">TileType</a> <b>has</b> <b>copy</b>, drop, store
</code></pre>



<details>
<summary>Variants</summary>


<dl>
<dt>
Variant <code>Empty</code>
</dt>
<dd>
 An empty tile without any cover.
</dd>
<dt>
Variant <code>Cover</code>
</dt>
<dd>
 A low cover tile. Provides partial cover from 1-3 sides. Can be
 destroyed by explosives and heavy weapons.
 Cover also limits the movement of units, as they cannot move through
 cover sides.
</dd>

<dl>
<dt>
<code>left: u8</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>top: u8</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>right: u8</code>
</dt>
<dd>
</dd>
</dl>


<dl>
<dt>
<code>bottom: u8</code>
</dt>
<dd>
</dd>
</dl>

<dt>
Variant <code>Unwalkable</code>
</dt>
<dd>
 An empty tile that cannot be walked on, like water or a pit. Does not
 block line of sight and can be targeted by area weapons.
</dd>
<dt>
Variant <code>Wall</code>
</dt>
<dd>
 A solid tile: cannot be walked on, cannot be targeted and blocks line
 of sight. A dead zone for both movement and aiming.
</dd>
</dl>


</details>

<a name="@Constants_0"></a>

## Constants


<a name="commander_map_EUnitAlreadyOnTile"></a>

Attempt to place a <code>Recruit</code> on a tile that already has a unit.


<pre><code><b>const</b> <a href="./map.md#commander_map_EUnitAlreadyOnTile">EUnitAlreadyOnTile</a>: u64 = 1;
</code></pre>



<a name="commander_map_ETileIsUnwalkable"></a>

Attempt to place a <code>Recruit</code> on an unwalkable tile.


<pre><code><b>const</b> <a href="./map.md#commander_map_ETileIsUnwalkable">ETileIsUnwalkable</a>: u64 = 2;
</code></pre>



<a name="commander_map_EPathUnwalkable"></a>

The path is unwalkable.


<pre><code><b>const</b> <a href="./map.md#commander_map_EPathUnwalkable">EPathUnwalkable</a>: u64 = 3;
</code></pre>



<a name="commander_map_ENoUnit"></a>

The unit is not on the tile.


<pre><code><b>const</b> <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>: u64 = 5;
</code></pre>



<a name="commander_map_EPathTooShort"></a>

The path is too short.


<pre><code><b>const</b> <a href="./map.md#commander_map_EPathTooShort">EPathTooShort</a>: u64 = 6;
</code></pre>



<a name="commander_map_ETileOutOfBounds"></a>

The tile is out of bounds.


<pre><code><b>const</b> <a href="./map.md#commander_map_ETileOutOfBounds">ETileOutOfBounds</a>: u64 = 7;
</code></pre>



<a name="commander_map_ETileIsWall"></a>

Attempt to stand on or target a <code>Wall</code> tile.


<pre><code><b>const</b> <a href="./map.md#commander_map_ETileIsWall">ETileIsWall</a>: u64 = 8;
</code></pre>



<a name="commander_map_ENoLineOfSight"></a>

No line of sight (or throw) from the attacker to the target.


<pre><code><b>const</b> <a href="./map.md#commander_map_ENoLineOfSight">ENoLineOfSight</a>: u64 = 9;
</code></pre>



<a name="commander_map_NO_COVER"></a>

Constant for no cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="./map.md#commander_map_NO_COVER">NO_COVER</a>: u8 = 0;
</code></pre>



<a name="commander_map_LOW_COVER"></a>

Constant for low cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="./map.md#commander_map_LOW_COVER">LOW_COVER</a>: u8 = 1;
</code></pre>



<a name="commander_map_HIGH_COVER"></a>

Constant for high cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>: u8 = 2;
</code></pre>



<a name="commander_map_DEFENSE_BONUS"></a>

Constant for the defense bonus.


<pre><code><b>const</b> <a href="./map.md#commander_map_DEFENSE_BONUS">DEFENSE_BONUS</a>: u8 = 25;
</code></pre>



<a name="commander_map_GRENADE_RANGE"></a>

The range of the grenade.


<pre><code><b>const</b> <a href="./map.md#commander_map_GRENADE_RANGE">GRENADE_RANGE</a>: u16 = 5;
</code></pre>



<a name="commander_map_GRENADE_RADIUS"></a>

The radius of the grenade explosion (von Neumann neighborhood).


<pre><code><b>const</b> <a href="./map.md#commander_map_GRENADE_RADIUS">GRENADE_RADIUS</a>: u16 = 2;
</code></pre>



<a name="commander_map_GRENADE_DAMAGE"></a>

The damage the grenade deals to every unit in the area.


<pre><code><b>const</b> <a href="./map.md#commander_map_GRENADE_DAMAGE">GRENADE_DAMAGE</a>: u8 = 4;
</code></pre>



<a name="commander_map_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_new">new</a>(<a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>, <a href="./map.md#commander_map_size">size</a>: u16): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_new">new</a>(<a href="./map.md#commander_map_id">id</a>: ID, <a href="./map.md#commander_map_size">size</a>: u16): <a href="./map.md#commander_map_Map">Map</a> {
    <a href="./map.md#commander_map_Map">Map</a> {
        <a href="./map.md#commander_map_id">id</a>,
        <a href="./map.md#commander_map_turn">turn</a>: 0,
        grid: grid::tabulate!(
            <a href="./map.md#commander_map_size">size</a>,
            <a href="./map.md#commander_map_size">size</a>,
            |_, _| <a href="./map.md#commander_map_Tile">Tile</a> {
                tile_type: TileType::Empty,
                <a href="./unit.md#commander_unit">unit</a>: option::none(),
            },
        ),
    }
}
</code></pre>



</details>

<a name="commander_map_default"></a>

## Function `default`

Default Map is 30x30 tiles for now. Initially empty.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_default">default</a>(<a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_default">default</a>(<a href="./map.md#commander_map_id">id</a>: ID): <a href="./map.md#commander_map_Map">Map</a> { <a href="./map.md#commander_map_new">new</a>(<a href="./map.md#commander_map_id">id</a>, 30) }
</code></pre>



</details>

<a name="commander_map_destroy"></a>

## Function `destroy`

Destroy the <code><a href="./map.md#commander_map_Map">Map</a></code> struct, returning the IDs of the units on the map.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_destroy">destroy</a>(<a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_Map">commander::map::Map</a>): vector&lt;<a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_destroy">destroy</a>(<a href="./map.md#commander_map">map</a>: <a href="./map.md#commander_map_Map">Map</a>): vector&lt;ID&gt; {
    <b>let</b> <a href="./map.md#commander_map_Map">Map</a> { grid, .. } = <a href="./map.md#commander_map">map</a>;
    <b>let</b> <b>mut</b> units = vector[];
    grid.<a href="./map.md#commander_map_destroy">destroy</a>!(|<a href="./map.md#commander_map_Tile">Tile</a> { <a href="./unit.md#commander_unit">unit</a>, .. }| <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_destroy">destroy</a>!(|<a href="./unit.md#commander_unit">unit</a>| units.push_back(<a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_destroy">destroy</a>())));
    units
}
</code></pre>



</details>

<a name="commander_map_id"></a>

## Function `id`

Get the ID of the map.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_id">id</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>): <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_id">id</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>): ID { <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_id">id</a> }
</code></pre>



</details>

<a name="commander_map_set_id"></a>

## Function `set_id`

Set the ID of the map.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_set_id">set_id</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, <a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_set_id">set_id</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>, <a href="./map.md#commander_map_id">id</a>: ID) { <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_id">id</a> = <a href="./map.md#commander_map_id">id</a>; }
</code></pre>



</details>

<a name="commander_map_clone"></a>

## Function `clone`

Clone the <code><a href="./map.md#commander_map_Map">Map</a></code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_clone">clone</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_clone">clone</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>): <a href="./map.md#commander_map_Map">Map</a> { <a href="./map.md#commander_map_Map">Map</a> { <a href="./map.md#commander_map_id">id</a>: <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_id">id</a>, <a href="./map.md#commander_map_turn">turn</a>: <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>, grid: <a href="./map.md#commander_map">map</a>.grid } }
</code></pre>



</details>

<a name="commander_map_place_recruit"></a>

## Function `place_recruit`

Place a <code>Recruit</code> on the map at the given position.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_place_recruit">place_recruit</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, <a href="./recruit.md#commander_recruit">recruit</a>: &<a href="./recruit.md#commander_recruit_Recruit">commander::recruit::Recruit</a>, x: u16, y: u16): <a href="./history.md#commander_history_Record">commander::history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_place_recruit">place_recruit</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>, <a href="./recruit.md#commander_recruit">recruit</a>: &Recruit, x: u16, y: u16): Record {
    <b>let</b> target_tile = &<a href="./map.md#commander_map">map</a>.grid[x, y];
    <b>assert</b>!(target_tile.<a href="./unit.md#commander_unit">unit</a>.is_none(), <a href="./map.md#commander_map_EUnitAlreadyOnTile">EUnitAlreadyOnTile</a>);
    <b>assert</b>!(target_tile.tile_type != TileType::Unwalkable, <a href="./map.md#commander_map_ETileIsUnwalkable">ETileIsUnwalkable</a>);
    <b>assert</b>!(target_tile.tile_type != TileType::Wall, <a href="./map.md#commander_map_ETileIsWall">ETileIsWall</a>);
    <a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>.fill(<a href="./recruit.md#commander_recruit">recruit</a>.to_unit());
    <a href="./history.md#commander_history_new_recruit_placed">history::new_recruit_placed</a>(x, y)
}
</code></pre>



</details>

<a name="commander_map_next_turn"></a>

## Function `next_turn`

Proceed to the next turn.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_next_turn">next_turn</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>): <a href="./history.md#commander_history_Record">commander::history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_next_turn">next_turn</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>): Record {
    <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a> = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a> + 1;
    <a href="./history.md#commander_history_new_next_turn">history::new_next_turn</a>(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>)
}
</code></pre>



</details>

<a name="commander_map_perform_reload"></a>

## Function `perform_reload`

Reload the unit's weapon. It costs 1 AP.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_reload">perform_reload</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): <a href="./history.md#commander_history_Record">commander::history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_reload">perform_reload</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): Record {
    <b>assert</b>!(<a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = <a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>.borrow_mut();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_perform_reload">perform_reload</a>();
    <a href="./history.md#commander_history_new_reload">history::new_reload</a>(x, y)
}
</code></pre>



</details>

<a name="commander_map_move_unit"></a>

## Function `move_unit`

Move a unit along the path. The first cell is the current position of the unit.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_move_unit">move_unit</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, path: vector&lt;u8&gt;): <a href="./history.md#commander_history_Record">commander::history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_move_unit">move_unit</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>, path: vector&lt;u8&gt;): Record {
    <b>assert</b>!(path.length() &gt; 2, <a href="./map.md#commander_map_EPathTooShort">EPathTooShort</a>);
    <b>let</b> distance = path.length() - 2;
    <b>let</b> (x0, y0) = (path[0] <b>as</b> u16, path[1] <b>as</b> u16);
    <b>let</b> (rows, cols) = (<a href="./map.md#commander_map">map</a>.grid.rows(), <a href="./map.md#commander_map">map</a>.grid.cols());
    <b>assert</b>!(x0 &lt; rows && y0 &lt; cols, <a href="./map.md#commander_map_ETileOutOfBounds">ETileOutOfBounds</a>);
    <b>let</b> search = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_check_path">check_path</a>(path).destroy_or!(<b>abort</b> <a href="./map.md#commander_map_EPathUnwalkable">EPathUnwalkable</a>);
    <b>let</b> (x1, y1) = (search[0], search[1]);
    <b>assert</b>!(x1 &lt; rows && y1 &lt; cols, <a href="./map.md#commander_map_ETileOutOfBounds">ETileOutOfBounds</a>);
    <b>let</b> <b>mut</b> <a href="./unit.md#commander_unit">unit</a> = <a href="./map.md#commander_map">map</a>.grid[x0, y0].<a href="./unit.md#commander_unit">unit</a>.extract();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <a href="./unit.md#commander_unit">unit</a>.perform_move(distance <b>as</b> u8);
    <a href="./map.md#commander_map">map</a>.grid[x1, y1].<a href="./unit.md#commander_unit">unit</a>.fill(<a href="./unit.md#commander_unit">unit</a>);
    <a href="./history.md#commander_history_new_move">history::new_move</a>(path)
}
</code></pre>



</details>

<a name="commander_map_perform_attack"></a>

## Function `perform_attack`

Perform a ranged attack from <code>(x0, y0)</code> at <code>(x1, y1)</code>.

The hit chance is the attacker's aim adjusted for range, minus the target's
defense. With a single-target weapon (<code>area_size</code> of 0) the target tile must
hold a unit, and the defense is the directional cover bonus plus the
target's natural <code>defense</code> stat. With an area weapon (<code>area_size</code> above 0)
the target is any tile but a <code>Wall</code>, defense does not apply, and a hit
explodes with the radius <code>area_size</code> (see <code><a href="./map.md#commander_map_explode">explode</a></code>). The weapon's
<code>can_be_dodged</code> stat decides whether the damage can be dodged. Either way
the attacker needs a line of sight to the target (see <code><a href="./map.md#commander_map_line_of_sight">line_of_sight</a></code>).

Records: <code>Attack</code>, then <code>Miss</code>; or for a single target <code>[Dodged]</code>,
<code>Damage</code> / <code>CriticalHit</code>, <code>[UnitKIA]</code>; or for an area weapon the records
of <code><a href="./map.md#commander_map_explode">explode</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_attack">perform_attack</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, rng: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, x0: u16, y0: u16, x1: u16, y1: u16): vector&lt;<a href="./history.md#commander_history_Record">commander::history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_attack">perform_attack</a>(
    <a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>,
    rng: &<b>mut</b> RandomGenerator,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
): vector&lt;Record&gt; {
    <b>let</b> <b>mut</b> <a href="./history.md#commander_history">history</a> = vector[<a href="./history.md#commander_history_new_attack">history::new_attack</a>(vector[x0, y0], vector[x1, y1])];
    <b>let</b> range = grid::manhattan_distance!(x0, y0, x1, y1) <b>as</b> u8;
    <b>let</b> attacker = &<a href="./map.md#commander_map">map</a>.grid[x0, y0].<a href="./unit.md#commander_unit">unit</a>;
    <b>assert</b>!(attacker.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <a href="./stats.md#commander_stats">stats</a> = attacker.borrow().<a href="./stats.md#commander_stats">stats</a>();
    <b>let</b> radius = <a href="./stats.md#commander_stats">stats</a>.area_size() <b>as</b> u16;
    <b>let</b> can_dodge = <a href="./stats.md#commander_stats">stats</a>.can_be_dodged() != 0;
    <b>let</b> env_damage = <a href="./stats.md#commander_stats">stats</a>.env_damage() != 0;
    // single target: the tile must hold a <a href="./unit.md#commander_unit">unit</a>, whose cover and natural defense
    // lower the hit chance; an area <a href="./weapon.md#commander_weapon">weapon</a> targets a tile and ignores both
    <b>let</b> target_defense = <b>if</b> (radius == 0) {
        <b>let</b> target = &<a href="./map.md#commander_map">map</a>.grid[x1, y1].<a href="./unit.md#commander_unit">unit</a>;
        <b>assert</b>!(target.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
        <b>let</b> cover = <b>if</b> (range &gt; 0) <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_cover_bonus">cover_bonus</a>(x0, y0, x1, y1) <b>else</b> 0;
        <b>let</b> natural = target.borrow().<a href="./stats.md#commander_stats">stats</a>().defense();
        ((cover <b>as</b> u16) + (natural <b>as</b> u16)).min(100) <b>as</b> u8
    } <b>else</b> {
        <b>assert</b>!(!<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_is_tile_wall">is_tile_wall</a>(x1, y1), <a href="./map.md#commander_map_ETileIsWall">ETileIsWall</a>);
        0
    };
    <b>assert</b>!(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_line_of_sight">line_of_sight</a>(x0, y0, x1, y1), <a href="./map.md#commander_map_ENoLineOfSight">ENoLineOfSight</a>);
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = <a href="./map.md#commander_map">map</a>.grid[x0, y0].<a href="./unit.md#commander_unit">unit</a>.borrow_mut();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <b>let</b> (is_hit, _, is_crit, damage, _) = <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_perform_attack">perform_attack</a>(rng, range, target_defense);
    <b>if</b> (!is_hit) {
        <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_miss">history::new_miss</a>());
        <b>return</b> <a href="./history.md#commander_history">history</a>
    };
    <b>if</b> (radius &gt; 0) {
        <a href="./history.md#commander_history">history</a>.append(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_explode">explode</a>(rng, x1, y1, radius, damage, env_damage, can_dodge));
        <b>return</b> <a href="./history.md#commander_history">history</a>
    };
    <b>let</b> <b>mut</b> target = <a href="./map.md#commander_map">map</a>.grid[x1, y1].<a href="./unit.md#commander_unit">unit</a>.extract();
    <b>let</b> (is_dodged, damage, is_kia) = <b>if</b> (damage &gt; 0) {
        target.apply_damage(rng, damage, can_dodge)
    } <b>else</b> (<b>false</b>, 0, <b>false</b>);
    <b>if</b> (is_dodged) <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_dodged">history::new_dodged</a>());
    <a href="./history.md#commander_history">history</a>.push_back({
        <b>if</b> (is_crit) <a href="./history.md#commander_history_new_critical_hit">history::new_critical_hit</a>(damage) // same cost
        <b>else</b> <a href="./history.md#commander_history_new_damage">history::new_damage</a>(damage)
    });
    <b>if</b> (is_kia) <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_kia">history::new_kia</a>(target.<a href="./map.md#commander_map_destroy">destroy</a>()))
    <b>else</b> <a href="./map.md#commander_map">map</a>.grid[x1, y1].<a href="./unit.md#commander_unit">unit</a>.fill(target);
    <a href="./history.md#commander_history">history</a>
}
</code></pre>



</details>

<a name="commander_map_cover_bonus"></a>

## Function `cover_bonus`

Calculate the cover bonus for the given tile. The cover bonus is calculated
based on the direction of the attack and the type of cover on the tile.

- no cover - 0
- LOW_COVER - 25
- HIGH_COVER - 50

A <code>Wall</code> tile next to the target counts as high cover on that side.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_cover_bonus">cover_bonus</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_cover_bonus">cover_bonus</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): u8 {
    <b>use</b> <a href="../../.doc-deps/grid/direction.md#grid_direction">grid::direction</a>::{direction, none, up, down, left, right};
    <b>let</b> direction = direction!(x0, y0, x1, y1);
    <b>let</b> (up, down, left, right) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1);
    // edge case: same tile, should never happen
    <b>if</b> (direction == none!()) <b>return</b> 0;
    // target tile cover type (does not check neighboring tiles with reverse defense)
    <b>let</b> cover_type = <b>if</b> (direction == up!()) {
        <b>if</b> (down != 0) down // target tile <b>has</b> cover
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            top
        }
    } <b>else</b> <b>if</b> (direction == down!()) {
        <b>if</b> (up != 0) up
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            bottom
        }
    } <b>else</b> <b>if</b> (direction == left!()) {
        <b>if</b> (right != 0) right
        <b>else</b> {
            <b>let</b> (_, _, left, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            left
        }
    } <b>else</b> <b>if</b> (direction == right!()) {
        <b>if</b> (left != 0) left
        <b>else</b> {
            <b>let</b> (_, _, _, right) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            right
        }
    } <b>else</b> <b>if</b> (direction == up!() | left!()) {
        <b>let</b> cover_type = down.max(right);
        <b>if</b> (cover_type  != 0) cover_type
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            <b>let</b> (_, _, left, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            top.max(left)
        }
    } <b>else</b> <b>if</b> (direction == up!() | right!()) {
        <b>let</b> cover_type = down.max(left);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            <b>let</b> (_, _, _, right) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            top.max(right)
        }
    } <b>else</b> <b>if</b> (direction == down!() | left!()) {
        <b>let</b> cover_type = up.max(right);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            <b>let</b> (_, _, left, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            bottom.max(left)
        }
    } <b>else</b> <b>if</b> (direction == down!() | right!()) {
        <b>let</b> cover_type = up.max(left);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            <b>let</b> (_, _, _, right) = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            bottom.max(right)
        }
    } <b>else</b> <b>abort</b>; // unreachable
    // cover <b>enum</b> is 0, 1, 2, so by multiplying it by 25 we get the value we
    // need; same, <b>as</b> <b>if</b> we matched it to 0, 25, 50
    cover_type * <a href="./map.md#commander_map_DEFENSE_BONUS">DEFENSE_BONUS</a>
}
</code></pre>



</details>

<a name="commander_map_tile_cover"></a>

## Macro function `tile_cover`



<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_tile_cover">tile_cover</a>($<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, $x: u16, $y: u16): (u8, u8, u8, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_tile_cover">tile_cover</a>($<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, $x: u16, $y: u16): (u8, u8, u8, u8) {
    <b>let</b> <a href="./map.md#commander_map">map</a> = $<a href="./map.md#commander_map">map</a>;
    match (<a href="./map.md#commander_map">map</a>.grid[$x, $y].tile_type) {
        TileType::Cover { left, right, top, bottom } =&gt; (top, bottom, left, right),
        TileType::Wall =&gt; (<a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>, <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>, <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>, <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>),
        _ =&gt; (0, 0, 0, 0),
    }
}
</code></pre>



</details>

<a name="commander_map_perform_grenade"></a>

## Function `perform_grenade`

Throw a grenade from <code>(x, y)</code> at <code>(x1, y1)</code>. This action costs 1 AP, deals
<code><a href="./map.md#commander_map_GRENADE_DAMAGE">GRENADE_DAMAGE</a></code> to every unit in the von Neumann neighborhood of radius
<code><a href="./map.md#commander_map_GRENADE_RADIUS">GRENADE_RADIUS</a></code> around the target tile (a diamond), cannot be dodged, and
destroys covers in the area. The target tile must be reachable by a throw:
walls block it, covers do not (see <code><a href="./map.md#commander_map_line_of_throw">line_of_throw</a></code>).

Records: <code>Grenade</code>, then the records of <code><a href="./map.md#commander_map_explode">explode</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_grenade">perform_grenade</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, rng: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, x: u16, y: u16, x1: u16, y1: u16): vector&lt;<a href="./history.md#commander_history_Record">commander::history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_perform_grenade">perform_grenade</a>(
    <a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>,
    rng: &<b>mut</b> RandomGenerator,
    x: u16,
    y: u16,
    x1: u16,
    y1: u16,
): vector&lt;Record&gt; {
    <b>assert</b>!(grid::manhattan_distance!(x, y, x1, y1) &lt;= <a href="./map.md#commander_map_GRENADE_RANGE">GRENADE_RANGE</a>, <a href="./map.md#commander_map_EPathTooShort">EPathTooShort</a>);
    <b>assert</b>!(!<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_is_tile_wall">is_tile_wall</a>(x1, y1), <a href="./map.md#commander_map_ETileIsWall">ETileIsWall</a>);
    <b>assert</b>!(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_line_of_throw">line_of_throw</a>(x, y, x1, y1), <a href="./map.md#commander_map_ENoLineOfSight">ENoLineOfSight</a>);
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>;
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    // update <a href="./unit.md#commander_unit">unit</a>'s <a href="./stats.md#commander_stats">stats</a>
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = <a href="./unit.md#commander_unit">unit</a>.borrow_mut();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_perform_grenade">perform_grenade</a>();
    <b>let</b> <b>mut</b> <a href="./history.md#commander_history">history</a> = vector[<a href="./history.md#commander_history_new_grenade">history::new_grenade</a>(vector[x, y], vector[x1, y1])];
    <a href="./history.md#commander_history">history</a>.append(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_explode">explode</a>(rng, x1, y1, <a href="./map.md#commander_map_GRENADE_RADIUS">GRENADE_RADIUS</a>, <a href="./map.md#commander_map_GRENADE_DAMAGE">GRENADE_DAMAGE</a>, <b>true</b>, <b>false</b>));
    <a href="./history.md#commander_history">history</a>
}
</code></pre>



</details>

<a name="commander_map_explode"></a>

## Function `explode`

Apply area damage centered at <code>(x, y)</code>: every unit in the von Neumann
neighborhood of <code>radius</code> (center included) takes <code>damage</code>, reduced by its
armor and dodged only if <code>can_dodge</code>. With <code>env_damage</code>, covers in the area
are destroyed (<code>Cover</code> -> <code>Empty</code>). Shared by grenades and area weapons.

Records: <code>Explosion</code>, then <code>[Dodged]</code>, <code>Damage</code>, <code>[UnitKIA]</code> per unit in
the area. Tiles are visited in the order of <code>Grid.von_neumann_neighbors</code>
with the center tile last; a replay must walk them in the same order.


<pre><code><b>fun</b> <a href="./map.md#commander_map_explode">explode</a>(<a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">commander::map::Map</a>, rng: &<b>mut</b> <a href="../../.doc-deps/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, x: u16, y: u16, radius: u16, damage: u8, env_damage: bool, can_dodge: bool): vector&lt;<a href="./history.md#commander_history_Record">commander::history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./map.md#commander_map_explode">explode</a>(
    <a href="./map.md#commander_map">map</a>: &<b>mut</b> <a href="./map.md#commander_map_Map">Map</a>,
    rng: &<b>mut</b> RandomGenerator,
    x: u16,
    y: u16,
    radius: u16,
    damage: u8,
    env_damage: bool,
    can_dodge: bool,
): vector&lt;Record&gt; {
    <b>let</b> <b>mut</b> <a href="./history.md#commander_history">history</a> = vector[<a href="./history.md#commander_history_new_explosion">history::new_explosion</a>(x, y, radius)];
    <b>let</b> <b>mut</b> cells = <a href="./map.md#commander_map">map</a>.grid.von_neumann_neighbors(cell::new(x, y), radius);
    cells.push_back(cell::new(x, y));
    cells.do!(|p| {
        <b>let</b> (x, y) = p.to_values();
        <b>let</b> tile = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x, y];
        <b>if</b> (tile.<a href="./unit.md#commander_unit">unit</a>.is_some()) {
            <b>let</b> <b>mut</b> <a href="./unit.md#commander_unit">unit</a> = tile.<a href="./unit.md#commander_unit">unit</a>.extract();
            <b>let</b> (is_dodged, dmg, is_kia) = <a href="./unit.md#commander_unit">unit</a>.apply_damage(rng, damage, can_dodge);
            <b>if</b> (is_dodged) <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_dodged">history::new_dodged</a>());
            <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_damage">history::new_damage</a>(dmg));
            <b>if</b> (!is_kia) tile.<a href="./unit.md#commander_unit">unit</a>.fill(<a href="./unit.md#commander_unit">unit</a>)
            <b>else</b> <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_kia">history::new_kia</a>(<a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_destroy">destroy</a>()));
        };
        <b>if</b> (env_damage) {
            match (tile.tile_type) {
                TileType::Cover { .. } =&gt; tile.tile_type = TileType::Empty,
                _ =&gt; (),
            }
        };
    });
    <a href="./history.md#commander_history">history</a>
}
</code></pre>



</details>

<a name="commander_map_turn"></a>

## Function `turn`

Get the current turn number.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_turn">turn</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_turn">turn</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>): u16 { <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a> }
</code></pre>



</details>

<a name="commander_map_size"></a>

## Function `size`

Get the size of the map as <code>(rows, cols)</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_size">size</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>): (u16, u16)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_size">size</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>): (u16, u16) { (<a href="./map.md#commander_map">map</a>.grid.rows(), <a href="./map.md#commander_map">map</a>.grid.cols()) }
</code></pre>



</details>

<a name="commander_map_unit"></a>

## Function `unit`

Read the Unit at the given position.


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit">unit</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): &<a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;<a href="./unit.md#commander_unit_Unit">commander::unit::Unit</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./unit.md#commander_unit">unit</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): &Option&lt;Unit&gt; {
    &<a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>
}
</code></pre>



</details>

<a name="commander_map_tile_has_unit"></a>

## Function `tile_has_unit`

Check if the given tile has a unit on it.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_tile_has_unit">tile_has_unit</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_tile_has_unit">tile_has_unit</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool {
    <a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>.is_some()
}
</code></pre>



</details>

<a name="commander_map_is_tile_cover"></a>

## Function `is_tile_cover`

Check if the given tile is a cover.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_cover">is_tile_cover</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_cover">is_tile_cover</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="./map.md#commander_map">map</a>.grid[x, y].tile_type) {
        TileType::Cover { .. } =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="commander_map_is_tile_empty"></a>

## Function `is_tile_empty`

Check if the given tile is empty.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_empty">is_tile_empty</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_empty">is_tile_empty</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="./map.md#commander_map">map</a>.grid[x, y].tile_type) {
        TileType::Empty =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="commander_map_is_tile_unwalkable"></a>

## Function `is_tile_unwalkable`

Check if the given tile is unwalkable.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_unwalkable">is_tile_unwalkable</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_unwalkable">is_tile_unwalkable</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="./map.md#commander_map">map</a>.grid[x, y].tile_type) {
        TileType::Unwalkable =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="commander_map_is_tile_wall"></a>

## Function `is_tile_wall`

Check if the given tile is a wall.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_wall">is_tile_wall</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_wall">is_tile_wall</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool { <a href="./map.md#commander_map_is_wall">is_wall</a>!(&<a href="./map.md#commander_map">map</a>.grid[x, y]) }
</code></pre>



</details>

<a name="commander_map_is_tile_walkable"></a>

## Function `is_tile_walkable`

Check if the given tile can be walked on: neither <code>Unwalkable</code> nor <code>Wall</code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_walkable">is_tile_walkable</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_is_tile_walkable">is_tile_walkable</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x: u16, y: u16): bool { <a href="./map.md#commander_map_is_walkable">is_walkable</a>!(&<a href="./map.md#commander_map">map</a>.grid[x, y]) }
</code></pre>



</details>

<a name="commander_map_is_wall"></a>

## Macro function `is_wall`

Whether <code>$tile</code> is a <code>Wall</code>.


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_wall">is_wall</a>($tile: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_wall">is_wall</a>($tile: &<a href="./map.md#commander_map_Tile">Tile</a>): bool {
    <b>let</b> tile = $tile;
    match (tile.tile_type) {
        TileType::Wall =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="commander_map_is_walkable"></a>

## Macro function `is_walkable`

Whether <code>$tile</code> can be walked on: neither <code>Unwalkable</code> nor <code>Wall</code>.


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_walkable">is_walkable</a>($tile: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_walkable">is_walkable</a>($tile: &<a href="./map.md#commander_map_Tile">Tile</a>): bool {
    <b>let</b> tile = $tile;
    match (tile.tile_type) {
        TileType::Unwalkable | TileType::Wall =&gt; <b>false</b>,
        _ =&gt; <b>true</b>,
    }
}
</code></pre>



</details>

<a name="commander_map_side_cover"></a>

## Macro function `side_cover`

Cover value of the side of <code>$tile</code> facing <code>$direction</code>. A <code>Wall</code> has no
cover here: it is handled as a wall before cover is looked at.


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_side_cover">side_cover</a>($tile: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>, $direction: u8): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_side_cover">side_cover</a>($tile: &<a href="./map.md#commander_map_Tile">Tile</a>, $direction: u8): u8 {
    <b>use</b> <a href="../../.doc-deps/grid/direction.md#grid_direction">grid::direction</a>::{up, down, left};
    <b>let</b> (tile, direction) = ($tile, $direction);
    match (tile.tile_type) {
        TileType::Cover { left: l, top, right, bottom } =&gt; {
            <b>if</b> (direction == up!()) top
            <b>else</b> <b>if</b> (direction == down!()) bottom
            <b>else</b> <b>if</b> (direction == left!()) l
            <b>else</b> right
        },
        _ =&gt; <a href="./map.md#commander_map_NO_COVER">NO_COVER</a>,
    }
}
</code></pre>



</details>

<a name="commander_map_is_edge_high_cover"></a>

## Macro function `is_edge_high_cover`

Whether the edge between <code>$from</code> and its neighbor <code>$to</code> in <code>$direction</code>
has high cover on either side. Shared by <code><a href="./map.md#commander_map_check_path">check_path</a></code> and <code><a href="./map.md#commander_map_trace_line">trace_line</a></code>.


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_edge_high_cover">is_edge_high_cover</a>($from: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>, $to: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>, $direction: u8): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="./map.md#commander_map_is_edge_high_cover">is_edge_high_cover</a>($from: &<a href="./map.md#commander_map_Tile">Tile</a>, $to: &<a href="./map.md#commander_map_Tile">Tile</a>, $direction: u8): bool {
    <b>use</b> <a href="../../.doc-deps/grid/direction.md#grid_direction_inverse">grid::direction::inverse</a>;
    <b>let</b> (from, to, direction) = ($from, $to, $direction);
    <a href="./map.md#commander_map_side_cover">side_cover</a>!(from, direction) == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>
        || <a href="./map.md#commander_map_side_cover">side_cover</a>!(to, inverse!(direction)) == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>
}
</code></pre>



</details>

<a name="commander_map_tile_to_string"></a>

## Function `tile_to_string`

Print the <code><a href="./map.md#commander_map_Tile">Tile</a></code> as a <code>String</code>. Used in the <code>Grid.<a href="./map.md#commander_map_to_string">to_string</a>!()</code> macro.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_tile_to_string">tile_to_string</a>(tile: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_tile_to_string">tile_to_string</a>(tile: &<a href="./map.md#commander_map_Tile">Tile</a>): String {
    match (tile.tile_type) {
        TileType::Empty =&gt; b"     ".<a href="./map.md#commander_map_to_string">to_string</a>(),
        TileType::Cover { left, right, top, bottom } =&gt; {
            <b>let</b> <b>mut</b> str = b"".<a href="./map.md#commander_map_to_string">to_string</a>();
            str.append(left.<a href="./map.md#commander_map_to_string">to_string</a>());
            str.append(top.<a href="./map.md#commander_map_to_string">to_string</a>());
            str.append(right.<a href="./map.md#commander_map_to_string">to_string</a>());
            str.append(bottom.<a href="./map.md#commander_map_to_string">to_string</a>());
            str.append_utf8(<b>if</b> (tile.<a href="./unit.md#commander_unit">unit</a>.is_some()) b"U" <b>else</b> b"-");
            str
        },
        TileType::Unwalkable =&gt; b" XXX ".<a href="./map.md#commander_map_to_string">to_string</a>(),
        TileType::Wall =&gt; b" ### ".<a href="./map.md#commander_map_to_string">to_string</a>(),
    }
}
</code></pre>



</details>

<a name="commander_map_check_path"></a>

## Function `check_path`

Check if the given path is walkable. Can be an optimization for pathfinding,
if the path is traced on the frontend.

Returns <code>None</code> if the path is not walkable, otherwise returns the end cell
of the path.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_check_path">check_path</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, path: vector&lt;u8&gt;): <a href="../../.doc-deps/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;u16&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_check_path">check_path</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, <b>mut</b> path: vector&lt;u8&gt;): Option&lt;vector&lt;u16&gt;&gt; {
    path.reverse();
    // first two values are X and Y coordinates, the rest are directions
    <b>let</b> (x0, y0) = (path.pop_back() <b>as</b> u16, path.pop_back() <b>as</b> u16);
    <b>let</b> <b>mut</b> cursor = cursor::new(x0, y0);
    <b>let</b> none = option::none();
    // the tile the path starts on; every later source is the previous target
    <b>let</b> <b>mut</b> source = &<a href="./map.md#commander_map">map</a>.grid[x0, y0];
    <b>if</b> (!path.is_empty() && !<a href="./map.md#commander_map_is_walkable">is_walkable</a>!(source)) <b>return</b> none;
    'path: {
        path.<a href="./map.md#commander_map_destroy">destroy</a>!(|direction| {
            cursor.move_to(direction);
            <b>let</b> (x1, y1) = cursor.to_values();
            <b>let</b> target = &<a href="./map.md#commander_map">map</a>.grid[x1, y1];
            // units, walls, unwalkable tiles and high covers block the path
            <b>if</b> (target.<a href="./unit.md#commander_unit">unit</a>.is_some()) <b>return</b> 'path none;
            <b>if</b> (!<a href="./map.md#commander_map_is_walkable">is_walkable</a>!(target)) <b>return</b> 'path none;
            <b>if</b> (<a href="./map.md#commander_map_is_edge_high_cover">is_edge_high_cover</a>!(source, target, direction)) <b>return</b> 'path none;
            source = target;
        });
        option::some(cursor.to_vector())
    }
}
</code></pre>



</details>

<a name="commander_map_line_of_sight"></a>

## Function `line_of_sight`

Check the line of sight for a shot from <code>(x0, y0)</code> to <code>(x1, y1)</code>: walls and
high covers block it, unwalkable tiles and units do not. See <code><a href="./map.md#commander_map_trace_line">trace_line</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_line_of_sight">line_of_sight</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_line_of_sight">line_of_sight</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): bool {
    <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_trace_line">trace_line</a>(x0, y0, x1, y1, <b>true</b>)
}
</code></pre>



</details>

<a name="commander_map_line_of_throw"></a>

## Function `line_of_throw`

Check the line of throw for a grenade from <code>(x0, y0)</code> to <code>(x1, y1)</code>: only
walls block it, a grenade flies over covers. See <code><a href="./map.md#commander_map_trace_line">trace_line</a></code>.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_line_of_throw">line_of_throw</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_line_of_throw">line_of_throw</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): bool {
    <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_trace_line">trace_line</a>(x0, y0, x1, y1, <b>false</b>)
}
</code></pre>



</details>

<a name="commander_map_trace_line"></a>

## Function `trace_line`

Walk the segment between the centers of two tiles one edge at a time and
check that it is clear. Entering a <code>Wall</code> always blocks. With
<code>high_cover_blocks</code>, a high cover on either side of a crossed edge blocks
too, except on the edges touching the two end tiles: cover next to the
attacker or the target is cover, not a wall. <code>Unwalkable</code> tiles and units
never block. Where the segment passes exactly through a corner, it is
clear if either of the two orthogonal routes around the corner is clear.

The walk is the Amanatides-Woo grid traversal in unsigned integers: after
<code>i</code> row steps and <code>j</code> column steps the next row edge lies at
<code>(i + 0.5) / dx</code> of the segment and the next column edge at
<code>(j + 0.5) / dy</code>, compared as <code>(2i + 1) * dy</code> against <code>(2j + 1) * dx</code>.
It takes <code>dx + dy</code> steps with one tile read each: the tile being left was
read when it was entered. An edge is inner when it is neither the first
nor the last of the <code>dx + dy</code> edges crossed, counted as <code>i + j</code>. The same
edges are visited from either end, so the result is symmetric: <code>a</code> sees
<code>b</code> if and only if <code>b</code> sees <code>a</code>.


<pre><code><b>fun</b> <a href="./map.md#commander_map_trace_line">trace_line</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>, x0: u16, y0: u16, x1: u16, y1: u16, high_cover_blocks: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./map.md#commander_map_trace_line">trace_line</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>, x0: u16, y0: u16, x1: u16, y1: u16, high_cover_blocks: bool): bool {
    <b>use</b> <a href="../../.doc-deps/grid/direction.md#grid_direction">grid::direction</a>::{up, down, left, right};
    <b>let</b> (dx, dy) = (x0.diff(x1) <b>as</b> u64, y0.diff(y1) <b>as</b> u64);
    <b>let</b> edges = dx + dy;
    <b>let</b> (downward, rightward) = (x1 &gt; x0, y1 &gt; y0);
    <b>let</b> sx = <b>if</b> (downward) down!() <b>else</b> up!();
    <b>let</b> sy = <b>if</b> (rightward) right!() <b>else</b> left!();
    <b>let</b> (<b>mut</b> x, <b>mut</b> y) = (x0, y0);
    <b>let</b> <b>mut</b> cur = &<a href="./map.md#commander_map">map</a>.grid[x0, y0];
    <b>let</b> (<b>mut</b> i, <b>mut</b> j) = (0u64, 0u64);
    <b>while</b> (i + j &lt; edges) {
        <b>let</b> k = i + j; // edges crossed so far
        <b>let</b> (t_row, t_col) = ((2 * i + 1) * dy, (2 * j + 1) * dx);
        <b>if</b> (t_row &lt; t_col) {
            <b>let</b> nx = <b>if</b> (downward) x + 1 <b>else</b> x - 1;
            <b>let</b> next = &<a href="./map.md#commander_map">map</a>.grid[nx, y];
            <b>if</b> (<a href="./map.md#commander_map_step_blocks">step_blocks</a>(cur, next, sx, k &gt; 0 && k + 1 &lt; edges, high_cover_blocks)) <b>return</b> <b>false</b>;
            cur = next;
            x = nx;
            i = i + 1;
        } <b>else</b> <b>if</b> (t_col &lt; t_row) {
            <b>let</b> ny = <b>if</b> (rightward) y + 1 <b>else</b> y - 1;
            <b>let</b> next = &<a href="./map.md#commander_map">map</a>.grid[x, ny];
            <b>if</b> (<a href="./map.md#commander_map_step_blocks">step_blocks</a>(cur, next, sy, k &gt; 0 && k + 1 &lt; edges, high_cover_blocks)) <b>return</b> <b>false</b>;
            cur = next;
            y = ny;
            j = j + 1;
        } <b>else</b> {
            // corner: two edges are crossed at once, and the line is clear <b>if</b>
            // either route around the vertex is clear; the tiles beside the
            // vertex are never the end tile, the one past it is when it ends
            // the walk
            <b>let</b> nx = <b>if</b> (downward) x + 1 <b>else</b> x - 1;
            <b>let</b> ny = <b>if</b> (rightward) y + 1 <b>else</b> y - 1;
            <b>let</b> (a, b, c) = (&<a href="./map.md#commander_map">map</a>.grid[nx, y], &<a href="./map.md#commander_map">map</a>.grid[x, ny], &<a href="./map.md#commander_map">map</a>.grid[nx, ny]);
            <b>let</b> (inner1, inner2) = (k &gt; 0, k + 2 &lt; edges);
            <b>let</b> via_row =
                !<a href="./map.md#commander_map_step_blocks">step_blocks</a>(cur, a, sx, inner1, high_cover_blocks)
                    && !<a href="./map.md#commander_map_step_blocks">step_blocks</a>(a, c, sy, inner2, high_cover_blocks);
            <b>let</b> via_col =
                !<a href="./map.md#commander_map_step_blocks">step_blocks</a>(cur, b, sy, inner1, high_cover_blocks)
                    && !<a href="./map.md#commander_map_step_blocks">step_blocks</a>(b, c, sx, inner2, high_cover_blocks);
            <b>if</b> (!via_row && !via_col) <b>return</b> <b>false</b>;
            cur = c;
            (x, y) = (nx, ny);
            i = i + 1;
            j = j + 1;
        }
    };
    <b>true</b>
}
</code></pre>



</details>

<a name="commander_map_step_blocks"></a>

## Function `step_blocks`

Whether stepping from <code>from</code> into its neighbor <code>to</code> in <code>direction</code> blocks
the line: <code>to</code> is a <code>Wall</code>, or, with <code>high_cover_blocks</code>, the edge is
<code>inner</code> (touches neither end tile) and has high cover on either side.

A function rather than a macro on purpose: <code><a href="./map.md#commander_map_trace_line">trace_line</a></code> calls it six times
and the inlined matches would exceed the 255 locals a function may have.


<pre><code><b>fun</b> <a href="./map.md#commander_map_step_blocks">step_blocks</a>(from: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>, to: &<a href="./map.md#commander_map_Tile">commander::map::Tile</a>, direction: u8, inner: bool, high_cover_blocks: bool): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>fun</b> <a href="./map.md#commander_map_step_blocks">step_blocks</a>(from: &<a href="./map.md#commander_map_Tile">Tile</a>, to: &<a href="./map.md#commander_map_Tile">Tile</a>, direction: u8, inner: bool, high_cover_blocks: bool): bool {
    <b>if</b> (<a href="./map.md#commander_map_is_wall">is_wall</a>!(to)) <b>true</b>
    <b>else</b> <b>if</b> (!high_cover_blocks || !inner) <b>false</b>
    <b>else</b> <a href="./map.md#commander_map_is_edge_high_cover">is_edge_high_cover</a>!(from, to, direction)
}
</code></pre>



</details>

<a name="commander_map_demo_1"></a>

## Function `demo_1`

Creates a demo map #1.

- Map: 01 - 7x7 LEGO prototype.
- Unit positions: (0, 3), (1, 6), (6, 5)
- Firing lane in the demo: (3, 1) <-> (0, 3)
- Goal: close encounter with low and high cover to test line of sight and cover mechanics.
- Schema:

```
|     |     |2002-|0001-|0002-|     |     |
| XXX |     |     |     |     |     |     |
|     |     |     |     |     |0001-|0001-|
|0100-|0120-|     | XXX |     |1000-|1000-|
|0001-|0102-|     |     |     |     |     |
|     |     |     |     |     |     |     |
|     | XXX |     |     |1100-|0100-|0110-|
```


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_demo_1">demo_1</a>(<a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_demo_1">demo_1</a>(<a href="./map.md#commander_map_id">id</a>: ID): <a href="./map.md#commander_map_Map">Map</a> {
    <b>let</b> <b>mut</b> preset_bytes = bcs::to_bytes(&<a href="./map.md#commander_map_id">id</a>);
    // prettier-ignore
    preset_bytes.append(x"070700000000010200000200010000000100010000000200000000000702000000000000000000000000000700000000000000000000010000000100010000000100070100010000000100010200000000020000000101000000000101000000000701000000010001000100020000000000000000000000070000000000000000000000000000070000020000000000010101000000010001000000010001010000000700070000");
    <a href="./map.md#commander_map_from_bytes">from_bytes</a>(preset_bytes)
}
</code></pre>



</details>

<a name="commander_map_demo_2"></a>

## Function `demo_2`

Creates a demo map #2.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_demo_2">demo_2</a>(<a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_demo_2">demo_2</a>(<a href="./map.md#commander_map_id">id</a>: ID): <a href="./map.md#commander_map_Map">Map</a> {
    // prettier-ignore
    <b>let</b> <b>mut</b> <a href="./map.md#commander_map">map</a> = <a href="./map.md#commander_map_from_bytes">from_bytes</a>(x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000101000001000100000001000100000101000000000001010000010001000000010001000001010000000a00000000000000000000000000000000000000000a00000200020002000000000002000200020000000a000001010000010000000100000101000000000000000200000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a010202000000010001000000010001000000010002020000000000000101020000000100010000000100010000000100020200000a01020000000000000000010000010000000000000000000000000100000200000a010200000200010000000200010000000200010000000200010000000200010000000200010000000200010000000200010000000200010000020200000a000a0000");
    <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_id">id</a> = <a href="./map.md#commander_map_id">id</a>;
    <a href="./map.md#commander_map">map</a>
}
</code></pre>



</details>

<a name="commander_map_from_bytes"></a>

## Function `from_bytes`

Deserializes the <code><a href="./map.md#commander_map_Map">Map</a></code> from the given bytes.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="./map.md#commander_map_Map">Map</a> {
    <a href="./map.md#commander_map_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="commander_map_from_bcs"></a>

## Function `from_bcs`

Deserialize the <code><a href="./map.md#commander_map_Map">Map</a></code> from the <code>BCS</code> instance.


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../../.doc-deps/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="./map.md#commander_map_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="./map.md#commander_map_Map">Map</a> {
    <b>let</b> <a href="./map.md#commander_map_id">id</a> = bcs.peel_address().to_id();
    <b>let</b> grid = grid::from_bcs!(bcs, |bcs| {
        <a href="./map.md#commander_map_Tile">Tile</a> {
            tile_type: match (bcs.peel_u8()) {
                0 =&gt; TileType::Empty,
                1 =&gt; TileType::Cover {
                    left: bcs.peel_u8(),
                    top: bcs.peel_u8(),
                    right: bcs.peel_u8(),
                    bottom: bcs.peel_u8(),
                },
                2 =&gt; TileType::Unwalkable,
                3 =&gt; TileType::Wall,
                _ =&gt; <b>abort</b>,
            },
            <a href="./unit.md#commander_unit">unit</a>: bcs.peel_option!(|bcs| <a href="./unit.md#commander_unit_from_bcs">unit::from_bcs</a>(bcs)),
        }
    });
    <b>let</b> <a href="./map.md#commander_map_turn">turn</a> = bcs.peel_u16();
    <a href="./map.md#commander_map_Map">Map</a> { <a href="./map.md#commander_map_id">id</a>, <a href="./map.md#commander_map_turn">turn</a>, grid }
}
</code></pre>



</details>

<a name="commander_map_to_string"></a>

## Function `to_string`

Implements the <code>Grid.<a href="./map.md#commander_map_to_string">to_string</a></code> method due to <code><a href="./map.md#commander_map_Tile">Tile</a></code> implementing
<code><a href="./map.md#commander_map_to_string">to_string</a></code> too.


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_to_string">to_string</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">commander::map::Map</a>): <a href="../../.doc-deps/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_to_string">to_string</a>(<a href="./map.md#commander_map">map</a>: &<a href="./map.md#commander_map_Map">Map</a>): String {
    <a href="./map.md#commander_map">map</a>.grid.<a href="./map.md#commander_map_to_string">to_string</a>!()
}
</code></pre>



</details>
