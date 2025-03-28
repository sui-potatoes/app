// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines the game `Map` - a grid of tiles where the game takes place. Map is
/// the most important component of the game, which provides direct access to
/// the stored data and objects and is used by game logic.
///
/// Traits:
/// - from_bcs
/// - to_string
module commander::map;

use commander::{history::{Self, Record}, recruit::Recruit, unit::{Self, Unit}};
use grid::{grid::{Self, Grid}, point};
use std::string::String;
use sui::{bcs::{Self, BCS}, random::RandomGenerator};

/// Attempt to place a `Recruit` on a tile that already has a unit.
const EUnitAlreadyOnTile: u64 = 1;
/// Attempt to place a `Recruit` on an unwalkable tile.
const ETileIsUnwalkable: u64 = 2;
/// The path is unwalkable.
const EPathUnwalkable: u64 = 3;
/// The path is incorrect: skipping tiles or standing still.
const EIncorrectPath: u64 = 4;
/// The unit is not on the tile.
const ENoUnit: u64 = 5;
/// The path is too short.
const EPathTooShort: u64 = 6;
/// The tile is out of bounds.
const ETileOutOfBounds: u64 = 7;

#[allow(unused_const)]
/// Constant for no cover in the `TileType::Cover`.
const NO_COVER: u8 = 0;
#[allow(unused_const)]
/// Constant for low cover in the `TileType::Cover`.
const LOW_COVER: u8 = 1;
/// Constant for high cover in the `TileType::Cover`.
const HIGH_COVER: u8 = 2;

/// The range of the grenade.
const GRENADE_RANGE: u16 = 5;

/// Defines a single Tile in the game `Map`. Tiles can be empty, provide cover
/// or be unwalkable. Additionally, a unit standing on a tile effectively makes
/// it unwalkable.
public struct Tile has store {
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
        left: u8,
        top: u8,
        right: u8,
        bottom: u8,
    },
    /// Certain tiles cannot be walked on, like walls or water.
    Unwalkable,
}

/// Defines the game Map - a grid of tiles where the game takes place.
public struct Map has store {
    /// The unique identifier of the map.
    id: ID,
    /// The grid of tiles.
    grid: Grid<Tile>,
    /// The current turn number.
    turn: u16,
}

