// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Unit is a representation of the `Recruit` in the game. It copies most of the
/// fields of the `Recruit` into a "digestible" form for the `Map`. Units are
/// placed on the `Map` directly and linked to their corresponding `Recruit`s
/// via the `address` -> `UID`.
///
/// Traits:
/// - from_bcs
module commander::unit;

use commander::{param::{Self, Param}, recruit::Recruit, stats::{Self, Stats}};
use std::{macros::num_min, string::String};
use sui::{bcs::{Self, BCS}, random::RandomGenerator};

/// Trying to attack a target that is out of range.
const ERangeExceeded: u64 = 1;

/// Weapon range can be exceeded by this value with aim penalty.
const MAX_RANGE_OFFSET: u8 = 3;
/// If distance is less than range, the aim bonus is applied for each tile.
const DISTANCE_BONUS: u8 = 5;
/// If distance is greater than range, the aim penalty is applied for each tile.
const DISTANCE_PENALTY: u8 = 10;

/// A single `Unit` on the `Map`.
public struct Unit has copy, store {
    /// The `ID` of the `Recruit`.
    recruit: ID,
    /// Number of actions the `Unit` can perform in a single turn. Resets at the
    /// beginning of eafch turn. A single action takes 1 point, options vary from
    /// moving, attacking, using abilities, etc.
    ap: Param,
    /// The HP of the `Unit`.
    hp: Param,
    /// Stats of the `Recruit`.
    stats: Stats,
    /// The last turn the `Unit` has performed an action.
    last_turn: u16,
}

/// Get the attack parameters of the `Unit`: damage and aim.
public fun attack_params(unit: &Unit): (u16, u16) {
    (unit.stats.damage() as u16, unit.stats.aim() as u16)
}

/// Reset the AP of the `Unit` to the default value if the turn is over.
public fun try_reset_ap(unit: &mut Unit, turn: u16) {
    if (unit.last_turn < turn) unit.ap.reset();
    unit.last_turn = turn;
}

/// Get the HP of the `Unit`.
public fun perform_move(unit: &mut Unit, distance: u8) {
    assert!(unit.stats.mobility() >= distance);
    assert!(unit.ap.value() > 0);

    unit.ap.decrease(1);
}

/// Reload the `Unit`'s weapon. It costs 1 AP.
public fun perform_reload(unit: &mut Unit) {
    assert!(unit.ap.value() > 0);
    unit.ap.decrease(1);
}

#[allow(lint(public_random))]
/// The `Unit` performs an attack on another `Unit`. The attack is calculated
/// from the `Unit`'s stats and returns the damage dealt. It does not include
/// the target's armor or dodge, which should be calculated separately.
///
/// Notes:
/// - Crit chance is currently hardcoded to 10%.
/// - Crit damage is 50% higher than the base damage.
/// - Regular attack can be + or - 10% of the base damage - random.
/// - The attack fully depletes the `Unit`'s AP.
///
/// Returns: (is_hit, is_critical, is_plus_one, damage, hit_chance)
///
/// Rng security:
/// - this function is more expensive in the happy path, so the gas limit attack
/// is less likely to be successful
public fun perform_attack(
    unit: &mut Unit,
    rng: &mut RandomGenerator,
    range: u8,
): (bool, bool, bool, u8, u8) {
    assert!(unit.ap.value() > 0);

    unit.ap.deplete();

    let crit_chance = unit.stats.crit_chance();
    let dmg_stat = unit.stats.damage();
    let eff_range = unit.stats.range();
    let aim_stat = unit.stats.aim();
    let spread = MAX_RANGE_OFFSET;

    assert!(eff_range + spread >= range, ERangeExceeded);

    // aim stat is affected by the range
    let hit_chance = if (eff_range == range) {
        aim_stat
    } else if (eff_range > range) {
        num_min!(aim_stat + DISTANCE_BONUS * (eff_range - range), 100)
    } else {
        aim_stat - num_min!(DISTANCE_PENALTY * (range - eff_range), aim_stat)
    };

    let is_hit = rng.generate_u8_in_range(0, 99) < hit_chance;
    if (!is_hit) return (false, false, false, 0, hit_chance);

    let spread = unit.stats.spread();
    let is_critical = rng.generate_u8_in_range(0, 99) < crit_chance;
    let damage = match (rng.generate_bool()) {
        true => dmg_stat + rng.generate_u8_in_range(0, spread),
        false => dmg_stat - rng.generate_u8_in_range(0, spread),
    };

    let is_plus_one = rng.generate_u8_in_range(0, 99) < unit.stats.plus_one();
    let damage = if (is_plus_one) damage + 1 else damage;
    let damage = if (is_critical) damage + (dmg_stat / 2) else damage;

    (true, is_plus_one, is_critical, damage, hit_chance)
}

