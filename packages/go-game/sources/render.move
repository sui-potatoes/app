// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module go_game::render;

use go_game::go::Board;
use svg::{shape, svg::{Self, Svg}};

/// Print the board as an SVG.
public(package) fun svg(b: &Board): Svg {
    let padding = 1u16;
    let cell_size = 20u16;
    let size = b.size() as u16;
    let width = ((size * (cell_size + 1)) + (size * padding)) as u16;

    // create a new SVG document
    let mut svg = svg::svg(vector[0, 0, width, width]);

    // construct a circle definition for black stones
    let black = shape::circle(10).map_attributes!(|attrs| {
        attrs.insert(b"id".to_string(), b"b".to_string());
        attrs.insert(b"fill".to_string(), b"#000".to_string());
    });

    // construct a circle definition for white stones
    let white = shape::circle(10).map_attributes!(|attrs| {
        attrs.insert(b"id".to_string(), b"w".to_string());
        attrs.insert(b"fill".to_string(), b"#fff".to_string());
        attrs.insert(b"stroke".to_string(), b"#000".to_string());
    });

    // pattern + background definition
    let pattern = shape::custom(b"<pattern id='g' width='21' height='21' x='20' y='20' patternUnits='userSpaceOnUse'><path d='M 40 0 L 0 0 0 40' fill='none' stroke='gray' stroke-width='0.8'/></pattern>".to_string());
    let mut background = shape::rect(width, width);
    background.attributes_mut().insert(b"fill".to_string(), b"url(#g)".to_string());

    svg.add_defs(vector[black, white, pattern]);

    let mut elements = vector[background];
    b.grid().traverse!(|tile, row, col| {
        let num = tile.to_number();
        if (num == 0) return;
        let stone = if (num == 1) b"#b" else { b"#w" }.to_string();

        let cx = (row * cell_size) + (row * padding) + 10;
        let cy = (col * cell_size) + (col * padding) + 10;

        elements.push_back(shape::use_(stone).move_to(cx, cy));
    });

    svg.add_root(elements);
    svg
}

#[test]
fun test_rendering_safari() {
    let board = go_game::go::from_vector(vector[
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

    // let res = svg(&board).to_url();
    // let mut data_url = b"data:image/svg+xml;charset=utf8,";
    // data_url.append(res.into_bytes());

    std::debug::print(&svg(&board).to_url());

    // print the data URL
    // std::debug::print(&data_url.to_ascii_string());
    // std::debug::print(&data_url.length());
}
