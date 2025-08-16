#![allow(unused_variables)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, path::Path, rc::Rc, sync::Arc};

use macroquad::prelude::*;
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

use crate::config::{TILE_HEIGHT, TILE_WIDTH};

use super::DrawCommand;

thread_local! {
    pub static ASSETS: OnceCell<Arc<AssetStore>> = OnceCell::new();
}

/// Macro to insert a sprite sheet into the asset store.
///
/// Use:
/// ```rust
/// load_and_register_sprite!(self.sprites, "soldier.png", 6, 32.0 * 4.0, [
///     (Sprite::SoldierRunDown, 0),
///     (Sprite::SoldierRunRight, 1),
///     (Sprite::SoldierRunLeft, 2),
///     (Sprite::SoldierRunUp, 3),
///     (Sprite::SoldierIdle, 4),
/// ]);
/// ```
macro_rules! load_and_register_sprite {
    (
        $map:expr,                // the sprite HashMap
        $file:literal,            // texture filename under `assets/`
        $frames:expr,             // frame count
        $frame_size:expr,         // frame width
        $y_offset:expr,           // y offset
        [ $( ($variant:expr, $row:expr) ),+ $(,)? ] // enum + row list
    ) => {{
        let texture = load_texture(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join(concat!("assets/", $file))
                .to_str()
                .unwrap()
        ).await.unwrap();

        $(
            $map.insert(
                $variant,
                Rc::new(SpriteSheet::new(
                    texture.clone(),
                    $frames,
                    $frame_size,
                    $row,
                    $y_offset,
                )),
            );
        )+
    }};
}

/// Macro to load a texture and register it in the asset store.
macro_rules! load_and_register_texture {
    (
        $map:expr,
        $key:expr,
        $file:literal
    ) => {{
        let texture = load_texture(
            Path::new(env!("CARGO_MANIFEST_DIR"))
                .join(concat!("assets/", $file))
                .to_str()
                .unwrap(),
        )
        .await
        .unwrap();

        $map.insert($key, Rc::new(texture));
    }};
}

#[derive(Debug, Clone)]
pub struct AssetStore {
    pub textures: HashMap<Texture, Rc<Texture2D>>,
    pub fonts: HashMap<String, Rc<Font>>,
    pub sprites: HashMap<Sprite, Rc<SpriteSheet>>,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Texture {
    Background,
    Main,
    Unit,
    Obstacle,
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum Sprite {
    SoldierIdle,
    SoldierRunDown,
    SoldierRunRight,
    SoldierRunLeft,
    SoldierRunUp,
    Shadow,
    Wall,
    WallSnow,
}

#[derive(Debug, Clone)]
/// 2D Sprite sheet with square tiles.
pub struct SpriteSheet {
    pub texture: Rc<Texture2D>,
    pub frames: usize,
    pub frame_size: f32,
    /// The row being loaded (for multi-row sprite sheets).
    pub row: usize,
    pub y_offset: f32,
}

impl SpriteSheet {
    pub fn new(
        texture: Texture2D,
        frames: usize,
        frame_size: f32,
        row: usize,
        y_offset: f32,
    ) -> Self {
        Self {
            texture: Rc::new(texture),
            frames,
            frame_size,
            row,
            y_offset,
        }
    }

    pub fn draw_frame(&self, x: f32, y: f32, frame: usize, dimensions: (u8, u8)) {
        self.draw_frame_with_index(x, y, frame, dimensions, 1);
    }

    pub fn draw_frame_with_index(
        &self,
        x: f32,
        y: f32,
        frame: usize,
        dimensions: (u8, u8),
        z_index: u8,
    ) {
        assert!(
            frame < self.frames,
            "Frame out of bounds: {} < {}",
            frame,
            self.frames
        );

        let (scale_x, scale_y) = super::get_scale(dimensions);
        let y_offset = -self.y_offset * TILE_HEIGHT as f32 * scale_y;

        super::request_draw(DrawCommand::Texture {
            texture: self.texture.clone(),
            x,
            y: y + y_offset,
            color: WHITE,
            params: DrawTextureParams {
                source: Some(Rect {
                    x: self.frame_size * frame as f32,
                    y: self.frame_size * self.row as f32,
                    w: self.frame_size,
                    h: self.frame_size,
                }),
                dest_size: Some(Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y)),
                ..Default::default()
            },
            z_index,
        });
    }
}

impl AssetStore {
    pub fn new() -> Self {
        Self {
            textures: HashMap::new(),
            fonts: HashMap::new(),
            sprites: HashMap::new(),
        }
    }

    pub async fn load_all(&mut self) {
        // === Textures ===

        load_and_register_texture!(self.textures, Texture::Unit, "unit-soldier.png");
        load_and_register_texture!(self.textures, Texture::Background, "texture-snow.png");
        load_and_register_texture!(self.textures, Texture::Obstacle, "obstacle-boulder.png");
        load_and_register_texture!(self.textures, Texture::Main, "main-screen-variation.png");

        // === Fonts ===

        self.fonts.insert(
            "doto".into(),
            Rc::new(
                load_ttf_font(
                    Path::new(env!("CARGO_MANIFEST_DIR"))
                        .join("assets/fonts/jersey20.ttf")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        // === Sprites ===

        load_and_register_sprite!(
            self.sprites,
            "wall-sprite.png",
            4,
            32.0 * 4.0,
            0.0,
            [(Sprite::Wall, 0)]
        );

        load_and_register_sprite!(
            self.sprites,
            "wall-snow-sprite.png",
            4,
            32.0 * 4.0,
            0.0,
            [(Sprite::WallSnow, 1)]
        );

        load_and_register_sprite!(
            self.sprites,
            "soldier.png",
            6,
            32.0 * 4.0,
            0.2,
            [
                (Sprite::SoldierRunDown, 0),
                (Sprite::SoldierRunRight, 1),
                (Sprite::SoldierRunLeft, 2),
                (Sprite::SoldierRunUp, 3),
                (Sprite::SoldierIdle, 4),
            ]
        );

        load_and_register_sprite!(
            self.sprites,
            "shadow.png",
            1,
            32.0 * 4.0,
            0.2,
            [(Sprite::Shadow, 0)]
        );
    }

    pub fn texture(&self, key: Texture) -> Option<Rc<Texture2D>> {
        self.textures.get(&key).cloned()
    }

    pub fn font(&self, key: &str) -> Option<Rc<Font>> {
        self.fonts.get(key).cloned()
    }

    pub fn sprite_sheet(&self, key: Sprite) -> Option<Rc<SpriteSheet>> {
        self.sprites.get(&key).cloned()
    }
}
