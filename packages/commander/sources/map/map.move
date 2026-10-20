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
use grid::{cell, cursor, grid::{Self, Grid}};
use std::string::String;
use sui::{bcs::{Self, BCS}, random::RandomGenerator};

/// Attempt to place a `Recruit` on a tile that already has a unit.
const EUnitAlreadyOnTile: u64 = 1;
/// Attempt to place a `Recruit` on an unwalkable tile.
const ETileIsUnwalkable: u64 = 2;
/// The path is unwalkable.
const EPathUnwalkable: u64 = 3;
/// The unit is not on the tile.
const ENoUnit: u64 = 5;
/// The path is too short.
const EPathTooShort: u64 = 6;
/// The tile is out of bounds.
const ETileOutOfBounds: u64 = 7;
/// Attempt to stand on or target a `Wall` tile.
const ETileIsWall: u64 = 8;
/// No line of sight (or throw) from the attacker to the target.
const ENoLineOfSight: u64 = 9;

#[allow(unused_const)]
/// Constant for no cover in the `TileType::Cover`.
const NO_COVER: u8 = 0;
#[allow(unused_const)]
/// Constant for low cover in the `TileType::Cover`.
const LOW_COVER: u8 = 1;
/// Constant for high cover in the `TileType::Cover`.
const HIGH_COVER: u8 = 2;
/// Constant for the defense bonus.
const DEFENSE_BONUS: u8 = 25;

/// The range of the grenade.
const GRENADE_RANGE: u16 = 5;
/// The radius of the grenade explosion (von Neumann neighborhood).
const GRENADE_RADIUS: u16 = 2;
/// The damage the grenade deals to every unit in the area.
const GRENADE_DAMAGE: u8 = 4;

