// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: container
module svg::container {
    use std::string::String;
    use sui::vec_map;
    use svg::print;
    use svg::shape::Shape;

    /// Code for the `NotImplemented` error.
    const ENotImplemented: u64 = 0;

    /// SVG container enum, which contains shapes.
    /// - using `None` - no container, just a list of shapes.
    /// - hyperlink container, `<a>`.
    /// - definition container, `<defs>`, to be used for reusable shapes.
    /// - group container, `<g>`, to group shapes.
    public enum Container has store, copy, drop {
        Root(vector<Shape>),
        A(String),
        Defs(vector<Shape>),
        G(vector<Shape>),
        _Marker(vector<Shape>),
    }

    /// Create a new root container, no container, just a list of shapes.
    public fun root(shapes: vector<Shape>): Container { Container::Root(shapes) }

    /// Create a new hyperlink container.
    public fun a(href: String): Container { Container::A(href) }

    /// Create a new `Defs` container.
    public fun defs(shapes: vector<Shape>): Container { Container::Defs(shapes) }

    /// Create a new `G` container.
    public fun g(shapes: vector<Shape>): Container { Container::G(shapes) }

    /// Create a new `_Marker` container.
    public fun marker(_shapes: vector<Shape>): Container { abort ENotImplemented }

    /// Move a container, keep the interface consistent with shapes.
    public fun move_to(container: Container, _x: u16, _y: u16): Container { container }

    /// Print the container as an `SVG` element.
    public fun to_string(container: &Container): String {
        let (name, elements) = match (container) {
            // Root is a special case, it's just a list of shapes.
            Container::Root(shapes) => {
                let mut svg = b"".to_string();
                shapes.do_ref!(|shape| svg.append(shape.to_string()));
                return svg
            },
            Container::A(_href) => (b"a", vector[]),
            Container::Defs(shapes) => (b"defs", shapes.map_ref!(|shape| shape.to_string())),
            Container::G(shapes) => (b"g", shapes.map_ref!(|shape| shape.to_string())),
            _ => abort ENotImplemented
        };

        print::print(name.to_string(), vec_map::empty(), option::some(elements))
    }
}
