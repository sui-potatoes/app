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