/// Defines a single Tile in the game `Map`. Tiles can be empty, provide cover
/// or be unwalkable. Additionally, a unit standing on a tile effectively makes
/// it unwalkable.
public struct Tile has copy, store {
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
    /// An empty tile that cannot be walked on, like water or a pit. Does not
    /// block line of sight and can be targeted by area weapons.
    Unwalkable,
    /// A solid tile: cannot be walked on, cannot be targeted and blocks line
    /// of sight. A dead zone for both movement and aiming.
    Wall,
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

/// Destroy the `Map` struct, returning the IDs of the units on the map.
public fun destroy(map: Map): vector<ID> {
    let Map { grid, .. } = map;
    let mut units = vector[];
    grid.destroy!(|Tile { unit, .. }| unit.destroy!(|unit| units.push_back(unit.destroy())));
    units
}

/// Get the ID of the map.
public fun id(map: &Map): ID { map.id }

/// Set the ID of the map.
public(package) fun set_id(map: &mut Map, id: ID) { map.id = id; }

/// Clone the `Map`.
public(package) fun clone(map: &Map): Map { Map { id: map.id, turn: map.turn, grid: map.grid } }

// === Actions ===

/// Place a `Recruit` on the map at the given position.
public fun place_recruit(map: &mut Map, recruit: &Recruit, x: u16, y: u16): Record {
    let target_tile = &map.grid[x, y];

    assert!(target_tile.unit.is_none(), EUnitAlreadyOnTile);
    assert!(target_tile.tile_type != TileType::Unwalkable, ETileIsUnwalkable);
    assert!(target_tile.tile_type != TileType::Wall, ETileIsWall);

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

/// Move a unit along the path. The first cell is the current position of the unit.
public fun move_unit(map: &mut Map, path: vector<u8>): Record {
    assert!(path.length() > 2, EPathTooShort);

    let distance = path.length() - 2;
    let (x0, y0) = (path[0] as u16, path[1] as u16);
    let (rows, cols) = (map.grid.rows(), map.grid.cols());

    assert!(x0 < rows && y0 < cols, ETileOutOfBounds);
    let search = map.check_path(path).destroy_or!(abort EPathUnwalkable);
    let (x1, y1) = (search[0], search[1]);
    assert!(x1 < rows && y1 < cols, ETileOutOfBounds);

    let mut unit = map.grid[x0, y0].unit.extract();
    unit.try_reset_ap(map.turn);
    unit.perform_move(distance as u8);
    map.grid[x1, y1].unit.fill(unit);

    history::new_move(path)
}

#[allow(lint(public_random))]
/// Perform a ranged attack from `(x0, y0)` at `(x1, y1)`.
///
/// The hit chance is the attacker's aim adjusted for range, minus the target's
/// defense. With a single-target weapon (`area_size` of 0) the target tile must
/// hold a unit, and the defense is the directional cover bonus plus the
/// target's natural `defense` stat. With an area weapon (`area_size` above 0)
/// the target is any tile but a `Wall`, defense does not apply, and a hit
/// explodes with the radius `area_size` (see `explode`). The weapon's
/// `can_be_dodged` stat decides whether the damage can be dodged. Either way
/// the attacker needs a line of sight to the target (see `line_of_sight`).
///
/// Records: `Attack`, then `Miss`; or for a single target `[Dodged]`,
/// `Damage` / `CriticalHit`, `[UnitKIA]`; or for an area weapon the records
/// of `explode`.
public fun perform_attack(
    map: &mut Map,
    rng: &mut RandomGenerator,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
): vector<Record> {
    let mut history = vector[history::new_attack(vector[x0, y0], vector[x1, y1])];
    let range = grid::manhattan_distance!(x0, y0, x1, y1) as u8;

    let attacker = &map.grid[x0, y0].unit;
    assert!(attacker.is_some(), ENoUnit);

    let stats = attacker.borrow().stats();
    let radius = stats.area_size() as u16;
    let can_dodge = stats.can_be_dodged() != 0;
    let env_damage = stats.env_damage() != 0;

    // single target: the tile must hold a unit, whose cover and natural defense
    // lower the hit chance; an area weapon targets a tile and ignores both
    let target_defense = if (radius == 0) {
        let target = &map.grid[x1, y1].unit;
        assert!(target.is_some(), ENoUnit);
        let cover = if (range > 0) map.cover_bonus(x0, y0, x1, y1) else 0;
        let natural = target.borrow().stats().defense();
        ((cover as u16) + (natural as u16)).min(100) as u8
    } else {
        assert!(!map.is_tile_wall(x1, y1), ETileIsWall);
        0
    };

    assert!(map.line_of_sight(x0, y0, x1, y1), ENoLineOfSight);

    let unit = map.grid[x0, y0].unit.borrow_mut();
    unit.try_reset_ap(map.turn);

    let (is_hit, _, is_crit, damage, _) = unit.perform_attack(rng, range, target_defense);
    if (!is_hit) {
        history.push_back(history::new_miss());
        return history
    };

    if (radius > 0) {
        history.append(map.explode(rng, x1, y1, radius, damage, env_damage, can_dodge));
        return history
    };

    let mut target = map.grid[x1, y1].unit.extract();
    let (is_dodged, damage, is_kia) = if (damage > 0) {
        target.apply_damage(rng, damage, can_dodge)
    } else (false, 0, false);

    if (is_dodged) history.push_back(history::new_dodged());
    history.push_back({
        if (is_crit) history::new_critical_hit(damage) // same cost
        else history::new_damage(damage)
    });

    if (is_kia) history.push_back(history::new_kia(target.destroy()))
    else map.grid[x1, y1].unit.fill(target);

    history
}

/// Calculate the cover bonus for the given tile. The cover bonus is calculated
/// based on the direction of the attack and the type of cover on the tile.
///
/// - no cover - 0
/// - LOW_COVER - 25
/// - HIGH_COVER - 50
///
/// A `Wall` tile next to the target counts as high cover on that side.
public(package) fun cover_bonus(map: &Map, x0: u16, y0: u16, x1: u16, y1: u16): u8 {
    use grid::direction::{direction, none, up, down, left, right};

    let direction = direction!(x0, y0, x1, y1);
    let (up, down, left, right) = map.tile_cover!(x1, y1);

    // edge case: same tile, should never happen
    if (direction == none!()) return 0;

    // target tile cover type (does not check neighboring tiles with reverse defense)
    let cover_type = if (direction == up!()) {
        if (down != 0) down // target tile has cover
        else {
            let (top, _, _, _) = map.tile_cover!(x1 + 1, y1);
            top
        }
    } else if (direction == down!()) {
        if (up != 0) up
        else {
            let (_, bottom, _, _) = map.tile_cover!(x1 - 1, y1);
            bottom
        }
    } else if (direction == left!()) {
        if (right != 0) right
        else {
            let (_, _, left, _) = map.tile_cover!(x1, y1 + 1);
            left
        }
    } else if (direction == right!()) {
        if (left != 0) left
        else {
            let (_, _, _, right) = map.tile_cover!(x1, y1 - 1);
            right
        }
    } else if (direction == up!() | left!()) {
        let cover_type = down.max(right);
        if (cover_type  != 0) cover_type
        else {
            let (top, _, _, _) = map.tile_cover!(x1 + 1, y1);
            let (_, _, left, _) = map.tile_cover!(x1, y1 + 1);
            top.max(left)
        }
    } else if (direction == up!() | right!()) {
        let cover_type = down.max(left);
        if (cover_type != 0) cover_type
        else {
            let (top, _, _, _) = map.tile_cover!(x1 + 1, y1);
            let (_, _, _, right) = map.tile_cover!(x1, y1 - 1);
            top.max(right)
        }
    } else if (direction == down!() | left!()) {
        let cover_type = up.max(right);
        if (cover_type != 0) cover_type
        else {
            let (_, bottom, _, _) = map.tile_cover!(x1 - 1, y1);
            let (_, _, left, _) = map.tile_cover!(x1, y1 + 1);
            bottom.max(left)
        }
    } else if (direction == down!() | right!()) {
        let cover_type = up.max(left);
        if (cover_type != 0) cover_type
        else {
            let (_, bottom, _, _) = map.tile_cover!(x1 - 1, y1);
            let (_, _, _, right) = map.tile_cover!(x1, y1 - 1);
            bottom.max(right)
        }
    } else abort; // unreachable

    // cover enum is 0, 1, 2, so by multiplying it by 25 we get the value we
    // need; same, as if we matched it to 0, 25, 50
    cover_type * DEFENSE_BONUS
}

macro fun tile_cover($map: &Map, $x: u16, $y: u16): (u8, u8, u8, u8) {
    let map = $map;
    match (map.grid[$x, $y].tile_type) {
        TileType::Cover { left, right, top, bottom } => (top, bottom, left, right),
        TileType::Wall => (HIGH_COVER, HIGH_COVER, HIGH_COVER, HIGH_COVER),
        _ => (0, 0, 0, 0),
    }
}

#[allow(lint(public_random))]
/// Throw a grenade from `(x, y)` at `(x1, y1)`. This action costs 1 AP, deals
/// `GRENADE_DAMAGE` to every unit in the von Neumann neighborhood of radius
/// `GRENADE_RADIUS` around the target tile (a diamond), cannot be dodged, and
/// destroys covers in the area. The target tile must be reachable by a throw:
/// walls block it, covers do not (see `line_of_throw`).
///
/// Records: `Grenade`, then the records of `explode`.
public fun perform_grenade(
    map: &mut Map,
    rng: &mut RandomGenerator,
    x: u16,
    y: u16,
    x1: u16,
    y1: u16,
): vector<Record> {
    assert!(grid::manhattan_distance!(x, y, x1, y1) <= GRENADE_RANGE, EPathTooShort);
    assert!(!map.is_tile_wall(x1, y1), ETileIsWall);
    assert!(map.line_of_throw(x, y, x1, y1), ENoLineOfSight);
    let unit = &mut map.grid[x, y].unit;
    assert!(unit.is_some(), ENoUnit);

    // update unit's stats
    let unit = unit.borrow_mut();
    unit.try_reset_ap(map.turn);
    unit.perform_grenade();

    let mut history = vector[history::new_grenade(vector[x, y], vector[x1, y1])];
    history.append(map.explode(rng, x1, y1, GRENADE_RADIUS, GRENADE_DAMAGE, true, false));
    history
}

/// Apply area damage centered at `(x, y)`: every unit in the von Neumann
/// neighborhood of `radius` (center included) takes `damage`, reduced by its
/// armor and dodged only if `can_dodge`. With `env_damage`, covers in the area
/// are destroyed (`Cover` -> `Empty`). Shared by grenades and area weapons.
///
/// Records: `Explosion`, then `[Dodged]`, `Damage`, `[UnitKIA]` per unit in
/// the area. Tiles are visited in the order of `Grid.von_neumann_neighbors`
/// with the center tile last; a replay must walk them in the same order.
fun explode(
    map: &mut Map,
    rng: &mut RandomGenerator,
    x: u16,
    y: u16,
    radius: u16,
    damage: u8,
    env_damage: bool,
    can_dodge: bool,
): vector<Record> {
    let mut history = vector[history::new_explosion(x, y, radius)];
    let mut cells = map.grid.von_neumann_neighbors(cell::new(x, y), radius);

    cells.push_back(cell::new(x, y));
    cells.do!(|p| {
        let (x, y) = p.to_values();
        let tile = &mut map.grid[x, y];

        if (tile.unit.is_some()) {
            let mut unit = tile.unit.extract();
            let (is_dodged, dmg, is_kia) = unit.apply_damage(rng, damage, can_dodge);

            if (is_dodged) history.push_back(history::new_dodged());
            history.push_back(history::new_damage(dmg));

            if (!is_kia) tile.unit.fill(unit)
            else history.push_back(history::new_kia(unit.destroy()));
        };

        if (env_damage) {
            match (tile.tile_type) {
                TileType::Cover { .. } => tile.tile_type = TileType::Empty,
                _ => (),
            }
        };
    });

    history
}

/// Get the current turn number.
public fun turn(map: &Map): u16 { map.turn }

/// Get the size of the map as `(rows, cols)`.
public fun size(map: &Map): (u16, u16) { (map.grid.rows(), map.grid.cols()) }

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

/// Check if the given tile is a wall.
public fun is_tile_wall(map: &Map, x: u16, y: u16): bool {
    match (map.grid[x, y].tile_type) {
        TileType::Wall => true,
        _ => false,
    }
}

/// Check if the given tile can be walked on: neither `Unwalkable` nor `Wall`.
public fun is_tile_walkable(map: &Map, x: u16, y: u16): bool {
    match (map.grid[x, y].tile_type) {
        TileType::Unwalkable | TileType::Wall => false,
        _ => true,
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
            str.append_utf8(if (tile.unit.is_some()) b"U" else b"-");
            str
        },
        TileType::Unwalkable => b" XXX ".to_string(),
        TileType::Wall => b" ### ".to_string(),
    }
}

/// Check if the given path is walkable. Can be an optimization for pathfinding,
/// if the path is traced on the frontend.
///
/// Returns `None` if the path is not walkable, otherwise returns the end cell
/// of the path.
public fun check_path(map: &Map, mut path: vector<u8>): Option<vector<u16>> {
    path.reverse();

    // first two values are X and Y coordinates, the rest are directions
    let (x0, y0) = (path.pop_back(), path.pop_back());
    let mut cursor = cursor::new(x0 as u16, y0 as u16);
    let none = option::none();

    'path: {
        path.destroy!(|direction| {
            let (x0, y0) = cursor.to_values();
            cursor.move_to(direction);
            let (x1, y1) = cursor.to_values();

            // units, walls, unwalkable tiles and high covers block the path
            if (map.grid[x1, y1].unit.is_some()) return 'path none;
            if (!map.is_tile_walkable(x0, y0) || !map.is_tile_walkable(x1, y1)) return 'path none;
            if (map.is_edge_high_cover(x0, y0, direction)) return 'path none;
        });

        option::some(cursor.to_vector())
    }
}

