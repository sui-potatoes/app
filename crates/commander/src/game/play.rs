// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{cell::RefCell, collections::HashMap, fmt::Display, rc::Rc};

use macroquad::prelude::*;
use sui_sdk_types::Address;

use crate::{
    draw::{
        self, Align, Asset, Draw, DrawCommand, Highlight, Sprite, SpriteSheet, Texture, ZIndex,
        grid_to_world,
    },
    game::{Animation, AnimationType, AppComponent, GameObject, Selectable},
    input::InputCommand,
    types::{Direction, Game, GameMap, GridPath, History, ID, Param, Preset, Target, Unit},
};

pub struct Play {
    id: ID,
    mode: Mode,
    action_mode: ActionMode,
    game: GameMap,
    players: Vec<Address>,
    cursor: PlayCursor,
    highlight: Option<Highlight>,
    objects: HashMap<ID, GameObject>,
    selected_unit: Option<Rc<RefCell<Unit>>>,
    pub test_preset: Option<Preset>,
}

pub enum Mode {
    Play,
    Menu(PlayMenu),
}

#[derive(Clone)]
pub struct PlayMenu {
    items: Vec<PlayMenuItem>,
    selected_item: usize,
}

#[derive(Clone)]
pub enum PlayMenuItem {
    NextTurn,
    QuitGame,
    BackToEditor,
    Exit,
}

pub enum PlayMessage {
    None,
    /// Perform a Move action.
    Move(GridPath),
    Attack(Vec2, Vec2),
    BackToEditor,
    NextTurn,
    QuitGame,
    Exit,
}

#[derive(Debug)]
enum ActionMode {
    Walk,
    Shoot,
}

struct PlayCursor {
    position: (u8, u8),
    dimensions: (u8, u8),
}

impl AppComponent for Play {
    type Message = PlayMessage;

    fn handle_key_press(&mut self, key: InputCommand) -> PlayMessage {
        match &mut self.mode {
            // Menu handling.
            Mode::Menu(menu) => match key {
                InputCommand::Menu => self.mode = Mode::Play,
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Select => {
                    return match menu.selected_item() {
                        PlayMenuItem::NextTurn => {
                            self.mode = Mode::Play;
                            self.game.next_turn(self.test_preset.is_some());
                            PlayMessage::NextTurn
                        }
                        PlayMenuItem::BackToEditor => PlayMessage::BackToEditor,
                        PlayMenuItem::QuitGame => PlayMessage::QuitGame,
                        PlayMenuItem::Exit => PlayMessage::Exit,
                    };
                }
                _ => {}
            },
            // Play handling.
            Mode::Play => match key {
                InputCommand::Action => {} // no action yet
                InputCommand::Menu => {
                    if let Some(_preset) = &self.test_preset {
                        self.mode = Mode::Menu(PlayMenu::new_test_preset())
                    } else {
                        self.mode = Mode::Menu(PlayMenu::new())
                    }
                }
                InputCommand::Up => self.cursor.move_to(Direction::Up),
                InputCommand::Down => self.cursor.move_to(Direction::Down),
                InputCommand::Left => self.cursor.move_to(Direction::Left),
                InputCommand::Right => self.cursor.move_to(Direction::Right),
                InputCommand::Back => {
                    self.deselect_unit();
                    self.action_mode = ActionMode::Walk;
                }
                InputCommand::Select => {
                    let pos = self.cursor.position;

                    if self.selected_unit.is_none() {
                        self.select_unit(pos);
                        self.action_mode = ActionMode::Walk;

                        if let Some(unit) = &self.selected_unit {
                            let distance = unit.borrow().stats;
                            let tiles = self.game.walkable_tiles(pos, distance.mobility() as u8);
                            self.highlight = Some(Highlight(tiles, BLUE.with_alpha(0.2)));
                        }
                    } else {
                        match self.action_mode {
                            ActionMode::Walk => {
                                let unit_pos = self
                                    .game
                                    .unit_position(&self.selected_unit.as_ref().unwrap().borrow())
                                    .unwrap();

                                if let Some(path) =
                                    self.game.trace_path(unit_pos, self.cursor.position)
                                {
                                    if path.len() > 1 {
                                        let path = GridPath::new(path);
                                        self.move_selected_unit(path.clone());
                                        self.deselect_unit();
                                        return PlayMessage::Move(path);
                                    }
                                }
                            }
                            ActionMode::Shoot => {}
                        }
                    }
                }
                InputCommand::Tool => match self.action_mode.next() {
                    ActionMode::Walk => {
                        self.highlight = None;
                        if let Some(unit) = &self.selected_unit {
                            let distance = unit.borrow().stats;
                            let unit_pos = self.game.unit_position(&unit.borrow()).unwrap();
                            let tiles = self
                                .game
                                .walkable_tiles(unit_pos, distance.mobility() as u8);

                            self.game.targets(unit_pos).iter().for_each(|t| {
                                self.objects
                                    .get_mut(&t.target_id)
                                    .map(|o| o.remove_status_animation("hit_chance"));
                            });
                            self.highlight = Some(Highlight(tiles, BLUE.with_alpha(0.2)));
                        }
                    }
                    ActionMode::Shoot => {
                        self.highlight = None;
                        if let Some(unit) = &self.selected_unit {
                            let unit_pos = self.game.unit_position(&unit.borrow()).unwrap();
                            let targets = self.game.targets(unit_pos);

                            targets.iter().for_each(|t| {
                                if let Some(chance) = t.chance {
                                    if let Some(object) = self.objects.get_mut(&t.target_id) {
                                        object.add_status_animation(
                                            "hit_chance",
                                            Animation::status(
                                                format!("Hit chance: {}", chance),
                                                24,
                                                RED,
                                                None,
                                            ),
                                        );
                                    }
                                }
                            });

                            self.highlight = Some(Highlight(
                                targets.into_iter().map(|t| t.position).collect::<Vec<_>>(),
                                RED.with_alpha(0.2),
                            ));
                        }
                    }
                },
            },
        }

        PlayMessage::None
    }

