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

/// Special container for SVG descriptions.
public enum Desc has store, copy, drop {
    Desc(String),
    Metadata(String),
    Title(String),
    /// Any custom text to be inserted into a shape, container or SVG.
    Custom(String),
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
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// let desc = desc::desc(b"This is a circle".to_string());
/// let mut circle = shape::circle(5).move_to(50, 50);
///
/// circle.add_desc(desc);
/// svg.add_root(vector[ circle ]);
///
/// let str = svg.to_string();
/// ```
public fun desc(text: String): Desc { Desc::Desc(text) }

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
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.add_desc(desc::metadata(b"...".to_string()));
///
/// let str = svg.to_string();
/// ```
public fun metadata(content: String): Desc { Desc::Metadata(content) }

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
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// let title = desc::title(b"This is a circle");
/// let mut circle = shape::circle(5).move_to(50, 50);
///
/// circle.add_desc(title);
/// svg.add_root(vector[ circle ]);
///
/// let str = svg.to_string();
/// ```
public fun title(text: String): Desc { Desc::Title(text) }

/// Insert a custom element into the `Desc` container.
///
/// ```rust
/// use svg::{desc, svg};
///
/// let custom = desc::custom("<custom>Custom element</custom>");
/// let mut svg = svg(vector[0, 0, 200, 200]);
/// svg.add_desc(custom);
///
/// let str = svg.to_string();
/// ```
public fun custom(text: String): Desc { Desc::Custom(text) }

/// Print the shape as an `SVG` element.
public fun to_string(shape: &Desc): String {
    let (name, content) = match (shape) {
        Desc::Desc(str) => (b"desc", vector[*str]),
        Desc::Metadata(str) => (b"metadata", vector[*str]),
        Desc::Title(str) => (b"title", vector[*str]),
        Desc::Custom(str) => return *str,
    };

    print::print(name.to_string(), vec_map::empty(), option::some(content))
}

#[test_only]
/// Print the `Desc` as a string to console in tests.
public fun debug(self: &Desc) { std::debug::print(&to_string(self)); }
