#![allow(dead_code)]

// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{cell::RefCell, collections::HashMap, rc::Rc};

use macroquad::prelude::*;

use crate::draw::{self, Draw, DrawCommand, SpriteSheet, ZIndex};

/// An in-game object which has a position and an animation. If the object is
/// static, then the animation is also static (or `idle` in some cases).
pub struct GameObject {
    /// Game dimensions, so sprite can be scaled.
    pub dimensions: (u8, u8),
    /// The position of the object.
    pub position: Vec2,
    /// The animation of the object (including static representation).
    pub animation: Animation,
    /// Optional shadow sprite.
    pub shadow: Option<Rc<SpriteSheet>>,
    /// Optional status sprite.
    pub statuses: HashMap<String, Animation>,
}

/// Animation of the object.
pub struct Animation {
    /// Optional duration of the animation in milliseconds.
    /// When not set, the animation will run indefinitely.
    pub duration: Option<f64>,
    /// Time when animation started.
    pub start_time: f64,
    /// The type of animation.
    pub type_: AnimationType,
    /// Callback to trigger on end of animation.
    pub on_end: Option<Box<dyn Fn(&mut GameObject)>>,
    // Animation to set in `GameObject` after reaching the end of the current
    // animation.
    // TODO: implement this
    pub chain: Option<Box<Animation>>,
}

pub enum AnimationType {
    Hidden,
    Static(Rc<Texture2D>),
    /// Static sprite with a single frame.
    StaticSprite {
        frame: usize,
        fps: Option<f64>,
        sprite: Rc<SpriteSheet>,
    },
    Move {
        texture: Rc<Texture2D>,
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
        sprite: Rc<SpriteSheet>,
        start_position: Vec2,
        end_position: Vec2,
        frame: usize,
        /// Frames per second.
        fps: f64,
    },
    /// Status animation. Used to display text on the object for a short time.
    /// Preferably uses `duration` field to set the duration of the animation.
    Status {
        text: String,
        font_size: u16,
        color: Color,
    },
    /// Action Point animation. Shows the number of AP the object has.
    AP {
        ap: u16,
        max_ap: u16,
        color: Color,
    },
}

impl GameObject {
    pub fn new(
        position: Vec2,
        dimensions: (u8, u8),
        animation: Animation,
        shadow: Option<Rc<SpriteSheet>>,
    ) -> Self {
        Self {
            dimensions,
            position,
            animation,
            shadow,
            statuses: HashMap::new(),
        }
    }

    /// Chain an animation to the very last animation in the chain.
    pub fn chain(&mut self, animation: Animation) {
        self.animation.chain(animation);
    }

    /// Set (or replaces) status animation with a given key.
    pub fn add_status_animation(&mut self, key: &str, animation: Animation) {
        let _ = self.statuses.remove(&key.to_string());
        self.statuses.insert(key.to_string(), animation);
    }

    /// Remove status animation with a given key.
    pub fn remove_status_animation(&mut self, key: &str) {
        let _ = self.statuses.remove(&key.to_string());
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
        let mut statuses_to_remove = vec![];
        for (key, status) in self.statuses.iter_mut() {
            if let Some(duration) = status.duration {
                if time - status.start_time > duration {
                    if let Some(chain) = status.chain.take().map(|c| {
                        let mut next_anim = *c;
                        next_anim.start_time = get_time();
                        next_anim
                    }) {
                        *status = chain;
                    } else {
                        statuses_to_remove.push(key.clone());
                    }

                    // if let Some(on_end) = status.on_end.take() {
                    //     on_end(self);
                    // }
                }
            }
        }

        // Remove statuses that have ended.
        for key in statuses_to_remove {
            self.statuses.remove(&key);
        }

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
            *frame = frames_passed as usize % sprite.frames;
        }

        // If animation is static sprite, update the frame of the sprite
        if let AnimationType::StaticSprite { frame, fps, sprite } = &mut self.animation.type_ {
            if let Some(fps) = fps {
                let time = get_time();
                let frames_passed = (time - self.animation.start_time) / *fps;
                *frame = frames_passed as usize % sprite.frames;
            }
        }

