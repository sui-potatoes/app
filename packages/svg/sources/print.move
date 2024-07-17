// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: print
module svg::print {
    use std::string::String;
    use sui::vec_map::VecMap;

    public fun print(
        name: String,
        attributes: VecMap<String, String>,
        elements: Option<vector<String>>,
    ): String {
        let mut svg = b"<".to_string();
        svg.append(name);
        svg.append(b" ".to_string());
        let (keys, values) = attributes.into_keys_values();
        keys
            .length()
            .do!(
                |i| {
                    svg.append(keys[i]);
                    svg.append(b"=\"".to_string());
                    svg.append(values[i]);
                    svg.append(b"\" ".to_string());
                },
            );

        if (elements.is_none()) {
            svg.append(b"/>".to_string());
            return svg
        };

        elements.do!(|vec| vec.do!(|el| svg.append(el)));
        svg.append(b"</".to_string());
        svg.append(name);
        svg.append(b">".to_string());
        svg
    }

    public fun num_to_string(mut num: u64): String {
        let mut chars = vector[];
        while (num > 0) {
            let digit = num % 10;
            num = num / 10;
            chars.push_back((digit + 48) as u8);
        };
        chars.reverse();
        chars.to_string()
    }
}
