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

export const Stats = bcs.struct("Stats", {
    mobility: bcs.u8(),
    aim: bcs.u8(),
    will: bcs.u8(),
    health: bcs.u8(),
    armor: bcs.u8(),
    dodge: bcs.u8(),
    hack: bcs.u8(),
});

export const Metadata = bcs.struct("Metadata", {
    name: bcs.string(),
    backstory: bcs.string(),
});

export const Weapon = bcs.struct("Weapon", {
    id: bcs.Address,
    name: bcs.string(),
    damage: bcs.u8(),
    spread: bcs.u8(),
    plus_one: bcs.u8(),
    crit_chance: bcs.u8(),
    is_dodgeable: bcs.bool(),
    area_damage: bcs.bool(),
    area_size: bcs.u8(),
    range: bcs.u8(),
    ammo: bcs.u8(),
});

export const Recruit = bcs.struct("Recruit", {
    id: bcs.Address,
    metadata: Metadata,
    rank: Rank,
    stats: Stats,
    weapon: bcs.option(Weapon),
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
