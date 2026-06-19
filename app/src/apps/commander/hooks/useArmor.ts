// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { COMMANDER_V2_PACKAGE_ID } from "../../../constants";
import { useOwnedBcsObjects, WithRef } from "../../../hooks/useBcsObjects";
import { Armor as ArmorBcs } from "../types/bcs";

export type Armor = WithRef<typeof ArmorBcs.$inferType>;

export function useArmor({ address, unique }: { address?: string; unique?: boolean }) {
    return useOwnedBcsObjects({
        owner: address,
        type: `${COMMANDER_V2_PACKAGE_ID}::armor::Armor`,
        schema: ArmorBcs,
        select(items): Armor[] {
            if (!unique) return items;
            const seen = new Set<string>();
            return items.filter((armor) => {
                if (seen.has(armor.name)) return false;
                seen.add(armor.name);
                return true;
            });
        },
    });
}
