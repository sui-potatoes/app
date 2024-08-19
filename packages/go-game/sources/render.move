// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module gogame::render;

use codec::urlencode;
use gogame::go::Board;
use std::string::String;
use svg::{container, shape, svg};

/// Print the board as an SVG.
public fun svg(b: &Board): String {
    let padding = 1;
    let cell_size = 20;
    let size = b.size() as u64;
    let width = ((size * (cell_size + 1)) + (size * padding)) as u16;

    // create a new SVG document
    let mut svg = svg::svg(vector[0, 0, width, width]);

    // construct a circle definition for black stones
    let black = {
        let mut shape = shape::circle(0, 0, 10);
        let attrs = shape.attributes_mut();
        attrs.insert(b"id".to_string(), b"b".to_string());
        attrs.insert(b"fill".to_string(), b"#000".to_string());
        shape
    };

    // construct a circle definition for white stones
    let white = {
        let mut shape = shape::circle(0, 0, 10);
        let attrs = shape.attributes_mut();
        attrs.insert(b"id".to_string(), b"w".to_string());
        attrs.insert(b"fill".to_string(), b"#fff".to_string());
        attrs.insert(b"stroke".to_string(), b"#000".to_string());
        shape
    };

    // pattern + background definition
    let pattern = shape::custom(b"<pattern id='g' width='21' height='21' x='10' y='10' patternUnits='userSpaceOnUse'><path d='M 40 0 L 0 0 0 40' fill='none' stroke='gray' stroke-width='0.8'/></pattern>".to_string());
    let mut background = shape::rect(0, 0, width, width);
    background.attributes_mut().insert(b"fill".to_string(), b"url(#g)".to_string());

    svg.add(container::defs(vector[black, white, pattern]));

    let mut elements = vector[background];
    size.do!(|i| {
        size.do!(|j| {
            let e = &b.data()[i][j];
            if (e.is_empty()) return;

            let cx = (i * cell_size) + (i * padding) + 10;
            let cy = (j * cell_size) + (j * padding) + 10;

            let mut stone = match (e.is_black()) {
                true => shape::use_(b"#b".to_string()),
                false => shape::use_(b"#w".to_string()),
            };

            stone.move_to(cx as u16, cy as u16);
            elements.push_back(stone);
        });
    });

    svg.root(elements);
    svg.to_string()
}

#[test]
fun test_rendering_safari() {
    let board = gogame::go::from_vector(vector[
        vector[0, 0, 0, 0, 0, 0, 0, 0, 0],
        vector[0, 0, 2, 0, 0, 0, 0, 1, 0],
        vector[0, 1, 2, 1, 1, 1, 1, 0, 0],
        vector[0, 1, 1, 2, 2, 2, 2, 1, 0],
        vector[0, 1, 2, 2, 0, 2, 0, 1, 0],
        vector[0, 0, 1, 2, 2, 2, 2, 0, 0],
        vector[0, 1, 1, 1, 1, 2, 0, 2, 2],
        vector[0, 1, 0, 1, 2, 0, 2, 0, 0],
        vector[1, 0, 1, 2, 2, 2, 0, 0, 0],
    ]);


    let res = urlencode::encode(svg(&board).into_bytes());
    let mut data_url = b"data:image/svg+xml;charset=utf8,";
    data_url.append(res.into_bytes());

    // print the data URL
    // std::debug::print(&data_url.to_ascii_string());
    // std::debug::print(&data_url.length());
}
