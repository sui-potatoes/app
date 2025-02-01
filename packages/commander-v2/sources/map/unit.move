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
use std::string::String;
use sui::{bcs::{Self, BCS}, random::RandomGenerator};

/// The chance for a critical hit. (100 - 10%)
const CRIT_CHANCE: u8 = 90;

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
/// Returns: (is_hit, is_critical, damage)
///
/// Rng security:
/// - this function is more expensive in the happy path, so the gas limit attack
/// is less likely to be successful
public fun perform_attack(
    unit: &mut Unit,
    rng: &mut RandomGenerator,
    _ctx: &mut TxContext,
): (bool, bool, u8) {
    assert!(unit.ap.value() > 0);

    unit.ap.deplete();

    let dmg_stat = unit.stats.damage();
    let aim_stat = unit.stats.aim();

    let is_hit = rng.generate_u8_in_range(0, 99) >= aim_stat;
    if (!is_hit) return (false, false, 0);

    let is_critical = rng.generate_u8_in_range(0, 99) >= CRIT_CHANCE;
    let swing = rng.generate_u8_in_range(0, 9) % 3; // 0, 1, 2
    let mut damage = match (swing) {
        0 => dmg_stat + 1,
        2 => dmg_stat - 1,
        _ => dmg_stat,
    };

    if (is_critical) damage = ((damage as u16) * 15 / 10) as u8;

    (true, is_critical, damage)
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
    if (can_dodge && dodge_stat > 0 && rng < dodge_stat) {
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

#[test]
fun test_unit() {
    use std::unit_test::assert_eq;
    use sui::random;
    use commander::recruit;

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    // make sure the conversion is correct
    // assert_eq!(unit.stats, *recruit.stats());
    assert_eq!(unit.hp.value(), recruit.stats().health() as u16);
    assert_eq!(unit.ap.value(), 2);

    // now test the attack params
    // make sure to update the values if the rng seed changes
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 0);
    // assert!(unit.ap.is_empty());
    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 6);
    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 4);
    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 0);
    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 0);

    // now test application of damage to the unit
    // for simplicity we'll use the same unit
    unit.apply_damage(&mut rng, 5, true);
    assert_eq!(unit.hp.value(), 5);

    let (weapon, armor) = recruit.dismiss();
    weapon.destroy_none();
    armor.destroy_none();
    unit.destroy();
}

#[test, allow(unused_let_mut, unused_variable, unused_use)]
fun test_unit_custom_weapon() {
    use std::unit_test::assert_eq;
    use sui::random;
    use commander::{recruit, weapon, stats_builder};

    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let mut recruit = recruit::default(ctx);
    let weapon = weapon::new(
        b"Test Rifle".to_string(),
        stats_builder::new().damage(7).build_weapon(),
        ctx,
    );

    recruit.add_weapon(weapon);

    let mut unit = recruit.to_unit();

    // assert_eq!(unit.stats, *recruit.stats());
    // assert_eq!(unit.hp.value(), recruit.stats().health() as u16);
    // assert_eq!(unit.ap.value(), 2);

    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 0); // miss

    // unit.ap.reset();
    // assert_eq!(unit.perform_attack(&mut rng, ctx), 6); // hit

    let (weapon, armor) = recruit.dismiss();
    weapon.do!(|weapon| weapon.destroy());
    armor.do!(|armor| armor.destroy());
    unit.destroy();
}

#[test]
fun test_from_bcs() {
    use std::unit_test::assert_eq;
    use commander::recruit;

    let ctx = &mut tx_context::dummy();
    let recruit = recruit::default(ctx);
    let unit = recruit.to_unit();

    let bytes = bcs::to_bytes(&unit);
    let unit2 = from_bytes(bytes);

    assert_eq!(unit.recruit, unit2.recruit);
    let (weapon, armor) = recruit.dismiss();
    weapon.do!(|weapon| weapon.destroy());
    armor.do!(|armor| armor.destroy());
    unit2.destroy();
    unit.destroy();
}
