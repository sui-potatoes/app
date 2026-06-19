// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { COMMANDER_V2_PACKAGE_ID } from "../../../constants";
import { useOwnedBcsObjects, WithRef } from "../../../hooks/useBcsObjects";
import { Recruit as RecruitBcs } from "../types/bcs";

type Props = {
    owner: string;
    enabled: boolean;
};

export type Recruit = WithRef<typeof RecruitBcs.$inferType>;

export function useRecruits({ owner, enabled }: Props) {
    return useOwnedBcsObjects({
        owner,
        enabled,
        type: `${COMMANDER_V2_PACKAGE_ID}::recruit::Recruit`,
        schema: RecruitBcs,
    });
}
