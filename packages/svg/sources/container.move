// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: container
module svg::container;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{animation::Animation, desc::Desc, print, shape::Shape};

/// Code for the `NotImplemented` error.
const ENotImplemented: u64 = 0;

/// Represents an SVG container, which contains shapes. All of the containers
/// support `Shape`s placed inside them, and most of them support attributes,
/// which will be rendered as XML attributes in the SVG output.
///
/// Containers are created via one of:
/// - `container::root` - no container, just a list of shapes.
/// - `container::a` - hyperlink container, `<a>`.
/// - `container::defs` - definition container, `<defs>`, to be used for reusable shapes.
/// - `container::g` - group container, `<g>`, to group shapes.
/// - `container::marker` - marker container, `<marker>`, to define a marker symbol.
/// - `container::symbol` - symbol container, `<symbol>`, to define a reusable graphic.
public struct Container has store, copy, drop {
    container: ContainerType,
    shapes: vector<Shape>,
    attributes: VecMap<String, String>,
    animation: Option<Animation>,
    desc: vector<Desc>,
}

/// SVG container enum, which contains shapes.
/// - using `None` - no container, just a list of shapes.
/// - hyperlink container, `<a>`.
/// - definition container, `<defs>`, to be used for reusable shapes.
/// - group container, `<g>`, to group shapes.
public enum ContainerType has store, copy, drop {
    Root,
    Defs,
    A,
    G,
    Marker,
    ClipPath,
}

/// Create a new root container, no container, just a list of shapes.
///
/// ## Description
///
/// Used to place shapes directly in the root of the SVG.
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
///
/// svg.add_root(vector[
///     shape::circle(5),
///     shape::ellipse(30, 30, 10, 5),
/// ]);
///
/// let str = svg.to_string();
/// ```
public fun root(shapes: vector<Shape>): Container {
    Container {
        container: ContainerType::Root,
        shapes,
        attributes: vec_map::empty(),
        animation: option::none(),
        desc: vector[],
    }
}

/// Create a new hyperlink container.
///
/// ## Description
///
/// Hyperlink container, `<a>`. Must be initialized with an `href`.
///
/// - Element: `<a>`.
/// - Own properties: `href`.
/// - Extended properties: None.
///
/// See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/a).
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// let link = container::a(b"https://example.com".to_string(), vector[
///     shape::circle(5),
/// ]);
///
/// svg.add(link); // or svg.a(vector[ /* ... */ ]);
/// let str = svg.to_string();
/// ```
public fun a(href: String, shapes: vector<Shape>): Container {
    let mut attributes = vec_map::empty();
    if (href.length() > 0) {
        attributes.insert(b"href".to_string(), href);
    };

    Container {
        container: ContainerType::A,
        shapes,
        attributes,
        animation: option::none(),
        desc: vector[],
    }
}

/// Create a new `Defs` container.
///
/// ## Description
///
/// A `<defs>` container, to be used for reusable shapes. It's like a
// dictionary of shapes.
///
/// - Element: `<defs>`.
/// - Own properties: None.
/// - Extended properties: None.
///
/// See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/defs).
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// let defs = container::defs(vector[
///   shape::circle(5),
///   shape::ellipse(30, 30, 10, 5),
/// ]);
///
/// svg.add(defs); // or svg.add_defs(vector[ /* ... */ ]);
/// let str = svg.to_string();
/// ```
public fun defs(shapes: vector<Shape>): Container {
    Container {
        container: ContainerType::Defs,
        shapes,
        attributes: vec_map::empty(),
        animation: option::none(),
        desc: vector[],
    }
}

