// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { fromBase64 } from "@mysten/bcs";
import { Preset } from "../types/bcs";
import type { SuiObjectRef } from "@mysten/sui/client";
import { useNetworkVariable } from "../../../networkConfig";

type Props = {
    id: string | null;
    enabled?: boolean;
    refetchInterval?: number;
};

export type Preset = SuiObjectRef & typeof Preset.$inferType;

export function usePreset({ id, enabled, refetchInterval }: Props) {
    const packageId = useNetworkVariable("commanderV2PackageId");
    return useSuiClientQuery(
        "getObject",
        { id: id!, options: { showBcs: true, showOwner: true, showType: true } },
        {
            refetchInterval,
            enabled: enabled == undefined ? true : enabled && !!id,
            select(data): Preset | null {
                if (!data.data) return null;
                if (!data.data.bcs) return null;
                if (!data.data.type) return null;
                if (data.data.type !== `${packageId}::commander::Preset`) return null;
                if (data.data.bcs.dataType !== "moveObject") return null;
                const preset = Preset.parse(fromBase64(data.data.bcs.bcsBytes));

                return {
                    objectId: data.data.objectId,
                    version: data.data.version,
                    digest: data.data.digest,
                    ...preset,
                };
            },
        },
    );
}
