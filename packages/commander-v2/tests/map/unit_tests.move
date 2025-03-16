// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::unit_tests;

use commander::{recruit, stats_builder, unit, weapon};
use std::{bcs, unit_test::assert_eq};
use sui::random;

#[test]
fun default() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    // make sure the conversion is correct
    // assert_eq!(unit.stats, *recruit.stats());
    assert_eq!(unit.hp(), recruit.stats().health() as u16);
    assert_eq!(unit.ap(), 2);

    // now test application of damage to the unit
    // for simplicity we'll use the same unit
    unit.apply_damage(&mut rng, 5, true);
    assert_eq!(unit.hp(), 5);

    let (weapon, armor) = recruit.dismiss();
    weapon.destroy_none();
    armor.destroy_none();
    unit.destroy();
}

#[test]
// Scenario:
// - perform attack, next turn
// - reload
fun perform_reload() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    unit.perform_attack(&mut rng, 1);
    unit.try_reset_ap(1);
    unit.perform_reload();

    let (weapon, armor) = recruit.dismiss();
    weapon.destroy_none();
    armor.destroy_none();
    unit.destroy();
}

#[test, expected_failure(abort_code = unit::ENoAP)]
// Scenario:
// - reload at full clip capacity - fail
fun perform_reload_no_ap_fail() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    unit.perform_attack(&mut rng, 1);
    unit.perform_reload();

    abort
}

#[test, expected_failure(abort_code = unit::EFullAmmo)]
// Scenario:
// - reload at full clip capacity - fail
fun perform_reload_full_clip_fail() {
    let ctx = &mut tx_context::dummy();
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    unit.perform_reload();

    abort
}

#[test]
// Scenario:
// - throw a grenade
// - check AP and whether grenade was used
fun perform_grenade() {
    let ctx = &mut tx_context::dummy();
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    assert!(!unit.grenade_used());
    assert_eq!(unit.ap(), 2);
    unit.perform_grenade();

    assert_eq!(unit.ap(), 1);
    assert!(unit.grenade_used());

    let (weapon, armor) = recruit.dismiss();
    weapon.destroy_none();
    armor.destroy_none();
    unit.destroy();
}

#[test, expected_failure(abort_code = unit::EOutOfAmmo)]
// Scenario:
// - throw grenade twice - fail - grenade used
fun perform_grenade_twice_fail() {
    let ctx = &mut tx_context::dummy();
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    unit.perform_grenade();
    unit.perform_grenade();

    abort
}

#[test, expected_failure(abort_code = unit::ENoAP)]
// Scenario:
// - deplete AP by performing an attack
// - try throwing a grenade
fun perform_grenade_no_ap_fail() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    unit.perform_attack(&mut rng, 4);
    unit.perform_grenade();

    abort
}

#[test]
fun perform_attack_distance_modifiers() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    assert_eq!(unit.stats().range(), 4);
    assert_eq!(unit.stats().aim(), 65);

    // 15% bonus
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 1);
    assert_eq!(hit_chance, 80);
    unit.try_reset_ap(1);

    // 10% bonus
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 2);
    assert_eq!(hit_chance, 75);
    unit.try_reset_ap(2);

    // 5% bonus
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 3);
    assert_eq!(hit_chance, 70);
    unit.try_reset_ap(3);

    // no bonus, no penalty
    unit.perform_reload();
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 4);
    assert_eq!(hit_chance, 65);
    unit.try_reset_ap(4);

    // 10% penalty
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 5);
    assert_eq!(hit_chance, 55);
    unit.try_reset_ap(5);

    // 20% penalty
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 6);
    assert_eq!(hit_chance, 45);
    unit.try_reset_ap(6);

    // 30% penalty
    unit.perform_reload();
    let (_, _, _, _, hit_chance) = unit.perform_attack(&mut rng, 7);
    assert_eq!(hit_chance, 35);
    unit.try_reset_ap(7);

    recruit.kill(ctx).throw_away();
    unit.destroy();
}

#[test]
fun shoot_and_reload() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[0]);
    let recruit = recruit::default(ctx);
    let mut unit = recruit.to_unit();

    assert_eq!(unit.ammo(), 3);
    unit.perform_attack(&mut rng, 1);
    assert_eq!(unit.ammo(), 2);
    unit.try_reset_ap(1);
    unit.perform_reload();
    assert_eq!(unit.ammo(), 3);
    assert_eq!(unit.ap(), 1);
    unit.perform_attack(&mut rng, 1);
    assert_eq!(unit.ammo(), 2);
    unit.try_reset_ap(2);
    unit.perform_attack(&mut rng, 1);
    assert_eq!(unit.ammo(), 1);
    unit.try_reset_ap(3);
    unit.perform_attack(&mut rng, 1);
    assert_eq!(unit.ammo(), 0);

    recruit.kill(ctx).throw_away();
    unit.destroy();
}

#[test]
fun unit_custom_weapon() {
    let ctx = &mut tx_context::dummy();
    let mut recruit = recruit::default(ctx);
    let weapon = weapon::new(
        b"Test Rifle".to_string(),
        stats_builder::new().damage(7).build_weapon(),
        ctx,
    );

    recruit.add_weapon(weapon);

    let unit = recruit.to_unit();
    let (weapon, armor) = recruit.dismiss();

    assert_eq!(unit.stats().damage(), 7);

    weapon.do!(|weapon| weapon.destroy());
    armor.do!(|armor| armor.destroy());
    unit.destroy();
}

#[test]
fun from_bcs() {
    let ctx = &mut tx_context::dummy();
    let recruit = recruit::default(ctx);
    let unit = recruit.to_unit();

    let bytes = bcs::to_bytes(&unit);
    let unit2 = unit::from_bytes(bytes);

    assert_eq!(unit.recruit_id(), unit2.recruit_id());
    let (weapon, armor) = recruit.dismiss();
    weapon.do!(|weapon| weapon.destroy());
    armor.do!(|armor| armor.destroy());
    unit2.destroy();
    unit.destroy();
}
