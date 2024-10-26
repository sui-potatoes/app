// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: character
///
/// Character is a fully on-chain inscribed piece of pixel art. While the main
/// application of the module is to serve and manage the character art and minting
/// process (unrestricted right now), it is also implemented in a `Bag`-like manner
/// to allow other applications be built on top of it.
///
/// The API of `add`, `get`, `get_mut`, and `remove` functions is provided to
/// store and retrieve application data in the `Character` object. The data is
/// attached as a dynamic field.
///
/// Read more about it in the Move Book:
/// https://move-book.com/programmability/dynamic-fields.html
///
/// As a cherry on top `Character` also supports index syntax for its dynamic
/// fields. So you can use it like this:
/// ```move
/// let field: AppData = &character[ApplicationKey {}];
/// ```
module character::character;

use codec::urlencode;
use std::{string::String, type_name};
use sui::{display::{Self, Display}, dynamic_field as df, package, vec_map::{Self, VecMap}};
use svg::{container::{Self, Container}, macros::add_class, shape, svg};

#[error]
const EWrongBody: vector<u8> = b"The body type is not found in the `Builder`";
#[error]
const EWrongHair: vector<u8> = b"The hair type is not found in the `Builder`";
#[error]
const EWrongEyesColour: vector<u8> = b"Eyes colour must be in the allowed palette";
#[error]
const EWrongTrousersColour: vector<u8> = b"Trousers colour must be in the allowed palette";
#[error]
const EWrongSkinColour: vector<u8> = b"Skin colour must be in the allowed palette";
#[error]
const EWrongBaseColour: vector<u8> = b"Base colour must be in the allowed palette";
#[error]
const EWrongAccentColour: vector<u8> = b"Accent colour must be in the allowed palette";
#[error]
const EWrongHairColour: vector<u8> = b"Hair colour must be in the allowed palette";
#[error]
const EIncorrectDynamicField: vector<u8> = b"Application key cannot be a primitive type";

// === Constants ===

const HAIR: vector<u8> = b"h";
const BODY: vector<u8> = b"b";
const EYES: vector<u8> = b"e";
const LEGS: vector<u8> = b"l";
const SKIN: vector<u8> = b"s";
const ACCENT: vector<u8> = b"a";

// prettier-ignore
/// EDG 32 palette. Classic 32 colour palette.
const PALETTE: vector<vector<u8>> = vector[
    b"be4a2f", b"d77643", b"ead4aa",
    b"e4a672", b"b86f50", b"733e39",
    b"3e2731", b"a22633", b"e43b44",
    b"f77622", b"feae34", b"fee761",
    b"63c74d", b"3e8948", b"265c42",
    b"193c3e", b"124e89", b"0099db",
    b"2ce8f5", b"ffffff", b"c0cbdc",
    b"8b9bb4", b"5a6988", b"3a4466",
    b"262b44", b"181425", b"ff0044",
    b"68386c", b"b55088", b"f6757a",
    b"e8b796", b"c28569",
];

/// The Builder object which stores configurations under names.
/// Intentionally avoids using dynamic fields to keep the implementation
/// minimal.
///
/// Please, note that by using static fields of the struct, the implementation
/// is limited to the max object size (256KB). If you need to store more data,
/// you should reimplement it to use a `Bag` and store body parts as dynamic
/// fields.
public struct Builder has key {
    id: UID,
    body: VecMap<String, Container>,
    hair: VecMap<String, Container>,
    colours: vector<vector<u8>>,
}

/// The OTW for the application.
public struct CHARACTER has drop {}

/// The builder for the image of a Character, can use available shapes and
/// colours from the game object.
public struct Props has store, drop {
    /// Body type.
    body_type: String,
    /// Hair type.
    hair_type: String,
    /// Urlencoded Body parts.
    body: String,
    /// Urlencoded Hair parts.
    hair: String,
    /// Hair colour, a HEX string.
    hair_colour: String,
    /// Eyes colour, a HEX string.
    eyes_colour: String,
    /// Trousers colour, a HEX string.
    trousers_colour: String,
    /// Skin colour, a HEX string.
    skin_colour: String,
    /// Base colour, a HEX string.
    base_colour: String,
    /// Accent colour, a HEX string.
    accent_colour: String,
}

/// A character in the game.
public struct Character has key, store {
    id: UID,
    image: Props,
}

