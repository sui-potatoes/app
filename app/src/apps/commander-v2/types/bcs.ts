// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { bcs } from "@mysten/sui/bcs";

export const Rank = bcs.enum("Rank", {
    Rookie: null,
    Squaddie: null,
    Corporal: null,
    Sergeant: null,
    Lieutenant: null,
    Captain: null,
    Major: null,
    Colonel: null,
});

export type Stats = {
    mobility: number;
    aim: number;
    health: number;
    armor: number;
    dodge: number;
    defense: number;
    damage: number;
    spread: number;
    plus_one: number;
    crit_chance: number;
    is_dodgeable: boolean;
    area_size: number;
    env_damage: boolean;
    range: number;
    ammo: number;
    _: number;
};

export const Stats = bcs.u128().transform({
    input(val): any {
        return val;
    },
    output(stats: string | bigint): Stats {
        stats = BigInt(stats);
        const asObject: { [key: string]: number | boolean } = {
            mobility: Number(stats & 0xffn),
            aim: Number((stats >> 8n) & 0xffn),
            health: Number((stats >> 16n) & 0xffn),
            armor: Number((stats >> 24n) & 0xffn),
            dodge: Number((stats >> 32n) & 0xffn),
            defense: Number((stats >> 40n) & 0xffn),
            damage: Number((stats >> 48n) & 0xffn),
            spread: Number((stats >> 56n) & 0xffn),
            plus_one: Number((stats >> 64n) & 0xffn),
            crit_chance: Number((stats >> 72n) & 0xffn),
            is_dodgeable: Number((stats >> 80n) & 0xffn) == 1,
            area_size: Number((stats >> 88n) & 0xffn),
            env_damage: Number((stats >> 96n) & 0xffn) == 1,
            range: Number((stats >> 104n) & 0xffn),
            ammo: Number((stats >> 112n) & 0xffn),
            _: Number((stats >> 120n) & 0xffn),
        };

        // additionally process i8 values encoded in the stats
        for (let key in asObject) {
            if (typeof asObject[key] == "number" && asObject[key] > 128) {
                asObject[key] = 128 - asObject[key];
            }
        }

        return asObject as Stats;
    },
});

export const Param = bcs.struct("Param", {
    value: bcs.u16(),
    max_value: bcs.u16(),
});

export const Unit = bcs.struct("Unit", {
    recruit: bcs.Address,
    ap: Param,
    hp: Param,
    ammo: Param,
    stats: Stats,
    last_turn: bcs.u16(),
});

const Cover = bcs.struct("Cover", {
    left: bcs.u8(),
    up: bcs.u8(),
    right: bcs.u8(),
    down: bcs.u8(),
});

const TileType = bcs.enum("TileType", {
    Empty: null,
    Cover: Cover,
    Unwalkable: null,
});

export const Tile = bcs.struct("Tile", {
    tile_type: TileType,
    unit: bcs.option(Unit),
});

export const Map = bcs.struct("Map", {
    id: bcs.Address,
    grid: bcs.vector(bcs.vector(Tile)),
    turn: bcs.u16(),
});

export const Metadata = bcs.struct("Metadata", {
    name: bcs.string(),
    backstory: bcs.string(),
});

export const Game = bcs
    .struct("Game", {
        id: bcs.Address,
        map: Map,
    })
    .transform({
        output(game) {
            let recruits: string[] = [];
            game.map.grid.forEach((row) => {
                row.forEach((cell) => {
                    if (cell.unit) recruits.push(cell.unit.recruit);
                });
            });
            return { ...game, recruits };
        },
    });

export const WeaponUpgrade = bcs.struct("WeaponUpgrade", {
    name: bcs.string(),
    tier: bcs.u8(),
    stats: Stats,
});

export const Weapon = bcs.struct("Weapon", {
    id: bcs.Address,
    name: bcs.string(),
    stats: Stats,
    upgrades: bcs.vector(WeaponUpgrade),
});

export const Armor = bcs.struct("Armor", {
    id: bcs.Address,
    name: bcs.string(),
    stats: Stats,
});

export const Recruit = bcs.struct("Recruit", {
    id: bcs.Address,
    metadata: Metadata,
    rank: Rank,
    stats: Stats,
    weapon: bcs.option(Weapon),
    armor: bcs.option(Armor),
    leader: bcs.Address,
});

type CommanderBcs = typeof bcs & {
    Rank: typeof Rank;
    Stats: typeof Stats;
    Metadata: typeof Metadata;
    Weapon: typeof Weapon;
    Recruit: typeof Recruit;
};

export const commanderBcs = { ...bcs, Rank, Stats, Metadata, Weapon, Recruit } as typeof bcs &
    CommanderBcs;

export { commanderBcs as bcs };
