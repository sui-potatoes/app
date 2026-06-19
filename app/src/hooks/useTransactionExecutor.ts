// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import {
    CurrentAccountSigner,
    useCurrentAccount,
    useCurrentClient,
    useDAppKit,
    type DAppKit,
} from "@mysten/dapp-kit-react";
import { SerialTransactionExecutor, Transaction } from "@mysten/sui/transactions";
import { useMemo, useState } from "react";

/**
 * Wraps `SerialTransactionExecutor` (gas-object caching for rapid sequential
 * transactions) around the currently connected wallet account.
 */
export function useTransactionExecutor() {
    const dAppKit = useDAppKit();
    const client = useCurrentClient();
    const account = useCurrentAccount();
    const [isExecuting, setIsExecuting] = useState(false);

    const executor = useMemo(
        () =>
            account
                ? new SerialTransactionExecutor({
                      client,
                      signer: new CurrentAccountSigner(dAppKit as unknown as DAppKit),
                      defaultGasBudget: 1_000_000_000n,
                  })
                : null,
        [client, dAppKit, account],
    );

    if (!executor) return { executor: null, isExecuting: false, executeTransaction: null };

    return {
        executor,
        isExecuting,
        async executeTransaction(tx: Transaction) {
            setIsExecuting(true);
            try {
                const result = await executor.executeTransaction(tx, {
                    effects: true,
                    events: true,
                    objectTypes: true,
                });

                if (result.FailedTransaction) {
                    throw new Error(
                        `Transaction failed: ${result.FailedTransaction.status.error?.message}`,
                    );
                }

                return result.Transaction;
            } finally {
                setIsExecuting(false);
            }
        },
    };
}
