// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { fromBase64 } from "@mysten/bcs";
import { bcs, Map } from "../types/bcs";
import { useNetworkVariable } from "../../../networkConfig";
import type { SuiObjectRef } from "@mysten/sui/client";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

const Preset = bcs.struct("Commander", {
    id: bcs.Address,
    map: Map,
    positions: bcs.vector(bcs.vector(bcs.u8())),
    author: bcs.Address,
    popularity: bcs.u64(),
});

export function useMaps({ enabled, refetchInterval }: Props) {
    const registryId = useNetworkVariable("commanderV2RegistryId");
    const packageId = useNetworkVariable("commanderV2PackageId");
    return useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: registryId,
            options: { showBcs: true },
            filter: { StructType: `${packageId}::commander::Preset` },
        },
        {
            refetchInterval,
            enabled: enabled == undefined ? true : enabled,
            select(data): (typeof Preset.$inferType & SuiObjectRef)[] {
                return (data.data || [])
                    .map((item) => {
                        if (!item.data) return null;
                        if (!item.data.bcs) return null;
                        if (item.data.bcs.dataType !== "moveObject") return null;

                        const objectRef = {
                            objectId: item.data.objectId,
                            version: item.data.version,
                            digest: item.data.digest,
                        } as SuiObjectRef;

                        return {
                            ...Preset.parse(fromBase64(item.data.bcs.bcsBytes)),
                            ...objectRef,
                        };
                    })
                    .filter((item) => item !== null);
            },
        },
    );
}
