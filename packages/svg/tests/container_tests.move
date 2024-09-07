// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::container_tests;

use std::unit_test::assert_eq;
use svg::{container, shape, svg};

#[test]
fun test_name() {
    assert_eq!(container::desc(vector[]).name(), b"".to_string());
    assert_eq!(container::root(vector[]).name(), b"".to_string());
    assert_eq!(container::defs(vector[]).name(), b"defs".to_string());
    assert_eq!(container::a(b"".to_string(), vector[]).name(), b"a".to_string());
    assert_eq!(container::g(vector[]).name(), b"g".to_string());
    // assert_eq!(container::marker(vector[]).name(), b"marker".to_string());
    // assert_eq!(container::symbol(vector[]).name(), b"symbol".to_string());
}

#[test]
fun test_to_string() {
    assert_eq!(container::desc(vector[]).to_string(), b"".to_string());
    assert_eq!(container::root(vector[]).to_string(), b"".to_string());
    assert_eq!(container::defs(vector[]).to_string(), b"<defs></defs>".to_string());
    assert_eq!(container::a(b"".to_string(), vector[]).to_string(), b"<a></a>".to_string());
    assert_eq!(container::g(vector[]).to_string(), b"<g></g>".to_string());
    // assert_eq!(container::marker(vector[]).to_string(), b"<marker/>".to_string());
    // assert_eq!(container::symbol(vector[]).to_string(), b"<symbol/>".to_string());
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/defs
//
// ```xml
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <defs>
//     <cicle id="myCircle" cx="10" cy="10" r="5"/>
//     <linearGradient id="myGradient" x1="0%" y1="0%" x2="100%" y2="0%">
//       <stop offset="0%" style="stop-color:rgb(255,255,255);stop-opacity:0" />
//       <stop offset="100%" style="stop-color:rgb(255,0,0);stop-opacity:1" />
//     </linearGradient>
//   </defs>
//   <use x="5" y="5" href="#myCircle" fill="url(#myGradient)" />
// </svg>
// ```
fun test_defs() {
    let mut svg = svg::svg(vector[0, 0, 10, 10]);
    svg.defs(vector[shape::circle(5).map_attributes!(|attrs| {
            attrs.insert(b"id".to_string(), b"myCircle".to_string());
            attrs.insert(b"cx".to_string(), b"0".to_string());
            attrs.insert(b"cy".to_string(), b"0".to_string());
        }), shape::linear_gradient(vector[shape::stop(b"10%", b"gold"), shape::stop(b"90%", b"red")]).map_attributes!(|attrs| {
            attrs.insert(b"id".to_string(), b"myGradient".to_string());
        })]);


    svg.root(vector[
        shape::use_(b"#myCircle".to_string()).map_attributes!(|attrs| {
            attrs.insert(b"x".to_string(), b"5".to_string());
            attrs.insert(b"y".to_string(), b"5".to_string());
            attrs.insert(b"fill".to_string(), b"url(#myGradient)".to_string());
        }),
    ]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'><defs><circle id='myCircle' cx='0' cy='0' r='5'/><linearGradient id='myGradient'><stop offset='10%' stop-color='gold'/><stop offset='90%' stop-color='red'/></linearGradient></defs><use x='5' y='5' fill='url(#myGradient)' href='#myCircle'/></svg>".to_string(),
    );

    // svg.debug();
}
