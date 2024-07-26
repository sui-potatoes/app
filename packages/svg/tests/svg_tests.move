// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[test_only]
module svg::svg_tests {
    use svg::svg;
    use svg::shape;
    use svg::container;
    use svg::macros::{add_class, add_attribute};

    const ENotImplemented: u64 = 0;

    #[test]
    // character is a 9x13 rectangle with head, body, hands, and legs
    fun test_character() {
        let mut svg = svg::svg(vector[0, 0, 9, 13]);

        // head
        let mut head = shape::rect(3, 3, 3, 3);
        add_class!(&mut head, b"head");
        add_attribute!(&mut head, b"fill", b"orange");

        // body
        let mut body = shape::rect(3, 6, 3, 3);
        add_class!(&mut body, b"body");
        add_attribute!(&mut body, b"fill", b"blue");

        // hands (a container already!)
        let mut hands = container::g(vector[
            shape::rect(2, 6, 1, 3), // left hand
            shape::rect(6, 6, 1, 3), // right hand
        ]);

        add_class!(&mut hands, b"hand");
        add_attribute!(&mut hands, b"fill", b"black");

        // legs
        let mut legs = container::g(vector[
            shape::rect(3, 9, 1, 3), // left leg
            shape::rect(4, 9, 1, 1), // middle
            shape::rect(5, 9, 1, 3), // right leg
        ]);

        add_attribute!(&mut legs, b"fill", b"black");

        svg.root(vector[head, body]).add(hands).add(legs);
        std::debug::print(&svg.to_string().as_bytes().length());
        svg.debug()
    }

    #[test, expected_failure(abort_code = ::svg::svg_tests::ENotImplemented)]
    fun test_svg_fail() {
        abort ENotImplemented
    }
}
