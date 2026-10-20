// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import {
    CurrentAccountSigner,
    useCurrentClient,
    useDAppKit,
    type DAppKit,
} from "@mysten/dapp-kit-react";
import { Transaction } from "@mysten/sui/transactions";

/**
 * Sign a transaction with the connected wallet, execute it, and wait for it
 * to be indexed. Throws when the transaction fails on-chain.
 *
 * `CurrentAccountSigner` is typed against the bare `DAppKit<[]>`, so the
 * registered `DAppKit<["testnet"], SuiGrpcClient>` needs the cast.
 */
export function useSignAndExecute() {
    const dAppKit = useDAppKit();
    const client = useCurrentClient();

    return async function signAndExecute(tx: Transaction) {
        const result = await client.core.signAndExecuteTransaction({
            transaction: tx,
            signer: new CurrentAccountSigner(dAppKit as unknown as DAppKit),
            include: { effects: true, objectTypes: true },
        });

        if (result.FailedTransaction) {
            throw new Error(
                `Transaction failed: ${result.FailedTransaction.status.error?.message}`,
            );
        }

        await client.core.waitForTransaction({ digest: result.Transaction.digest });
        return result.Transaction;
    };
}
