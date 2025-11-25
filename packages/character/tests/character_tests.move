// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module character::character_tests;

use character::character;
use std::unit_test::{assert_eq,destroy};

/// The key to use in application tests.
public struct ApplicationKey(u8) has copy, drop, store;

#[test]
fun test_new_edit_flow() {
    let ctx = &mut tx_context::dummy();
    let mut builder = character::new_builder_for_testing(ctx);
    let mut character = builder.new(
        b"blazer".to_string(),
        b"wind".to_string(),
        b"3e8948".to_string(),
        b"2ce8f5".to_string(),
        b"181425".to_string(),
        b"ff0044".to_string(),
        b"0099db".to_string(),
        b"ead4aa".to_string(),
        ctx,
    );

    assert_eq!(character.body_type(), b"blazer".to_string());
    assert_eq!(character.hair_type(), b"wind".to_string());
    assert_eq!(character.eyes_color(), b"3e8948".to_string());
    assert_eq!(character.hair_color(), b"2ce8f5".to_string());
    assert_eq!(character.trousers_color(), b"181425".to_string());
    assert_eq!(character.skin_color(), b"ff0044".to_string());
    assert_eq!(character.base_color(), b"0099db".to_string());
    assert_eq!(character.accent_color(), b"ead4aa".to_string());

    builder.update_image(
        &mut character,
        option::some(b"office".to_string()),
        option::some(b"punk".to_string()),
        option::some(b"ead4aa".to_string()),
        option::some(b"0099db".to_string()),
        option::some(b"ff0044".to_string()),
        option::some(b"181425".to_string()),
        option::some(b"2ce8f5".to_string()),
        option::some(b"3e8948".to_string()),
        ctx,
    );

    assert_eq!(character.body_type(), b"office".to_string());
    assert_eq!(character.hair_type(), b"punk".to_string());
    assert_eq!(character.eyes_color(), b"ead4aa".to_string());
    assert_eq!(character.hair_color(), b"0099db".to_string());
    assert_eq!(character.trousers_color(), b"ff0044".to_string());
    assert_eq!(character.skin_color(), b"181425".to_string());
    assert_eq!(character.base_color(), b"2ce8f5".to_string());
    assert_eq!(character.accent_color(), b"3e8948".to_string());

    builder.update_image(
        &mut character,
        option::none(),
        option::none(),
        option::none(),
        option::none(),
        option::none(),
        option::none(),
        option::none(),
        option::none(),
        ctx,
    );

    assert_eq!(character.body_type(), b"office".to_string());
    assert_eq!(character.hair_type(), b"punk".to_string());
    assert_eq!(character.eyes_color(), b"ead4aa".to_string());
    assert_eq!(character.hair_color(), b"0099db".to_string());
    assert_eq!(character.trousers_color(), b"ff0044".to_string());
    assert_eq!(character.skin_color(), b"181425".to_string());
    assert_eq!(character.base_color(), b"2ce8f5".to_string());
    assert_eq!(character.accent_color(), b"3e8948".to_string());

    destroy(character);
    destroy(builder);
}

#[test]
fun test_application_storage() {
    let ctx = &mut tx_context::dummy();
    let mut builder = character::new_builder_for_testing(ctx);
    let mut character = builder.new(
        b"blazer".to_string(),
        b"wind".to_string(),
        b"3e8948".to_string(),
        b"2ce8f5".to_string(),
        b"181425".to_string(),
        b"ff0044".to_string(),
        b"0099db".to_string(),
        b"ead4aa".to_string(),
        ctx,
    );

    // add a new storage
    character.add(ApplicationKey(0), vector[100u64]);
    character.add(ApplicationKey(1), vector[200u64]);

    let app1_data = character[ApplicationKey(0)];
    let app2_data = &mut character[ApplicationKey(1)];

    assert_eq!(app1_data, vector[100u64]);
    assert_eq!(*app2_data, vector[200u64]);
    *app2_data = vector[100, 200];

    let app1_data = character.remove(ApplicationKey(0));
    let app2_data = character.remove(ApplicationKey(1));

    assert_eq!(app1_data, vector[100]);
    assert_eq!(app2_data, vector[100, 200]);

    destroy(character);
    destroy(builder);
}
