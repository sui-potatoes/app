// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module bit_field::bit_field;

// === Pack ===

public(package) macro fun pack<$X,$Y>($values: vector<$X>): $Y {
    let mut values = $values; 

    // return the bit size of type $X
    let x_type = std::type_name::get<$X>().into_string();
    
    // size of type X
    let x_size = if (x_type.as_bytes() == b"u8") {
        8
    }  else if (x_type.as_bytes() == b"u16") {
        16
    } else if (x_type.as_bytes() == b"u32") {
        32
    } else { // u64
        64
    };

    let mut v: $Y = 0;
    let (mut i, len) = (0, values.length() as u8);
    values.reverse();

    while (i < len) {
        v = v | (values.pop_back() as $Y) << (x_size * i);
        i = i + 1;
    };
    v
} 

/// Pack a vector of `bool` into an unsigned integer.
/// Unlike other pack functions, this one shifts bit by bit.
public macro fun pack_bool<$T>($values: vector<bool>): $T {
    let mut values = $values;
    let mut v: $T = 0;
    let (mut i, len) = (0, values.length() as u8);
    values.reverse();

    while (i < len) {
        v = v | (if (values.pop_back()) 1 else 0 as $T) << i;
        i = i + 1;
    };
    v
}

/// Pack a vector of `u8` into an unsigned integer.
public macro fun pack_u8<$T>($values: vector<u8>): $T {
    pack!<u8, $T>($values)
}

/// Pack a vector of `u16` into an unsigned integer.
public macro fun pack_u16<$T>($values: vector<u16>): $T {
    pack!<u16, $T>($values)
}

/// Pack a vector of `u32` into an unsigned integer.
public macro fun pack_u32<$T>($values: vector<u32>): $T {
    pack!<u32, $T>($values)
}

/// Pack a vector of `u64` into an unsigned integer.
public macro fun pack_u64<$T>($values: vector<u64>): $T {
    pack!<u64, $T>($values)
}

// === Unpack ===

/// Unpack a vector of `bool` from an unsigned integer.
public macro fun unpack_bool<$T>($v: $T, $size: u8): vector<bool> {
    vector::tabulate!($size as u64, |i| (($v >> (i as u8)) & 1) == 1)
}

/// Unpack a vector of `u8` from an unsigned integer.
public macro fun unpack_u8<$T>($v: $T, $size: u8): vector<u8> {
    vector::tabulate!($size as u64, |i| ($v >> 8 * (i as u8) & 0xFF) as u8)
}

/// Unpack a vector of `u16` from an unsigned integer.
public macro fun unpack_u16<$T>($v: $T, $size: u8): vector<u16> {
    vector::tabulate!($size as u64, |i| ($v >> 16 * (i as u8) & 0xFFFF) as u16)
}

/// Unpack a vector of `u32` from an unsigned integer.
public macro fun unpack_u32<$T>($v: $T, $size: u8): vector<u32> {
    vector::tabulate!($size as u64, |i| ($v >> 32 * (i as u8) & 0xFFFFFFFF) as u32)
}

/// Unpack a vector of `u64` from an unsigned integer.
public macro fun unpack_u64<$T>($v: $T, $size: u8): vector<u64> {
    vector::tabulate!($size as u64, |i| ($v >> 64 * (i as u8) & 0xFFFFFFFFFFFFFFFF) as u64)
}

// === Reads ===

/// Read a `bool` value at a specific offset.
public macro fun read_bool_at_offset<$T>($v: $T, $offset: u8): bool {
    (($v >> $offset) & 1) == 1
}

/// Read a `u8` value at a specific offset.
public macro fun read_u8_at_offset<$T>($v: $T, $offset: u8): u8 {
    ($v >> 8 * $offset & 0xFF) as u8
}

/// Read a `u16` value at a specific offset.
public macro fun read_u16_at_offset<$T>($v: $T, $offset: u8): u16 {
    ($v >> 16 * $offset & 0xFFFF) as u16
}

/// Read a `u32` value at a specific offset.
public macro fun read_u32_at_offset<$T>($v: $T, $offset: u8): u32 {
    ($v >> 32 * $offset & 0xFFFFFFFF) as u32
}

/// Read a `u64` value at a specific offset.
public macro fun read_u64_at_offset<$T>($v: $T, $offset: u8): u64 {
    ($v >> 64 * $offset & 0xFFFFFFFFFFFFFFFF) as u64
}

// === Writes ===

// currently not implemented
