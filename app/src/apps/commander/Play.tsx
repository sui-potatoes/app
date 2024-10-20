// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// NOTE:
// Due to EventDispatcher implementation in `Three.js`, we avoid using
// `useEffect` to track the selected unit. Instead, we use a `useRef`. And it's
// crucial to use specifically `useRef` instead of `useState` to allow value to
// persist between renders (and in the callback scope).

import { useEffect, useRef, useState } from "react";
import { UnitStats } from "./UnitStats";
import { Map } from "./three/Map";
import { SelectedAction, SelectedUnit, Game, TracedPath } from "./types";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiObjectId } from "@mysten/sui/utils";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { actionRange, markInRange } from "./state";
import { useTransactionExecutor } from "./useTransactionExecutor";

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
    const { executeTransaction } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair(),
        enabled: !!zkLogin.address,
    });
    const [action, selectAction] = useState<SelectedAction | null>(null);
    const unitRef = useRef<SelectedUnit | null>(null);
    // const actionRef = useRef<SelectedAction | null>(null);
    const [target, setTarget] = useState<{ x: number; y: number } | null>(null);

    const [wait, setWait] = useState(false);
    const [highlight, setHighlight] = useState<{ x: number; y: number; d: number }[]>([]);
    const canBypass = !!action && action.action?.inner.$kind === "Attack";

    // triggers re-render when the selected unit changes
    // (via the auto action selection)
    useEffect(() => {
        if (!unitRef.current) return;
        if (action) {
            setHighlight(markInRange(
                game.map,
                unitRef.current.x,
                unitRef.current.y,
                actionRange(unitRef.current.unit, action.action),
                canBypass,
            ))
        } else {
            setHighlight([])
        }
    }, [action]);

    useEffect(() => {
        if (!target) return;
        performSelectedAction(target.x, target.y).then(() => setWait(false));
    }, [target]);

    return (
        <div
            className="items-center flex"
            onContextMenu={(e) => {
                e.preventDefault();
            }}
        >
            <div className="max-md:flex max-md:flex-col max-md:justify-center max-md:items-center">
                <div className={`${wait ? "disabled" : ""}`}>
                    <Map
                        disabled={wait}
                        highlight={highlight}
                        grid={game.map}
                        onSelect={(unit, x, y) =>
                            setSelectedUnit(unit === null ? null : { unit, x, y })
                        }
                        onTarget={(x, y) => {
                            console.log("ontarget", unitRef.current);
                            setTarget({ x, y });
                            // performSelectedAction(x, y).then(() => setWait(false));
                        }}
                    />
                </div>
            </div>
            <div className="flex flex-col justify-center">
                <h2 className="my-2 text-xl">Game</h2>
                <p className="">
                    <button onClick={() => destroy().then(() => setWait(false))}>
                        Destroy Game
                    </button>
                </p>
                <p className="mb-4">
                    <button onClick={() => nextTurn().then(() => setWait(false))}>
                        Next Turn ({game.turn + 1})
                    </button>
                </p>
                <UnitStats
                    game={game}
                    unit={unitRef.current?.unit || null}
                    onSelect={(idx, action) => {
                        selectAction({ idx, action });
                        // action = { idx, action };
                        // setCounter((c) => c + 1);
                        console.log("selected action", action);
                    }}
                />
            </div>
        </div>
    );

    async function performSelectedAction(x: number, y: number) {
        if (!zkLogin.address) return;
        if (!action) return;
        if (!unitRef.current) return;
        if (!game) return;
        if (wait) return;

        let timer: any;

        const unit = unitRef.current;

        setWait(true);

        // very silly check for now
        if (action.action.inner.$kind === "Move") {
            const maxRange = unit.unit.ap.value / action.action.cost;
            const range = Math.abs(unit.x - x) + Math.abs(unit.y - y);

            if (game.map.grid[x][y].$kind !== "Empty") return console.log("not empty");
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

            // await moveObject(unit.x, unit.y, parsedPath);

            const unitData = { ...game.map.grid[unit.x][unit.y] };
            let prev = { x: unit.x, y: unit.y };
            timer = setInterval(() => {
                if (parsedPath.length === 0) {
                    return clearInterval(timer);
                }

                game.map.grid[prev.x][prev.y] = { Empty: true, $kind: "Empty" };
                const { x, y } = parsedPath.shift()!; // @ts-ignore
                unitData.Unit!.unit.ap.value -= action.action.cost;

                unit.x = x;
                unit.y = y;

                game.map.grid[x][y] = unitData;
                setGame(() => ({ ...game }));
                prev = { x, y };
            }, 200);
        }

        if (action.action.inner.$kind === "Attack") {
            if (game.map.grid[x][y].$kind !== "Unit") return console.log("no unit");

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

        const txResult = await executeTransaction(tx)!;
        // const { digest } = await executeTransaction(tx)!;
        // await client.waitForTransaction({ digest });

        console.log(txResult);

        clearInterval(timer);
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

        const { digest } = await executeTransaction(tx)!;
        await client.waitForTransaction({ digest });

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

        const { digest } = await executeTransaction(tx)!;
        await client.waitForTransaction({ digest });
        refetch();
    }

    function setSelectedUnit(unit: SelectedUnit | null) {
        if (!game) return;

        unitRef.current = unit;
        setTarget(null);

        if (!unit || !unitRef.current) {
            setHighlight([])
            return;
        }

        if (game.turn > unitRef.current.unit.turn) {
            unitRef.current.unit.turn = game.turn;
            unitRef.current.unit.ap.value = unitRef.current.unit.ap.maxValue;
        }

        if (action) {
            setHighlight(markInRange(
                game.map,
                unitRef.current.x,
                unitRef.current.y,
                actionRange(unitRef.current.unit, action.action),
                canBypass,
            ))
        } else {
            setHighlight([])
        }
    }
}
