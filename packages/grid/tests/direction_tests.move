// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::direction_tests;

use grid::direction::{Self, up, down, left, right, inverse};
use std::unit_test::assert_eq;

#[test]
fun is_direction() {
    assert!(direction::is_up!(1, 1, 0, 1));
    assert!(direction::is_down!(0, 0, 1, 0));
    assert!(direction::is_left!(0, 1, 0, 0));
    assert!(direction::is_right!(0, 0, 0, 1));
}

#[test]
fun direction() {
    assert_eq!(direction::direction!(0, 0, 0, 0), direction::none!());
    assert_eq!(direction::direction!(0, 0, 1, 0), direction::down!());
    assert_eq!(direction::direction!(1, 0, 0, 0), direction::up!());
    assert_eq!(direction::direction!(0, 0, 0, 1), direction::right!());
    assert_eq!(direction::direction!(0, 1, 0, 0), direction::left!());

    assert_eq!(direction::direction!(1, 1, 0, 0), direction::up_left!());
    assert_eq!(direction::direction!(1, 0, 0, 1), direction::up_right!());
    assert_eq!(direction::direction!(0, 1, 1, 0), direction::down_left!());
    assert_eq!(direction::direction!(0, 0, 1, 1), direction::down_right!());
}

#[test]
fun direction_inverse() {
    assert_eq!(inverse!(up!()), down!());
    assert_eq!(inverse!(down!()), up!());
    assert_eq!(inverse!(left!()), right!());
    assert_eq!(inverse!(right!()), left!());
    assert_eq!(inverse!(up!() | left!()), down!() | right!());
    assert_eq!(inverse!(up!() | right!()), down!() | left!());
    assert_eq!(inverse!(down!() | left!()), up!() | right!());
    assert_eq!(inverse!(down!() | right!()), up!() | left!());
}

#[test]
// goes in a square: down, right, up, left
// then in zigzag: down-right, down-left, up-right, up-left
fun cursor() {
    let mut cursor = direction::new_cursor(0, 0);
    let (x, y) = cursor.to_values();
    assert_eq!(x + y, 0); // lazy check

    cursor.move_to(down!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 0);

    cursor.move_to(right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(up!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 1);

    cursor.move_to(left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 0);

    cursor.move_to(down!() | right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(down!() | left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 2);
    assert_eq!(y, 0);

    cursor.move_to(up!() | right!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 1);
    assert_eq!(y, 1);

    cursor.move_to(up!() | left!());
    let (x, y) = cursor.to_values();
    assert_eq!(x, 0);
    assert_eq!(y, 0);
}

#[test]
fun cursor_to_from_point() {
    let cursor = direction::new_cursor(10, 10);
    let point = cursor.to_point();
    let cursor = point.to_cursor();

    let (xc, yc) = cursor.to_values();
    let (xp, yp) = point.to_values();

    assert_eq!(xc, xp);
    assert_eq!(yc, yp);
}
