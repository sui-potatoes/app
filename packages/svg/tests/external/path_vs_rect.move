// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::path_vs_rect_tests;

use svg::path_builder as path;

/// Size of a single px.
const PX: u16 = 20;

#[test]
// 0 1 2 3 4 5 6 7 8 9
// _ _ _ _ _ _ _ _ _ _ 0
// _ X X X X X _ _ _ _ 1
// _ X _ _ _ x x x _ _ 2
// _ X _ _ _ x x _ _ _ 3
// _ _ _ _ _ _ _ _ _ _ 4
// _ _ _ _ _ _ _ _ _ _ 5
// _ _ _ _ _ _ _ _ _ _ 6
// _ _ _ _ _ _ _ _ _ _ 7
// _ _ _ _ _ _ _ _ _ _ 8
// _ _ _ _ _ _ _ _ _ _ 9
// _ _ _ _ _ _ _ _ _ _ 10
// _ _ _ _ _ _ _ _ _ _ 11
// _ _ _ _ _ _ _ _ _ _ 12
// _ _ _ _ _ _ _ _ _ _ 13
fun test_path_vs_rect() {
    // M20,60V0H100V50H120V20H170
    // M20,70V30H110V70H240V20H160

    let offset = PX / 2;
    let path = path::new()
        .move_to(1 * PX + offset, 4 * PX + offset)
        .vertical_line_to(1 * PX + offset)
        .horizontal_line_to(5 * PX + offset)
        .vertical_line_to(3 * PX + offset)
        .horizontal_line_to(12 * PX)
        .vertical_line_to(1 * PX)
        .horizontal_line_to(8 * PX)
        // .horizontal_line_to(5 * PX)
        // .vertical_line_to(3 * PX)
        // .horizontal_line_to(6 * PX)
        // .vertical_line_to(2 * PX)
        // .horizontal_line_to(5 * PX)
        .to_string();

    std::debug::print(&path);

    let mut svg = svg::svg::svg(vector[0, 0, 10 * PX, 14 * PX]);
    svg.add_root(vector[svg::shape::path(path, option::none())]);
    svg.debug();
}
