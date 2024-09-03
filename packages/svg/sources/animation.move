// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Module: animation
module svg::animation;

public enum Animation {
    Animate,
    AnimateMotion,
    AnimateTransform,
    MPath,
    Set,
}

/// Create a new animation.
public fun animate(): Animation { Animation::Animate }

/// Create a new motion animation.
public fun animate_motion(): Animation { Animation::AnimateMotion }

/// Create a new transform animation.
public fun animate_transform(): Animation { Animation::AnimateTransform }

/// Create a new path animation.
public fun mpath(): Animation { Animation::MPath }

/// Create a new set animation.
public fun set(): Animation { Animation::Set }
