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

const ENotImplemented: u64 = 264;
const EUnitAlreadyOnTile: u64 = 1;
const ETileIsUnwalkable: u64 = 2;

/// Defines a single Tile in the game `Map`. Tiles can be empty, provide cover
/// or be unwalkable. Additionally, a unit standing on a tile effectively makes
/// it unwalkable.
public struct Tile has drop, store {
    /// The type of the tile.
    tile_type: TileType,
    /// The position of the tile on the map.
    unit: Option<Unit>,
}

/// A type of the `Tile`.
public enum TileType has copy, drop, store {
    /// An empty tile without any cover.
    Empty,
    /// A low cover tile. Provides partial cover from 1-3 sides. Can be
    /// destroyed by explosives and heavy weapons.
    ///
    /// Cover also limits the movement of units, as they cannot move through
    /// cover sides.
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
public struct Map has drop, store {
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
        return tile.unit.borrow().hp().to_string()
    };

    match (tile.tile_type) {
        // _ if (tile.unit.is_some()) => b"U".to_string(),
        TileType::Empty => b" ".to_string(),
        TileType::Cover { .. } => b"C".to_string(),
        TileType::Unwalkable => b"X".to_string(),
    }
}

/// Check if the given path is walkable. Can be an optimization for pathfinding,
/// if the path is traced on the frontend.
public fun check_path(map: &Map, path: vector<vector<u16>>): bool {
    let mut prev = path[0];
    'a: {
        path.do_ref!(|step| {
            if (step == prev) return; // skip 1st and duplicate steps
            let (x0, y0) = (prev[0], prev[1]);
            let (x1, y1) = (step[0], step[1]);

            let source = &map.grid[x0, y0];
            let target = &map.grid[x1, y1];
            if (target.unit.is_some()) return 'a false;

            prev = *step;

            // UP
            if (x0 == x1 && y0 == y1 + 1) {
                match (&source.tile_type) {
                    TileType::Cover { top, .. } if (*top) => return 'a false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { bottom, .. } if (*bottom) => return 'a false,
                    _ => (),
                };
            };

            // DOWN
            if (x0 == x1 && y0 + 1 == y1) {
                match (&source.tile_type) {
                    TileType::Cover { bottom, .. } if (*bottom) => return 'a false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { top, .. } if (*top) => return 'a false,
                    _ => (),
                };
            };

            // LEFT
            if (y0 == y1 && x0 == x1 + 1) {
                match (&source.tile_type) {
                    TileType::Cover { left, .. } if (*left) => return 'a false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { right, .. } if (*right) => return 'a false,
                    _ => (),
                };
            };

            // RIGHT
            if (y0 == y1 && x1 == x0 + 1) {
                match (&source.tile_type) {
                    TileType::Cover { right, .. } if (*right) => return 'a false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { left, .. } if (*left) => return 'a false,
                    _ => (),
                };
            }
        });

        true
    }
}

/// Deserialize bytes into a `Rank`.
public fun from_bytes(_bytes: vector<u8>): Map {
    abort ENotImplemented
}

/// Helper method to allow nested deserialization of `Rank`.
public(package) fun from_bcs(_bcs: &mut BCS): Map {
    abort ENotImplemented
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

    // apply the damage to the second unit
    map.grid[5, 2].unit.borrow_mut().apply_damage(&mut rng, damage, false);

    recruit_one.dismiss().destroy_none();
    recruit_two.dismiss().destroy_none();
}

#[test]
fun test_check_path() {
    let mut map = Self::new(3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: false, right: true, top: false, bottom: false };

    // try going right and then back-left
    assert!(map.check_path(vector[vector[0, 0], vector[1, 0]]) == false);
    assert!(map.check_path(vector[vector[1, 0], vector[0, 0]]) == false);

    // try going down, right and then back-up; then reverse
    assert!(map.check_path(vector[vector[0, 0], vector[0, 1], vector[1, 1], vector[1, 0]]) == true);
    assert!(map.check_path(vector[vector[1, 0], vector[1, 1], vector[0, 1], vector[0, 0]]) == true);

    let mut map = Self::new(3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: false, right: false, top: false, bottom: true };

    // try going down and then back-up
    assert!(map.check_path(vector[vector[0, 0], vector[0, 1]]) == false);
    assert!(map.check_path(vector[vector[0, 1], vector[0, 0]]) == false);

    // try going right, down and then back-left; then reverse
    assert!(map.check_path(vector[vector[0, 0], vector[1, 0], vector[1, 1], vector[0, 1]]) == true);
    assert!(map.check_path(vector[vector[0, 1], vector[1, 1], vector[1, 0], vector[0, 0]]) == true);
}
