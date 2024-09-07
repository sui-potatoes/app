// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: container
module svg::container;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{desc::Desc, print, shape::Shape};

/// Code for the `NotImplemented` error.
const ENotImplemented: u64 = 0;

/// SVG container enum, which contains shapes.
/// - using `None` - no container, just a list of shapes.
/// - hyperlink container, `<a>`.
/// - definition container, `<defs>`, to be used for reusable shapes.
/// - group container, `<g>`, to group shapes.
public enum Container has store, copy, drop {
    // A root-level container for `Desc` elements, only contains metadata
    // like `<title>`, `<desc>`, and `<metadata>`.
    Desc(vector<Desc>),
    // A root-level container for shapes, no container, just a list of shapes.
    Root(vector<Shape>),
    // A `<defs> container, to be used for reusable shapes. It's like a
    // dictionary of shapes.
    Defs(vector<Shape>),
    // Hyperlink container, `<a>`.
    A(String, vector<Shape>, VecMap<String, String>),
    // Group container, `<g>`, to group shapes and apply transformations.
    G(vector<Shape>, VecMap<String, String>),
    // Marker container, `<marker>`, to define a marker symbol.
    _Marker(vector<Shape>),
}

/// Create a new description container, only contains metadata.
public fun desc(tags: vector<Desc>): Container { Container::Desc(tags) }

/// Create a new root container, no container, just a list of shapes.
public fun root(shapes: vector<Shape>): Container { Container::Root(shapes) }

/// Create a new hyperlink container.
public fun a(href: String, shapes: vector<Shape>): Container {
    Container::A(href, shapes, vec_map::empty())
}

/// Create a new `Defs` container.
public fun defs(shapes: vector<Shape>): Container { Container::Defs(shapes) }

/// Create a new `G` container.
public fun g(shapes: vector<Shape>): Container { Container::G(shapes, vec_map::empty()) }

/// Create a new `_Marker` container.
public fun marker(_shapes: vector<Shape>): Container { abort ENotImplemented }

/// Move a container, keep the interface consistent with shapes.
public fun move_to(container: Container, _x: u16, _y: u16): Container { container }

/// Add a shape to a container.
public fun add(container: &mut Container, shape: Shape) {
    match (container) {
        Container::Root(shapes) => shapes.push_back(shape),
        Container::Defs(shapes) => shapes.push_back(shape),
        Container::G(shapes, _) => shapes.push_back(shape),
        _ => abort 0,
    }
}

/// Get a mutable reference to the attributes of a container.
public fun attributes_mut(container: &mut Container): &mut VecMap<String, String> {
    match (container) {
        Container::A(_, _, attributes) => attributes,
        Container::G(_, attributes) => attributes,
        _ => abort 0,
    }
}

/// Map attributes of the `Container`.
///
/// ```rust
/// let mut container = container::g(vector[
///    shape::circle(5).move_to(10, 10),
///    shape::ellipse(30, 30, 10, 5),
/// ]).map_attributes!(|attrs| {
///    attrs.insert(b"fill".to_string(), b"red".to_string());
///    attrs.insert(b"stroke".to_string(), b"black".to_string());
/// });
/// ```
public macro fun map_attributes($self: Container, $f: |&mut VecMap<String, String>|): Container {
    let mut self = $self;
    let attributes = self.attributes_mut();
    $f(attributes);
    self
}

/// Simplification to not create functions for each container invariant.
public fun name(container: &Container): String {
    match (container) {
        Container::Desc(..) => b"desc".to_string(),
        Container::Root(..) => b"root".to_string(),
        Container::A(..) => b"a".to_string(),
        Container::G(..) => b"g".to_string(),
        Container::Defs(..) => b"defs".to_string(),
        _ => abort 0,
    }
}

/// Print the container as an `SVG` element.
public fun to_string(container: &Container): String {
    let (name, attributes, elements) = match (container) {
        // Desc is a special case, it's just a list of descriptions.
        Container::Desc(tags) => {
            return (*tags).fold!(b"".to_string(), |mut svg, tag| {
                svg.append(tag.to_string());
                svg
            })
        },
        // Root is a special case, we append all elements directly.
        Container::Root(shapes) => {
            return (*shapes).fold!(b"".to_string(), |mut svg, shape| {
                svg.append(shape.to_string());
                svg
            })
        },
        Container::Defs(shapes) => (
            b"defs",
            vec_map::empty(),
            shapes.map_ref!(|shape| shape.to_string()),
        ),
        Container::A(href, shapes, attrs) => {
            let mut attrs = *attrs;
            attrs.insert(b"href".to_string(), *href);
            (b"a", attrs, shapes.map_ref!(|shape| shape.to_string()))
        },
        Container::G(shapes, attrs) => (b"g", *attrs, shapes.map_ref!(|shape| shape.to_string())),
        _ => abort ENotImplemented,
    };

    print::print(name.to_string(), attributes, option::some(elements))
}

#[test_only]
/// Print the `Container` as a string to console in tests.
public fun debug(self: &Container) { std::debug::print(&to_string(self)); }