// === Line of Sight ===

/// Check the line of sight for a shot from `(x0, y0)` to `(x1, y1)`: walls and
/// high covers block it, unwalkable tiles and units do not. See `trace_line`.
public fun line_of_sight(map: &Map, x0: u16, y0: u16, x1: u16, y1: u16): bool {
    map.trace_line(x0, y0, x1, y1, true)
}

/// Check the line of throw for a grenade from `(x0, y0)` to `(x1, y1)`: only
/// walls block it, a grenade flies over covers. See `trace_line`.
public fun line_of_throw(map: &Map, x0: u16, y0: u16, x1: u16, y1: u16): bool {
    map.trace_line(x0, y0, x1, y1, false)
}

/// Walk the segment between the centers of two tiles one edge at a time and
/// check that it is clear. Entering a `Wall` always blocks. With
/// `high_cover_blocks`, a high cover on either side of a crossed edge blocks
/// too, except on the edges touching the two end tiles: cover next to the
/// attacker or the target is cover, not a wall. `Unwalkable` tiles and units
/// never block. Where the segment passes exactly through a corner, it is
/// clear if either of the two orthogonal routes around the corner is clear.
///
/// The walk is the Amanatides-Woo grid traversal in unsigned integers: after
/// `i` row steps and `j` column steps the next row edge lies at
/// `(i + 0.5) / dx` of the segment and the next column edge at
/// `(j + 0.5) / dy`, compared as `(2i + 1) * dy` against `(2j + 1) * dx`.
/// It takes `dx + dy` steps with two tile reads each. The same edges are
/// visited from either end, so the result is symmetric: `a` sees `b` if and
/// only if `b` sees `a`.
fun trace_line(map: &Map, x0: u16, y0: u16, x1: u16, y1: u16, high_cover_blocks: bool): bool {
    use grid::direction::{up, down, left, right};

    let (dx, dy) = (x0.diff(x1) as u64, y0.diff(y1) as u64);
    let sx = if (x1 > x0) down!() else up!();
    let sy = if (y1 > y0) right!() else left!();
    let (mut x, mut y) = (x0, y0);
    let (mut i, mut j) = (0u64, 0u64);

    while (i < dx || j < dy) {
        let (t_row, t_col) = ((2 * i + 1) * dy, (2 * j + 1) * dx);

        if (t_row < t_col) {
            if (map.blocks_line(x, y, sx, x0, y0, x1, y1, high_cover_blocks)) return false;
            (x, y) = neighbor(x, y, sx);
            i = i + 1;
        } else if (t_col < t_row) {
            if (map.blocks_line(x, y, sy, x0, y0, x1, y1, high_cover_blocks)) return false;
            (x, y) = neighbor(x, y, sy);
            j = j + 1;
        } else {
            // corner: clear if either route around the vertex is clear
            let (ax, ay) = neighbor(x, y, sx);
            let (bx, by) = neighbor(x, y, sy);
            let via_row =
                !map.blocks_line(x, y, sx, x0, y0, x1, y1, high_cover_blocks)
                    && !map.blocks_line(ax, ay, sy, x0, y0, x1, y1, high_cover_blocks);
            let via_col =
                !map.blocks_line(x, y, sy, x0, y0, x1, y1, high_cover_blocks)
                    && !map.blocks_line(bx, by, sx, x0, y0, x1, y1, high_cover_blocks);

            if (!via_row && !via_col) return false;
            (x, y) = neighbor(ax, ay, sy);
            i = i + 1;
            j = j + 1;
        }
    };

    true
}

