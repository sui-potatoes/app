// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::svg_tests;

use svg::{container, macros::{add_class, add_attribute}, shape, svg};

#[test]
// character is a 9x13 rectangle with head, body, hands, and legs
fun test_character() {
    let mut svg = svg::svg(vector[0, 0, 9, 13]);

    // head
    let mut head = shape::rect(3, 3);
    head.move_to(3, 3);
    add_class!(&mut head, b"head");
    add_attribute!(&mut head, b"fill", b"orange");

    // body
    let mut body = shape::rect(3, 3);
    head.move_to(3, 6);
    add_class!(&mut body, b"body");
    add_attribute!(&mut body, b"fill", b"blue");

    // hands (a container already!)
    let mut hands = container::g(vector[
        shape::rect(1, 3).move_to(2, 6), // left hand
        shape::rect(1, 3).move_to(6, 6), // right hand
    ]);

    add_class!(&mut hands, b"hand");
    add_attribute!(&mut hands, b"fill", b"black");

    // legs
    let mut legs = container::g(vector[
        shape::rect(1, 3).move_to(3, 9), // left leg
        shape::rect(1, 1).move_to(4, 9), // middle
        shape::rect(1, 3).move_to(5, 9), // right leg
    ]);

    add_attribute!(&mut legs, b"fill", b"black");

    svg.add_root(vector[head, body]).add(hands).add(legs);
    std::debug::print(&svg.to_string().as_bytes().length());

    // svg.debug()
}
