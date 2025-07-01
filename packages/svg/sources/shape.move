// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: shapes
module svg::shape;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::{animation::Animation, coordinate::{Self, Coordinate}, filter::Filter, print};

/// Abort code for the `NotImplemented` error.
const ENotImplemented: u64 = 264;

/// SVG shape struct, contains a shape type and a set of attributes.
public struct Shape has copy, drop, store {
    /// The shape type, such as a circle, rectangle, or path.
    shape: ShapeType,
    /// A set of attributes for the shape.
    attributes: VecMap<String, String>,
    /// An optional animation to apply to the shape.
    animation: Option<Animation>,
    /// An optional position for the shape, changed in the `move_to` function.
    position: Option<Coordinate>,
}

/// SVG shape enum. Each variant represents a different shape, all of them
/// containing a set of attributes as a `VecMap`.
public enum ShapeType has copy, drop, store {
    Circle(u16),
    Ellipse(Coordinate, u16, u16),
    Filter(String, vector<Filter>),
    ForeignObject(String),
    Line(Coordinate, Coordinate),
    Image(String),
    Polygon(vector<Coordinate>),
    Polyline(vector<Coordinate>),
    Rect(u16, u16),
    Text(String),
    /// Text with text path shape, a text element with a string and a path.
    ///
    /// Element: `<text><textPath>` (group)
    ///
    /// Own properties:
    /// - `text` - the text to display.
    /// - `path` - the path to follow.
    ///
    /// Inherited properties:
    /// - `x` - the x-coordinate of the text.
    /// - `y` - the y-coordinate of the text.
    ///
    /// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/textPath
    TextWithTextPath { text: String, href: String },
    Path(String, Option<u16>),
    Use(String),
    View(vector<u16>),
    LinearGradient {
        stops: vector<Stop>,
    },
    RadialGradient {
        stops: vector<Stop>,
    },
    Custom(String),
}

/// A stop element for a gradient nodes (`linearGradient`, `radialGradient`).
public struct Stop has copy, drop, store { offset: String, color: String }

