// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { bcs } from "@mysten/sui/bcs";

const Cell = bcs.struct("Cell", {
    row: bcs.u16(),
    column: bcs.u16(),
});

const Players = bcs.struct("Players", {
    player1: bcs.option(bcs.Address),
    player2: bcs.option(bcs.Address),
});

const Grid = bcs.struct("Grid", {
    grid: bcs.vector(bcs.vector(bcs.u8())),
    rows: bcs.u16(),
    cols: bcs.u16(),
});

const Board = bcs.struct("Board", {
    size: bcs.u16(),
    grid: Grid,
    is_black: bcs.bool(),
    score: bcs.struct("Score", {
        black: bcs.u16(),
        white: bcs.u16(),
    }),
    moves: bcs.vector(Cell),
    prev_states: bcs.vector(Grid),
});

export const Account = bcs.struct("Account", {
    id: bcs.Address,
    games: bcs.vector(bcs.Address),
});

export const Game = bcs.struct("Game", {
    id: bcs.Address,
    players: Players,
    board: Board,
    image_blob: bcs.string(),
    created_at: bcs.u64(),
    joined_at: bcs.option(bcs.u64()),
    is_over: bcs.bool(),
});

export type GameType = typeof Game.$inferType;
export type AccountType = typeof Account.$inferType;
