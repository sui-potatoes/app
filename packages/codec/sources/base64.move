// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Base64 encoding.
///
/// See [RFC 4648; Section 4](https://datatracker.ietf.org/doc/html/rfc4648#section-4) for more details.
module codec::base64;

use std::string::String;

#[allow(unused_const)]
/// Error code for illegal character.
const EIllegalCharacter: u64 = 0;
#[allow(unused_const)]
/// Error code for incorrect number of characters.
const EIncorrectNumberOfCharacters: u64 = 1;

/// Base64 keys.
const KEYS: vector<u8> = b"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

/// Encode the `str` to base64.
public fun encode(bytes: vector<u8>): String {
    encode_impl!(bytes, KEYS, true)
}

/// Decode the base64 `str`.
public fun decode(str: String): vector<u8> {
    decode_impl!(str, KEYS)
}

/// Internal macro for base64-based encodings, allows to use different dictionaries
/// and control padding.
public(package) macro fun encode_impl(
    $bytes: vector<u8>,
    $dictionary: vector<u8>,
    $pad: bool,
): String {
    let mut bytes = $bytes;
    let keys = $dictionary;
    let mut res = vector[];
    let mut len = bytes.length();
    bytes.reverse();

    while (len > 0) {
        len = len - 1;
        let b1 = bytes.pop_back();
        let b2 = if (len > 0) { len = len - 1; bytes.pop_back() } else 0;
        let b3 = if (len > 0) { len = len - 1; bytes.pop_back() } else 0;

        let c1 = b1 >> 2;
        let c2 = ((b1 & 3) << 4) | (b2 >> 4);
        let c3 = if (b2 == 0) 64 else ((b2 & 15) << 2) | (b3 >> 6);
        let c4 = if (b3 == 0) 64 else b3 & 63;

        res.push_back(keys[c1 as u64]);
        res.push_back(keys[c2 as u64]);
        res.push_back(keys[c3 as u64]);
        res.push_back(keys[c4 as u64]);
    };

    res.to_string()
}

public(package) macro fun decode_impl($str: String, $dictionary: vector<u8>): vector<u8> {
    let keys = $dictionary;
    let str = $str;
    let mut res = vector[];

    // Ensure the length is a multiple of 4.
    assert!(str.length() % 4 == 0, 1);

    let mut buffer = 0u32;
    let mut bits_collected = 0;

    str.into_bytes().do!(|byte| {
        let (res1, val) = keys.index_of(&byte);
        assert!(res1, 0);
        if (val == 64) return;
        buffer = (buffer << 6) | (val as u32);
        bits_collected = bits_collected + 6;

        if (bits_collected >= 8) {
            bits_collected = bits_collected - 8;
            let byte = (buffer >> bits_collected) & 0xFF;
            res.push_back(byte as u8);
        }
    });

    res
}

#[test]
fun test_encode() {
    use std::unit_test::assert_eq;

    assert_eq!(encode(b"hello"), b"aGVsbG8=".to_string());
    assert_eq!(encode(b"world"), b"d29ybGQ=".to_string());
    assert_eq!(encode(b"hello world"), b"aGVsbG8gd29ybGQ=".to_string());
    assert_eq!(encode(b"sui potatoes"), b"c3VpIHBvdGF0b2Vz".to_string());

    // need to create tricky use case for encode - padding
    assert_eq!(encode(b"/"), b"Lw==".to_string());
    assert_eq!(encode(b"//"), b"Ly8=".to_string());
    assert_eq!(encode(b"///"), b"Ly8v".to_string());
}

#[random_test]
fun test_decode_random(bytes: vector<u8>) {
    use std::unit_test::assert_eq;
    // std::debug::print(&encode(bytes));
    let encoded = encode(bytes);
    assert_eq!(decode(encode(bytes)), bytes);
}