/// Whether crossing from `(x, y)` in `direction` blocks the line from
/// `(x0, y0)` to `(x1, y1)`: the tile entered is a `Wall`, or, with
/// `high_cover_blocks`, the edge has high cover on either side and touches
/// neither end tile.
fun blocks_line(
    map: &Map,
    x: u16,
    y: u16,
    direction: u8,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
    high_cover_blocks: bool,
): bool {
    let (nx, ny) = neighbor(x, y, direction);
    if (map.is_tile_wall(nx, ny)) return true;
    if (!high_cover_blocks) return false;

    let is_inner = !(x == x0 && y == y0) && !(nx == x1 && ny == y1);
    is_inner && map.is_edge_high_cover(x, y, direction)
}

/// Whether the edge between `(x, y)` and its neighbor in `direction` has high
/// cover on either of its sides. Shared by `check_path` and `trace_line`.
fun is_edge_high_cover(map: &Map, x: u16, y: u16, direction: u8): bool {
    use grid::direction::inverse;

    let (nx, ny) = neighbor(x, y, direction);
    map.side_cover(x, y, direction) == HIGH_COVER
        || map.side_cover(nx, ny, inverse!(direction)) == HIGH_COVER
}

/// Cover value of the side of the tile at `(x, y)` facing `direction`.
fun side_cover(map: &Map, x: u16, y: u16, direction: u8): u8 {
    use grid::direction::{up, down, left};

    match (map.grid[x, y].tile_type) {
        TileType::Cover { left: l, top, right, bottom } => {
            if (direction == up!()) top
            else if (direction == down!()) bottom
            else if (direction == left!()) l
            else right
        },
        _ => NO_COVER,
    }
}

