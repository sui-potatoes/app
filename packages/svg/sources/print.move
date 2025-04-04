// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements tag printing for any XML elements. This is a base utility used by
/// most of the types in this library.
module svg::print;

use std::string::String;
use sui::vec_map::VecMap;

/// Prints a generic SVG element, with attributes and elements. Rarely should be
/// used directly, given that each type in this library has its own `to_string`.
///
/// In case custom XML elements are needed for `Custom(String)` nodes, here is
/// an example of usage:
///
/// ```rust
/// // for double tags `<a>Link contents</a>`
/// let printed = svg::print::print(
///     b"a".to_string(), // element name
///     vec_map::empty(), // VecMap of attributes
///     option::some(vector[ b"Link contents".to_string() ]), // Option<vector<String>> of elements
/// );
///
/// // for single tag `<br />`
/// let printed = svg::print::print(
///     b"br".to_string(), // element name
///     vec_map::empty(), // VecMap of attributes
///     option::none(), // empty option for single tags
/// );
/// ```
public fun print(
    name: String,
    attributes: VecMap<String, String>,
    elements: Option<vector<String>>,
): String {
    let mut svg = b"<".to_string();
    svg.append(name);
    let (keys, values) = attributes.into_keys_values();
    let length = keys.length();
    if (length > 0) svg.append(b" ".to_string());
    length.do!(|i| {
        svg.append(keys[i]);
        svg.append(b"='".to_string());
        svg.append(values[i]);
        svg.append(if (i < length - 1) { b"' " } else { b"'" }.to_string());
    });

    if (elements.is_none()) {
        svg.append(b"/>".to_string());
        return svg
    };

    svg.append(b">".to_string());
    elements.do!(|vec| vec.do!(|el| svg.append(el)));
    svg.append(b"</".to_string());
    svg.append(name);
    svg.append(b">".to_string());
    svg
}
