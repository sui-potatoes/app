// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { Transaction } from "@mysten/sui/transactions";
import { useEffect, useState } from "react";
import { Action, Game, TracedPath, Unit } from "./types";
import { Map } from "./Map";
import { fromB64 } from "@mysten/bcs";
import { UnitStats } from "./UnitStats";

import "./commander.css";
import { normalizeSuiObjectId } from "@mysten/sui/utils";

type SelectedAction = {
    idx: number;
    action: typeof Action.$inferType;
};

type SelectedUnit = {
    unit: typeof Unit.$inferType;
    x: number;
    y: number;
};

export default function Commander() {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const [game, setGame] = useState<typeof Game.$inferType | null>(null);
    const [action, selectAction] = useState<SelectedAction | null>(null);
    const [unit, setUnit] = useState<SelectedUnit | null>(null);
    const [wait, setWait] = useState(false);
    const packageId = useNetworkVariable("commanderPackageId");
    const { data, isPending, refetch, error } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address || "",
            filter: { StructType: `${packageId}::commander::Game` },
            options: { showBcs: true },
        },
        { enabled: !!zkLogin.address },
    );

    useEffect(() => {
        if (!data) return;
        if (!data.data[0]) return;
        if (!data.data[0].data) return;

        const { bcsBytes } = data.data[0].data.bcs as { bcsBytes: string };

        const game = Game.parse(fromB64(bcsBytes));
        setGame(game);
    }, [data]);

    if (isPending) return <p>Loading...</p>;
    if (error) return <p>Error: {error.message}</p>;
    if (game === null)
        return (
            <>
                <h1>Commander</h1>
                <p>Package ID: {packageId}</p>
                <p>
                    <button
                        disabled={!zkLogin.address}
                        onClick={() => newPreset()}
                    >
                        New Game (Preset)
                    </button>
                </p>
                <p>
                    <button
                        disabled={!zkLogin.address}
                        onClick={() => newGame()}
                    >
                        New Game (Custom)
                    </button>
                </p>
            </>
        );

    return (
        // I want tailwind columns, so that the map is 2/3 of the screen and the unit stats are 1/3
        <div className="grid grid-cols-6">
            <div className={`${wait ? "disabled" : ""} col-span-4 gap-1`}>
                <Map
                    grid={game.map}
                    onSelect={(unit, x, y) =>
                        unit === null ? setUnit(null) : setUnit({ unit, x, y })
                    }
                    onPoint={(unit, x, y) => {
                        performSelectedAction(unit, x, y).then(() =>
                            setWait(false),
                        );
                    }}
                />
                <p className="mt-4">
                    <button
                        className="mx-2"
                        onClick={() => destroy().then(() => setWait(false))}
                    >
                        Destroy Game
                    </button>
                    <button
                        className="mx-2"
                        onClick={() => nextTurn().then(() => setWait(false))}
                    >
                        Next Turn ({game.turn + 1})
                    </button>
                </p>
            </div>
            <div className="col-span-1">
                <UnitStats
                    game={game}
                    unit={unit?.unit || null}
                    onSelect={(idx, action) => selectAction({ idx, action })}
                />
            </div>
        </div>
    );

    async function newPreset() {
        if (!zkLogin.address) return;

        const tx = new Transaction();
        const game = tx.moveCall({ target: `${packageId}::commander::preset` });
        tx.transferObjects([game], zkLogin.address!);

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        await refetch();
    }

    async function newGame() {
        if (!zkLogin.address) return;

        const tx = new Transaction();
        const game = tx.moveCall({
            target: `${packageId}::commander::new`,
            arguments: [tx.pure.u16(10), tx.pure.u16(10)], // width, height
        });

        tx.transferObjects([game], zkLogin.address!);

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        await refetch();
    }

    async function performSelectedAction(
        _unit: typeof Unit.$inferType,
        x: number,
        y: number,
    ) {
        if (!zkLogin.address) return;
        if (!action) return;
        if (!unit) return;
        if (!game) return;
        if (wait) return;

        let timer: any;

        setWait(true);

        // very silly check for now
        if (action.action.inner.$kind === "Move") {
            const maxRange = unit.unit.ap.value / action.action.cost;
            const range = Math.abs(unit.x - x) + Math.abs(unit.y - y);

            if (game.map.grid[x][y].$kind !== "Empty")
                return console.log("not empty");

            if (range > maxRange) return console.log("out of range");

            const inspect = new Transaction();
            inspect.moveCall({
                target: `${packageId}::commander::trace_path`,
                arguments: [
                    inspect.object(normalizeSuiObjectId(game.id)),
                    inspect.pure.u16(maxRange),
                    inspect.pure.u16(unit.x),
                    inspect.pure.u16(unit.y),
                    inspect.pure.u16(x),
                    inspect.pure.u16(y),
                ],
            });

            const result = await client.devInspectTransactionBlock({
                sender: zkLogin.address!,
                transactionBlock: inspect as any,
            });

            // kill me
            if (!result) return console.log("no result");
            if (!result.results) return console.log("no results");
            if (!result.results[0]) return console.log("no result 0");

            const [path] = result.results[0].returnValues as any[];
            const parsedPath = TracedPath.parse(new Uint8Array(path[0]));

            if (!parsedPath) return console.log("no path");

            const unitData = { ...game.map.grid[unit.x][unit.y] };
            let prev = { x: unit.x, y: unit.y };
            timer = setInterval(() => {
                if (parsedPath.length === 0) {
                    clearInterval(timer);
                    return;
                }

                game.map.grid[prev.x][prev.y] = { Empty: true, $kind: "Empty" };
                const { x, y } = parsedPath.shift()!;
                game.map.grid[x][y] = unitData;
                setGame(() => ({ ...game }));
                prev = { x, y };
            }, 300);
        }

        if (action.action.inner.$kind === "Attack") {
            if (game.map.grid[x][y].$kind !== "Unit")
                return console.log("no unit");

            const target = game.map.grid[x][y].Unit!.unit;
            const { damage, maxRange } = action.action.inner.Attack;

            if (Math.abs(unit.x - x) + Math.abs(unit.y - y) > maxRange) {
                return console.log("out of range");
            }

            if (target.health.value <= damage) {
                alert("You killed the enemy!");
                game.map.grid[x][y] = { Empty: true, $kind: "Empty" };
            }
        }

        if (action.action.inner.$kind === "Skip") {
            x = 0;
            y = 0;
        }

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::commander::perform_action`,
            arguments: [
                tx.object(normalizeSuiObjectId(game.id)),
                tx.pure.u16(unit.x),
                tx.pure.u16(unit.y),
                tx.pure.u16(action.idx),
                tx.pure.u16(x),
                tx.pure.u16(y),
            ],
        });

        const effects = await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
            options: { showObjectChanges: true, showRawEffects: true },
        });

        clearInterval(timer);
        console.log(effects);
        await refetch();

        console.log(`performing action ${action?.action.name}`, unit, x, y);
    }

    async function destroy() {
        if (!zkLogin.address) return;
        if (!game) return;
        if (wait) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::commander::destroy`,
            arguments: [tx.object(normalizeSuiObjectId(game.id))],
        });

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
            options: { showObjectChanges: true },
        });

        setGame(null);

        await refetch();
    }

    async function nextTurn() {
        if (!zkLogin.address) return;
        if (!game) return;
        if (wait) return;

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::commander::next_turn`,
            arguments: [tx.object(normalizeSuiObjectId(game.id))],
        });

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
            options: { showObjectChanges: true },
        });

        await refetch();
    }
}
