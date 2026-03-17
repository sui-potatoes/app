// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use crate::{
    draw::{Asset, Sprite, grid_to_world},
    game::{Animation, AnimationType},
    types::{Cursor, Direction, Record},
};

use macroquad::{color::WHITE, prelude::Vec2};

#[derive(Debug, Clone)]
/// Representation of a `Path` on the grid.
pub struct GridPath(pub Vec<(u8, u8)>);

impl GridPath {
    /// Create a new `GridPath` from a list of coordinates. Performs validation
    /// of the path, comparing each consecutive pair of coordinates.
    pub fn new(path: Vec<(u8, u8)>) -> Self {
        assert!(path.len() > 0, "Path is empty");

        path.windows(2).for_each(|window| {
            let prev = window[0];
            let curr = window[1];

            if prev.0 != curr.0 && prev.1 != curr.1 {
                panic!(
                    "Path is invalid: ({}, {}) -> ({}, {})",
                    prev.0, prev.1, curr.0, curr.1,
                );
            }
        });

        Self(path)
    }

    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    /// Direction path is a representation of a Path as a start coordinate (
    /// first two elements) and a list of directions (rest of the elements).
    pub fn from_direction_path(path: Vec<u8>) -> Self {
        assert!(path.len() > 2, "Path is missing the start coordinate");
        let mut cursor = Cursor::new((path[0], path[1]));
        path.iter().skip(2).for_each(|dir| {
            cursor.move_to(Direction::try_from(*dir).unwrap());
        });
        Self(cursor.into())
    }

    pub fn to_direction_path(&self) -> Vec<u8> {
        if self.0.is_empty() {
            return vec![];
        }

        let start = self.0[0];
        let mut direction_path = vec![start.0, start.1];

        direction_path.extend(
            self.0
                .windows(2)
                .map(|window| {
                    let direction = Direction::from_coords(window[0], window[1]);
                    direction.into()
                })
                .collect::<Vec<u8>>(),
        );

        direction_path
    }

    pub fn to_path_segments(&self, dimensions: (u8, u8)) -> Vec<PathSegment> {
        let mut path = self.to_direction_path();
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

    pub fn to_world_path(&self) -> Vec<Vec2> {
        unimplemented!("TODO: implement as world path");
    }
}

impl TryFrom<Record> for GridPath {
    type Error = ();

    fn try_from(value: Record) -> Result<Self, Self::Error> {
        if let Record::Move(path) = value {
            Ok(GridPath::from_direction_path(path))
        } else {
            Err(())
        }
    }
}

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
                sprite: sprite.load().unwrap(),
                start_position: self.start_position,
                end_position: self.end_position,
                frame: 0,
                fps: 0.1,
                color: WHITE,
            },
            ..Default::default()
        }
    }
}
