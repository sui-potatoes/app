// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useState } from "react";
import { useNetworkVariable } from "../../../networkConfig";
import { useNameGenerator } from "./useNameGenerator";
import { Transaction, TransactionObjectInput, TransactionResult } from "@mysten/sui/transactions";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { GameMap } from "./useGame";
import { useSuiClient } from "@mysten/dapp-kit";
import { bcs } from "@mysten/bcs";
import { useTransactionExecutor } from "./useTransactionExecutor";
import { coordinatesToPath } from "../types/cursor";
import type { SuiObjectRef } from "@mysten/sui/client";
import { Preset } from "./useMaps";
import { Host } from "./useHostedGames";
import { useRecruits } from "./useRecruits";

export const LS_KEY = "commander-v2";

export function useGameTransactions({ map }: { map: GameMap | null | undefined }) {
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const registryId = useNetworkVariable("commanderV2RegistryId");
    const packageId = useNetworkVariable("commanderV2PackageId");
    const [lockedTx, setLockedTx] = useState<Transaction | null>(null);
    const [isChecking, setIsChecking] = useState(false);
    const { data: ownedRecruits, refetch: refetchRecruits } = useRecruits({
        owner: zkLogin.address!,
        enabled: !!zkLogin.address,
    });
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const canTransact = !!zkLogin.address && !isExecuting && executeTransaction;

    return {
        address: zkLogin.address,
        canTransact,
        lockedTx,
        createDemo,
        hostGame,
        joinGame,
        placeRecruits,
        publishMap,
        performAttack,
        performGrenade,
        performReload,
        destroyHostedGame,
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
    async function createDemo(preset: Preset & SuiObjectRef) {
        if (!canTransact) return;

        const tx = new Transaction();
        const registryArg = tx.object(registryId);
        const game = tx.moveCall({
            target: `${packageId}::commander::new_game`,
            arguments: [registryArg, tx.receivingRef(preset), tx.object.clock()],
        });

        const recruits = await getNumRecruits(tx, 2);

        // Register the game in the Commander object.
        tx.moveCall({
            target: `${packageId}::commander::register_game`,
            arguments: [registryArg, game, tx.object.clock()],
        });

        // Place recruits on the map.
        tx.moveCall({
            target: `${packageId}::commander::place_recruits`,
            arguments: [
                game,
                tx.makeMoveVec({
                    type: `${packageId}::recruit::Recruit`,
                    elements: recruits as any,
                }),
            ],
        });

        tx.moveCall({ target: `${packageId}::commander::share`, arguments: [game] });

        const res = await executeTransaction(tx);
        const map = res.data.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!map)
            throw new Error(`Map not found, something is off: ${res.data.effects?.status.error}`);
        if (map.type !== "created") throw new Error("Map not created, something is off");

        sessionStorage.setItem(LS_KEY, map.objectId);
        refetchRecruits();
        return map;
    }

    /** Host a multiplayer game, wait for players to join. */
    async function hostGame(
        preset: Preset & SuiObjectRef,
    ): Promise<{ host: SuiObjectRef; map: SuiObjectRef }> {
        if (!canTransact) throw new Error("Cannot transact");

        const tx = new Transaction();
        const game = tx.moveCall({
            target: `${packageId}::commander::host_game`,
            arguments: [tx.object(registryId), tx.receivingRef(preset), tx.object.clock()],
        });

        tx.moveCall({ target: `${packageId}::commander::share`, arguments: [game] });

        const res = await executeTransaction(tx);
        const host = res.data.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Host`
            );
        });
        const map = res.data.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!host) {
            throw new Error(`Host not found, something is off: ${res.data.effects?.status.error}`);
        }

        if (!map) {
            throw new Error(`Map not found, something is off: ${res.data.effects?.status.error}`);
        }

        if (map.type !== "created" || host.type !== "created") {
            throw new Error("Map or Host not created, something is off");
        }

        sessionStorage.setItem(LS_KEY, map.objectId);
        return { host, map };
    }

    /** Join a multiplayer game, place recruits right away. */
    async function joinGame(host: Host) {
        if (!canTransact) return;

        const game = await client.getObject({
            id: host.gameId,
            options: { showBcs: true, showOwner: true },
        });

        if (!game || !game.data || !game.data.bcs || game.data.bcs.dataType !== "moveObject") {
            throw new Error("Game not found");
        }

        const tx = new Transaction();
        const gameArg = tx.object(host.gameId);
        tx.moveCall({
            target: `${packageId}::commander::join_game`,
            arguments: [tx.object(registryId), gameArg, tx.receivingRef(host), tx.object.clock()],
        });

        const recruits = await getNumRecruits(tx, 2);

        tx.moveCall({
            target: `${packageId}::commander::place_recruits`,
            arguments: [
                gameArg,
                tx.makeMoveVec({
                    type: `${packageId}::recruit::Recruit`,
                    elements: recruits as any,
                }),
            ],
        });

        tx.setSender(zkLogin.address!);

        const res = await executeTransaction(tx);
        const map = res.data.objectChanges?.find((change) => {
            return (
                change.type === "mutated" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!map)
            throw new Error(`Map not found, something is off: ${res.data.effects?.status.error}`);
        if (map.type !== "mutated") throw new Error("Map not created, something is off");

        sessionStorage.setItem(LS_KEY, map.objectId);
    }

    /** In a multiplayer game, place the recruits on the map. */
    async function placeRecruits(game: string) {
        if (!canTransact) return;

        const tx = new Transaction();
        const gameArg = tx.object(game);
        const recruits = await getNumRecruits(tx, 2);

        tx.moveCall({
            target: `${packageId}::commander::place_recruits`,
            arguments: [
                gameArg,
                tx.makeMoveVec({
                    type: `${packageId}::recruit::Recruit`,
                    elements: recruits as any,
                }),
            ],
        });

        return await executeTransaction(tx);
    }

    /** Perform ranged attack. I've been waiting for this soooo long */
    async function performAttack(unit: [number, number], target: [number, number]) {
        if (!map) return;
        if (!canTransact) return;
        setIsChecking(true);

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
                tx.object.clock(),
            ],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setIsChecking(false);
        setLockedTx(tx);

        return { res, tx };
    }

    /** Perform reload. */
    async function performReload(unit: [number, number]) {
        if (!map) return;
        if (!canTransact) return;
        setIsChecking(true);

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({
            target: `${packageId}::commander::perform_reload`,
            arguments: [game, tx.pure.u16(unit[0]), tx.pure.u16(unit[1]), tx.object.clock()],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setIsChecking(false);
        setLockedTx(tx);

        return { res, tx };
    }

    async function performGrenade(from: [number, number], to: [number, number]) {
        if (!map) return;
        if (!canTransact) return;
        setIsChecking(true);
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
                tx.object.clock(),
            ],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setIsChecking(false);
        setLockedTx(tx);

        return { res, tx };
    }

    /** Move the unit on the map. The initial coordinate is the gridPosition of the unit. */
    async function moveUnit(path: [number, number][]) {
        if (!map) throw new Error("Map not found");
        if (!canTransact) throw new Error("Cannot transact");
        setIsChecking(true);

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        const pathArg = tx.pure(bcs.vector(bcs.u8()).serialize(coordinatesToPath(path)));

        tx.moveCall({
            target: `${packageId}::commander::move_unit`,
            arguments: [game, pathArg, tx.object.clock()],
        });
        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        setIsChecking(false);
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

        tx.moveCall({
            target: `${packageId}::commander::next_turn`,
            arguments: [game, tx.object.clock()],
        });
        tx.setSender(zkLogin.address!);

        return await executeTransaction(tx);
    }

    async function destroyGame(gameId: string, saveReplay: boolean) {
        if (!canTransact) return;

        const tx = new Transaction();
        const opt = tx.moveCall({
            target: `0x1::option::none`,
            typeArguments: [`0x2::transfer::Receiving<${packageId}::commander::Host>`],
        });

        const replay = tx.moveCall({
            target: `${packageId}::commander::destroy_game`,
            arguments: [tx.object(registryId), tx.object(gameId), opt],
        });

        if (saveReplay) {
            tx.transferObjects([replay], zkLogin.address!);
        } else {
            tx.moveCall({
                target: `${packageId}::replay::delete`,
                arguments: [replay],
            });
        }

        tx.setSender(zkLogin.address!);

        return await executeTransaction(tx);
    }

    async function destroyHostedGame(gameId: string, host: SuiObjectRef) {
        if (!canTransact) throw new Error("Cannot transact");

        const tx = new Transaction();
        const opt = tx.moveCall({
            target: `0x1::option::some`,
            arguments: [tx.receivingRef(host)],
            typeArguments: [`0x2::transfer::Receiving<${packageId}::commander::Host>`],
        });

        const replay = tx.moveCall({
            target: `${packageId}::commander::destroy_game`,
            arguments: [tx.object(registryId), tx.object(gameId), opt],
        });

        tx.moveCall({
            target: `${packageId}::replay::delete`,
            arguments: [replay],
        });

        tx.setSender(zkLogin.address!);

        return await executeTransaction(tx);
    }

    async function deleteReplay(replayId: string) {
        if (!canTransact) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::replay::delete`,
            arguments: [tx.object(replayId)],
        });
        tx.setSender(zkLogin.address!);

        return await executeTransaction(tx);
    }

    /** Publish a map to the registry. */
    async function publishMap(name: string, map: Uint8Array) {
        if (!canTransact) return;

        const tx = new Transaction();
        const nameArg = tx.pure.string(name);
        const mapBytesArg = tx.pure(bcs.vector(bcs.u8()).serialize(map));

        tx.moveCall({
            target: `${packageId}::commander::publish_map`,
            arguments: [tx.object(registryId), nameArg, mapBytesArg],
        });
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

    /** Pull recruits from the owner's inventory and create new ones if needed. */
    async function getNumRecruits(tx: Transaction, limit: number) {
        const ownedLen = ownedRecruits?.length || 0;
        const recruits: (TransactionResult | TransactionObjectInput)[] = [
            ...(ownedRecruits || []).slice(0, limit).map((r) => tx.objectRef(r)),
        ];

        limit = Math.min(ownedLen, limit);

        // If we don't have enough recruits, create new ones.
        for (let i = limit; i < 2; i++) {
            const { name, backstory } = await useNameGenerator();
            const recruit = tx.moveCall({
                target: `${packageId}::recruit::new`,
                arguments: [tx.pure.string(name), tx.pure.string(backstory)],
            });

            recruits.push(recruit);
        }

        return recruits;
    }
}
