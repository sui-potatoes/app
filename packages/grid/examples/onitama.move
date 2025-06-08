// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Demo implementation of the Onitama board game.
/// See https://en.wikipedia.org/wiki/Onitama for more information.
module grid::onitama;

use grid::{cursor, direction::{Self, up, down, left, right}, grid::{Self, Grid}};
use std::string::String;

const EIllegalMove: u64 = 1;

public enum Figure has store {
    BlueMaster,
    BlueStudent,
    RedMaster,
    RedStudent,
    None,
}

public struct Field has store {
    grid: Grid<Figure>,
    turn: bool,
    red_cards: vector<MoveCard>,
    blue_cards: vector<MoveCard>,
    next_card: Option<MoveCard>,
}

public enum MoveCard has store {
    Tiger,
    Dragon,
    Frog,
    Rabbit,
    Crab,
    Elephant,
    Goose,
    Rooster,
    Monkey,
    Mantis,
    Horse,
    Ox,
    Crane,
    Boar,
    Eel,
    Cobra,
}

public fun new(mut cards: vector<u8>): Field {
    let grid = grid::tabulate!(5, 5, |x, y| {
        if (x == 0 && y != 2) Figure::BlueStudent
        else if (x == 0 && y == 2) Figure::BlueMaster
        else if (x == 4 && y != 2) Figure::RedStudent
        else if (x == 4 && y == 2) Figure::RedMaster
        else Figure::None
    });

    assert!(cards.length() == 5);

    Field {
        grid,
        turn: true,
        red_cards: vector[card_from_index(cards.pop_back()), card_from_index(cards.pop_back())],
        blue_cards: vector[card_from_index(cards.pop_back()), card_from_index(cards.pop_back())],
        next_card: option::some(card_from_index(cards.pop_back())),
    }
}

public fun play(field: &mut Field, card_idx: u8, x0: u16, y0: u16, x1: u16, y1: u16) {
    let is_red = field.turn;

    let swap_card = field.next_card.extract();
    let stack = if (is_red) &mut field.red_cards else &mut field.blue_cards;

    stack.push_back(swap_card);

    let play_card = stack.swap_remove(card_idx as u64);
    let mut cursor = cursor::new(x0, y0);
    let moves = play_card.moves(is_red);
    let is_valid = moves.any!(|moves| {
        cursor.reset(x0, y0);
        'try: {
            moves.do_ref!(|direction| {
                if (!cursor.can_move_to(*direction)) return 'try false
                else cursor.move_to(*direction)
            });
            let (x, y) = cursor.to_values();
            x == x1 && y == y1
        }
    });

    assert!(is_valid, EIllegalMove);

    field.next_card.fill(play_card);

    let figure = field.grid.swap(x0, y0, Figure::None);

    match (&figure) {
        Figure::BlueMaster | Figure::BlueStudent => assert!(!is_red, EIllegalMove),
        Figure::RedMaster | Figure::RedStudent => assert!(is_red, EIllegalMove),
        _ => abort EIllegalMove,
    };

    let target = field.grid.swap(x1, y1, figure);

    match (target) {
        Figure::BlueMaster => assert!(is_red, EIllegalMove), // win
        Figure::BlueStudent => assert!(is_red, EIllegalMove),
        Figure::RedMaster => assert!(!is_red, EIllegalMove), // win
        Figure::RedStudent => assert!(!is_red, EIllegalMove),
        Figure::None => (),
    };

    field.turn = !field.turn;

    // if (!is_red) {};
}

