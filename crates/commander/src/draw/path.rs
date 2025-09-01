// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::{
    draw::{ASSETS, Sprite, grid_to_world},
    game::{Animation, AnimationType},
    types::{Cursor, Direction},
};

use macroquad::prelude::Vec2;

#[derive(Debug)]
pub struct PathSegment {
    direction: Direction,
    start_position: Vec2,
    end_position: Vec2,
    length: usize,
}

/// Converts a `PathSegment` into an `Animation` that moves the unit along the
/// segment.
impl Into<Animation> for PathSegment {
    fn into(self) -> Animation {
        let sprite = match self.direction {
            Direction::Up => Sprite::SoldierRunUp,
            Direction::Down => Sprite::SoldierRunDown,
            Direction::Left => Sprite::SoldierRunLeft,
            Direction::Right => Sprite::SoldierRunRight,
            _ => Sprite::SoldierIdle,
        };

        Animation {
            duration: Some(self.length as f64 / 2.0),
            type_: AnimationType::MoveSprite {
                sprite: ASSETS
                    .with(|assets| assets.get().unwrap().sprite_sheet(sprite).unwrap())
                    .clone(),
                start_position: self.start_position,
                end_position: self.end_position,
                frame: 0,
                fps: 0.1,
            },
            ..Default::default()
        }
    }
}

/// Splits the path into sections where only one coordinate changes.
pub fn direction_path_to_path_segments(
    mut path: Vec<u8>,
    dimensions: (u8, u8),
) -> Vec<PathSegment> {
    let start = (path.remove(0), path.remove(0));
    let start_position = grid_to_world(start, dimensions);
    let mut segments: Vec<PathSegment> = Vec::new();

    // TODO: check if path can be empty.
    if path.len() == 0 {
        return vec![PathSegment {
            direction: Direction::None,
            start_position: grid_to_world(start, dimensions),
            end_position: grid_to_world(start, dimensions),
            length: 0,
        }];
    }

    let mut cursor = Cursor::new(start);
    let mut curr_direction = Direction::None;

    for dir in path {
        let direction = Direction::try_from(dir).unwrap();
        if direction != curr_direction {
            segments.push(PathSegment {
                direction: curr_direction,
                start_position: segments
                    .last()
                    .map(|e| e.end_position)
                    .unwrap_or(start_position),
                end_position: grid_to_world(cursor.position, dimensions),
                length: cursor.history.len(),
            });
            curr_direction = direction;
            cursor.reset(cursor.position);
        }
        cursor.move_to(direction);
    }

    // Push the last direction.
    segments.push(PathSegment {
        direction: curr_direction,
        start_position: segments.last().unwrap().end_position,
        end_position: grid_to_world(cursor.position, dimensions),
        length: cursor.history.len(),
    });

    segments
}

pub fn grid_path_to_direction_path(path: Vec<(u8, u8)>) -> Vec<u8> {
    if path.is_empty() {
        return vec![];
    }

    let start = path[0];
    let mut direction_path = vec![start.0, start.1];

    direction_path.extend(
        path.windows(2)
            .map(|window| {
                let direction = Direction::from_coords(window[0], window[1]);
                direction.into()
            })
            .collect::<Vec<u8>>(),
    );

    direction_path
}
