// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { COMMANDER_V2_PACKAGE_ID, COMMANDER_V2_REGISTRY_ID } from "../../../constants";
import { useOwnedBcsObjects } from "../../../hooks/useBcsObjects";
import { Preset as PresetBcs } from "../types/bcs";

type Props = {
    enabled?: boolean;
    refetchInterval?: number;
};

export type Preset = typeof PresetBcs.$inferType;

export function useMaps({ enabled = true, refetchInterval }: Props) {
    return useOwnedBcsObjects({
        owner: COMMANDER_V2_REGISTRY_ID,
        type: `${COMMANDER_V2_PACKAGE_ID}::commander::Preset`,
        schema: PresetBcs,
        enabled,
        refetchInterval,
    });
}
