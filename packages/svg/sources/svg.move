// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: svg
module svg::svg;

use codec::{base64, urlencode};
use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{container::{Self, Container}, print, shape::Shape};

/// The base SVG element.
public struct Svg has store, copy, drop {
    view_box: vector<u16>,
    elements: vector<Container>,
    attributes: VecMap<String, String>,
}

/// Create a new `<svg>` element with the given view box. View box is optional,
/// but if provided, it must have 4 elements.
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 200, 200]);
/// svg.root(vector[ shape::circle(5).move_to(10, 10) ]);
/// svg.to_string(); // to print as a string
/// svg.debug(); // to print in the console in tests
/// ```
public fun svg(view_box: vector<u16>): Svg {
    assert!(view_box.length() == 4 || view_box.length() == 0);
    Svg { view_box, elements: vector[], attributes: vec_map::empty() }
}

/// Adds any `Container` to the `Svg`, if container is created manually. Alternatively,
/// to add a group container or place elements in the "root", use `root` or `g` functions.
///
/// ```rust
/// let container = container::g(vector[
///    shape::circle(5).move_to(10, 10),
///    shape::ellipse(30, 30, 10, 5),
/// ]);
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.add(container);
/// svg.to_string();
/// ```
public fun add(svg: &mut Svg, element: Container): &mut Svg {
    svg.elements.push_back(element);
    svg
}

/// Place `Shape`s directly in the root of the SVG.
///
/// ```rust
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.root(vector[
///   shape::circle(5).move_to(10, 10),
///   shape::square(30, 30).move_to(20, 20),
/// ]);
/// svg.to_string();
/// ```
public fun root(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
    svg.add(container::root(shapes))
}

/// Create a `<g>` (group) container and place `Shape`s in it.
///
/// Shortcut for `svg.add(container::g(shapes))`.
///
/// ```rust
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.g(vector[
///  shape::circle(5).move_to(10, 10),
///  shape::ellipse(30, 30, 10, 5),
/// ]);
/// svg.to_string();
/// ```
public fun g(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
    svg.add(container::g(shapes))
}

/// Create a `<defs>` container and place `Shape`s in it.
///
/// Shortcut for `svg.add(container::defs(shapes))`.
///
/// ```rust
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.defs(vector[
///     shape::linear_gradient(vector[
///         shape::stop(b"10%", b"gold"),
///         shape::stop(b"90%", b"red"),
///     ]).map_attributes!(|attrs| {
///        attrs.insert(b"id".to_string(), b"grad1".to_string());
///     }),
/// ]);
/// svg.to_string();
/// ```
public fun defs(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
    svg.add(container::defs(shapes))
}

/// Get mutable access to the attributes of the SVG. This is useful for adding
/// custom attributes directly to the `<svg>` element.
///
/// ```rust
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.attributes_mut().insert(
///     b"width".to_string(),
///     b"10000".to_string()
/// );
/// ```
public fun attributes_mut(svg: &mut Svg): &mut VecMap<String, String> {
    &mut svg.attributes
}

/// Print the SVG element as a `String`.
///
/// ```rust
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.root(vector[ shape::circle(5).move_to(10, 10) ]);
/// let printed = svg.to_string();
/// ```
public fun to_string(svg: &Svg): String {
    let mut attributes = vec_map::empty();
    attributes.insert(b"xmlns".to_string(), b"http://www.w3.org/2000/svg".to_string());

    let length = svg.view_box.length();
    if (length == 4) {
        let mut view_box = b"".to_string();
        length.do!(|index| {
            view_box.append(svg.view_box[index].to_string());
            if (index < 3) view_box.append(b" ".to_string());
        });
        attributes.insert(b"viewBox".to_string(), view_box);
    };

    print::print(
        b"svg".to_string(),
        attributes,
        option::some(svg.elements.map_ref!(|element| element.to_string())),
    )
}

/// Convert the SVG element to a base64-encoded data URI.
///
/// Outputs: `data:image/svg+xml;base64,PHN2Zz4KPC9zdmc+`.
/// > If you need a URL-encoded data URI, use `svg.to_url()`
public fun to_data_uri(svg: &Svg): String {
    let mut result = b"data:image/svg+xml;base64,".to_string();
    result.append(base64::encode(to_string(svg).into_bytes()));
    result
}

/// Convert the SVG element to a url-encoded data URI.
///
/// Outputs: `data:image/svg+xml,%3Csvg%3E%3C%2Fsvg%3E`.
/// > If you need a base64-encoded data URI, use `svg.to_data_uri()`
public fun to_url(svg: &Svg): String {
    let mut result = b"data:image/svg+xml,".to_string();
    result.append(urlencode::encode(to_string(svg).into_bytes()));
    result
}

#[test_only]
/// Print the SVG element in the console, only for tests.
public fun debug(svg: &Svg) { std::debug::print(&to_string(svg)); }
