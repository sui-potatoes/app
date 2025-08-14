#![allow(unused_variables)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, path::Path, sync::Arc};

use macroquad::prelude::*;
use once_cell::sync::OnceCell;
use serde::{Deserialize, Serialize};

use crate::config::{TILE_HEIGHT, TILE_WIDTH};

pub static ASSETS: OnceCell<Arc<AssetStore>> = OnceCell::new();

#[derive(Debug, Clone)]
pub struct AssetStore {
    pub textures: HashMap<Texture, Texture2D>,
    pub fonts: HashMap<String, Font>,
    pub sprites: HashMap<Sprite, SpriteSheet>,
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
    UnitSoldier,
    Wall,
}

#[derive(Debug, Clone)]
/// 2D Sprite sheet with square tiles.
pub struct SpriteSheet {
    pub texture: Texture2D,
    pub frames: usize,
    pub frame_size: f32,
}

impl SpriteSheet {
    pub fn new(texture: Texture2D, frames: usize, frame_size: f32) -> Self {
        Self {
            texture,
            frames,
            frame_size,
        }
    }

    pub fn draw_frame(&self, x: f32, y: f32, frame: usize, dimensions: (u8, u8)) {
        assert!(
            frame < self.frames,
            "Frame out of bounds: {} < {}",
            frame,
            self.frames
        );

        let (scale_x, scale_y) = super::get_scale(dimensions);

        draw_texture_ex(
            &self.texture,
            x,
            y,
            WHITE,
            DrawTextureParams {
                source: Some(Rect {
                    x: self.frame_size * frame as f32,
                    y: 0.0,
                    w: self.frame_size,
                    h: self.frame_size,
                }),
                dest_size: Some(Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y)),
                ..Default::default()
            },
        )
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
        let root = env!("CARGO_MANIFEST_DIR");

        self.textures.insert(
            Texture::Background,
            load_texture(
                Path::new(root)
                    .join("assets/texture-snow.png")
                    .to_str()
                    .unwrap(),
            )
            .await
            .unwrap(),
        );

        self.textures.insert(
            Texture::Unit,
            load_texture(
                Path::new(root)
                    .join("assets/unit-soldier.png")
                    .to_str()
                    .unwrap(),
            )
            .await
            .unwrap(),
        );

        self.textures.insert(
            Texture::Obstacle,
            load_texture(
                Path::new(root)
                    .join("assets/obstacle-boulder.png")
                    .to_str()
                    .unwrap(),
            )
            .await
            .unwrap(),
        );

        self.textures.insert(
            Texture::Main,
            load_texture(
                Path::new(root)
                    .join("assets/main-screen-variation.png")
                    .to_str()
                    .unwrap(),
            )
            .await
            .unwrap(),
        );

        // === Fonts ===

        self.fonts.insert(
            "doto".into(),
            load_ttf_font(
                Path::new(root)
                    .join("assets/fonts/jersey20.ttf")
                    .to_str()
                    .unwrap(),
            )
            .await
            .unwrap(),
        );

        // === Sprites ===

        self.sprites.insert(
            Sprite::UnitSoldier,
            SpriteSheet::new(
                load_texture(
                    Path::new(root)
                        .join("assets/soldier-sprite.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
                8,
                32.0 * 4.0,
            ),
        );

        self.sprites.insert(
            Sprite::Wall,
            SpriteSheet::new(
                load_texture(
                    Path::new(root)
                        .join("assets/wall-sprite.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
                4,
                32.0 * 4.0,
            ),
        );
    }

    pub fn texture(&self, key: Texture) -> Option<&Texture2D> {
        self.textures.get(&key)
    }

    pub fn font(&self, key: &str) -> Option<&Font> {
        self.fonts.get(key)
    }

    pub fn sprite_sheet(&self, key: Sprite) -> Option<&SpriteSheet> {
        self.sprites.get(&key)
    }
}
