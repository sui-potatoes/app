// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: commander
module commander::commander;

use commander::unit::{Self, Unit};
use grid::{grid::{Self, Grid}, point::Point};
use std::string::String;

public struct Game has key, store {
    id: UID,
    /// The current turn number. Starts at 0.
    turn: Team,
    /// Number of the current turn.
    current_turn: u16,
    /// The map of the game. Contains tiles with units, barricades, or empty tiles.
    map: Grid<Tile>,
}

/// A tile on the map. Tiles can be either empty or contain a unit. Every object
/// in the `Game` is a `Unit` including obstacles, terrain types and actual
/// actionable units.
public enum Tile has copy, store, drop {
    Empty,
    Unit(Unit, Team),
}

/// A team in the game. Teams can be neutral, red, or blue. Neutral teams are
/// typically used for obstacles or terrain types. Red and blue teams are used
/// for player units.
public enum Team has copy, store, drop {
    Neutral,
    Red,
    Blue,
}

/// Create a new `Game`, the current turn set to `Team::Red`, and the map is
/// initialized with empty tiles.
public fun new(width: u16, height: u16, ctx: &mut TxContext): Game {
    Game {
        id: object::new(ctx),
        turn: Team::Red,
        current_turn: 0,
        map: grid::tabulate!(width, height, |_, _| Tile::Empty),
    }
}

/// Create a new `Game` with a preset map.
public fun preset(ctx: &mut TxContext): Game {
    let mut game = Game {
        id: object::new(ctx),
        turn: Team::Red,
        current_turn: 0,
        map: grid::tabulate!(8, 5, |_, _| Tile::Empty),
    };

    // Now create a `Unit` and place it on the map.
    *&mut game.map[1, 2] = Tile::Unit(unit::sniper(), Team::Red);

    // Protect it with some barricades.
    *&mut game.map[2, 1] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[2, 2] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[2, 3] = Tile::Unit(unit::barricade(), Team::Neutral);

    // Place barricades in the middle of the map.
    *&mut game.map[5, 0] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[5, 1] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[5, 3] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[5, 4] = Tile::Unit(unit::barricade(), Team::Neutral);

    // Place soldiers on the map.
    *&mut game.map[7, 1] = Tile::Unit(unit::soldier(), Team::Red);
    *&mut game.map[7, 2] = Tile::Unit(unit::soldier(), Team::Red);
    *&mut game.map[7, 3] = Tile::Unit(unit::soldier(), Team::Red);

    game
}

// === Editing (Sandbox features) ===

/// Place a unit on an empty `Tile`.
public fun place_unit(game: &mut Game, x: u16, y: u16, unit: Unit, team: Team) {
    assert!(x < grid::width(&game.map) && y < grid::height(&game.map));
    assert!(game.map[x, y] == Tile::Empty);

    *&mut game.map[x, y] = Tile::Unit(unit, team);
}

/// Remove a unit from the map.
public fun remove_unit(game: &mut Game, x: u16, y: u16): Unit {
    assert!(x < grid::width(&game.map) && y < grid::height(&game.map));
    assert!(game.map[x, y] != Tile::Empty);

    match (game.map.swap(x, y, Tile::Empty)) {
        Tile::Unit(unit, _) => unit,
        _ => abort 0,
    }
}

// === Game features ===

/// Perform an action by a `Unit` located at `(x0, y0)` coordinates. Action idx is the ID of the
/// action in the unit's inventory. `(x1, y1)` are coordinates of the target - though they may be
/// optional for some actions (eg `Wait`), then a pair of 0,0 can be used.
public fun perform_action(game: &mut Game, x0: u16, y0: u16, action_idx: u16, x1: u16, y1: u16) {
    assert!(game.is_unit(x0, y0));

    // make sure there's a unit at the source location
    let (unit, _) = game.map[x0, y0].unit_mut();
    let action = unit.action(action_idx);

    // if the unit has already performed an action this turn, reset its AP
    if (unit.current_turn() < game.current_turn) {
        unit.ap_mut().reset();
        unit.set_turn(game.current_turn);
    };

    let unit_ap = unit.ap().value();

    // make sure the unit has enough AP to perform the action
    assert!(action.cost() <= unit_ap);
    // assert!(game.turn == team); // TODO: re-enable this check

    // if the action is move, check if the target tile is empty
    if (action.is_move()) {
        let max_range = unit_ap / action.cost();

        assert!(game.is_empty(x1, y1));
        assert!(grid::range(x0, y0, x1, y1) <= max_range);

        // if a path can be traced, move the unit
        let path = game.trace_path(max_range, x0, y0, x1, y1);

        assert!(path.is_some());

        let length = path.destroy_some().length() as u16;
        assert!(length <= max_range);

        let mut tile = game.map.swap(x0, y0, Tile::Empty);
        let (unit, _) = tile.unit_mut();
        unit.ap_mut().decrease((length as u16) * action.cost());
        let _ = game.map.swap(x1, y1, tile);
        return
    };

    // if the action is attack, check if the target is within range
    if (action.is_attack()) {
        let (max_range, damage) = action.attack_params();

        assert!(grid::range(x0, y0, x1, y1) <= max_range);
        assert!(game.is_unit(x1, y1));

        // decrease AP of the unit
        let (attacker, _) = game.map[x0, y0].unit_mut();
        attacker.ap_mut().decrease(action.cost());

        // decrease HP of the target. if health is 0, remove unit from the map
        let (target, _) = game.map[x1, y1].unit_mut();
        target.health_mut().decrease(damage);

        // remove the unit from the map if it's dead
        if (target.health().value() == 0) {
            let _ = game.map.swap(x1, y1, Tile::Empty);
        };
        return
    };

    // if the action is wait, decrease the AP of the unit by the cost of the action
    if (action.is_skip()) {
        let (unit, _) = game.map[x0, y0].unit_mut();
        unit.ap_mut().decrease(action.cost());
        return
    };
}

