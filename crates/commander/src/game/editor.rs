// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

use std::fmt::Display;

use macroquad::prelude::*;
use quad_storage::STORAGE;
use sui_sdk_types::Address;

use crate::{
    config::{TILE_HEIGHT, TILE_WIDTH},
    draw::{
        Align, Asset, Draw, DrawCommand, Sprite, Texture, ZIndex, draw, font, get_scale,
        grid_to_world,
    },
    game::Selectable,
    input::InputCommand,
    types::{Cursor, Direction, GameMap, ID, Map, Preset, TileType},
};

const EDITOR_GRID_KEY: &str = "editor_state";

#[derive(Clone)]
pub struct Editor {
    grid: GameMap,
    tool: Tool,
    mode: Mode,
    cursor: EditorCursor,
    spawns: Vec<(u8, u8)>,
}

#[derive(Clone)]
struct EditorCursor {
    position: (u8, u8),
    dimensions: (u8, u8),
}

#[derive(Clone)]
/// The mode the editor is in, changed with the Tool key.
enum Mode {
    /// The default mode, where the editor is used to edit the map.
    Editor,
    /// The menu mode, where the user can save the preset, exit or reset the map.
    Menu(EditorMenu),
}

#[derive(Clone)]
struct EditorMenu {
    items: Vec<EditorMenuItem>,
    selected_item: usize,
}

#[derive(Clone)]
enum EditorMenuItem {
    UploadPreset,
    Reset,
    Exit,
}

#[derive(Clone)]
/// The tool that the editor is using. Editor tracks the direction of the tool
/// used, so no need to have different variants for each direction (yet).
enum Tool {
    Wall(Direction),
    Obstacle,
    Spawn,
}

pub enum EditorMessage {
    Play(Preset),
    Exit,
    None,
}

impl Editor {
    pub fn new(width: u8, height: u8) -> Self {
        if let Some(grid) = STORAGE.lock().unwrap().get(EDITOR_GRID_KEY) {
            Self::from(serde_json::from_str::<Preset>(&grid).unwrap())
        } else {
            Self {
                grid: GameMap::new(width, height),
                tool: Tool::Obstacle,
                cursor: EditorCursor::new((0, 0), (width, height)),
                mode: Mode::Editor,
                spawns: vec![],
            }
        }
    }

