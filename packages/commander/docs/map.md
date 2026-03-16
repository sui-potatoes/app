
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
-  [Function `turn`](#commander_map_turn)
-  [Function `unit`](#commander_map_unit)
-  [Function `tile_has_unit`](#commander_map_tile_has_unit)
-  [Function `is_tile_cover`](#commander_map_is_tile_cover)
-  [Function `is_tile_empty`](#commander_map_is_tile_empty)
-  [Function `is_tile_unwalkable`](#commander_map_is_tile_unwalkable)
-  [Function `tile_to_string`](#commander_map_tile_to_string)
-  [Function `check_path`](#commander_map_check_path)
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
 Certain tiles cannot be walked on, like walls or water.
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



<a name="commander_map_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_new">new</a>(<a href="./map.md#commander_map_id">id</a>: <a href="../../.doc-deps/sui/object.md#sui_object_ID">sui::object::ID</a>, size: u16): <a href="./map.md#commander_map_Map">commander::map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="./map.md#commander_map_new">new</a>(<a href="./map.md#commander_map_id">id</a>: ID, size: u16): <a href="./map.md#commander_map_Map">Map</a> {
    <a href="./map.md#commander_map_Map">Map</a> {
        <a href="./map.md#commander_map_id">id</a>,
        <a href="./map.md#commander_map_turn">turn</a>: 0,
        grid: grid::tabulate!(
            size,
            size,
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
    <b>let</b> (width, height) = (<a href="./map.md#commander_map">map</a>.grid.rows(), <a href="./map.md#commander_map">map</a>.grid.cols());
    <b>assert</b>!(y0 &lt; width && x0 &lt; height, <a href="./map.md#commander_map_ETileOutOfBounds">ETileOutOfBounds</a>);
    <b>let</b> search = <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_check_path">check_path</a>(path).destroy_or!(<b>abort</b> <a href="./map.md#commander_map_EPathUnwalkable">EPathUnwalkable</a>);
    <b>let</b> (x1, y1) = (search[0], search[1]);
    <b>assert</b>!(y1 &lt; width && x1 &lt; height, <a href="./map.md#commander_map_ETileOutOfBounds">ETileOutOfBounds</a>);
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

Perform a ranged attack.

TODO: cover mechanic, provide <code>DEF</code> stat based on the direction of the
attack and the relative position of the attacker and the target.


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
    <b>let</b> defense_bonus = <b>if</b> (range &gt; 0) <a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_cover_bonus">cover_bonus</a>(x0, y0, x1, y1) <b>else</b> 0;
    <b>let</b> attacker = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x0, y0].<a href="./unit.md#commander_unit">unit</a>;
    <b>assert</b>!(attacker.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = attacker.borrow_mut();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <b>let</b> (is_hit, _, is_crit, damage, _) = <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_perform_attack">perform_attack</a>(rng, range, defense_bonus);
    <b>let</b> target = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x1, y1].<a href="./unit.md#commander_unit">unit</a>;
    <b>assert</b>!(target.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <b>mut</b> target = target.extract();
    <b>let</b> (is_dodged, damage, is_kia) = <b>if</b> (is_hit && damage &gt; 0) {
        target.apply_damage(rng, damage, <b>true</b>)
    } <b>else</b> (<b>false</b>, 0, <b>false</b>);
    <b>if</b> (is_dodged) <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_dodged">history::new_dodged</a>());
    <b>if</b> (is_hit) {
        <a href="./history.md#commander_history">history</a>.push_back({
            <b>if</b> (is_crit) <a href="./history.md#commander_history_new_critical_hit">history::new_critical_hit</a>(damage) // same cost
            <b>else</b> <a href="./history.md#commander_history_new_damage">history::new_damage</a>(damage)
        });
    } <b>else</b> <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_miss">history::new_miss</a>());
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
        _ =&gt; (0, 0, 0, 0),
    }
}
</code></pre>



</details>

<a name="commander_map_perform_grenade"></a>

## Function `perform_grenade`

Throw a grenade. This action costs 1AP, deals area damage and destroys
covers in the area of effect (currently 3x3).


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
    <b>let</b> radius = 2; // 5x5 area of effect
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x, y].<a href="./unit.md#commander_unit">unit</a>;
    <b>assert</b>!(grid::manhattan_distance!(x, y, x1, y1) &lt;= <a href="./map.md#commander_map_GRENADE_RANGE">GRENADE_RANGE</a>, <a href="./map.md#commander_map_EPathTooShort">EPathTooShort</a>);
    <b>assert</b>!(<a href="./unit.md#commander_unit">unit</a>.is_some(), <a href="./map.md#commander_map_ENoUnit">ENoUnit</a>);
    // update <a href="./unit.md#commander_unit">unit</a>'s <a href="./stats.md#commander_stats">stats</a>
    <b>let</b> <a href="./unit.md#commander_unit">unit</a> = <a href="./unit.md#commander_unit">unit</a>.borrow_mut();
    <a href="./unit.md#commander_unit">unit</a>.try_reset_ap(<a href="./map.md#commander_map">map</a>.<a href="./map.md#commander_map_turn">turn</a>);
    <a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_perform_grenade">perform_grenade</a>();
    // update each tile: Cover -&gt; Empty
    <b>let</b> <b>mut</b> <a href="./history.md#commander_history">history</a> = vector[<a href="./history.md#commander_history_new_grenade">history::new_grenade</a>(x1, y1, radius)];
    <b>let</b> <b>mut</b> cells = <a href="./map.md#commander_map">map</a>.grid.von_neumann_neighbors(cell::new(x1, y1), radius);
    cells.push_back(cell::new(x1, y1));
    cells.do!(|p| {
        <b>let</b> (x, y) = p.to_values();
        <b>let</b> tile = &<b>mut</b> <a href="./map.md#commander_map">map</a>.grid[x, y];
        <b>if</b> (tile.<a href="./unit.md#commander_unit">unit</a>.is_some()) {
            <b>let</b> <b>mut</b> <a href="./unit.md#commander_unit">unit</a> = tile.<a href="./unit.md#commander_unit">unit</a>.extract();
            <b>let</b> (_, dmg, is_kia) = <a href="./unit.md#commander_unit">unit</a>.apply_damage(rng, 4, <b>false</b>);
            <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_damage">history::new_damage</a>(dmg));
            <b>if</b> (!is_kia) tile.<a href="./unit.md#commander_unit">unit</a>.fill(<a href="./unit.md#commander_unit">unit</a>)
            <b>else</b> <a href="./history.md#commander_history">history</a>.push_back(<a href="./history.md#commander_history_new_kia">history::new_kia</a>(<a href="./unit.md#commander_unit">unit</a>.<a href="./map.md#commander_map_destroy">destroy</a>()));
        };
        match (tile.tile_type) {
            TileType::Cover { .. } =&gt; tile.tile_type = TileType::Empty,
            _ =&gt; (),
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
    <b>use</b> <a href="../../.doc-deps/grid/direction.md#grid_direction">grid::direction</a>::{up, down, left, right};
    path.reverse();
    // first two values are X and Y coordinates, the rest are directions
    <b>let</b> (x0, y0) = (path.pop_back(), path.pop_back());
    <b>let</b> <b>mut</b> cursor = cursor::new(x0 <b>as</b> u16, y0 <b>as</b> u16);
    <b>let</b> none = option::none();
    'path: {
        path.<a href="./map.md#commander_map_destroy">destroy</a>!(|direction| {
            <b>let</b> (x0, y0) = cursor.to_values();
            <b>let</b> source = &<a href="./map.md#commander_map">map</a>.grid[x0, y0];
            cursor.move_to(direction);
            <b>let</b> (x1, y1) = cursor.to_values();
            <b>let</b> target = &<a href="./map.md#commander_map">map</a>.grid[x1, y1];
            // units, high covers and unwalkable tiles block the path
            <b>if</b> (target.<a href="./unit.md#commander_unit">unit</a>.is_some()) <b>return</b> 'path none;
            match (source.tile_type) {
                TileType::Empty =&gt; (),
                TileType::Unwalkable =&gt; <b>return</b> 'path none,
                TileType::Cover { left, right, top, bottom } =&gt; {
                    <b>if</b> (direction == left!() && left == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == right!() && right == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == up!() && top == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == down!() && bottom == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                },
            };
            match (target.tile_type) {
                TileType::Empty =&gt; (),
                TileType::Unwalkable =&gt; <b>return</b> 'path none,
                TileType::Cover { left, right, top, bottom } =&gt; {
                    <b>if</b> (direction == left!() && right == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == right!() && left == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == up!() && bottom == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == down!() && top == <a href="./map.md#commander_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                },
            };
        });
        option::some(cursor.to_vector())
    }
}
</code></pre>



</details>

<a name="commander_map_demo_1"></a>

## Function `demo_1`

Creates a demo map #1.

- Map: 01 - 7x7 LEGO prototype.
- Unit positions: (0, 3), (1, 6), (6, 5)
- Goal: close encounter with low and high cover to test line of sight and cover mechanics.
- Schema:

```
|     |     |2002-|0001-|0002-|     |     |
| XXX |     |     |     |     |     |     |
|     |     |     |     |     |0001-|0001-|
|0100-|0210-|     | XXX |     |1000-|1000-|
|0001-|0012-|     |     |     |     |     |
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
