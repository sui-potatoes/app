/// Module: black_spots
module spots::urlencode {
    use std::ascii::String;

    /// Encode a string to be used in a URL.
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

    /// Decode a string that was encoded for a URL.
    public fun urldecode(s: &String): String {
        let mut res = vector[];
        let mut i = 0;
        while (i < s.length()) {
            let c = s.as_bytes()[i];
            if (c == 37) { // "%"
                let c1 = s.as_bytes()[i + 1];
                let c2 = s.as_bytes()[i + 2];
                let n1 = if (c1 >= 48 && c1 <= 57) c1 - 48
                    else if (c1 >= 65 && c1 <= 70) c1 - 55
                    else c1 - 87;

                let n2 = if (c2 >= 48 && c2 <= 57) c2 - 48
                    else if (c2 >= 65 && c2 <= 70) c2 - 55
                    else c2 - 87;
                res.push_back(n1 * 16 + n2);
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
            urlencode(&b"http://example.com/?q=foo bar".to_ascii_string()),
            b"http%3A%2F%2Fexample%2Ecom%2F%3Fq%3Dfoo%20bar".to_ascii_string()
        );

        assert_eq(
            urlencode(&b"haha this is a test".to_ascii_string()),
            b"haha%20this%20is%20a%20test".to_ascii_string()
        );
    }

    #[test]
    fun test_urldecode() {
        use sui::test_utils::assert_eq;

        assert_eq(
            urldecode(&b"http%3A%2F%2Fexample%2Ecom%2F%3Fq%3Dfoo%20bar".to_ascii_string()),
            b"http://example.com/?q=foo bar".to_ascii_string()
        );

        assert_eq(
            urldecode(&b"haha%20this%20is%20a%20test".to_ascii_string()),
            b"haha this is a test".to_ascii_string()
        );
    }
}