#[test]
fun test_decode() {
    use std::unit_test::assert_eq;

    assert_eq!(decode(b"aGVsbG8=".to_string()), b"hello");
    assert_eq!(decode(b"d29ybGQ=".to_string()), b"world");
    assert_eq!(decode(b"aGVsbG8gd29ybGQ=".to_string()), b"hello world");
    assert_eq!(decode(b"c3VpIHBvdGF0b2Vz".to_string()), b"sui potatoes");
    assert_eq!(
        decode(b"l66ZC5pxvf2SD81M+FdRvUf1FrjhX0fyiQtU+2YD2OsFmro52J+JG6d84jTHdtLjwIN5vzTu6jTU8npfDdYFpqaVVSd9k3sxRhABuZkVLNI6mJjDFHD7YtqwjG44TGjPqnsTwdn+MkJTStBxEOsAByJcrWMb9mzLCOBNbpwNe31r7FG+ZeayiqV9cRS5SctDOALSeOeDSjuu4nsv4+ST6avqc4Llh3oFWeBS2d8oC+Z7ewcX70drqWo8C8gdB9zSqMH3OBbDs89xz0ppzTx1Vfa2UhDuGhL4WSqyuGa2JnQttBk5gj+ojoPA9bU5ArL+pMg7Tz+1nKOBfWMZJT/yfr7H4e41BnGkbY2OwzR5ZhwWBBkANL8uVG7lMk0BcOo2iIGt1x7rytyCzRDFSqJPpS8XjM+tXmpy77Cdm/ivb6Vz2+wuvYgAPUI/Zb24OUEiFs9gfe5dSJSXe680hOchC6BzrDJup5zWxaaqrPX6Z6ClYcynV+f1cwb9vwn3105FK5t6Gk6/AiBTKf1AbyDHh/VBwYwQ38GRUl74YM3x3nNVOI2QBbm4g1ygwHCYxMyEP/Cf818DNekLkhaXW3FoO5UzosIgzJXYRPhdVUv01/p4xKECO83EJOzioFttGbfXbzQoI5v+wBwB1HWJFDsNXTO+emP7ctT4ir4VJG83V86HuR3dNPlS0rpRMZl1qu8bIzqTA+be4Zw1kS/6v7ib3DUfn4Q/OxVYhikqg8/uS3Z37O0lZFMh0y1E4oSqxbZinH9aWPNNJtjwiHJVAtGD43ryDbC0vHFqYg9Daea9qMUMKiGfEQPWhxIxgFdHQpRVt1wmyUQpmaqYHQLwr+qnzlkYJlpC3RWoUbFMq4+5c5hOwe08SPjWvhFfyhga/jGgVj8rcmGolfB0PqLqJPmpmPZGYNTNz5CDatnJgCFDq+GPMmrUtNY6tVOXUqcWd/83E8IqPiVAGui8Gi9/rRU/wl8JhBbKiMfeBANoT6byCz+K1+5zm+ki1h1jjQssDMLeNvC1e2zWYQA=".to_string()),
        x"97ae990b9a71bdfd920fcd4cf85751bd47f516b8e15f47f2890b54fb6603d8eb059aba39d89f891ba77ce234c776d2e3c08379bf34eeea34d4f27a5f0dd605a6a69555277d937b31461001b999152cd23a9898c31470fb62dab08c6e384c68cfaa7b13c1d9fe3242534ad07110eb0007225cad631bf66ccb08e04d6e9c0d7b7d6bec51be65e6b28aa57d7114b949cb433802d278e7834a3baee27b2fe3e493e9abea7382e5877a0559e052d9df280be67b7b0717ef476ba96a3c0bc81d07dcd2a8c1f73816c3b3cf71cf4a69cd3c7555f6b65210ee1a12f8592ab2b866b626742db41939823fa88e83c0f5b53902b2fea4c83b4f3fb59ca3817d6319253ff27ebec7e1ee350671a46d8d8ec33479661c1604190034bf2e546ee5324d0170ea368881add71eebcadc82cd10c54aa24fa52f178ccfad5e6a72efb09d9bf8af6fa573dbec2ebd88003d423f65bdb839412216cf607dee5d4894977baf3484e7210ba073ac326ea79cd6c5a6aaacf5fa67a0a561cca757e7f57306fdbf09f7d74e452b9b7a1a4ebf02205329fd406f20c787f541c18c10dfc191525ef860cdf1de7355388d9005b9b8835ca0c07098c4cc843ff09ff35f0335e90b9216975b71683b9533a2c220cc95d844f85d554bf4d7fa78c4a1023bcdc424ece2a05b6d19b7d76f3428239bfec01c01d47589143b0d5d33be7a63fb72d4f88abe15246f3757ce87b91ddd34f952d2ba51319975aaef1b233a9303e6dee19c35912ffabfb89bdc351f9f843f3b155886292a83cfee4b7677eced25645321d32d44e284aac5b6629c7f5a58f34d26d8f088725502d183e37af20db0b4bc716a620f4369e6bda8c50c2a219f1103d6871231805747429455b75c26c9442999aa981d02f0afeaa7ce5918265a42dd15a851b14cab8fb973984ec1ed3c48f8d6be115fca181afe31a0563f2b7261a895f0743ea2ea24f9a998f64660d4cdcf90836ad9c9802143abe18f326ad4b4d63ab5539752a71677ff3713c22a3e25401ae8bc1a2f7fad153fc25f098416ca88c7de0403684fa6f20b3f8ad7ee739be922d61d638d0b2c0cc2de36f0b57b6cd66100",
    );
}

#[test, expected_failure(abort_code = EIncorrectNumberOfCharacters)]
fun test_decode_length_failure() {
    // count of characters is not multiple of 4
    decode(b"aGVsbG8".to_string());
}

#[test, expected_failure(abort_code = EIllegalCharacter)]
fun test_decode_character_failure() {
    // count of characters is not multiple of 4
    decode(b"aGVs\\G8=".to_string());
}
