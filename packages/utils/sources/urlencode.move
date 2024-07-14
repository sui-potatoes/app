// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements URL encoding and decoding.
module utils::urlencode {
    use std::ascii::String;

    /// Encode a string to URL format.
    public fun urlencode(string: &String): String {
        let mut res = vector[];
        let mut i = 0;
        let bytes = string.as_bytes();
        bytes.do_ref!(
            |c| if (*c == 32) {
                res.append(b"%20");
            } else if ((*c < 48 || *c > 57) && (*c < 65 || *c > 90) && (*c < 97 || *c > 122)) {
                res.push_back(37);
                res.push_back((*c / 16) + if (*c / 16 < 10) 48 else 55);
                res.push_back((*c % 16) + if (*c % 16 < 10) 48 else 55);
            } else {
                res.push_back(*c);
            },
        );
        res.to_ascii_string()
    }

    /// Decode a URL-encoded string.
    public fun urldecode(s: &String): String {
        let mut res = vector[];
        let mut i = 0;
        while (i < s.length()) {
            let c = s.as_bytes()[i];
            if (c == 37) {
                // percent "%"
                let a = s.as_bytes()[i + 1];
                let b = s.as_bytes()[i + 2];
                let a = if (a >= 65) a - 55 else a - 48;
                let b = if (b >= 65) b - 55 else b - 48;
                res.push_back(a * 16 + b);
                i = i + 2;
            } else {
                res.push_back(c);
            };
            i = i + 1;
        };
        res.to_ascii_string()
    }

    #[test]
    fun test_urlencode() {
        use sui::test_utils::assert_eq;

        assert_eq(
            urlencode(&b"Hello, World!".to_ascii_string()),
            b"Hello%2C%20World%21".to_ascii_string(),
        );

        let str = b"Hello, World!?<>aa:;".to_ascii_string();
        assert_eq(urldecode(&urlencode(&str)), str);
    }
}
