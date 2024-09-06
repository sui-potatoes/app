// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shape;

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
    /// Circle shape, a circle with a center and a radius.
    /// - `cx` - the x-coordinate of the center of the circle.
    /// - `cy` - the y-coordinate of the center of the circle.
    /// - `r` - the radius of the circle.
    Circle(u16, u16, u16),
    /// Ellipse shape, a circle that is stretched in one direction.
    /// - `cx` - the x-coordinate of the center of the ellipse.
    /// - `cy` - the y-coordinate of the center of the ellipse.
    /// - `rx` - the radius of the ellipse in the x-axis.
    /// - `ry` - the radius of the ellipse in the y-axis.
    Ellipse(u16, u16, u16, u16),
    /// Line shape, a line that connects two points, each point is a pair
    /// of `x` and `y`.
    Line(u16, u16, u16, u16),
    /// Polygon shape, a closed shape that connects multiple points. With
    /// straight lines between each pair of points.
    Polygon(vector<vector<u16>>),
    /// Polyline shape, a line that connects multiple points.
    /// - `vector<u16>` - a list of points, each point is a pair of `x` and `y`.
    Polyline(vector<vector<u16>>), // TODO: Add more points.,
    /// Rectangle shape, a rectangle with a position, width, and height.
    /// - `x` - the x-coordinate of the top-left corner of the rectangle.
    /// - `y` - the y-coordinate of the top-left corner of the rectangle.
    /// - `width` - the width of the rectangle.
    /// - `height` - the height of the rectangle.
    Rect(u16, u16, u16, u16),
    /// Text shape, a text element with a string and a position.
    Text(String, u16, u16),
    /// Path shape, a shape defined by a path string. The path string is
    /// a series of commands and coordinates. The `length` attribute is
    /// optional and specifies the total length of the path.
    Path(String, Option<u16>),
    /// Use shape, a reference to a shape defined elsewhere in the document.
    /// - `href` - the id of the shape to reference.
    Use(String),
    /// Custom shape, a custom shape defined by a `String` of SVG code.
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
public fun polygon(points: vector<vector<u16>>): Shape {
    points.do_ref!(|point| assert!(point.length() == 2));

    Shape {
        shape: Type::Polygon(points),
        attributes: vec_map::empty(),
    }
}

/// Create a new polyline shape.
public fun polyline(points: vector<vector<u16>>): Shape {
    points.do_ref!(|point| assert!(point.length() == 2));

    Shape {
        shape: Type::Polyline(points),
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
        Type::Circle(cx, cy, _) => {
            *cx = x;
            *cy = y;
        },
        Type::Ellipse(cx, cy, _, _) => {
            *cx = x;
            *cy = y;
        },
        Type::Line(x1, y1, x2, y2) => {
            *x2 = *x2 - *x1 + x;
            *y2 = *y2 - *y1 + y;
            *x1 = x;
            *y1 = y;
        },
        Type::Polygon(points) => {
            points.do_mut!(|point| {
                *&mut point[0] = point[0] - point[0] + x;
                *&mut point[1] = point[1] - point[1] + y;
            });
        },
        Type::Polyline(points) => {
            points.do_mut!(|point| {
                *&mut point[0] = point[0] - point[0] + x;
                *&mut point[1] = point[1] - point[1] + y;
            });
        },
        Type::Rect(ox, oy, _, _) => {
            *ox = x;
            *oy = y;
        },
        Type::Text(_, ox, oy) => {
            *ox = x;
            *oy = y;
        },
        Type::Use(_) => {
            shape.attributes.insert(b"x".to_string(), print::num_to_string(x));
            shape.attributes.insert(b"y".to_string(), print::num_to_string(y));
        },
        Type::Custom(_) => {},
        Type::Path(_, _) => {},
        _ => abort 0,
    };
}

/// Simplification to not create functions for each container invariant.
public fun name(shape: &Shape): String {
    match (shape.shape) {
        Type::Circle(..) => b"circle".to_string(),
        Type::Ellipse(..) => b"ellipse".to_string(),
        Type::Line(..) => b"line".to_string(),
        Type::Polygon(..) => b"polygon".to_string(),
        Type::Polyline(..) => b"polyline".to_string(),
        Type::Rect(..) => b"rect".to_string(),
        Type::Text(..) => b"text".to_string(),
        Type::Use(..) => b"use".to_string(),
        Type::Custom(..) => b"custom".to_string(),
        Type::Path(..) => b"path".to_string(),
        _ => abort 0,
    }
}

/// Print the shape as an `SVG` element.
public fun to_string(base_shape: &Shape): String {
    let Shape { shape, attributes: attrs } = base_shape;
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
        Type::Polygon(points) | Type::Polyline(points) => {
            let mut map = *attrs;
            let points = (*points).fold!(b"".to_string(), |mut points, point| {
                points.append(print::num_to_string(point[0]));
                points.append(b",".to_string());
                points.append(print::num_to_string(point[1]));
                points.append(b",".to_string());
                points
            });

            map.insert(b"points".to_string(), points);
            (base_shape.name().into_bytes(), map, option::none())
        },
        Type::Polyline(points) => {
            let mut map = *attrs;
            let points = (*points).fold!(b"".to_string(), |mut points, point| {
                points.append(print::num_to_string(point[0]));
                points.append(b",".to_string());
                points.append(print::num_to_string(point[1]));
                points.append(b",".to_string());
                points
            });

            map.insert(b"points".to_string(), points);
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
