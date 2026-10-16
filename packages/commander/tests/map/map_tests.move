// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

module commander::map_tests;

use commander::{
    armor,
    history,
    map,
    recruit::{Self, Recruit},
    stats::{Self, Stats},
    stats_builder,
    weapon
};
use grid::direction;
use std::{bcs, unit_test::assert_eq};
use sui::random;

#[test]
// To better understand the test, please refer to the `demo_1` function and see
// the each map tile in the schema.
fun demo_maps() {
    use grid::direction::{up, down, left, right};

    let demo_1 = map::demo_1(@1.to_id());
    assert!(demo_1.check_path(vector[1, 6, down!(), down!(), left!()]).is_some());
    assert!(demo_1.check_path(vector[0, 0, right!(), right!()]).is_none()); // hop over low cover
    assert!(demo_1.check_path(vector[6, 5, up!()]).is_some()); // also low cover
    assert!(demo_1.check_path(vector[0, 0, down!()]).is_none()); // un-walkable tile
    assert!(demo_1.check_path(vector[0, 3, left!(), down!()]).is_none()); // high cover
    demo_1.destroy();
}

#[test]
fun next_turn() {
    let ctx = &mut tx_context::dummy();
    let mut map = map::demo_1(@1.to_id());
    let recruit = recruit::default(ctx);

    assert_eq!(map.turn(), 0);
    map.place_recruit(&recruit, 0, 0);
    map.move_unit(vector[0, 0, direction::right!()]); // spend 1 AP point
    assert!(map.unit(0, 1).is_some_and!(|unit| unit.ap() == 1));

    map.next_turn();
    map.move_unit(vector[0, 1, direction::left!()]); // spend 1 AP point
    assert!(map.unit(0, 0).is_some_and!(|unit| unit.ap() == 1));
    assert_eq!(map.turn(), 1);

    map.next_turn();
    assert_eq!(map.turn(), 2);

    let (w, a) = recruit.dismiss();
    w.destroy_none();
    a.destroy_none();
    map.destroy();
}

// TODO: REGENERATE DEMO MAPS, GRID FORMAT CHANGED
#[test]
fun from_bcs() {
    let map = map::demo_1(@1.to_id());
    let bytes = bcs::to_bytes(&map);
    let map_copy = map::from_bytes(bytes);
    // assert_ref_eq!(&map, &map_copy);
    map_copy.destroy();
    map.destroy();
}

// === Attacks ===

/// A recruit with a custom weapon. Aim is a recruit stat (65 by default), so a
/// weapon with `aim(35)` makes the unit hit at 100% within its range.
fun recruit_with_weapon(weapon_stats: Stats, ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::default(ctx);
    recruit.add_weapon(weapon::new(b"Test".to_string(), weapon_stats, ctx));
    recruit
}

/// A recruit with an armor that applies the given modifier.
fun recruit_with_armor(armor_stats: Stats, ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::default(ctx);
    recruit.add_armor(armor::new(b"Test".to_string(), armor_stats, ctx));
    recruit
}

fun dismiss(recruit: Recruit) {
    let (weapon, armor) = recruit.dismiss();
    weapon.do!(|w| w.destroy());
    armor.do!(|a| a.destroy());
}

#[test]
/// The weapon's `can_be_dodged` stat decides whether the target may dodge.
fun attack_respects_can_be_dodged() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = map::new(@1.to_id(), 4);

    // both attackers hit at 100%, the target dodges at 100%
    let dodgeable = recruit_with_weapon(
        stats_builder::new().aim(35).can_be_dodged(1).build_weapon(),
        ctx,
    );
    let undodgeable = recruit_with_weapon(
        stats_builder::new().aim(35).can_be_dodged(0).build_weapon(),
        ctx,
    );
    let target = recruit_with_armor(stats::new(0, 0, 0, 0, 100), ctx);

    map.place_recruit(&dodgeable, 0, 0);
    map.place_recruit(&undodgeable, 2, 0);
    map.place_recruit(&target, 1, 1);

    let history = map.perform_attack(&mut rng, 0, 0, 1, 1);
    assert_eq!(history[1], history::new_dodged());
    assert_eq!(history[2], history::new_damage(0));
    assert!(map.unit(1, 1).is_some_and!(|unit| unit.hp() == 10));

    let history = map.perform_attack(&mut rng, 2, 0, 1, 1);
    assert_eq!(history.length(), 2);
    assert!(history[1] != history::new_dodged());
    assert!(map.unit(1, 1).is_some_and!(|unit| unit.hp() < 10));

    dismiss(dodgeable);
    dismiss(undodgeable);
    dismiss(target);
    map.destroy();
}

