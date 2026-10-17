// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { fromBase64 } from "@mysten/sui/utils";
import { useCurrentClient, useDAppKit } from "@mysten/dapp-kit-react";
import { Transaction } from "@mysten/sui/transactions";
import { GOGAME_PACKAGE_ID as packageId } from "../../../constants";
import { useTransactionExecutor } from "../../../hooks/useTransactionExecutor";
import { AccountType, Game, GameType } from "../bcs";

export function useGameActions() {
    const client = useCurrentClient();
    const dAppKit = useDAppKit();
    // serial executor: caches object/gas versions from effects, so consecutive
    // moves are built and submitted immediately, in order, without waiting for
    // the previous transaction to be indexed
    const { executor, executeTransaction, isExecuting } = useTransactionExecutor();

    async function signAndExecute(tx: Transaction) {
        if (!executeTransaction) throw new Error("Wallet is not connected");
        return executeTransaction(tx);
    }

    async function newGame(account: AccountType | null, size: number): Promise<string | null> {
        const tx = new Transaction();
        const accArg = account
            ? tx.object(account.id)
            : tx.moveCall({ target: `${packageId}::game::new_account` });

        tx.moveCall({
            target: `${packageId}::game::new`,
            arguments: [accArg, tx.pure.u8(size), tx.object.clock()],
        });

        if (!account) {
            tx.moveCall({ target: `${packageId}::game::keep`, arguments: [accArg] });
        }

        const result = await signAndExecute(tx);
        const created = result.effects.changedObjects.find(
            (change) =>
                change.idOperation === "Created" &&
                result.objectTypes[change.objectId] === `${packageId}::game::Game`,
        );

        // wait for indexing so the lobby/game view sees the new object
        await client.core.waitForTransaction({ digest: result.digest });
        return created?.objectId ?? null;
    }

    async function joinGame(game: GameType, account: AccountType | null) {
        const tx = new Transaction();
        const accArg = account
            ? tx.object(account.id)
            : tx.moveCall({ target: `${packageId}::game::new_account` });

        tx.moveCall({
            target: `${packageId}::game::join`,
            arguments: [tx.object(game.id), accArg, tx.object.clock()],
        });

        if (!account) {
            tx.moveCall({ target: `${packageId}::game::keep`, arguments: [accArg] });
        }

        const result = await signAndExecute(tx);
        await client.core.waitForTransaction({ digest: result.digest });
    }

    async function endGame(game: GameType, account: AccountType) {
        const isSolo = game.players.player1 === game.players.player2;
        const action = !isSolo && game.players.player1 && game.players.player2 ? "quit" : "wrap_up";
        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::${action}`,
            arguments: [tx.object(game.id), tx.object(account.id)],
        });

        const result = await signAndExecute(tx);
        await client.core.waitForTransaction({ digest: result.digest });
    }

    /**
     * Submit a move and return the post-transaction `Game` state, taken
     * directly from the gRPC execution response (`transaction.objects`
     * carries the output objects' BCS) — no extra fetch, no indexing wait.
     */
    async function play(
        game: GameType,
        playerAccount: AccountType,
        x: number,
        y: number,
    ): Promise<GameType | null> {
        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::play`,
            arguments: [
                tx.object(game.id),
                tx.object(playerAccount.id),
                tx.pure.u16(x),
                tx.pure.u16(y),
                tx.object.clock(),
            ],
        });

        const { bytes, signature } = await dAppKit.signTransaction({ transaction: tx });
        const { response } = await client.transactionExecutionService.executeTransaction({
            transaction: { bcs: { value: fromBase64(bytes) } },
            signatures: [
                { bcs: { value: fromBase64(signature) }, signature: { oneofKind: undefined } },
            ],
            // mask paths are relative to the ExecutedTransaction message
            readMask: { paths: ["digest", "effects.status", "objects"] },
        });

        // moves execute outside the serial executor, so its cached gas-coin
        // version is stale after every move — drop the cache so the next
        // executor-routed transaction (new game / join / end) rebuilds fresh
        await executor?.resetCache();

        const status = response.transaction?.effects?.status;
        if (status?.success === false) {
            throw new Error(status.error?.description ?? "Move transaction failed");
        }

        // objects are sorted by (object_id, version); the last entry for the
        // game id is the post-transaction state
        const updated = (response.transaction?.objects?.objects ?? [])
            .filter((object) => object.objectId === game.id && object.contents?.value)
            .pop();

        return updated ? Game.parse(updated.contents!.value!) : null;
    }

    return { newGame, joinGame, endGame, play, isExecuting };
}
