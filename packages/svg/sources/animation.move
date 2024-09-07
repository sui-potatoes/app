// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements SVG animations. Animations can be applied to SVG elements to create
/// interactive and dynamic content.
///
/// Animation can be added to any `Shape` element by calling `add_animation` on the
/// element. The `add_animation` method takes an `Animation` struct as an argument.
///
/// ```move
/// let animation = animation::animate_transform(b"rotate", b"0 5 5", b"360 5 5")
///     .attribute_name(b"transform")
///     .duration(b"10s")
///     .repeat_count(b"indefinite");
///
/// let mut rect = shape::rect(10, 10);
/// rect.add_animation(animation);
/// let mut svg = svg::svg(vector[0, 0, 120, 120]);
/// svg.root(vector[rect]);
/// ```
///
/// The `Animation` struct has several builder methods to set the properties of the
/// animation. The `to_string` method can be called on the `Animation` struct to
/// convert it to a string.
///
/// ```move
/// let animation = animation::animate()
///    .attribute_name(b"rx")
///    .values(b"0;5;0")
///    .duration(b"10s")
///    .repeat_count(b"indefinite");
///
/// ```
module svg::animation;

use std::string::String;
use sui::vec_map::{Self, VecMap};
use svg::print;

/// MPath animation, defines a path for an element to follow. Used in the
/// `animateMotion` element, and references a `path` element by id.
/// - `href` - the id of the path element to follow.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/mpath
public struct MPath(String) has copy, store, drop;

/// Animation struct, represents an animation that can be applied to SVG elements.
public struct Animation has copy, store, drop {
    /// The type of animation element.
    animation: AnimationType,
    /// The name of the attribute to animate. Translates to the `attributeName`
    /// property in the SVG element.
    attribute_name: Option<String>,
    /// The path to animate along. Translates to the `path` property in the SVG element.
    /// Used in the `animateMotion` element.
    values: Option<String>,
    /// Duration of the animation. Translates to the `dur` property in the SVG element.
    duration: Option<String>,
    /// Number of times to repeat the animation. Translates to the `repeatCount`
    /// property in the SVG element.
    repeat_count: Option<String>,
    /// A list of other attributes to add to the animation element.
    attributes: VecMap<String, String>,
}

/// Animation enum, represents different types of animations that can be
/// applied to SVG elements.
///
/// - `Animate` - animate animation, animates an attribute from one value to another.
/// - `AnimateMotion` - animate motion animation, animates an element along a path.
/// - `AnimateTransform` - animate transform animation, animates a transformation.
/// - `Set` - set animation, sets the value of an attribute at a specific time.
public enum AnimationType has copy, store, drop {
    /// Animate animation, animates an attribute from one value to another.
    /// - `attribute` - the name of the attribute to animate.
    /// - `values` - a list of values to animate between.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    ///
    /// Animate is placed inside an element to animate the element.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animate
    Animate,
    /// Animate motion animation, animates an element along a path.
    ///
    /// Own properties:
    /// - `path` - the path to animate along.
    /// - `mpath` - the path element to follow.
    ///
    /// Inherited:
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    ///
    /// Extended:
    /// - `begin` - the time to start the animation.
    /// - `end` - the time to end the animation.
    /// - `rotate` - the rotation of the element.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateMotion
    AnimateMotion(Option<String>, Option<MPath>),
    /// Animate transform animation, animates a transformation.
    ///
    /// Own properties:
    /// - `type` - the type of transformation to animate.
    /// - `from` - the starting value of the transformation.
    /// - `to` - the ending value of the transformation.
    ///
    /// Inherited:
    /// - `attribute` - the name of the attribute to animate.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    /// - `values` - the values to animate between.
    ///
    /// Extended:
    /// - `by` - the amount to change the transformation by.
    /// - `begin` - the time to start the animation.
    /// - `end` - the time to end the animation.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateTransform
    AnimateTransform(String, String, String),
    /// Set animation, sets the value of an attribute at a specific time.
    ///
    /// Own properties:
    /// - `to` - the value to set the attribute to.
    ///
    /// Inherited:
    /// - `attribute` - the name of the attribute to set.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    ///
    /// Extended:
    /// - `begin` - the time to start the animation.
    /// - `end` - the time to end the animation.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/set
    Set(String),
}

