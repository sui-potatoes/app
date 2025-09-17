// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{
    cell::RefCell,
    collections::{HashMap, VecDeque},
    convert::TryFrom,
    fmt::Display,
    rc::Rc,
};

use macroquad::prelude::*;
use sui_sdk_types::Address;

use super::{Animation, AnimationType, GameObject};
use crate::{
    config::{MENU_FONT_SIZE as FONT_SIZE, TILE_HEIGHT, TILE_WIDTH},
    draw::{
        self, Align, Asset, Draw, DrawCommand, GridPath, Highlight, Sprite, Texture, ZIndex,
        draw_highlight, grid_to_world,
    },
    game::AppComponent,
    input::InputCommand,
    types::{Cursor, Direction, GameMap, History, ID, Map, Preset, Record, Replay, Unit},
};

/// A Player for `Replay`s. Allows playing the replay step by step.
pub struct Player {
    /// The Game Map.
    pub map: Option<GameMap>,
    /// The Replay to play.
    pub preset_id: ID,
    /// Stores unprocessed actions.
    pub records: VecDeque<ProcessedRecord>,
    /// Stores processed actions.
    pub processed_records: VecDeque<ProcessedRecord>,
    /// Stores units that have been KIA to restore them on prev_action.
    pub kia_units: Vec<Rc<RefCell<Unit>>>,
    /// Highlight the tiles that are affected by the action.
    pub highlight: Option<Highlight>,
    /// Stores units that are currently on the Map and their animations.
    pub objects: HashMap<ID, GameObject>,
    /// Just a value that allows distinguishing between units.
    pub id_counter: u8,
}

const COLOR_PLACE: Color = Color {
    r: 0.0,
    g: 200.0,
    b: 0.0,
    a: 0.2,
};

const COLOR_MOVE: Color = Color {
    r: 0.0,
    g: 0.0,
    b: 200.0,
    a: 0.2,
};

const COLOR_ATTACK: Color = Color {
    r: 200.0,
    g: 0.0,
    b: 0.0,
    a: 0.2,
};

const COLOR_RELOAD: Color = Color {
    r: 0.0,
    g: 200.0,
    b: 0.0,
    a: 0.2,
};

#[derive(Debug)]
pub enum ProcessedRecord {
    Reload((u8, u8)),
    NextTurn(u16),
    /// Stores the grid coordinates and the original directional path.
    Move(Vec<(u8, u8)>, Vec<u8>),
    Attack {
        origin: (u8, u8),
        target: (u8, u8),
        effects: Vec<Record>,
    },
    RecruitPlaced(u8, u8),
    Grenade {
        radius: u16,
        target: (u8, u8),
        effects: Vec<Record>,
    },
}

pub enum PlayerMessage {
    None,
    Exit,
}

impl AppComponent for Player {
    type Message = PlayerMessage;

    fn handle_key_press(&mut self, key: InputCommand) -> PlayerMessage {
        match key {
            InputCommand::Menu => return PlayerMessage::Exit,
            InputCommand::Right => self
                .next_action()
                .unwrap_or_else(|e| eprintln!("Error: {}", e)),
            InputCommand::Left => self
                .prev_action()
                .unwrap_or_else(|e| eprintln!("Error: {}", e)),
            _ => {}
        }
        PlayerMessage::None
    }

    fn tick(&mut self) {
        for (_id, object) in self.objects.iter_mut() {
            object.tick(get_time());
        }

        self.draw();
    }
}

impl Player {
    pub fn new(mut replay: Replay) -> Self {
        Self {
            map: None,
            records: replay.history.take_records_with_effects().into(),
            preset_id: replay.preset_id,
            processed_records: VecDeque::new(),
            kia_units: Vec::new(),
            highlight: None,
            objects: HashMap::new(),
            id_counter: 0,
        }
    }

    pub fn stop_all_animations(&mut self) {
        for (_id, object) in self.objects.iter_mut() {
            object.skip_all_animations();
            object.animation = static_unit_animation();
        }
    }

    pub fn add_preset(&mut self, preset: Preset) {
        self.map = Some(preset.map.clone().into());
    }

