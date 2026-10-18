// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import {
    CurrentAccountSigner,
    useCurrentAccount,
    useCurrentClient,
    useDAppKit,
    type DAppKit,
} from "@mysten/dapp-kit-react";
import type { SuiClientTypes } from "@mysten/sui/client";
import { SerialTransactionExecutor, Transaction } from "@mysten/sui/transactions";
import { useMemo, useState } from "react";

/** Same safety margin the SDK applies when it estimates a budget in `Transaction.build`. */
const GAS_SAFE_OVERHEAD = 1000n;

/** Budget from simulated gas usage, mirroring the SDK's own formula. */
function computeGasBudget(gasUsed: SuiClientTypes.GasCostSummary, gasPrice: bigint): bigint {
    const computation = BigInt(gasUsed.computationCost) + GAS_SAFE_OVERHEAD * gasPrice;
    const total = computation + BigInt(gasUsed.storageCost) - BigInt(gasUsed.storageRebate);
    return total > computation ? total : computation;
}

/**
 * Wraps `SerialTransactionExecutor` (gas-object caching for rapid sequential
 * transactions) around the currently connected wallet account.
 *
 * The executor always stamps a fixed budget before building, which skips the
 * SDK's dry-run estimation and fails for any account holding less than that
 * budget. So the budget is measured here instead: a simulation sets it from
 * the actual gas used, unless the caller already set one.
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
                  })
                : null,
        [client, dAppKit, account],
    );

    if (!executor || !account) {
        return { executor: null, isExecuting: false, executeTransaction: null };
    }

    async function setMeasuredBudget(tx: Transaction) {
        if (tx.getData().gasData.budget !== null) return;
        tx.setSenderIfNotSet(account!.address);

        const [simulation, { referenceGasPrice }] = await Promise.all([
            client.core.simulateTransaction({ transaction: tx, include: { effects: true } }),
            client.core.getReferenceGasPrice(),
        ]);
        if (simulation.FailedTransaction) {
            throw new Error(
                `Transaction failed in simulation: ${simulation.FailedTransaction.status.error?.message}`,
            );
        }

        tx.setGasBudget(
            computeGasBudget(simulation.Transaction.effects.gasUsed, BigInt(referenceGasPrice)),
        );
    }

    return {
        executor,
        isExecuting,
        async executeTransaction(tx: Transaction) {
            setIsExecuting(true);
            try {
                await setMeasuredBudget(tx);

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