/// Create a new `<animate>` element.
public fun animate(): Animation {
    Animation {
        animation: AnimationType::Animate,
        attribute_name: option::none(),
        values: option::none(),
        duration: option::none(),
        repeat_count: option::none(),
        attributes: vec_map::empty(),
    }
}

/// Create a new `<animateMotion>` element.
public fun animate_motion(path: Option<vector<u8>>, mpath: Option<MPath>): Animation {
    Animation {
        animation: AnimationType::AnimateMotion(path.map!(|p| p.to_string()), mpath),
        attribute_name: option::none(),
        values: option::none(),
        duration: option::none(),
        repeat_count: option::none(),
        attributes: vec_map::empty(),
    }
}

/// Create a new `<animateTransform>` element.
public fun animate_transform(
    transform_type: vector<u8>,
    from: vector<u8>,
    to: vector<u8>,
): Animation {
    Animation {
        animation: AnimationType::AnimateTransform(
            transform_type.to_string(),
            from.to_string(),
            to.to_string(),
        ),
        attribute_name: option::none(),
        values: option::none(),
        duration: option::none(),
        repeat_count: option::none(),
        attributes: vec_map::empty(),
    }
}

/// Create a new `<set>` element.
public fun set(to: vector<u8>): Animation {
    Animation {
        animation: AnimationType::Set(to.to_string()),
        attribute_name: option::none(),
        values: option::none(),
        duration: option::none(),
        repeat_count: option::none(),
        attributes: vec_map::empty(),
    }
}

/// Create a new `<mpath>` element. Special element used in the `animateMotion` element
/// to reference a `path` element by id. Passed as an argument to the `animateMotion`.
public fun mpath(href: vector<u8>): MPath { MPath(href.to_string()) }

// === Builder methods ===

/// Set the name of the attribute to animate.
public fun attribute_name(mut self: Animation, name: vector<u8>): Animation {
    self.attribute_name.fill(name.to_string());
    self
}

/// Set the values to animate between.
public fun values(mut self: Animation, values: vector<u8>): Animation {
    self.values.fill(values.to_string());
    self
}

/// Set the duration of the animation.
public fun duration(mut self: Animation, duration: vector<u8>): Animation {
    self.duration.fill(duration.to_string());
    self
}

/// Set the number of times to repeat the animation.
public fun repeat_count(mut self: Animation, count: vector<u8>): Animation {
    self.repeat_count.fill(count.to_string());
    self
}

/// Get mutable access to the attributes of the animation.
public fun attributes_mut(self: &mut Animation): &mut VecMap<String, String> {
    &mut self.attributes
}

/// Map over the attributes of the animation.
public macro fun map_attributes($self: Animation, $f: |&mut VecMap<String, String>|): Animation {
    let mut self = $self;
    let attributes = self.attributes_mut();
    $f(attributes);
    self
}

/// Convert the animation to a string.
public fun to_string(self: &Animation): String {
    let Animation { animation, attribute_name, values, duration, repeat_count, attributes } = self;
    let mut attrs = *attributes;

    attribute_name.do_ref!(|attr| attrs.insert(b"attributeName".to_string(), *attr));
    values.do_ref!(|val| attrs.insert(b"values".to_string(), *val));
    duration.do_ref!(|dur| attrs.insert(b"dur".to_string(), *dur));
    repeat_count.do_ref!(|count| attrs.insert(b"repeatCount".to_string(), *count));

    // modify the internal attribute if needed and return the name
    let (name, content) = match (animation) {
        AnimationType::Animate => (b"animate".to_string(), option::none()),
        AnimationType::AnimateMotion(path, mpath) => {
            let mut contents = option::none();

            path.do_ref!(|p| attrs.insert(b"path".to_string(), *p));
            mpath.do_ref!(|mpath| contents.fill({
                let mut attrs = vec_map::empty();
                attrs.insert(b"href".to_string(), mpath.0);
                vector[print::print(b"mpath".to_string(), attrs, option::none())]
            }));

            (b"animateMotion".to_string(), contents)
        },
        AnimationType::AnimateTransform(transform_type, from, to) => {
            attrs.insert(b"type".to_string(), *transform_type);
            attrs.insert(b"from".to_string(), *from);
            attrs.insert(b"to".to_string(), *to);

            (b"animateTransform".to_string(), option::none())
        },
        AnimationType::Set(to) => {
            attrs.insert(b"to".to_string(), *to);
            (b"set".to_string(), option::none())
        },
    };

    print::print(name, attrs, content)
}