#[allow(lint(public_random))]
/// Apply damage to unit, can dodgeable (shot) or not (explosive).
///
/// Returns: (is_dodged, damage applied, is_kia),
public fun apply_damage(
    unit: &mut Unit,
    rng: &mut RandomGenerator,
    damage: u8,
    can_dodge: bool,
): (bool, u8, bool) {
    let dodge_stat = unit.stats.dodge();
    let armor_stat = unit.stats.armor();

    // prettier-ignore
    let damage =
        if (armor_stat >= damage) 1
        else damage - armor_stat;

    // if attack can be dodged, spin the wheel and see if the unit dodges
    let rng = rng.generate_u8_in_range(0, 99);
    if (can_dodge && rng < dodge_stat) {
        return (true, 0, false)
    };

    let hp_left = unit.hp.decrease(damage as u16);
    (false, damage, hp_left == 0)
}

/// Creates a new `Unit` - an in-game represenation of a `Recruit`.
public fun from_recruit(recruit: &Recruit): Unit {
    let stats = *recruit.stats();
    let mut armor_stats = stats::default_armor();
    let mut weapon_stats = stats::default_weapon();
    recruit.weapon().do_ref!(|w| weapon_stats = *w.stats());
    recruit.armor().do_ref!(|a| armor_stats = *a.stats());

    Unit {
        recruit: object::id(recruit),
        ap: param::new(2),
        hp: param::new(stats.health() as u16),
        stats: stats.add(&weapon_stats.add(&armor_stats)),
        last_turn: 0,
    }
}

/// Destroy the `Unit` struct. KIA.
/// Returns the `ID` of the `Recruit` for easier tracking and "elimination" of
/// the `Recruit` from the game.
public fun destroy(unit: Unit): ID {
    let Unit { recruit, .. } = unit;
    recruit
}

// === Accessors ===

/// Get the `Recruit`'s ID from the `Unit`.
public fun recruit_id(unit: &Unit): ID { unit.recruit }

/// Get the `Unit`'s HP.
public fun hp(unit: &Unit): u16 { unit.hp.value() }

/// Get the `Unit`'s AP.
public fun ap(unit: &Unit): u16 { unit.ap.value() }

/// Get the `Unit`'s stats.
public fun stats(unit: &Unit): &Stats { &unit.stats }

// === Convenience and compatibility ===

/// Deserialize bytes into a `Rank`.
public fun from_bytes(bytes: vector<u8>): Unit {
    from_bcs(&mut bcs::new(bytes))
}

/// Helper method to allow nested deserialization of `Unit`.
public(package) fun from_bcs(bcs: &mut BCS): Unit {
    Unit {
        recruit: bcs.peel_address().to_id(),
        ap: param::from_bcs(bcs),
        hp: param::from_bcs(bcs),
        stats: stats::from_bcs(bcs),
        last_turn: bcs.peel_u16(),
    }
}

/// Print the `Unit` as a `String`.
public fun to_string(_unit: &Unit): String { b"Unit".to_string() }
