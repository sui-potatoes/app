// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[allow(unused_use)]
/// Simple Dungeon Crawler game, has levels and monsters at each level, randomly
/// distributed across the level.
///
/// ```
/// |#|#|#|D|#|#|#| Hero: Stranger
/// |#|M|_|_|_|t|#| Level: 1
/// |#|_|_|_|_|_|#| HP: 10/10
/// |D|_|_|_|_|_|D| Gold: 100
/// |#|_|_|_|_|_|#|
/// |#|t|_|H|_|#|#|
/// |#|#|#|D|#|#|#|
/// ```
///
/// ^ expected output when running tests.
module grid::dungeon;

use grid::{cursor::{Self, Cursor}, direction::{up, down, left, right}, grid::{Self, Grid}};
use std::string::String;
use sui::random::{Self, RandomGenerator};

/// The size of a single room.
const SIZE: u16 = 7;

/// For sake of simplicity, all rooms are 7x7, with walls on the edges. We don't
/// use any procedural generation, just create a square grid with doors in the
/// middle of each side.
///
/// |#|#|#|D|#|#|#|
/// |#|?|_|_|_|?|#|
/// |#|_|_|_|_|_|#|
/// |D|_|_|?|_|_|D|
/// |#|_|_|_|_|_|#|
/// |#|?|_|_|_|?|#|
/// |#|#|#|D|#|#|#|
///
public struct Room has drop, store {
    grid: Grid<Tile>,
}

/// The Dungeon object, contains the current level and already discovered rooms.
public struct Dungeon has key {
    id: UID,
    /// The hero's position in the current level.
    hero: Cursor,
    /// The current Room.
    room: Room,
}

///
public enum Tile has drop, store {
    Empty,
    /// The index of the room it leads to.
    Door(u8),
    Wall,
    /// Treasure and whether the treasure is already taken.
    Treasure(bool),
    /// Monster, for sake of simplicity, all monsters are the same.
    Monster,
    /// Hero's current position. Hero can only move to empty tiles and interact
    /// with adjacent tiles (including doors).
    Hero,
}

#[allow(lint(public_random))]
public fun new(rng: RandomGenerator, ctx: &mut TxContext): Dungeon {
    let mut room = new_room(rng);
    let (x, y) = (3, 5);

    // initial placement of the hero
    *&mut room.grid[y, x] = Tile::Hero;

    Dungeon {
        id: object::new(ctx),
        hero: cursor::new(y, x),
        room,
    }
}

/// Move the hero in the given direction.
public fun step(d: &mut Dungeon, direction: u8) {
    let (y0, x0) = d.hero.to_values();
    d.hero.move_to(direction);
    let (y1, x1) = d.hero.to_values();

    let hero_tile = d.room.grid.swap(y0, x0, Tile::Empty);
    assert!(&hero_tile == &Tile::Hero); // sanity check

    let replaced_tile = d.room.grid.swap(y1, x1, hero_tile);
    assert!(replaced_tile == Tile::Empty);
}

public fun destroy(d: Dungeon) {
    let Dungeon { id, .. } = d;
    id.delete();
}

/// Allows printing the `Tile` as a `String`, hence allowing `debug!` macro to
/// work.
public fun to_string(t: &Tile): String {
    match (t) {
        Tile::Empty => b"_",
        Tile::Door(_) => b"D",
        Tile::Wall => b"#",
        Tile::Treasure(taken) => if (*taken) b"T" else b"t",
        Tile::Monster => b"M",
        Tile::Hero => b"H",
    }.to_string()
}

// === Internal ===

fun new_room(mut rng: RandomGenerator): Room {
    let mut grid = grid::tabulate!(SIZE, SIZE, |row, col| {
        if (row == 0 || row == (SIZE - 1) || col == 0 || col == (SIZE - 1)) Tile::Wall
        else Tile::Empty
    });

    // set up doors
    *&mut grid[SIZE - 1, SIZE / 2] = Tile::Door(0);
    *&mut grid[SIZE / 2, 0] = Tile::Door(1);
    *&mut grid[0, SIZE / 2] = Tile::Door(2);
    *&mut grid[SIZE / 2, SIZE - 1] = Tile::Door(3);

    // place random elements in corners
    *&mut grid[1, 1] = random_element!(&mut rng);
    *&mut grid[SIZE - 2, 1] = random_element!(&mut rng);
    *&mut grid[1, SIZE - 2] = random_element!(&mut rng);
    *&mut grid[SIZE - 2, SIZE - 2] = random_element!(&mut rng);

    // and one random in the center
    *&mut grid[SIZE / 2, SIZE / 2] = random_element!(&mut rng);

    Room { grid }
}

macro fun random_element($rng: &mut RandomGenerator): Tile {
    let rng = $rng;
    match (rng.generate_u8_in_range(0, 5)) {
        3 => Tile::Treasure(false),
        4 => Tile::Monster,
        5 => Tile::Wall,
        _ => Tile::Empty,
    }
}

// === Tests ===

#[test_only]
public fun debug(d: &Dungeon) {
    let mut str = b"\n".to_string();
    let extra_content = vector[
        b"Hero: Stranger".to_string(),
        b"Level: 1".to_string(),
        b"HP: 10/10".to_string(),
        b"Gold: 100".to_string(),
    ];

    d.room.grid.traverse!(|e, (row, col)| {
        if (col == 0) str.append_utf8(b"|");
        str.append(e.to_string());
        str.append_utf8(b"|");

        if (col == 6) {
            if (row as u64 < extra_content.length()) {
                str.append_utf8(b" ");
                str.append(extra_content[row as u64]);
                str.append_utf8(b"\n");
            } else {
                str.append_utf8(b"\n");
            }
        };
    });

    std::debug::print(&str);
}

#[test]
fun test_dungeon() {
    let ctx = &mut tx_context::dummy();
    let rng = random::new_generator_from_seed_for_testing(b"seed");
    let mut d = new(rng, ctx);

    // d.debug();
    d.step(left!());

    // d.debug();

    // rooms can be rotated to create a new room
    d.room.grid.rotate(2);

    // d.debug();

    d.destroy();
}
