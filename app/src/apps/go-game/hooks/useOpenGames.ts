// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useQuery } from "@tanstack/react-query";
import { fromBase64 } from "@mysten/bcs";
import { Game } from "../bcs";

export type OpenGame = { id: string; size: number; timestampMs: number; player1: string };

export function useOpenGames(packageId: string, accountId?: string, enabled = true) {
    const client = useSuiClient();

    return useQuery<OpenGame[]>({
        queryKey: ["go-open-games", packageId, accountId],
        enabled,
        refetchInterval: 10000,
        queryFn: async () => {
            const oneDayAgo = Date.now() - 24 * 60 * 60 * 1000;
            const txs = await client.queryTransactionBlocks({
                filter: { MoveFunction: { package: packageId, module: "game", function: "new" } },
                options: { showObjectChanges: true },
                limit: 30,
                order: "descending",
            });

            const candidates = txs.data.flatMap((tx) =>
                (tx.objectChanges || [])
                    .filter(
                        (c) =>
                            c.type === "created" &&
                            (c as any).objectType === `${packageId}::game::Game`,
                    )
                    .map((c) => ({ id: (c as any).objectId })),
            );

            const results = await Promise.all(
                candidates.map(async ({ id }) => {
                    try {
                        const obj = await client.getObject({ id, options: { showBcs: true } });
                        if (!obj.data?.bcs || !("bcsBytes" in obj.data.bcs)) return null;
                        const game = Game.parse(fromBase64(obj.data.bcs.bcsBytes));
                        if (game.players.player2 !== null) return null;
                        if (accountId && game.players.player1 === accountId) return null;
                        const timestampMs = Number(game.created_at);
                        if (timestampMs < oneDayAgo) return null;
                        return {
                            id,
                            size: game.board.size as number,
                            timestampMs,
                            player1: game.players.player1 as string,
                        };
                    } catch {
                        return null;
                    }
                }),
            );

            return results.filter((g): g is OpenGame => g !== null);
        },
    });
}
