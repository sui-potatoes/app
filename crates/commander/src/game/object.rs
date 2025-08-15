#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::cell::RefCell;

use macroquad::prelude::*;

use crate::draw::{Draw, SpriteSheet};

/// An in-game object which has a position and an animation. If the object is
/// static, then the animation is also static (or `idle` in some cases).
pub struct GameObject<'a> {
    /// Game dimensions, so sprite can be scaled.
    pub dimensions: (u8, u8),
    /// The position of the object.
    pub position: Vec2,
    /// The animation of the object (including static representation).
    pub animation: Animation<'a>,
}

/// Animation of the object.
pub struct Animation<'a> {
    /// Optional duration of the animation in milliseconds.
    /// When not set, the animation will run indefinitely.
    pub duration: Option<f64>,
    /// Time when animation started.
    pub start_time: f64,
    /// The type of animation.
    pub type_: AnimationType<'a>,
    /// Callback to trigger on end of animation.
    pub on_end: Option<Box<dyn Fn(&mut GameObject)>>,
    // Animation to set in `GameObject` after reaching the end of the current
    // animation.
    // TODO: implement this
    pub chain: Option<Box<Animation<'a>>>,
}

pub enum AnimationType<'a> {
    Hidden,
    Static(RefCell<&'a Texture2D>),
    /// Static sprite with a single frame.
    StaticSprite {
        frame: usize,
        fps: Option<f64>,
        sprite: RefCell<&'a SpriteSheet>,
    },
    Move {
        texture: RefCell<&'a Texture2D>,
        /// This field may be considered duplicate to the `position` field
        /// of the `GameObject`, yet let's keep it for now. Maybe Animation
        /// system has applications beyond `GameObject`.`
        start_position: Vec2,
        end_position: Vec2,
    },
    /// Unlike `Move`, this animation is used to move and trigger frame changes
    /// in a `SpriteSheet`. Uses `SpriteSheet`'s built-in drawing method to
    /// function.
    MoveSprite {
        sprite: RefCell<&'a SpriteSheet>,
        start_position: Vec2,
        end_position: Vec2,
        frame: usize,
        /// Frames per second.
        fps: f64,
    },
}

impl<'a> GameObject<'a> {
    pub fn new(position: Vec2, dimensions: (u8, u8), animation: Animation<'a>) -> Self {
        Self {
            dimensions,
            position,
            animation,
        }
    }

    /// Chain an animation to the very last animation in the chain.
    pub fn chain(&mut self, animation: Animation<'a>) {
        self.animation.chain(animation);
    }

    pub fn skip_all_animations(&mut self) {
        if let Some(end_position) = self.animation.end_position() {
            self.position = end_position;
        }

        while let Some(chain) = self.animation.chain.take() {
            if let Some(end_position) = chain.end_position() {
                self.position = end_position;
            }

            self.animation = *chain;
        }
    }

    pub fn tick(&mut self, time: f64) {
        let animation = &self.animation;

        // Check if the time has come for the animation to end.
        // Stop it and don't do anything but the `on_end` callback.
        if let Some(duration) = animation.duration {
            if time - animation.start_time > duration {
                if let Some(on_end) = self.animation.on_end.take() {
                    on_end(self);
                }

                if let Some(mut chain) = self.animation.chain.take() {
                    chain.start_time = get_time();

                    match &mut chain.type_ {
                        AnimationType::Move { start_position, .. } => {
                            *start_position = self.position;
                        }
                        AnimationType::MoveSprite { start_position, .. } => {
                            *start_position = self.position;
                        }
                        AnimationType::StaticSprite { frame, .. } => {
                            *frame = 0;
                        }
                        _ => {}
                    }

                    self.animation = *chain;
                }

                // If condition is reached, we ignore the rest of the code.
                return;
            }
        }

        // If animation is transition, update the position of the object (to then
        // use it in the `draw` method).
        if let AnimationType::Move {
            texture: _,
            start_position,
            end_position,
        } = &self.animation.type_
        {
            let time = get_time();
            let t = (time - self.animation.start_time) / self.animation.duration.unwrap();
            let position = start_position.lerp(*end_position, t as f32);
            self.position = position;
        }

        // If animation is transition + sprite, do 2 things:
        // - update the position of the object
        // - update the frame of the sprite
        if let AnimationType::MoveSprite {
            sprite,
            start_position,
            end_position,
            frame,
            fps,
        } = &mut self.animation.type_
        {
            let time = get_time();
            let t = (time - self.animation.start_time) / self.animation.duration.unwrap();
            let position = start_position.lerp(*end_position, t as f32);
            let frames_passed = (time - self.animation.start_time) / *fps;

            self.position = position;
            *frame = frames_passed as usize % sprite.borrow().frames;
        }

        // If animation is static sprite, update the frame of the sprite
        if let AnimationType::StaticSprite { frame, fps, sprite } = &mut self.animation.type_ {
            if let Some(fps) = fps {
                let time = get_time();
                let frames_passed = (time - self.animation.start_time) / *fps;
                *frame = frames_passed as usize % sprite.borrow().frames;
            }
        }

        // If it's not over yet, do what the `AnimationType` requires.
        self.draw();
    }
}

impl<'a> Animation<'a> {
    /// Returns the final position of the animation.
    pub fn end_position(&self) -> Option<Vec2> {
        match &self.type_ {
            AnimationType::Move { end_position, .. } => Some(*end_position),
            AnimationType::MoveSprite { end_position, .. } => Some(*end_position),
            _ => None,
        }
    }

    pub fn chain(&mut self, animation: Animation<'a>) {
        let mut nested_anim_ref = &mut self.chain;

        loop {
            match nested_anim_ref {
                Some(nested_anim) => {
                    nested_anim_ref = &mut nested_anim.chain;
                }
                None => break,
            }
        }

        *nested_anim_ref = Some(Box::new(animation));
    }
}

impl<'a> Draw for GameObject<'a> {
    fn draw(&self) {
        match &self.animation.type_ {
            AnimationType::Static(texture) => {
                draw_texture_ex(
                    &texture.borrow(),
                    self.position.x,
                    self.position.y,
                    WHITE,
                    DrawTextureParams::default(),
                );
            }
            AnimationType::Move { texture, .. } => {
                draw_texture_ex(
                    &texture.borrow(),
                    self.position.x,
                    self.position.y,
                    WHITE,
                    DrawTextureParams::default(),
                );
            }
            AnimationType::StaticSprite { frame, sprite, .. } => {
                sprite.borrow().draw_frame(
                    self.position.x,
                    self.position.y,
                    *frame,
                    self.dimensions,
                );
            }
            AnimationType::MoveSprite { sprite, frame, .. } => sprite.borrow().draw_frame(
                self.position.x,
                self.position.y,
                *frame,
                self.dimensions,
            ),
            AnimationType::Hidden => {}
        }
    }
}

impl<'a> Default for Animation<'a> {
    fn default() -> Self {
        Self {
            duration: None,
            start_time: 0.0,
            type_: AnimationType::Hidden,
            on_end: None,
            chain: None,
        }
    }
}