/// The neighbor of `(x, y)` in `direction` (`up` is the previous row).
fun neighbor(x: u16, y: u16, direction: u8): (u16, u16) {
    use grid::direction::{up, down, left};

    if (direction == up!()) (x - 1, y) else if (direction == down!()) (x + 1, y) else if (
        direction == left!()
    ) (x, y - 1) else (x, y + 1)
}

// === Map Presets ===

/// Creates a demo map #1.
///
/// - Map: 01 - 7x7 LEGO prototype.
/// - Unit positions: (0, 3), (1, 6), (6, 5)
/// - Firing lane in the demo: (3, 1) <-> (0, 3)
/// - Goal: close encounter with low and high cover to test line of sight and cover mechanics.
/// - Schema:
///
/// ```
/// |     |     |2002-|0001-|0002-|     |     |
/// | XXX |     |     |     |     |     |     |
/// |     |     |     |     |     |0001-|0001-|
/// |0100-|0120-|     | XXX |     |1000-|1000-|
/// |0001-|0102-|     |     |     |     |     |
/// |     |     |     |     |     |     |     |
/// |     | XXX |     |     |1100-|0100-|0110-|
/// ```
public fun demo_1(id: ID): Map {
    let mut preset_bytes = bcs::to_bytes(&id);
    // prettier-ignore
    preset_bytes.append(x"070700000000010200000200010000000100010000000200000000000702000000000000000000000000000700000000000000000000010000000100010000000100070100010000000100010200000000020000000101000000000101000000000701000000010001000100020000000000000000000000070000000000000000000000000000070000020000000000010101000000010001000000010001010000000700070000");
    from_bytes(preset_bytes)
}

/// Creates a demo map #2.
public fun demo_2(id: ID): Map {
    // prettier-ignore
    let mut map = from_bytes(x"00000000000000000000000000000000000000000000000000000000000000000a0a00000000000000000000000000000000000000000a00000101000001000100000001000100000101000000000001010000010001000000010001000001010000000a00000000000000000000000000000000000000000a00000200020002000000000002000200020000000a000001010000010000000100000101000000000000000200000000000a00000000000000000000000000000000000000000a00000000000000000000000000000000000000000a010202000000010001000000010001000000010002020000000000000101020000000100010000000100010000000100020200000a01020000000000000000010000010000000000000000000000000100000200000a010200000200010000000200010000000200010000000200010000000200010000000200010000000200010000000200010000000200010000020200000a000a0000");
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
                3 => TileType::Wall,
                _ => abort,
            },
            unit: bcs.peel_option!(|bcs| unit::from_bcs(bcs)),
        }
    });
    let turn = bcs.peel_u16();

    Map { id, turn, grid }
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

