// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::map_tests;

use commander::map;
use std::{bcs, unit_test::assert_ref_eq};

#[test]
// To better understand the test, please refer to the `demo_1` function and see
// the each map tile in the schema.
fun demo_maps() {
    let demo_1 = map::demo_1(@1.to_id());
    assert!(demo_1.check_path(vector[vector[1, 6], vector[2, 6], vector[3, 6], vector[3, 5]]));
    assert!(
        !demo_1.check_path(vector[
            /* start */ vector[0, 0],
            /* right */ vector[0, 1],
            /* right */ vector[0, 2],
        ]),
    ); // hop over low cover
    assert!(demo_1.check_path(vector[vector[6, 5], /* up */ vector[5, 5]])); // also low cover
    assert!(!demo_1.check_path(vector[vector[0, 0], vector[1, 0]])); // un-walkable tile
    assert!(
        !demo_1.check_path(vector[
            /* start */ vector[0, 3],
            /* left */ vector[0, 2],
            /* bottom */ vector[1, 2],
        ]),
    ); // high cover
    demo_1.destroy();
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