/// Create a new character.
public fun new(
    b: &mut Builder,
    body_type: String,
    hair_type: String,
    eyes_colour: String,
    hair_colour: String,
    trousers_colour: String,
    skin_colour: String,
    base_colour: String,
    accent_colour: String,
    ctx: &mut TxContext,
): Character {
    assert!(b.body.contains(&body_type), EWrongBody);
    assert!(b.hair.contains(&hair_type), EWrongHair);
    assert!(b.colours.contains(hair_colour.as_bytes()), EWrongHairColour);
    assert!(b.colours.contains(eyes_colour.as_bytes()), EWrongEyesColour);
    assert!(b.colours.contains(trousers_colour.as_bytes()), EWrongTrousersColour);
    assert!(b.colours.contains(skin_colour.as_bytes()), EWrongSkinColour);
    assert!(b.colours.contains(base_colour.as_bytes()), EWrongBaseColour);
    assert!(b.colours.contains(accent_colour.as_bytes()), EWrongAccentColour);

    let image = Props {
        body: urlencode::encode(b.body[&body_type].to_string().into_bytes()),
        hair: urlencode::encode(b.hair[&hair_type].to_string().into_bytes()),
        body_type,
        hair_type,
        eyes_colour,
        hair_colour,
        trousers_colour,
        skin_colour,
        base_colour,
        accent_colour,
    };

    Character { id: object::new(ctx), image }
}

/// Edit the character.
public fun update_image(
    b: &mut Builder,
    c: &mut Character,
    body_type: Option<String>,
    hair_type: Option<String>,
    eyes_colour: Option<String>,
    hair_colour: Option<String>,
    trousers_colour: Option<String>,
    skin_colour: Option<String>,
    base_colour: Option<String>,
    accent_colour: Option<String>,
    _ctx: &mut TxContext,
) {
    body_type.do!(|body_type| {
        assert!(b.body.contains(&body_type), EWrongBody);
        c.image.body = urlencode::encode(b.body[&body_type].to_string().into_bytes());
        c.image.body_type = body_type;
    });

    hair_type.do!(|hair_type| {
        assert!(b.hair.contains(&hair_type), EWrongHair);
        c.image.hair = urlencode::encode(b.hair[&hair_type].to_string().into_bytes());
        c.image.hair_type = hair_type;
    });

    hair_colour.do!(|hair_colour| {
        assert!(b.colours.contains(hair_colour.as_bytes()), EWrongHairColour);
        c.image.hair_colour = hair_colour;
    });

    eyes_colour.do!(|eyes_colour| {
        assert!(b.colours.contains(eyes_colour.as_bytes()), EWrongHairColour);
        c.image.eyes_colour = eyes_colour;
    });

    trousers_colour.do!(|trousers_colour| {
        assert!(b.colours.contains(trousers_colour.as_bytes()), EWrongHairColour);
        c.image.trousers_colour = trousers_colour;
    });

    skin_colour.do!(|skin_colour| {
        assert!(b.colours.contains(skin_colour.as_bytes()), EWrongHairColour);
        c.image.skin_colour = skin_colour;
    });

    base_colour.do!(|base_colour| {
        assert!(b.colours.contains(base_colour.as_bytes()), EWrongHairColour);
        c.image.base_colour = base_colour;
    });

    accent_colour.do!(|accent_colour| {
        assert!(b.colours.contains(accent_colour.as_bytes()), EWrongHairColour);
        c.image.accent_colour = accent_colour;
    });
}

// === Usability ===

/// Add a dynamic field to the character.
///
/// We make sure that the Key is not a primitive type to enforce the usage of custom
/// types for dynamic fields. This is a necessary step in preventing misimplementation
/// of the dynamic fields in this setting.
///
/// TODO: a stricter check would be to check against the `0x1` and `0x2` origin
///      of the type, but we can leave it for now.
public fun add<K: store + copy + drop, V: store>(c: &mut Character, key: K, value: V) {
    assert!(!type_name::get<K>().is_primitive(), EIncorrectDynamicField);
    df::add(&mut c.id, key, value)
}

/// Borrow a dynamic field of the `Character`
#[syntax(index)]
public fun borrow<K: store + copy + drop, V: store>(c: &Character, key: K): &V {
    df::borrow(&c.id, key)
}

/// Borrow a dynamic field of the `Character` mutably
#[syntax(index)]
public fun borrow_mut<K: store + copy + drop, V: store>(c: &mut Character, key: K): &mut V {
    df::borrow_mut(&mut c.id, key)
}

/// Remove a dynamic field from the character.
public fun remove<K: store + copy + drop, V: store>(c: &mut Character, key: K): V {
    df::remove(&mut c.id, key)
}

// === Accessors ===