/// Move the game to the next turn.
public fun next_turn(game: &mut Game) {
    game.current_turn = game.current_turn + 1;
    match (game.turn) {
        Team::Red => game.turn = Team::Blue,
        Team::Blue => game.turn = Team::Red,
        _ => abort 0,
    }
}

/// Destroy a `Game` object.
public fun destroy(game: Game) {
    let Game { id, .. } = game;
    id.delete()
}

// === Querying ===

/// Create
public fun unit(tile: &Tile): (&Unit, Team) {
    match (tile) {
        Tile::Unit(unit, team) => (unit, *team),
        _ => abort 0,
    }
}

public fun unit_mut(tile: &mut Tile): (&mut Unit, Team) {
    match (tile) {
        Tile::Unit(unit, team) => (unit, *team),
        _ => abort 0,
    }
}

/// Check if a tile contains a unit.
public fun is_unit(game: &Game, x: u16, y: u16): bool {
    match (&game.map[x, y]) {
        Tile::Unit(_, _) => true,
        _ => false,
    }
}

/// Check if a tile is empty.
public fun is_empty(game: &Game, x: u16, y: u16): bool {
    match (&game.map[x, y]) {
        Tile::Empty => true,
        _ => false,
    }
}

// Alias the `tile_to_string` as `to_string` for public use.
public use fun tile_to_string as Tile.to_string;

/// Convert a tile to a `String` representation.
public fun tile_to_string(tile: &Tile): String {
    match (tile) {
        Tile::Empty => b"_".to_string(),
        Tile::Unit(unit, _) => unit.symbol(),
    }
}

/// Create a `Team::Red` marker to indicate the red team.
public fun team_red(): Team { Team::Red }

/// Create a `Team::Blue` marker to indicate the blue team.
public fun team_blue(): Team { Team::Blue }

/// Create a `Team::Neutral` marker to indicate a neutral team.
/// TODO: Neutral team cannot be controlled by any player.
public fun team_neutral(): Team { Team::Neutral }

// === Internal ===

/// Trace a path from one point to another. The path is traced using the
/// Von Neumann neighborhood. The path is traced until the destination is
/// reached or the maximum range is exceeded.
///
/// Used by the client in dry-run mode to visualize the path of a unit.
fun trace_path(
    game: &Game,
    max_range: u16,
    x0: u16,
    y0: u16,
    x1: u16,
    y1: u16,
): Option<vector<Point>> {
    game.map.trace!(x0, y0, x1, y1, max_range, |tile| {
        match (tile) {
            Tile::Empty => true,
            Tile::Unit(_, team) => team == game.turn,
        }
    })
}

#[test_only]
/// Debug function to print the map of the game to the console.
public fun debug(game: &Game) {
    std::debug::print(&game.map.to_string!());
}

#[test]
fun test_map() {
    //    0 1 2 3 4  Y
    // 0 |_|_|_|_|_|
    // 1 |_|_|L|_|_|
    // 2 |_|B|B|B|_|
    // 3 |_|_|_|_|_|
    // 4 |_|_|_|_|_|
    // 5 |B|B|_|B|B|
    // 6 |_|_|_|_|_|
    // 7 |_|S|S|S|_|
    // X
    //
    // L - Sniper
    // S - Soldier
    // B - Barricade

    // Create a 5x5 map with all empty tiles.
    let ctx = &mut tx_context::dummy();
    let mut game = Game {
        id: object::new(ctx),
        turn: Team::Red,
        current_turn: 0,
        map: grid::tabulate!(5, 8, |_, _| Tile::Empty),
    };

    // Now create a `Unit` and place it on the map.
    *&mut game.map[2, 1] = Tile::Unit(unit::sniper(), Team::Red);

    // Protect it with some barricades.
    *&mut game.map[1, 2] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[2, 2] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[3, 2] = Tile::Unit(unit::barricade(), Team::Neutral);

    // Place barricades in the middle of the map.
    *&mut game.map[0, 5] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[1, 5] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[3, 5] = Tile::Unit(unit::barricade(), Team::Neutral);
    *&mut game.map[4, 5] = Tile::Unit(unit::barricade(), Team::Neutral);

    // Place soldiers on the map.
    *&mut game.map[1, 7] = Tile::Unit(unit::soldier(), Team::Red);
    *&mut game.map[2, 7] = Tile::Unit(unit::soldier(), Team::Red);
    *&mut game.map[3, 7] = Tile::Unit(unit::soldier(), Team::Red);

    // game.debug();

    let path = game.trace_path(10, 1, 7, 1, 4);
    assert!(path.is_some());

    game.perform_action(1, 7, 0, 1, 4);
    game.perform_action(2, 7, 0, 2, 4);
    game.perform_action(3, 7, 0, 3, 4);

    // game.debug();

    // now sniper shoots and kills the soldier on the left
    game.perform_action(2, 1, 1, 1, 4);
    game.perform_action(2, 1, 1, 2, 4);

    // now sniper doesn't have any AP left
    let (unit, _) = game.map[2, 1].unit();
    assert!(unit.ap().value() == 0);

    // next turn, now sniper has full AP
    game.next_turn();

    // now sniper shoots and kills the soldier on the right
    game.perform_action(2, 1, 1, 3, 4);

    // game.debug();
    game.destroy();
}
