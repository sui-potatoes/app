// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useQuery } from "@tanstack/react-query";
import { fromBase64 } from "@mysten/bcs";
import { Game, GameType } from "../bcs";

export function useGame(gameId?: string) {
    const client = useSuiClient();

    return useQuery<GameType | null>({
        queryKey: ["go-game", gameId],
        enabled: !!gameId,
        refetchInterval: 1000,
        queryFn: async () => {
            const result = await client.getObject({ id: gameId!, options: { showBcs: true } });
            console.log(result);
            if (!result.data?.bcs || !("bcsBytes" in result.data.bcs)) return null;
            const game = Game.parse(fromBase64(result.data.bcs.bcsBytes));
            console.log(game);
            return game;
        },
    });
}
