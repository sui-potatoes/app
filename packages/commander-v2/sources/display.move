// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements Sui Object Display for objects in the game.
module commander::display;

use commander::{recruit::Recruit, weapon::Weapon};
use sui::display;

public struct DISPLAY has drop {}

fun init(otw: DISPLAY, ctx: &mut TxContext) {
    let publisher = sui::package::claim(otw, ctx);

    // Display for the `Recruit` object.
    let recruit_display = {
        let mut display = display::new<Recruit>(&publisher, ctx);
        display.add(b"name".to_string(), b"{metadata.name} (Rank: {rank})".to_string());
        display.add(b"description".to_string(), b"{metadata.description}".to_string());
        display.add(
            b"image_url".to_string(),
            b"https://i.postimg.cc/wTdDxN7V/recruit.webp".to_string(),
        );
        display.add(
            b"link".to_string(),
            b"http://localhost:5173/commander/recruit/{id}".to_string(),
        );
        display.update_version();
        display
    };

    // Display for the `Weapon` object.
    let weapon_display = {
        let mut display = display::new<Weapon>(&publisher, ctx);
        display.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        display.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        display.add(
            b"image_url".to_string(),
            b"https://i.postimg.cc/ZKG1FT05/weapon.webp".to_string(),
        );
        display.add(b"link".to_string(), b"".to_string());
        display
    };

    transfer::public_transfer(recruit_display, ctx.sender());
    transfer::public_transfer(weapon_display, ctx.sender());
    transfer::public_transfer(publisher, ctx.sender());
}
