// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Loader, Footer } from "./Components";
import { useEffect, useMemo, useState } from "react";
import { UI } from "./play/UI";
import { Camera, EventBus, models, loadModels, GameAction } from "../engine";
import { bcs, HistoryRecord } from "../types/bcs";
import { useGame } from "../hooks/useGame";
import { useGameRecruits } from "../hooks/useGameRecruits";
import { NavLink } from "react-router-dom";
import { fromBase64 } from "@mysten/bcs";
import { GameApp } from "./play/Game";
import { useGameTransactions } from "../hooks/useGameTransactions";
import { useNetworkVariable } from "../../../networkConfig";

export const SIZE = 10;
export const LS_KEY = "commander-v2";

/**
 * The main component of the game.
 */
export function Playground() {
    const packageId = useNetworkVariable("commanderV2PackageId");
    const camera = useMemo(() => loadCamera(), []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const [mapKey, setMapKey] = useState<string | null>(sessionStorage.getItem(LS_KEY));
    const { data: map, isFetching, isFetched } = useGame({ id: mapKey, enabled: true });
    const { data: recruits } = useGameRecruits({ recruits: map?.map.recruits || [] });
    const tx = useGameTransactions({ map });

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
    }, [models]);

    useEffect(() => {
        if (!map) return;

        eventBus.addEventListener("game:shoot:aim", onGameAim);
        eventBus.addEventListener("game:move:trace", onGameTrace);
        eventBus.addEventListener("game:reload:perform", onGameReload);
        eventBus.addEventListener("game:grenade:target", onGameGrenade);
        eventBus.addEventListener("ui:next_turn", onNextTurn);

        console.log("game", map.objectId);

        return () => {
            eventBus.removeEventListener("game:shoot:aim", onGameAim);
            eventBus.removeEventListener("game:move:trace", onGameTrace);
            eventBus.removeEventListener("game:reload:perform", onGameReload);
            eventBus.removeEventListener("game:grenade:target", onGameGrenade);
            eventBus.removeEventListener("ui:next_turn", onNextTurn);
        };
    }, [map, tx, eventBus, tx.lockedTx]); // mind the `tx` dependency here!

    /**
     * Submit the locked transaction when the user clicks the confirm button.
     * This event listener is reset every time a transaction is executed.
     */
    useEffect(() => {
        eventBus.addEventListener("ui:confirm", onConfirm);
        return () => eventBus.removeEventListener("ui:confirm", onConfirm);
    }, [tx.lockedTx, map]);

    const centerDiv = (children: any) => (
        <div className="text-center bg-black/40 w-full h-full flex flex-col items-center justify-center">
            {children}
        </div>
    );

    if (isFetching || (tx.isExecuting && !map)) return <Loader />;
    if (isFetched && !map)
        return centerDiv(
            <>
                <p>Map not found</p>
                <button
                    onClick={() => {
                        sessionStorage.removeItem(LS_KEY);
                        setMapKey(null);
                    }}
                >
                    Back
                </button>
            </>,
        );
    if (!modelsLoaded) return centerDiv("Models not loaded");
    if (!map)
        return (
            <div className="flex justify-between flex-col w-full">
                <div className="text-left p-10 max-w-xl">
                    <h1 className="p-1 mb-10 page-heading">play</h1>
                </div>
                <div className="p-10 max-w-3xl">
                    <a
                        className="options-row interactive"
                        onClick={async () => {
                            const map = await tx.createDemo(1, [
                                [0, 3],
                                [6, 5],
                            ]);
                            eventBus.dispatchEvent({ type: "sui:map_created" });
                            setTimeout(() => map && setMapKey(map.objectId), 1000);
                        }}
                    >
                        Create demo 1
                    </a>
                    <a
                        className="options-row interactive"
                        style={{ border: "1px solid grey" }}
                        onClick={async () => {
                            const map = await tx.createDemo(2, [
                                [8, 2],
                                [7, 6],
                                [1, 2],
                                [1, 7],
                            ]);
                            eventBus.dispatchEvent({ type: "sui:map_created" });
                            setTimeout(() => map && setMapKey(map.objectId), 1000);
                        }}
                    >
                        Create demo 2
                    </a>
                    <NavLink to="../editor" className="options-row mt-10 interactive">
                        Level Editor
                    </NavLink>
                </div>
                <Footer />
            </div>
        );

    return (
        <>
            <GameApp map={map} eventBus={eventBus} camera={camera} />
            <UI
                isExecuting={tx.isExecuting}
                recruits={recruits}
                turn={map.map.map.turn}
                eventBus={eventBus}
            />
        </>
    );

    // === Events Handling ===

    /** Listen to the ui:confirm event, trigger tx sending */
    async function onConfirm() {
        if (!tx.lockedTx) return;
        const res = await tx.executeLocked();
        const events = res.data.events || [];
        const eventType = `${packageId}::history::HistoryUpdated`;
        const historyBcs = events.find((e) => e.type == eventType)?.bcs;
        if (!historyBcs) return;
        const history = bcs.vector(HistoryRecord).parse(fromBase64(historyBcs));
        if (!history) return;

        eventBus.dispatchEvent({ type: "sui:tx_success", history });

        const first = history[0]!; // the first record cannot be an empty

        switch (first.$kind) {
            case "Reload":
                return eventBus.dispatchEvent({
                    type: "sui:reload",
                    success: true,
                    unit: first.Reload as [number, number],
                });

            case "NextTurn":
                return eventBus.dispatchEvent({
                    type: "sui:next_turn",
                    turn: map!.map.map.turn,
                });

            case "Move":
                return eventBus.dispatchEvent({
                    type: "sui:path",
                    path: first.Move as [number, number][],
                });
            case "Attack": {
                const unit = first.Attack.origin as [number, number];
                const targetUnit = first.Attack.target as [number, number];
                const result = history[1];
                if (!result)
                    throw new Error("History log is incorrect, only one attack record is present");

                if (result.$kind === "Miss") {
                    return eventBus.dispatchEvent({
                        type: "sui:attack",
                        unit,
                        targetUnit,
                        result: "Miss",
                        damage: 0,
                    });
                }

                if (result.$kind === "Damage") {
                    return eventBus.dispatchEvent({
                        type: "sui:attack",
                        unit,
                        targetUnit,
                        result: "Damage",
                        damage: result[result.$kind],
                    });
                }

                if (result.$kind === "CriticalHit") {
                    return eventBus.dispatchEvent({
                        type: "sui:attack",
                        unit,
                        targetUnit,
                        result: "CriticalHit",
                        damage: result[result.$kind],
                    });
                }

                throw new Error(`Unexpected record in the history log: ${result.$kind}`);
            }
            case "Grenade": {
                const result = history[1];
                console.log(history);
                if (!result)
                    throw new Error("History log is incorrect, only one grenade record is present");
                return eventBus.dispatchEvent({ type: "sui:grenade", success: true });
            }
        }
    }

    async function onGameTrace({ path }: GameAction["move:trace"]) {
        const result = await tx.moveUnit(path.map((p: THREE.Vector2) => [p.x, p.y])).catch((e) => {
            console.error(e);
            return false;
        });
        eventBus.dispatchEvent({
            type: "sui:trace",
            success: !!result,
        });
    }

    async function onGameGrenade({ unit, x: x1, y: y1 }: GameAction["grenade:target"]) {
        const { x: x0, y: y0 } = unit.gridPosition;
        const result = await tx.performGrenade([x0, y0], [x1, y1]);
        eventBus.dispatchEvent({
            type: "sui:grenade",
            success: !!result,
        });
    }

    async function onGameReload({ unit }: GameAction["reload:perform"]) {
        const { x, y } = unit.gridPosition as THREE.Vector2;
        const result = await tx.performReload([x, y]);
        eventBus.dispatchEvent({
            type: "sui:reload",
            unit: [x, y],
            success: !!result,
        });
    }

    async function onGameAim({ unit, targetUnit }: GameAction["shoot:aim"]) {
        const { x: x0, y: y0 } = unit.gridPosition as THREE.Vector2;
        const { x: x1, y: y1 } = targetUnit.gridPosition as THREE.Vector2;

        const result = await tx.performAttack([x0, y0], [x1, y1]);
        eventBus.dispatchEvent({
            type: "sui:aim",
            success: !!result,
        });
    }

    /** Next turn button is clicked in the UI */
    async function onNextTurn() {
        const res = await tx.nextTurn();
        if (!res) console.error("Failed to execute next turn transaction");
        if (map) {
            eventBus.dispatchEvent({
                type: "sui:next_turn",
                turn: ++map.map.map.turn,
            });
        }
    }
}

/**
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera() {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    camera.resetForSize(SIZE);
    return camera;
}
