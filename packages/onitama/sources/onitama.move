// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: onitama
module onitama::onitama;

use grid::{grid::{Self, Grid}, point::{Self, Point}};
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
    let moves = play_card.moves(x0, y0, is_red);
    field.next_card.fill(play_card);

    assert!(moves.contains(&point::new(x1, y1)), EIllegalMove);

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

/// X is row, Y is column
/// 0, 0 is top left corner
/// 4, 4 is bottom right corner
public fun moves(card: &MoveCard, x: u16, y: u16, turn: bool): vector<Point> {
    match (card) {
        MoveCard::Tiger => {
            let mut moves = vector[];
            if (turn) {
                if (x <= 3) moves.push_back(point::new(x + 1, y)); // down
                if (x >= 2) moves.push_back(point::new(x - 2, y)); // up x2
            } else {
                if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
                if (x <= 2) moves.push_back(point::new(x + 2, y)); // down x2
            };
            moves
        },
        MoveCard::Dragon => {
            let mut moves = vector[];
            if (turn) {
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (x >= 1 && y >= 2) moves.push_back(point::new(x - 1, y - 2)); // up left x2
                if (x >= 1 && y <= 2) moves.push_back(point::new(x - 1, y + 2)); // up right x2
            } else {
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x <= 3 && y >= 2) moves.push_back(point::new(x + 1, y - 2)); // down left x2
                if (x <= 3 && y <= 2) moves.push_back(point::new(x + 1, y + 2)); // down right x2
            };
            moves
        },
        MoveCard::Frog => {
            let mut moves = vector[];
            if (turn) {
                if (y >= 2) moves.push_back(point::new(x, y - 2)); // left
                if (y >= 1 && x >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (y <= 3 && x <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
            } else {
                if (y <= 2) moves.push_back(point::new(x, y + 2)); // right
                if (y <= 3 && x <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (y >= 1 && x >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
            };
            moves
        },
        MoveCard::Rabbit => {
            let mut moves = vector[];
            if (turn) {
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (y <= 2) moves.push_back(point::new(x, y + 2)); // right
            } else {
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (y >= 2) moves.push_back(point::new(x, y - 2)); // left
            };
            moves
        },
        MoveCard::Crab => {
            let mut moves = vector[];
            if (y >= 2) moves.push_back(point::new(x, y - 2)); // left x2
            if (y <= 2) moves.push_back(point::new(x, y + 2)); // right x2
            if (turn) {
                if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
            } else {
                if (x <= 3) moves.push_back(point::new(x + 1, y)); // down
            };
            moves
        },
        MoveCard::Elephant => {
            let mut moves = vector[];
            if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            if (turn) {
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
            } else {
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
            };
            moves
        },
        MoveCard::Goose => {
            let mut moves = vector[];
            if (turn) {
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (y <= 3 && x <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
            } else {
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
            };
            moves
        },
        MoveCard::Rooster => {
            let mut moves = vector[];
            if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            if (turn) {
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
            } else {
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
            };
            moves
        },
        // the only symmetric card
        MoveCard::Monkey => {
            let mut moves = vector[];
            if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
            if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
            if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
            if (y <= 3 && x <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
            moves
        },
        MoveCard::Mantis => {
            let mut moves = vector[];
            if (turn) {
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (x <= 3) moves.push_back(point::new(x + 1, y)); // down
            } else {
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
            };
            moves
        },
        MoveCard::Horse => {
            let mut moves = vector[];
            if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
            if (x <= 3) moves.push_back(point::new(x + 1, y)); // down

            if (turn) {
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            } else {
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            };
            moves
        },
        MoveCard::Ox => {
            let mut moves = vector[];
            if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
            if (x <= 3) moves.push_back(point::new(x + 1, y)); // down

            if (turn) {
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            } else {
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            };
            moves
        },
        MoveCard::Crane => {
            let mut moves = vector[];
            if (turn) {
                if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (y <= 3 && x <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
            } else {
                if (x <= 3) moves.push_back(point::new(x + 1, y)); // down
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
            };
            moves
        },
        MoveCard::Boar => {
            let mut moves = vector[];
            if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            if (y <= 3) moves.push_back(point::new(x, y + 1)); // right

            if (turn) {
                if (x >= 1) moves.push_back(point::new(x - 1, y)); // up
            } else {
                if (x <= 3) moves.push_back(point::new(x + 1, y)); // down
            };
            moves
        },
        MoveCard::Eel => {
            let mut moves = vector[];
            if (turn) {
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            } else {
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            };
            moves
        },
        MoveCard::Cobra => {
            let mut moves = vector[];
            if (turn) {
                if (x >= 1 && y <= 3) moves.push_back(point::new(x - 1, y + 1)); // up right
                if (x <= 3 && y <= 3) moves.push_back(point::new(x + 1, y + 1)); // down right
                if (y >= 1) moves.push_back(point::new(x, y - 1)); // left
            } else {
                if (x >= 1 && y >= 1) moves.push_back(point::new(x - 1, y - 1)); // up left
                if (x <= 3 && y >= 1) moves.push_back(point::new(x + 1, y - 1)); // down left
                if (y <= 3) moves.push_back(point::new(x, y + 1)); // right
            };
            moves
        },
    }
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
    // prettier-ignore
    std::debug::print(&{
        let mut str = b"\n".to_string();
        str.append(field.to_string());
        str
    });
}

#[test]
fun test_game() {
    use sui::test_utils::destroy;
    use std::unit_test::assert_eq;

    let mut field = new(vector[0, 1, 2, 3, 4]); // cards 0-4 are used

    field.debug();

    assert!(field.turn); // is red

    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Tiger".to_string()));

    assert_eq!(field.red_cards[0].to_string(), b"Crab".to_string());

    // red left student goes up with Crab card
    field.play(0, 4, 0, 3, 0);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Crab".to_string()));

    assert_eq!(field.blue_cards[0].to_string(), b"Frog".to_string());

    // blue master goes forward left with Frog card
    field.play(0, 0, 2, 1, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Frog".to_string()));
    field.debug();

    // central-right red student goes up 2 fields with Tiger card
    field.play(0, 4, 3, 2, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Tiger".to_string()));
    field.debug();

    // blue master takes down student with Crab card
    field.play(0, 1, 3, 2, 3);
    field.next_card.do_ref!(|card| assert_eq!(card.to_string(), b"Crab".to_string()));
    field.debug();

    // red player turn, huh, Tiger
    // std::debug::print(&field.red_cards[0].to_string());

    destroy(field)
}
