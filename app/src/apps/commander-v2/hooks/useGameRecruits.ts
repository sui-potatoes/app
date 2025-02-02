// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { Recruit } from "../types/bcs";
import { fromBase64 } from "@mysten/bcs";

type Props = {
    recruits: string[];
};

/**
 * Hook to create a transaction executor
 */
export function useGameRecruits({ recruits }: Props) {
    return useSuiClientQuery("multiGetObjects", {
        ids: recruits,
        options: { showBcs: true }
    }, {
        enabled: recruits.length > 0,
        select(data) {
            const mapped: { [key: string]: typeof Recruit.$inferType } = {};

            data.map((recruit) => {
                if (!recruit.data?.bcs) throw new Error("Unreachable");
                if (recruit.data.bcs.dataType === "package") throw new Error("Unreachable");
                const data = Recruit.parse(fromBase64(recruit.data.bcs.bcsBytes));
                mapped[data.id] = data;
            });

            return mapped;
        }
    })
}
