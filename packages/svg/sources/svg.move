// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: svg
module svg::svg;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{container::{Self, Container}, print, shape::Shape};

/// The base SVG element.
public struct Svg has store, copy, drop {
    view_box: vector<u16>,
    elements: vector<Container>,
    attributes: VecMap<String, String>,
}

/// Create a new SVG element.
public fun svg(view_box: vector<u16>): Svg {
    assert!(view_box.length() == 4 || view_box.length() == 0);
    Svg { view_box, elements: vector[], attributes: vec_map::empty() }
}

/// Adds any element to the SVG.
public fun add(svg: &mut Svg, element: Container): &mut Svg {
    svg.elements.push_back(element);
    svg
}

/// Add a root container to the SVG.
public fun root(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
    svg.add(container::root(shapes))
}

/// Add a group container to the SVG.
public fun g(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
    svg.add(container::g(shapes))
}

/// Get mutable access to the attributes of the SVG.
public fun attributes_mut(svg: &mut Svg): &mut VecMap<String, String> {
    &mut svg.attributes
}

/// Print the SVG element as a `String`.
public fun to_string(svg: &Svg): String {
    let mut attributes = vec_map::empty();
    attributes.insert(b"xmlns".to_string(), b"http://www.w3.org/2000/svg".to_string());
    if (svg.view_box.length() == 4) {
        let mut view_box = b"".to_string();
        svg.view_box.do_ref!(|value| {
            view_box.append(print::num_to_string(*value));
            view_box.append(b" ".to_string());
        });

        attributes.insert(b"viewBox".to_string(), view_box);
    };

    print::print(
        b"svg".to_string(),
        attributes,
        option::some(svg.elements.map_ref!(|element| element.to_string())),
    )
}

#[test_only]
public fun debug(svg: &Svg) {
    std::debug::print(&to_string(svg));
}

#[test]
fun test_svg() {
    use svg::shape;
    use svg::macros::add_attribute;

    let mut svg = svg(vector[0, 0, 200, 200]); // elephant emoji HEX is 01F418
    let mut str = x"F09F9098";
    str.append(b"You won't believe this!");

    svg.root(vector[{
            let mut shape = shape::text(str.to_string(), 100, 50);
            add_attribute!(&mut shape, b"fill", b"black");
            add_attribute!(&mut shape, b"font-size", b"20");
            shape
        }, shape::circle(10, 10, 5), {
            let mut rect = shape::rect(10, 10, 20, 20);
            add_attribute!(&mut rect, b"fill", b"red");
            add_attribute!(&mut rect, b"stroke", b"black");
            rect
        }, shape::ellipse(30, 30, 10, 5)]);

    let mut prefix = b"data:image/svg+xml;charset=utf8,".to_string();
    let str = codec::urlencode::encode(svg.to_string().into_bytes());
    prefix.append(str);
    std::debug::print(&prefix.length());
    std::debug::print(&prefix);
}
