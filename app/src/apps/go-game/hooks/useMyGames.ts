// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { Game, GameType } from "../bcs";

export function useMyGames(gameIds?: string[]) {
    const client = useCurrentClient();

    return useQuery<Record<string, GameType>>({
        queryKey: ["go-my-games", gameIds],
        enabled: !!gameIds?.length,
        queryFn: async () => {
            const { objects } = await client.core.getObjects({
                objectIds: gameIds!,
                include: { content: true },
            });

            const map: Record<string, GameType> = {};
            for (const object of objects) {
                if (object instanceof Error) continue;
                const game = Game.parse(object.content);
                map[game.id] = game;
            }

            return map;
        },
    });
}
