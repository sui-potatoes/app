#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{cell::RefCell, f32::consts::PI, rc::Rc};

use macroquad::prelude::*;

/// Default size of a tile in pixels, will be scaled to the window size.
const TILE_SIZE: f32 = 20.0;

// Safe to use in the main thread, forces the use of a single thread. Hence,
// allows using RefCell which doesn't implement Sync for 'static lifetime.
thread_local! {
    pub static DRAW_REGISTRY: RefCell<Vec<DrawCommand>> = RefCell::new(Vec::new());
}

pub enum DrawCommand {
    Texture {
        texture: Rc<Texture2D>,
        x: f32,
        y: f32,
        color: Color,
        params: DrawTextureParams,
        z_index: u8,
    },
    RectangleLines {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        thickness: f32,
        color: Color,
        z_index: u8,
    },
    Rectangle {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        color: Color,
        z_index: u8,
    },
    Text {
        text: String,
        x: f32,
        y: f32,
        font: Option<Rc<Font>>,
        font_size: u16,
        font_scale: f32,
        font_scale_aspect: f32,
        rotation: f32,
        color: Color,
        z_index: u8,
    },
}

pub struct Highlight(pub Vec<(u8, u8)>, pub Color);

pub trait Draw {
    /// Draw the object globally.
    fn draw(&self);
}

/// Draw the object at the given position (in cell coordinates).
/// Requires the dimensions of the map where the object is being drawn.
pub trait DrawAt {
    fn draw_at(&self, position: (u8, u8), dimensions: (u8, u8));
}

pub fn draw_main_menu_background() {
    request_draw(DrawCommand::Texture {
        texture: super::ASSETS
            .with(|assets| assets.get().unwrap().texture(super::Texture::Main).unwrap())
            .clone(),
        x: 0.0,
        y: 0.0,
        color: WHITE,
        params: DrawTextureParams {
            dest_size: Some(Vec2::new(screen_width(), screen_height())),
            ..Default::default()
        },
        z_index: 0,
    });
}

/// Draw a cursor at the given tile.
/// The cursor is a rectangle with a thickness of 4.0.
pub fn draw_cursor(position: (u8, u8), dimensions: (u8, u8)) {
    let (scale_x, scale_y) = get_scale(dimensions);

    request_draw(DrawCommand::RectangleLines {
        x: position.1 as f32 * TILE_SIZE * scale_x,
        y: position.0 as f32 * TILE_SIZE * scale_y,
        width: TILE_SIZE * scale_x,
        height: TILE_SIZE * scale_y,
        thickness: 4.0,
        color: RED,
        z_index: 1,
    });
}

/// Draw a highlight on the given tiles.
pub fn draw_highlight(highlight: &Highlight, dimensions: (u8, u8)) {
    let (scale_x, scale_y) = get_scale(dimensions);
    for (x, y) in &highlight.0 {
        request_draw(DrawCommand::Rectangle {
            x: *y as f32 * TILE_SIZE * scale_x,
            y: *x as f32 * TILE_SIZE * scale_y,
            width: TILE_SIZE * scale_x,
            height: TILE_SIZE * scale_y,
            color: highlight.1,
            z_index: 1,
        });
    }
}

/// Get the size of the map and for each tile draw the texture. Apply the scale
/// similarly to the Map drawing.
pub fn draw_texture_background(dimensions: (u8, u8), texture: Rc<Texture2D>) {
    let (scale_x, scale_y) = get_scale(dimensions);
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);

    for y in 0..height as i32 {
        for x in 0..width as i32 {
            request_draw(DrawCommand::Texture {
                texture: texture.clone(),
                x: x as f32 * TILE_SIZE * scale_x,
                y: y as f32 * TILE_SIZE * scale_y,
                color: WHITE,
                params: DrawTextureParams {
                    dest_size: Some(Vec2::new(TILE_SIZE * scale_x, TILE_SIZE * scale_y)),
                    // draw 180º counter-clockwise
                    rotation: if x % 2 == 0 { 0.0 } else { PI },
                    ..Default::default()
                },
                z_index: 0,
            });
        }
    }
}

pub fn get_scale(dimensions: (u8, u8)) -> (f32, f32) {
    let (screen_width, screen_height) = (screen_width(), screen_height());
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);
    (
        screen_width / (width * TILE_SIZE),
        screen_height / (height * TILE_SIZE),
    )
}

pub fn grid_to_world(p: (u8, u8), dimensions: (u8, u8)) -> Vec2 {
    let (scale_x, scale_y) = get_scale(dimensions);
    Vec2::new(
        p.1 as f32 * TILE_SIZE * scale_x,
        p.0 as f32 * TILE_SIZE * scale_y,
    )
}

/// Stores the draw command in the thread-local registry to be executed on each
/// frame. The commands are sorted by their z-index and then drawn in order.
///
/// See `flush_draw_registry` for the actual drawing.
pub fn request_draw(cmd: DrawCommand) {
    DRAW_REGISTRY.with(move |registry| {
        registry.borrow_mut().push(cmd);
    });
}

/// Drain the draw registry and draw the commands in order.
pub fn flush_draw_registry() {
    DRAW_REGISTRY.with(|registry| {
        let mut registry = registry.borrow_mut();
        registry.sort_by_key(|command| command.z_index());
        registry.drain(..).for_each(|command| command.draw());
    });
}

impl DrawCommand {
    pub fn z_index(&self) -> u8 {
        match self {
            DrawCommand::Texture { z_index, .. } => *z_index,
            DrawCommand::RectangleLines { z_index, .. } => *z_index,
            DrawCommand::Rectangle { z_index, .. } => *z_index,
            DrawCommand::Text { z_index, .. } => *z_index,
        }
    }

    pub fn text(text: String, x: f32, y: f32, font_size: u16, color: Color, z_index: u8) -> Self {
        DrawCommand::Text {
            text,
            x,
            y,
            color,
            z_index,
            font: Some(
                super::ASSETS
                    .with(|assets| assets.get().unwrap().font("doto").unwrap())
                    .clone(),
            ),
            font_size,
            font_scale: 1.0,
            font_scale_aspect: 1.0,
            rotation: 0.0,
        }
    }

    pub fn schedule(self) {
        request_draw(self);
    }

    pub fn draw(self) {
        match self {
            DrawCommand::Texture {
                texture,
                x,
                y,
                color,
                params,
                ..
            } => {
                draw_texture_ex(&texture, x, y, color, params.clone());
            }
            DrawCommand::RectangleLines {
                x,
                y,
                width,
                height,
                thickness,
                color,
                ..
            } => {
                draw_rectangle_lines(x, y, width, height, thickness, color);
            }
            DrawCommand::Rectangle {
                x,
                y,
                width,
                height,
                color,
                ..
            } => {
                draw_rectangle(x, y, width, height, color);
            }
            DrawCommand::Text {
                text,
                x,
                y,
                font,
                font_size,
                font_scale,
                font_scale_aspect,
                rotation,
                color,
                ..
            } => {
                draw_text_ex(
                    &text,
                    x,
                    y,
                    TextParams {
                        font: font.as_ref().map(|f| f.as_ref()),
                        font_size,
                        font_scale,
                        font_scale_aspect,
                        rotation,
                        color,
                    },
                );
            }
        }
    }
}
