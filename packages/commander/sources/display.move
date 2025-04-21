// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/// Implements Sui Object Display for objects in the game.
module commander::display;

use commander::{armor::Armor, recruit::{DogTag, Recruit}, weapon::Weapon};
use sui::{display, package};

public struct DISPLAY has drop {}

/// Creates Display objects for the Recruit and Weapon objects.
fun init(otw: DISPLAY, ctx: &mut TxContext) {
    let publisher = package::claim(otw, ctx);

    // Display for the `Recruit` object.
    let recruit_display = {
        let mut display = display::new<Recruit>(&publisher, ctx);
        display.add(b"name".to_string(), b"{metadata.name} (Rank: {rank})".to_string());
        display.add(b"description".to_string(), b"{metadata.description}".to_string());
        display.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/recruit.webp".to_string(),
        );
        display.add(
            b"link".to_string(),
            b"https://potatoes.app/commander/recruit/{id}".to_string(),
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
            b"https://potatoes.app/images/weapon.webp".to_string(),
        );
        display.add(b"link".to_string(), b"".to_string());
        display.update_version();
        display
    };

    // Armor display
    let armor_display = {
        let mut display = display::new<Armor>(&publisher, ctx);
        display.add(b"name".to_string(), b"Standard Issue Rifle".to_string());
        display.add(
            b"description".to_string(),
            b"Standard Rifle (DMG {damage}; RNG {range}; AMMO {ammo})".to_string(),
        );
        display.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/armor-light.webp".to_string(),
        );
        display.add(b"link".to_string(), b"".to_string());
        display.update_version();
        display
    };

    // Display for the `DogTag` object.
    let dogtag_display = {
        let mut display = display::new<DogTag>(&publisher, ctx);
        display.add(b"name".to_string(), b"{metadata.name} (Rank: {rank})".to_string());
        display.add(b"description".to_string(), b"{metadata.description}".to_string());
        display.add(
            b"image_url".to_string(),
            b"https://potatoes.app/images/recruit.webp".to_string(),
        );
        display.add(
            b"link".to_string(),
            b"https://potatoes.app/commander/recruit/{id}".to_string(),
        );
        display.update_version();
        display
    };

    let sender = ctx.sender();

    transfer::public_transfer(recruit_display, sender);
    transfer::public_transfer(weapon_display, sender);
    transfer::public_transfer(dogtag_display, sender);
    transfer::public_transfer(armor_display, sender);
    transfer::public_transfer(publisher, sender);
}
