// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{cell::RefCell, collections::HashMap, rc::Rc};

use macroquad::prelude::*;
use sui_sdk_types::Address;

use crate::{
    draw::{
        self, ASSETS, Draw, Highlight, Sprite, SpriteSheet, Texture,
        direction_path_to_path_segments, grid_path_to_direction_path, grid_to_world,
    },
    game::{Animation, AnimationType, AppComponent, GameObject},
    input::InputCommand,
    types::{Direction, Game, GameMap, ID, Unit},
};

pub struct Play {
    id: ID,
    mode: Mode,
    game: GameMap,
    players: Vec<Address>,
    cursor: PlayCursor,
    highlight: Option<Highlight>,
    objects: HashMap<ID, GameObject>,
    selected_unit: Option<Rc<RefCell<Unit>>>,
}

enum Mode {
    Walk,
}

struct PlayCursor {
    position: (u8, u8),
    dimensions: (u8, u8),
}

impl AppComponent for Play {
    fn handle_key_press(&mut self, key: InputCommand) -> bool {
        match key {
            InputCommand::Menu => return true,
            InputCommand::Up => self.cursor.move_to(Direction::Up),
            InputCommand::Down => self.cursor.move_to(Direction::Down),
            InputCommand::Left => self.cursor.move_to(Direction::Left),
            InputCommand::Right => self.cursor.move_to(Direction::Right),
            InputCommand::Back => {
                self.deselect_unit();
                self.mode = Mode::Walk;
            }
            InputCommand::Select => {
                let pos = self.cursor.position;

                if self.selected_unit.is_some() && matches!(self.mode, Mode::Walk) {
                    let unit_pos = self
                        .game
                        .unit_position(&self.selected_unit.as_ref().unwrap().borrow())
                        .unwrap();

                    if let Some(path) = self.game.trace_path(unit_pos, self.cursor.position) {
                        if path.len() > 1 {
                            self.move_selected_unit(path);
                            self.deselect_unit();
                        }
                    }
                } else {
                    self.select_unit(pos);
                    self.mode = Mode::Walk;

                    if let Some(unit) = &self.selected_unit {
                        let distance = unit.borrow().stats;
                        let tiles = self.game.walkable_tiles(pos, distance.mobility() as u8);
                        self.highlight = Some(Highlight(tiles, BLUE.with_alpha(0.2)));
                    }
                }
            }
            InputCommand::Tool => {}
        }

        false
    }

    fn tick(&mut self) {
        for (_id, object) in self.objects.iter_mut() {
            object.tick(get_time());
        }

        self.draw();
    }
}

impl Play {
    fn deselect_unit(&mut self) {
        if let Some(unit) = &self.selected_unit {
            let object = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            object.status_animation(Animation::none());
            self.selected_unit = None;
            self.highlight = None;
        }
    }

    fn select_unit(&mut self, pos: (u8, u8)) {
        self.deselect_unit();

        let tile = &self.game.grid[pos.0 as usize][pos.1 as usize];
        if let Some(unit) = &tile.unit {
            self.selected_unit = Some(unit.clone());
            let object = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            let shadow = object.shadow.as_ref().unwrap().clone();

            object.status_animation(Animation {
                type_: AnimationType::StaticSprite {
                    frame: 2,
                    fps: None,
                    sprite: shadow,
                },
                duration: None,
                ..Default::default()
            });
        }
    }

