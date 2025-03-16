// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::history_tests;

use commander::history;
use std::unit_test::assert_eq;

#[test]
fun test_all_records() {
    let mut history = history::empty();

    history.add_record(history::new_attack(vector[0, 0], vector[0, 0]));
    history.add_record(history::new_move(vector[]));
    history.add_record(history::new_next_turn());
    history.add_record(history::new_reload(0, 0));

    assert_eq!(history.length(), 4);

    // add 8 more records
    80u8.do!(|_| history.add_record(history::new_next_turn()));

    assert_eq!(history.length(), 20);
}