/// Create a new `G` container.
///
/// ## Description
///
/// Group container, `<g>`, to group shapes and apply transformations to groups
/// of elements.
///
/// - Element: `<g>`.
/// - Own properties: None.
/// - Extended properties: None.
///
/// See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/g).
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
///
/// // Create a group of shapes.
/// let mut group = container::g(vector[
///   shape::circle(5),
///   shape::ellipse(30, 30, 10, 5),
/// ]);
///
/// group.attributes_mut().insert(b"fill".to_string(), b"red".to_string());
///
/// svg.add(group); // // or svg.add_g(vector[ /* ... */ ]);
/// let str = svg.to_string();
/// ```
public fun g(shapes: vector<Shape>): Container {
    Container {
        container: ContainerType::G,
        shapes,
        attributes: vec_map::empty(),
        animation: option::none(),
        desc: vector[],
    }
}

/// Create a new `_Marker` container.
///
/// ## Description
/// Marker container, `<marker>`, to define a marker symbol.
/// - Element: `<marker>`.
/// - Own properties: None.
/// - Extended properties: None.
///
/// See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/marker).
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// let marker = container::marker(vector[
///    shape::circle(5),
///    shape::ellipse(30, 30, 10, 5),
/// ]);
///
/// svg.add(marker); // or svg.marker(vector[ /* ... */ ]);
/// let str = svg.to_string();
/// ```
public fun marker(_shapes: vector<Shape>): Container { abort ENotImplemented }

/// Create a new `ClipPath` container.
///
/// ## Description
/// ClipPath container, `<clipPath>`, to define a clipping path.
/// - Element: `<clipPath>`.
/// - Own properties: None.
/// - Extended properties: None.
///
/// See [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/clipPath).
///
/// ## Usage
///
/// ```rust
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// let clip_path = container::clip_path(vector[
///   shape::circle(5),
/// ]);
/// svg.add(clip_path); // or svg.clip_path(vector[ /* ... */ ]);
/// let str = svg.to_string();
/// ```
public fun clip_path(shapes: vector<Shape>): Container {
    Container {
        container: ContainerType::ClipPath,
        shapes,
        attributes: vec_map::empty(),
        animation: option::none(),
        desc: vector[],
    }
}

/// Move a container, keep the interface consistent with shapes.
public fun move_to(container: Container, x: u16, y: u16): Container {
    container.map_attributes!(|attributes| {
        let x_key = b"x".to_string();
        let y_key = b"y".to_string();

        if (attributes.contains(&x_key)) {
            attributes.remove(&x_key);
        };

        if (attributes.contains(&y_key)) {
            attributes.remove(&y_key);
        };

        attributes.insert(x_key, x.to_string());
        attributes.insert(y_key, y.to_string());
    })
}

/// Add a shape to a container.
public fun add(container: &mut Container, shape: Shape) {
    container.shapes.push_back(shape);
}

/// Access Option with `Animation`, fill, extract and so on.
public fun animation_mut(container: &mut Container): &mut Option<Animation> {
    &mut container.animation
}

/// Get a mutable reference to the attributes of a container.
public fun attributes_mut(container: &mut Container): &mut VecMap<String, String> {
    &mut container.attributes
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
    match (&container.container) {
        // ContainerType::Desc(..) => b"".to_string(),
        ContainerType::Root => b"".to_string(),
        ContainerType::A => b"a".to_string(),
        ContainerType::G => b"g".to_string(),
        ContainerType::Defs => b"defs".to_string(),
        ContainerType::Marker => b"marker".to_string(),
        // Container::Symbol(..) => b"symbol".to_string(),
        _ => abort 0,
    }
}

/// Print the container as an `SVG` element.
public fun to_string(container: &Container): String {
    if (container.container == ContainerType::Root) {
        return container.shapes.fold!(b"".to_string(), |mut acc, shape| {
            acc.append(shape.to_string());
            acc
        })
    };

    let mut contents = container.shapes.map!(|shape| shape.to_string());
    container.animation.do_ref!(|animation| contents.push_back(animation.to_string()));

    print::print(
        container.name(),
        container.attributes,
        option::some(contents),
    )
}

#[test_only]
/// Print the `Container` as a string to console in tests.
public fun debug(self: &Container) { std::debug::print(&to_string(self)); }