    pub fn next_action(&mut self) -> Result<(), anyhow::Error> {
        self.stop_all_animations();

        let action: ProcessedRecord = self
            .records
            .pop_front()
            .ok_or(anyhow::anyhow!("Replay is over"))?;

        // Take the header.
        match &action {
            ProcessedRecord::RecruitPlaced(x, y) => {
                self.highlight = Some(Highlight(vec![(*x, *y)], COLOR_PLACE));

                let tile = &mut self.map.as_mut().unwrap().grid[*x as usize][*y as usize];
                let mut unit = Unit::default();
                unit.recruit = ID(Address::from_bytes([self.id_counter; 32]).unwrap());
                tile.unit = Some(Rc::new(RefCell::new(unit)));

                let position = grid_to_world((*x, *y), self.map.as_ref().unwrap().dimensions());

                self.objects.insert(
                    unit.recruit,
                    GameObject::new(
                        position,
                        self.map.as_ref().unwrap().dimensions(),
                        static_unit_animation(),
                        Some(Sprite::Shadow.load().unwrap()),
                    ),
                );
                self.id_counter += 1;
            }
            ProcessedRecord::NextTurn(turn) => {
                self.highlight = None;
                self.map.as_mut().unwrap().turn = *turn;
            }
            ProcessedRecord::Move(coords, path) => {
                self.highlight = Some(Highlight(coords.clone(), COLOR_MOVE));

                let start = coords
                    .first()
                    .ok_or(anyhow::anyhow!("Failed to get start"))?;
                let end = coords.last().ok_or(anyhow::anyhow!("Failed to get end"))?;

                let start_tile =
                    &mut self.map.as_mut().unwrap().grid[start.0 as usize][start.1 as usize];
                let unit = start_tile
                    .unit
                    .take()
                    .ok_or(anyhow::anyhow!("Failed to get unit"))?;

                if let Some(obj) = self.objects.get_mut(&unit.borrow().recruit) {
                    let path = GridPath::from_direction_path(path.clone());
                    let mut animations = path
                        .to_path_segments(self.map.as_ref().unwrap().dimensions())
                        .into_iter()
                        .map(|segment| segment.into())
                        .collect::<Vec<_>>();

                    let mut start_animation: Animation = animations.remove(0);

                    for animation in animations {
                        start_animation.chain(animation);
                    }

                    start_animation.chain(static_unit_animation());
                    obj.animation = start_animation;
                }

                let end_tile = &mut self.map.as_mut().unwrap().grid[end.0 as usize][end.1 as usize];
                end_tile.unit = Some(unit);

                println!(
                    "Moved unit from ({}, {}) to ({}, {})",
                    start.0, start.1, end.0, end.1
                );
            }
            ProcessedRecord::Attack {
                origin: _,
                target,
                effects,
            } => {
                self.highlight = Some(Highlight(vec![*target], COLOR_ATTACK));

                let tile =
                    &mut self.map.as_mut().unwrap().grid[target.0 as usize][target.1 as usize];

                let target_unit = tile.unit.as_ref().unwrap();
                let target_obj = self.objects.get_mut(&target_unit.borrow().recruit).unwrap();

                effects
                    .iter()
                    .map(|e| Animation::status(e.to_string(), 25, RED, Some(1.0)))
                    .reduce(|mut acc, e| {
                        acc.chain(e);
                        acc
                    })
                    .map(|e| target_obj.add_status_animation("status", e));

                if let Some(Record::UnitKIA(_)) =
                    effects.iter().find(|e| matches!(e, Record::UnitKIA(_)))
                {
                    let unit = tile
                        .unit
                        .take()
                        .ok_or(anyhow::anyhow!("Failed to get unit"))?;

                    self.kia_units.push(unit);
                }
            }
            ProcessedRecord::Reload(pos) => {
                self.highlight = Some(Highlight(vec![*pos], COLOR_RELOAD));
            }
            c @ _ => {
                println!("Skipping action: {:?}", c);
            }
        }

        self.processed_records.push_back(action);

        Ok(())
    }