    pub fn handle_key_press(&mut self, key: InputCommand) -> EditorMessage {
        match &mut self.mode {
            Mode::Editor => match key {
                InputCommand::Up => self.cursor.move_to(Direction::Up),
                InputCommand::Down => self.cursor.move_to(Direction::Down),
                InputCommand::Left => self.cursor.move_to(Direction::Left),
                InputCommand::Right => self.cursor.move_to(Direction::Right),
                InputCommand::Tool => match self.tool {
                    Tool::Obstacle => self.tool = Tool::Wall(Direction::Up),
                    Tool::Wall(_) => self.tool = Tool::Spawn,
                    Tool::Spawn => self.tool = Tool::Obstacle,
                },
                InputCommand::Action => {
                    if let Tool::Wall(direction) = &mut self.tool {
                        direction.rotate();
                    }
                }
                InputCommand::Back => {
                    // Erase the tile on `O` press
                    let (x, y) = self.cursor.position;
                    let tile = &mut self.grid.grid[x as usize][y as usize];
                    tile.tile_type = TileType::Empty;
                    return EditorMessage::None;
                }
                InputCommand::Select => {
                    let (x, y) = self.cursor.position;
                    let tile = &mut self.grid.grid[x as usize][y as usize];
                    match self.tool {
                        Tool::Wall(direction) => {
                            let (mut left, mut top, mut right, mut bottom) = match tile.tile_type {
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
                        Tool::Obstacle => {
                            self.spawns.retain(|&spawn| spawn != (x, y));
                            tile.tile_type = TileType::Obstacle;
                        }
                        Tool::Spawn => {
                            let (x, y) = self.cursor.position;
                            if self.spawns.contains(&(x, y)) {
                                self.spawns.retain(|&spawn| spawn != (x, y));
                            } else {
                                self.spawns.push((x, y));
                            }
                        }
                    }
                }
                // This is handled by the main menu, cannot be used in the Editor.
                InputCommand::Menu => self.mode = Mode::Menu(EditorMenu::new()),
            },
            Mode::Menu(menu) => match key {
                InputCommand::Menu => self.mode = Mode::Editor,
                InputCommand::Up => menu.previous_item(),
                InputCommand::Down => menu.next_item(),
                InputCommand::Select => match menu.selected_item() {
                    EditorMenuItem::UploadPreset => {
                        STORAGE.lock().unwrap().set(
                            EDITOR_GRID_KEY,
                            &serde_json::to_string(&Preset::from(self.clone().into())).unwrap(),
                        );
                        return EditorMessage::Play(Preset::from(self.clone().into()));
                    }
                    EditorMenuItem::Reset => {
                        let (width, height) = self.grid.dimensions();
                        self.grid = GameMap::new(width, height);
                        self.mode = Mode::Editor;
                    }
                    // EditorMenuItem::Play => {}
                    // Exit the editor.
                    EditorMenuItem::Exit => {
                        STORAGE.lock().unwrap().set(
                            EDITOR_GRID_KEY,
                            &serde_json::to_string(&Preset::from(self.clone().into())).unwrap(),
                        );
                        return EditorMessage::Exit;
                    }
                },
                key @ _ => menu.handle_key_press(key),
            },
        }

        EditorMessage::None
    }
}

impl Draw for Editor {
    fn draw(&self) {
        draw::draw_texture_background(self.grid.dimensions(), Texture::Background);

        self.grid.draw();
        self.cursor.draw();

        DrawCommand::text(format!("Tool: {}", self.tool))
            .position(10.0, screen_height() - 20.0)
            .font_size(20)
            .color(BLACK)
            .z_index(ZIndex::ModalText)
            .schedule();

        for grid_point in self.spawns.clone() {
            let pos = grid_to_world(grid_point, self.grid.dimensions());
            let sprite = Sprite::Shadow.load().unwrap();
            sprite
                .draw_frame_with_index(
                    pos.x,
                    pos.y,
                    0,
                    WHITE,
                    self.grid.dimensions(),
                    ZIndex::UnitShadow,
                )
                .schedule();
        }

        match &self.mode {
            Mode::Menu(menu) => menu.draw(),
            // Draw semi-transparent tool at position of the cursor.
            Mode::Editor => match self.tool {
                Tool::Obstacle => {
                    let pos = self.cursor.absolute_position();
                    let texture = Texture::Obstacle.load().unwrap();
                    DrawCommand::texture(texture)
                        .position(pos.x, pos.y)
                        .dest_size(self.cursor.size())
                        .color(WHITE.with_alpha(0.5))
                        .schedule();
                }
                Tool::Wall(direction) => {
                    let pos = self.cursor.absolute_position();
                    let sprite = Sprite::WallSnow.load().unwrap();
                    let frame = match direction {
                        Direction::Left => 0,
                        Direction::Up => 1,
                        Direction::Right => 2,
                        Direction::Down => 3,
                        Direction::None => 0,
                    };

                    sprite
                        .draw_frame_with_index(
                            pos.x,
                            pos.y,
                            frame,
                            WHITE.with_alpha(0.5),
                            self.cursor.dimensions,
                            ZIndex::TopCover,
                        )
                        .schedule();
                }
                Tool::Spawn => {
                    let pos = self.cursor.absolute_position();
                    let sprite = Sprite::Shadow.load().unwrap();

                    sprite
                        .draw_frame_with_index(
                            pos.x,
                            pos.y,
                            0,
                            WHITE.with_alpha(0.5),
                            self.cursor.dimensions,
                            ZIndex::UnitShadow,
                        )
                        .schedule();
                }
            },
        }
    }
}

impl EditorMenu {
    fn new() -> Self {
        Self {
            items: vec![
                EditorMenuItem::UploadPreset,
                EditorMenuItem::Reset,
                EditorMenuItem::Exit,
            ],
            selected_item: 0,
        }
    }

    fn handle_key_press(&mut self, key: InputCommand) {
        match key {
            InputCommand::Up => {
                self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len()
            }
            InputCommand::Down => self.selected_item = (self.selected_item + 1) % self.items.len(),
            _ => {}
        }
    }
}

impl Selectable for EditorMenu {
    type Item = EditorMenuItem;

    fn next_item(&mut self) {
        self.selected_item = (self.selected_item + 1) % self.items.len();
    }

    fn previous_item(&mut self) {
        self.selected_item = (self.selected_item + self.items.len() - 1) % self.items.len();
    }

    fn selected_item(&self) -> &EditorMenuItem {
        &self.items[self.selected_item]
    }
}

impl Draw for EditorMenu {
    fn draw(&self) {
        let width = screen_width();
        let height = screen_height();
        let line_height = 44.0;

        DrawCommand::text("Editor Menu".to_string())
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

impl EditorCursor {
    pub fn new(position: (u8, u8), dimensions: (u8, u8)) -> Self {
        Self {
            position,
            dimensions,
        }
    }

    pub fn absolute_position(&self) -> Vec2 {
        grid_to_world(self.position, self.dimensions)
    }

    pub fn size(&self) -> Vec2 {
        let (scale_x, scale_y) = get_scale(self.dimensions);
        Vec2::new(TILE_WIDTH * scale_x, TILE_HEIGHT * scale_y)
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

impl From<Preset> for Editor {
    fn from(preset: Preset) -> Self {
        let Preset { map, positions, .. } = preset;
        let grid = GameMap::from(map);
        let dimensions = grid.dimensions();
        Self {
            grid,
            tool: Tool::Obstacle,
            cursor: EditorCursor::new((0, 0), dimensions),
            mode: Mode::Editor,
            spawns: positions
                .iter()
                .map(|position| (position[0], position[1]))
                .collect(),
        }
    }
}

impl Into<Preset> for Editor {
    fn into(self) -> Preset {
        let Editor { grid, spawns, .. } = self;
        Preset {
            map: grid.into(),
            positions: spawns.iter().map(|(x, y)| vec![*x, *y]).collect(),
            id: ID::default(),
            name: "".to_string(),
            author: Address::ZERO,
            popularity: 0,
        }
    }
}

impl Draw for EditorCursor {
    fn draw(&self) {
        draw::draw_cursor(self.position, self.dimensions, BLUE);
    }
}

impl Display for Tool {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Tool::Wall(direction) => write!(f, "Wall ({})", direction),
            Tool::Obstacle => write!(f, "Obstacle"),
            Tool::Spawn => write!(f, "Spawn"),
        }
    }
}

impl Display for EditorMenuItem {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            EditorMenuItem::UploadPreset => write!(f, "Play Test Preset"),
            EditorMenuItem::Reset => write!(f, "Reset"),
            EditorMenuItem::Exit => write!(f, "Save and Exit"),
        }
    }
}
