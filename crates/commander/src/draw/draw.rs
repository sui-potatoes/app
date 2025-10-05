#![allow(dead_code)]
// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

//! # Draw
//!
//! Draw commands are stored in a thread-local registry and executed on each
//! frame. The commands are sorted by their z-index and then drawn in order.
//!
//! Each command has a matching builder that allows setting the properties of
//! the command and then building it. Once built, the command can be scheduled
//! to be executed on the next frame.
//!
//! See `flush_draw_registry` for the actual drawing.

use std::{cell::RefCell, f32::consts::PI, rc::Rc};

use macroquad::prelude::*;

use crate::draw::{Asset, Sprite, Texture};

/// Default size of a tile in pixels, will be scaled to the window size.
const TILE_SIZE: f32 = 20.0;

// Safe to use in the main thread, forces the use of a single thread. Hence,
// allows using RefCell which doesn't implement Sync for 'static lifetime.
thread_local! {
    pub static DRAW_REGISTRY: RefCell<Vec<DrawCommand>> = RefCell::new(Vec::new());
}

/// Draw command that can be scheduled to be executed on the next frame.
pub enum DrawCommand {
    Texture {
        texture: Rc<Texture2D>,
        x: f32,
        y: f32,
        color: Color,
        dest_size: Option<Vec2>,
        source: Option<Rect>,
        rotation: f32,
        flip_x: bool,
        flip_y: bool,
        pivot: Option<Vec2>,
        z_index: ZIndex,
    },
    RectangleLines {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        thickness: f32,
        color: Color,
        z_index: ZIndex,
    },
    Rectangle {
        x: f32,
        y: f32,
        width: f32,
        height: f32,
        color: Color,
        z_index: ZIndex,
    },
    Line {
        x1: f32,
        y1: f32,
        x2: f32,
        y2: f32,
        color: Color,
        thickness: f32,
        z_index: ZIndex,
    },
    Text {
        text: String,
        x: f32,
        y: f32,
        align: Align,
        font: Rc<Font>,
        font_size: u16,
        font_scale: f32,
        font_scale_aspect: f32,
        rotation: f32,
        background: Option<Color>,
        padding: Vec2,
        line_height: Option<f32>,
        color: Color,
        z_index: ZIndex,
    },
}

#[repr(u8)]
#[derive(Clone, Copy, PartialEq, PartialOrd, Ord, Eq)]
pub enum ZIndex {
    Background = 0,
    Grid = 1,
    TopCover = 2,
    Highlight = 3,
    Cursor = 4,
    UnitShadow = 10,
    Unit = 11,
    Obstacle = 20,
    BottomCover = 21,
    ModalBackground = 30,
    ModalText = 32,
    UnitStatus = 40,
    MenuText = 41,
    Max = 255,
}

pub enum Align {
    Left,
    Center,
    Right,
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
    let frame = (get_time() * 10.0) as usize % 12;
    let sprite = Sprite::MainAnim.load().unwrap();

    sprite.draw_frame(0.0, 0.0, frame, (1, 1));
}

/// Draw a cursor at the given tile.
/// The cursor is a rectangle with a thickness of 4.0.
pub fn draw_cursor(position: (u8, u8), dimensions: (u8, u8)) {
    let (scale_x, scale_y) = get_scale(dimensions);
    let thickness = 6.0;

    let x = position.1 as f32 * TILE_SIZE * scale_x + thickness / 2.0;
    let y = position.0 as f32 * TILE_SIZE * scale_y + thickness / 2.0;
    let width = TILE_SIZE * scale_x - thickness;
    let height = TILE_SIZE * scale_y - thickness;

    DrawRectangleLinesBuilder::new()
        .position(x, y)
        .dimensions(width, height)
        .thickness(thickness)
        .color(BLUE)
        .z_index(ZIndex::Cursor)
        .schedule();
}

/// Draw a highlight on the given tiles.
pub fn draw_highlight(highlight: &Highlight, dimensions: (u8, u8)) {
    let (scale_x, scale_y) = get_scale(dimensions);
    for (hx, hy) in &highlight.0 {
        let x = *hy as f32 * TILE_SIZE * scale_x;
        let y = *hx as f32 * TILE_SIZE * scale_y;

        DrawRectangleBuilder::new()
            .position(x, y)
            .dimensions(TILE_SIZE * scale_x, TILE_SIZE * scale_y)
            .color(highlight.1)
            .z_index(ZIndex::Highlight)
            .schedule();
    }
}