#[test]
/// A - Attacker
/// Top-left corner - Target
/// ```
///    0  1  2
///  0 _|    A
///  1
///  2 A     A
/// ```
fun test_cover_system_a() {
    use std::unit_test::assert_eq;

    let (no, low, high) = (NO_COVER, LOW_COVER, HIGH_COVER);
    let mut map = new(@0.to_id(), 3);

    assert_eq!(map.cover_bonus(2, 0, 0, 0), 0); // attack up
    assert_eq!(map.cover_bonus(0, 2, 0, 0), 0); // attack left
    assert_eq!(map.cover_bonus(2, 2, 0, 0), 0); // attack up-right

    // top-left corner, protected by covers
    *&mut map.grid[0, 0].tile_type = TileType::Cover { right: low, bottom: low, left: no, top: no };

    assert_eq!(map.cover_bonus(2, 0, 0, 0), DEFENSE_BONUS); // attack up
    assert_eq!(map.cover_bonus(0, 2, 0, 0), DEFENSE_BONUS); // attack left
    assert_eq!(map.cover_bonus(2, 2, 0, 0), DEFENSE_BONUS); // attack up-right

    // replace the top-left cover with high cover
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { right: high, bottom: high, left: no, top: no };

    assert_eq!(map.cover_bonus(2, 0, 0, 0), 2 * DEFENSE_BONUS); // attack up
    assert_eq!(map.cover_bonus(0, 2, 0, 0), 2 * DEFENSE_BONUS); // attack left
    assert_eq!(map.cover_bonus(2, 2, 0, 0), 2 * DEFENSE_BONUS); // attack up-right

    // now remove the cover on the target tile, and place on neighboring tiles: to the right and bottom
    *&mut map.grid[0, 0].tile_type = TileType::Empty;
    *&mut map.grid[1, 0].tile_type = TileType::Cover { right: no, bottom: no, left: no, top: low };
    *&mut map.grid[0, 1].tile_type = TileType::Cover { right: no, bottom: no, left: low, top: no };

    assert_eq!(map.cover_bonus(2, 0, 0, 0), 1 * DEFENSE_BONUS); // attack up
    assert_eq!(map.cover_bonus(0, 2, 0, 0), 1 * DEFENSE_BONUS); // attack left
    assert_eq!(map.cover_bonus(2, 2, 0, 0), 1 * DEFENSE_BONUS); // attack up-right

    // replace one of the covers with high cover and attack diagonally
    *&mut map.grid[0, 1].tile_type = TileType::Cover { right: no, bottom: no, left: high, top: no };
    assert_eq!(map.cover_bonus(2, 2, 0, 0), 2 * DEFENSE_BONUS); // attack up-right

    map.destroy();
}

