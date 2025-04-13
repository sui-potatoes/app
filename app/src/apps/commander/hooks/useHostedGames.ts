// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { fromBase64 } from "@mysten/bcs";
import { bcs } from "@mysten/sui/bcs";
import { useNetworkVariable } from "../../../networkConfig";
import type { SuiObjectRef } from "@mysten/sui/client";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

const Host = bcs.struct("Host", {
    id: bcs.Address,
    gameId: bcs.Address,
    name: bcs.string(),
    timestampMs: bcs.u64(),
    host: bcs.Address,
});

export type Host = typeof Host.$inferType & SuiObjectRef;

export function useHostedGames({ enabled, refetchInterval }: Props) {
    const registryId = useNetworkVariable("commanderV2RegistryId");
    const packageId = useNetworkVariable("commanderV2PackageId");
    return useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: registryId,
            options: { showBcs: true },
            filter: { StructType: `${packageId}::commander::Host` },
        },
        {
            refetchInterval,
            enabled: enabled == undefined ? true : enabled,
            select(data): (typeof Host.$inferType & SuiObjectRef)[] {
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
                            ...Host.parse(fromBase64(item.data.bcs.bcsBytes)),
                            ...objectRef,
                        };
                    })
                    .filter((item) => item !== null);
            },
        },
    );
}
