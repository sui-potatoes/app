// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useState } from "react";
import { UnitStats } from "./UnitStats";
import { Map } from "./Map";
import { SelectedAction, SelectedUnit, Game, TracedPath, Unit } from "./types";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiObjectId } from "@mysten/sui/utils";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";

type Props = {
    game: typeof Game.$inferType;
    refetch: () => void;
    setGame: (game: any) => void;
};

export function Play({ game, refetch, setGame }: Props) {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const packageId = useNetworkVariable("commanderPackageId");
    const [action, selectAction] = useState<SelectedAction | null>(null);
    const [unit, setUnit] = useState<SelectedUnit | null>(null);
    const [wait, setWait] = useState(false);

    return (
        <div className="grid md:grid-cols-2 gap-5 items-center">
            <div className="max-md:flex max-md:flex-col gap-3 max-md:justify-center max-md:items-center">
                <div className={`${wait ? "disabled" : ""}`}>
                    <Map
                        grid={game.map}
                        onSelect={(unit, x, y) =>
                            unit === null
                                ? setUnit(null)
                                : setUnit({ unit, x, y })
                        }
                        onPoint={(unit, x, y) => {
                            performSelectedAction(unit, x, y).then(() =>
                                setWait(false),
                            );
                        }}
                    />
                </div>
            </div>
            <div className="flex flex-col justify-center">
                <h2 className="my-2 text-xl">Game</h2>
                <p className="">
                    <button
                        onClick={() => destroy().then(() => setWait(false))}
                    >
                        Destroy Game
                    </button>
                </p>
                <p className="mb-4">
                    <button
                        onClick={() => nextTurn().then(() => setWait(false))}
                    >
                        Next Turn ({game.turn + 1})
                    </button>
                </p>
                <UnitStats
                    game={game}
                    unit={unit?.unit || null}
                    onSelect={(idx, action) => selectAction({ idx, action })}
                />
            </div>
        </div>
    );

    async function performSelectedAction(
        _unit: typeof Unit.$inferType | null,
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

        if (game.turn > unit.unit.turn) {
            unit.unit.turn = game.turn;
            unit.unit.ap.value = unit.unit.ap.maxValue;
            setUnit({ ...unit });
        }

        // very silly check for now
        if (action.action.inner.$kind === "Move") {
            const maxRange = unit.unit.ap.value / action.action.cost;
            const range = Math.abs(unit.x - x) + Math.abs(unit.y - y);

            if (game.map.grid[x][y].$kind !== "Empty")
                return console.log("not empty");

            console.log(range, maxRange);

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
                unitData.Unit!.unit.ap.value -= action.action.cost;
                setUnit({ ...unit, x, y, unit: { ...unit.unit } });
                game.map.grid[x][y] = unitData;
                setGame(() => ({ ...game }));
                prev = { x, y };
            }, 200);
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
        refetch();
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
        refetch();
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
