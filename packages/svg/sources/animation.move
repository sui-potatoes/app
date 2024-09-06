// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: animation
module svg::animation;

use std::string::String;

/// MPath animation, defines a path for an element to follow. Used in the
/// `animateMotion` element, and references a `path` element by id.
/// - `href` - the id of the path element to follow.
///
/// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/mpath
public struct MPath(String)

/// Animation enum, represents different types of animations that can be
/// applied to SVG elements.
///
/// - `Animate` - animate animation, animates an attribute from one value to another.
/// - `AnimateMotion` - animate motion animation, animates an element along a path.
/// - `AnimateTransform` - animate transform animation, animates a transformation.
/// - `Set` - set animation, sets the value of an attribute at a specific time.
public enum Animation {
    /// Animate animation, animates an attribute from one value to another.
    /// - `attribute` - the name of the attribute to animate.
    /// - `values` - a list of values to animate between.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animate
    Animate(String),
    /// Animate motion animation, animates an element along a path.
    /// - `path` - the path to animate along.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateMotion
    AnimateMotion(String, Option<MPath>),
    /// Animate transform animation, animates a transformation.
    /// - `attribute` - the name of the attribute to animate.
    /// - `type` - the type of transformation to animate.
    /// - `values` - a list of values to animate between.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    /// - `from` - the starting value of the transformation.
    /// - `to` - the ending value of the transformation.
    /// - `by` - the amount to change the transformation by.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/animateTransform
    AnimateTransform(String),
    /// Set animation, sets the value of an attribute at a specific time.
    /// - `attribute` - the name of the attribute to set.
    /// - `to` - the value to set the attribute to.
    /// - `dur` - the duration of the animation.
    /// - `repeatCount` - the number of times to repeat the animation.
    /// - `begin` - the time (or condition) to begin the animation.
    /// - `end` - the time (or condition) to end the animation.
    ///
    /// See: https://developer.mozilla.org/en-US/docs/Web/SVG/Element/set
    Set(String),
}

/// Create a new `<animate>` element.
public fun animate(attribute: String): Animation { Animation::Animate(attribute) }

/// Create a new `<animateMotion>` element.
public fun animate_motion(path: String, mpath: Option<MPath>): Animation {
    Animation::AnimateMotion(path, mpath)
}

/// Create a new `<animateTransform>` element.
public fun animate_transform(attribute: String): Animation {
    Animation::AnimateTransform(attribute)
}

/// Create a new `<set>` element.
public fun set(attribute: String): Animation { Animation::Set(attribute) }

/// Create a new `<mpath>` element. Special element used in the `animateMotion` element
/// to reference a `path` element by id.
public fun mpath(href: String): MPath { MPath(href) }