    fn tick(&mut self) {
        let units = self.units();
        // let turn = self.game.turn;

        for (id, object) in self.objects.iter_mut() {
            if let Some(unit) = units.iter().find(|u| u.borrow().recruit == *id) {
                let unit = unit.borrow();

                object.remove_status_animation("ap");
                object.add_status_animation(
                    "ap",
                    Animation::ap(unit.ap.value(), unit.ap.max_value(), BLUE, None),
                );

                object.remove_status_animation("hp");
                object.add_status_animation(
                    "hp",
                    Animation::hp(unit.hp.value(), unit.hp.max_value(), RED, None),
                );
            }

            object.tick(get_time());
        }

        if let Mode::Menu(menu) = &mut self.mode {
            menu.draw();
        }

        self.draw();
    }
}

impl Play {
    fn units(&self) -> Vec<Rc<RefCell<Unit>>> {
        let mut units = Vec::new();
        for (_i, row) in self.game.grid.iter().enumerate() {
            for (_j, tile) in row.iter().enumerate() {
                if let Some(unit) = &tile.unit {
                    units.push(unit.clone());
                }
            }
        }
        units
    }

    fn deselect_unit(&mut self) {
        if let Some(unit) = &self.selected_unit {
            let object = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            object.add_status_animation("shadow", Animation::none());
            self.selected_unit = None;
            self.highlight = None;
        }
    }

    fn select_unit(&mut self, pos: (u8, u8)) -> Option<Rc<RefCell<Unit>>> {
        self.deselect_unit();

        let tile = &self.game.grid[pos.0 as usize][pos.1 as usize];
        if let Some(unit) = &tile.unit {
            self.selected_unit = Some(unit.clone());
            let object = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            let shadow = object.shadow.as_ref().unwrap().clone();

            object.add_status_animation(
                "shadow",
                Animation {
                    type_: AnimationType::StaticSprite {
                        frame: 2,
                        fps: None,
                        sprite: shadow,
                    },
                    duration: None,
                    ..Default::default()
                },
            );

            Some(unit.clone())
        } else {
            None
        }
    }

    fn move_selected_unit(&mut self, grid_path: GridPath) {
        if grid_path.is_empty() {
            return;
        }

        if let Some(unit) = &mut self.selected_unit {
            assert!(
                self.game
                    .unit_position(&unit.borrow())
                    .is_some_and(|pos| pos == grid_path.0[0])
            );

            if unit.borrow().ap.value() == 0 {
                return println!("No AP left");
            }

            unit.borrow_mut().ap.decrease(1);

            // Move the unit on the Map.
            {
                let first = *grid_path.0.first().unwrap();
                let last = *grid_path.0.last().unwrap();
                let unit_rc = self.game.grid[first.0 as usize][first.1 as usize]
                    .unit
                    .take()
                    .unwrap();
                self.game.grid[last.0 as usize][last.1 as usize]
                    .unit
                    .replace(unit_rc);
            };

            let obj = self.objects.get_mut(&unit.borrow().recruit).unwrap();
            let mut animations = grid_path
                .to_path_segments(self.game.dimensions())
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
                            Some(Sprite::Shadow.load().unwrap()),
                        ),
                    );
                }
            }
        }

        Self {
            id,
            mode: Mode::Play,
            action_mode: ActionMode::Walk,
            cursor: PlayCursor::new((0, 0), game.dimensions()),
            highlight: None,
            objects,
            players,
            game,
            selected_unit: None,
            test_preset: None,
        }
    }
}

