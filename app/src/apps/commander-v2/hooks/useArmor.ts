// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../../networkConfig";
import { Armor as ArmorBcs } from "./../types/bcs";
import { fromBase64 } from "@mysten/bcs";
import { SuiObjectRef } from "@mysten/sui/client";

export type Armor = typeof ArmorBcs.$inferType & SuiObjectRef;

export function useArmor({ address, unique }: { address?: string; unique?: boolean }) {
    const packageId = useNetworkVariable("commanderV2PackageId");
    return useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: address!,
            filter: { MoveModule: { package: packageId, module: "armor" } },
            options: { showBcs: true, showType: true },
        },
        {
            queryKey: ["armors"],
            enabled: !!address,
            // gcTime: 10000,
            select(data) {
                const processed = [] as string[];
                const result = data.data.map((obj) => {
                    // @ts-ignore
                    const armor = ArmorBcs.parse(fromBase64(obj.data?.bcs!.bcsBytes));
                    return {
                        ...armor,
                        objectId: obj.data?.objectId,
                        version: obj.data?.version,
                        digest: obj.data?.digest,
                    } as Armor & SuiObjectRef;
                });

                return !unique
                    ? result
                    : result.filter((el) => {
                          if (processed.includes(el.name)) return false;
                          processed.push(el.name);
                          return true;
                      });
            },
        },
    );
}
