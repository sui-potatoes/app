// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::container_tests;

use std::unit_test::assert_eq;
use svg::{container, shape, svg};

#[test]
fun test_name() {
    assert_eq!(container::root(vector[]).name(), b"".to_string());
    assert_eq!(container::defs(vector[]).name(), b"defs".to_string());
    assert_eq!(container::a(b"".to_string(), vector[]).name(), b"a".to_string());
    assert_eq!(container::g(vector[]).name(), b"g".to_string());
    // assert_eq!(container::marker(vector[]).name(), b"marker".to_string());
    // assert_eq!(container::symbol(vector[]).name(), b"symbol".to_string());
}

#[test]
fun test_to_string() {
    assert_eq!(container::root(vector[]).to_string(), b"".to_string());
    assert_eq!(container::defs(vector[]).to_string(), b"<defs></defs>".to_string());
    assert_eq!(container::a(b"".to_string(), vector[]).to_string(), b"<a></a>".to_string());
    assert_eq!(
        container::a(b"/potatoes".to_string(), vector[]).to_string(),
        b"<a href='/potatoes'></a>".to_string(),
    );
    assert_eq!(container::g(vector[]).to_string(), b"<g></g>".to_string());
    // assert_eq!(container::marker(vector[]).to_string(), b"<marker/>".to_string());
    // assert_eq!(container::symbol(vector[]).to_string(), b"<symbol/>".to_string());
}

#[test]
// We expect this container to be ignored and its elements be printed directly in the root.
fun test_root() {
    let mut svg = svg::svg(vector[0, 0, 200, 200]);
    svg.add_root(vector[shape::circle(5).move_to(10, 10)]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 200'><circle cx='10' cy='10' r='5'/></svg>".to_string(),
    );

    // svg.debug();
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
    svg.add_defs(vector[shape::circle(5).map_attributes!(|attrs| {
            attrs.insert(b"id".to_string(), b"myCircle".to_string());
            attrs.insert(b"cx".to_string(), b"0".to_string());
            attrs.insert(b"cy".to_string(), b"0".to_string());
        }), shape::linear_gradient(vector[shape::stop(b"10%", b"gold"), shape::stop(b"90%", b"red")]).map_attributes!(|attrs| {
            attrs.insert(b"id".to_string(), b"myGradient".to_string());
        })]);

    svg.add_root(vector[shape::use_(b"#myCircle".to_string()).map_attributes!(|attrs| {
            attrs.insert(b"x".to_string(), b"5".to_string());
            attrs.insert(b"y".to_string(), b"5".to_string());
            attrs.insert(b"fill".to_string(), b"url(#myGradient)".to_string());
        })]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'><defs><circle id='myCircle' cx='0' cy='0' r='5'/><linearGradient id='myGradient'><stop offset='10%' stop-color='gold'/><stop offset='90%' stop-color='red'/></linearGradient></defs><use x='5' y='5' fill='url(#myGradient)' href='#myCircle'/></svg>".to_string(),
    );

    // svg.debug();
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <!-- A link around a shape -->
//   <a href="/docs/Web/SVG/Element/circle">
//     <circle cx="50" cy="40" r="35" />
//   </a>

//   <!-- A link around a text -->
//   <a href="/docs/Web/SVG/Element/text">
//     <text x="50" y="90" text-anchor="middle">&lt;circle&gt;</text>
//   </a>
// </svg>
// ```
fun test_a() {
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    let link = container::a(
        b"/docs/Web/SVG/Element/circle".to_string(),
        vector[shape::circle(35).move_to(50, 40)],
    );
    svg.add(link);

    let link = container::a(
        b"/docs/Web/SVG/Element/text".to_string(),
        vector[shape::text(b"&lt;circle&gt;".to_string()).move_to(50, 90).map_attributes!(|attrs| {
                attrs.insert(b"text-anchor".to_string(), b"middle".to_string());
            })],
    );
    svg.add(link);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><a href='/docs/Web/SVG/Element/circle'><circle cx='50' cy='40' r='35'/></a><a href='/docs/Web/SVG/Element/text'><text text-anchor='middle' x='50' y='90'>&lt;circle&gt;</text></a></svg>".to_string(),
    );

    // svg.debug();
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/g
//
// ```
// <svg viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
//   <!-- Using g to inherit presentation attributes -->
//   <g fill="white" stroke="green" stroke-width="5">
//     <circle cx="40" cy="40" r="25" />
//     <circle cx="60" cy="60" r="25" />
//   </g>
// </svg>
// ```
fun test_g() {
    let mut svg = svg::svg(vector[0, 0, 100, 100]);
    let group = container::g(vector[
        shape::circle(25).move_to(40, 40),
        shape::circle(25).move_to(60, 60),
    ]).map_attributes!(|attrs| {
        attrs.insert(b"fill".to_string(), b"white".to_string());
        attrs.insert(b"stroke".to_string(), b"green".to_string());
        attrs.insert(b"stroke-width".to_string(), b"5".to_string());
    });

    svg.add(group);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 100'><g fill='white' stroke='green' stroke-width='5'><circle cx='40' cy='40' r='25'/><circle cx='60' cy='60' r='25'/></g></svg>".to_string(),
    );

    // svg.debug();
}
