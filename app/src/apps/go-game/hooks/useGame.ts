// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { Game, GameType } from "../bcs";

export function useGame(gameId?: string) {
    const client = useCurrentClient();

    return useQuery<GameType | null>({
        queryKey: ["go-game", gameId],
        enabled: !!gameId,
        refetchInterval: 1000,
        queryFn: async () => {
            const { object } = await client.core
                .getObject({ objectId: gameId!, include: { content: true } })
                .catch(() => ({ object: null }));

            return object ? Game.parse(object.content) : null;
        },
    });
}