    pub fn prev_action(&mut self) -> Result<(), anyhow::Error> {
        if self.processed_records.len() == 0 {
            return Err(anyhow::anyhow!("Action History is empty"));
        }

        let action = self
            .processed_records
            .pop_back()
            .ok_or(anyhow::anyhow!("Failed to get previous action"))?;

        match &action {
            ProcessedRecord::RecruitPlaced(x, y) => {
                self.highlight = Some(Highlight(vec![(*x, *y)], COLOR_PLACE));

                let tile = &mut self
                    .map
                    .as_mut()
                    .ok_or(anyhow::anyhow!("Failed to get map"))?
                    .grid[*x as usize][*y as usize];

                self.objects
                    .remove(&tile.unit.as_ref().unwrap().borrow().recruit);
                tile.unit = None;
            }
            ProcessedRecord::NextTurn(turn) => {
                self.highlight = None;
                self.map
                    .as_mut()
                    .ok_or(anyhow::anyhow!("Failed to get map"))?
                    .turn = turn - 1;
            }
            ProcessedRecord::Move(coords, _) => {
                self.highlight = Some(Highlight(coords.clone(), COLOR_MOVE));

                let dimensions = self.map.as_ref().unwrap().dimensions();
                let start = coords
                    .first()
                    .ok_or(anyhow::anyhow!("Failed to get start"))?;
                let end = coords.last().ok_or(anyhow::anyhow!("Failed to get end"))?;

                let map_mut = self
                    .map
                    .as_mut()
                    .ok_or(anyhow::anyhow!("Failed to get map"))?;
                let end_tile = &mut map_mut.grid[end.0 as usize][end.1 as usize];
                let unit = end_tile
                    .unit
                    .take()
                    .ok_or(anyhow::anyhow!("Failed to get unit"))?;

                if let Some(obj) = self.objects.get_mut(&unit.borrow().recruit) {
                    obj.position = grid_to_world(*start, dimensions);
                    obj.animation = static_unit_animation();
                }

                let start_tile = &mut map_mut.grid[start.0 as usize][start.1 as usize];
                start_tile.unit = Some(unit);
            }
            ProcessedRecord::Attack {
                origin: _,
                target,
                effects,
            } => {
                self.highlight = Some(Highlight(vec![*target], COLOR_ATTACK));

                let tile =
                    &mut self.map.as_mut().unwrap().grid[target.0 as usize][target.1 as usize];

                if let Some(Record::UnitKIA(_)) =
                    effects.iter().find(|e| matches!(e, Record::UnitKIA(_)))
                {
                    tile.unit.replace(
                        self.kia_units
                            .pop()
                            .ok_or(anyhow::anyhow!("Failed to get unit"))?,
                    );
                }
            }
            ProcessedRecord::Reload(pos) => {
                self.highlight = Some(Highlight(vec![*pos], COLOR_RELOAD));
            }
            _ => {
                println!("Skipping action: {:?}", action);
            }
        }

        self.records.push_front(action);

        Ok(())
    }
}

impl Draw for Player {
    fn draw(&self) {
        if let Some(map) = &self.map {
            draw::draw_texture_background(map.dimensions(), Texture::Background);

            map.draw();

            if let Some(highlight) = &self.highlight {
                draw_highlight(highlight, map.dimensions());
            }

            let bottom = screen_height();

            // Draw the turn number, the action number in the very bottom.
            DrawCommand::text(format!("Turn: {}", map.turn))
                .position(20.0, bottom - 30.0)
                .font_size(FONT_SIZE as u16)
                .color(BLACK)
                .z_index(ZIndex::ModalText)
                .schedule();

            DrawCommand::text(format!(
                "Action: {} ({}/{})",
                self.processed_records
                    .back()
                    .unwrap_or(&ProcessedRecord::NextTurn(0))
                    .to_string(),
                self.processed_records.len(),
                self.records.len() + self.processed_records.len()
            ))
            .position(20.0, bottom - 10.0)
            .font_size(FONT_SIZE as u16)
            .color(BLACK)
            .z_index(ZIndex::ModalText)
            .schedule();

            DrawCommand::text("Arrow keys to control the Replay; Menu or Esc to exit".to_string())
                .position(screen_width() / 2.0, bottom - 10.0)
                .align(Align::Center)
                .font_size(FONT_SIZE as u16)
                .color(BLACK)
                .z_index(ZIndex::ModalText)
                .schedule();
        }
    }
}

impl History {
    pub fn len(&self) -> usize {
        self.0.len()
    }

    pub fn is_empty(&self) -> bool {
        self.0.is_empty()
    }

    /// Takes the next action from the start until the next header, modifies the original history.
    pub fn take_one_action_from_start(&mut self) -> Option<Vec<Record>> {
        if self.is_empty() {
            return None;
        }

        let position = self
            .0
            .iter()
            .enumerate()
            .position(|(i, e)| i != 0 && e.is_header());

        Some(
            if let Some(idx) = position {
                self.0.drain(0..idx)
            } else {
                self.0.drain(..)
            }
            .collect::<Vec<_>>(),
        )
    }

