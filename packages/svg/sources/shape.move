// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shape;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{animation::Animation, point::{Self, Point}, print};

#[error]
const ENotImplemented: vector<u8> = b"This shape is not implemented yet.";

/// SVG shape struct, contains a shape type and a set of attributes.
public struct Shape has store, copy, drop {
    /// The shape type, such as a circle, rectangle, or path.
    shape: ShapeType,
    /// A set of attributes for the shape.
    attributes: VecMap<String, String>,
    /// An optional animation to apply to the shape.
    animation: Option<Animation>,
    /// An optional position for the shape, changed in the `move_to` function.
    position: Option<Point>,
}

/// SVG shape enum. Each variant represents a different shape, all of them
/// containing a set of attributes as a `VecMap`.
public enum ShapeType has store, copy, drop {
    /// Circle shape, a circle with a center and a radius.
    ///
    /// **Element:** `<circle>`
    ///
    /// **Own properties:**
    /// - `r` - the radius of the circle.
    ///
    /// **Inherited properties:**
    /// - `cx` - the x-coordinate of the circle.
    /// - `cy` - the y-coordinate of the circle.
    ///
    /// **Extended properties:**
    /// - `pathLength` - the total length of the path.
    /// - `transform` - a transformation to apply to the circle.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/circle
    Circle(u16),
    /// Ellipse shape, a circle that is stretched in one direction.
    ///
    /// **Element:** `<ellipse>`
    ///
    /// **Own properties:**
    /// - `pc` - the point of the center of the ellipse.
    /// - `rx` - the radius of the ellipse in the x-axis.
    /// - `ry` - the radius of the ellipse in the y-axis.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the ellipse.
    /// - `y` - the y-coordinate of the ellipse.
    ///
    /// **Extended properties:**
    /// - `pathLength` - the total length of the path.
    /// - `transform` - a transformation to apply to the ellipse.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/ellipse
    Ellipse(Point, u16, u16),
    /// Line shape, a line that connects two points, each point is a pair
    /// of `x` and `y`.
    ///
    /// **Element:** `<line>`
    ///
    /// **Own properties:**
    /// - p0 - the first point.
    /// - p1 - the second point.
    ///
    /// **Extended properties:**
    /// - `pathLength` - the total length of the path.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/line
    Line(Point, Point),
    /// Polygon shape, a closed shape that connects multiple points. With
    /// straight lines between each pair of points.
    ///
    /// **Element:** `<polygon>`
    ///
    /// **Own properties:**
    /// - `vector<u16>` - a list of points, each point is a pair of `x` and `y`.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the polygon.
    /// - `y` - the y-coordinate of the polygon.
    ///
    /// **Extended properties:**
    /// - `pathLength` - the total length of the path.
    Polygon(vector<Point>),
    /// Polyline shape, a line that connects multiple points.
    ///
    /// **Own properties:**
    /// - `vector<u16>` - a list of points, each point is a pair of `x` and `y`.
    ///
    /// **Extended properties:**
    /// - `pathLength` - the total length of the path.
    Polyline(vector<Point>),
    /// Rectangle shape, a rectangle with a position, width, and height.
    ///
    /// **Element:** `<rect>`
    ///
    /// **Own properties:**
    /// - `width` - the width of the rectangle.
    /// - `height` - the height of the rectangle.
    ///
    /// **Extended properties:**
    /// - `rx` - the radius of the rectangle in the x-axis.
    /// - `ry` - the radius of the rectangle in the y-axis.
    /// - `pathLength` - the total length of the path.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/rect
    Rect(u16, u16),
    /// Text shape, a text element with a string and a position.
    ///
    /// **Element:** `<text>`
    ///
    /// **Own properties:**
    /// - `text` - the text to display.
    /// - `path` - an optional `TextPath` element.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the text.
    /// - `y` - the y-coordinate of the text.
    ///
    /// **Extended properties:**
    /// - `dx` - the x-offset of the text.
    /// - `dy` - the y-offset of the text.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text
    Text(String),
    /// Text with text path shape, a text element with a string and a path.
    ///
    /// **Element:** `<text><textPath>` (group)
    ///
    /// **Own properties:**
    /// - `text` - the text to display.
    /// - `path` - the path to follow.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the text.
    /// - `y` - the y-coordinate of the text.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/textPath
    TextWithTextPath { text: String, href: String },
    /// Path shape, a shape defined by a path string. The path string is
    /// a series of commands and coordinates. The `length` attribute is
    /// optional and specifies the total length of the path.
    ///
    /// **Element:** `<path>`
    ///
    /// **Own properties:**
    /// - `path` - the path string.
    /// - `length` - the total length of the path.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the path.
    /// - `y` - the y-coordinate of the path.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/path
    Path(String, Option<u16>),
    /// Use shape, a reference to a shape defined elsewhere in the document.
    ///
    /// **Element:** `<use>`
    ///
    /// **Own properties:**
    /// - `href` - the id of the shape to reference.
    ///
    /// **Inherited properties:**
    /// - `x` - the x-coordinate of the shape.
    /// - `y` - the y-coordinate of the shape.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/use
    Use(String),
    /// Custom string, allows for custom expressions passed as a string.
    ///
    /// ** Ownedproperties: none**
    /// **Inherited properties:** none
    /// **Extended properties: none**
    Custom(String),
}