#[test]
/// A - Attacker
/// Bottom-right corner - Target
/// ```
///    0  1  2
///  0 A     A
///  1       _
///  2 A    |
/// ```
fun test_cover_system_b() {
    use std::unit_test::assert_eq;

    let (no, low, high) = (NO_COVER, LOW_COVER, HIGH_COVER);
    let mut map = new(@0.to_id(), 3);

    assert_eq!(map.cover_bonus(0, 2, 2, 2), 0); // attack down
    assert_eq!(map.cover_bonus(2, 0, 2, 2), 0); // attack right
    assert_eq!(map.cover_bonus(0, 0, 2, 2), 0); // attack down-right

    // top-left corner, protected by covers
    *&mut map.grid[2, 2].tile_type = TileType::Cover { right: no, bottom: no, left: low, top: low };

    assert_eq!(map.cover_bonus(0, 2, 2, 2), DEFENSE_BONUS); // attack down
    assert_eq!(map.cover_bonus(2, 0, 2, 2), DEFENSE_BONUS); // attack right
    assert_eq!(map.cover_bonus(0, 0, 2, 2), DEFENSE_BONUS); // attack down-right

    // replace the top-left cover with high cover
    *&mut map.grid[2, 2].tile_type =
        TileType::Cover { right: no, bottom: no, left: high, top: high };

    assert_eq!(map.cover_bonus(0, 2, 2, 2), 2 * DEFENSE_BONUS); // attack down
    assert_eq!(map.cover_bonus(2, 0, 2, 2), 2 * DEFENSE_BONUS); // attack right
    assert_eq!(map.cover_bonus(0, 0, 2, 2), 2 * DEFENSE_BONUS); // attack down-right

    // now remove the cover on the target tile, and place on neighboring tiles: to the right and bottom
    *&mut map.grid[2, 2].tile_type = TileType::Empty;
    *&mut map.grid[1, 2].tile_type = TileType::Cover { right: no, bottom: low, left: no, top: no };
    *&mut map.grid[2, 1].tile_type = TileType::Cover { right: low, bottom: no, left: no, top: no };

    assert_eq!(map.cover_bonus(2, 0, 2, 2), 1 * DEFENSE_BONUS); // attack right
    assert_eq!(map.cover_bonus(0, 2, 2, 2), 1 * DEFENSE_BONUS); // attack down
    assert_eq!(map.cover_bonus(0, 0, 2, 2), 1 * DEFENSE_BONUS); // attack down-right

    // replace one of the covers with high cover and attack diagonally
    *&mut map.grid[2, 1].tile_type = TileType::Cover { right: high, bottom: no, left: no, top: no };
    assert_eq!(map.cover_bonus(0, 0, 2, 2), 2 * DEFENSE_BONUS); // attack up-right

    map.destroy();
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
    use grid::direction::{up, down, left, right};

    let mut map = Self::new(@1.to_id(), 3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: NO_COVER, right: HIGH_COVER, top: NO_COVER, bottom: NO_COVER };

    // try going right and then back-left
    assert!(map.check_path(vector[0, 0, right!()]).is_none());
    assert!(map.check_path(vector[0, 1, left!()]).is_none());

    // try going down, right and then back-up; then reverse
    assert!(map.check_path(vector[0, 0, down!(), right!(), left!()]).is_some());
    assert!(map.check_path(vector[0, 1, down!(), left!(), up!()]).is_some());
    map.destroy();

    let mut map = Self::new(@1.to_id(), 3);
    *&mut map.grid[0, 0].tile_type =
        TileType::Cover { left: NO_COVER, right: NO_COVER, top: NO_COVER, bottom: HIGH_COVER };

    // try going down and then back-up
    assert!(map.check_path(vector[0, 0, down!()]).is_none());
    assert!(map.check_path(vector[1, 0, up!()]).is_none());

    // try going right, down and then back-left; then reverse
    assert!(map.check_path(vector[0, 0, right!(), down!(), left!()]).is_some());
    assert!(map.check_path(vector[1, 0, right!(), up!(), left!()]).is_some());

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
    map.grid[3, 3].unit.do_mut!(|unit| (_, _, _, damage, _) = unit.perform_attack(&mut rng, 4, 0));

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

#[test]
/// Walls block movement in and out, count as high cover for a neighbor, give
/// no cover as `Unwalkable`, and survive a BCS roundtrip.
fun test_wall() {
    use grid::direction::{down, right};
    use std::unit_test::assert_eq;

    let mut map = new(@0.to_id(), 3);
    *&mut map.grid[1, 1].tile_type = TileType::Wall;

    assert!(map.is_tile_wall(1, 1));
    assert!(!map.is_tile_unwalkable(1, 1));
    assert!(map.check_path(vector[0, 1, down!()]).is_none());
    assert!(map.check_path(vector[1, 0, right!()]).is_none());
    assert!(map.check_path(vector[0, 0, right!(), right!(), down!()]).is_some());

    // target (2, 1) attacked from (0, 1): the wall at (1, 1) is high cover
    assert_eq!(map.cover_bonus(0, 1, 2, 1), 2 * DEFENSE_BONUS);
    assert_eq!(map.cover_bonus(2, 0, 2, 1), 0); // attack from the side

    *&mut map.grid[1, 1].tile_type = TileType::Unwalkable;
    assert_eq!(map.cover_bonus(0, 1, 2, 1), 0);

    *&mut map.grid[1, 1].tile_type = TileType::Wall;
    let restored = from_bytes(bcs::to_bytes(&map));
    assert!(restored.is_tile_wall(1, 1));
    assert_eq!(map.to_string(), restored.to_string());

    restored.destroy();
    map.destroy();
}

#[test, expected_failure(abort_code = ETileIsWall)]
fun test_place_recruit_on_wall_fails() {
    let ctx = &mut tx_context::dummy();
    let recruit = commander::recruit::default(ctx);
    let mut map = new(@0.to_id(), 3);
    *&mut map.grid[1, 1].tile_type = TileType::Wall;
    map.place_recruit(&recruit, 1, 1);
    abort
}

#[test, expected_failure(abort_code = ETileIsWall)]
/// An area weapon cannot target a wall tile; checked before the roll.
fun test_area_attack_on_wall_fails() {
    use commander::{recruit, stats, weapon};

    let ctx = &mut tx_context::dummy();
    let mut rng = sui::random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = new(@0.to_id(), 3);
    *&mut map.grid[0, 2].tile_type = TileType::Wall;

    // default weapon with `area_size` 1 (radius 1)
    let mut recruit = recruit::default(ctx);
    let launcher = stats::new_unchecked(0x03_04_00_01_01_00_00_02_04 << (6 * 8));
    recruit.add_weapon(weapon::new(b"Launcher".to_string(), launcher, ctx));
    map.place_recruit(&recruit, 0, 0);
    map.perform_attack(&mut rng, 0, 0, 0, 2);
    abort
}

#[test_only]
fun cover(left: u8, top: u8, right: u8, bottom: u8): TileType {
    TileType::Cover { left, top, right, bottom }
}

#[test]
/// Line of sight: open map, walls, unwalkable tiles, covers on inner and end
/// edges, corners; every case checked from both ends.
fun test_line_of_sight() {
    let (no, low, high) = (NO_COVER, LOW_COVER, HIGH_COVER);
    let mut map = new(@0.to_id(), 5);

    // open map
    assert!(map.line_of_sight(0, 0, 4, 4) && map.line_of_sight(4, 4, 0, 0));
    assert!(map.line_of_sight(0, 0, 0, 4) && map.line_of_sight(0, 4, 0, 0));
    assert!(map.line_of_sight(0, 0, 4, 0) && map.line_of_sight(4, 0, 0, 0));
    assert!(map.line_of_sight(0, 0, 2, 4) && map.line_of_sight(2, 4, 0, 0));
    assert!(map.line_of_sight(1, 1, 1, 1));

    // a wall on the line blocks it, a wall next to the line does not
    *&mut map.grid[0, 2].tile_type = TileType::Wall;
    assert!(!map.line_of_sight(0, 0, 0, 4) && !map.line_of_sight(0, 4, 0, 0));
    assert!(!map.line_of_throw(0, 0, 0, 4) && !map.line_of_throw(0, 4, 0, 0));
    assert!(map.line_of_sight(1, 0, 1, 4) && map.line_of_sight(1, 4, 1, 0));

    // an unwalkable tile does not block
    *&mut map.grid[0, 2].tile_type = TileType::Unwalkable;
    assert!(map.line_of_sight(0, 0, 0, 4) && map.line_of_sight(0, 4, 0, 0));
    *&mut map.grid[0, 2].tile_type = TileType::Empty;

    // high cover on the edge between (0, 2) and (0, 3): blocks a line passing
    // through, is plain cover for a line starting or ending next to it, and a
    // grenade flies over it
    *&mut map.grid[0, 2].tile_type = cover(no, no, high, no);
    assert!(!map.line_of_sight(0, 0, 0, 4) && !map.line_of_sight(0, 4, 0, 0));
    assert!(map.line_of_sight(0, 2, 0, 4) && map.line_of_sight(0, 4, 0, 2));
    assert!(map.line_of_sight(0, 0, 0, 3) && map.line_of_sight(0, 3, 0, 0));
    assert!(map.line_of_throw(0, 0, 0, 4) && map.line_of_throw(0, 4, 0, 0));

    // declared on the other side of the same edge; low cover never blocks
    *&mut map.grid[0, 2].tile_type = TileType::Empty;
    *&mut map.grid[0, 3].tile_type = cover(high, no, no, no);
    assert!(!map.line_of_sight(0, 0, 0, 4) && !map.line_of_sight(0, 4, 0, 0));
    *&mut map.grid[0, 3].tile_type = cover(low, no, no, no);
    assert!(map.line_of_sight(0, 0, 0, 4) && map.line_of_sight(0, 4, 0, 0));
    *&mut map.grid[0, 3].tile_type = TileType::Empty;

    // the diagonal (0, 0) -> (2, 2) passes through two corners; one open
    // route around a corner is enough, two walls close it
    *&mut map.grid[0, 1].tile_type = TileType::Wall;
    assert!(map.line_of_sight(0, 0, 2, 2) && map.line_of_sight(2, 2, 0, 0));
    *&mut map.grid[1, 0].tile_type = TileType::Wall;
    assert!(!map.line_of_sight(0, 0, 2, 2) && !map.line_of_sight(2, 2, 0, 0));
    assert!(!map.line_of_sight(0, 0, 1, 1) && !map.line_of_sight(1, 1, 0, 0));
    *&mut map.grid[0, 1].tile_type = TileType::Empty;
    *&mut map.grid[1, 0].tile_type = TileType::Empty;

    // the same corner closed by high covers on the two inner edges; the
    // adjacent diagonal stays clear since all its edges touch an end tile
    *&mut map.grid[1, 0].tile_type = cover(no, no, high, no);
    assert!(map.line_of_sight(0, 0, 2, 2) && map.line_of_sight(2, 2, 0, 0));
    *&mut map.grid[0, 1].tile_type = cover(no, no, no, high);
    assert!(!map.line_of_sight(0, 0, 2, 2) && !map.line_of_sight(2, 2, 0, 0));
    assert!(map.line_of_sight(0, 0, 1, 1) && map.line_of_sight(1, 1, 0, 0));
    assert!(map.line_of_throw(0, 0, 2, 2) && map.line_of_throw(2, 2, 0, 0));
    *&mut map.grid[1, 0].tile_type = TileType::Empty;
    *&mut map.grid[0, 1].tile_type = TileType::Empty;

    // (0, 0) -> (1, 3) crosses the vertex shared by (0, 1), (0, 2), (1, 1), (1, 2)
    *&mut map.grid[1, 1].tile_type = TileType::Wall;
    assert!(map.line_of_sight(0, 0, 1, 3) && map.line_of_sight(1, 3, 0, 0));
    *&mut map.grid[0, 2].tile_type = TileType::Wall;
    assert!(!map.line_of_sight(0, 0, 1, 3) && !map.line_of_sight(1, 3, 0, 0));

    map.destroy();
}

#[test, expected_failure(abort_code = ENoLineOfSight)]
fun test_attack_without_line_of_sight_fails() {
    let ctx = &mut tx_context::dummy();
    let mut rng = sui::random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = new(@0.to_id(), 5);
    let (a, b) = (commander::recruit::default(ctx), commander::recruit::default(ctx));

    *&mut map.grid[0, 2].tile_type = TileType::Wall;
    map.place_recruit(&a, 0, 0);
    map.place_recruit(&b, 0, 4);
    map.perform_attack(&mut rng, 0, 0, 0, 4);
    abort
}

#[test, expected_failure(abort_code = ENoLineOfSight)]
fun test_grenade_without_line_of_throw_fails() {
    let ctx = &mut tx_context::dummy();
    let mut rng = sui::random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = new(@0.to_id(), 5);
    let recruit = commander::recruit::default(ctx);

    *&mut map.grid[0, 2].tile_type = TileType::Wall;
    map.place_recruit(&recruit, 0, 0);
    map.perform_grenade(&mut rng, 0, 0, 0, 4);
    abort
}
