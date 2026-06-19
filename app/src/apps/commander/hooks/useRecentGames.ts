// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { COMMANDER_V2_REGISTRY_ID } from "../../../constants";
import { bcs } from "../types/bcs";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

const Commander = bcs.struct("Commander", {
    id: bcs.Address,
    games: bcs.vector(bcs.struct("Entry", { id: bcs.Address, timestamp_ms: bcs.u64() })),
});

export function useRecentGames({ enabled = true, refetchInterval }: Props) {
    const client = useCurrentClient();
    return useQuery({
        queryKey: ["commander", "recent-games"],
        enabled,
        refetchInterval,
        async queryFn() {
            const { object } = await client.core.getObject({
                objectId: COMMANDER_V2_REGISTRY_ID,
                include: { content: true },
            });

            return Commander.parse(object.content).games;
        },
    });
}