#[test]
/// The target's natural `defense` stat lowers the hit chance like cover does.
fun attack_applies_natural_defense() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = map::new(@1.to_id(), 4);

    let attacker = recruit_with_weapon(stats_builder::new().aim(35).build_weapon(), ctx);
    let target = recruit_with_armor(stats::new_unchecked(100 << (5 * 8)), ctx);

    map.place_recruit(&attacker, 0, 0);
    map.place_recruit(&target, 0, 2);

    let history = map.perform_attack(&mut rng, 0, 0, 0, 2);
    assert_eq!(
        history,
        vector[history::new_attack(vector[0, 0], vector[0, 2]), history::new_miss()],
    );
    assert!(map.unit(0, 2).is_some_and!(|unit| unit.hp() == 10));

    dismiss(attacker);
    dismiss(target);
    map.destroy();
}

#[test]
/// An area weapon targets a tile, damages every unit in the radius and, with
/// `env_damage`, destroys covers in the area.
fun area_attack_explodes() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = map::demo_1(@1.to_id());

    let attacker = recruit_with_weapon(
        stats_builder::new().aim(35).area_size(1).env_damage(1).can_be_dodged(0).build_weapon(),
        ctx,
    );
    let (one, two) = (recruit::default(ctx), recruit::default(ctx));

    // target tile (2, 5) is empty; (2, 4) and (2, 6) are in the radius
    map.place_recruit(&attacker, 0, 5);
    map.place_recruit(&one, 2, 4);
    map.place_recruit(&two, 2, 6);

    assert!(map.is_tile_cover(2, 5));
    assert!(map.is_tile_cover(2, 6));
    assert!(map.is_tile_cover(3, 5));
    assert!(map.is_tile_cover(3, 6));

    let history = map.perform_attack(&mut rng, 0, 5, 2, 5);
    assert_eq!(history.length(), 4); // attack, explosion, damage x2
    assert_eq!(history[1], history::new_explosion(2, 5, 1));
    assert!(map.unit(2, 4).is_some_and!(|unit| unit.hp() < 10));
    assert!(map.unit(2, 6).is_some_and!(|unit| unit.hp() < 10));
    assert!(map.unit(0, 5).is_some_and!(|unit| unit.hp() == 10)); // out of the area

    assert!(!map.is_tile_cover(2, 5));
    assert!(!map.is_tile_cover(2, 6));
    assert!(!map.is_tile_cover(3, 5));
    assert!(map.is_tile_cover(3, 6)); // out of the area

    dismiss(attacker);
    dismiss(one);
    dismiss(two);
    map.destroy();
}

#[test]
/// A missed area attack has no effect.
fun area_attack_miss_has_no_effect() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = map::new(@1.to_id(), 6);

    // aim 65 - 65 = 0 at the effective range of 4
    let attacker = recruit_with_weapon(
        stats_builder::new().aim(0x80 + 65).area_size(1).build_weapon(),
        ctx,
    );
    let target = recruit::default(ctx);

    map.place_recruit(&attacker, 0, 0);
    map.place_recruit(&target, 0, 3);

    let history = map.perform_attack(&mut rng, 0, 0, 0, 4);
    assert_eq!(
        history,
        vector[history::new_attack(vector[0, 0], vector[0, 4]), history::new_miss()],
    );
    assert!(map.unit(0, 3).is_some_and!(|unit| unit.hp() == 10));

    dismiss(attacker);
    dismiss(target);
    map.destroy();
}

#[test]
/// A grenade records its origin and target, then the explosion; the thrower
/// standing inside the radius is hit too.
fun grenade_records_origin() {
    let ctx = &mut tx_context::dummy();
    let mut rng = random::new_generator_from_seed_for_testing(vector[1]);
    let mut map = map::new(@1.to_id(), 6);
    let recruit = recruit::default(ctx);

    map.place_recruit(&recruit, 0, 0);

    let history = map.perform_grenade(&mut rng, 0, 0, 0, 2);
    assert_eq!(
        history,
        vector[
            history::new_grenade(vector[0, 0], vector[0, 2]),
            history::new_explosion(0, 2, 2),
            history::new_damage(4),
        ],
    );
    assert!(map.unit(0, 0).is_some_and!(|unit| unit.hp() == 6));

    dismiss(recruit);
    map.destroy();
}
