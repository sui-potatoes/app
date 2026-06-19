// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount, useCurrentClient } from "@mysten/dapp-kit-react";
import { useQuery } from "@tanstack/react-query";

/** How often to re-check the balance while signed in (ms). */
const POLL_INTERVAL = 10_000;

/**
 * Poll the connected account's total SUI balance, in MIST (a bigint).
 * The query is disabled while signed out, and keeps refetching on an interval
 * so callers can react to funds arriving (e.g. from a faucet) without a reload.
 */
export function useBalance() {
    const client = useCurrentClient();
    const address = useCurrentAccount()?.address;

    return useQuery({
        queryKey: ["balance", address],
        enabled: !!address,
        refetchInterval: POLL_INTERVAL,
        queryFn: async (): Promise<bigint> => {
            const { balance } = await client.core.getBalance({ owner: address! });
            return BigInt(balance.balance);
        },
    });
}
