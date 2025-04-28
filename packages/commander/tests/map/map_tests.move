// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::map_tests;

use commander::{map, recruit};
use grid::{direction, point};
use std::{bcs, unit_test::{assert_eq, assert_ref_eq}};

#[test]
// To better understand the test, please refer to the `demo_1` function and see
// the each map tile in the schema.
fun demo_maps() {
    use grid::direction::{up, down, left, right};

    let demo_1 = map::demo_1(@1.to_id());
    assert!(demo_1.check_path(vector[1, 6, down!(), down!(), left!()]).is_some());
    assert!(demo_1.check_path(vector[0, 0, right!(), right!()]).is_none()); // hop over low cover
    assert!(demo_1.check_path(vector[6, 5, up!()]).is_some()); // also low cover
    assert!(demo_1.check_path(vector[0, 0, down!()]).is_none()); // un-walkable tile
    assert!(demo_1.check_path(vector[0, 3, left!(), down!()]).is_none()); // high cover
    demo_1.destroy();
}

#[test]
fun next_turn() {
    let ctx = &mut tx_context::dummy();
    let mut map = map::demo_1(@1.to_id());
    let recruit = recruit::default(ctx);

    assert_eq!(map.turn(), 0);
    map.place_recruit(&recruit, point::new(0, 0), 0);
    map.move_unit(vector[0, 0, direction::right!()]); // spend 1 AP point
    assert!(map.unit(0, 1).is_some_and!(|unit| unit.ap() == 1));

    map.next_turn();
    map.move_unit(vector[0, 1, direction::left!()]); // spend 1 AP point
    assert!(map.unit(0, 0).is_some_and!(|unit| unit.ap() == 1));
    assert_eq!(map.turn(), 1);

    map.next_turn();
    assert_eq!(map.turn(), 2);

    let (w, a) = recruit.dismiss();
    w.destroy_none();
    a.destroy_none();
    map.destroy();
}

#[test]
fun from_bcs() {
    let map = map::demo_1(@1.to_id());
    let bytes = bcs::to_bytes(&map);
    let map_copy = map::from_bytes(bytes);

    assert_ref_eq!(&map, &map_copy);
    map_copy.destroy();
    map.destroy();
}
