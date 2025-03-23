// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useState } from "react";
import { useNetworkVariable } from "../../../networkConfig";
import { useNameGenerator } from "./useNameGenerator";
import { Transaction } from "@mysten/sui/transactions";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { GameMap } from "./useGame";
import { useSuiClient } from "@mysten/dapp-kit";
import { bcs } from "@mysten/bcs";
import { useTransactionExecutor } from "./useTransactionExecutor";

export const LS_KEY = "commander-v2";

export function useGameTransactions({ map }: { map: GameMap | null | undefined }) {
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const registryId = useNetworkVariable("commanderV2RegistryId");
    const packageId = useNetworkVariable("commanderV2PackageId");
    const [lockedTx, setLockedTx] = useState<Transaction | null>(null);
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const canTransact = !!zkLogin.address && !isExecuting && executeTransaction;

    return {
        canTransact,
        lockedTx,
        createDemo,
        performAttack,
        performGrenade,
        performReload,
        moveUnit,
        nextTurn,
        isExecuting,
        executeLocked,
    };

    /**
     * Create a demo map (1 or 2) with the given positions.
     * Add recruits to the given positions.
     */
    async function createDemo(num: 1 | 2, positions: [number, number][] = []) {
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.moveCall({ target: `${packageId}::commander::demo_${num}` });

        for (let [x, y] of positions) {
            const { name, backstory } = await useNameGenerator();
            const recruit = tx.moveCall({
                target: `${packageId}::recruit::new`,
                arguments: [tx.pure.string(name), tx.pure.string(backstory)],
            });

            const armor = tx.moveCall({
                target: `${packageId}::items::armor`,
                arguments: [tx.pure.u8(1)],
            });

            tx.moveCall({
                target: `${packageId}::recruit::add_armor`,
                arguments: [recruit, armor],
            });

            tx.moveCall({
                target: `${packageId}::commander::place_recruit`,
                arguments: [game, recruit, tx.pure.u16(x), tx.pure.u16(y)],
            });
        }

        // register the game in the Commander object.
        tx.moveCall({
            target: `${packageId}::commander::register_game`,
            arguments: [tx.object(registryId), tx.object.clock(), game],
        });

        tx.moveCall({ target: `${packageId}::commander::share`, arguments: [game] });

        const res = await executeTransaction(tx);
        const map = res.data.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!map) throw new Error("Map not found, something is off");
        if (map.type !== "created") throw new Error("Map not created, something is off");

        sessionStorage.setItem(LS_KEY, map.objectId);
        return map;
    }

    /** Perform ranged attack. I've been waiting for this soooo long */
    async function performAttack(unit: [number, number], target: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({
            target: `${packageId}::commander::perform_attack`,
            arguments: [
                game,
                tx.object.random(),
                tx.pure.u16(unit[0]),
                tx.pure.u16(unit[1]),
                tx.pure.u16(target[0]),
                tx.pure.u16(target[1]),
            ],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setLockedTx(tx);

        return { res, tx };
    }

    async function performReload(unit: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({
            target: `${packageId}::commander::perform_reload`,
            arguments: [game, tx.pure.u16(unit[0]), tx.pure.u16(unit[1])],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setLockedTx(tx);

        return { res, tx };
    }

    async function performGrenade(from: [number, number], to: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({
            target: `${packageId}::commander::perform_grenade`,
            arguments: [
                game,
                tx.object.random(),
                tx.pure.u16(from[0]),
                tx.pure.u16(from[1]),
                tx.pure.u16(to[0]),
                tx.pure.u16(to[1]),
            ],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setLockedTx(tx);

        return { res, tx };
    }

    /** Move the unit on the map. The initial coordinate is the gridPosition of the unit. */
    async function moveUnit(path: [number, number][]) {
        if (!map) throw new Error("Map not found");
        if (!canTransact) throw new Error("Cannot transact");

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        const pathArg = tx.pure(bcs.vector(bcs.vector(bcs.u16())).serialize(path));

        tx.moveCall({ target: `${packageId}::commander::move_unit`, arguments: [game, pathArg] });
        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setLockedTx(tx);

        return { res, tx };
    }

    /** End the turn. */
    async function nextTurn() {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({ target: `${packageId}::commander::next_turn`, arguments: [game] });
        tx.setSender(zkLogin.address!);

        return await executeTransaction(tx);
    }

    /** Execute locked transaction */
    async function executeLocked() {
        if (!lockedTx) throw new Error("No locked transaction to execute");
        if (!canTransact) throw new Error("Cannot execute transaction");

        const res = await executeTransaction(lockedTx);
        setLockedTx(null);
        return res;
    }
}
