// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { COMMANDER_V2_PACKAGE_ID } from "../../../constants";
import { useOwnedBcsObjects, WithRef } from "../../../hooks/useBcsObjects";
import { Weapon as WeaponBcs } from "../types/bcs";

export type Weapon = WithRef<typeof WeaponBcs.$inferType> & {
    hasUpgrades: boolean;
    count: number;
};

export function useWeapons({ address, unique }: { address?: string; unique?: boolean }) {
    return useOwnedBcsObjects({
        owner: address,
        type: `${COMMANDER_V2_PACKAGE_ID}::weapon::Weapon`,
        schema: WeaponBcs,
        gcTime: 10000,
        select(items): Weapon[] {
            const counts: { [key: string]: number } = {};
            return items
                .map((weapon) => {
                    const count = (counts[weapon.name] = (counts[weapon.name] || 0) + 1);
                    if (unique && !weapon.upgrades.length && count > 1) return null;
                    return { ...weapon, hasUpgrades: weapon.upgrades.length > 0, count };
                })
                .filter((weapon) => weapon !== null)
                .sort((a, b) => a.name.localeCompare(b.name));
        },
    });
}
