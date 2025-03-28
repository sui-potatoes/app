// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module bit_field::bit_field_tests;

use bit_field::bit_field;

#[test_only]
use std::unit_test::assert_eq;

#[test]
fun test_u64_pack_u8() {
    let packed: u64 = bit_field::pack_u8!(vector<u8>[1, 2, 3, 4, 5, 6, 7, 8]);

    assert_eq!(bit_field::read_u8_at_offset!(packed, 0), 1);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 1), 2);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 2), 3);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 3), 4);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 4), 5);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 5), 6);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 6), 7);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 7), 8);
    assert_eq!(bit_field::unpack_u8!(packed, 8), vector[1, 2, 3, 4, 5, 6, 7, 8]);
}

#[test]
fun test_u64_pack_u16() {
    let packed_u16: u64 = bit_field::pack_u16!(vector[1000, 2000, 3000, 4000]);

    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 0), 1000);
    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 1), 2000);
    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 2), 3000);
    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 3), 4000);
    assert_eq!(bit_field::unpack_u16!(packed_u16, 4), vector[1000, 2000, 3000, 4000]);
}

#[test]
fun test_u64_pack_u32() {
    let packed_u32: u64 = bit_field::pack_u32!(vector[1000000, 2000000]);

    assert_eq!(bit_field::read_u32_at_offset!(packed_u32, 0), 1000000);
    assert_eq!(bit_field::read_u32_at_offset!(packed_u32, 1), 2000000);
    assert_eq!(bit_field::unpack_u32!(packed_u32, 2), vector[1000000, 2000000]);
}

#[test]
fun test_u64_pack_u64() {
    let packed_u64: u64 = bit_field::pack_u64!(vector[1000000000]);

    assert_eq!(bit_field::read_u64_at_offset!(packed_u64, 0), 1000000000);
    assert_eq!(bit_field::unpack_u64!(packed_u64, 1), vector[1000000000]);
}

#[test]
fun test_u32_pack_u8() {
    let packed: u32 = bit_field::pack_u8!(vector[1, 2, 3, 4]);

    assert_eq!(bit_field::read_u8_at_offset!(packed, 0), 1);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 1), 2);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 2), 3);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 3), 4);
    assert_eq!(bit_field::unpack_u8!(packed, 4), vector[1, 2, 3, 4]);
}

#[test]
fun test_u32_pack_u16() {
    let packed_u16: u32 = bit_field::pack_u16!(vector[1000, 2000]);

    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 0), 1000);
    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 1), 2000);
    assert_eq!(bit_field::unpack_u16!(packed_u16, 2), vector[1000, 2000]);
}

#[test]
fun test_u32_pack_u32() {
    let packed_u32: u32 = bit_field::pack_u32!(vector[1000000]);

    assert_eq!(bit_field::read_u32_at_offset!(packed_u32, 0), 1000000);
    assert_eq!(bit_field::unpack_u32!(packed_u32, 1), vector[1000000]);
}

#[test]
fun test_u16_pack_u8() {
    let packed: u16 = bit_field::pack_u8!(vector[1, 2]);

    assert_eq!(bit_field::read_u8_at_offset!(packed, 0), 1);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 1), 2);
    assert_eq!(bit_field::unpack_u8!(packed, 2), vector[1, 2]);
}

#[test]
fun test_u16_pack_u16() {
    let packed_u16: u16 = bit_field::pack_u16!(vector[1000]);

    assert_eq!(bit_field::read_u16_at_offset!(packed_u16, 0), 1000);
    assert_eq!(bit_field::unpack_u16!(packed_u16, 1), vector[1000]);
}

// === Bool ===

#[test]
fun test_u8_pack_bool() {
    let packed: u8 = bit_field::pack_bool!(
        vector[true, false, true, false, true, false, true, false],
    );

    assert_eq!(bit_field::read_bool_at_offset!(packed, 0), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 1), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 2), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 3), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 4), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 5), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 6), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 7), false);
    assert_eq!(
        bit_field::unpack_bool!(packed, 8),
        vector[true, false, true, false, true, false, true, false],
    );
}

#[test]
fun test_u16_pack_bool() {
    let packed: u16 = bit_field::pack_bool!(
        vector[true, false, true, false, true, false, true, false],
    );

    assert_eq!(bit_field::read_bool_at_offset!(packed, 0), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 1), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 2), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 3), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 4), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 5), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 6), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 7), false);
    assert_eq!(
        bit_field::unpack_bool!(packed, 8),
        vector[true, false, true, false, true, false, true, false],
    );
}

#[test]
fun test_u32_pack_bool() {
    let packed: u32 = bit_field::pack_bool!(
        vector[true, false, true, false, true, false, true, false],
    );

    assert_eq!(bit_field::read_bool_at_offset!(packed, 0), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 1), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 2), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 3), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 4), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 5), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 6), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 7), false);
    assert_eq!(
        bit_field::unpack_bool!(packed, 8),
        vector[true, false, true, false, true, false, true, false],
    );
}

#[test]
fun test_u64_pack_bool() {
    let packed: u64 = bit_field::pack_bool!(vector::tabulate!(64, |_| true));

    assert_eq!(bit_field::read_bool_at_offset!(packed, 0), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 1), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 2), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 3), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 4), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 5), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 6), true);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 7), true);
    assert_eq!(bit_field::unpack_bool!(packed, 64), vector::tabulate!(64, |_| true));
}

#[test]
fun test_u128_pack_bool() {
    let packed: u128 = bit_field::pack_bool!(vector::tabulate!(128, |_| false));

    assert_eq!(bit_field::read_bool_at_offset!(packed, 0), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 1), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 2), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 3), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 4), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 5), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 6), false);
    assert_eq!(bit_field::read_bool_at_offset!(packed, 7), false);
    assert_eq!(bit_field::unpack_bool!(packed, 128), vector::tabulate!(128, |_| false));
}
