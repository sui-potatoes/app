// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module identify::identify;

use std::type_name;
use sui::dynamic_field as df;

/// Check if the type `T` is a `u8` type.
public fun is_u8<T>(): bool { type_bytes!<T>() == b"u8" }

/// Check if the type `T` is a `u16` type.
public fun is_u16<T>(): bool { type_bytes!<T>() == b"u16" }

/// Check if the type `T` is a `u32` type.
public fun is_u32<T>(): bool { type_bytes!<T>() == b"u32" }

/// Check if the type `T` is a `u64` type.
public fun is_u64<T>(): bool { type_bytes!<T>() == b"u64" }

/// Check if the type `T` is a `u128` type.
public fun is_u128<T>(): bool { type_bytes!<T>() == b"u128" }

/// Check if the type `T` is a `u256` type.
public fun is_u256<T>(): bool { type_bytes!<T>() == b"u256" }

/// Check if the type `T` is a `address` type.
public fun is_address<T>(): bool { type_bytes!<T>() == b"address" }

/// Check if the type `T` is a `bool` type.
public fun is_bool<T>(): bool { type_bytes!<T>() == b"bool" }

/// Check if the type `T` is a `vector` type.
public fun is_vector<T>(): bool {
    let tb = type_bytes!<T>();
    tb.length() > 5 && vector[tb[0], tb[1], tb[2], tb[3], tb[4], tb[5]] == b"vector"
}

/// Compare type names of `T` and `E`.
public fun is_type<T, E>(): bool {
    type_name::with_original_ids<T>() == type_name::with_original_ids<E>()
}

// === Built-in types ===

/// Identify generic input `v` as the `u8` type.
public fun as_u8<T: store>(v: T, ctx: &mut TxContext): u8 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `u16` type.
public fun as_u16<T: store>(v: T, ctx: &mut TxContext): u16 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `u32` type.
public fun as_u32<T: store>(v: T, ctx: &mut TxContext): u32 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `u64` type.
public fun as_u64<T: store>(v: T, ctx: &mut TxContext): u64 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `u128` type.
public fun as_u128<T: store>(v: T, ctx: &mut TxContext): u128 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `u256` type.
public fun as_u256<T: store>(v: T, ctx: &mut TxContext): u256 { as_internal!(v, ctx) }

/// Identify generic input `v` as the `address` type.
public fun as_address<T: store>(v: T, ctx: &mut TxContext): address { as_internal!(v, ctx) }

/// Identify generic input `v` as the `bool` type.
public fun as_bool<T: store>(v: T, ctx: &mut TxContext): bool { as_internal!(v, ctx) }

/// Identify generic input `v` as the `vector` type.
public fun as_vector<T: store, V: store>(v: T, ctx: &mut TxContext): vector<V> {
    as_internal!(v, ctx)
}

/// Identify generic input `v` as the `R` type.
public fun as_type<T: store, R: store>(v: T, ctx: &mut TxContext): R { as_internal!(v, ctx) }

// === Integer Upscaling ===

/// Convert any uint `T` to the largest integer type `u256`.
public fun to_u256<T: copy + drop + store>(v: T, ctx: &mut TxContext): u256 {
    let type_bytes = type_bytes!<T>();
    if (type_bytes == b"u8") as_u8(v, ctx) as u256
    else if (type_bytes == b"u16") as_u16(v, ctx) as u256
    else if (type_bytes == b"u32") as_u32(v, ctx) as u256
    else if (type_bytes == b"u64") as_u64(v, ctx) as u256
    else if (type_bytes == b"u128") as_u128(v, ctx) as u256
    else if (type_bytes == b"u256") as_u256(v, ctx)
    else abort
}

// === Helper ===

/// Identify the input `$V` as the `$R` type.
public macro fun as_internal<$V: store, $R>($v: $V, $ctx: &mut TxContext): $R {
    let mut id = object::new($ctx);
    df::add(&mut id, true, $v);
    let value: $R = df::remove(&mut id, true);
    id.delete();
    value
}

/// Internal utility to get the bytes of the `TypeName` for `$T`.
macro fun type_bytes<$T>(): vector<u8> {
    type_name::with_original_ids<$T>().into_string().into_bytes()
}
