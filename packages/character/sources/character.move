/// Module: character
///
/// Ideally the static implementation should be contained in a shared object, so
/// that the admin could register new assets for character building. To keep the
/// engine pure and simple, we provide them statically based on the inputs.
module character::character {
    use std::ascii::String;
    use sui::display::{Self, Display};
    use sui::vec_map::{Self, VecMap};
    use sui::package;
    use gogame::render;

    const EWrongBody: u64 = 1;
    const EWrongHair: u64 = 2;
    const EWrongEyesColour: u64 = 3;
    const EWrongPantsColour: u64 = 4;
    const EWrongSkinColour: u64 = 5;
    const EWrongBaseColour: u64 = 6;
    const EWrongAccentColour: u64 = 7;
    const EWrongHairColour: u64 = 8;

    /// EDG 32 palette. Classic 32 colour palette.
    const PALETTE: vector<vector<u8>> = vector[
        b"be4a2f", b"d77643", b"ead4aa", b"e4a672",
        b"b86f50", b"733e39", b"3e2731", b"a22633",
        b"e43b44", b"f77622", b"feae34", b"fee761",
        b"63c74d", b"3e8948", b"265c42", b"193c3e",
        b"124e89", b"0099db", b"2ce8f5", b"ffffff",
        b"c0cbdc", b"8b9bb4", b"5a6988", b"3a4466",
        b"262b44", b"181425", b"ff0044", b"68386c",
        b"b55088", b"f6757a", b"e8b796", b"c28569",
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
        body: VecMap<String, vector<Rect>>,
        hair: VecMap<String, vector<Rect>>,
        colours: vector<vector<u8>>
    }

    /// The OTW for the application.
    public struct CHARACTER has drop {}

