// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

///
module commander::modifier;

public struct Modifier has store, copy, drop {
    /// The effect of the modifier.
    effect: ModifierEffect,
    /// The duration of the modifier, in turns.
    duration: u16,
}

public enum ModifierEffect has store, copy, drop {
    /// Increase the value by the given amount.
    Increase(u16),
    /// Decrease the value by the given amount.
    Decrease(u16),
    /// Disable the parameter (set to 0).
    Disable,
}

/// A parameter that can be modified by `Modifier`s.
public struct Param has store, copy, drop {
    /// The current value of the parameter.
    value: u16,
    /// The maximum value of the parameter, originally set.
    max_value: u16,
    /// Modifiers applied to the parameter.
    modifiers: vector<Modifier>,
}
