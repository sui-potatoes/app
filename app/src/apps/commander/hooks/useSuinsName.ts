// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { COMMANDER_BASE_NAME } from "../../../constants";

export function useSuinsName({ address }: { address?: string }) {
    const { data: names } = useSuiClientQuery(
        "resolveNameServiceNames",
        { address: address! },
        { enabled: !!address },
    );

    return names?.data.find((n) => n.includes(COMMANDER_BASE_NAME))?.split(".")[0];
}
