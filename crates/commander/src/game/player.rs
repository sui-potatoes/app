// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::{collections::VecDeque, convert::TryFrom};

use macroquad::color::*;
use sui_types::base_types::SuiAddress;

use crate::{
    draw::{Draw, Highlight, draw_highlight},
    move_types::{Cursor, Direction, History, ID, Map, Preset, Record, Replay, Unit},
};

/// A Player for `Replay`s. Allows playing the replay step by step.
pub struct Player {
    /// The Game Map.
    pub map: Option<Map>,
    /// The Replay to play.
    pub preset_id: ID,
    /// Stores unprocessed actions.
    pub records: VecDeque<ProcessedRecord>,
    /// Stores processed actions.
    pub processed_records: VecDeque<ProcessedRecord>,
    /// Stores units that have been KIA to restore them on prev_action.
    pub kia_units: Vec<Unit>,
    /// Highlight the tiles that are affected by the action.
    pub highlight: Option<Highlight>,
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

#[derive(Debug)]
pub enum ProcessedRecord {
    Reload((u8, u8)),
    NextTurn(u16),
    Move(Vec<(u8, u8)>),
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

impl Player {
    pub fn new(mut replay: Replay) -> Self {
        Self {
            map: None,
            records: replay.history.take_records_with_effects().into(),
            preset_id: replay.preset_id,
            processed_records: VecDeque::new(),
            kia_units: Vec::new(),
            highlight: None,
        }
    }

    pub fn add_preset(&mut self, preset: Preset) {
        self.map = Some(preset.map.clone());
    }

    pub fn next_action(&mut self) -> Result<(), anyhow::Error> {
        let action: ProcessedRecord = self
            .records
            .pop_front()
            .ok_or(anyhow::anyhow!("Replay is over"))?;

        // Take the header.
        match &action {
            ProcessedRecord::RecruitPlaced(x, y) => {
                self.highlight = Some(Highlight(vec![(*x, *y)], COLOR_PLACE));

                let tile = &mut self.map.as_mut().unwrap().grid[*x as usize][*y as usize];
                tile.unit = Some(Unit::default());

                println!("Placed unit at ({}, {})", x, y);
            }
            ProcessedRecord::NextTurn(turn) => {
                self.highlight = None;
                self.map.as_mut().unwrap().turn = *turn;
            }
            ProcessedRecord::Move(coords) => {
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

                if let Some(Record::UnitKIA(_)) =
                    effects.iter().find(|e| matches!(e, Record::UnitKIA(_)))
                {
                    let unit = self
                        .map
                        .as_mut()
                        .ok_or(anyhow::anyhow!("Failed to get map"))?
                        .grid[target.0 as usize][target.1 as usize]
                        .unit
                        .take()
                        .ok_or(anyhow::anyhow!("Failed to get unit"))?;

                    self.kia_units.push(unit);
                }
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

                tile.unit = None;
            }
            ProcessedRecord::NextTurn(turn) => {
                self.highlight = None;
                self.map
                    .as_mut()
                    .ok_or(anyhow::anyhow!("Failed to get map"))?
                    .turn = turn - 1;
            }
            ProcessedRecord::Move(coords) => {
                self.highlight = Some(Highlight(coords.clone(), COLOR_MOVE));

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
                let start_tile = &mut map_mut.grid[start.0 as usize][start.1 as usize];
                start_tile.unit = Some(unit);
            }
            ProcessedRecord::Attack {
                origin: _,
                target,
                effects,
            } => {
                self.highlight = Some(Highlight(vec![*target], COLOR_ATTACK));

                if let Some(Record::UnitKIA(_)) =
                    effects.iter().find(|e| matches!(e, Record::UnitKIA(_)))
                {
                    let tile =
                        &mut self.map.as_mut().unwrap().grid[target.0 as usize][target.1 as usize];

                    tile.unit.replace(
                        self.kia_units
                            .pop()
                            .ok_or(anyhow::anyhow!("Failed to get unit"))?,
                    );
                }
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
            map.draw();

            if let Some(highlight) = &self.highlight {
                draw_highlight(highlight, (map.width(), map.height()));
            }
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
                r @ Record::Move(_) => ProcessedRecord::Move(r.move_to_coords().unwrap()),
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