/// Get the body type of the character.
public fun body_type(c: &Character): String { c.image.body_type }

/// Get the hair type of the character.
public fun hair_type(c: &Character): String { c.image.hair_type }

/// Get the eyes colour of the character.
public fun eyes_colour(c: &Character): String { c.image.eyes_colour }

/// Get the hair colour of the character.
public fun hair_colour(c: &Character): String { c.image.hair_colour }

/// Get the pants colour of the character.
public fun trousers_colour(c: &Character): String { c.image.trousers_colour }

/// Get the skin colour of the character.
public fun skin_colour(c: &Character): String { c.image.skin_colour }

/// Get the base colour of the character.
public fun base_colour(c: &Character): String { c.image.base_colour }

/// Get the accent colour of the character.
public fun accent_colour(c: &Character): String { c.image.accent_colour }

// === Static Read ===

/// Returns vector of available colours for the application.
public fun palette(): vector<vector<u8>> { PALETTE }

// === Display & Rendering ===

/// Create Display for the Character type.
fun init(otw: CHARACTER, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);
    let mut display = display::new<Character>(&publisher, ctx);

    let mut builder = Builder {
        id: object::new(ctx),
        body: vec_map::empty(),
        hair: vec_map::empty(),
        colours: PALETTE,
    };

    builder.set_initial_assets();
    set_display(&mut display);

    transfer::public_transfer(display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
    transfer::share_object(builder);
}

/// Size of a single pixel in the Character
const PX: u16 = 20;

/// Set the initial assets for the character.
fun set_initial_assets(builder: &mut Builder) {
    // hair: punk
    // let px = 20;
    let mut punk = container::g(vector[
        shape::rect(3 * PX, PX).move_to(4 * PX, PX),
        shape::rect(2 * PX, PX).move_to(4 * PX, 0),
    ]);

    add_class!(&mut punk, HAIR);
    builder.hair.insert(b"punk".to_string(), punk);

    // hair: flat
    let mut flat = shape::rect(3 * PX, PX).move_to(4 * PX, PX);
    add_class!(&mut flat, HAIR);
    builder.hair.insert(b"flat".to_string(), container::root(vector[flat]));

    // hair: bang
    let mut bang = container::g(vector[
        shape::rect(3 * PX, PX).move_to(80, PX),
        shape::rect(PX, PX).move_to(6 * PX, 2 * PX),
    ]);
    add_class!(&mut bang, HAIR);
    builder.hair.insert(b"bang".to_string(), bang);

    // hair: wind
    let mut wind = container::g(vector[
        shape::rect(PX, 3 * PX).move_to(3 * PX, PX),
        shape::rect(4 * PX, PX).move_to(4 * PX, PX),
        shape::rect(2 * PX, 2 * PX).move_to(7 * PX, 2 * PX),
        shape::rect(PX, PX).move_to(9 * PX, 2 * PX),
    ]);
    add_class!(&mut wind, HAIR);
    builder.hair.insert(b"wind".to_string(), wind);

    // body: blazer
    let mut blazer = container::g(vector[
        shape::rect(PX, PX).move_to(4 * PX, 5 * PX),
        shape::rect(PX, PX).move_to(6 * PX, 5 * PX),
        shape::rect(PX, PX).move_to(5 * PX, 6 * PX),
        shape::rect(PX, PX).move_to(3 * PX, 5 * PX),
        shape::rect(PX, PX).move_to(7 * PX, 5 * PX),
    ]);
    add_class!(&mut blazer, BODY);
    builder.body.insert(b"blazer".to_string(), blazer);

    // body: office
    let mut office = container::g(vector[
        shape::rect(PX, 2 * PX).move_to(3 * PX, 5 * PX),
        shape::rect(PX, 2 * PX).move_to(5 * PX, 5 * PX),
        shape::rect(PX, 2 * PX).move_to(7 * PX, 5 * PX),
    ]);
    add_class!(&mut office, ACCENT);
    builder.body.insert(b"office".to_string(), office);

    // body: tshirt
    let mut tshirt = container::g(vector[
        shape::rect(PX, PX).move_to(3 * PX, 5 * PX),
        shape::rect(PX, PX).move_to(7 * PX, 5 * PX),
    ]);
    add_class!(&mut tshirt, BODY);
    builder.body.insert(b"tshirt".to_string(), tshirt);
}

