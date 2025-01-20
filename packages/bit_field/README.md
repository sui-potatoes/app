# Bit Field

The Bit Field library provides a way of packing and unpacking homogeneous data types into a single
integer. For example, one could pack 8 booleans into a single `u8` or 32 booleans into a `u32`,
alternatively, one could pack 4 `u8` into a single `u32` or 2 `u32` into a `u64`.

## Implementation Details

The library does not contain a single public function, instead, it provides a set of macros that can
be used without creating an on-chain dependency. The macros provided allow packing any unsigned integer
in the range of 1 to 64 bits into another unsigned integer of the same and bigger size.

## Installation & Usage

Add this to your `Move.toml`:

```toml
[dependencies]
BitField = { git = "https://github.com/sui-potatoes/app.git", subdir = "packages/bit_field", rev = "main" }
```

## Structure

All of the functions follow the same naming pattern: `pack_<type>!` and `unpack_<type>!` do the
packing and unpacking respectively. The `<type>` is the type of the data that is being packed or
unpacked. The type can be one of the following: `u8`, `u16`, `u32`, `u64`, `bool`.

```move
use bit_field::bit_field;
use std::unit_test::assert_eq;

#[test]
fun test_pack_unpack() {
    // packs 4 u8's into a single u64
    let packed: u64 = bit_field::pack_u8!(vector[1, 2, 3, 4]);

    // packs 2 u8's into a single u16
    let packed: u32 = bit_field::pack_u8!(vector[100, 200]);
    let unpacked = bit_field::unpack_u8!(packed);

    assert_eq!(unpacked, vector[100, 200]);
}
```

Additionally, there is a read macro which allows reading a single value at the specified offset. The
example is shown below:

```move
use bit_field::bit_field;
use std::unit_test::assert_eq;

#[test]
fun test_pack_and_read() {
    // packs 4 u8's into a single u64
    let packed: u64 = bit_field::pack_u8!(vector[1, 2, 3, 4]);
    
    assert_eq!(bit_field::read_u8_at_offset!(packed, 0), 1);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 1), 2);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 2), 3);
    assert_eq!(bit_field::read_u8_at_offset!(packed, 3), 4);
    
    // similarly, one can read u16, u32 or u64
    let packed: u256 = bit_field::pack_u64!(vector[1000, 2000]);
    
    assert_eq!(bit_field::read_u64_at_offset!(packed, 0), 1000);
    assert_eq!(bit_field::read_u64_at_offset!(packed, 1), 2000);
}
```

## Contributing

For changes, please [open an issue](https://github.com/sui-potatoes/app/issues/new/choose) or submit a [pull request](https://github.com/sui-potatoes/app).

## License

MIT
