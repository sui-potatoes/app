// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";

export function useSuinsName({ address }: { address?: string }) {
    const { data: names } = useSuiClientQuery(
        "resolveNameServiceNames",
        { address: address! },
        { enabled: !!address },
    );

    return names?.data[0];
}
