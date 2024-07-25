// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: svg
module svg::svg {
    use std::string::String;
    use sui::vec_map;
    use svg::container::{Self, Container};
    use svg::shape::Shape;
    use svg::print;

    /// The base SVG element.
    public struct Svg has store, copy, drop {
        width: Option<u16>,
        height: Option<u16>,
        view_box: vector<u16>,
        elements: vector<Container>,
    }

    /// Create a new SVG element.
    public fun svg(view_box: vector<u16>): Svg {
        assert!(view_box.length() == 4 || view_box.length() == 0);
        Svg { width: option::none(), height: option::none(), view_box, elements: vector[] }
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

    /// Print the SVG element as a `String`.
    public fun to_string(svg: &Svg): String {
        let mut attributes = vec_map::empty();
        svg
            .width
            .do_ref!(|value| attributes.insert(b"width".to_string(), print::num_to_string(*value)));

        svg
            .height
            .do_ref!(
                |value| attributes.insert(b"height".to_string(), print::num_to_string(*value)),
            );

        if (svg.view_box.length() == 4) {
            let mut view_box = b"".to_string();
            svg
                .view_box
                .do_ref!(
                    |value| {
                        view_box.append(print::num_to_string(*value));
                        view_box.append(b" ".to_string());
                    },
                );
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

        let mut svg = svg(vector[0, 0, 200, 200]);

        svg.root(vector[
            shape::text(b"You won't believe this!".to_string(), 100, 50).map_attributes!(
                |attrs| {
                    attrs.insert(b"fill".to_string(), b"black".to_string());
                    attrs.insert(b"font-size".to_string(), b"20".to_string());
                },
            ),
            shape::circle(10, 10, 5),
            shape::rect(10, 10, 20, 20).map_attributes!(
                |attrs| {
                    attrs.insert(b"fill".to_string(), b"red".to_string());
                    attrs.insert(b"stroke".to_string(), b"black".to_string());
                },
            ),
            shape::ellipse(30, 30, 10, 5),
        ]);

        svg.debug();
    }
}
