// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";
import { Account, AccountType } from "../bcs";

/**
 * All `Account` objects owned by the address. An address can own several
 * (creating a game without an account mints a new one), so consumers pick
 * the relevant account per game, or merge the game lists.
 */
export function useAccounts(packageId: string, owner?: string) {
    const client = useCurrentClient();

    return useQuery<AccountType[]>({
        queryKey: ["go-accounts", packageId, owner],
        enabled: !!owner,
        queryFn: async () => {
            const { objects } = await client.core.listOwnedObjects({
                owner: owner!,
                type: `${packageId}::game::Account`,
                include: { content: true },
            });

            return objects
                .map((object) => Account.parse(object.content))
                .sort((a, b) => b.games.length - a.games.length);
        },
    });
}
