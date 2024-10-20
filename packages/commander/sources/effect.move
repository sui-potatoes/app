// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::effect;

public struct Effect has copy, drop, store {
    /// The type of the effect.
    effect: EffectType,
    /// The duration of the effect.
    duration: u16,
}

public enum EffectType has copy, drop, store {
    /// The target will lose health over time, before each turn.
    Bleeding,
    /// The target will lose health over time, after each turn.
    Poison,
    /// The target will skip its next turn.
    Stun,
    /// The target will have its movement cost increased.
    Slow,
}

/// Create a new bleeding effect with the given duration.
public fun new_bleeding(duration: u16): Effect { Effect { effect: EffectType::Bleeding, duration } }

/// Create a new poison effect with the given duration.
public fun new_poison(duration: u16): Effect { Effect { effect: EffectType::Poison, duration } }

/// Create a new stun effect with the given duration.
public fun new_stun(duration: u16): Effect { Effect { effect: EffectType::Stun, duration } }

/// Create a new slow effect with the given duration.
public fun new_slow(duration: u16): Effect { Effect { effect: EffectType::Slow, duration } }
