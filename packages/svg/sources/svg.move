// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: svg
module svg::svg {
    use std::string::String;
    use sui::vec_map;
    use svg::container::{Self, Container};
    use svg::shape::{Self, Shape};
    use svg::print;

    /// The base SVG element.
    public struct Svg has store, copy, drop {
        width: u64,
        height: u64,
        view_box: vector<u64>,
        elements: vector<Container>,
    }

    /// Create a new SVG element.
    public fun svg(width: u64, height: u64, view_box: vector<u64>): Svg {
        assert!(view_box.length() == 4 || view_box.length() == 0);

        Svg {
            width,
            height,
            view_box,
            elements: vector[],
        }
    }

    /// Add a root container to the SVG.
    public fun root(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
        svg.add(container::root(shapes));
        svg
    }

    /// Add a group container to the SVG.
    public fun g(svg: &mut Svg, shapes: vector<Shape>): &mut Svg {
        svg.add(container::g(shapes));
        svg
    }

    public fun to_string(svg: &Svg): String {
        let mut attributes = vec_map::empty();
        attributes.insert(b"width".to_string(), print::num_to_string(svg.width));
        attributes.insert(b"height".to_string(), print::num_to_string(svg.height));

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

    /// Internal function to add an element to the SVG.
    fun add(svg: &mut Svg, element: Container) {
        svg.elements.push_back(element);
    }

    #[test]
    fun test_svg() {
        let mut svg = svg(100, 100, vector[0, 0, 100, 100]);
        let text = svg
            .root(vector[
                shape::circle(50, 50, 40),
                shape::rect(10, 10, 80, 80),
            ])
            .root(vector[
                shape::ellipse(50, 50, 40, 20),
                shape::line(10, 10, 90, 90),
            ])
            .to_string();

        std::debug::print(&text)
    }
}