/// Display setup
fun set_display(d: &mut Display<Character>) {
    let mut image_url = b"data:image/svg+xml;charset=utf8,".to_string();
    image_url.append(urlencode::encode(build_character_base().into_bytes()));

    d.add(b"image_url".to_string(), image_url);
    d.add(b"name".to_string(), b"Brave Character!".to_string());
    d.add(b"description".to_string(), b"How wild can you go?".to_string());
    d.add(b"link".to_string(), b"https://potatoes.app/character/{id}".to_string());
    d.add(b"project_url".to_string(), b"https://potatoes.app/".to_string());
    d.add(b"creator".to_string(), b"Sui Potatoes (c)".to_string());
    d.update_version();
}

fun build_pure_svg(): String {
    let mut body = shape::rect(3 * PX, 3 * PX).move_to(4 * PX, 5 * PX);
    add_class!(&mut body, BODY);

    let mut head = shape::rect(3 * PX, 3 * PX).move_to(4 * PX, 2 * PX);
    add_class!(&mut head, SKIN);

    let mut eyes = container::g(vector[
        shape::rect(PX, PX).move_to(4 * PX, 3 * PX),
        shape::rect(PX, PX).move_to(6 * PX, 3 * PX),
    ]);
    add_class!(&mut eyes, EYES);

    let mut legs = container::g(vector[
        shape::rect(PX, 3 * PX).move_to(4 * PX, 8 * PX),
        shape::rect(PX, PX).move_to(5 * PX, 8 * PX),
        shape::rect(PX, 3 * PX).move_to(6 * PX, 8 * PX),
    ]);
    add_class!(&mut legs, LEGS);

    let mut hands = container::g(vector[
        shape::rect(PX, 3 * PX).move_to(3 * PX, 5 * PX),
        shape::rect(PX, 3 * PX).move_to(7 * PX, 5 * PX),
    ]);
    add_class!(&mut hands, SKIN);

    // New SVG with the viewbox.
    let mut svg = svg::svg(vector[0, 0, 11 * PX, 12 * PX]);
    let styles = shape::custom(b"<style>.s{fill:#SKIN} .e{fill:#EYES} .h{fill:#HAIR} .l{fill:#PANTS} .b{fill:#BODY} .a{fill:#ACCENT}</style>".to_string());

    svg.root(vector[styles, body, head]);
    svg.add(eyes);
    svg.add(legs);
    svg.add(hands);
    svg.root(vector[shape::custom(b"TEMPLATE".to_string())]); // template
    svg.to_string()
}

/// Builds the base character SVG template, used in the `Display` in the
/// `init` (`set_display`) function.
fun build_character_base(): String {
    let template = build_pure_svg();

    // then run replacement script with the following values
    // HAIR -> {image.hair_colour}
    // EYES -> {image.eyes_colour}w
    // PANTS -> {image.pants_colour}
    // SKIN -> {image.skin_colour}
    // BODY -> {image.base_colour}
    // ACCENT -> {image.accent_colour}

    // ideally let's just write the template with Move...
    let template = replace(template, b"SKIN".to_string(), b"{image.skin_colour}".to_string());
    let template = replace(template, b"EYES".to_string(), b"{image.eyes_colour}".to_string());
    let template = replace(template, b"HAIR".to_string(), b"{image.hair_colour}".to_string());
    let template = replace(template, b"PANTS".to_string(), b"{image.pants_colour}".to_string());
    let template = replace(template, b"BODY".to_string(), b"{image.base_colour}".to_string());
    let template = replace(
        template,
        b"ACCENT".to_string(),
        b"{image.accent_colour}".to_string(),
    );
    let template = replace(
        template,
        b"TEMPLATE".to_string(),
        b"{image.hair}{image.body}".to_string(),
    );

    template
}

fun replace(str: String, from: String, to: String): String {
    let pos = str.index_of(&from);
    let str = {
        let mut lhs = str.substring(0, pos);
        let rhs = str.substring(pos + from.length(), str.length());
        lhs.append(to);
        lhs.append(rhs);
        lhs
    };
    str
}

#[test_only]
public fun new_builder_for_testing(ctx: &mut TxContext): Builder {
    let mut builder = Builder {
        id: object::new(ctx),
        body: vec_map::empty(),
        hair: vec_map::empty(),
        colours: PALETTE,
    };

    builder.set_initial_assets();
    builder
}

#[test]
fun test_preview_character_build() {
    let mut image_url = b"data:image/svg+xml;charset=utf8,".to_string();
    image_url.append(urlencode::encode(build_character_base().into_bytes()));
    // std::debug::print(&image_url);
}

#[test]
fun test_init() {
    let ctx = &mut tx_context::dummy();
    init(CHARACTER {}, ctx);
}
