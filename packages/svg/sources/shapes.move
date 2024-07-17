// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shapes {
    use std::string::String;
    use sui::vec_map;
    use svg::print;

    /// SVG shape enum.
    public enum Shape has store, copy, drop {
        Circle(u64, u64, u64),
        Ellipse(u64, u64, u64, u64),
        Line(u64, u64, u64, u64),
        Polygon(u64, u64, u64, u64),
        Polyline(u64, u64, u64, u64),
        Rect(u64, u64, u64, u64),
    }

    /// Create a new circle shape.
    public fun circle(cx: u64, cy: u64, r: u64): Shape { Shape::Circle(cx, cy, r) }

    /// Create a new ellipse shape.
    public fun ellipse(cx: u64, cy: u64, rx: u64, ry: u64): Shape { Shape::Ellipse(cx, cy, rx, ry) }

    /// Create a new line shape.
    public fun line(x1: u64, y1: u64, x2: u64, y2: u64): Shape { Shape::Line(x1, y1, x2, y2) }

    /// Create a new polygon shape.
    public fun polygon(x1: u64, y1: u64, x2: u64, y2: u64): Shape { Shape::Polygon(x1, y1, x2, y2) }

    /// Create a new polyline shape.
    public fun polyline(x1: u64, y1: u64, x2: u64, y2: u64): Shape {
        Shape::Polyline(x1, y1, x2, y2)
    }

    /// Create a new rectangle shape.
    public fun rect(x: u64, y: u64, width: u64, height: u64): Shape {
        Shape::Rect(x, y, width, height)
    }

    /// Move a shape.
    public fun move_to(shape: Shape, x: u64, y: u64): Shape {
        match (shape) {
            Shape::Circle(cx, cy, r) => Shape::Circle(cx + x, cy + y, r),
            Shape::Ellipse(cx, cy, rx, ry) => Shape::Ellipse(cx + x, cy + y, rx, ry),
            Shape::Line(x1, y1, x2, y2) => Shape::Line(x1 + x, y1 + y, x2 + x, y2 + y),
            Shape::Polygon(x1, y1, x2, y2) => Shape::Polygon(x1 + x, y1 + y, x2 + x, y2 + y),
            Shape::Polyline(x1, y1, x2, y2) => Shape::Polyline(x1 + x, y1 + y, x2 + x, y2 + y),
            Shape::Rect(x, y, width, height) => Shape::Rect(x + x, y + y, width, height),
        }
    }

    public fun print(shape: &Shape): String {
        let mut map = vec_map::empty();
        let name = match (shape) {
            Shape::Circle(cx, cy, r) => {
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"r".to_string(), print::num_to_string(*r));
                b"circle"
            },
            Shape::Ellipse(cx, cy, rx, ry) => {
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"rx".to_string(), print::num_to_string(*rx));
                map.insert(b"ry".to_string(), print::num_to_string(*ry));
                b"ellipse"
            },
            Shape::Line(x1, y1, x2, y2) => {
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                b"line"
            },
            Shape::Polygon(x1, y1, x2, y2) => {
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                b"polygon"
            },
            Shape::Polyline(x1, y1, x2, y2) => {
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                b"polyline"
            },
            Shape::Rect(x, y, width, height) => {
                map.insert(b"x".to_string(), print::num_to_string(*x));
                map.insert(b"y".to_string(), print::num_to_string(*y));
                map.insert(b"width".to_string(), print::num_to_string(*width));
                map.insert(b"height".to_string(), print::num_to_string(*height));
                b"rect"
            },
        };

        print::print(name.to_string(), map, option::none())
    }

    #[test]
    // prettier-ignore
    fun test_shapes() {
        assert!(circle(10, 10, 5).print() == b"<circle cx=\"10\" cy=\"10\" r=\"5\" />".to_string());
        assert!(ellipse(10, 10, 5, 5).print() == b"<ellipse cx=\"10\" cy=\"10\" rx=\"5\" ry=\"5\" />".to_string());
        assert!(line(10, 10, 20, 20).print() == b"<line x1=\"10\" y1=\"10\" x2=\"20\" y2=\"20\" />".to_string());
        assert!(polygon(10, 10, 20, 20).print() == b"<polygon x1=\"10\" y1=\"10\" x2=\"20\" y2=\"20\" />".to_string());
        assert!(polyline(10, 10, 20, 20).print() == b"<polyline x1=\"10\" y1=\"10\" x2=\"20\" y2=\"20\" />".to_string());
        assert!(rect(10, 10, 20, 20).print() == b"<rect x=\"10\" y=\"10\" width=\"20\" height=\"20\" />".to_string());
    }

    #[test]
    // prettier-ignore
    fun test_move() {
        assert!(circle(10, 10, 5).move_to(5, 5).print() == b"<circle cx=\"15\" cy=\"15\" r=\"5\" />".to_string());
        assert!(ellipse(10, 10, 5, 5).move_to(5, 5).print() == b"<ellipse cx=\"15\" cy=\"15\" rx=\"5\" ry=\"5\" />".to_string());
        assert!(line(10, 10, 20, 20).move_to(5, 5).print() == b"<line x1=\"15\" y1=\"15\" x2=\"25\" y2=\"25\" />".to_string());
        assert!(polygon(10, 10, 20, 20).move_to(5, 5).print() == b"<polygon x1=\"15\" y1=\"15\" x2=\"25\" y2=\"25\" />".to_string());
        assert!(polyline(10, 10, 20, 20).move_to(5, 5).print() == b"<polyline x1=\"15\" y1=\"15\" x2=\"25\" y2=\"25\" />".to_string());
        assert!(rect(10, 10, 20, 20).move_to(5, 5).print() == b"<rect x=\"15\" y=\"15\" width=\"20\" height=\"20\" />".to_string());
    }
}
