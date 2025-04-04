// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { fromBase64 } from "@mysten/bcs";
import { bcs, Game } from "../types/bcs";
import type { SuiObjectRef } from "@mysten/sui/client";
import { useNetworkVariable } from "../../../networkConfig";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

export type GameMap = SuiObjectRef & {
    initialSharedVersion: string;
    map: typeof Game.$inferType;
};

const Commander = bcs.struct("Commander", {
    id: bcs.Address,
    games: bcs.vector(bcs.struct("Entry", { id: bcs.Address, timestamp_ms: bcs.u64() })),
});

/**
 * Hook to create a transaction executor
 */
export function useRecentGames({ enabled, refetchInterval }: Props) {
    const registryId = useNetworkVariable("commanderV2RegistryId");

    return useSuiClientQuery(
        "getObject",
        { id: registryId, options: { showBcs: true } },
        {
            refetchInterval,
            enabled: enabled == undefined ? true : enabled,
            select(data) {
                if (!data.data) return null;
                if (!data.data.bcs) return null;
                if (data.data.bcs.dataType !== "moveObject") return null;

                const { games } = Commander.parse(fromBase64(data.data.bcs.bcsBytes));
                return games;
            },
        },
    );
}
