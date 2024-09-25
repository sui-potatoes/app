// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::armour;

public enum Armour has store, copy, drop {
    /// No armor. The unit will take full damage.
    None,
    /// Light armor. The unit will 10% less damage.
    Light,
    /// Medium armor. The unit will take 20% less damage.
    Medium,
    /// Heavy armor. The unit will take 30% less damage.
    Heavy,
}

/// Apply the armor reduction to the given damage.
public fun apply_armor(armor: &Armour, damage: u16): u16 {
    match (armor) {
        Armour::None => damage,
        Armour::Light => damage - (damage / 10),
        Armour::Medium => damage - (damage / 5),
        Armour::Heavy => damage - (damage / 3),
    }
}
