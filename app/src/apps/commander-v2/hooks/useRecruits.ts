// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../../networkConfig";
import { fromBase64 } from "@mysten/bcs";
import { bcs } from "../types/bcs";

type Props = {
    owner: string;
    enabled: boolean;
};

/**
 * Hook to create a transaction executor
 */
export function useRecruits({ owner, enabled }: Props) {
    const packageId = useNetworkVariable("commanderV2PackageId");
    const result = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner,
            options: { showBcs: true },
            filter: { StructType: `${packageId}::recruit::Recruit` },
        },
        {
            enabled,
            select(data) {
                return data.data.map((res) => {
                    if (!res.data) {
                        throw new Error("Fetching failed, no data");
                    }

                    const bcsData = res.data.bcs;

                    if (!bcsData || bcsData.dataType === "package") {
                        throw new Error("Unreachable");
                    }

                    return bcs.Recruit.parse(fromBase64(bcsData.bcsBytes));
                });
            },
        },
    );

    return result;
}
