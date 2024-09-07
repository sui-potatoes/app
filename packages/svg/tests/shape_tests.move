// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::shape_tests;

use svg::{shape, svg};

#[test]
// prettier-ignore
fun test_shapes() {
    assert!(shape::circle(5).move_to(10, 10).to_string() == b"<circle cx='10' cy='10' r='5'/>".to_string());
    assert!(shape::ellipse(10, 10, 5, 5).to_string() == b"<ellipse cx='10' cy='10' rx='5' ry='5'/>".to_string());
    assert!(shape::line(10, 10, 20, 20).to_string() == b"<line x1='10' y1='10' x2='20' y2='20'/>".to_string());
    // assert!(shape::polygon(vector[vector[0, 0], vector[10, 10]]).to_string() == b"<polygon points='0,0 10,10'/>".to_string());
    // assert!(shape::polyline(vector[vector[0, 0], vector[10, 10]]).to_string() == b"<polyline points='0,0 10,10/>".to_string());
    assert!(shape::rect(20, 20).to_string() == b"<rect width='20' height='20'/>".to_string());
    assert!(shape::text(b"Hello, World!".to_string()).move_to(10, 10).to_string() == b"<text x='10' y='10'>Hello, World!</text>".to_string());
    assert!(shape::use_(b"#circle".to_string()).to_string() == b"<use href='#circle'/>".to_string());
    assert!(shape::custom(b"<custom/>".to_string()).to_string() == b"<custom/>".to_string());
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/rect
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <rect x="10" y="10" width="30" height="30" fill="red"/>
// </svg>
// ```
fun test_rect() {
    let mut rect = shape::rect(30, 30).move_to(10, 10);
    rect.attributes_mut().insert(b"fill".to_string(), b"red".to_string());

    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.root(vector[rect]);
    svg.debug();
}