        // If it's not over yet, do what the `AnimationType` requires.
        self.draw();
    }
}

impl Animation {
    pub fn none() -> Self {
        Self {
            duration: None,
            start_time: 0.0,
            type_: AnimationType::Hidden,
            on_end: None,
            chain: None,
        }
    }

    pub fn status(text: String, font_size: u16, color: Color, duration: Option<f64>) -> Self {
        Self {
            duration,
            start_time: get_time(),
            type_: AnimationType::Status {
                text,
                font_size,
                color,
            },
            on_end: None,
            chain: None,
        }
    }

    pub fn ap(ap: u16, max_ap: u16, color: Color, duration: Option<f64>) -> Self {
        Self {
            duration,
            start_time: get_time(),
            type_: AnimationType::AP { ap, max_ap, color },
            on_end: None,
            chain: None,
        }
    }

    /// Returns the final position of the animation.
    pub fn end_position(&self) -> Option<Vec2> {
        match &self.type_ {
            AnimationType::Move { end_position, .. } => Some(*end_position),
            AnimationType::MoveSprite { end_position, .. } => Some(*end_position),
            _ => None,
        }
    }

    pub fn chain(&mut self, animation: Animation) {
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

impl Draw for GameObject {
    fn draw(&self) {
        if let Some(shadow) = &self.shadow {
            shadow.draw_frame_with_index(
                self.position.x,
                self.position.y,
                0,
                WHITE,
                self.dimensions,
                ZIndex::UnitShadow,
            );
        }

        for (_, status) in self.statuses.iter() {
            match &status.type_ {
                AnimationType::Status {
                    text,
                    font_size,
                    color,
                } => {
                    DrawCommand::text(text.clone())
                        .position(self.position.x, self.position.y)
                        .font_size(*font_size)
                        .color(*color)
                        .z_index(ZIndex::UnitStatus)
                        .schedule();
                }
                AnimationType::AP { ap, max_ap, color } => {
                    DrawCommand::text(format!("AP: {} / {}", ap, max_ap))
                        .position(self.position.x, self.position.y)
                        .font_size(20)
                        .color(*color)
                        .z_index(ZIndex::UnitStatus)
                        .schedule();
                }
                AnimationType::StaticSprite { frame, sprite, .. } => {
                    sprite.draw_frame_with_index(
                        self.position.x,
                        self.position.y,
                        *frame,
                        WHITE,
                        self.dimensions,
                        ZIndex::Unit,
                    );
                }
                _ => {}
            }
        }

        match &self.animation.type_ {
            AnimationType::Static(texture) => {
                DrawCommand::texture(texture.clone())
                    .position(self.position.x, self.position.y)
                    .color(WHITE)
                    .z_index(ZIndex::Unit)
                    .schedule();
            }
            AnimationType::Move { texture, .. } => {
                DrawCommand::texture(texture.clone())
                    .position(self.position.x, self.position.y)
                    .color(WHITE)
                    .z_index(ZIndex::Unit)
                    .schedule();
            }
            AnimationType::StaticSprite { frame, sprite, .. } => {
                sprite.draw_frame_with_index(
                    self.position.x,
                    self.position.y,
                    *frame,
                    WHITE,
                    self.dimensions,
                    ZIndex::Unit,
                );
            }
            AnimationType::MoveSprite { sprite, frame, .. } => sprite.draw_frame_with_index(
                self.position.x,
                self.position.y,
                *frame,
                WHITE,
                self.dimensions,
                ZIndex::Unit,
            ),
            // AP is only drawn as status.
            AnimationType::AP { .. } => {}
            AnimationType::Status {
                text,
                font_size,
                color,
            } => {
                println!("Drawing status animation");

                DrawCommand::text(text.clone())
                    .position(self.position.x, self.position.y)
                    .font_size(*font_size)
                    .color(*color)
                    .z_index(ZIndex::UnitStatus)
                    .schedule();
            }
            AnimationType::Hidden => {}
        }
    }
}

impl Default for Animation {
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
