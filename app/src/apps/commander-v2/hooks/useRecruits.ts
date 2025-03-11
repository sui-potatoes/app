// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../../networkConfig";
import { fromBase64 } from "@mysten/bcs";
import { Recruit } from "../types/bcs";
import { SuiObjectRef } from "@mysten/sui/client";

type Props = {
    owner: string;
    enabled: boolean;
};

export type Recruit = typeof Recruit.$inferType & SuiObjectRef;

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
            select(data): (typeof Recruit.$inferType & SuiObjectRef)[] {
                return data.data.map((res) => {
                    if (!res.data) {
                        throw new Error("Fetching failed, no data");
                    }

                    const bcsData = res.data.bcs;

                    if (!bcsData || bcsData.dataType === "package") {
                        throw new Error("Unreachable");
                    }

                    return {
                        objectId: res.data.objectId,
                        digest: res.data.digest,
                        version: res.data.version,
                        ...Recruit.parse(fromBase64(bcsData.bcsBytes)),
                    };
                });
            },
        },
    );

    return result;
}
