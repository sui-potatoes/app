// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module grid::direction_tests;

use grid::direction::{Self, none, up, down, left, right, inverse};
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
    assert_eq!(direction::direction!(0, 0, 0, 0), none!());
    assert_eq!(direction::direction!(0, 0, 1, 0), down!());
    assert_eq!(direction::direction!(1, 0, 0, 0), up!());
    assert_eq!(direction::direction!(0, 0, 0, 1), right!());
    assert_eq!(direction::direction!(0, 1, 0, 0), left!());

    assert_eq!(direction::direction!(1, 1, 0, 0), direction::up_left!());
    assert_eq!(direction::direction!(1, 0, 0, 1), direction::up_right!());
    assert_eq!(direction::direction!(0, 1, 1, 0), direction::down_left!());
    assert_eq!(direction::direction!(0, 0, 1, 1), direction::down_right!());
}

#[test]
fun is_direction_valid() {
    use grid::direction::is_direction_valid;

    // single directions
    assert!(is_direction_valid!(up!()));
    assert!(is_direction_valid!(down!()));
    assert!(is_direction_valid!(left!()));
    assert!(is_direction_valid!(right!()));

    // combinations
    assert!(is_direction_valid!(up!() | left!()));
    assert!(is_direction_valid!(up!() | right!()));
    assert!(is_direction_valid!(down!() | left!()));
    assert!(is_direction_valid!(down!() | right!()));

    // invalid combinations
    assert!(!is_direction_valid!(up!() | down!()));
    assert!(!is_direction_valid!(left!() | right!()));
    assert!(!is_direction_valid!(up!() | down!() | left!() | right!()));
}

#[test]
fun is_direction_vertical() {
    use grid::direction::is_direction_vertical;

    assert!(is_direction_vertical!(up!()));
    assert!(is_direction_vertical!(down!()));
    assert!(!is_direction_vertical!(left!()));
    assert!(!is_direction_vertical!(right!()));
    assert!(!is_direction_vertical!(up!() | left!()));
    assert!(!is_direction_vertical!(up!() | right!()));
    assert!(!is_direction_vertical!(down!() | left!()));
}

#[test]
fun is_direction_horizontal() {
    use grid::direction::is_direction_horizontal;

    assert!(is_direction_horizontal!(left!()));
    assert!(is_direction_horizontal!(right!()));
    assert!(!is_direction_horizontal!(up!()));
    assert!(!is_direction_horizontal!(down!()));
    assert!(!is_direction_horizontal!(up!() | left!()));
    assert!(!is_direction_horizontal!(up!() | right!()));
    assert!(!is_direction_horizontal!(down!() | left!()));
    assert!(!is_direction_horizontal!(down!() | right!()));
}

#[test]
fun is_direction_diagonal() {
    use grid::direction::is_direction_diagonal;

    assert!(is_direction_diagonal!(up!() | left!()));
    assert!(is_direction_diagonal!(up!() | right!()));
    assert!(is_direction_diagonal!(down!() | left!()));
    assert!(is_direction_diagonal!(down!() | right!()));

    assert!(!is_direction_diagonal!(up!()));
    assert!(!is_direction_diagonal!(down!()));
    assert!(!is_direction_diagonal!(left!()));
    assert!(!is_direction_diagonal!(right!()));
    assert!(!is_direction_diagonal!(up!() | down!()));
    assert!(!is_direction_diagonal!(left!() | right!()));
    assert!(!is_direction_diagonal!(up!() | down!() | left!() | right!()));
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