impl From<Preset> for Game {
    fn from(value: Preset) -> Self {
        let Preset {
            id,
            mut map,
            positions,
            ..
        } = value;

        for (i, pos) in positions.iter().enumerate() {
            map.grid[pos[0] as usize][pos[1] as usize].unit = Some(Unit {
                recruit: ID(Address::from_hex(format!("0x{}", i)).unwrap()),
                ..Default::default()
            });
        }

        Game {
            id,
            map: map.into(),
            players: vec![],
            positions: positions.clone(),
            history: History(vec![]),
            recruits: (Address::ZERO, 0),
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

        draw::DrawCommand::text(format!(
            "Mode: {}\nUnit: {}",
            self.action_mode,
            self.selected_unit.is_some()
        ))
        .position(screen_width() / 2.0, screen_height() - 40.0 - 20.0)
        .background(BLACK.with_alpha(0.5))
        .align(Align::Center)
        .font_size(20)
        .padding(Vec2::new(40.0, 20.0))
        .schedule();

        if let Some(unit) = &self.selected_unit {
            if unit.borrow().ap.value() == 0 {
                return;
            }

            if let Some(highlight) = &self.highlight {
                draw::draw_highlight(highlight, self.game.dimensions());
            }

            if matches!(self.action_mode, ActionMode::Walk) {
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

impl Draw for PlayMenu {
    fn draw(&self) {
        let width = screen_width();
        let height = screen_height();
        let line_height = 44.0;

        DrawCommand::text("Play Menu".to_string())
            .position(width / 2.0, height / 4.0 + 64.0)
            .font_size(32)
            .color(WHITE)
            .align(Align::Center)
            .z_index(ZIndex::ModalText)
            .schedule();

        DrawCommand::rectangle(width / 4.0, height / 4.0, width / 2.0, height / 2.0)
            .color(BLACK.with_alpha(0.8))
            .z_index(ZIndex::ModalBackground)
            .schedule();

        for (i, item) in self.items.iter().enumerate() {
            let color = if i == self.selected_item { WHITE } else { GRAY };

            DrawCommand::text(item.to_string())
                .position(width / 2.0, height / 4.0 + 200.0 + (i as f32 * line_height))
                .font_size(32)
                .color(color)
                .align(Align::Center)
                .z_index(ZIndex::MenuText)
                .schedule();
        }
    }
}

impl PlayMenu {
    pub fn new() -> Self {
        Self {
            items: vec![
                PlayMenuItem::NextTurn,
                PlayMenuItem::QuitGame,
                PlayMenuItem::Exit,
            ],
            selected_item: 0,
        }
    }

    pub fn new_test_preset() -> Self {
        Self {
            items: vec![
                PlayMenuItem::NextTurn,
                PlayMenuItem::BackToEditor,
                PlayMenuItem::Exit,
            ],
            selected_item: 0,
        }
    }
}

impl Selectable for PlayMenu {
    type Item = PlayMenuItem;

    fn next_item(&mut self) {
        self.selected_item = (self.selected_item + 1) % self.items.len();
    }

    fn previous_item(&mut self) {
        self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len();
    }

    fn selected_item(&self) -> &PlayMenuItem {
        &self.items[self.selected_item]
    }
}

impl ActionMode {
    pub fn next(&mut self) -> &Self {
        match self {
            ActionMode::Walk => *self = ActionMode::Shoot,
            ActionMode::Shoot => *self = ActionMode::Walk,
        };
        self
    }
}

impl Default for ActionMode {
    fn default() -> Self {
        ActionMode::Walk
    }
}

impl Display for ActionMode {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ActionMode::Walk => write!(f, "Walk"),
            ActionMode::Shoot => write!(f, "Shoot"),
        }
    }
}

impl Display for PlayMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            PlayMenuItem::NextTurn => write!(f, "Next Turn"),
            PlayMenuItem::QuitGame => write!(f, "Quit Game"),
            PlayMenuItem::BackToEditor => write!(f, "Back to Editor"),
            PlayMenuItem::Exit => write!(f, "Back to Main Menu"),
        }
    }
}

fn static_unit_animation() -> Animation {
    Animation {
        type_: AnimationType::StaticSprite {
            sprite: Sprite::SoldierIdle.load().unwrap(),
            frame: 0,
            fps: Some(0.2),
        },
        ..Default::default()
    }
}