public fun moves(card: &MoveCard, turn: bool): vector<vector<u8>> {
    let moves = match (card) {
        // DOWN | UPx2
        MoveCard::Tiger => vector[vector[down!()], vector[up!(), up!()]],
        // DOWN-LEFT | DOWN-RIGHT | UP, LEFTx2 | UP, RIGHTx2
        MoveCard::Dragon => vector[
            vector[down!() | left!()],
            vector[down!() | right!()],
            vector[up!() | left!(), left!()],
            vector[up!() | right!(), right!()],
        ],
        // LEFT | UP-LEFT | DOWN-RIGHT
        MoveCard::Frog => vector[
            vector[left!()],
            vector[up!() | left!()],
            vector[down!() | right!()],
        ],
        // DOWN-LEFT | UP-RIGHT | RIGHT
        MoveCard::Rabbit => vector[
            vector[down!() | left!()],
            vector[up!() | right!()],
            vector[right!()],
        ],
        // LEFTx2 | RIGHTx2 | UP
        MoveCard::Crab => vector[
            vector[left!(), left!()],
            vector[right!(), right!()],
            vector[up!()],
        ],
        // LEFT | RIGHT | UP-LEFT | UP-RIGHT
        MoveCard::Elephant => vector[
            vector[left!()],
            vector[right!()],
            vector[up!() | left!()],
            vector[up!() | right!()],
        ],
        // LEFT | RIGHT | UP-LEFT | DOWN-RIGHT
        MoveCard::Goose => vector[
            vector[left!()],
            vector[right!()],
            vector[up!() | left!()],
            vector[down!() | right!()],
        ],
        // LEFT | RIGHT | UP-RIGHT | DOWN-LEFT
        MoveCard::Rooster => vector[
            vector[left!()],
            vector[right!()],
            vector[up!() | right!()],
            vector[down!() | left!()],
        ],
        // UP-RIGHT | UP-LEFT | DOWN-RIGHT | DOWN-LEFT
        MoveCard::Monkey => vector[
            vector[up!() | right!()],
            vector[up!() | left!()],
            vector[down!() | right!()],
            vector[down!() | left!()],
        ],
        // UP-RIGHT | UP-LEFT | DOWN
        MoveCard::Mantis => vector[
            vector[up!() | right!()],
            vector[up!() | left!()],
            vector[down!()],
        ],
        // UP | DOWN | LEFT
        MoveCard::Horse => vector[vector[up!()], vector[down!()], vector[left!()]],
        // UP | DOWN | RIGHT
        MoveCard::Ox => vector[vector[up!()], vector[down!()], vector[right!()]],
        // UP | DOWN-LEFT | DOWN-RIGHT
        MoveCard::Crane => vector[
            vector[up!()],
            vector[down!() | left!()],
            vector[down!() | right!()],
        ],
        // LEFT | RIGHT | UP
        MoveCard::Boar => vector[vector[left!()], vector[right!()], vector[up!()]],
        // UP-LEFT | DOWN-LEFT | RIGHT
        MoveCard::Eel => vector[
            vector[up!() | left!()],
            vector[down!() | left!()],
            vector[right!()],
        ],
        // UP-RIGHT | DOWN-RIGHT | LEFT
        MoveCard::Cobra => vector[
            vector[up!() | right!()],
            vector[down!() | right!()],
            vector[left!()],
        ],
    };

    // inverse direction if it's the second player's turn
    if (turn) moves else moves.map!(|m| m.map!(|d| direction::inverse!(d)))
}

public fun card_from_index(idx: u8): MoveCard {
    match (idx) {
        0 => MoveCard::Tiger,
        1 => MoveCard::Dragon,
        2 => MoveCard::Frog,
        3 => MoveCard::Rabbit,
        4 => MoveCard::Crab,
        5 => MoveCard::Elephant,
        6 => MoveCard::Goose,
        7 => MoveCard::Rooster,
        8 => MoveCard::Monkey,
        9 => MoveCard::Mantis,
        10 => MoveCard::Horse,
        11 => MoveCard::Ox,
        12 => MoveCard::Crane,
        13 => MoveCard::Boar,
        14 => MoveCard::Eel,
        15 => MoveCard::Cobra,
        _ => abort,
    }
}

public use fun figure_to_string as Figure.to_string;

/// Print the figure as a string.
public fun figure_to_string(figure: &Figure): String {
    match (figure) {
        Figure::BlueMaster => b"B",
        Figure::BlueStudent => b"b",
        Figure::RedMaster => b"R",
        Figure::RedStudent => b"r",
        Figure::None => b" ",
    }.to_string()
}

public use fun card_to_string as MoveCard.to_string;
public fun card_to_string(card: &MoveCard): String {
    match (card) {
        MoveCard::Tiger => b"Tiger",
        MoveCard::Dragon => b"Dragon",
        MoveCard::Frog => b"Frog",
        MoveCard::Rabbit => b"Rabbit",
        MoveCard::Crab => b"Crab",
        MoveCard::Elephant => b"Elephant",
        MoveCard::Goose => b"Goose",
        MoveCard::Rooster => b"Rooster",
        MoveCard::Monkey => b"Monkey",
        MoveCard::Mantis => b"Mantis",
        MoveCard::Horse => b"Horse",
        MoveCard::Ox => b"Ox",
        MoveCard::Crane => b"Crane",
        MoveCard::Boar => b"Boar",
        MoveCard::Eel => b"Eel",
        MoveCard::Cobra => b"Cobra",
    }.to_string()
}

/// Print the field as a string.
public fun to_string(field: &Field): String {
    field.grid.to_string!()
}

#[test_only]
public fun debug(field: &Field) {
    field.grid.debug!();
}

#[test]
fun test_game() {
    use sui::test_utils::destroy;
    use std::unit_test::assert_eq;

    let use_debug = false;
    let mut field = new(vector[0, 1, 2, 3, 4]); // cards 0-4 are used

    if (use_debug) field.debug();

    assert!(field.turn); // is red

    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Tiger".to_string()));

    assert_eq!(field.red_cards[0].to_string(), b"Crab".to_string());

    // red left student goes up with Crab card
    field.play(0, 4, 0, 3, 0);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Crab".to_string()));
    if (use_debug) field.debug();

    assert_eq!(field.blue_cards[0].to_string(), b"Frog".to_string());

    // blue master goes forward left with Frog card
    field.play(0, 0, 2, 1, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Frog".to_string()));
    if (use_debug) field.debug();

    // central-right red student goes up 2 fields with Tiger card
    field.play(0, 4, 3, 2, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Tiger".to_string()));
    if (use_debug) field.debug();

    // blue master takes down student with Crab card
    field.play(0, 1, 3, 2, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Crab".to_string()));
    if (use_debug) field.debug();

    destroy(field)
}
