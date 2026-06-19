// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { Recruit } from "../types/bcs";

type Props = {
    recruits: string[];
};

export function useGameRecruits({ recruits }: Props) {
    const client = useCurrentClient();
    return useQuery({
        queryKey: ["commander", "game-recruits", recruits],
        enabled: recruits.length > 0,
        async queryFn() {
            const { objects } = await client.core.getObjects({
                objectIds: recruits,
                include: { content: true },
            });

            const mapped: { [key: string]: typeof Recruit.$inferType } = {};
            for (const object of objects) {
                if (object instanceof Error) throw object;
                const recruit = Recruit.parse(object.content);
                mapped[recruit.id] = recruit;
            }

            return mapped;
        },
    });
}
