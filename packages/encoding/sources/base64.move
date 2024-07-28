// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: base64
module encoding::base64 {
    use std::string::String;

    /// Base64 keys.
    const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    /// Encode the `str` to base64.
    public fun encode(mut bytes: vector<u8>): String {
        let keys = KEYS;
        let mut res = vector[];
        bytes.reverse();

        while (bytes.length() > 0) {
            let b1 = bytes.pop_back();
            let b2 = if (bytes.length() > 0) bytes.pop_back() else 0;
            let b3 = if (bytes.length() > 0) bytes.pop_back() else 0;

            let c1 = b1 >> 2;
            let c2 = ((b1 & 3) << 4) | (b2 >> 4);
            let c3 = if (b2 == 0) 64 else ((b2 & 15) << 2) | (b3 >> 6);
            let c4 = if (b3 == 0) 64 else b3 & 63;

            res.append(vector[keys[c1 as u64], keys[c2 as u64], keys[c3 as u64], keys[c4 as u64]]);
        };

        res.to_string()
    }

    /// Decode the base64 `str`.
    public fun decode(str: String): vector<u8> {
        let keys = KEYS;
        let mut res = vector[];
        let mut bytes = str.into_bytes();
        bytes.reverse();

        // Ensure the length is a multiple of 4.
        assert!(bytes.length() % 4 == 0);

        while (bytes.length() > 0) {
            let (_, b1) = keys.index_of(&bytes.pop_back());
            let (_, b2) = keys.index_of(&bytes.pop_back());
            let (_, b3) = keys.index_of(&bytes.pop_back());
            let (_, b4) = keys.index_of(&bytes.pop_back());

            let c1 = (b1 << 2) | (b2 >> 4);
            let c2 = ((b2 & 15) << 4) | (b3 >> 2);
            let c3 = ((b3 & 3) << 6) | b4;

            res.push_back(c1 as u8);
            if (b3 != 64) res.push_back(c2 as u8);
            if (b4 != 64) res.push_back(c3 as u8);
        };

        res
    }

    #[test]
    fun test_encode() {
        use sui::test_utils::assert_eq;

        assert_eq(encode(b"hello"), b"aGVsbG8=".to_string());
        assert_eq(encode(b"world"), b"d29ybGQ=".to_string());
        assert_eq(encode(b"hello world"), b"aGVsbG8gd29ybGQ=".to_string());
        assert_eq(encode(b"sui potatoes"), b"c3VpIHBvdGF0b2Vz".to_string());

        // need to create tricky use case for encode - padding
        assert_eq(encode(b"/"), b"Lw==".to_string());
        assert_eq(encode(b"//"), b"Ly8=".to_string());
        assert_eq(encode(b"///"), b"Ly8v".to_string());
    }

    #[test]
    fun test_decode() {
        use sui::test_utils::assert_eq;

        assert_eq(decode(b"aGVsbG8=".to_string()), b"hello");
        assert_eq(decode(b"d29ybGQ=".to_string()), b"world");
        assert_eq(decode(b"aGVsbG8gd29ybGQ=".to_string()), b"hello world");
        assert_eq(decode(b"c3VpIHBvdGF0b2Vz".to_string()), b"sui potatoes");
    }

    #[test, expected_failure]
    fun test_decode_failure() {
        // count of characters is not multiple of 4
        decode(b"aGVsbG8".to_string());
    }
}