public fun new(id: ID, size: u16): Map {
    Map {
        id,
        turn: 0,
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

/// Default Map is 30x30 tiles for now. Initially empty.
public fun default(id: ID): Map { new(id, 30) }

// === Actions ===

/// Place a `Recruit` on the map at the given position.
public fun place_recruit(map: &mut Map, recruit: &Recruit, x: u16, y: u16): Record {
    let target_tile = &map.grid[x, y];

    assert!(target_tile.unit.is_none(), EUnitAlreadyOnTile);
    assert!(target_tile.tile_type != TileType::Unwalkable, ETileIsUnwalkable);

    map.grid[x, y].unit.fill(recruit.to_unit());
    history::new_recruit_placed(x, y)
}

/// Proceed to the next turn.
public fun next_turn(map: &mut Map): Record {
    map.turn = map.turn + 1;
    history::new_next_turn(map.turn)
}

/// Reload the unit's weapon. It costs 1 AP.
public fun perform_reload(map: &mut Map, x: u16, y: u16): Record {
    assert!(map.grid[x, y].unit.is_some(), ENoUnit);
    let unit = map.grid[x, y].unit.borrow_mut();
    unit.try_reset_ap(map.turn);
    unit.perform_reload();

    history::new_reload(x, y)
}

/// Move a unit along the path. The first point is the current position of the unit.
public fun move_unit(map: &mut Map, path: vector<vector<u16>>): Record {
    assert!(path.length() > 1, EPathTooShort);

    let distance = path.length() - 1;
    let (first, last) = (path[0], path[distance]);
    let (x0, y0) = (first[0], first[1]);
    let (x1, y1) = (last[0], last[1]);
    let (width, height) = (map.grid.width(), map.grid.height());

    assert!(y0 < height && x0 < width, ETileOutOfBounds);
    assert!(y1 < height && x1 < width, ETileOutOfBounds);
    assert!(map.check_path(path), EPathUnwalkable);

    // transfer the unit from one position to another
    let mut unit = map.grid[x0, y0].unit.extract();
    unit.try_reset_ap(map.turn);
    unit.perform_move(distance as u8);
    map.grid[x1, y1].unit.fill(unit);

    history::new_move(path)
}

#[allow(lint(public_random))]
/// Perform a ranged attack.
///
/// TODO: cover mechanic, provide `DEF` stat based on the direction of the
///     attack and the relative position of the attacker and the target.
public fun perform_attack(
    map: &mut Map,
    rng: &mut RandomGenerator,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
): vector<Record> {
    let mut history = vector[history::new_attack(vector[x0, y0], vector[x1, y1])];
    let attacker = &mut map.grid[x0, y0].unit;
    assert!(attacker.is_some(), ENoUnit);

    let unit = attacker.borrow_mut();
    unit.try_reset_ap(map.turn);

    let range = grid::range!(x0, y0, x1, y1) as u8;
    let (is_hit, _, is_crit, damage, _) = unit.perform_attack(rng, range);
    let target = &mut map.grid[x1, y1].unit;
    assert!(target.is_some(), ENoUnit);

    let mut target = target.extract();
    let (is_dodged, damage, is_kia) = if (is_hit && damage > 0) {
        target.apply_damage(rng, damage, true)
    } else (false, 0, false);

    if (is_dodged) history.push_back(history::new_dodged());
    if (is_hit) {
        history.push_back({
            if (is_crit) history::new_critical_hit(damage)
            else history::new_damage(damage)
        })
    } else history.push_back(history::new_miss());

    if (is_kia) history.push_back(history::new_kia(target.destroy()))
    else map.grid[x1, y1].unit.fill(target);

    history
}

#[allow(lint(public_random))]
/// Throw a grenade. This action costs 1AP, deals area damage and destroys
/// covers in the area of effect (currently 3x3).
public fun perform_grenade(
    map: &mut Map,
    rng: &mut RandomGenerator,
    x: u16,
    y: u16,
    x1: u16,
    y1: u16,
): vector<Record> {
    let radius = 2; // 5x5 area of effect
    let unit = &mut map.grid[x, y].unit;
    assert!(grid::range!(x, y, x1, y1) <= GRENADE_RANGE, EPathTooShort);
    assert!(unit.is_some(), ENoUnit);

    // update unit's stats
    let unit = unit.borrow_mut();
    unit.try_reset_ap(map.turn);
    unit.perform_grenade();

    // update each tile: Cover -> Empty
    let mut history = vector[history::new_grenade(x1, y1, radius)];
    let mut points = map.grid.von_neumann!(point::new(x1, y1), radius);

    points.push_back(point::new(x1, y1));
    points.do!(|p| {
        let (x, y) = p.to_values();
        let tile = &mut map.grid[x, y];

        if (tile.unit.is_some()) {
            let mut unit = tile.unit.extract();
            let (_, dmg, is_kia) = unit.apply_damage(rng, 4, false);

            history.push_back(history::new_damage(dmg));

            if (!is_kia) tile.unit.fill(unit)
            else history.push_back(history::new_kia(unit.destroy()));
        };

        match (tile.tile_type) {
            TileType::Cover { .. } => tile.tile_type = TileType::Empty,
            _ => (),
        };
    });

    history
}

/// Get the current turn number.
public fun turn(map: &Map): u16 { map.turn }

/// Read the Unit at the given position.
public fun unit(map: &Map, x: u16, y: u16): &Option<Unit> {
    &map.grid[x, y].unit
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

/// Alias to support the `Grid.to_string` method.
public use fun tile_to_string as Tile.to_string;

/// Print the `Tile` as a `String`. Used in the `Grid.to_string!()` macro.
public fun tile_to_string(tile: &Tile): String {
    match (tile.tile_type) {
        TileType::Empty => b"     ".to_string(),
        TileType::Cover { left, right, top, bottom } => {
            let mut str = b"".to_string();
            str.append(left.to_string());
            str.append(top.to_string());
            str.append(right.to_string());
            str.append(bottom.to_string());

            if (tile.unit.is_some()) str.append_utf8(b"U")
            else str.append_utf8(b"-");
            str
        },
        TileType::Unwalkable => b" XXX ".to_string(),
    }
}

/// Check if the given path is walkable. Can be an optimization for pathfinding,
/// if the path is traced on the frontend.
public fun check_path(map: &Map, path: vector<vector<u16>>): bool {
    let mut prev = path[0];
    let high_cover = HIGH_COVER;

    'path: {
        path.do!(|step| {
            if (prev == step) return;
            let (x0, y0) = (prev[0], prev[1]);
            let (x1, y1) = (step[0], step[1]);

            let source = &map.grid[x0, y0];
            let target = &map.grid[x1, y1];
            if (target.unit.is_some()) return 'path false;
            if (target.tile_type == TileType::Unwalkable) return 'path false;

            // make sure that the path is not skipping tiles and is not repeating
            // the same tile
            assert!(x0.diff(x1) == 1 && y0 == y1 || y0.diff(y1) == 1 && x0 == x1, EIncorrectPath);

            prev = step;

            // UP
            if (grid::is_up!(x0, y0, x1, y1)) {
                match (&source.tile_type) {
                    TileType::Cover { top, .. } if (top == &high_cover) => return 'path false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { bottom, .. } if (bottom == &high_cover) => return 'path false,
                    _ => (),
                };
            };

            // DOWN
            if (grid::is_down!(x0, y0, x1, y1)) {
                match (&source.tile_type) {
                    TileType::Cover { bottom, .. } if (bottom == &high_cover) => return 'path false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { top, .. } if (top == &high_cover) => return 'path false,
                    _ => (),
                };
            };

            // LEFT
            if (grid::is_left!(x0, y0, x1, y1)) {
                match (&source.tile_type) {
                    TileType::Cover { left, .. } if (left == &high_cover) => return 'path false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { right, .. } if (right == &high_cover) => return 'path false,
                    _ => (),
                };
            };

            // RIGHT
            if (grid::is_right!(x0, y0, x1, y1)) {
                match (&source.tile_type) {
                    TileType::Cover { right, .. } if (right == &high_cover) => return 'path false,
                    _ => (),
                };

                match (&target.tile_type) {
                    TileType::Cover { left, .. } if (left == &high_cover) => return 'path false,
                    _ => (),
                };
            }
        });

        true
    }
}

// === Map Presets ===

/// Creates a demo map #1.
///
/// - Map: 01 - 7x7 LEGO prototype.
/// - Unit positions: (0, 3), (1, 6), (6, 5)
/// - Goal: close encounter with low and high cover to test line of sight and cover mechanics.
/// - Schema:
///
/// ```
/// |     |     |2002-|0001-|0002-|     |     |
/// | XXX |     |     |     |     |     |     |
/// |     |     |     |     |     |0001-|0001-|
/// |0100-|0210-|     | XXX |     |1000-|1000-|
/// |0001-|0012-|     |     |     |     |     |
/// |     |     |     |     |     |     |     |
/// |     | XXX |     |     |1100-|0100-|0110-|
/// ```
public fun demo_1(id: ID): Map {
    let mut preset_bytes = bcs::to_bytes(&id);
    // prettier-ignore
    preset_bytes.append(x"0707000000000102000002000100000001000100000002000000000007020000000000000000000000000007000000000000000000000100000001000100000001000701000100000001000102000000000200000001010000000001010000000007010000000100010001000200000000000000000000000700000000000000000000000000000700000200000000000101010000000100010000000100010100000000");
    from_bytes(preset_bytes)
}

/// Creates a demo map #2.
public fun demo_2(id: ID): Map {
    // prettier-ignore
    let mut map = from_bytes(x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000101000001000100000001000100000101000000000001010000010001000000010001000001010000000a00000000000000000000000000000000000000000a00000200020002000000000002000200020000000a000001010000010000000100000101000000000000000200000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a010202000000010001000000010001000000010002020000000000000101020000000100010000000100010000000100020200000a01020000000000000000010000010000000000000000000000000100000200000a0102000002000100000002000100000002000100000002000100000002000100000002000100000002000100000002000100000002000100000202000000");
    map.id = id;
    map
}

// === Compatibility / Conversion ===

/// Deserializes the `Map` from the given bytes.
public fun from_bytes(bytes: vector<u8>): Map {
    from_bcs(&mut bcs::new(bytes))
}

/// Deserialize the `Map` from the `BCS` instance.
public(package) fun from_bcs(bcs: &mut BCS): Map {
    let id = bcs.peel_address().to_id();
    let grid = grid::from_bcs!(bcs, |bcs| {
        Tile {
            tile_type: match (bcs.peel_u8()) {
                0 => TileType::Empty,
                1 => TileType::Cover {
                    left: bcs.peel_u8(),
                    top: bcs.peel_u8(),
                    right: bcs.peel_u8(),
                    bottom: bcs.peel_u8(),
                },
                2 => TileType::Unwalkable,
                _ => abort,
            },
            unit: bcs.peel_option!(|bcs| unit::from_bcs(bcs)),
        }
    });

    Map { id, turn: 0, grid }
}

/// Implements the `Grid.to_string` method due to `Tile` implementing
/// `to_string` too.
public fun to_string(map: &Map): String {
    map.grid.to_string!()
}

#[test_only]
public fun debug(map: &Map) {
    std::debug::print(&map.to_string())
}

#[test_only]
public fun destroy(map: Map) {
    sui::test_utils::destroy(map)
}

#[test]
// Map in this test is 3x3
//
// First (high cover):
//  o| o  o
//  o  o  o
//  o  o  o
//
// Second (high cover):
//  _  o  o
//  o  o  o
//  o  o  o
//
// Third (low cover):
// _| _ |_
// o| o |o
// o| o |o
fun test_check_path() {
    let mut map = Self::new(@1.to_id(), 3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: NO_COVER, right: HIGH_COVER, top: NO_COVER, bottom: NO_COVER };

    // try going right and then back-left
    assert!(!map.check_path(vector[vector[0, 0], vector[0, 1]]));
    assert!(!map.check_path(vector[vector[0, 1], vector[0, 0]]));

    // try going down, right and then back-up; then reverse
    assert!(
        map.check_path(vector[
            /* start */ vector[0, 0],
            /* down  */ vector[1, 0],
            /* right */ vector[1, 1],
            /* left  */ vector[1, 0],
        ]),
    );
    assert!(
        map.check_path(vector[
            /* start */ vector[0, 1],
            /* down  */ vector[1, 1],
            /* left  */ vector[1, 0],
            /* up    */ vector[0, 0],
        ]),
    );
    map.destroy();

    let mut map = Self::new(@1.to_id(), 3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: NO_COVER, right: NO_COVER, top: NO_COVER, bottom: HIGH_COVER };

    // try going down and then back-up
    assert!(!map.check_path(vector[vector[0, 0], /* down */ vector[1, 0]]));
    assert!(!map.check_path(vector[vector[1, 0], /* up   */ vector[0, 0]]));

    // try going right, down and then back-left; then reverse
    assert!(
        map.check_path(vector[
            /* start */ vector[0, 0],
            /* right */ vector[0, 1],
            /* down  */ vector[1, 1],
            /* left  */ vector[1, 0],
        ]),
    );

    assert!(
        map.check_path(vector[
            /* start */ vector[1, 0],
            /* right */ vector[1, 1],
            /* up    */ vector[0, 1],
            /* left  */ vector[0, 0],
        ]),
    );

    // crawl over the cover
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover {
            left: NO_COVER,
            right: LOW_COVER,
            top: NO_COVER,
            bottom: LOW_COVER,
        };

    *&mut map.grid[0, 1].tile_type =
        TileType::Cover {
            left: LOW_COVER,
            right: NO_COVER,
            top: NO_COVER,
            bottom: LOW_COVER,
        };

    *&mut map.grid[0, 2].tile_type =
        TileType::Cover {
            left: LOW_COVER,
            right: NO_COVER,
            top: LOW_COVER,
            bottom: NO_COVER,
        };

    map.destroy();
}

#[test]
fun test_map_with_units() {
    use sui::random;
    use commander::recruit;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[2]);
    let recruit_one = recruit::default(ctx);
    let recruit_two = recruit::default(ctx);

    let mut map = Self::new(@1.to_id(), 6);

    assert!(!map.tile_has_unit(3, 3));
    assert!(!map.tile_has_unit(5, 2));

    map.place_recruit(&recruit_one, 3, 3);
    map.place_recruit(&recruit_two, 5, 2);

    assert!(map.tile_has_unit(3, 3));
    assert!(map.tile_has_unit(5, 2));

    // | | | | | | |
    // | | | | | | |
    // | | | | | |5|
    // | | | |5| | |
    // | | | | | | |
    // | | | | | | |

    // now try to attack another unit with the first one
    let mut damage = 0;
    map.grid[3, 3].unit.do_mut!(|unit| (_, _, _, damage, _) = unit.perform_attack(&mut rng, 4));

    // apply the damage to the second unit
    map.grid[5, 2].unit.borrow_mut().apply_damage(&mut rng, damage, false);

    let (weapon, armor) = recruit_one.dismiss();
    weapon.destroy!(|w| w.destroy());
    armor.destroy!(|a| a.destroy());

    let (weapon, armor) = recruit_two.dismiss();
    weapon.destroy!(|w| w.destroy());
    armor.destroy!(|a| a.destroy());

    map.destroy();
}
