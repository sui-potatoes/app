// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { bcs } from "@mysten/bcs";
import { useCurrentAccount, useCurrentClient } from "@mysten/dapp-kit-react";
import type { SuiClientTypes } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import { useState } from "react";
import { COMMANDER_V2_PACKAGE_ID, COMMANDER_V2_REGISTRY_ID } from "../../../constants";
import { ObjectRef } from "../../../hooks/useBcsObjects";
import { SimulationError } from "../types/abort-codes";
import { Game } from "../types/bcs";
import { coordinatesToPath } from "../types/cursor";
import { generateRecruitName } from "../utils/nameGenerator";
import { GameMap } from "./useGame";
import { Host } from "./useHostedGames";
import { Preset } from "./useMaps";
import { useTransactionExecutor } from "../../../hooks/useTransactionExecutor";

export const LS_KEY = "commander-v2";

const PKG = COMMANDER_V2_PACKAGE_ID;
const REGISTRY = COMMANDER_V2_REGISTRY_ID;

/** Result of an executed transaction with effects, events and object types. */
export type ExecutedTransaction = SuiClientTypes.Transaction<{
    effects: true;
    events: true;
    objectTypes: true;
}>;

export function useGameTransactions({ map }: { map: GameMap | null | undefined }) {
    const account = useCurrentAccount();
    const client = useCurrentClient();
    const [lockedTx, setLockedTx] = useState<Transaction | null>(null);
    const [isChecking, setIsChecking] = useState(false);
    const { executeTransaction, isExecuting } = useTransactionExecutor();
    const canTransact = !!account && !isExecuting && !!executeTransaction;

    return {
        canTransact,
        lockedTx,
        createDemo,
        hostGame,
        joinGame,
        publishMap,
        performAttack,
        performGrenade,
        performReload,
        moveUnit,
        nextTurn,
        isExecuting,
        isChecking,
        executeLocked,
        destroyGame,
        deleteReplay,
    };

    /**
     * Create a demo map (1 or 2) with the given positions.
     * Add recruits to the given positions.
     */
    async function createDemo(preset: Preset & ObjectRef) {
        if (!canTransact) return;

        const tx = new Transaction();
        const registryArg = tx.object(REGISTRY);
        const game = tx.moveCall({
            target: `${PKG}::commander::new_game`,
            arguments: [registryArg, tx.receivingRef(preset)],
        });

        for (const _ of preset.positions) {
            const recruit = newRecruit(tx);
            const armor = tx.moveCall({
                target: `${PKG}::items::armor`,
                arguments: [tx.pure.u8(1)],
            });

            tx.moveCall({ target: `${PKG}::recruit::add_armor`, arguments: [recruit, armor] });
            tx.moveCall({ target: `${PKG}::commander::place_recruit`, arguments: [game, recruit] });
        }

        // register the game in the Commander object.
        tx.moveCall({
            target: `${PKG}::commander::register_game`,
            arguments: [registryArg, tx.object.clock(), game],
        });

        tx.moveCall({ target: `${PKG}::commander::share`, arguments: [game] });

        const res = await executeTransaction!(tx);
        const gameRef = findGameRef(res, "Created");
        sessionStorage.setItem(LS_KEY, gameRef.objectId);
        return gameRef;
    }

    async function hostGame(preset: Preset & ObjectRef) {
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.moveCall({
            target: `${PKG}::commander::host_game`,
            arguments: [tx.object(REGISTRY), tx.object.clock(), tx.receivingRef(preset)],
        });

        const myRecruits = preset.positions.length / 2;
        for (let i = 0; i < myRecruits; i++) {
            const recruit = newRecruit(tx);
            tx.moveCall({ target: `${PKG}::commander::place_recruit`, arguments: [game, recruit] });
        }

        tx.moveCall({ target: `${PKG}::commander::share`, arguments: [game] });

        const res = await executeTransaction!(tx);
        const gameRef = findGameRef(res, "Created");
        sessionStorage.setItem(LS_KEY, gameRef.objectId);
        return gameRef;
    }

    async function joinGame(host: Host) {
        if (!canTransact) return;

        const { object } = await client.core.getObject({
            objectId: host.gameId,
            include: { content: true },
        });

        const positions = Game.parse(object.content).positions;

        const tx = new Transaction();
        const gameArg = tx.object(host.gameId);
        tx.moveCall({
            target: `${PKG}::commander::join_game`,
            arguments: [tx.object(REGISTRY), gameArg, tx.receivingRef(host)],
        });

        for (let i = 0; i < positions.length; i++) {
            const recruit = newRecruit(tx);
            tx.moveCall({
                target: `${PKG}::commander::place_recruit`,
                arguments: [gameArg, recruit],
            });
        }

        tx.setSender(account!.address);

        const res = await executeTransaction!(tx);
        const gameRef = findGameRef(res, "None");
        sessionStorage.setItem(LS_KEY, gameRef.objectId);
    }

    /** Perform ranged attack. I've been waiting for this soooo long */
    async function performAttack(unit: [number, number], target: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${PKG}::commander::perform_attack`,
            arguments: [
                sharedGame(tx),
                tx.object.random(),
                tx.pure.u16(unit[0]),
                tx.pure.u16(unit[1]),
                tx.pure.u16(target[0]),
                tx.pure.u16(target[1]),
            ],
        });

        const res = await simulate(tx);
        setLockedTx(tx);

        return { res, tx };
    }

    async function performReload(unit: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${PKG}::commander::perform_reload`,
            arguments: [sharedGame(tx), tx.pure.u16(unit[0]), tx.pure.u16(unit[1])],
        });

        const res = await simulate(tx);
        setLockedTx(tx);

        return { res, tx };
    }

    async function performGrenade(from: [number, number], to: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${PKG}::commander::perform_grenade`,
            arguments: [
                sharedGame(tx),
                tx.object.random(),
                tx.pure.u16(from[0]),
                tx.pure.u16(from[1]),
                tx.pure.u16(to[0]),
                tx.pure.u16(to[1]),
            ],
        });

        const res = await simulate(tx);
        setLockedTx(tx);

        return { res, tx };
    }

    /** Move the unit on the map. The initial coordinate is the gridPosition of the unit. */
    async function moveUnit(path: [number, number][]) {
        if (!map) throw new Error("Map not found");
        if (!canTransact) throw new Error("Cannot transact");

        const tx = new Transaction();
        const pathArg = tx.pure(bcs.vector(bcs.u8()).serialize(coordinatesToPath(path)));

        tx.moveCall({
            target: `${PKG}::commander::move_unit`,
            arguments: [sharedGame(tx), pathArg],
        });

        const res = await simulate(tx);
        setLockedTx(tx);

        return { res, tx };
    }

    /** End the turn. */
    async function nextTurn() {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({ target: `${PKG}::commander::next_turn`, arguments: [sharedGame(tx)] });
        tx.setSender(account!.address);

        return await executeTransaction!(tx);
    }

    async function destroyGame(gameId: string, saveReplay: boolean) {
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${PKG}::commander::destroy_game`,
            arguments: [tx.object(REGISTRY), tx.object(gameId), tx.pure.bool(saveReplay)],
        });
        tx.setSender(account!.address);

        return await executeTransaction!(tx);
    }

    async function deleteReplay(replayId: string) {
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({ target: `${PKG}::replay::delete`, arguments: [tx.object(replayId)] });
        tx.setSender(account!.address);

        return await executeTransaction!(tx);
    }

    /** Publish a map to the registry. */
    async function publishMap(name: string, map: Uint8Array) {
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${PKG}::commander::publish_map`,
            arguments: [
                tx.object(REGISTRY),
                tx.pure.string(name),
                tx.pure(bcs.vector(bcs.u8()).serialize(map)),
            ],
        });
        tx.setSender(account!.address);

        return await executeTransaction!(tx);
    }

    /** Execute locked transaction */
    async function executeLocked() {
        if (!lockedTx) throw new Error("No locked transaction to execute");
        if (!canTransact) throw new Error("Cannot execute transaction");

        const res = await executeTransaction!(lockedTx);
        setLockedTx(null);
        return res;
    }

    // === Helpers ===

    /** Add a freshly named recruit to the transaction. */
    function newRecruit(tx: Transaction) {
        const { name, backstory } = generateRecruitName();
        return tx.moveCall({
            target: `${PKG}::recruit::new`,
            arguments: [tx.pure.string(name), tx.pure.string(backstory)],
        });
    }

    /** Mutable shared object input for the current game. */
    function sharedGame(tx: Transaction) {
        return tx.sharedObjectRef({
            objectId: map!.objectId,
            initialSharedVersion: map!.initialSharedVersion,
            mutable: true,
        });
    }

    /**
     * Simulate (dry-run) a transaction; throws `SimulationError` when the
     * transaction would fail on-chain.
     */
    async function simulate(tx: Transaction) {
        tx.setSender(account!.address);
        setIsChecking(true);

        try {
            const result = await client.core.simulateTransaction({
                transaction: tx,
                include: { effects: true, events: true },
            });

            if (result.FailedTransaction) {
                throw new SimulationError(result.FailedTransaction.status.error);
            }

            return result.Transaction;
        } finally {
            setIsChecking(false);
        }
    }

    /** Find the `Game` object created or mutated by the transaction. */
    function findGameRef(result: ExecutedTransaction, operation: "Created" | "None"): ObjectRef {
        const changed = result.effects.changedObjects.find(
            (object) =>
                object.idOperation === operation &&
                result.objectTypes[object.objectId] === `${PKG}::commander::Game`,
        );

        if (!changed) {
            throw new Error(`Game not found, something is off: ${result.status.error?.message}`);
        }

        return {
            objectId: changed.objectId,
            version: changed.outputVersion!,
            digest: changed.outputDigest!,
        };
    }
}
