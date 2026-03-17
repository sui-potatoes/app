// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useQuery } from "@tanstack/react-query";
import { fromBase64 } from "@mysten/bcs";
import { Account, AccountType } from "../bcs";

export function useAccount(packageId: string, owner?: string) {
    const client = useSuiClient();

    return useQuery<AccountType | null>({
        queryKey: ["go-account", packageId, owner],
        enabled: !!owner,
        queryFn: async () => {
            const result = await client.getOwnedObjects({
                owner: owner!,
                filter: { MoveModule: { package: packageId, module: "game" } },
                options: { showBcs: true },
            });
            if (!result.data.length) return null;
            const bcsData = result.data[0].data?.bcs;
            if (!bcsData || !("bcsBytes" in bcsData)) return null;
            return Account.parse(fromBase64(bcsData.bcsBytes as string));
        },
    });
}
