#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::f32::consts::PI;

use macroquad::prelude::*;

/// Default size of a tile in pixels, will be scaled to the window size.
const TILE_SIZE: f32 = 20.0;

pub struct Highlight(pub Vec<(u8, u8)>, pub Color);

pub trait Draw {
    fn draw(&self);
}

/// Draw a cursor at the given tile.
/// The cursor is a rectangle with a thickness of 4.0.
pub fn draw_cursor(position: (u8, u8), dimensions: (u8, u8)) {
    let (screen_width, screen_height) = (screen_width(), screen_height());
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);
    let (scale_x, scale_y) = (
        screen_width / (width * TILE_SIZE),
        screen_height / (height * TILE_SIZE),
    );

    draw_rectangle_lines(
        position.1 as f32 * TILE_SIZE * scale_x,
        position.0 as f32 * TILE_SIZE * scale_y,
        TILE_SIZE * scale_x,
        TILE_SIZE * scale_y,
        4.0,
        RED,
    );
}

/// Draw a highlight on the given tiles.
pub fn draw_highlight(highlight: &Highlight, dimensions: (u8, u8)) {
    let (screen_width, screen_height) = (screen_width(), screen_height());
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);
    let (scale_x, scale_y) = (
        screen_width / (width * TILE_SIZE),
        screen_height / (height * TILE_SIZE),
    );

    for (x, y) in &highlight.0 {
        draw_rectangle(
            *y as f32 * TILE_SIZE * scale_x,
            *x as f32 * TILE_SIZE * scale_y,
            TILE_SIZE * scale_x,
            TILE_SIZE * scale_y,
            highlight.1,
        );
    }
}

/// Get the size of the map and for each tile draw the texture. Apply the scale
/// similarly to the Map drawing.
pub fn draw_texture_background(dimensions: (u8, u8), texture: &Texture2D) {
    let (screen_width, screen_height) = (screen_width(), screen_height());
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);
    let (scale_x, scale_y) = (
        screen_width / (width * TILE_SIZE),
        screen_height / (height * TILE_SIZE),
    );

    for y in 0..height as i32 {
        for x in 0..width as i32 {
            draw_texture_ex(
                texture,
                x as f32 * TILE_SIZE * scale_x,
                y as f32 * TILE_SIZE * scale_y,
                WHITE,
                DrawTextureParams {
                    dest_size: Some(Vec2::new(TILE_SIZE * scale_x, TILE_SIZE * scale_y)),
                    // draw 180º counter-clockwise
                    rotation: if x % 2 == 0 { 0.0 } else { PI },
                    ..Default::default()
                },
            );
        }
    }
}
