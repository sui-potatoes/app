// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { graphqlClient } from "../../../sui";
import { Game } from "../bcs";

export type OpenGame = { id: string; size: number; timestampMs: number; player1: string };

/**
 * Recently created `Game` objects, found through transaction history.
 * gRPC `listTransactions` with a `function` filter returns nothing on the public
 * testnet fullnode (checked against GraphQL, which does), so this query goes
 * through GraphQL; object contents are then fetched over gRPC.
 */
const RECENT_GAMES_QUERY = `
    query RecentGames($function: String!) {
        transactions(last: 30, filter: { function: $function }) {
            nodes {
                effects {
                    objectChanges {
                        nodes {
                            idCreated
                            address
                        }
                    }
                }
            }
        }
    }
`;

type RecentGamesResult = {
    transactions: {
        nodes: {
            effects: {
                objectChanges: {
                    nodes: { idCreated: boolean | null; address: string }[];
                } | null;
            } | null;
        }[];
    } | null;
};

export function useOpenGames(packageId: string, accountIds: string[], enabled = true) {
    const client = useCurrentClient();

    return useQuery<OpenGame[]>({
        queryKey: ["go-open-games", packageId, accountIds],
        enabled,
        refetchInterval: 10000,
        queryFn: async () => {
            const oneDayAgo = Date.now() - 24 * 60 * 60 * 1000;
            const { data } = await graphqlClient.query<RecentGamesResult>({
                query: RECENT_GAMES_QUERY,
                variables: { function: `${packageId}::game::new` },
            });

            const candidates = (data?.transactions?.nodes || []).flatMap(
                (tx) =>
                    tx.effects?.objectChanges?.nodes
                        ?.filter((change) => change.idCreated)
                        .map((change) => change.address) || [],
            );

            if (!candidates.length) return [];

            const { objects } = await client.core.getObjects({
                objectIds: candidates,
                include: { content: true },
            });

            const games: OpenGame[] = [];
            for (const object of objects) {
                if (object instanceof Error) continue;
                if (object.type !== `${packageId}::game::Game`) continue;

                const game = Game.parse(object.content);
                if (game.players.player2 !== null) continue;
                if (game.players.player1 && accountIds.includes(game.players.player1)) continue;

                const timestampMs = Number(game.created_at);
                if (timestampMs < oneDayAgo) continue;

                games.push({
                    id: game.id,
                    size: game.board.size as number,
                    timestampMs,
                    player1: game.players.player1 as string,
                });
            }

            return games;
        },
    });
}
