module commander::bench_test;

use commander::{items, map, recruit::{Self, Recruit}};
use std::unit_test::destroy;
use sui::random;

fun setup(ctx: &mut TxContext): (map::Map, Recruit, Recruit) {
    let id = ctx.fresh_object_address().to_id();
    let mut map = map::demo_1(id);
    let (r1, r3) = (recruit_one(ctx), recruit_two(ctx));
    map.place_recruit(&r1, 6, 5);
    map.place_recruit(&r3, 0, 3);
    (map, r1, r3)
}

fun teardown(map: map::Map, r1: Recruit, r3: Recruit) {
    destroy(vector[r1, r3]);
    let _ = map.destroy();
}

fun do_move(map: &mut map::Map) {
    use grid::direction::{up, left};
    map.move_unit(vector[6, 5, up!(), up!(), left!(), left!(), left!(), left!(), up!()]);
}

#[test]
fun a_baseline() {
    let ctx = &mut tx_context::dummy();
    let (map, r1, r3) = setup(ctx);
    teardown(map, r1, r3);
}

#[test]
fun b_move() {
    let ctx = &mut tx_context::dummy();
    let (mut map, r1, r3) = setup(ctx);
    do_move(&mut map);
    teardown(map, r1, r3);
}

#[test]
fun c_move_shoot() {
    let ctx = &mut tx_context::dummy();
    let (mut map, r1, r3) = setup(ctx);
    do_move(&mut map);
    let mut rng = random::new_generator_from_seed_for_testing(b"bench");
    let _ = map.perform_attack(&mut rng, 3, 1, 0, 3);
    teardown(map, r1, r3);
}

#[test]
fun d_move_grenade() {
    let ctx = &mut tx_context::dummy();
    let (mut map, r1, r3) = setup(ctx);
    do_move(&mut map);
    let mut rng = random::new_generator_from_seed_for_testing(b"bench");
    let _ = map.perform_grenade(&mut rng, 3, 1, 0, 3);
    teardown(map, r1, r3);
}

fun recruit_one(ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::new(b"Recruit 1".to_string(), b"".to_string(), ctx);
    recruit.add_armor(items::armor(2, ctx));
    recruit.add_weapon(items::rifle(3, ctx));
    recruit
}

fun recruit_two(ctx: &mut TxContext): Recruit {
    let mut recruit = recruit::new(b"Recruit 2".to_string(), b"".to_string(), ctx);
    recruit.add_armor(items::armor(2, ctx));
    recruit.add_weapon(items::rifle(2, ctx));
    recruit
}