    fn move_selected_unit(&mut self, grid_path: Vec<(u8, u8)>) {
        if grid_path.is_empty() {
            return;
        }

        if let Some(unit) = &self.selected_unit {
            assert!(
                self.game
                    .unit_position(&unit.borrow())
                    .is_some_and(|pos| pos == grid_path[0])
            );

            // Move the unit on the Map.
            {
                let first = *grid_path.first().unwrap();
                let last = *grid_path.last().unwrap();
                let unit_rc = self.game.grid[first.0 as usize][first.1 as usize]
                    .unit
                    .take()
                    .unwrap();
                self.game.grid[last.0 as usize][last.1 as usize]
                    .unit
                    .replace(unit_rc);
            };

            let obj = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            let direction_path = grid_path_to_direction_path(grid_path);
            let path_segments =
                direction_path_to_path_segments(direction_path, self.game.dimensions());

            let mut animations = path_segments
                .into_iter()
                .map(|segment| segment.into())
                .collect::<Vec<_>>();

            let start_animation: Animation = animations.remove(0);
            let mut animation =
                animations
                    .into_iter()
                    .fold(start_animation, |mut acc, animation| {
                        acc.chain(animation);
                        acc
                    });

            animation.chain(static_unit_animation());

            obj.animation = animation;
        }
    }
}

impl From<Game> for Play {
    fn from(value: Game) -> Self {
        let Game {
            id,
            map,
            players,
            positions: _,
            history: _,
            recruits: _,
        } = value;

        let game: GameMap = map.into();
        let mut objects = HashMap::new();

        for (x, row) in game.grid.iter().enumerate() {
            for (y, col) in row.iter().enumerate() {
                if let Some(unit) = &col.unit {
                    let unit = unit.borrow();
                    let position = grid_to_world((x as u8, y as u8), game.dimensions());
                    objects.insert(
                        unit.recruit,
                        GameObject::new(
                            position,
                            game.dimensions(),
                            static_unit_animation(),
                            Some(shadow()),
                        ),
                    );
                }
            }
        }

        Self {
            id,
            mode: Mode::Walk,
            cursor: PlayCursor::new((0, 0), game.dimensions()),
            highlight: None,
            objects,
            players,
            game,
            selected_unit: None,
        }
    }
}

impl PlayCursor {
    pub fn new(position: (u8, u8), dimensions: (u8, u8)) -> Self {
        Self {
            position,
            dimensions,
        }
    }

    /// Move the cursor to the given direction. Instead of overflowing, it
    /// jumps to the other side of the grid (allowing infinite scrolling within
    /// bounds).
    pub fn move_to(&mut self, direction: Direction) {
        let pos = self.position;
        let dim = self.dimensions;

        match direction {
            Direction::Up => self.position.0 = (pos.0 + dim.0 - 1) % dim.0,
            Direction::Down => self.position.0 = (pos.0 + 1) % dim.0,
            Direction::Left => self.position.1 = (pos.1 + dim.1 - 1) % dim.1,
            Direction::Right => self.position.1 = (pos.1 + 1) % dim.1,
            Direction::None => {}
        }
    }
}

impl Draw for PlayCursor {
    fn draw(&self) {
        draw::draw_cursor(self.position, self.dimensions);
    }
}

impl Draw for Play {
    fn draw(&self) {
        draw::draw_texture_background(self.game.dimensions(), Texture::Background);
        self.game.draw();
        self.cursor.draw();

        if let Some(highlight) = &self.highlight {
            draw::draw_highlight(highlight, self.game.dimensions());
        }

        if let Some(unit) = &self.selected_unit {
            if matches!(self.mode, Mode::Walk) {
                if let Some(unit_position) = self.game.unit_position(&unit.borrow()) {
                    if let Some(path_to_cursor) =
                        self.game.trace_path(unit_position, self.cursor.position)
                    {
                        draw::draw_path(&path_to_cursor, self.game.dimensions());
                    }
                }
            }
        }
    }
}

fn shadow() -> Rc<SpriteSheet> {
    ASSETS
        .with(|assets| assets.get().unwrap().sprite_sheet(Sprite::Shadow).unwrap())
        .clone()
}

fn static_unit_animation() -> Animation {
    Animation {
        type_: AnimationType::StaticSprite {
            sprite: ASSETS
                .with(|assets| {
                    assets
                        .get()
                        .unwrap()
                        .sprite_sheet(Sprite::SoldierIdle)
                        .unwrap()
                })
                .clone(),
            frame: 0,
            fps: Some(0.2),
        },
        ..Default::default()
    }
}
