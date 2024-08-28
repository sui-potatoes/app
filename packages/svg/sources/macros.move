// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: macros
/// All of the shapes and containers in the SVG module have a shared set of methods,
/// for example, `to_string` and `attributes_mut`. This module defines a set of macros
/// which can be used to generate calls to these methods.
module svg::macros;

/// Adds an attribute to the shape or updates it if it already exists.
public macro fun add_attribute<$T>($el: &mut $T, $key: vector<u8>, $value: vector<u8>) {
    let el = $el;
    let key = $key;
    let value = $value;
    el.attributes_mut().insert(key.to_string(), value.to_string());
}

/// Adds a "class" attribute to the shape or updates it if it already exists.
///
/// Can be called on:
/// - `svg::svg::SVG`
/// - `svg::shape::Shape`
/// - `svg::container::Container`
public macro fun add_class<$T>($el: &mut $T, $class: vector<u8>) {
    let el = $el;
    let value = $class;
    let key = b"class".to_string();
    let attributes = el.attributes_mut();
    let mut class_list = if (attributes.contains(&key)) {
        let (_, mut list) = attributes.remove(&key);
        list.append(b" ".to_string());
        list
    } else {
        b"".to_string()
    };

    class_list.append(value.to_string());
    attributes.insert(key, class_list);
}
