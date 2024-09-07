// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::animation_tests;

use std::unit_test::assert_eq;
use svg::{animation, shape, svg};

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animate
//
// ```
// <svg viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg">
// <rect width="10" height="10">
//    <animate
//      attributeName="rx"
//      values="0;5;0"
//      dur="10s"
//      repeatCount="indefinite" />
// </rect>
// </svg>
// ```
fun test_animate() {
    let animation = animation::animate()
        .attribute_name(b"rx")
        .values(b"0;5;0")
        .duration(b"10s")
        .repeat_count(b"indefinite");

    let mut rect = shape::rect(10, 10);
    rect.add_animation(animation);

    let mut svg = svg::svg(vector[0, 0, 10, 10]);
    svg.root(vector[rect]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'><rect width='10' height='10'><animate attributeName='rx' values='0;5;0' dur='10s' repeatCount='indefinite'/></rect></svg>".to_string()
    );

    // svg.debug();
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateTransform
//
// ```
// <svg viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg">
// <rect width="10" height="10">
//    <animateTransform
//      attributeName="transform"
//      type="rotate"
//      from="0 5 5"
//      to="360 5 5"
//      dur="10s"
//      repeatCount="indefinite" />
// </rect>
// </svg>
// ```
fun test_animate_transform() {
    let animation = animation::animate_transform(b"rotate", b"0 5 5", b"360 5 5")
        .attribute_name(b"transform")
        .duration(b"10s")
        .repeat_count(b"indefinite");

    let mut rect = shape::rect(10, 10);
    rect.add_animation(animation);

    let mut svg = svg::svg(vector[0, 0, 120, 120]);
    svg.root(vector[rect]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 120 120'><rect width='10' height='10'><animateTransform attributeName='transform' dur='10s' repeatCount='indefinite' type='rotate' from='0 5 5' to='360 5 5'/></rect></svg>".to_string()
    );

    // svg.debug();
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateMotion
//
// ```
// <svg viewBox="0 0 200 100" xmlns="http://www.w3.org/2000/svg">
//   <path
//     fill="none"
//     stroke="lightgrey"
//     d="M20,50 C20,-50 180,150 180,50 C180-50 20,150 20,50 z" />

//   <circle r="5" fill="red">
//     <animateMotion
//       dur="10s"
//       repeatCount="indefinite"
//       path="M20,50 C20,-50 180,150 180,50 C180-50 20,150 20,50 z" />
//   </circle>
// </svg>
// ```
fun test_animate_motion() {
    let path_value = b"M20,50 C20,-50 180,150 180,50 C180-50 20,150 20,50 z";
    let mut path = shape::path(path_value.to_string(), option::none());
    let attributes = path.attributes_mut();

    attributes.insert(b"id".to_string(), b"#path".to_string());
    attributes.insert(b"fill".to_string(), b"none".to_string());
    attributes.insert(b"stroke".to_string(), b"lightgrey".to_string());

    let animation = animation::animate_motion(option::some(path_value), option::none())
        .duration(b"10s")
        .repeat_count(b"indefinite");

    let mut circle = shape::circle(5);
    circle.attributes_mut().insert(b"fill".to_string(), b"red".to_string());
    circle.add_animation(animation);

    let mut svg = svg::svg(vector[0, 0, 200, 100]);
    svg.root(vector[path, circle]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 200 100'><path id='#path' fill='none' stroke='lightgrey' d='M20,50 C20,-50 180,150 180,50 C180-50 20,150 20,50 z'/><circle fill='red' r='5'><animateMotion dur='10s' repeatCount='indefinite' path='M20,50 C20,-50 180,150 180,50 C180-50 20,150 20,50 z'/></circle></svg>".to_string()
    );

    // svg.debug();
}

#[test]
// From MDN Web Docs: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/set
//
// ```
// <svg viewBox="0 0 10 10" xmlns="http://www.w3.org/2000/svg">
// <rect width="10" height="10">
//    <set attributeName="fill" to="red" begin="mouseover" end="mouseout" />
// </rect>
// </svg>
// ```
fun test_set() {
    let animation = animation::set(b"red")
        .attribute_name(b"fill")
        .map_attributes!(|a| {
            a.insert(b"begin".to_string(), b"mouseover".to_string());
            a.insert(b"end".to_string(), b"mouseout".to_string());
        });

    let mut rect = shape::rect(10, 10);
    rect.add_animation(animation);

    let mut svg = svg::svg(vector[0, 0, 10, 10]);
    svg.root(vector[rect]);

    assert_eq!(
        svg.to_string(),
        b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'><rect width='10' height='10'><set begin='mouseover' end='mouseout' attributeName='fill' to='red'/></rect></svg>".to_string()
    );

}
