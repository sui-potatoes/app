module identify::identify_tests;

use identify::identify;

#[test]
fun is_as_u8() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u8<u8>());
    assert!(!identify::is_u8<u16>());
    assert!(identify::as_u8<u8>(10u8, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u8_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u8(10u64, ctx);
}

#[test]
fun is_as_u16() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u16<u16>());
    assert!(!identify::is_u16<u32>());
    assert!(identify::as_u16<u16>(10u16, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u16_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u16(10u64, ctx);
}

#[test]
fun is_as_u32() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u32<u32>());
    assert!(!identify::is_u32<u64>());
    assert!(identify::as_u32<u32>(10u32, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u32_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u32(10u64, ctx);
}

#[test]
fun is_as_u64() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u64<u64>());
    assert!(!identify::is_u64<u128>());
    assert!(identify::as_u64<u64>(10u64, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u64_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u64(10u32, ctx);
}

#[test]
fun is_as_u128() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u128<u128>());
    assert!(!identify::is_u128<u64>());
    assert!(identify::as_u128<u128>(10u128, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u128_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u128(10u64, ctx);
}

#[test]
fun is_as_u256() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_u256<u256>());
    assert!(!identify::is_u256<u64>());
    assert!(identify::as_u256<u256>(10u256, ctx) == 10);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_u256_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_u256(10u64, ctx);
}

#[test]
fun is_as_address() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_address<address>());
    assert!(!identify::is_address<u64>());
    assert!(identify::as_address<address>(@0, ctx) == @0);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_address_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_address(10u64, ctx);
}

#[test]
fun is_as_bool() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_bool<bool>());
    assert!(!identify::is_bool<u64>());
    assert!(identify::as_bool<bool>(false, ctx) == false);
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_bool_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_bool(10u64, ctx);
}

#[test]
fun is_as_vector() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_vector<vector<u8>>());
    assert!(!identify::is_vector<u64>());
    assert!(!identify::is_vector<std::type_name::TypeName>());
    assert!(identify::as_vector<_, u8>(b"vec", ctx) == b"vec");
}

#[test, expected_failure(location = sui::dynamic_field, abort_code = 2)]
fun as_vector_fail() {
    let ctx = &mut tx_context::dummy();
    identify::as_vector<_, u8>(10u64, ctx);
}

#[test]
fun is_as_type() {
    let ctx = &mut tx_context::dummy();
    assert!(identify::is_type<u8, u8>());
    assert!(!identify::is_type<u8, u16>());
    assert!(identify::as_type<u8, u8>(10u8, ctx) == 10);
}
