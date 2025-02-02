// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Defines SVG description elements: `<desc>`, `<metadata>`, and `<title>`.
///
/// These elements may be used to provide additional information about the SVG content, such as
/// descriptions, metadata, and titles.
module svg::desc;

use std::string::String;
use sui::vec_map;
use svg::print;

const TYPE_DESC: u8 = 0;
const TYPE_METADATA: u8 = 1;
const TYPE_TITLE: u8 = 2;
const TYPE_CUSTOM: u8 = 3;

/// Special container for SVG descriptions.
public struct Desc has copy, drop, store {
    desc_type: u8,
    content: String,
}

/// Create a new `<desc>` element with the given text.
///
/// ## Description
///
/// Provides a description of the SVG content, which can be rendered by user agents in a
/// tooltip. Authors are encouraged to provide such a description, which can improve accessibility.
/// However, in the blockchain environment, space optimization is crucial, so it is recommended to
/// use this element only when necessary.
///
/// - Element: `<desc>`.
/// - Owned property: description string.
/// - Extended properties: None.
///
/// [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/desc)
///
/// ## Usage
///
/// ```rust
/// use svg::{desc, shape, svg};
///
/// let mut svg = svg::svg(vector[0, 0, 200, 200]);
/// let desc = desc::desc(b"This is a circle".to_string());
/// let mut circle = shape::circle(5).move_to(50, 50);
///
/// circle.add_desc(desc);
/// svg.add_root(vector[ circle ]);
///
/// let str = svg.to_string();
/// ```
public fun desc(content: String): Desc { Desc { desc_type: TYPE_DESC, content } }

/// Create a new `<metadata>` element with the given raw content.
///
/// ## Description
///
/// Organizes arbitrary metadata for the parent element, which can be used by user agents.
/// Metadata should be structured data, such as elements from other XML namespaces, JSON, or
/// RDF.
///
/// - Element: `<metadata>`.
/// - Owned property: content.
/// - Extended properties: None.
///
/// [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/metadata)
///
/// ## Usage
///
/// ```rust
/// use svg::{desc, svg};
///
/// let mut svg = svg::svg(vector[0, 0, 200, 200]);
/// svg.add_desc(desc::metadata(b"...".to_string()));
///
/// let str = svg.to_string();
/// ```
public fun metadata(content: String): Desc { Desc { desc_type: TYPE_METADATA, content } }

/// Create a new title description.
///
/// ## Description
///
/// Provides a title for the parent element, which can be rendered by user agents in a tooltip.
///
/// - Element: `<title>`.
/// - Owned property: title text.
/// - Extended properties: None.
///
/// [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/title)
///
/// ## Usage
///
/// ```rust
/// use svg::{desc, shape, svg};
///
/// let mut svg = svg::svg(vector[0, 0, 200, 200]);
/// let title = desc::title(b"This is a circle");
/// let mut circle = shape::circle(5).move_to(50, 50);
///
/// circle.add_desc(title);
/// svg.add_root(vector[ circle ]);
///
/// let str = svg.to_string();
/// ```
public fun title(text: String): Desc { Desc { desc_type: TYPE_TITLE, content: text } }

/// Insert a custom element into the `Desc` container.
///
/// ```rust
/// use svg::{desc, svg};
///
/// let custom = desc::custom("<custom>Custom element</custom>");
/// let mut svg = svg::svg(vector[0, 0, 200, 200]);
/// svg.add_desc(custom);
///
/// let str = svg.to_string();
/// ```
public fun custom(text: String): Desc { Desc { desc_type: TYPE_CUSTOM, content: text } }

/// Print the shape as an `SVG` element.
///
/// TODO: replace with constants when compiler bug is fixed.
public fun to_string(shape: &Desc): String {
    let (name, content) = match (shape.desc_type) {
        0 => (b"desc", vector[shape.content]),
        1 => (b"metadata", vector[shape.content]),
        2 => (b"title", vector[shape.content]),
        3 => return shape.content,
        _ => abort,
    };

    print::print(name.to_string(), vec_map::empty(), option::some(content))
}

#[test_only]
/// Print the `Desc` as a string to console in tests.
public fun debug(self: &Desc) { std::debug::print(&to_string(self)); }
