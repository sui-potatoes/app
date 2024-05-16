// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module gogame::render {
    use std::ascii::String;
    use gogame::go::{Self,Board};

    /// Print the board as an SVG.
    public fun svg(b: &Board): String {
        let size = b.size() as u64;
        let cell_size = 20;
        let padding = 1;

        let width = num_to_ascii((size * (cell_size + 1)) + (size * padding));

        let mut i = 0;
        let mut chunks = vector[
            // SVG header
            b"<svg width='", width, b"' height='", width, b"' xmlns='http://www.w3.org/2000/svg'>",
            b"<defs>",
            b"<pattern id='grid' width='", num_to_ascii(cell_size + padding), b"' x='10' y='10' height='", num_to_ascii(cell_size + padding), b"' patternUnits='userSpaceOnUse'>",
            b"<path d='M 40 0 L 0 0 0 40' fill='none' stroke='gray' stroke-width='0.8'/>",
            b"</pattern>",
            b"<style>",
            b" circle { stroke: #000; }",
            b" .b { fill: #000; }",
            b" .w { fill: #fff; }",
            b"</style>",
            b"</defs>",
            b"<rect width='", width, b"' height='", width, b"' fill='url(#grid)' />",
        ];

        while (i < size) {
            let mut j = 0;
            while (j < size) {
                if (b.data()[i][j].is_empty()) {
                    j = j + 1;
                    continue
                };

                let cx = (i * cell_size) + (i * padding) + 10;
                let cy = (j * cell_size) + (j * padding) + 10;
                let class = if (b.data()[i][j].is_black()) b"b" else b"w";

                chunks.append(vector[
                    b"<circle r='10' cy='", num_to_ascii(cy), b"' cx='", num_to_ascii(cx), b"' class='", class, b"' />"
                ]);

                j = j + 1;
            };
            i = i + 1;
        };

        // let mut str = b"".to_ascii_string();
        chunks.push_back(b"</svg>");
        chunks.reverse();
        let mut str = vector[];
        while (!chunks.is_empty()) {
            let chunk = chunks.pop_back();
            str.append(chunk);
        };
        // str
        str.to_ascii_string()
    }

    public fun urlencode(s: &String): String {
        let mut res = vector[];
        let mut i = 0;
        while (i < s.length()) {
            let c = s.as_bytes()[i];
            if (c == 32) { // whitespace " "
                res.append(b"%20")
            } else if ((c < 48 || c > 57) && (c < 65 || c > 90) && (c < 97 || c > 122)) {
                res.push_back(37);
                res.push_back((c / 16) + if (c / 16 < 10) 48 else 55);
                res.push_back((c % 16) + if (c % 16 < 10) 48 else 55);
            } else {
                res.push_back(c);
            };
            i = i + 1;
        };
        res.to_ascii_string()
    }

    fun num_to_ascii(mut num: u64): vector<u8> {
        let mut res = vector[];
        if (num == 0) return vector[ 48 ];
        while (num > 0) {
            let digit = (num % 10) as u8;
            num = num / 10;
            res.insert(digit + 48, 0);
        };
        res //
    }

    #[test]
    fun test_rendering_safari() {
        let board = go::from_vector(vector[
            vector[0, 0, 0, 0, 0, 0, 0, 0, 0],
            vector[0, 0, 2, 0, 0, 0, 0, 1, 0],
            vector[0, 1, 2, 1, 1, 1, 1, 0, 0],
            vector[0, 1, 1, 2, 2, 2, 2, 1, 0],
            vector[0, 1, 2, 2, 0, 2, 0, 1, 0],
            vector[0, 0, 1, 2, 2, 2, 2, 0, 0],
            vector[0, 1, 1, 1, 1, 2, 0, 2, 2],
            vector[0, 1, 0, 1, 2, 0, 2, 0, 0],
            vector[1, 0, 1, 2, 2, 2, 0, 0, 0],
        ]);


        let res = urlencode(&svg(&board));
        let mut data_url = b"data:image/svg+xml;charset=utf8,";
        data_url.append(res.into_bytes());

        std::debug::print(&data_url.to_ascii_string());
        std::debug::print(&data_url.length());

    }
}
