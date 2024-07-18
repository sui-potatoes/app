// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: print
module svg::print {
    use std::string::String;
    use sui::vec_map::VecMap;

    /// Prints a generic SVG element, with attributes and elements.
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
        length.do!(
            |i| {
                svg.append(keys[i]);
                svg.append(b"='".to_string());
                svg.append(values[i]);
                if (i < length - 1) svg.append(b"' ".to_string())
                else svg.append(b"'".to_string())
            },
        );

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

    /// Converts a number to a string, uses u16 for the digits.
    public fun num_to_string(mut num: u16): String {
        let mut chars = vector[];

        if (num == 0) {
            chars.push_back(48);
            return chars.to_string()
        };

        while (num > 0) {
            let digit = num % 10;
            num = num / 10;
            chars.push_back((digit + 48) as u8);
        };
        chars.reverse();
        chars.to_string()
    }
}
