// SPDX-License-Identifier: MIT
// Copyright (c) Sui Potatoes

/// An example of how to use the `date` package to create an owned timestamp.
///
/// Note:
/// if you plan on copying this example, make sure to add:
/// - `@potatoes/codec`
/// - `@potatoes/svg`
/// ...as dependencies via `MVR`.
module date::stamp;

use date::date;
use std::string::String;
use sui::{clock::Clock, display, package};
use svg::{shape, svg};

/// One Time Witness to create `Display` and `Publisher`.
public struct STAMP has drop {}

/// An object that represents a timestamp.
public struct Stamp has key, store {
    id: UID,
    date_string: String,
}

/// Create a new `Stamp` object.
public fun new(clock: &Clock, ctx: &mut TxContext): Stamp {
    let date = date::from_clock(clock);

    Stamp {
        id: object::new(ctx),
        date_string: date.to_utc_string(),
    }
}

/// Create Publisher object and set up Display for the `Stamp`.
fun init(otw: STAMP, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    let mut display = display::new<Stamp>(&publisher, ctx);

    display.add(b"name".to_string(), b"Timestamp NFT: {date_string}".to_string());
    display.add(b"link".to_string(), b"https://potatoes.app/".to_string());
    display.add(b"image_url".to_string(), create_svg_data_uri(b"{date_string}".to_string()));
    display.add(b"author".to_string(), b"Sui Potatoes".to_string());
    display.add(
        b"description".to_string(),
        b"Timestamp NFT illustrates how to use `@potatoes/date` package".to_string(),
    );

    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
}

/// Create a SVG data URI with substituted date. Because we intend to use this
/// in a Display template, the value expected is a template `{date_string}`.
fun create_svg_data_uri(date: String): String {
    let mut svg = svg::svg(vector[0, 0, 500, 500]);
    svg.add_root(vector[
        shape::custom(b"<style>text { font-family: monospace; font-size: 24px }</style>".to_string()),
        shape::text(b"Timestamped Date:".to_string()).move_to(10, 200),
        shape::text(date).move_to(10, 260),
    ]);
    svg.to_url()
}
