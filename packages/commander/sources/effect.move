// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::effect;

use commander::unit::{Self, Unit};

public struct Effect has copy, drop, store {
    /// The type of the effect.
    effect: EffectType,
    /// The duration of the effect.
    duration: u16,
}

public enum EffectType has copy, drop, store {
    /// The target will lose health over time, before each turn.
    Bleed,
    /// The target will lose health over time, after each turn.
    Poison,
    /// The target will skip its next turn.
    Stun,
    /// The target will have its movement cost increased.
    Slow,
    /// Unit will have its attack increased.
    Bloodlust,
}

// /// Effects are applied on
// public fun apply_effect(unit: &mut Unit, effect: Effect): Unit {
// }
