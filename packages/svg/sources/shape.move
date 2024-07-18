// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shape {
    use std::string::String;
    use sui::vec_map::{Self, VecMap};
    use svg::print;

    /// SVG shape enum. Each variant represents a different shape, all of them
    /// containing a set of attributes as a `VecMap`.
    public enum Shape has store, copy, drop {
        Circle(u16, u16, u16, VecMap<String, String>),
        Ellipse(u16, u16, u16, u16, VecMap<String, String>),
        Line(u16, u16, u16, u16, VecMap<String, String>),
        Polygon(u16, u16, u16, u16, VecMap<String, String>),
        Polyline(u16, u16, u16, u16, VecMap<String, String>),
        Rect(u16, u16, u16, u16, VecMap<String, String>),
    }

    /// Create a new circle shape.
    public fun circle(cx: u16, cy: u16, r: u16): Shape {
        Shape::Circle(cx, cy, r, vec_map::empty())
    }

    /// Create a new ellipse shape.
    public fun ellipse(cx: u16, cy: u16, rx: u16, ry: u16): Shape {
        Shape::Ellipse(cx, cy, rx, ry, vec_map::empty())
    }

    /// Create a new line shape.
    public fun line(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape::Line(x1, y1, x2, y2, vec_map::empty())
    }

    /// Create a new polygon shape.
    public fun polygon(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape::Polygon(x1, y1, x2, y2, vec_map::empty())
    }

    /// Create a new polyline shape.
    public fun polyline(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape::Polyline(x1, y1, x2, y2, vec_map::empty())
    }

    /// Create a new rectangle shape.
    public fun rect(x: u16, y: u16, width: u16, height: u16): Shape {
        Shape::Rect(x, y, width, height, vec_map::empty())
    }

    /// Move a shape.
    public fun move_to(shape: &mut Shape, x: u16, y: u16) {
        match (shape) {
            Shape::Circle(cx, cy, _, _) => { *cx = x; *cy = y; },
            Shape::Ellipse(cx, cy, _, _, _) => { *cx = x; *cy = y; },
            Shape::Line(x1, y1, x2, y2, _) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Shape::Polygon(x1, y1, x2, y2, _) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Shape::Polyline(x1, y1, x2, y2, _) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Shape::Rect(ox, oy, _, _, _) => { *ox = x; *oy = y; },
        };
    }

    /// Print the shape as an `SVG` element.
    public fun to_string(shape: &Shape): String {
        let (name, attributes) = match (shape) {
            Shape::Circle(cx, cy, r, attrs) => {
                let mut map = *attrs;
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"r".to_string(), print::num_to_string(*r));
                (b"circle", map)
            },
            Shape::Ellipse(cx, cy, rx, ry, attrs) => {
                let mut map = *attrs;
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"rx".to_string(), print::num_to_string(*rx));
                map.insert(b"ry".to_string(), print::num_to_string(*ry));
                (b"ellipse", map)
            },
            Shape::Line(x1, y1, x2, y2, attrs) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"line", map)
            },
            Shape::Polygon(x1, y1, x2, y2, attrs) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"polygon", map)
            },
            Shape::Polyline(x1, y1, x2, y2, attrs) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"polyline", map)
            },
            Shape::Rect(x, y, width, height, attrs) => {
                let mut map = *attrs;
                map.insert(b"x".to_string(), print::num_to_string(*x));
                map.insert(b"y".to_string(), print::num_to_string(*y));
                map.insert(b"width".to_string(), print::num_to_string(*width));
                map.insert(b"height".to_string(), print::num_to_string(*height));
                (b"rect", map)
            },
        };

        print::print(name.to_string(), attributes, option::none())
    }

    /// Get a mutable reference (!) to the attributes of a shape. This allows to
    /// add custom attributes without writing too much boilerplate.
    ///
    /// `_mut` suffix is intentionally omitted to make the function name shorter.
    public fun attributes(shape: &mut Shape): &mut VecMap<String, String> {
        match (shape) {
            Shape::Circle(_, _, _, attrs) => attrs,
            Shape::Ellipse(_, _, _, _, attrs) => attrs,
            Shape::Line(_, _, _, _, attrs) => attrs,
            Shape::Polygon(_, _, _, _, attrs) => attrs,
            Shape::Polyline(_, _, _, _, attrs) => attrs,
            Shape::Rect(_, _, _, _, attrs) => attrs,
        }
    }

    /// Map over the attributes of a shape.
    public macro fun map_attributes($shape: Shape, $f: |VecMap<String, String>| -> ()): Shape {
        let shape = $shape;
        let attrs = attributes(shape);
        $f(attrs);
        shape
    }

    #[test]
    // prettier-ignore
    fun test_shapes() {
        assert!(circle(10, 10, 5).to_string() == b"<circle cx='10' cy='10' r='5'/>".to_string());
        assert!(ellipse(10, 10, 5, 5).to_string() == b"<ellipse cx='10' cy='10' rx='5' ry='5'/>".to_string());
        assert!(line(10, 10, 20, 20).to_string() == b"<line x1='10' y1='10' x2='20' y2='20'/>".to_string());
        assert!(polygon(10, 10, 20, 20).to_string() == b"<polygon x1='10' y1='10' x2='20' y2='20'/>".to_string());
        assert!(polyline(10, 10, 20, 20).to_string() == b"<polyline x1='10' y1='10' x2='20' y2='20'/>".to_string());
        assert!(rect(10, 10, 20, 20).to_string() == b"<rect x='10' y='10' width='20' height='20'/>".to_string());
    }

    #[test]
    // prettier-ignore
    fun test_move_to() {
        use sui::test_utils::assert_eq;

        let mut circle = circle(10, 10, 5);
        circle.move_to(5, 5);
        assert_eq(circle.to_string(), b"<circle cx='5' cy='5' r='5'/>".to_string());

        let mut ellipse = ellipse(10, 10, 5, 5);
        ellipse.move_to(5, 5);
        assert_eq(ellipse.to_string(), b"<ellipse cx='5' cy='5' rx='5' ry='5'/>".to_string());

        let mut line = line(10, 10, 20, 20);
        line.move_to(5, 5);
        assert_eq(line.to_string(), b"<line x1='5' y1='5' x2='15' y2='15'/>".to_string());

        let mut polygon = polygon(10, 10, 20, 20);
        polygon.move_to(5, 5);
        assert_eq(polygon.to_string(), b"<polygon x1='5' y1='5' x2='15' y2='15'/>".to_string());

        let mut polyline = polyline(10, 10, 20, 20);
        polyline.move_to(5, 5);
        assert_eq(polyline.to_string(), b"<polyline x1='5' y1='5' x2='15' y2='15'/>".to_string());

        let mut rect = rect(10, 10, 20, 20);
        rect.move_to(5, 5);
        assert_eq(rect.to_string(), b"<rect x='5' y='5' width='20' height='20'/>".to_string());
    }
}
