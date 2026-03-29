module 0x0::test_mvr;

use sui::clock::Clock;
use ascii::char;
use codec::urlencode;
use bit_field::bit_field;
use date::date;

/// This function uses all the packages in the test_mvr module.
public fun use_them_all(c: &Clock): u256 {
    let mut str = b"".to_string();
    str.push_back(char::A!());
    str.append(date::from_clock(c).to_iso_string());
    let encoded = urlencode::encode(str.into_bytes()).into_bytes();
    bit_field::pack_u8!(encoded)
}

#[test]
fun test_use_them_all() {
    let ctx = &mut tx_context::dummy();
    let clock = sui::clock::create_for_testing(ctx);
    let value = use_them_all(&clock);

    std::debug::print(&value);
}
