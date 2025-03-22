// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { SuiClient, SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Signer } from "@mysten/sui/cryptography";
import { SerialTransactionExecutor, Transaction } from "@mysten/sui/transactions";
import { useEffect, useMemo, useState } from "react";

type Props = {
    client: SuiClient;
    signer: () => Promise<Signer>;
    enabled: boolean;
};

/**
 * Hook to create a transaction executor
 */
export function useTransactionExecutor({ client, signer: getSigner, enabled }: Props) {
    const [signer, setSigner] = useState<Signer | null>(null);
    const executor = useMemo(
        () => signer && new SerialTransactionExecutor({ client, signer }),
        [signer],
    );

    useEffect(() => {
        if (!enabled) return;
        getSigner().then(setSigner);
    }, [enabled]);

    if (!enabled || !signer) return { executor: null, executeTransaction: () => {} };

    return {
        executor,
        executeTransaction(tx: Transaction) {
            const txPromise = executor!.executeTransaction(tx);
            return {
                data: txPromise,
                async wait(): Promise<SuiTransactionBlockResponse> {
                    const { digest } = await txPromise;
                    return client.waitForTransaction({ digest });
                },
            };
        },
    };
}
