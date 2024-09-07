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
    /// **Element:** `<desc>`.
    ///
    /// Provides a description of the SVG content, which can be rendered by user agents in a
    /// tooltip.
    /// Authors are encouraged to provide such a description, which can improve accessibility.
    ///
    /// **Owned property:** description string.
    ///
    /// **Extended properties:** None.
    ///
    /// [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/desc)
    Desc(String),
    /// **Element:** `<metadata>`.
    ///
    /// Organizes arbitrary metadata for the parent element, which can be used by user agents.
    /// Metadata should be structured data, such as elements from other XML namespaces, JSON, or
    /// RDF.
    ///
    /// **Owned property:** content.
    ///
    /// **Extended properties:** None.
    Metadata(String),
    /// **Element:** `<title>`.
    ///
    /// Provides a title for the parent element, which can be rendered by user agents in a tooltip.
    ///
    /// **Owned property:** title text.
    ///
    /// **Extended properties:** None.
    ///
    /// [MDN Web Docs](https://developer.mozilla.org/en-US/docs/Web/SVG/Element/title)
    Title(String),
}

/// Create a new `<desc>` element with the given text.
public fun desc(text: String): Desc { Desc::Desc(text) }

/// Create a new `<metadata>` element with the given raw content.
public fun metadata(content: String): Desc { Desc::Metadata(content) }

/// Create a new title description.
public fun title(text: String): Desc { Desc::Title(text) }

/// Move a shape.
public fun move_to(shape: Desc, _x: u64, _y: u64): Desc { shape }

/// Print the shape as an `SVG` element.
public fun to_string(shape: &Desc): String {
    let (name, content) = match (shape) {
        Desc::Desc(str) => (b"desc", vector[*str]),
        Desc::Metadata(str) => (b"metadata", vector[*str]),
        Desc::Title(str) => (b"title", vector[*str]),
    };

    print::print(name.to_string(), vec_map::empty(), option::some(content))
}

#[test_only]
/// Print the `Desc` as a string to console in tests.
public fun debug(self: &Desc) { std::debug::print(&to_string(self)); }
