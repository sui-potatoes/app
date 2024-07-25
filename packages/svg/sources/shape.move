// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shape {
    use std::string::String;
    use sui::vec_map::{Self, VecMap};
    use svg::print;

    /// SVG shape struct, contains a shape type and a set of attributes.
    public struct Shape has store, copy, drop {
        shape: Type,
        attributes: VecMap<String, String>,
    }

    /// SVG shape enum. Each variant represents a different shape, all of them
    /// containing a set of attributes as a `VecMap`.
    public enum Type has store, copy, drop {
        Circle(u16, u16, u16),
        Ellipse(u16, u16, u16, u16),
        Line(u16, u16, u16, u16),
        Polygon(u16, u16, u16, u16),
        Polyline(u16, u16, u16, u16),
        Rect(u16, u16, u16, u16),
        Text(String, u16, u16),
        Path(String, Option<u16>),
        Use(String),
        Custom(String),
    }

    /// Create a new circle shape.
    public fun circle(cx: u16, cy: u16, r: u16): Shape {
        Shape {
            shape: Type::Circle(cx, cy, r),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new ellipse shape.
    public fun ellipse(cx: u16, cy: u16, rx: u16, ry: u16): Shape {
        Shape {
            shape: Type::Ellipse(cx, cy, rx, ry),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new line shape.
    public fun line(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape {
            shape: Type::Line(x1, y1, x2, y2),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new polygon shape.
    public fun polygon(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape {
            shape: Type::Polygon(x1, y1, x2, y2),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new polyline shape.
    public fun polyline(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
        Shape {
            shape: Type::Polyline(x1, y1, x2, y2),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new rectangle shape.
    public fun rect(x: u16, y: u16, width: u16, height: u16): Shape {
        Shape {
            shape: Type::Rect(x, y, width, height),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new `<text>` shape.
    public fun text(text: String, x: u16, y: u16): Shape {
        Shape {
            shape: Type::Text(text, x, y),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new `<path>` shape.
    public fun path(path: String, length: Option<u16>): Shape {
        Shape {
            shape: Type::Path(path, length),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new `<use>` shape.
    public fun use_(href: String): Shape {
        Shape {
            shape: Type::Use(href),
            attributes: vec_map::empty(),
        }
    }

    /// Create a new custom shape.
    public fun custom(text: String): Shape {
        Shape {
            shape: Type::Custom(text),
            attributes: vec_map::empty(),
        }
    }

    /// Move a shape.
    public fun move_to(shape: &mut Shape, x: u16, y: u16) {
        let shape_type = &mut shape.shape;
        match (shape_type) {
            Type::Circle(cx, cy, _) => { *cx = x; *cy = y; },
            Type::Ellipse(cx, cy, _, _) => { *cx = x; *cy = y; },
            Type::Line(x1, y1, x2, y2) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Type::Polygon(x1, y1, x2, y2) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Type::Polyline(x1, y1, x2, y2) => {
                *x2 = *x2 - *x1 + x;
                *y2 = *y2 - *y1 + y;
                *x1 = x;
                *y1 = y;
            },
            Type::Rect(ox, oy, _, _) => { *ox = x; *oy = y; },
            Type::Text(_, ox, oy) => { *ox = x; *oy = y; },
            Type::Use(_) => {
                shape.attributes.insert(b"x".to_string(), print::num_to_string(x));
                shape.attributes.insert(b"y".to_string(), print::num_to_string(y));
            },
            Type::Custom(_) => {},
            Type::Path(_, _) => {},
            _ => abort 0,
        };
    }

    /// Print the shape as an `SVG` element.
    public fun to_string(shape: &Shape): String {
        let Shape { shape, attributes: attrs } = shape;
        let (name, attributes, contents) = match (shape) {
            Type::Circle(cx, cy, r) => {
                let mut map = *attrs;
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"r".to_string(), print::num_to_string(*r));
                (b"circle", map, option::none())
            },
            Type::Ellipse(cx, cy, rx, ry) => {
                let mut map = *attrs;
                map.insert(b"cx".to_string(), print::num_to_string(*cx));
                map.insert(b"cy".to_string(), print::num_to_string(*cy));
                map.insert(b"rx".to_string(), print::num_to_string(*rx));
                map.insert(b"ry".to_string(), print::num_to_string(*ry));
                (b"ellipse", map, option::none())
            },
            Type::Line(x1, y1, x2, y2) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"line", map, option::none())
            },
            Type::Polygon(x1, y1, x2, y2) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"polygon", map, option::none())
            },
            Type::Polyline(x1, y1, x2, y2) => {
                let mut map = *attrs;
                map.insert(b"x1".to_string(), print::num_to_string(*x1));
                map.insert(b"y1".to_string(), print::num_to_string(*y1));
                map.insert(b"x2".to_string(), print::num_to_string(*x2));
                map.insert(b"y2".to_string(), print::num_to_string(*y2));
                (b"polyline", map, option::none())
            },
            Type::Rect(x, y, width, height) => {
                let mut map = *attrs;
                map.insert(b"x".to_string(), print::num_to_string(*x));
                map.insert(b"y".to_string(), print::num_to_string(*y));
                map.insert(b"width".to_string(), print::num_to_string(*width));
                map.insert(b"height".to_string(), print::num_to_string(*height));
                (b"rect", map, option::none())
            },
            Type::Text(text, x, y) => {
                let mut map = *attrs;
                map.insert(b"x".to_string(), print::num_to_string(*x));
                map.insert(b"y".to_string(), print::num_to_string(*y));
                (b"text", map, option::some(vector[*text]))
            },
            Type::Use(href) => {
                let mut map = *attrs;
                map.insert(b"href".to_string(), *href);
                (b"use", map, option::none())
            },
            Type::Path(path, length) => {
                let mut map = *attrs;
                map.insert(b"d".to_string(), *path);
                length.do_ref!(
                    |value| map.insert(
                        b"length".to_string(),
                        print::num_to_string(*value),
                    ),
                );
                (b"path", map, option::none())
            },
            Type::Custom(text) => return *text,
        };

        print::print(name.to_string(), attributes, contents)
    }

    /// Get a reference to the attributes of a shape.
    public fun attributes(shape: &Shape): &VecMap<String, String> {
        &shape.attributes
    }

    /// Get a mutable reference to the attributes of a shape.
    public fun attributes_mut(shape: &mut Shape): &mut VecMap<String, String> {
        &mut shape.attributes
    }

    /// Set the attributes of a shape.
    public fun set_attributes(shape: &mut Shape, attrs: VecMap<String, String>) {
        shape.attributes = attrs;
    }

    /// Map over the attributes of a shape.
    public macro fun map_attributes($shape: Shape, $f: |&mut VecMap<String, String>|): Shape {
        let mut shape = $shape;
        $f(shape.attributes_mut());
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
        assert!(text(b"Hello, World!".to_string(), 10, 10).to_string() == b"<text x='10' y='10'>Hello, World!</text>".to_string());
        assert!(use_(b"#circle".to_string()).to_string() == b"<use href='#circle'/>".to_string());
        assert!(custom(b"<custom/>".to_string()).to_string() == b"<custom/>".to_string());
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

        let mut text = text(b"Hello, World!".to_string(), 10, 10);
        text.move_to(5, 5);
        assert_eq(text.to_string(), b"<text x='5' y='5'>Hello, World!</text>".to_string());

        let mut use_ = use_(b"#circle".to_string());
        use_.move_to(5, 5);
        assert_eq(use_.to_string(), b"<use x='5' y='5' href='#circle'/>".to_string());
    }
}
