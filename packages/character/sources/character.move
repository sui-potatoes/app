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
module character::character {
    use std::string::{Self, String};
    use std::type_name;
    use sui::display::{Self, Display};
    use sui::vec_map::{Self, VecMap};
    use sui::dynamic_field as df;
    use sui::package;

    use potatoes_utils::urlencode;
    use svg::{svg, shape, container::{Self, Container}, macros::add_class};

    const EWrongBody: u64 = 1;
    const EWrongHair: u64 = 2;
    const EWrongEyesColour: u64 = 3;
    const EWrongPantsColour: u64 = 4;
    const EWrongSkinColour: u64 = 5;
    const EWrongBaseColour: u64 = 6;
    const EWrongAccentColour: u64 = 7;
    const EWrongHairColour: u64 = 8;

    /// Trying to add a dynamic field with a primitive type to the character.
    const EIncorrectDynamicField: u64 = 9;

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
        /// Pants colour, a HEX string.
        pants_colour: String,
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
        pants_colour: String,
        skin_colour: String,
        base_colour: String,
        accent_colour: String,
        ctx: &mut TxContext,
    ): Character {
        assert!(b.body.contains(&body_type), EWrongBody);
        assert!(b.hair.contains(&hair_type), EWrongHair);
        assert!(b.colours.contains(hair_colour.as_bytes()), EWrongHairColour);
        assert!(b.colours.contains(eyes_colour.as_bytes()), EWrongEyesColour);
        assert!(b.colours.contains(pants_colour.as_bytes()), EWrongPantsColour);
        assert!(b.colours.contains(skin_colour.as_bytes()), EWrongSkinColour);
        assert!(b.colours.contains(base_colour.as_bytes()), EWrongBaseColour);
        assert!(b.colours.contains(accent_colour.as_bytes()), EWrongAccentColour);

        let image = Props {
            body: urlencode::encode(b.body[&body_type].to_string()),
            hair: urlencode::encode(b.hair[&hair_type].to_string()),
            body_type,
            hair_type,
            eyes_colour,
            hair_colour,
            pants_colour,
            skin_colour,
            base_colour,
            accent_colour,
        };

        Character { id: object::new(ctx), image }
    }

    /// Edit the character.
    public fun edit(
        b: &mut Builder,
        c: &mut Character,
        body_type: String,
        hair_type: String,
        eyes_colour: String,
        hair_colour: String,
        pants_colour: String,
        skin_colour: String,
        base_colour: String,
        accent_colour: String,
        _ctx: &mut TxContext,
    ) {
        assert!(b.body.contains(&body_type), EWrongBody);
        assert!(b.hair.contains(&hair_type), EWrongHair);
        assert!(b.colours.contains(hair_colour.as_bytes()), EWrongHairColour);
        assert!(b.colours.contains(eyes_colour.as_bytes()), EWrongEyesColour);
        assert!(b.colours.contains(pants_colour.as_bytes()), EWrongPantsColour);
        assert!(b.colours.contains(skin_colour.as_bytes()), EWrongSkinColour);
        assert!(b.colours.contains(base_colour.as_bytes()), EWrongBaseColour);
        assert!(b.colours.contains(accent_colour.as_bytes()), EWrongAccentColour);

        c.image.body = urlencode::encode(b.body[&body_type].to_string());
        c.image.hair = urlencode::encode(b.hair[&hair_type].to_string());
        c.image.body_type = body_type;
        c.image.hair_type = hair_type;
        c.image.eyes_colour = eyes_colour;
        c.image.hair_colour = hair_colour;
        c.image.pants_colour = pants_colour;
        c.image.skin_colour = skin_colour;
        c.image.base_colour = base_colour;
        c.image.accent_colour = accent_colour;
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
    public fun pants_colour(c: &Character): String { c.image.pants_colour }

    /// Get the skin colour of the character.
    public fun skin_colour(c: &Character): String { c.image.skin_colour }

    /// Get the base colour of the character.
    public fun base_colour(c: &Character): String { c.image.base_colour }

    /// Get the accent colour of the character.
    public fun accent_colour(c: &Character): String { c.image.accent_colour }

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

        set_initial_assets(&mut builder);
        set_display(&mut display);

        transfer::public_transfer(display, ctx.sender());
        transfer::public_transfer(publisher, ctx.sender());
        transfer::share_object(builder);
    }

    /// Set the initial assets for the character.
    fun set_initial_assets(builder: &mut Builder) {
        // hair: punk
        let mut punk = container::g(vector[
            shape::rect(80, 20, 60, 20),
            shape::rect(80, 0, 40, 20),
        ]);

        add_class!(&mut punk, HAIR);
        builder.hair.insert(b"punk".to_string(), punk);

        // hair: flat
        let mut flat = shape::rect(80, 20, 60, 20);
        add_class!(&mut flat, HAIR);
        builder.hair.insert(b"flat".to_string(), container::root(vector[flat]));

        // hair: bang
        let mut bang = container::g(vector[
            shape::rect(80, 20, 60, 20),
            shape::rect(120, 40, 20, 20),
        ]);
        add_class!(&mut bang, HAIR);
        builder.hair.insert(b"bang".to_string(), bang);

        // hair: wind
        let mut wind = container::g(vector[
            shape::rect(60, 20, 20, 60),
            shape::rect(80, 20, 80, 20),
            shape::rect(140, 40, 40, 40),
            shape::rect(180, 40, 20, 20),
        ]);
        add_class!(&mut wind, HAIR);
        builder.hair.insert(b"wind".to_string(), wind);

        // body: blazer
        let mut blazer = container::g(vector[
            shape::rect(80, 100, 20, 20),
            shape::rect(120, 100, 20, 20),
            shape::rect(100, 120, 20, 20),
            shape::rect(60, 100, 20, 20),
            shape::rect(140, 100, 20, 20),
        ]);
        add_class!(&mut blazer, BODY);
        builder.body.insert(b"blazer".to_string(), blazer);

        // body: office
        let mut office = container::g(vector[
            shape::rect(60, 100, 20, 40),
            shape::rect(100, 100, 20, 40),
            shape::rect(140, 100, 20, 40),
        ]);
        add_class!(&mut office, ACCENT);
        builder.body.insert(b"office".to_string(), office);

        // body: tshirt
        let mut tshirt = container::g(vector[
            shape::rect(60, 100, 20, 20),
            shape::rect(140, 100, 20, 20),
        ]);
        add_class!(&mut tshirt, BODY);
        builder.body.insert(b"tshirt".to_string(), tshirt);
    }

    /// Display setup
    fun set_display(d: &mut Display<Character>) {
        let mut image_url = b"data:image/svg+xml;charset=utf8,".to_string();
        image_url.append(build_character_base());

        d.add(b"image_url".to_string(), image_url);
        d.add(b"name".to_string(), b"Brave Character!".to_string());
        d.add(b"description".to_string(), b"How wild can you go?".to_string());
        d.add(b"link".to_string(), b"https://potatoes.app/character/{id}".to_string());
        d.add(b"project_url".to_string(), b"https://potatoes.app/".to_string());
        d.add(b"creator".to_string(), b"Sui Potatoes (c)".to_string());
        d.update_version();
    }

    fun build_pure_svg(): String {
        let mut body = shape::rect(80, 100, 60, 60);
        add_class!(&mut body, BODY);

        let mut head = shape::rect(80, 40, 60, 60);
        add_class!(&mut head, SKIN);

        let mut eyes = container::g(vector[
            shape::rect(80, 60, 20, 20),
            shape::rect(120, 60, 20, 20),
        ]);
        add_class!(&mut eyes, EYES);

        let mut legs = container::g(vector[
            shape::rect(80, 160, 20, 60),
            shape::rect(100, 160, 20, 20),
            shape::rect(120, 160, 20, 60),
        ]);
        add_class!(&mut legs, LEGS);

        let mut hands = container::g(vector[
            shape::rect(60, 100, 20, 60),
            shape::rect(140, 100, 20, 60),
        ]);
        add_class!(&mut hands, SKIN);

        // New SVG with the viewbox.
        let mut svg = svg::svg(vector[0, 0, 220, 240]);
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
    fun build_character_base(): string::String {
        let template = build_pure_svg();

        // then run replacement script with the following values
        // HAIR -> {image.hair_colour}
        // EYES -> {image.eyes_colour}
        // PANTS -> {image.pants_colour}
        // SKIN -> {image.skin_colour}
        // BODY -> {image.base_colour}
        // ACCENT -> {image.accent_colour}

        // ideally let's just write the template with Move...
        let template = replace(template, b"HAIR".to_string(), b"{image.hair_colour}".to_string());
        let template = replace(template, b"EYES".to_string(), b"{image.eyes_colour}".to_string());
        let template = replace(template, b"PANTS".to_string(), b"{image.pants_colour}".to_string());
        let template = replace(template, b"SKIN".to_string(), b"{image.skin_colour}".to_string());
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

    #[test]
    fun test_preview_character_build() {
        let mut image_url = b"data:image/svg+xml;charset=utf8,".to_string();
        image_url.append(urlencode::encode(build_character_base()));
        std::debug::print(&image_url);
    }
}
