// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../../networkConfig";
import { AccountType, GameType, Game } from "../bcs";

export function useGameActions() {
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const packageId = useNetworkVariable("goPackageId");

    async function sign(tx: Transaction) {
        return client.signAndExecuteTransaction({
            signer: (await flow.getKeypair({ network: "testnet" })) as any,
            transaction: tx as any,
        });
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

        const result = await sign(tx);
        const { objectChanges } = await client.waitForTransaction({
            digest: result.digest,
            timeout: 10000,
            pollInterval: 500,
            options: { showObjectChanges: true },
        });

        const change = objectChanges?.find(
            (c) => c.type === "created" && c.objectType === `${packageId}::game::Game`,
        );
        return change?.type === "created" ? change.objectId : null;
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

        const result = await sign(tx);
        await client.waitForTransaction({ digest: result.digest });
    }

    async function endGame(game: GameType, account: AccountType) {
        const isSolo = game.players.player1 === game.players.player2;
        const action = !isSolo && game.players.player1 && game.players.player2 ? "quit" : "wrap_up";
        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::${action}`,
            arguments: [tx.object(game.id), tx.object(account.id)],
        });
        const result = await sign(tx);
        await client.waitForTransaction({ digest: result.digest });
    }

    /**
     * Validates the move via devInspect (returns the updated board state optimistically),
     * then submits the actual transaction on-chain.
     */
    async function play(
        game: GameType,
        account: AccountType,
        x: number,
        y: number,
        onPreview?: (updated: GameType) => void,
    ): Promise<void> {
        const inspect = new Transaction();
        inspect.moveCall({
            target: `${packageId}::game::board_state`,
            arguments: [inspect.object(game.id), inspect.pure.u16(x), inspect.pure.u16(y)],
        });

        const res = await client.devInspectTransactionBlock({
            sender: zkLogin.address!,
            transactionBlock: inspect as any,
        });

        if (!res.results?.[0] || res.error) return;

        const boardBytes = res.results[0].mutableReferenceOutputs as any;
        onPreview?.(Game.parse(new Uint8Array(boardBytes[0][1])));

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::game::play`,
            arguments: [
                tx.object(game.id),
                tx.object(account.id),
                tx.pure.u16(x),
                tx.pure.u16(y),
                tx.object("0x6"),
            ],
        });

        const result = await sign(tx);
        await client.waitForTransaction({ digest: result.digest });
    }

    return { newGame, joinGame, endGame, play };
}
