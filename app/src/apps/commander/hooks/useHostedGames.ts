// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { bcs } from "@mysten/sui/bcs";
import { COMMANDER_V2_PACKAGE_ID, COMMANDER_V2_REGISTRY_ID } from "../../../constants";
import { useOwnedBcsObjects, WithRef } from "../../../hooks/useBcsObjects";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

const HostBcs = bcs.struct("Host", {
    id: bcs.Address,
    gameId: bcs.Address,
    name: bcs.string(),
    timestampMs: bcs.u64(),
    host: bcs.Address,
});

export type Host = WithRef<typeof HostBcs.$inferType>;

export function useHostedGames({ enabled = true, refetchInterval }: Props) {
    return useOwnedBcsObjects({
        owner: COMMANDER_V2_REGISTRY_ID,
        type: `${COMMANDER_V2_PACKAGE_ID}::commander::Host`,
        schema: HostBcs,
        enabled,
        refetchInterval,
    });
}
