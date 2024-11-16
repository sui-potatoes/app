// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the game `Map` - a grid of tiles where the game takes place. Map is
/// the most important component of the game, which provides direct access to
/// the stored data and objects and is used by game logic.
module commander::map;

use commander::{recruit::Recruit, unit::Unit};
use grid::grid::{Self, Grid};
use std::string::String;
use sui::bcs::BCS;

const EUnitAlreadyOnTile: u64 = 1;
const ETileIsUnwalkable: u64 = 2;

/// Defines a single Tile in the game `Map`. Tiles can be empty, provide cover
/// or be unwalkable. Additionally, a unit standing on a tile effectively makes
/// it unwalkable.
public struct Tile has store, drop {
    /// The type of the tile.
    tile_type: TileType,
    /// The position of the tile on the map.
    unit: Option<Unit>,
}

/// A type of the `Tile`.
public enum TileType has store, copy, drop {
    /// An empty tile without any cover.
    Empty,
    /// A low cover tile. Provides partial cover from 1-3 sides. Can be
    /// destroyed by explosives and heavy weapons.
    Cover {
        left: bool,
        right: bool,
        top: bool,
        bottom: bool,
    },
    /// Certain tiles cannot be walked on, like walls or water.
    Unwalkable,
}

/// Defines the game Map - a grid of tiles where the game takes place.
public struct Map has store, drop {
    /// The grid of tiles.
    grid: Grid<Tile>,
}

public fun new(size: u16): Map {
    Map {
        grid: grid::tabulate!(
            size,
            size,
            |_, _| Tile {
                tile_type: TileType::Empty,
                unit: option::none(),
            },
        ),
    }
}

/// Maps will be 30x30 tiles for now. Initially empty.
public fun default(): Map {
    new(30)
}

/// Place Rookie on the map at the given position.
public fun place_recruit(map: &mut Map, recruit: &Recruit, x: u16, y: u16) {
    assert!(!map.tile_has_unit(x, y), EUnitAlreadyOnTile);
    assert!(!map.is_tile_unwalkable(x, y), ETileIsUnwalkable);

    map.grid[x, y].unit.fill(recruit.to_unit())
}

/// Check if the given tile has a unit on it.
public fun tile_has_unit(map: &Map, x: u16, y: u16): bool {
    map.grid[x, y].unit.is_some()
}

/// Check if the given tile is a cover.
public fun is_tile_cover(map: &Map, x: u16, y: u16): bool {
    match (map.grid[x, y].tile_type) {
        TileType::Cover { .. } => true,
        _ => false,
    }
}

/// Check if the given tile is empty.
public fun is_tile_empty(map: &Map, x: u16, y: u16): bool {
    match (map.grid[x, y].tile_type) {
        TileType::Empty => true,
        _ => false,
    }
}

/// Check if the given tile is unwalkable.
public fun is_tile_unwalkable(map: &Map, x: u16, y: u16): bool {
    match (map.grid[x, y].tile_type) {
        TileType::Unwalkable => true,
        _ => false,
    }
}

// adds an alias so that `Map.to_string` function can be run
public use fun tile_to_string as Tile.to_string;

/// Get the tile at the given position.
public fun tile_to_string(tile: &Tile): String {
    if (tile.unit.is_some()) {
        return tile.unit.borrow().hp().to_string();
        // return b"U".to_string()
    };

    match (tile.tile_type) {
        // _ if (tile.unit.is_some()) => b"U".to_string(),
        TileType::Empty => b" ".to_string(),
        TileType::Cover { .. } => b"C".to_string(),
        TileType::Unwalkable => b"X".to_string(),
    }
}

#[allow(unused_variable)]
/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Map {
    abort 264
}

#[allow(unused_variable, unused_mut_parameter)]
/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(bcs: &mut BCS): Map {
    abort 264
}

/// Implements the `Grid.to_string` method due to `Tile` implementing
/// `to_string` too.
public fun to_string(map: &Map): String {
    map.grid.to_string!()
}

#[test]
fun test_map_with_units() {
    use sui::random;
    use commander::recruit;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[2]);
    let recruit_one = recruit::default(ctx);
    let recruit_two = recruit::default(ctx);

    let mut map = Self::new(6);

    assert!(!map.tile_has_unit(3, 3));
    assert!(!map.tile_has_unit(5, 2));

    map.place_recruit(&recruit_one, 3, 3);
    map.place_recruit(&recruit_two, 5, 2);

    assert!(map.tile_has_unit(3, 3));
    assert!(map.tile_has_unit(5, 2));

    std::debug::print(&map.to_string());

    // now try to attack another unit with the first one
    let damage = map
        .grid[3, 3]
        .unit
        .map!(|mut unit| unit.perform_attack(&mut rng, ctx))
        .destroy_or!(abort 264);

    std::debug::print(&damage.to_string());

    // apply the damage to the second unit
    map.grid[5, 2].unit.borrow_mut().apply_damage(&mut rng, damage, false);

    std::debug::print(&map.to_string()); // shows damage dealt

    recruit_one.dismiss().destroy_none();
    recruit_two.dismiss().destroy_none();
}
