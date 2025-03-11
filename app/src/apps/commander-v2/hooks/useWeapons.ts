// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../../networkConfig";
import { Weapon as WeaponBcs } from "./../types/bcs";
import { fromBase64 } from "@mysten/bcs";
import { SuiObjectRef } from "@mysten/sui/client";

export type Weapon = typeof WeaponBcs.$inferType & SuiObjectRef & { hasUpgrades: boolean };

export function useWeapons({ address }: { address?: string }) {
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
            // gcTime: 10000,
            select(data) {
                return data.data.map((obj) => {
                    // @ts-ignore
                    const weapon = WeaponBcs.parse(fromBase64(obj.data?.bcs!.bcsBytes));
                    return {
                        ...weapon,
                        hasUpgrades: weapon.upgrades.length > 0,
                        objectId: obj.data?.objectId,
                        version: obj.data?.version,
                        digest: obj.data?.digest,
                    } as Weapon & SuiObjectRef;
                });
            },
        },
    );
}
