// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

#[test_only]
module svg::svg_tests {
    use svg::svg;
    use svg::shape;
    use svg::container;

    const ENotImplemented: u64 = 0;

    #[test]
    // character is a 9x13 rectangle with head, body, hands, and legs
    fun test_character() {
        let mut svg = svg::svg(vector[0, 0, 9, 13]);

        // head
        let head = shape::rect(3, 3, 3, 3).map_attributes!(
            |attrs| attrs.insert(b"fill".to_string(), b"orange".to_string()),
        );

        // body
        let body = shape::rect(3, 6, 3, 3).map_attributes!(
            |attrs| attrs.insert(b"fill".to_string(), b"black".to_string()),
        );

        // hands (a container already!)
        let mut hands = container::g(vector[
            shape::rect(2, 6, 1, 3), // left hand
            shape::rect(6, 6, 1, 3), // right hand
        ]);

        hands.attributes_mut().insert(b"fill".to_string(), b"black".to_string());

        // legs
        let mut legs = container::g(vector[
            shape::rect(3, 9, 1, 3), // left leg
            shape::rect(4, 9, 1, 1), // middle
            shape::rect(5, 9, 1, 3), // right leg
        ]);

        legs.attributes_mut().insert(b"fill".to_string(), b"black".to_string());

        svg.root(vector[head, body]).add(hands).add(legs);
        std::debug::print(&svg.to_string().as_bytes().length());
        svg.debug()
    }

    #[test, expected_failure(abort_code = ::svg::svg_tests::ENotImplemented)]
    fun test_svg_fail() {
        abort ENotImplemented
    }
}
