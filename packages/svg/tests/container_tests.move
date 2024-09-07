// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module svg::container_tests;

use std::unit_test;
use svg::{container, desc};

#[test]
fun test_container() {
    let desc = container::desc(vector[
        desc::title(b"Title".to_string()),
        desc::desc(b"Description".to_string()),
        desc::metadata(b"".to_string()),
    ]);

    unit_test::assert_eq!(
        desc.to_string(),
        b"<title>Title</title><desc>Description</desc><metadata></metadata>".to_string(),
    );
}
