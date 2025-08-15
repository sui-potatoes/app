// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use macroquad::color::{BLACK, Color};

pub const SUI_COIN_TYPE: &str = "0x2::coin::Coin<0x2::sui::SUI>";

pub const COMMANDER_OBJ: &'static str =
    "0x133420084e1dc366bb9a39d77c4c6a64e9caa553b0a16f704b3f9e7058f98cb7";
pub const PLAYER_ADDRESS: &'static str =
    "0xddb2d7471a381e5080d7c48d5da5baacdd07ddfada4d4cfeec929e27bff44aa9";
pub const COMMANDER_PKG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7";
pub const REPLAY_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::replay::Replay";
pub const RECRUIT_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::recruit::Recruit";
pub const WEAPON_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::weapon::Weapon";
pub const ARMOR_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::armor::Armor";
pub const PRESET_STRUCT_TAG: &'static str =
    "0x6e6770b3554b6bf4997aee770b29e1395aa640979afc84504058f05721ee54a7::commander::Preset";

// === Draw Configuration ===

pub const TILE_WIDTH: f32 = 20.0;
pub const TILE_HEIGHT: f32 = 20.0;

// === Font Configuration ===

pub const MENU_FONT_SIZE: f32 = 24.0;
pub const MENU_FONT_COLOR: Color = BLACK;
