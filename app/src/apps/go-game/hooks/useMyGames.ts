// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useQuery } from "@tanstack/react-query";
import { fromBase64 } from "@mysten/bcs";
import { Game, GameType } from "../bcs";

export function useMyGames(gameIds?: string[]) {
    const client = useSuiClient();

    return useQuery<Record<string, GameType>>({
        queryKey: ["go-my-games", gameIds],
        enabled: !!gameIds?.length,
        queryFn: async () => {
            const results = await Promise.all(
                gameIds!.map(async (id) => {
                    try {
                        const obj = await client.getObject({ id, options: { showBcs: true } });
                        if (!obj.data?.bcs || !("bcsBytes" in obj.data.bcs)) return null;
                        return Game.parse(fromBase64(obj.data.bcs.bcsBytes));
                    } catch {
                        return null;
                    }
                }),
            );
            const map: Record<string, GameType> = {};
            results.forEach((g) => {
                if (g) map[g.id] = g;
            });
            return map;
        },
    });
}
