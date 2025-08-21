// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::HashMap, rc::Rc};

use macroquad::prelude::*;
use sui_sdk_types::Address;

use crate::{
    draw::{self, ASSETS, Draw, Sprite, SpriteSheet, Texture, grid_to_world},
    game::{Animation, AnimationType, AppComponent, GameObject},
    input::InputCommand,
    types::{Direction, Game, GameMap, ID},
};

pub struct Play {
    id: ID,
    game: GameMap,
    players: Vec<Address>,
    cursor: PlayCursor,
    objects: HashMap<ID, GameObject>,
    selected_unit: Option<ID>,
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
            InputCommand::Select => {
                let pos = self.cursor.position;
                let tile = &self.game.grid[pos.0 as usize][pos.1 as usize];

                if let Some(unit) = &tile.unit {
                    self.selected_unit = Some(unit.borrow().recruit);
                    let object = self.objects.get_mut(&unit.borrow().recruit).unwrap();
                    let shadow = object.shadow.as_ref().unwrap().clone();

                    object.status_animation(Animation {
                        type_: AnimationType::StaticSprite {
                            frame: 1,
                            fps: None,
                            sprite: shadow,
                        },
                        duration: None,
                        ..Default::default()
                    });
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
            cursor: PlayCursor::new((0, 0), game.dimensions()),
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
