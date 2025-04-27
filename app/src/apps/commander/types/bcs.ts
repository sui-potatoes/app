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

export function mergeStats(a?: Stats, b?: Stats): Stats {
    return {
        mobility: (a?.mobility || 0) + (b?.mobility || 0),
        aim: (a?.aim || 0) + (b?.aim || 0),
        health: (a?.health || 0) + (b?.health || 0),
        armor: (a?.armor || 0) + (b?.armor || 0),
        dodge: (a?.dodge || 0) + (b?.dodge || 0),
        defense: (a?.defense || 0) + (b?.defense || 0),
        damage: (a?.damage || 0) + (b?.damage || 0),
        spread: (a?.spread || 0) + (b?.spread || 0),
        plus_one: (a?.plus_one || 0) + (b?.plus_one || 0),
        crit_chance: (a?.crit_chance || 0) + (b?.crit_chance || 0),
        can_be_dodged: !!a?.can_be_dodged || !!b?.can_be_dodged,
        area_size: (a?.area_size || 0) + (b?.area_size || 0),
        env_damage: !!a?.env_damage || !!b?.env_damage,
        range: (a?.range || 0) + (b?.range || 0),
        ammo: (a?.ammo || 0) + (b?.ammo || 0),
        _: (a?._ || 0) + (b?._ || 0),
    };
}

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
    can_be_dodged: boolean;
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
            can_be_dodged: Number((stats >> 80n) & 0xffn) == 1,
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
    grenade_used: bcs.bool(),
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

export const HistoryRecord = bcs.enum("HistoryRecord", {
    Reload: bcs.vector(bcs.U16),
    NextTurn: bcs.U16,
    Move: bcs.vector(bcs.U8),
    Attack: bcs.struct("Attack", {
        origin: bcs.vector(bcs.U16),
        target: bcs.vector(bcs.U16),
    }),
    RecruitPlaced: bcs.struct("Placed", {
        x: bcs.U16,
        y: bcs.U16,
    }),
    Damage: bcs.U8,
    Miss: null,
    Explosion: null,
    CriticalHit: bcs.U8,
    Grenade: bcs.struct("Grenade", {
        radius: bcs.U16,
        x: bcs.U16,
        y: bcs.U16,
    }),
    UnitKIA: bcs.Address,
    Dodged: null,
});

export const Replay = bcs.struct("Replay", {
    id: bcs.Address,
    presetId: bcs.Address,
    history: bcs.vector(HistoryRecord),
});

export const Preset = bcs.struct("Commander", {
    id: bcs.Address,
    map: Map,
    name: bcs.String,
    positions: bcs.vector(bcs.vector(bcs.u8())),
    author: bcs.Address,
    popularity: bcs.u64(),
});

export const Host = bcs.struct("Host", {
    id: bcs.Address,
    game_id: bcs.Address,
    name: bcs.String,
    timestamp_ms: bcs.u64(),
    host: bcs.Address,
});

export const GameState = bcs.enum("GameState", {
    Waiting: bcs.Address,
    PlacingRecruits: bcs.vector(bcs.Address),
    Playing: bcs.U64,
    Finished: bcs.Address,
});

export const Game = bcs
    .struct("Game", {
        id: bcs.Address,
        map: Map,
        state: GameState,
        time_limit: bcs.u64(),
        last_turn: bcs.u64(),
        players: bcs.vector(bcs.Address),
        positions: bcs.vector(bcs.vector(bcs.u8())),
        history: bcs.vector(HistoryRecord),
        recruits: bcs.Address,
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
