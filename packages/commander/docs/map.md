
<a name="(commander=0x0)_map"></a>

# Module `(commander=0x0)::map`

Defines the game <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code> - a grid of tiles where the game takes place. Map is
the most important component of the game, which provides direct access to
the stored data and objects and is used by game logic.

Traits:
- from_bcs
- to_string


-  [Struct `Tile`](#(commander=0x0)_map_Tile)
-  [Struct `Map`](#(commander=0x0)_map_Map)
-  [Enum `TileType`](#(commander=0x0)_map_TileType)
-  [Constants](#@Constants_0)
-  [Function `new`](#(commander=0x0)_map_new)
-  [Function `default`](#(commander=0x0)_map_default)
-  [Function `destroy`](#(commander=0x0)_map_destroy)
-  [Function `id`](#(commander=0x0)_map_id)
-  [Function `set_id`](#(commander=0x0)_map_set_id)
-  [Function `clone`](#(commander=0x0)_map_clone)
-  [Function `place_recruit`](#(commander=0x0)_map_place_recruit)
-  [Function `next_turn`](#(commander=0x0)_map_next_turn)
-  [Function `perform_reload`](#(commander=0x0)_map_perform_reload)
-  [Function `move_unit`](#(commander=0x0)_map_move_unit)
-  [Function `perform_attack`](#(commander=0x0)_map_perform_attack)
-  [Function `cover_bonus`](#(commander=0x0)_map_cover_bonus)
-  [Macro function `tile_cover`](#(commander=0x0)_map_tile_cover)
-  [Function `perform_grenade`](#(commander=0x0)_map_perform_grenade)
-  [Function `turn`](#(commander=0x0)_map_turn)
-  [Function `unit`](#(commander=0x0)_map_unit)
-  [Function `tile_has_unit`](#(commander=0x0)_map_tile_has_unit)
-  [Function `is_tile_cover`](#(commander=0x0)_map_is_tile_cover)
-  [Function `is_tile_empty`](#(commander=0x0)_map_is_tile_empty)
-  [Function `is_tile_unwalkable`](#(commander=0x0)_map_is_tile_unwalkable)
-  [Function `tile_to_string`](#(commander=0x0)_map_tile_to_string)
-  [Function `check_path`](#(commander=0x0)_map_check_path)
-  [Function `demo_1`](#(commander=0x0)_map_demo_1)
-  [Function `demo_2`](#(commander=0x0)_map_demo_2)
-  [Function `from_bytes`](#(commander=0x0)_map_from_bytes)
-  [Function `from_bcs`](#(commander=0x0)_map_from_bcs)
-  [Function `to_string`](#(commander=0x0)_map_to_string)


<pre><code><b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/armor.md#(commander=0x0)_armor">armor</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history">history</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/param.md#(commander=0x0)_param">param</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/rank.md#(commander=0x0)_rank">rank</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon.md#(commander=0x0)_weapon">weapon</a>;
<b>use</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/weapon_upgrade.md#(commander=0x0)_weapon_upgrade">weapon_upgrade</a>;
<b>use</b> (grid=0x0)::cursor;
<b>use</b> (grid=0x0)::grid;
<b>use</b> (grid=0x0)::point;
<b>use</b> <a href="../dependencies/std/ascii.md#std_ascii">std::ascii</a>;
<b>use</b> <a href="../dependencies/std/bcs.md#std_bcs">std::bcs</a>;
<b>use</b> <a href="../dependencies/std/option.md#std_option">std::option</a>;
<b>use</b> <a href="../dependencies/std/string.md#std_string">std::string</a>;
<b>use</b> <a href="../dependencies/std/u16.md#std_u16">std::u16</a>;
<b>use</b> <a href="../dependencies/std/u8.md#std_u8">std::u8</a>;
<b>use</b> <a href="../dependencies/std/vector.md#std_vector">std::vector</a>;
<b>use</b> <a href="../dependencies/sui/address.md#sui_address">sui::address</a>;
<b>use</b> <a href="../dependencies/sui/bcs.md#sui_bcs">sui::bcs</a>;
<b>use</b> <a href="../dependencies/sui/dynamic_field.md#sui_dynamic_field">sui::dynamic_field</a>;
<b>use</b> <a href="../dependencies/sui/event.md#sui_event">sui::event</a>;
<b>use</b> <a href="../dependencies/sui/hex.md#sui_hex">sui::hex</a>;
<b>use</b> <a href="../dependencies/sui/hmac.md#sui_hmac">sui::hmac</a>;
<b>use</b> <a href="../dependencies/sui/object.md#sui_object">sui::object</a>;
<b>use</b> <a href="../dependencies/sui/party.md#sui_party">sui::party</a>;
<b>use</b> <a href="../dependencies/sui/random.md#sui_random">sui::random</a>;
<b>use</b> <a href="../dependencies/sui/transfer.md#sui_transfer">sui::transfer</a>;
<b>use</b> <a href="../dependencies/sui/tx_context.md#sui_tx_context">sui::tx_context</a>;
<b>use</b> <a href="../dependencies/sui/vec_map.md#sui_vec_map">sui::vec_map</a>;
<b>use</b> <a href="../dependencies/sui/versioned.md#sui_versioned">sui::versioned</a>;
</code></pre>



<a name="(commander=0x0)_map_Tile"></a>

## Struct `Tile`

Defines a single Tile in the game <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code>. Tiles can be empty, provide cover
or be unwalkable. Additionally, a unit standing on a tile effectively makes
it unwalkable.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a> <b>has</b> <b>copy</b>, store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code>tile_type: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_TileType">map::TileType</a></code>
</dt>
<dd>
 The type of the tile.
</dd>
<dt>
<code><a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>: <a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/unit.md#(commander=0x0)_unit_Unit">unit::Unit</a>&gt;</code>
</dt>
<dd>
 The position of the tile on the map.
</dd>
</dl>


</details>

<a name="(commander=0x0)_map_Map"></a>

## Struct `Map`

Defines the game Map - a grid of tiles where the game takes place.


<pre><code><b>public</b> <b>struct</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> <b>has</b> store
</code></pre>



<details>
<summary>Fields</summary>


<dl>
<dt>
<code><a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a></code>
</dt>
<dd>
 The unique identifier of the map.
</dd>
<dt>
<code>grid: (grid=0x0)::grid::Grid&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Tile">map::Tile</a>&gt;</code>
</dt>
<dd>
 The grid of tiles.
</dd>
<dt>
<code><a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>: u16</code>
</dt>
<dd>
 The current turn number.
</dd>
</dl>


</details>

<a name="(commander=0x0)_map_TileType"></a>

## Enum `TileType`

A type of the <code><a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a></code>.


<pre><code><b>public</b> <b>enum</b> <a href="../name_gen/map.md#(commander=0x0)_map_TileType">TileType</a> <b>has</b> <b>copy</b>, drop, store
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


<a name="(commander=0x0)_map_EUnitAlreadyOnTile"></a>

Attempt to place a <code>Recruit</code> on a tile that already has a unit.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_EUnitAlreadyOnTile">EUnitAlreadyOnTile</a>: u64 = 1;
</code></pre>



<a name="(commander=0x0)_map_ETileIsUnwalkable"></a>

Attempt to place a <code>Recruit</code> on an unwalkable tile.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_ETileIsUnwalkable">ETileIsUnwalkable</a>: u64 = 2;
</code></pre>



<a name="(commander=0x0)_map_EPathUnwalkable"></a>

The path is unwalkable.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_EPathUnwalkable">EPathUnwalkable</a>: u64 = 3;
</code></pre>



<a name="(commander=0x0)_map_ENoUnit"></a>

The unit is not on the tile.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_ENoUnit">ENoUnit</a>: u64 = 5;
</code></pre>



<a name="(commander=0x0)_map_EPathTooShort"></a>

The path is too short.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_EPathTooShort">EPathTooShort</a>: u64 = 6;
</code></pre>



<a name="(commander=0x0)_map_ETileOutOfBounds"></a>

The tile is out of bounds.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_ETileOutOfBounds">ETileOutOfBounds</a>: u64 = 7;
</code></pre>



<a name="(commander=0x0)_map_NO_COVER"></a>

Constant for no cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_NO_COVER">NO_COVER</a>: u8 = 0;
</code></pre>



<a name="(commander=0x0)_map_LOW_COVER"></a>

Constant for low cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_LOW_COVER">LOW_COVER</a>: u8 = 1;
</code></pre>



<a name="(commander=0x0)_map_HIGH_COVER"></a>

Constant for high cover in the <code>TileType::Cover</code>.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>: u8 = 2;
</code></pre>



<a name="(commander=0x0)_map_DEFENSE_BONUS"></a>

Constant for the defense bonus.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_DEFENSE_BONUS">DEFENSE_BONUS</a>: u8 = 25;
</code></pre>



<a name="(commander=0x0)_map_GRENADE_RANGE"></a>

The range of the grenade.


<pre><code><b>const</b> <a href="../name_gen/map.md#(commander=0x0)_map_GRENADE_RANGE">GRENADE_RANGE</a>: u16 = 5;
</code></pre>



<a name="(commander=0x0)_map_new"></a>

## Function `new`



<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_new">new</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>, size: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_new">new</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: ID, size: u16): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
    <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
        <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>,
        <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>: 0,
        grid: grid::tabulate!(
            size,
            size,
            |_, _| <a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a> {
                tile_type: TileType::Empty,
                <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>: option::none(),
            },
        ),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_default"></a>

## Function `default`

Default Map is 30x30 tiles for now. Initially empty.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_default">default</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_default">default</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: ID): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> { <a href="../name_gen/map.md#(commander=0x0)_map_new">new</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>, 30) }
</code></pre>



</details>

<a name="(commander=0x0)_map_destroy"></a>

## Function `destroy`

Destroy the <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code> struct, returning the IDs of the units on the map.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): vector&lt;<a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): vector&lt;ID&gt; {
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> { grid, .. } = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>;
    <b>let</b> <b>mut</b> units = vector[];
    grid.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>!(|<a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a> { <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>, .. }| <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>!(|<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>| units.push_back(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>())));
    units
}
</code></pre>



</details>

<a name="(commander=0x0)_map_id"></a>

## Function `id`

Get the ID of the map.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): ID { <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a> }
</code></pre>



</details>

<a name="(commander=0x0)_map_set_id"></a>

## Function `set_id`

Set the ID of the map.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_set_id">set_id</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_set_id">set_id</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: ID) { <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a> = <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>; }
</code></pre>



</details>

<a name="(commander=0x0)_map_clone"></a>

## Function `clone`

Clone the <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code>.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_clone">clone</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_clone">clone</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> { <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> { <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>, <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>: <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>, grid: <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid } }
</code></pre>



</details>

<a name="(commander=0x0)_map_place_recruit"></a>

## Function `place_recruit`

Place a <code>Recruit</code> on the map at the given position.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_place_recruit">place_recruit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/recruit.md#(commander=0x0)_recruit_Recruit">recruit::Recruit</a>, x: u16, y: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_place_recruit">place_recruit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, <a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>: &Recruit, x: u16, y: u16): Record {
    <b>let</b> target_tile = &<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y];
    <b>assert</b>!(target_tile.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_none(), <a href="../name_gen/map.md#(commander=0x0)_map_EUnitAlreadyOnTile">EUnitAlreadyOnTile</a>);
    <b>assert</b>!(target_tile.tile_type != TileType::Unwalkable, <a href="../name_gen/map.md#(commander=0x0)_map_ETileIsUnwalkable">ETileIsUnwalkable</a>);
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.fill(<a href="../name_gen/recruit.md#(commander=0x0)_recruit">recruit</a>.to_unit());
    <a href="../name_gen/history.md#(commander=0x0)_history_new_recruit_placed">history::new_recruit_placed</a>(x, y)
}
</code></pre>



</details>

<a name="(commander=0x0)_map_next_turn"></a>

## Function `next_turn`

Proceed to the next turn.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_next_turn">next_turn</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_next_turn">next_turn</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): Record {
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a> = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a> + 1;
    <a href="../name_gen/history.md#(commander=0x0)_history_new_next_turn">history::new_next_turn</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>)
}
</code></pre>



</details>

<a name="(commander=0x0)_map_perform_reload"></a>

## Function `perform_reload`

Reload the unit's weapon. It costs 1 AP.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_reload">perform_reload</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_reload">perform_reload</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): Record {
    <b>assert</b>!(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some(), <a href="../name_gen/map.md#(commander=0x0)_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.borrow_mut();
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.try_reset_ap(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>);
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_perform_reload">perform_reload</a>();
    <a href="../name_gen/history.md#(commander=0x0)_history_new_reload">history::new_reload</a>(x, y)
}
</code></pre>



</details>

<a name="(commander=0x0)_map_move_unit"></a>

## Function `move_unit`

Move a unit along the path. The first point is the current position of the unit.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_move_unit">move_unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, path: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_move_unit">move_unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, path: vector&lt;u8&gt;): Record {
    <b>assert</b>!(path.length() &gt; 2, <a href="../name_gen/map.md#(commander=0x0)_map_EPathTooShort">EPathTooShort</a>);
    <b>let</b> distance = path.length() - 2;
    <b>let</b> (x0, y0) = (path[0] <b>as</b> u16, path[1] <b>as</b> u16);
    <b>let</b> (width, height) = (<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid.rows(), <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid.cols());
    <b>assert</b>!(y0 &lt; width && x0 &lt; height, <a href="../name_gen/map.md#(commander=0x0)_map_ETileOutOfBounds">ETileOutOfBounds</a>);
    <b>let</b> search = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_check_path">check_path</a>(path).destroy_or!(<b>abort</b> <a href="../name_gen/map.md#(commander=0x0)_map_EPathUnwalkable">EPathUnwalkable</a>);
    <b>let</b> (x1, y1) = (search[0], search[1]);
    <b>assert</b>!(y1 &lt; width && x1 &lt; height, <a href="../name_gen/map.md#(commander=0x0)_map_ETileOutOfBounds">ETileOutOfBounds</a>);
    <b>let</b> <b>mut</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x0, y0].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.extract();
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.try_reset_ap(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>);
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.perform_move(distance <b>as</b> u8);
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x1, y1].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.fill(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>);
    <a href="../name_gen/history.md#(commander=0x0)_history_new_move">history::new_move</a>(path)
}
</code></pre>



</details>

<a name="(commander=0x0)_map_perform_attack"></a>

## Function `perform_attack`

Perform a ranged attack.

TODO: cover mechanic, provide <code>DEF</code> stat based on the direction of the
attack and the relative position of the attacker and the target.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_attack">perform_attack</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, rng: &<b>mut</b> <a href="../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, x0: u16, y0: u16, x1: u16, y1: u16): vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_attack">perform_attack</a>(
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>,
    rng: &<b>mut</b> RandomGenerator,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
): vector&lt;Record&gt; {
    <b>let</b> <b>mut</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a> = vector[<a href="../name_gen/history.md#(commander=0x0)_history_new_attack">history::new_attack</a>(vector[x0, y0], vector[x1, y1])];
    <b>let</b> range = grid::manhattan_distance!(x0, y0, x1, y1) <b>as</b> u8;
    <b>let</b> defense_bonus = <b>if</b> (range &gt; 0) <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_cover_bonus">cover_bonus</a>(x0, y0, x1, y1) <b>else</b> 0;
    <b>let</b> attacker = &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x0, y0].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>;
    <b>assert</b>!(attacker.is_some(), <a href="../name_gen/map.md#(commander=0x0)_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = attacker.borrow_mut();
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.try_reset_ap(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>);
    <b>let</b> (is_hit, _, is_crit, damage, _) = <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_perform_attack">perform_attack</a>(rng, range, defense_bonus);
    <b>let</b> target = &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x1, y1].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>;
    <b>assert</b>!(target.is_some(), <a href="../name_gen/map.md#(commander=0x0)_map_ENoUnit">ENoUnit</a>);
    <b>let</b> <b>mut</b> target = target.extract();
    <b>let</b> (is_dodged, damage, is_kia) = <b>if</b> (is_hit && damage &gt; 0) {
        target.apply_damage(rng, damage, <b>true</b>)
    } <b>else</b> (<b>false</b>, 0, <b>false</b>);
    <b>if</b> (is_dodged) <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(<a href="../name_gen/history.md#(commander=0x0)_history_new_dodged">history::new_dodged</a>());
    <b>if</b> (is_hit) {
        <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back({
            <b>if</b> (is_crit) <a href="../name_gen/history.md#(commander=0x0)_history_new_critical_hit">history::new_critical_hit</a>(damage) // same cost
            <b>else</b> <a href="../name_gen/history.md#(commander=0x0)_history_new_damage">history::new_damage</a>(damage)
        });
    } <b>else</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(<a href="../name_gen/history.md#(commander=0x0)_history_new_miss">history::new_miss</a>());
    <b>if</b> (is_kia) <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(<a href="../name_gen/history.md#(commander=0x0)_history_new_kia">history::new_kia</a>(target.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>()))
    <b>else</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x1, y1].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.fill(target);
    <a href="../name_gen/history.md#(commander=0x0)_history">history</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_map_cover_bonus"></a>

## Function `cover_bonus`

Calculate the cover bonus for the given tile. The cover bonus is calculated
based on the direction of the attack and the type of cover on the tile.

- no cover - 0
- LOW_COVER - 25
- HIGH_COVER - 50


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_cover_bonus">cover_bonus</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): u8
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_cover_bonus">cover_bonus</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x0: u16, y0: u16, x1: u16, y1: u16): u8 {
    <b>use</b> <a href="../dependencies/name_gen/direction.md#(grid=0x0)_direction">grid::direction</a>::{direction, none, up, down, left, right};
    <b>let</b> direction = direction!(x0, y0, x1, y1);
    <b>let</b> (up, down, left, right) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1);
    // edge case: same tile, should never happen
    <b>if</b> (direction == none!()) <b>return</b> 0;
    // target tile cover type (does not check neighboring tiles with reverse defense)
    <b>let</b> cover_type = <b>if</b> (direction == up!()) {
        <b>if</b> (down != 0) down // target tile <b>has</b> cover
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            top
        }
    } <b>else</b> <b>if</b> (direction == down!()) {
        <b>if</b> (up != 0) up
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            bottom
        }
    } <b>else</b> <b>if</b> (direction == left!()) {
        <b>if</b> (right != 0) right
        <b>else</b> {
            <b>let</b> (_, _, left, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            left
        }
    } <b>else</b> <b>if</b> (direction == right!()) {
        <b>if</b> (left != 0) left
        <b>else</b> {
            <b>let</b> (_, _, _, right) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            right
        }
    } <b>else</b> <b>if</b> (direction == up!() | left!()) {
        <b>let</b> cover_type = num_max!(down, right);
        <b>if</b> (cover_type  != 0) cover_type
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            <b>let</b> (_, _, left, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            num_max!(top, left)
        }
    } <b>else</b> <b>if</b> (direction == up!() | right!()) {
        <b>let</b> cover_type = num_max!(down, left);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (top, _, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 + 1, y1);
            <b>let</b> (_, _, _, right) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            num_max!(top, right)
        }
    } <b>else</b> <b>if</b> (direction == down!() | left!()) {
        <b>let</b> cover_type = num_max!(up, right);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            <b>let</b> (_, _, left, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 + 1);
            num_max!(bottom, left)
        }
    } <b>else</b> <b>if</b> (direction == down!() | right!()) {
        <b>let</b> cover_type = num_max!(up, left);
        <b>if</b> (cover_type != 0) cover_type
        <b>else</b> {
            <b>let</b> (_, bottom, _, _) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1 - 1, y1);
            <b>let</b> (_, _, _, right) = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>!(x1, y1 - 1);
            num_max!(bottom, right)
        }
    } <b>else</b> <b>abort</b>; // unreachable
    // cover <b>enum</b> is 0, 1, 2, so by multiplying it by 25 we get the value we
    // need; same, <b>as</b> <b>if</b> we matched it to 0, 25, 50
    cover_type * <a href="../name_gen/map.md#(commander=0x0)_map_DEFENSE_BONUS">DEFENSE_BONUS</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_map_tile_cover"></a>

## Macro function `tile_cover`



<pre><code><b>macro</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>($<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, $x: u16, $y: u16): (u8, u8, u8, u8)
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>macro</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_cover">tile_cover</a>($<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, $x: u16, $y: u16): (u8, u8, u8, u8) {
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a> = $<a href="../name_gen/map.md#(commander=0x0)_map">map</a>;
    match (<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[$x, $y].tile_type) {
        TileType::Cover { left, right, top, bottom } =&gt; (top, bottom, left, right),
        _ =&gt; (0, 0, 0, 0),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_perform_grenade"></a>

## Function `perform_grenade`

Throw a grenade. This action costs 1AP, deals area damage and destroys
covers in the area of effect (currently 3x3).


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_grenade">perform_grenade</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, rng: &<b>mut</b> <a href="../dependencies/sui/random.md#sui_random_RandomGenerator">sui::random::RandomGenerator</a>, x: u16, y: u16, x1: u16, y1: u16): vector&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/history.md#(commander=0x0)_history_Record">history::Record</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_perform_grenade">perform_grenade</a>(
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>,
    rng: &<b>mut</b> RandomGenerator,
    x: u16,
    y: u16,
    x1: u16,
    y1: u16,
): vector&lt;Record&gt; {
    <b>let</b> radius = 2; // 5x5 area of effect
    <b>let</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>;
    <b>assert</b>!(grid::manhattan_distance!(x, y, x1, y1) &lt;= <a href="../name_gen/map.md#(commander=0x0)_map_GRENADE_RANGE">GRENADE_RANGE</a>, <a href="../name_gen/map.md#(commander=0x0)_map_EPathTooShort">EPathTooShort</a>);
    <b>assert</b>!(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some(), <a href="../name_gen/map.md#(commander=0x0)_map_ENoUnit">ENoUnit</a>);
    // update <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>'s <a href="../name_gen/stats.md#(commander=0x0)_stats">stats</a>
    <b>let</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.borrow_mut();
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.try_reset_ap(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>);
    <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_perform_grenade">perform_grenade</a>();
    // update each tile: Cover -&gt; Empty
    <b>let</b> <b>mut</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a> = vector[<a href="../name_gen/history.md#(commander=0x0)_history_new_grenade">history::new_grenade</a>(x1, y1, radius)];
    <b>let</b> <b>mut</b> points = <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid.von_neumann(point::new(x1, y1), radius);
    points.push_back(point::new(x1, y1));
    points.do!(|p| {
        <b>let</b> (x, y) = p.to_values();
        <b>let</b> tile = &<b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y];
        <b>if</b> (tile.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some()) {
            <b>let</b> <b>mut</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a> = tile.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.extract();
            <b>let</b> (_, dmg, is_kia) = <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.apply_damage(rng, 4, <b>false</b>);
            <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(<a href="../name_gen/history.md#(commander=0x0)_history_new_damage">history::new_damage</a>(dmg));
            <b>if</b> (!is_kia) tile.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.fill(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>)
            <b>else</b> <a href="../name_gen/history.md#(commander=0x0)_history">history</a>.push_back(<a href="../name_gen/history.md#(commander=0x0)_history_new_kia">history::new_kia</a>(<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>()));
        };
        match (tile.tile_type) {
            TileType::Cover { .. } =&gt; tile.tile_type = TileType::Empty,
            _ =&gt; (),
        };
    });
    <a href="../name_gen/history.md#(commander=0x0)_history">history</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_map_turn"></a>

## Function `turn`

Get the current turn number.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): u16
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): u16 { <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a> }
</code></pre>



</details>

<a name="(commander=0x0)_map_unit"></a>

## Function `unit`

Read the Unit at the given position.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): &<a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/unit.md#(commander=0x0)_unit_Unit">unit::Unit</a>&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): &Option&lt;Unit&gt; {
    &<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_map_tile_has_unit"></a>

## Function `tile_has_unit`

Check if the given tile has a unit on it.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_has_unit">tile_has_unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_has_unit">tile_has_unit</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): bool {
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some()
}
</code></pre>



</details>

<a name="(commander=0x0)_map_is_tile_cover"></a>

## Function `is_tile_cover`

Check if the given tile is a cover.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_cover">is_tile_cover</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_cover">is_tile_cover</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].tile_type) {
        TileType::Cover { .. } =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_is_tile_empty"></a>

## Function `is_tile_empty`

Check if the given tile is empty.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_empty">is_tile_empty</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_empty">is_tile_empty</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].tile_type) {
        TileType::Empty =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_is_tile_unwalkable"></a>

## Function `is_tile_unwalkable`

Check if the given tile is unwalkable.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_unwalkable">is_tile_unwalkable</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, x: u16, y: u16): bool
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_is_tile_unwalkable">is_tile_unwalkable</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, x: u16, y: u16): bool {
    match (<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x, y].tile_type) {
        TileType::Unwalkable =&gt; <b>true</b>,
        _ =&gt; <b>false</b>,
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_tile_to_string"></a>

## Function `tile_to_string`

Print the <code><a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a></code> as a <code>String</code>. Used in the <code>Grid.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>!()</code> macro.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_to_string">tile_to_string</a>(tile: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Tile">map::Tile</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_tile_to_string">tile_to_string</a>(tile: &<a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a>): String {
    match (tile.tile_type) {
        TileType::Empty =&gt; b"     ".<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>(),
        TileType::Cover { left, right, top, bottom } =&gt; {
            <b>let</b> <b>mut</b> str = b"".<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>();
            str.append(left.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>());
            str.append(top.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>());
            str.append(right.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>());
            str.append(bottom.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>());
            str.append_utf8(<b>if</b> (tile.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some()) b"U" <b>else</b> b"-");
            str
        },
        TileType::Unwalkable =&gt; b" XXX ".<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>(),
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_check_path"></a>

## Function `check_path`

Check if the given path is walkable. Can be an optimization for pathfinding,
if the path is traced on the frontend.

Returns <code>None</code> if the path is not walkable, otherwise returns the end point
of the path.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_check_path">check_path</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>, path: vector&lt;u8&gt;): <a href="../dependencies/std/option.md#std_option_Option">std::option::Option</a>&lt;vector&lt;u16&gt;&gt;
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_check_path">check_path</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>, <b>mut</b> path: vector&lt;u8&gt;): Option&lt;vector&lt;u16&gt;&gt; {
    <b>use</b> <a href="../dependencies/name_gen/direction.md#(grid=0x0)_direction">grid::direction</a>::{up, down, left, right};
    path.reverse();
    // first two values are X and Y coordinates, the rest are directions
    <b>let</b> (x0, y0) = (path.pop_back(), path.pop_back());
    <b>let</b> <b>mut</b> cursor = cursor::new(x0 <b>as</b> u16, y0 <b>as</b> u16);
    <b>let</b> none = option::none();
    'path: {
        path.<a href="../name_gen/map.md#(commander=0x0)_map_destroy">destroy</a>!(|direction| {
            <b>let</b> (x0, y0) = cursor.to_values();
            <b>let</b> source = &<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x0, y0];
            cursor.move_to(direction);
            <b>let</b> (x1, y1) = cursor.to_values();
            <b>let</b> target = &<a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid[x1, y1];
            // units, high covers and unwalkable tiles block the path
            <b>if</b> (target.<a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>.is_some()) <b>return</b> 'path none;
            match (source.tile_type) {
                TileType::Empty =&gt; (),
                TileType::Unwalkable =&gt; <b>return</b> 'path none,
                TileType::Cover { left, right, top, bottom } =&gt; {
                    <b>if</b> (direction == left!() && left == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == right!() && right == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == up!() && top == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == down!() && bottom == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                },
            };
            match (target.tile_type) {
                TileType::Empty =&gt; (),
                TileType::Unwalkable =&gt; <b>return</b> 'path none,
                TileType::Cover { left, right, top, bottom } =&gt; {
                    <b>if</b> (direction == left!() && right == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == right!() && left == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == up!() && bottom == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                    <b>if</b> (direction == down!() && top == <a href="../name_gen/map.md#(commander=0x0)_map_HIGH_COVER">HIGH_COVER</a>) <b>return</b> 'path none;
                },
            };
        });
        option::some(cursor.to_vector())
    }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_demo_1"></a>

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


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_demo_1">demo_1</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_demo_1">demo_1</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: ID): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
    <b>let</b> <b>mut</b> preset_bytes = bcs::to_bytes(&<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>);
    // prettier-ignore
    preset_bytes.append(x"0707000000000102000002000100000001000100000002000000000007020000000000000000000000000007000000000000000000000100000001000100000001000701000100000001000102000000000200000001010000000001010000000007010000000100010001000200000000000000000000000700000000000000000000000000000700000200000000000101010000000100010000000100010100000000");
    <a href="../name_gen/map.md#(commander=0x0)_map_from_bytes">from_bytes</a>(preset_bytes)
}
</code></pre>



</details>

<a name="(commander=0x0)_map_demo_2"></a>

## Function `demo_2`

Creates a demo map #2.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_demo_2">demo_2</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: <a href="../dependencies/sui/object.md#sui_object_ID">sui::object::ID</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_demo_2">demo_2</a>(<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>: ID): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
    // prettier-ignore
    <b>let</b> <b>mut</b> <a href="../name_gen/map.md#(commander=0x0)_map">map</a> = <a href="../name_gen/map.md#(commander=0x0)_map_from_bytes">from_bytes</a>(x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000101000001000100000001000100000101000000000001010000010001000000010001000001010000000a00000000000000000000000000000000000000000a00000200020002000000000002000200020000000a000001010000010000000100000101000000000000000200000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a010202000000010001000000010001000000010002020000000000000101020000000100010000000100010000000100020200000a01020000000000000000010000010000000000000000000000000100000200000a0102000002000100000002000100000002000100000002000100000002000100000002000100000002000100000002000100000002000100000202000000");
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.<a href="../name_gen/map.md#(commander=0x0)_map_id">id</a> = <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>;
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>
}
</code></pre>



</details>

<a name="(commander=0x0)_map_from_bytes"></a>

## Function `from_bytes`

Deserializes the <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code> from the given bytes.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_from_bytes">from_bytes</a>(bytes: vector&lt;u8&gt;): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
    <a href="../name_gen/map.md#(commander=0x0)_map_from_bcs">from_bcs</a>(&<b>mut</b> bcs::new(bytes))
}
</code></pre>



</details>

<a name="(commander=0x0)_map_from_bcs"></a>

## Function `from_bcs`

Deserialize the <code><a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a></code> from the <code>BCS</code> instance.


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_from_bcs">from_bcs</a>(bcs: &<b>mut</b> <a href="../dependencies/sui/bcs.md#sui_bcs_BCS">sui::bcs::BCS</a>): (<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b>(package) <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_from_bcs">from_bcs</a>(bcs: &<b>mut</b> BCS): <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> {
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a> = bcs.peel_address().to_id();
    <b>let</b> grid = grid::from_bcs!(bcs, |bcs| {
        <a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a> {
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
            <a href="../name_gen/unit.md#(commander=0x0)_unit">unit</a>: bcs.peel_option!(|bcs| <a href="../name_gen/unit.md#(commander=0x0)_unit_from_bcs">unit::from_bcs</a>(bcs)),
        }
    });
    <b>let</b> <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a> = bcs.peel_u16();
    <a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a> { <a href="../name_gen/map.md#(commander=0x0)_map_id">id</a>, <a href="../name_gen/map.md#(commander=0x0)_map_turn">turn</a>, grid }
}
</code></pre>



</details>

<a name="(commander=0x0)_map_to_string"></a>

## Function `to_string`

Implements the <code>Grid.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a></code> method due to <code><a href="../name_gen/map.md#(commander=0x0)_map_Tile">Tile</a></code> implementing
<code><a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a></code> too.


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &(<a href="../name_gen/commander.md#(commander=0x0)_commander">commander</a>=0x0)::<a href="../name_gen/map.md#(commander=0x0)_map_Map">map::Map</a>): <a href="../dependencies/std/string.md#std_string_String">std::string::String</a>
</code></pre>



<details>
<summary>Implementation</summary>


<pre><code><b>public</b> <b>fun</b> <a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>(<a href="../name_gen/map.md#(commander=0x0)_map">map</a>: &<a href="../name_gen/map.md#(commander=0x0)_map_Map">Map</a>): String {
    <a href="../name_gen/map.md#(commander=0x0)_map">map</a>.grid.<a href="../name_gen/map.md#(commander=0x0)_map_to_string">to_string</a>!()
}
</code></pre>



</details>
