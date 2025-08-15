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
    Wall,
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
        self.draw_frame_with_index(x, y, frame, dimensions, 0);
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
        let root = env!("CARGO_MANIFEST_DIR");

        self.textures.insert(
            Texture::Background,
            Rc::new(
                load_texture(
                    Path::new(root)
                        .join("assets/texture-snow.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        self.textures.insert(
            Texture::Unit,
            Rc::new(
                load_texture(
                    Path::new(root)
                        .join("assets/unit-soldier.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        self.textures.insert(
            Texture::Obstacle,
            Rc::new(
                load_texture(
                    Path::new(root)
                        .join("assets/obstacle-boulder.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        self.textures.insert(
            Texture::Main,
            Rc::new(
                load_texture(
                    Path::new(root)
                        .join("assets/main-screen-variation.png")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        // === Fonts ===

        self.fonts.insert(
            "doto".into(),
            Rc::new(
                load_ttf_font(
                    Path::new(root)
                        .join("assets/fonts/jersey20.ttf")
                        .to_str()
                        .unwrap(),
                )
                .await
                .unwrap(),
            ),
        );

        // === Sprites ===

        self.sprites.insert(
            Sprite::Wall,
            Rc::new(SpriteSheet::new(
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
                0,
                0.0,
            )),
        );

        let soldier_sprite =
            load_texture(Path::new(root).join("assets/soldier.png").to_str().unwrap())
                .await
                .unwrap();

        self.sprites.insert(
            Sprite::SoldierRunDown,
            Rc::new(SpriteSheet::new(
                soldier_sprite.clone(),
                6,
                32.0 * 4.0,
                0,
                0.0,
            )),
        );

        self.sprites.insert(
            Sprite::SoldierRunRight,
            Rc::new(SpriteSheet::new(
                soldier_sprite.clone(),
                6,
                32.0 * 4.0,
                1,
                0.0,
            )),
        );

        self.sprites.insert(
            Sprite::SoldierRunLeft,
            Rc::new(SpriteSheet::new(
                soldier_sprite.clone(),
                6,
                32.0 * 4.0,
                2,
                0.0,
            )),
        );

        self.sprites.insert(
            Sprite::SoldierRunUp,
            Rc::new(SpriteSheet::new(
                soldier_sprite.clone(),
                6,
                32.0 * 4.0,
                3,
                0.0,
            )),
        );

        self.sprites.insert(
            Sprite::SoldierIdle,
            Rc::new(SpriteSheet::new(
                soldier_sprite.clone(),
                6,
                32.0 * 4.0,
                4,
                0.0,
            )),
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
