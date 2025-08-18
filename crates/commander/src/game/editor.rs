// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use macroquad::prelude::*;

use crate::{
    draw::{ASSETS, Draw, DrawCommand, Texture, draw},
    input::Command,
    types::{Cursor, Direction, GameMap, TileType},
};

const TOOL_COUNT: usize = 5;

pub struct Editor {
    grid: GameMap,
    tool: Tool,
    mode: Mode,
    cursor: EditorCursor,
}

struct EditorCursor {
    position: (u8, u8),
    dimensions: (u8, u8),
}

/// The mode the editor is in, changed with the Tool key.
enum Mode {
    /// The default mode, where the editor is used to edit the map.
    Editor,
    /// ToolSelect(index) is the index of the tool that is selected.
    ToolSelect(usize, usize),
}

#[derive(Clone)]
/// The tool that the editor is using. Editor tracks the direction of the tool
/// used, so no need to have different variants for each direction (yet).
enum Tool {
    Wall(Direction),
    Obstacle,
    SpawnRed,
    SpawnBlue,
    Clear,
}

impl Editor {
    pub fn new(width: u8, height: u8) -> Self {
        Self {
            grid: GameMap::new(width, height),
            tool: Tool::Obstacle,
            cursor: EditorCursor::new((0, 0), (width, height)),
            mode: Mode::Editor,
        }
    }

    pub fn handle_key_press(&mut self, key: Command) {
        match self.mode {
            Mode::Editor => {
                match key {
                    Command::Up => self.cursor.move_to(Direction::Up),
                    Command::Down => self.cursor.move_to(Direction::Down),
                    Command::Left => self.cursor.move_to(Direction::Left),
                    Command::Right => self.cursor.move_to(Direction::Right),
                    Command::Tool => self.mode = Mode::ToolSelect(self.tool.clone().into(), 0),
                    Command::Select => {
                        let (x, y) = self.cursor.position;
                        let tile = &mut self.grid.grid[x as usize][y as usize];
                        match self.tool {
                            Tool::Wall(direction) => {
                                let (mut left, mut top, mut right, mut bottom) =
                                    match tile.tile_type {
                                        TileType::Cover {
                                            left,
                                            top,
                                            right,
                                            bottom,
                                        } => (left, top, right, bottom),
                                        _ => (0, 0, 0, 0),
                                    };

                                match direction {
                                    Direction::Up => top = 1,
                                    Direction::Down => bottom = 1,
                                    Direction::Left => left = 1,
                                    Direction::Right => right = 1,
                                    Direction::None => {}
                                }

                                tile.tile_type = TileType::Cover {
                                    left,
                                    top,
                                    right,
                                    bottom,
                                };
                            }
                            Tool::Obstacle => tile.tile_type = TileType::Obstacle,
                            Tool::Clear => tile.tile_type = TileType::Empty,
                            Tool::SpawnRed => {}
                            Tool::SpawnBlue => {}
                        }
                    }
                    // This is handled by the main menu, cannot be used in the Editor.
                    Command::Menu => {}
                }
            }
            Mode::ToolSelect(index, secondary_index) => match key {
                Command::Up => {
                    self.mode = Mode::ToolSelect((index + 4) % TOOL_COUNT, secondary_index)
                }
                Command::Down => {
                    self.mode = Mode::ToolSelect((index + 1) % TOOL_COUNT, secondary_index)
                }
                Command::Left => self.mode = Mode::ToolSelect(index, (secondary_index + 3) % 4),
                Command::Right => self.mode = Mode::ToolSelect(index, (secondary_index + 1) % 4),
                Command::Tool => self.mode = Mode::Editor,
                Command::Select => {
                    self.mode = Mode::Editor;
                    self.tool = match index {
                        0 => Tool::Wall(match secondary_index {
                            0 => Direction::Up,
                            1 => Direction::Down,
                            2 => Direction::Left,
                            3 => Direction::Right,
                            _ => unreachable!(),
                        }),
                        1 => Tool::Obstacle,
                        2 => Tool::SpawnRed,
                        3 => Tool::SpawnBlue,
                        4 => Tool::Clear,
                        _ => unreachable!(),
                    };
                }
                _ => {}
            },
        }
    }
}

impl Draw for Editor {
    fn draw(&self) {
        draw::draw_texture_background(self.grid.dimensions(), Texture::Background);

        self.grid.draw();
        self.cursor.draw();

        DrawCommand::text(
            format!("Tool: {}", self.tool),
            10.0,
            screen_height() - 20.0,
            20,
            BLACK,
            1,
        )
        .schedule();

        if let Mode::ToolSelect(index, secondary_index) = self.mode {
            draw::request_draw(DrawCommand::Rectangle {
                x: 0.0,
                y: 0.0,
                width: screen_width(),
                height: screen_height(),
                color: BLACK.with_alpha(0.5),
                z_index: 20,
            });

            let font = ASSETS.with(|store| store.get().unwrap().font("doto").unwrap());

            for i in 0..TOOL_COUNT {
                let color = if i == index { WHITE } else { BLACK };
                let font_size = 24;
                let text = format!("{}", {
                    let mut tool = Tool::from(i);
                    if let Tool::Wall(direction) = &mut tool {
                        *direction = match secondary_index {
                            0 => Direction::Up,
                            1 => Direction::Down,
                            2 => Direction::Left,
                            3 => Direction::Right,
                            _ => unreachable!(),
                        };
                    }

                    tool
                });
                let (width, height) = (screen_width(), screen_height());
                let dims = measure_text(&text, Some(&font), font_size, 1.0);

                let x = (width - dims.width) / 2.0;
                let y = (height + dims.height) / 2.0 + (i as f32 * 40.0) - 40.0;

                DrawCommand::text(text, x, y, font_size, color, 20).schedule();
            }
        }
    }
}

impl EditorCursor {
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

impl Draw for EditorCursor {
    fn draw(&self) {
        draw::draw_cursor(self.position, self.dimensions);
    }
}

impl Display for Tool {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Tool::Wall(direction) => write!(f, "Wall ({})", direction),
            Tool::Obstacle => write!(f, "Obstacle"),
            Tool::SpawnRed => write!(f, "Spawn Red"),
            Tool::SpawnBlue => write!(f, "Spawn Blue"),
            Tool::Clear => write!(f, "Erase"),
        }
    }
}

impl From<usize> for Tool {
    fn from(index: usize) -> Self {
        match index {
            0 => Tool::Wall(Direction::Up),
            1 => Tool::Obstacle,
            2 => Tool::SpawnRed,
            3 => Tool::SpawnBlue,
            4 => Tool::Clear,
            _ => unreachable!(),
        }
    }
}

impl Into<usize> for Tool {
    fn into(self) -> usize {
        match self {
            Tool::Wall(_) => 0,
            Tool::Obstacle => 1,
            Tool::SpawnRed => 2,
            Tool::SpawnBlue => 3,
            Tool::Clear => 4,
        }
    }
}