    /// Single rectangle shape in the SVG. The first four values are the
    /// x and y coordinates, then the width and height. The last parameter is
    /// the class of the shape.
    public struct Rect(u8, u8, u8, u8, String) has store, copy, drop;

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
        ctx: &mut TxContext
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
            body: render::urlencode(&render_part(b.body[&body_type])),
            hair: render::urlencode(&render_part(b.hair[&hair_type])),
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
        _ctx: &mut TxContext
    ) {
        assert!(b.body.contains(&body_type), EWrongBody);
        assert!(b.hair.contains(&hair_type), EWrongHair);
        assert!(b.colours.contains(hair_colour.as_bytes()), EWrongHairColour);
        assert!(b.colours.contains(eyes_colour.as_bytes()), EWrongEyesColour);
        assert!(b.colours.contains(pants_colour.as_bytes()), EWrongPantsColour);
        assert!(b.colours.contains(skin_colour.as_bytes()), EWrongSkinColour);
        assert!(b.colours.contains(base_colour.as_bytes()), EWrongBaseColour);
        assert!(b.colours.contains(accent_colour.as_bytes()), EWrongAccentColour);

        c.image.body = render::urlencode(&render_part(b.body[&body_type]));
        c.image.hair = render::urlencode(&render_part(b.hair[&hair_type]));
        c.image.body_type = body_type;
        c.image.hair_type = hair_type;
        c.image.eyes_colour = eyes_colour;
        c.image.hair_colour = hair_colour;
        c.image.pants_colour = pants_colour;
        c.image.skin_colour = skin_colour;
        c.image.base_colour = base_colour;
        c.image.accent_colour = accent_colour;
    }

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

    fun rect_to_svg_bytes(rect: Rect): vector<u8> {
        let Rect(x, y, w, h, class) = rect;
        let mut res = vector[];
        let data = vector[
            b"<rect x='", num_to_ascii(x), b"' y='", num_to_ascii(y), b"' width='", num_to_ascii(w), b"' height='", num_to_ascii(h), b"' class='", class.into_bytes(), b"'/>"
        ];

        let mut i = 0;
        while (i < data.length()) {
            res.append(data[i]);
            i = i + 1;
        };
        res
    }

    fun render_part(mut part: vector<Rect>): String {
        let mut res = vector[];
        while (part.length() > 0) {
            res.append(rect_to_svg_bytes(part.pop_back()));
        };
        res.to_ascii_string()
    }

    fun num_to_ascii(mut num: u8): vector<u8> {
        let mut res = vector[];
        if (num == 0) return vector[ 48 ];
        while (num > 0) {
            let digit = (num % 10) as u8;
            num = num / 10;
            res.insert(digit + 48, 0);
        };
        res //
    }


    /// Set the initial assets for the character.
    fun set_initial_assets(builder: &mut Builder) {
        builder.hair.insert(b"punk".to_ascii_string(), vector[
            Rect(80, 20, 60, 20, b"h".to_ascii_string()),
            Rect(80, 0, 40, 20, b"h".to_ascii_string()),
        ]);
        builder.hair.insert(b"flat".to_ascii_string(), vector[
            Rect(80, 20, 60, 20, b"h".to_ascii_string())
        ]);
        builder.hair.insert(b"bang".to_ascii_string(), vector[
            Rect(80, 20, 60, 20, b"h".to_ascii_string()),
            Rect(120, 40, 20, 20, b"h".to_ascii_string()),
        ]);
        builder.hair.insert(b"wind".to_ascii_string(), vector[
            Rect(60, 20, 20, 60, b"h".to_ascii_string()),
            Rect(70, 20, 80, 20, b"h".to_ascii_string()),
            Rect(140, 40, 40, 40, b"h".to_ascii_string()),
            Rect(180, 40, 20, 20, b"h".to_ascii_string()),
        ]);

        builder.body.insert(b"blazer".to_ascii_string(), vector[
            Rect(80, 100, 20, 20, b"b".to_ascii_string()), // left
            Rect(120, 100, 20, 20, b"b".to_ascii_string()), // right
            Rect(100, 120, 20, 20, b"b".to_ascii_string()), // top
            Rect(60, 100, 20, 20, b"a".to_ascii_string()), // left shoulder
            Rect(140, 100, 20, 20, b"a".to_ascii_string()), // right shoulder
        ]);
        builder.body.insert(b"office".to_ascii_string(), vector[
            Rect(60, 100, 20, 40, b"a".to_ascii_string()), // left
            Rect(100, 100, 20, 40, b"a".to_ascii_string()), // top
            Rect(140, 100, 20, 40, b"a".to_ascii_string()), // right
        ]);
        builder.body.insert(b"tshirt".to_ascii_string(), vector[
            Rect(60, 100, 20, 20, b"b".to_ascii_string()), // left shoulder
            Rect(140, 100, 20, 20, b"b".to_ascii_string()), // right shoulder
        ]);
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

    // classes, short:
    // b - body
    // h - hair
    // e - eyes
    // l - legs
    // s - skin
    // a - accent
    // p - pants
    // empty - empty space

    fun build_pure_svg(): String {
        let body = Rect(80, 100, 60, 60, b"b".to_ascii_string());
        let head = Rect(80, 40, 60, 60, b"s".to_ascii_string());
        let l_eye = Rect(80, 60, 20, 20, b"e".to_ascii_string());
        let r_eye = Rect(120, 60, 20, 20, b"e".to_ascii_string());
        let legs = Rect(80, 160, 60, 60, b"l".to_ascii_string());
        let legs_space = Rect(100, 180, 20, 40, b"empty".to_ascii_string());
        let l_hand = Rect(60, 100, 20, 60, b"s".to_ascii_string());
        let r_hand = Rect(140, 100, 20, 60, b"s".to_ascii_string());

        let mut svg = vector[];
        svg.append(b"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 220 240'>");
        svg.append(b"<style>.empty{fill:#fff} .s{fill:#SKIN} .e{fill:#EYES} .h{fill:#HAIR} .l{fill:#PANTS} .b{fill:#BODY} .a{fill:#ACCENT}</style>");
        svg.append(rect_to_svg_bytes(body));
        svg.append(rect_to_svg_bytes(head));
        svg.append(rect_to_svg_bytes(l_eye));
        svg.append(rect_to_svg_bytes(r_eye));
        svg.append(rect_to_svg_bytes(legs));
        svg.append(rect_to_svg_bytes(legs_space));
        svg.append(rect_to_svg_bytes(l_hand));
        svg.append(rect_to_svg_bytes(r_hand));
        svg.append(b"TEMPLATE");
        svg.append(b"</svg>");
        svg.to_ascii_string()
    }

    /// Builds the base character SVG template, used in the `Display` in the
    /// `init` (`set_display`) function.
    fun build_character_base(): string::String {
        let template = gogame::render::urlencode(&build_pure_svg()).to_string();

        // std::debug::print(&url_encode);

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
        let template = replace(template, b"ACCENT".to_string(), b"{image.accent_colour}".to_string());
        let template = replace(template, b"TEMPLATE".to_string(), b"{image.hair}{image.body}".to_string());

        template
    }

    use std::string;

    fun replace(str: string::String, from: string::String, to: string::String): string::String {
        let pos = str.index_of(&from);
        let str = {
            let mut lhs = str.sub_string(0, pos);
            let rhs = str.sub_string(pos + from.length(), str.length());
            lhs.append(to);
            lhs.append(rhs);
            lhs
        };
        str
    }
}
