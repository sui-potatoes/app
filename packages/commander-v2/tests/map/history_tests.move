// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::history_tests;

use commander::history;
use std::unit_test::assert_eq;

#[test]
fun test_all_records() {
    let mut history = history::empty();

    history.add(history::new_attack(vector[0, 0], vector[0, 0]));
    history.add(history::new_move(vector[]));
    history.add(history::new_next_turn());
    history.add(history::new_reload(0, 0));

    assert_eq!(history.length(), 4);
}
