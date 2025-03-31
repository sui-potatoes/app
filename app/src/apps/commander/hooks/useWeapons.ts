// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../../networkConfig";
import { Weapon as WeaponBcs } from "../types/bcs";
import { fromBase64 } from "@mysten/bcs";
import { SuiObjectRef } from "@mysten/sui/client";

export type Weapon = typeof WeaponBcs.$inferType &
    SuiObjectRef & { hasUpgrades: boolean; count: number };

export function useWeapons({ address, unique }: { address?: string; unique?: boolean }) {
    const packageId = useNetworkVariable("commanderV2PackageId");
    return useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: address!,
            filter: { MoveModule: { package: packageId, module: "weapon" } },
            options: { showBcs: true, showType: true },
        },
        {
            queryKey: ["weapons"],
            enabled: !!address,
            gcTime: 10000,
            select(data) {
                const counts: { [key: string]: number } = {};
                const weapons = data.data
                    .map((obj) => {
                        // @ts-ignore
                        const weapon = WeaponBcs.parse(fromBase64(obj.data?.bcs!.bcsBytes));
                        const count = (counts[weapon.name] = (counts[weapon.name] || 0) + 1);

                        if (unique && !weapon.upgrades.length && count > 1) return null;

                        return {
                            ...weapon,
                            hasUpgrades: weapon.upgrades.length > 0,
                            objectId: obj.data?.objectId,
                            version: obj.data?.version,
                            digest: obj.data?.digest,
                            count,
                        } as Weapon & SuiObjectRef;
                    })
                    .filter((w) => w) as Weapon[];

                return weapons.sort((a, b) => a.name.localeCompare(b.name));
            },
        },
    );
}
