// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: desc
module svg::desc;

use std::string::String;
use sui::vec_map;
use svg::print;

/// Special container for SVG descriptions.
public enum Desc has store, copy, drop {
    Desc(String),
    Metadata,
    Title(String),
}

/// Create a new description.
public fun desc(text: String): Desc { Desc::Desc(text) }

/// Create a new metadata description.
public fun metadata(): Desc { Desc::Metadata }

/// Create a new title description.
public fun title(text: String): Desc { Desc::Title(text) }

/// Move a shape.
public fun move_to(shape: Desc, _x: u64, _y: u64): Desc { shape }

/// Print the shape as an `SVG` element.
public fun to_string(shape: &Desc): String {
    let (name, content) = match (shape) {
        Desc::Desc(str) => (b"desc", vector[*str]),
        Desc::Metadata => (b"metadata", vector[]),
        Desc::Title(str) => (b"title", vector[*str]),
    };

    print::print(name.to_string(), vec_map::empty(), option::some(content))
}
