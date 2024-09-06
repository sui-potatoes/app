// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::shape_tests;

use svg::shape;

#[test]
// prettier-ignore
fun test_shapes() {
    assert!(shape::circle(10, 10, 5).to_string() == b"<circle cx='10' cy='10' r='5'/>".to_string());
    assert!(shape::ellipse(10, 10, 5, 5).to_string() == b"<ellipse cx='10' cy='10' rx='5' ry='5'/>".to_string());
    assert!(shape::line(10, 10, 20, 20).to_string() == b"<line x1='10' y1='10' x2='20' y2='20'/>".to_string());
    assert!(shape::polygon(vector[vector[0, 0], vector[10, 10]]).to_string() == b"<polygon points='0,0 10,10'/>".to_string());
    assert!(shape::polyline(vector[vector[0, 0], vector[10, 10]]).to_string() == b"<polyline points='0,0 10,10/>".to_string());
    assert!(shape::rect(10, 10, 20, 20).to_string() == b"<rect x='10' y='10' width='20' height='20'/>".to_string());
    assert!(shape::text(b"Hello, World!".to_string(), 10, 10).to_string() == b"<text x='10' y='10'>Hello, World!</text>".to_string());
    assert!(shape::use_(b"#circle".to_string()).to_string() == b"<use href='#circle'/>".to_string());
    assert!(shape::custom(b"<custom/>".to_string()).to_string() == b"<custom/>".to_string());
}

#[test]
// prettier-ignore
fun test_move_to() {
    use sui::test_utils::assert_eq;

    let mut circle = shape::circle(10, 10, 5);
    circle.move_to(5, 5);
    assert_eq(circle.to_string(), b"<circle cx='5' cy='5' r='5'/>".to_string());

    let mut ellipse = shape::ellipse(10, 10, 5, 5);
    ellipse.move_to(5, 5);
    assert_eq(ellipse.to_string(), b"<ellipse cx='5' cy='5' rx='5' ry='5'/>".to_string());

    let mut line = shape::line(10, 10, 20, 20);
    line.move_to(5, 5);
    assert_eq(line.to_string(), b"<line x1='5' y1='5' x2='15' y2='15'/>".to_string());

    let mut polygon = shape::polygon(vector[vector[0, 0], vector[10, 10]]);
    polygon.move_to(5, 5);
    assert_eq(polygon.to_string(), b"<polygon points='5, 5 15, 15'/>".to_string());

    let mut polyline = shape::polyline(vector[vector[0, 0], vector[10, 10]]);
    polyline.move_to(5, 5);
    assert_eq(polyline.to_string(), b"<polyline points='5, 5 15, 15/>".to_string());

    let mut rect = shape::rect(10, 10, 20, 20);
    rect.move_to(5, 5);
    assert_eq(rect.to_string(), b"<rect x='5' y='5' width='20' height='20'/>".to_string());

    let mut text = shape::text(b"Hello, World!".to_string(), 10, 10);
    text.move_to(5, 5);
    assert_eq(text.to_string(), b"<text x='5' y='5'>Hello, World!</text>".to_string());

    let mut use_ = shape::use_(b"#circle".to_string());
    use_.move_to(5, 5);
    assert_eq(use_.to_string(), b"<use x='5' y='5' href='#circle'/>".to_string());
}
