// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::shape_tests;

use std::unit_test::assert_eq;
use svg::{animation, shape, svg};

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
// <svg viewBox='0 0 100 100' xmlns='http://www.w3.org/2000/svg'>
//   <rect x='10' y='10' width='30' height='30' fill='red'/>
// </svg>
// ```
fun rect() {
    let mut rect = shape::rect(30, 30).move_to(10, 10);
    rect.attributes_mut().insert(b"fill".to_string(), b"red".to_string());

    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[rect]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><rect fill='red' x='10' y='10' width='30' height='30'/></svg>".to_string(),
    );
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/circle
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <circle cx="50" cy="50" r="50" />
// </svg>
// ```
fun circle() {
    let circle = shape::circle(50).move_to(50, 50);
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[circle]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><circle cx='50' cy='50' r='50'/></svg>".to_string(),
    );
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/ellipse
//
// ```
// <svg viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">
//  <ellipse cx="100" cy="50" rx="100" ry="50" />
// </svg>
// ```
fun ellipse() {
    let ellipse = shape::ellipse(100, 50, 100, 50);
    let mut svg = svg::svg(vector[0, 0, 200, 100]);
    svg.add_root(vector[ellipse]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 100'><ellipse cx='100' cy='50' rx='100' ry='50'/></svg>".to_string(),
    );
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/line
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <line x1="10" y1="10" x2="90" y2="90" />
// </svg>
// ```
fun line() {
    let line = shape::line(10, 10, 90, 90);
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[line]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><line x1='10' y1='10' x2='90' y2='90'/></svg>".to_string(),
    );
}

#[test, expected_failure(abort_code = ::svg::shape::ENotImplemented)]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/polygon
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <polygon points="10,10 90,10 90,90 10,90" />
// </svg>
// ```
fun polygon() {
    let polygon = shape::polygon(vector[
        vector[10, 10],
        vector[90, 10],
        vector[90, 90],
        vector[10, 90],
    ]);
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[polygon]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><polygon points='10,10 90,10 90,90 10,90'/></svg>".to_string(),
    );
}

#[test, expected_failure(abort_code = ::svg::shape::ENotImplemented)]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/polyline
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <polyline points="10,10 90,10 90,90 10,90" />
// </svg>
// ```
fun polyline() {
    let polyline = shape::polyline(vector[
        vector[10, 10],
        vector[90, 10],
        vector[90, 90],
        vector[10, 90],
    ]);
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[polyline]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><polyline points='10,10 90,10 90,90 10,90'/></svg>".to_string(),
    );
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text
//
// ```
// <svg viewBox="0 0 200 200" xmlns="http://www.w3.org/2000/svg">
//   <text x="10" y="10">Hello, World!</text>
// </svg>
// ```
fun text() {
    let text = shape::text(b"Hello, World!".to_string()).move_to(10, 10);
    let mut svg = svg::svg(vector[0, 0, 200, 200]);
    svg.add_root(vector[text]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 200'><text x='10' y='10'>Hello, World!</text></svg>".to_string(),
    );
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/use
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <use href="#circle" />
// </svg>
// ```
fun use_() {
    let use_ = shape::use_(b"#circle".to_string());
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[use_]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><use href='#circle'/></svg>".to_string(),
    );
}

#[test]
// Custom element test:
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <custom />
// </svg>
// ```
fun custom() {
    let custom = shape::custom(b"<custom/>".to_string());
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    svg.add_root(vector[custom]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><custom/></svg>".to_string(),
    );
}

#[test]
fun animation_shape() {
    let mut svg = svg::svg(vector[0, 0, 200, 200]);
    let mut circle = shape::circle(5).move_to(10, 10);
    let animation = /* ERROR: */ animation::animate()
        .repeat_count(b"10")
        .attribute_name(b"r")
        .duration(b"1s");

    circle.animation_mut().fill(animation);
    svg.add_root(vector[ circle ]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 200'><circle cx='10' cy='10' r='5'><animate attributeName='r' dur='1s' repeatCount='10'/></circle></svg>".to_string(),
    );
}
