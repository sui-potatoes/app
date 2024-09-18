// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::action_tests;

use commander::action;
use std::unit_test::assert_eq;
use sui::bcs;

#[test]
fun action_creation() {
    let skip = action::new_skip(b"Skip".to_string(), 10);

    assert_eq!(skip.name(), b"Skip".to_string());
    assert_eq!(skip.cost(), 10);
    assert!(skip.is_skip());
    assert_eq!(skip.is_move(), false);
    assert_eq!(skip.is_attack(), false);

    let mv = action::new_move(b"Move".to_string(), 5);

    assert_eq!(mv.name(), b"Move".to_string());
    assert_eq!(mv.cost(), 5);
    assert_eq!(mv.is_skip(), false);
    assert!(mv.is_move());
    assert_eq!(mv.is_attack(), false);

    let attack = action::new_attack(b"Attack".to_string(), 10, 5, 100);

    assert_eq!(attack.name(), b"Attack".to_string());
    assert_eq!(attack.cost(), 10);
    assert_eq!(attack.is_skip(), false);
    assert_eq!(attack.is_move(), false);
    assert!(attack.is_attack());

    let (max_range, damage) = attack.attack_params();

    assert_eq!(max_range, 5);
    assert_eq!(damage, 100);
}

#[test]
fun action_bcs() {
    let skip = action::new_skip(b"Skip".to_string(), 10);
    let bytes = bcs::to_bytes(&skip);
    assert_eq!(skip, action::from_bytes(bytes));

    let mv = action::new_move(b"Move".to_string(), 5);
    let bytes = bcs::to_bytes(&mv);
    assert_eq!(mv, action::from_bytes(bytes));

    let attack = action::new_attack(b"Attack".to_string(), 10, 5, 100);
    let bytes = bcs::to_bytes(&attack);
    assert_eq!(attack, action::from_bytes(bytes));
}

#[test, expected_failure(abort_code = action::EUnknownEnumVariant)]
fun unknown_enum_variant() {
    let skip = action::new_skip(b"Skip".to_string(), 10);
    let mut bytes = bcs::to_bytes(&skip);

    bytes.pop_back();
    bytes.push_back(3);

    action::from_bytes(bytes);
}

#[test, expected_failure(abort_code = action::ENotAttackAction)]
fun not_an_attack() {
    let mv = action::new_move(b"Move".to_string(), 5);
    mv.attack_params();
}
