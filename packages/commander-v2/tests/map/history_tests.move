// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::history_tests;

use commander::history;
use std::unit_test::{assert_ref_eq, assert_eq};
use sui::bcs;

#[test]
fun test_all_records() {
    let mut history = history::empty();

    history.add(history::new_recruit_placed(0, 0));
    history.add(history::new_attack(vector[0, 0], vector[0, 0]));
    history.add(history::new_dodged());
    history.add(history::new_miss());
    history.add(history::new_critical_hit(0));
    history.add(history::new_damage(10));
    history.add(history::new_kia(@0.to_id()));
    history.add(history::new_grenade(2, 0, 0));
    history.add(history::new_move(vector[vector[0, 0], vector[1, 1]]));
    history.add(history::new_next_turn());
    history.add(history::new_reload(0, 0));

    assert_eq!(history::list_kia(history.inner()), vector[@0.to_id()]);
    assert_eq!(history.length(), 11);

    let bytes = bcs::to_bytes(&history);
    let mut bcs = bcs::new(bytes);
    let history_restored = history::from_bytes(bytes);
    let history_restored_2 = history::from_bcs(&mut bcs);

    assert_ref_eq!(&history, &history_restored);
    assert_ref_eq!(&history, &history_restored_2);
}
