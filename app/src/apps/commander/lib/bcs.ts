// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Contains BCS type definitions for the Commander app.
 * See matching structs in the `./packages/commander/sources/*.move` files.
 *
 * @module apps/commander/lib/bcs
 */

import { bcs } from "@mysten/sui/bcs";

export const commanderBcs = bcs as typeof bcs & CommanderBcs;

export type SelectedAction = {
    idx: number;
    action: typeof Action.$inferType;
};

export type SelectedUnit = {
    unit: typeof Unit.$inferType;
    x: number;
    y: number;
};

/**
 * Return value of the `trace_path` function.
 * Used in devInspect call.
 */
export const TracedPath = bcs.option(
    bcs.vector(
        bcs.struct("Point", {
            x: bcs.u16(),
            y: bcs.u16(),
        }),
    ),
);

export const AttackType = bcs.struct("AttackType", {
    maxRange: bcs.u16(),
    damage: bcs.u16(),
});

export const ActionType = bcs.enum("ActionType", {
    Attack: AttackType,
    Move: null,
    Skip: null,
});

export const Armor = bcs.struct("Armor", {
    name: bcs.string(),
    value: bcs.u16(),
});

export const Action = bcs.struct("Action", {
    name: bcs.string(),
    cost: bcs.u16(),
    inner: ActionType,
});

export const Param = bcs.struct("Param", {
    value: bcs.u16(),
    maxValue: bcs.u16(),
});

export const Unit = bcs.struct("Unit", {
    symbol: bcs.string(),
    name: bcs.string(),
    armor: bcs.option(Armor),
    actions: bcs.vector(Action),
    health: Param,
    ap: Param,
    turn: bcs.u16(),
});

export const Tile = bcs.enum("Tile", {
    Empty: null,
    Unit: bcs.struct("UnitTile", {
        unit: Unit,
        team: bcs.u8(),
    }),
});

export const Grid = bcs.struct("Grid", {
    grid: bcs.vector(bcs.vector(Tile)),
});

export const Game = bcs.struct("Game", {
    id: bcs.Address,
    team: bcs.u8(),
    turn: bcs.u16(),
    map: Grid,
});

type CommanderBcs = typeof bcs & {
    Game: typeof Game.$inferType;
    Grid: typeof Grid.$inferType;
    Tile: typeof Tile.$inferType;
    Unit: typeof Unit.$inferType;
    Param: typeof Param.$inferType;
    Action: typeof Action.$inferType;
    Armor: typeof Armor.$inferType;
    AttackType: typeof AttackType.$inferType;
    ActionType: typeof ActionType.$inferType;
    TracedPath: typeof TracedPath.$inferType;
};

export { commanderBcs as bcs };
