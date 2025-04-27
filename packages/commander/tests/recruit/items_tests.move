// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Contains all definitions for items that can be used by `Recruits`.
module commander::items_tests;

use commander::items;
use std::unit_test::assert_eq;

#[test]
fun test_weapons() {
    let ctx = &mut tx_context::dummy();

    {
        let rifle = items::rifle(1, ctx);
        assert_eq!(rifle.stats().damage(), 4);
        assert_eq!(rifle.stats().spread(), 2);
        assert_eq!(rifle.stats().plus_one(), 10);
        assert_eq!(rifle.stats().crit_chance(), 10);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 4);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };

    {
        let rifle = items::rifle(2, ctx);
        assert_eq!(rifle.stats().damage(), 5);
        assert_eq!(rifle.stats().spread(), 1);
        assert_eq!(rifle.stats().plus_one(), 20);
        assert_eq!(rifle.stats().crit_chance(), 20);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 5);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };

    {
        let rifle = items::rifle(3, ctx);
        assert_eq!(rifle.stats().damage(), 6);
        assert_eq!(rifle.stats().spread(), 1);
        assert_eq!(rifle.stats().plus_one(), 30);
        assert_eq!(rifle.stats().crit_chance(), 30);
        assert_eq!(rifle.stats().can_be_dodged(), 1);
        assert_eq!(rifle.stats().area_size(), 1);
        assert_eq!(rifle.stats().env_damage(), 0);
        assert_eq!(rifle.stats().range(), 5);
        assert_eq!(rifle.stats().ammo(), 3);
        rifle.destroy();
    };
}

#[test]
fun test_armor() {
    let ctx = &mut tx_context::dummy();

    {
        let armor = items::armor(1, ctx);
        assert_eq!(armor.stats().armor(), 1);
        assert_eq!(armor.stats().dodge(), 10);
        armor.destroy();
    };

    {
        let armor = items::armor(2, ctx);
        assert_eq!(armor.stats().armor(), 2);
        assert_eq!(armor.stats().dodge(), 0);
        armor.destroy();
    };

    {
        let armor = items::armor(3, ctx);
        assert_eq!(armor.stats().mobility(), 0x80 + 1);
        assert_eq!(armor.stats().health(), 1);
        assert_eq!(armor.stats().armor(), 3);
        assert_eq!(armor.stats().dodge(), 0x80 + 10);
        armor.destroy();
    };
}

#[test]
fun test_weapon_upgrades() {
    let ctx = &mut tx_context::dummy();
    let mut rifle = items::rifle(1, ctx);

    assert_eq!(rifle.stats().aim(), 0);

    // scope 1
    rifle.add_upgrade(items::scope(1));
    assert_eq!(rifle.stats().aim(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    // scope 2
    rifle.add_upgrade(items::scope(2));
    assert_eq!(rifle.stats().aim(), 10);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    // scope 3
    rifle.add_upgrade(items::scope(3));
    assert_eq!(rifle.stats().aim(), 15);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().aim(), 0);

    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 1
    rifle.add_upgrade(items::laser_sight(1));
    assert_eq!(rifle.stats().crit_chance(), 15);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 2
    rifle.add_upgrade(items::laser_sight(2));
    assert_eq!(rifle.stats().crit_chance(), 20);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // laser sight 3
    rifle.add_upgrade(items::laser_sight(3));
    assert_eq!(rifle.stats().crit_chance(), 25);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().crit_chance(), 10);

    // stock 1
    rifle.add_upgrade(items::stock(1));
    assert_eq!(rifle.stats().range(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // stock 2
    rifle.add_upgrade(items::stock(2));
    assert_eq!(rifle.stats().range(), 6);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // stock 3
    rifle.add_upgrade(items::stock(3));
    assert_eq!(rifle.stats().range(), 7);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().range(), 4);

    // expanded clip 1
    rifle.add_upgrade(items::expanded_clip(1));
    assert_eq!(rifle.stats().ammo(), 4);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    // expanded clip 2
    rifle.add_upgrade(items::expanded_clip(2));
    assert_eq!(rifle.stats().ammo(), 5);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    // expanded clip 3
    rifle.add_upgrade(items::expanded_clip(3));
    assert_eq!(rifle.stats().ammo(), 6);
    let _ = rifle.remove_upgrade(0);
    assert_eq!(rifle.stats().ammo(), 3);

    rifle.destroy();
}