/// Create a new circle shape.
/// Circle shape, a circle with a center and a radius.
///
/// Element: `<circle>`
///
/// Own properties:
/// - `r` - the radius of the circle.
///
/// Inherited properties:
/// - `cx` - the x-coordinate of the circle.
/// - `cy` - the y-coordinate of the circle.
///
/// Extended properties:
/// - `pathLength` - the total length of the path.
/// - `transform` - a transformation to apply to the circle.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/circle
public fun circle(r: u16): Shape {
    Shape {
        shape: ShapeType::Circle(r),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new ellipse `Shape`.
///
/// ## Description
///
/// Ellipse shape, a circle that is stretched in one direction.
///
/// Element: `<ellipse>`
///
/// Own properties:
/// - `pc` - the point of the center of the ellipse.
/// - `rx` - the radius of the ellipse in the x-axis.
/// - `ry` - the radius of the ellipse in the y-axis.
///
/// Inherited properties:
/// - `x` - the x-coordinate of the ellipse.
/// - `y` - the y-coordinate of the ellipse.
///
/// Extended properties:
/// - `pathLength` - the total length of the path.
/// - `transform` - a transformation to apply to the ellipse.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/ellipse
///
/// ```rust
/// let cx = 1400;
/// let cy = 1400;
/// let rx = 100;
/// let ry = 50;
///
/// let ellipse = shape::ellipse(cx, cy, rx, ry);
///
/// ellipse.to_string();
/// ```
public fun ellipse(cx: u16, cy: u16, rx: u16, ry: u16): Shape {
    Shape {
        shape: ShapeType::Ellipse(coordinate::new(cx, cy), rx, ry),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new filter element with the given id and a list of filter elements.
///
/// ## Description
///
/// Filter shape, a filter element that can be applied to other elements. Must
/// be used inside a `defs` container, contains an `id` and a list of filters
/// such as `feGaussianBlur`, `feColorMatrix`, and `feBlend`.
///
/// Element: `<filter>`
///
/// Own properties:
/// - `id` - the id of the filter.
/// - `filters` - a list of filter elements.
///
/// Extended properties: none
///
/// ## Usage
///
/// ```rust
/// let filter = shape::filter(b"f1".to_string(), vector[
///    filter::gaussian_blur(5),
///    filter::color_matrix(b"grayscale"),
/// ]);
///
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// svg.add_root(vector[filter]);
/// let str = svg.to_string();
/// ```
public fun filter(id: String, filters: vector<Filter>): Shape {
    Shape {
        shape: ShapeType::Filter(id, filters),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new line shape.
///
/// ## Description
///
/// Line shape, a line that connects two points, each point is a pair
/// of `x` and `y`.
///
/// Element: `<line>`
///
/// Own properties:
/// - p0 - the first point.
/// - p1 - the second point.
///
/// Extended properties:
/// - `pathLength` - the total length of the path.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/line
public fun line(x1: u16, y1: u16, x2: u16, y2: u16): Shape {
    Shape {
        shape: ShapeType::Line(coordinate::new(x1, y1), coordinate::new(x2, y2)),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

#[test_only]
/// Create a new polygon shape (not implemented).
///
/// ## Description
///
/// Polygon shape, a closed shape that connects multiple points. With
/// straight lines between each pair of points.
///
/// Element: `<polygon>`
///
/// Own properties:
/// - `vector<u16>` - a list of points, each point is a pair of `x` and `y`.
///
/// Inherited properties:
/// - `x` - the x-coordinate of the polygon.
/// - `y` - the y-coordinate of the polygon.
///
/// Extended properties:
/// - `pathLength` - the total length of the path.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/polygon
public fun polygon(_points: vector<vector<u16>>): Shape {
    abort ENotImplemented
}

#[test_only]
/// Create a new polyline shape.
/// Polyline shape, a line that connects multiple points.
///
/// ## Description
///
/// Own properties:
/// - `vector<u16>` - a list of points, each point is a pair of `x` and `y`.
///
/// Extended properties:
/// - `pathLength` - the total length of the path.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/polyline
public fun polyline(_points: vector<vector<u16>>): Shape {
    abort ENotImplemented
}

/// Create a new rectangle shape.
///
/// ## Description
///
/// Rectangle shape, a rectangle with a position, width, and height.
///
/// Element: `<rect>`
///
/// Own properties:
/// - `width` - the width of the rectangle.
/// - `height` - the height of the rectangle.
///
/// Extended properties:
/// - `rx` - the radius of the rectangle in the x-axis.
/// - `ry` - the radius of the rectangle in the y-axis.
/// - `pathLength` - the total length of the path.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/rect
public fun rect(width: u16, height: u16): Shape {
    Shape {
        shape: ShapeType::Rect(width, height),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<text>` shape.
///
/// ## Description
///
/// Text shape, a text element with a string and a position.
///
/// Element: `<text>`
///
/// Own properties:
/// - `text` - the text to display.
/// - `path` - an optional `TextPath` element.
///
/// Inherited properties:
/// - `x` - the x-coordinate of the text.
/// - `y` - the y-coordinate of the text.
///
/// Extended properties:
/// - `dx` - the x-offset of the text.
/// - `dy` - the y-offset of the text.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text
public fun text(text: String): Shape {
    Shape {
        shape: ShapeType::Text(text),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<path>` shape.
///
/// ## Description
///
/// Path shape, a shape defined by a path string. The path string is
/// a series of commands and coordinates. The `length` attribute is
/// optional and specifies the total length of the path.
///
/// Element: `<path>`
///
/// Own properties:
/// - `path` - the path string.
/// - `length` - the total length of the path.
///
/// Inherited properties:
/// - `x` - the x-coordinate of the path.
/// - `y` - the y-coordinate of the path.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/path
///
/// ```rust
/// let path_string = b"M 10 10 L 20 20".to_string();
/// let path = shape::path(path_string, option::none());
///
/// let mut svg = svg::svg(vector[0, 0, 100, 100]);
/// svg.add_root(vector[path]);
///
/// let str = svg.to_string();
/// ```
public fun path(path: String, length: Option<u16>): Shape {
    Shape {
        shape: ShapeType::Path(path, length),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<use>` shape.
///
/// ## Description
///
/// Use shape, a reference to a shape defined elsewhere in the document.
///
/// Element: `<use>`
///
/// Own properties:
/// - `href` - the id of the shape to reference.
///
/// Inherited properties:
/// - `x` - the x-coordinate of the shape.
/// - `y` - the y-coordinate of the shape.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/use
public fun use_(href: String): Shape {
    Shape {
        shape: ShapeType::Use(href),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<linearGradient>` shape.
///
/// ## Description
///
/// Part of the `defs` container, a shape that is not a standard SVG shape.
///
/// Element: `<linearGradient>`
///
/// Own properties:
/// - `stops` - a list of stop elements.
///
/// Inherited properties: none
///
/// Extended properties:
/// - `x1` - the x-coordinate of the start of the gradient.
/// - `y1` - the y-coordinate of the start of the gradient.
/// - `x2` - the x-coordinate of the end of the gradient.
/// - `y2` - the y-coordinate of the end of the gradient.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/linearGradient
public fun linear_gradient(stops: vector<Stop>): Shape {
    Shape {
        shape: ShapeType::LinearGradient { stops },
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<radialGradient>` shape.
///
/// ## Description
///
/// Part of the `defs` container, a shape that is not a standard SVG shape.
/// A radial gradient is a gradient that starts from a center point and
/// spreads out in all directions.
///
/// Element: `<radialGradient>`
///
/// Inherited properties: none
///
/// Own properties:
/// - `stops` - a list of stop elements.
///
/// Extended properties:
/// - `cx` - the x-coordinate of the center of the gradient.
/// - `cy` - the y-coordinate of the center of the gradient.
/// - `r` - the radius of the gradient.
///
/// See https://developer.mozilla.org/en-US/docs/Web/SVG/Element/radialGradient
public fun radial_gradient(stops: vector<Stop>): Shape {
    Shape {
        shape: ShapeType::RadialGradient { stops },
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new custom shape.
///
/// ## Description
///
/// Custom string, allows for custom expressions passed as a string.
///
/// Own properties: none
///
/// Inherited properties: none
///
/// Extended properties: none
public fun custom(text: String): Shape {
    Shape {
        shape: ShapeType::Custom(text),
        attributes: vec_map::empty(),
        animation: option::none(),
        position: option::none(),
    }
}

/// Create a new `<stop>` element for a gradient node (`linearGradient`, `radialGradient`).
public fun stop(offset: vector<u8>, color: vector<u8>): Stop {
    Stop { offset: offset.to_string(), color: color.to_string() }
}

/// Adds a `<stop>` element to a gradient.
public fun add_stop(gradient: &mut Shape, offset: String, color: String) {
    let stops = match (&mut gradient.shape) {
        ShapeType::LinearGradient { stops } => stops,
        ShapeType::RadialGradient { stops } => stops,
        _ => abort,
    };

    stops.push_back(Stop { offset, color });
}

/// Move a shape, add `x` and `y` to the attributes of the shape.
public fun move_to(mut shape: Shape, x: u16, y: u16): Shape {
    let shape_type = &mut shape.shape;

    match (shape_type) {
        ShapeType::Circle(_) => {
            let (cx, cy) = coordinate::new(x, y).to_values();
            shape.attributes.insert(b"cx".to_string(), cx.to_string());
            shape.attributes.insert(b"cy".to_string(), cy.to_string());
        },
        ShapeType::Line(p0, p1) => {
            let (x1, y1) = p0.to_values();
            let (x2, y2) = p1.to_values();

            *p0 = coordinate::new(x, y);
            *p1 = coordinate::new(x + x2 - x1, y + y2 - y1);
        },
        ShapeType::Polygon(_points) => abort ENotImplemented,
        ShapeType::Polyline(_points) => abort ENotImplemented,
        ShapeType::Path(_path, _length) => {
            let mut value = b"translate(".to_string();
            value.append(x.to_string());
            value.append(b", ".to_string());
            value.append(y.to_string());
            value.append(b")".to_string());

            shape.attributes_mut().insert(b"transform".to_string(), value);
        },
        _ => {
            shape.position = option::some(coordinate::new(x, y));
        },
    };

    shape
}

/// Simplification to not create functions for each container invariant.
public fun name(shape: &Shape): String {
    match (shape.shape) {
        ShapeType::Circle(..) => b"circle".to_string(),
        ShapeType::Ellipse(..) => b"ellipse".to_string(),
        ShapeType::Filter(..) => b"filter".to_string(),
        ShapeType::Line(..) => b"line".to_string(),
        ShapeType::LinearGradient { .. } => b"linearGradient".to_string(),
        ShapeType::Path(..) => b"path".to_string(),
        ShapeType::Polygon(..) => abort ENotImplemented,
        ShapeType::Polyline(..) => abort ENotImplemented,
        ShapeType::RadialGradient { .. } => b"radialGradient".to_string(),
        ShapeType::Rect(..) => b"rect".to_string(),
        ShapeType::Text(..) => b"text".to_string(),
        ShapeType::TextWithTextPath { .. } => b"text".to_string(),
        ShapeType::Use(..) => b"use".to_string(),
        ShapeType::Custom(..) => b"custom".to_string(),
        _ => abort,
    }
}

/// Print the shape as an `SVG` element.
public fun to_string(base_shape: &Shape): String {
    let Shape { shape, position, attributes, animation } = base_shape;
    let mut attributes = *attributes;

    position.do_ref!(|point| {
        let (x, y) = point.to_values();
        attributes.insert(b"x".to_string(), x.to_string());
        attributes.insert(b"y".to_string(), y.to_string());
    });

    let (name, mut contents) = match (shape) {
        ShapeType::Circle(r) => {
            attributes.insert(b"r".to_string(), (*r).to_string());
            (b"circle", option::none())
        },
        ShapeType::Ellipse(center, rx, ry) => {
            let (cx, cy) = center.to_values();
            attributes.insert(b"cx".to_string(), cx.to_string());
            attributes.insert(b"cy".to_string(), cy.to_string());
            attributes.insert(b"rx".to_string(), (*rx).to_string());
            attributes.insert(b"ry".to_string(), (*ry).to_string());
            (b"ellipse", option::none())
        },
        ShapeType::Filter(id, filters) => {
            let filters = filters.map_ref!(|filter| filter.to_string());
            attributes.insert(b"id".to_string(), *id);
            (b"filter", option::some(filters))
        },
        ShapeType::Line(p0, p1) => {
            let (x1, y1) = p0.to_values();
            let (x2, y2) = p1.to_values();
            attributes.insert(b"x1".to_string(), x1.to_string());
            attributes.insert(b"y1".to_string(), y1.to_string());
            attributes.insert(b"x2".to_string(), x2.to_string());
            attributes.insert(b"y2".to_string(), y2.to_string());
            (b"line", option::none())
        },
        ShapeType::Polygon(_points) => {
            abort ENotImplemented
        },
        ShapeType::Polyline(_points) => {
            abort ENotImplemented
        },
        ShapeType::Rect(width, height) => {
            attributes.insert(b"width".to_string(), (*width).to_string());
            attributes.insert(b"height".to_string(), (*height).to_string());
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
                    (*value).to_string(),
                ),
            );
            (b"path", option::none())
        },
        ShapeType::LinearGradient { stops } => {
            let stops = stops.map_ref!(|stop| {
                let mut attributes = vec_map::empty();
                attributes.insert(b"offset".to_string(), stop.offset);
                attributes.insert(b"stop-color".to_string(), stop.color);
                print::print(b"stop".to_string(), attributes, option::none())
            });

            (b"linearGradient", option::some(stops))
        },
        ShapeType::RadialGradient { stops } => {
            let stops = stops.map_ref!(|stop| {
                let mut attributes = vec_map::empty();
                attributes.insert(b"offset".to_string(), stop.offset);
                attributes.insert(b"stop-color".to_string(), stop.color);
                print::print(b"stop".to_string(), attributes, option::none())
            });

            (b"radialGradient", option::some(stops))
        },
        ShapeType::Custom(text) => return *text,
        _ => abort,
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

/// Add an attribute to a shape.
///
/// ```rust
/// use svg::{animation, shape};
///
/// let mut shape = shape::rect(10, 10);
/// let animation = animation::set(b"5")
///     .attribute_name(b"r")
///     .duration(b"10s")
///     .repeat_count(b"indefinite");
///
/// shape.add_animation(animation);
/// ```
public fun add_animation(shape: &mut Shape, animation: Animation) {
    shape.animation = option::some(animation);
}

/// Get a mutable reference to the animation field.
///
/// ```rust
/// use svg::{animation, shape};
///
/// let mut shape = shape::rect(10, 10);
/// let animation = animation::set(b"5")
///     .attribute_name(b"r")
///     .duration(b"10s")
///     .repeat_count(b"indefinite");
///
/// shape.add_animation(animation);
/// shape.animation_mut().extract(); // remove animation
/// ```
public fun animation_mut(shape: &mut Shape): &mut Option<Animation> {
    &mut shape.animation
}

/// Map over the attributes of the animation.
///
/// ```rust
/// let mut animation = shape::circle(10).move_to(20, 20).map_attributes!(|attrs| {
///    attrs.insert(b"fill".to_string(), b"red".to_string());
///    attrs.insert(b"stroke".to_string(), b"black".to_string());
/// });
/// ```
public macro fun map_attributes($self: Shape, $f: |&mut VecMap<String, String>|): Shape {
    let mut self = $self;
    let attributes = self.attributes_mut();
    $f(attributes);
    self
}

#[test_only]
/// Print the `Shape` as a string to console in tests.
public fun debug(self: &Shape) { std::debug::print(&to_string(self)); }