/// Draw a line through the given tiles, line starts at the center of each tile
/// and goes to the center of the next tile.
pub fn draw_path(path: &[(u8, u8)], dimensions: (u8, u8)) {
    let (scale_x, scale_y) = get_scale(dimensions);
    let thickness = 3.0;

    for w in path.windows(2) {
        let (x1, y1) = w[0];
        let (x2, y2) = w[1];

        DrawLineBuilder::new()
            .start(
                (y1 as f32 + 0.5) * TILE_SIZE * scale_y - thickness / 2.0,
                (x1 as f32 + 0.5) * TILE_SIZE * scale_x + thickness / 2.0,
            )
            .end(
                (y2 as f32 + 0.5) * TILE_SIZE * scale_y - thickness / 2.0,
                (x2 as f32 + 0.5) * TILE_SIZE * scale_x + thickness / 2.0,
            )
            .color(BLUE)
            .thickness(thickness)
            .z_index(ZIndex::Highlight)
            .schedule();
    }
}

/// Get the size of the map and for each tile draw the texture. Apply the scale
/// similarly to the Map drawing.
pub fn draw_texture_background(dimensions: (u8, u8), texture: Texture) {
    let (scale_x, scale_y) = get_scale(dimensions);
    let (width, height) = (dimensions.0 as f32, dimensions.1 as f32);
    let texture = texture.load().unwrap();

    for y in 0..height as i32 {
        for x in 0..width as i32 {
            DrawCommand::texture(texture.clone())
                .position(
                    x as f32 * TILE_SIZE * scale_x,
                    y as f32 * TILE_SIZE * scale_y,
                )
                .color(WHITE)
                .dest_size(Vec2::new(TILE_SIZE * scale_x, TILE_SIZE * scale_y))
                .rotation(if x % 2 == 0 { 0.0 } else { PI })
                .z_index(ZIndex::Background)
                .schedule();
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
fn request_draw(cmd: DrawCommand) {
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
    pub fn z_index(&self) -> ZIndex {
        match self {
            DrawCommand::Texture { z_index, .. } => *z_index,
            DrawCommand::RectangleLines { z_index, .. } => *z_index,
            DrawCommand::Rectangle { z_index, .. } => *z_index,
            DrawCommand::Line { z_index, .. } => *z_index,
            DrawCommand::Text { z_index, .. } => *z_index,
        }
    }

    pub fn text(text: String) -> DrawTextBuilder {
        DrawTextBuilder::new(text)
    }

    pub fn rectangle(x: f32, y: f32, width: f32, height: f32) -> DrawRectangleBuilder {
        DrawRectangleBuilder::new()
            .position(x, y)
            .dimensions(width, height)
    }

    pub fn rectangle_lines(x: f32, y: f32, width: f32, height: f32) -> DrawRectangleLinesBuilder {
        DrawRectangleLinesBuilder::new()
            .position(x, y)
            .dimensions(width, height)
    }

    pub fn texture(texture: Rc<Texture2D>) -> DrawTextureBuilder {
        DrawTextureBuilder::new(texture)
    }

    pub fn line(x1: f32, y1: f32, x2: f32, y2: f32) -> DrawLineBuilder {
        DrawLineBuilder::new().start(x1, y1).end(x2, y2)
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
                dest_size,
                source,
                rotation,
                flip_x,
                flip_y,
                pivot,
                z_index: _,
            } => {
                draw_texture_ex(
                    &texture,
                    x,
                    y,
                    color,
                    DrawTextureParams {
                        dest_size,
                        source,
                        rotation,
                        flip_x,
                        flip_y,
                        pivot,
                    },
                );
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
            DrawCommand::Line {
                x1,
                y1,
                x2,
                y2,
                color,
                thickness,
                z_index: _,
            } => {
                draw_line(x1, y1, x2, y2, thickness, color);
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
                align,
                background,
                line_height,
                padding,
                z_index: _,
            } => {
                let max_width = text
                    .lines()
                    .map(|line| measure_text(line, Some(&font), font_size, font_scale).width as i32)
                    .max()
                    .unwrap_or(0) as f32; // eh, conversion...

                let line_height = line_height.unwrap_or(font_size as f32) * font_scale;
                let lines = text.lines().collect::<Vec<&str>>();

                if let Some(background) = background {
                    let x = match align {
                        Align::Left => x - padding.x,
                        Align::Center => x - padding.x - max_width / 2.0,
                        Align::Right => x - padding.x - max_width,
                    };

                    draw_rectangle(
                        x,
                        y - padding.y,
                        max_width + padding.x * 2.0,
                        line_height * lines.len() as f32 + padding.y * 2.0,
                        background,
                    );
                }

                text.lines().enumerate().for_each(|(i, line)| {
                    let measure = measure_text(line, Some(&font), font_size, font_scale);
                    let width = measure.width;
                    let y = y + i as f32 * line_height + (padding.y / 2.0);
                    let x = match align {
                        Align::Left => x,
                        Align::Center => x - width / 2.0,
                        Align::Right => x - (padding.x / 2.0) - width,
                    };

                    draw_text_ex(
                        line,
                        x,
                        y,
                        TextParams {
                            font: Some(&font),
                            font_size,
                            font_scale,
                            font_scale_aspect,
                            rotation,
                            color,
                        },
                    );
                });
            }
        }
    }
}

// === Builders ===

pub struct DrawTextureBuilder {
    texture: Rc<Texture2D>,
    x: Option<f32>,
    y: Option<f32>,
    color: Option<Color>,
    dest_size: Option<Vec2>,
    source: Option<Rect>,
    rotation: Option<f32>,
    flip_x: Option<bool>,
    flip_y: Option<bool>,
    pivot: Option<Vec2>,
    z_index: Option<ZIndex>,
}

impl DrawTextureBuilder {
    pub fn new(texture: Rc<Texture2D>) -> Self {
        Self {
            texture,
            x: None,
            y: None,
            color: None,
            dest_size: None,
            source: None,
            rotation: None,
            flip_x: None,
            flip_y: None,
            pivot: None,
            z_index: None,
        }
    }

    pub fn position(mut self, x: f32, y: f32) -> Self {
        self.x = Some(x);
        self.y = Some(y);
        self
    }

    pub fn color(mut self, color: Color) -> Self {
        self.color = Some(color);
        self
    }

    pub fn dest_size(mut self, dest_size: Vec2) -> Self {
        self.dest_size = Some(dest_size);
        self
    }

    pub fn source(mut self, source: Rect) -> Self {
        self.source = Some(source);
        self
    }

    pub fn rotation(mut self, rotation: f32) -> Self {
        self.rotation = Some(rotation);
        self
    }

    pub fn flip_x(mut self, flip_x: bool) -> Self {
        self.flip_x = Some(flip_x);
        self
    }

    pub fn flip_y(mut self, flip_y: bool) -> Self {
        self.flip_y = Some(flip_y);
        self
    }

    pub fn pivot(mut self, pivot: Vec2) -> Self {
        self.pivot = Some(pivot);
        self
    }

    pub fn z_index(mut self, z_index: ZIndex) -> Self {
        self.z_index = Some(z_index);
        self
    }

    pub fn build(self) -> DrawCommand {
        DrawCommand::Texture {
            texture: self.texture,
            x: self.x.unwrap_or(0.0),
            y: self.y.unwrap_or(0.0),
            color: self.color.unwrap_or(WHITE),
            dest_size: self.dest_size,
            source: self.source,
            rotation: self.rotation.unwrap_or(0.0),
            flip_x: self.flip_x.unwrap_or(false),
            flip_y: self.flip_y.unwrap_or(false),
            pivot: self.pivot,
            z_index: self.z_index.unwrap_or(ZIndex::MenuText),
        }
    }

    pub fn schedule(self) {
        self.build().schedule();
    }
}

pub struct DrawRectangleLinesBuilder {
    x: Option<f32>,
    y: Option<f32>,
    width: Option<f32>,
    height: Option<f32>,
    thickness: Option<f32>,
    color: Option<Color>,
    z_index: Option<ZIndex>,
}

impl DrawRectangleLinesBuilder {
    pub fn new() -> Self {
        Self {
            x: None,
            y: None,
            width: None,
            height: None,
            thickness: None,
            color: None,
            z_index: None,
        }
    }

    pub fn position(mut self, x: f32, y: f32) -> Self {
        self.x = Some(x);
        self.y = Some(y);
        self
    }

    pub fn dimensions(mut self, width: f32, height: f32) -> Self {
        self.width = Some(width);
        self.height = Some(height);
        self
    }

    pub fn thickness(mut self, thickness: f32) -> Self {
        self.thickness = Some(thickness);
        self
    }

    pub fn color(mut self, color: Color) -> Self {
        self.color = Some(color);
        self
    }

    pub fn z_index(mut self, z_index: ZIndex) -> Self {
        self.z_index = Some(z_index);
        self
    }

    pub fn build(self) -> DrawCommand {
        DrawCommand::RectangleLines {
            x: self.x.unwrap_or(0.0),
            y: self.y.unwrap_or(0.0),
            width: self.width.unwrap_or(0.0),
            height: self.height.unwrap_or(0.0),
            thickness: self.thickness.unwrap_or(1.0),
            color: self.color.unwrap_or(WHITE),
            z_index: self.z_index.unwrap_or(ZIndex::MenuText),
        }
    }

    pub fn schedule(self) {
        self.build().schedule();
    }
}

pub struct DrawRectangleBuilder {
    x: Option<f32>,
    y: Option<f32>,
    width: Option<f32>,
    height: Option<f32>,
    color: Option<Color>,
    z_index: Option<ZIndex>,
}

impl DrawRectangleBuilder {
    pub fn new() -> Self {
        Self {
            x: None,
            y: None,
            width: None,
            height: None,
            color: None,
            z_index: None,
        }
    }

    pub fn position(mut self, x: f32, y: f32) -> Self {
        self.x = Some(x);
        self.y = Some(y);
        self
    }

    pub fn dimensions(mut self, width: f32, height: f32) -> Self {
        self.width = Some(width);
        self.height = Some(height);
        self
    }

    pub fn width(mut self, width: f32) -> Self {
        self.width = Some(width);
        self
    }

    pub fn height(mut self, height: f32) -> Self {
        self.height = Some(height);
        self
    }

    pub fn x(mut self, x: f32) -> Self {
        self.x = Some(x);
        self
    }

    pub fn y(mut self, y: f32) -> Self {
        self.y = Some(y);
        self
    }

    pub fn color(mut self, color: Color) -> Self {
        self.color = Some(color);
        self
    }

    pub fn z_index(mut self, z_index: ZIndex) -> Self {
        self.z_index = Some(z_index);
        self
    }

    pub fn build(self) -> DrawCommand {
        DrawCommand::Rectangle {
            x: self.x.unwrap_or(0.0),
            y: self.y.unwrap_or(0.0),
            width: self.width.unwrap_or(0.0),
            height: self.height.unwrap_or(0.0),
            color: self.color.unwrap_or(WHITE),
            z_index: self.z_index.unwrap_or(ZIndex::MenuText),
        }
    }

    pub fn schedule(self) {
        self.build().schedule();
    }
}

pub struct DrawLineBuilder {
    x1: Option<f32>,
    y1: Option<f32>,
    x2: Option<f32>,
    y2: Option<f32>,
    color: Option<Color>,
    thickness: Option<f32>,
    z_index: Option<ZIndex>,
}

impl DrawLineBuilder {
    pub fn new() -> Self {
        Self {
            x1: None,
            y1: None,
            x2: None,
            y2: None,
            color: None,
            thickness: None,
            z_index: None,
        }
    }

    pub fn start(mut self, x: f32, y: f32) -> Self {
        self.x1 = Some(x);
        self.y1 = Some(y);
        self
    }

    pub fn end(mut self, x: f32, y: f32) -> Self {
        self.x2 = Some(x);
        self.y2 = Some(y);
        self
    }

    pub fn color(mut self, color: Color) -> Self {
        self.color = Some(color);
        self
    }

    pub fn thickness(mut self, thickness: f32) -> Self {
        self.thickness = Some(thickness);
        self
    }

    pub fn z_index(mut self, z_index: ZIndex) -> Self {
        self.z_index = Some(z_index);
        self
    }

    pub fn build(self) -> DrawCommand {
        DrawCommand::Line {
            x1: self.x1.unwrap_or(0.0),
            y1: self.y1.unwrap_or(0.0),
            x2: self.x2.unwrap_or(0.0),
            y2: self.y2.unwrap_or(0.0),
            color: self.color.unwrap_or(WHITE),
            thickness: self.thickness.unwrap_or(1.0),
            z_index: self.z_index.unwrap_or(ZIndex::MenuText),
        }
    }

    pub fn schedule(self) {
        self.build().schedule();
    }
}

pub struct DrawTextBuilder {
    text: String,
    x: Option<f32>,
    y: Option<f32>,
    align: Option<Align>,
    font: Option<Rc<Font>>,
    font_size: Option<u16>,
    font_scale: Option<f32>,
    font_scale_aspect: Option<f32>,
    rotation: Option<f32>,
    background: Option<Color>,
    padding: Option<Vec2>,
    line_height: Option<f32>,
    color: Option<Color>,
    z_index: Option<ZIndex>,
}

impl DrawTextBuilder {
    pub fn new(text: String) -> Self {
        Self {
            text,
            x: None,
            y: None,
            align: None,
            font: None,
            font_size: None,
            font_scale: None,
            font_scale_aspect: None,
            rotation: None,
            background: None,
            line_height: None,
            padding: None,
            color: None,
            z_index: None,
        }
    }

    pub fn align(mut self, align: Align) -> Self {
        self.align = Some(align);
        self
    }

    pub fn position(mut self, x: f32, y: f32) -> Self {
        self.x = Some(x);
        self.y = Some(y);
        self
    }

    pub fn x(mut self, x: f32) -> Self {
        self.x = Some(x);
        self
    }

    pub fn y(mut self, y: f32) -> Self {
        self.y = Some(y);
        self
    }

    pub fn font(mut self, font: Rc<Font>) -> Self {
        self.font = Some(font);
        self
    }

    pub fn font_size(mut self, font_size: u16) -> Self {
        self.font_size = Some(font_size);
        self
    }

    pub fn font_scale(mut self, font_scale: f32) -> Self {
        self.font_scale = Some(font_scale);
        self
    }

    pub fn font_scale_aspect(mut self, font_scale_aspect: f32) -> Self {
        self.font_scale_aspect = Some(font_scale_aspect);
        self
    }

    pub fn rotation(mut self, rotation: f32) -> Self {
        self.rotation = Some(rotation);
        self
    }

    pub fn color(mut self, color: Color) -> Self {
        self.color = Some(color);
        self
    }

    pub fn z_index(mut self, z_index: ZIndex) -> Self {
        self.z_index = Some(z_index);
        self
    }

    pub fn background(mut self, background: Color) -> Self {
        self.background = Some(background);
        self
    }

    pub fn padding(mut self, padding: Vec2) -> Self {
        self.padding = Some(padding);
        self
    }

    pub fn line_height(mut self, line_height: f32) -> Self {
        self.line_height = Some(line_height);
        self
    }

    pub fn build(self) -> DrawCommand {
        DrawCommand::Text {
            text: self.text,
            x: self.x.unwrap_or(0.0),
            y: self.y.unwrap_or(0.0),
            align: self.align.unwrap_or(Align::Left),
            font: self.font.unwrap_or(super::font("doto").unwrap()),
            font_size: self.font_size.unwrap_or(16),
            font_scale: self.font_scale.unwrap_or(1.0),
            font_scale_aspect: self.font_scale_aspect.unwrap_or(1.0),
            rotation: self.rotation.unwrap_or(0.0),
            color: self.color.unwrap_or(WHITE),
            background: self.background,
            line_height: self.line_height,
            padding: self.padding.unwrap_or(Vec2::new(0.0, 0.0)),
            z_index: self.z_index.unwrap_or(ZIndex::MenuText),
        }
    }

    pub fn schedule(self) {
        self.build().schedule();
    }
}
