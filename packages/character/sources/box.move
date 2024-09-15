// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// A dynamic field storage which can store a single value or a single type.
module character::box;

use sui::dynamic_field as df;

/// A box that stores a single value or a single type.
public struct Box<phantom T> has key, store { id: UID }

public struct Key() has copy, store, drop;

/// Create a new box with the given value.
public fun create<T: store>(value: T, ctx: &mut TxContext): Box<T> {
    let mut id = object::new(ctx);
    df::add(&mut id, Key(), value);
    Box { id }
}

/// Get the value stored in the box.
public fun inner<T: store>(box: &Box<T>): &T { df::borrow(&box.id, Key()) }

/// Get a mutable reference to the value stored in the box.
public fun inner_mut<T: store>(box: &mut Box<T>): &mut T { df::borrow_mut(&mut box.id, Key()) }

/// Destroy the box and return the value stored in it.
public fun destroy<T: store>(mut box: Box<T>): T {
    let value = df::remove(&mut box.id, Key());
    let Box { id } = box;
    id.delete();
    value
}