    pub fn take_records_with_effects(&mut self) -> Vec<ProcessedRecord> {
        let mut res = Vec::new();
        while let Some(mut records) = self.take_one_action_from_start() {
            let header = records.remove(0);
            res.push(match header {
                Record::Reload(pos) => ProcessedRecord::Reload((pos[0] as u8, pos[1] as u8)),
                Record::NextTurn(turn) => ProcessedRecord::NextTurn(turn),
                r @ Record::Move(_) => {
                    ProcessedRecord::Move(r.move_to_coords().unwrap(), r.move_path().unwrap())
                }
                Record::RecruitPlaced(x, y) => ProcessedRecord::RecruitPlaced(x as u8, y as u8),
                Record::Attack { origin, target } => ProcessedRecord::Attack {
                    origin: (origin[0] as u8, origin[1] as u8),
                    target: (target[0] as u8, target[1] as u8),
                    effects: records,
                },
                Record::Grenade(radius, x, y) => ProcessedRecord::Grenade {
                    radius: radius,
                    target: (x as u8, y as u8),
                    effects: records,
                },
                h @ _ => panic!("Invalid header: {:?}", h),
            });
        }
        res
    }
}

impl Record {
    pub fn is_header(&self) -> bool {
        match self {
            Record::Attack { .. }
            | Record::Grenade { .. }
            | Record::Move(..)
            | Record::Reload(..)
            | Record::RecruitPlaced(..)
            | Record::NextTurn(..) => true,
            _ => false,
        }
    }

    pub fn move_path(&self) -> Option<Vec<u8>> {
        if let Record::Move(path) = self {
            Some(path.clone())
        } else {
            None
        }
    }

    pub fn move_to_coords(&self) -> Option<Vec<(u8, u8)>> {
        if let Record::Move(path) = self {
            // Start position is the first two elements of the path.
            let start = (path[0] as u8, path[1] as u8);
            let mut cursor = Cursor::new(start);

            for direction in path.iter().skip(2) {
                if let Ok(direction) = Direction::try_from(*direction) {
                    cursor.move_to(direction);
                } else {
                    println!("Invalid direction: {}", direction);
                    return None;
                }
            }

            Some(cursor.into())
        } else {
            None
        }
    }
}

impl Display for ProcessedRecord {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            ProcessedRecord::NextTurn(_) => write!(f, "Next Turn"),
            ProcessedRecord::Reload(_) => write!(f, "Reload"),
            ProcessedRecord::Move(..) => write!(f, "Move"),
            ProcessedRecord::RecruitPlaced(..) => write!(f, "Place Unit"),
            ProcessedRecord::Attack { .. } => write!(f, "Attack"),
            ProcessedRecord::Grenade { .. } => write!(f, "Grenade"),
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

#[test]
fn test_history() {
    let mut history = History(vec![
        Record::NextTurn(1),
        Record::Move(vec![0, 0, 1, 4]),
        Record::RecruitPlaced(0, 0),
        Record::Attack {
            origin: vec![0, 0],
            target: vec![0, 1],
        },
        Record::Miss,
        Record::NextTurn(4),
    ]);

    let next_turn = history.take_one_action_from_start().unwrap();
    assert_eq!(next_turn.len(), 1);
    assert_eq!(next_turn[0], Record::NextTurn(1));

    let move_record = history.take_one_action_from_start().unwrap();
    assert_eq!(move_record.len(), 1);
    assert_eq!(move_record[0], Record::Move(vec![0, 0, 1, 4]));

    let recruit_record = history.take_one_action_from_start().unwrap();
    assert_eq!(recruit_record.len(), 1);
    assert_eq!(recruit_record[0], Record::RecruitPlaced(0, 0));

    let attack_record = history.take_one_action_from_start().unwrap();
    assert_eq!(attack_record.len(), 2);
    assert_eq!(
        attack_record[0],
        Record::Attack {
            origin: vec![0, 0],
            target: vec![0, 1],
        }
    );
    assert_eq!(attack_record[1], Record::Miss);

    let next_turn = history.take_one_action_from_start().unwrap();
    assert_eq!(next_turn.len(), 1);
    assert_eq!(next_turn[0], Record::NextTurn(4));

    assert!(history.is_empty());
}