/// Create a new circle shape.
public fun circle(r: u16): Shape {
    Shape {
        shape: ShapeType::Circle(r),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new ellipse shape.
public fun ellipse(cx: u16, cy: u16, rx: u16, ry: u16): Shape {
    Shape {
        shape: ShapeType::Ellipse(point::point(cx, cy), rx, ry),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new line shape.
public fun line(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
    Shape {
        shape: ShapeType::Line(point::point(x1, y1), point::point(x2, y2)),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new polygon shape.
public fun polygon(_points: vector<vector<u16>>): Shape {
    abort ENotImplemented
}

/// Create a new polyline shape.
public fun polyline(_points: vector<vector<u16>>): Shape {
    abort ENotImplemented
}

/// Create a new rectangle shape.
public fun rect(width: u16, height: u16): Shape {
    Shape {
        shape: ShapeType::Rect(width, height),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<text>` shape.
public fun text(text: String): Shape {
    Shape {
        shape: ShapeType::Text(text),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<path>` shape.
public fun path(path: String, length: Option<u16>): Shape {
    Shape {
        shape: ShapeType::Path(path, length),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<use>` shape.
public fun use_(href: String): Shape {
    Shape {
        shape: ShapeType::Use(href),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new custom shape.
public fun custom(text: String): Shape {
    Shape {
        shape: ShapeType::Custom(text),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Move a shape.
public fun move_to(mut shape: Shape, x: u16, y: u16): Shape {
    let shape_type = &mut shape.shape;

    shape.position = option::some(point::point(x, y));

    match (shape_type) {
        ShapeType::Circle(_) => {
            let (cx, cy) = shape.position.extract().to_values();
            shape.attributes.insert(b"cx".to_string(), print::num_to_string(cx));
            shape.attributes.insert(b"cy".to_string(), print::num_to_string(cy));
        },
        ShapeType::Line(p0, p1) => {
            let (x1, y1) = p0.to_values();
            let (x2, y2) = p1.to_values();

            *p0 = point::point(x, y);
            *p1 = point::point(x + x2 - x1, y + y2 - y1);
        },
        ShapeType::Polygon(_points) => abort ENotImplemented,
        ShapeType::Polyline(_points) => abort ENotImplemented,
        _ => {},
    };

    shape
}

/// Simplification to not create functions for each container invariant.
public fun name(shape: &Shape): String {
    match (shape.shape) {
        ShapeType::Circle(..) => b"circle".to_string(),
        ShapeType::Ellipse(..) => b"ellipse".to_string(),
        ShapeType::Line(..) => b"line".to_string(),
        ShapeType::Polygon(..) => abort ENotImplemented,
        ShapeType::Polyline(..) => abort ENotImplemented,
        ShapeType::Rect(..) => b"rect".to_string(),
        ShapeType::Text(..) => b"text".to_string(),
        ShapeType::Use(..) => b"use".to_string(),
        ShapeType::Custom(..) => b"custom".to_string(),
        ShapeType::Path(..) => b"path".to_string(),
        _ => abort 0,
    }
}

/// Print the shape as an `SVG` element.
public fun to_string(base_shape: &Shape): String {
    let Shape { shape, position, attributes, animation } = base_shape;
    let mut attributes = *attributes;

    position.do_ref!(|point| {
        let (x, y) = point.to_values();
        attributes.insert(b"x".to_string(), print::num_to_string(x));
        attributes.insert(b"y".to_string(), print::num_to_string(y));
    });

    let (name, mut contents) = match (shape) {
        ShapeType::Circle(r) => {
            attributes.insert(b"r".to_string(), print::num_to_string(*r));
            (b"circle", option::none())
        },
        ShapeType::Ellipse(center, rx, ry) => {
            let (cx, cy) = center.to_values();
            attributes.insert(b"cx".to_string(), print::num_to_string(cx));
            attributes.insert(b"cy".to_string(), print::num_to_string(cy));
            attributes.insert(b"rx".to_string(), print::num_to_string(*rx));
            attributes.insert(b"ry".to_string(), print::num_to_string(*ry));
            (b"ellipse", option::none())
        },
        ShapeType::Line(p0, p1) => {
            let (x1, y1) = p0.to_values();
            let (x2, y2) = p1.to_values();
            attributes.insert(b"x1".to_string(), print::num_to_string(x1));
            attributes.insert(b"y1".to_string(), print::num_to_string(y1));
            attributes.insert(b"x2".to_string(), print::num_to_string(x2));
            attributes.insert(b"y2".to_string(), print::num_to_string(y2));
            (b"line", option::none())
        },
        ShapeType::Polygon(_points) => {
            abort ENotImplemented
        },
        ShapeType::Polyline(_points) => {
            abort ENotImplemented
        },
        ShapeType::Rect(width, height) => {
            attributes.insert(b"width".to_string(), print::num_to_string(*width));
            attributes.insert(b"height".to_string(), print::num_to_string(*height));
            (b"rect", option::none())
        },
        ShapeType::Text(text) => (b"text", option::some(vector[*text])),
        ShapeType::TextWithTextPath { text, href } => {
            attributes.insert(b"href".to_string(), *href);

            // print the textPath element as a string
            let text_path = print::print(
                b"textPath".to_string(),
                attributes,
                option::some(vector[*text]),
            );

            // unset all attributes for the text element
            attributes = vec_map::empty();

            (b"text", option::some(vector[text_path]))
        },
        ShapeType::Use(href) => {
            attributes.insert(b"href".to_string(), *href);
            (b"use", option::none())
        },
        ShapeType::Path(path, length) => {
            attributes.insert(b"d".to_string(), *path);
            length.do_ref!(
                |value| attributes.insert(
                    b"length".to_string(),
                    print::num_to_string(*value),
                ),
            );
            (b"path", option::none())
        },
        ShapeType::Custom(text) => return *text,
    };

    animation.do_ref!(|el| {
        contents = contents.map!(|mut contents| {
                contents.push_back(el.to_string());
                contents
            }).or!(option::some(vector[el.to_string()]));
    });

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

/// Add an animation to a shape.
public fun add_animation(shape: &mut Shape, animation: Animation) {
    shape.animation = option::some(animation);
}

#[test_only]
/// Print the `Shape` as a string to console in tests.
public fun debug(self: &Shape) { std::debug::print(&to_string(self)); }
