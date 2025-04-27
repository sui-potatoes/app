// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Loader, Footer } from "./Components";
import { useEffect, useMemo, useState } from "react";
import { UI } from "./play/UI";
import { Camera, EventBus, loadModels, GameAction } from "../engine";
import { bcs, HistoryRecord } from "../types/bcs";
import { GameMap, useGame } from "../hooks/useGame";
import { useGameRecruits } from "../hooks/useGameRecruits";
import { NavLink } from "react-router-dom";
import { fromBase64 } from "@mysten/bcs";
import { GameApp } from "./play/Game";
import { useGameTransactions } from "../hooks/useGameTransactions";
import { useNetworkVariable } from "../../../networkConfig";
import { DryRunTransactionBlockResponse, SuiObjectRef } from "@mysten/sui/client";
import { parseVMError, vmAbortCodeToMessage } from "../types/abort_codes";
import { pathToCoordinates } from "../types/cursor";
import { Preset, useMaps } from "../hooks/useMaps";
import { formatAddress, normalizeSuiAddress } from "@mysten/sui/utils";
import { useSuinsName } from "../hooks/useSuinsName";
import { Host, useHostedGames } from "../hooks/useHostedGames";
import { timeAgo } from "../types/utils";
import { usePreset } from "../hooks/usePreset";
import { GameScreen } from "./Components";

export const SIZE = 10;
export const LS_KEY = "commander-v2";
export const HOST_KEY = "commander-v2-host";

type Mode = "single" | "multi" | "join";

/**
 * The main component of the game.
 */
export function Playground() {
    const packageId = useNetworkVariable("commanderV2PackageId");
    const camera = useMemo(() => loadCamera(), []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const [mapKey, setMapKey] = useState<string | null>(sessionStorage.getItem(LS_KEY));
    const [mode, setMode] = useState<Mode>("single");
    const [initialGame, setInitialGame] = useState<GameMap>();
    const [host, setHost] = useState<SuiObjectRef | null>(
        sessionStorage.getItem(HOST_KEY) ? JSON.parse(sessionStorage.getItem(HOST_KEY)!) : null,
    );
    const { data: game, isFetching, isFetched, refetch } = useGame({ id: mapKey, enabled: true });
    const { data: hostedGames } = useHostedGames({ enabled: !game, refetchInterval: 1000 });
    const { data: recruits } = useGameRecruits({ recruits: game?.map.recruits || [] });
    const { data: presets } = useMaps({ enabled: !game, refetchInterval: 1000 });
    const tx = useGameTransactions({ map: game });

    // Filter hosted games to show only the ones that are less than 3 minutes old.
    const filteredHostedGames = (hostedGames || []).filter(
        (game) => Date.now() - +game.timestampMs < 1000 * 60 * 3,
    );

    useEffect(() => {
        if (modelsLoaded) return;
        if (mapKey === null) return;

        loadModels().then(() => setModelsLoaded(true));
    }, [mapKey]);

    useEffect(() => {
        if (!game || !!initialGame) return;
        setInitialGame(game);
    }, [game]);

    useEffect(() => {
        if (!game) return;

        eventBus.addEventListener("game:shoot:aim", onGameAim);
        eventBus.addEventListener("game:move:trace", onGameTrace);
        eventBus.addEventListener("game:reload:perform", onGameReload);
        eventBus.addEventListener("game:grenade:target", onGameGrenade);
        eventBus.addEventListener("ui:next_turn", onNextTurn);
        eventBus.addEventListener("ui:exit", onExit);

        return () => {
            eventBus.removeEventListener("game:shoot:aim", onGameAim);
            eventBus.removeEventListener("game:move:trace", onGameTrace);
            eventBus.removeEventListener("game:reload:perform", onGameReload);
            eventBus.removeEventListener("game:grenade:target", onGameGrenade);
            eventBus.removeEventListener("ui:next_turn", onNextTurn);
            eventBus.removeEventListener("ui:exit", onExit);
        };
    }, [game, tx, eventBus, tx.lockedTx]); // mind the `tx` dependency here!

    /**
     * Submit the locked transaction when the user clicks the confirm button.
     * This event listener is reset every time a transaction is executed.
     */
    useEffect(() => {
        eventBus.addEventListener("ui:confirm", onConfirm);
        return () => eventBus.removeEventListener("ui:confirm", onConfirm);
    }, [tx.lockedTx, game]);

    // If the host is set and the game is in the PlacingRecruits state,
    // place the recruits, if it's your turn to do so.
    useEffect(() => {
        if (!game) return;

        const state = game.map.state;

        if (
            host &&
            state.$kind === "PlacingRecruits" &&
            state.PlacingRecruits.some((r) => r === tx.address)
        ) {
            tx.placeRecruits(game.objectId).then((res) => {
                eventBus.dispatchEvent({ type: "sui:recruits_placed", success: !!res });
            });
        }
    }, [game]);

    const centerDiv = (children: any) => (
        <div className="text-center bg-black/40 w-full h-full flex flex-col items-center justify-center">
            {children}
        </div>
    );

    if (!modelsLoaded && mapKey) return <Loader text="loading models" />;
    if (tx.isExecuting && !game) return <Loader text="creating game" />;
    if (isFetching) return <Loader text="loading game" />;
    if (isFetched && !game)
        return centerDiv(
            <>
                <p>Map not found</p>
                <button onClick={unsetMapKey}>Back</button>
            </>,
        );

    if (game && game.map.state.$kind === "Waiting") {
        return (
            <Loader text="waiting for players">
                <button
                    className="mt-10 px-4 py-2 interactive"
                    onClick={(e) => {
                        e.preventDefault();
                        confirm("Are you sure you want to stop waiting for players?") &&
                            quitHostedGame().then(() => unsetMapKey());
                    }}
                >
                    Quit Game
                </button>
            </Loader>
        );
    }

    if (!game)
        return (
            <GameScreen title="play">
                <div className="max-w-3xl w-full">
                    <h2 className="text-left text-3xl mb-4">Mode</h2>
                    <div className="flex justify-between mb-10">
                        <div
                            className={`interactive p-3 w-1/2 ${mode == "single" ? "selected" : ""}`}
                            onClick={() => setMode("single")}
                        >
                            Demo
                        </div>
                        <div
                            className={`interactive p-3 w-full ${mode == "multi" ? "selected" : ""}`}
                            onClick={() => setMode("multi")}
                        >
                            Host Multiplayer
                        </div>
                        <div
                            className={`interactive p-3 w-full ${mode == "join" ? "selected" : ""}`}
                            onClick={() => setMode("join")}
                        >
                            Join Multiplayer
                        </div>
                    </div>
                    {mode == "join" ? (
                        <>
                            <h2 className="text-left text-3xl py-4">Games</h2>
                            {filteredHostedGames.length == 0 && <p>No games available</p>}
                            {filteredHostedGames.map((game) => (
                                <HostedGameItem
                                    key={game.objectId}
                                    game={game}
                                    onSelect={(host) =>
                                        confirm("Join the game?") &&
                                        tx.joinGame(host).then(() => {
                                            setTimeout(() => refetch(), 1000);
                                        })
                                    }
                                />
                            ))}
                        </>
                    ) : (
                        <>
                            <h2 className="text-left text-3xl py-4">Choose Map</h2>
                            {presets
                                ?.sort((a, b) => a.map.id.localeCompare(b.map.id))
                                .slice(0, 10)
                                .map((preset) => (
                                    <a
                                        key={preset.objectId}
                                        className={`options-row ${tx.canTransact ? "interactive" : "non-interactive"}`}
                                        onClick={async () => {
                                            const map = await createGame(mode, preset);
                                            eventBus.dispatchEvent({ type: "sui:map_created" });
                                            setTimeout(() => map && setMapKey(map.objectId), 1000);
                                        }}
                                    >
                                        <MapItem preset={preset} />
                                    </a>
                                ))}
                        </>
                    )}
                    <h2 className="text-left text-3xl py-4 mt-10">Other</h2>
                    <NavLink to="../editor" className="options-row interactive">
                        Level Editor
                    </NavLink>
                    <NavLink to="../replays" className="options-row interactive">
                        Replays (preview)
                    </NavLink>
                </div>
            </GameScreen>
        );

    return (
        <>
            <GameApp map={game} history={game?.map.history} eventBus={eventBus} camera={camera} />
            <UI
                isExecuting={tx.isExecuting}
                isChecking={tx.isChecking}
                recruits={recruits}
                turn={game.map.map.turn}
                lastTurnTimestamp={+game.map.last_turn}
                turnTimeLimit={+game.map.time_limit}
                eventBus={eventBus}
            />
        </>
    );

    // === Initiation ===

    async function createGame(type: Mode, preset: Preset & SuiObjectRef) {
        switch (type) {
            case "join":
                throw new Error("Incompatible mode");
            case "single":
                return tx.createDemo(preset);
            case "multi":
                const { host, map } = await tx.hostGame(preset);
                setHost(host);
                sessionStorage.setItem(HOST_KEY, JSON.stringify(host));
                return map;
        }
    }

    async function quitHostedGame() {
        if (!host) throw new Error("No hosted game");
        if (!game) throw new Error("No map");

        return tx.destroyHostedGame(game.objectId, host);
    }

    // === Events Handling ===

    /** Listen to the `ui:confirm` event, trigger tx sending. */
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

        const first = history[0]!; // The first record cannot be an empty.

        switch (first.$kind) {
            case "Reload":
                return eventBus.dispatchEvent({
                    type: "sui:reload",
                    success: true,
                    unit: first.Reload as [number, number],
                });

            case "Move":
                return eventBus.dispatchEvent({
                    type: "sui:path",
                    path: pathToCoordinates(first.Move),
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

                if (result.$kind === "Dodged") {
                    return eventBus.dispatchEvent({
                        type: "sui:attack",
                        unit,
                        targetUnit,
                        result: "Dodged",
                        damage: 0,
                    });
                }

                throw new Error(`Unexpected record in the history log: ${result.$kind}`);
            }
            case "Grenade": {
                const result = history[1];
                if (!result)
                    throw new Error("History log is incorrect, only one grenade record is present");
                return eventBus.dispatchEvent({ type: "sui:grenade", success: true });
            }
        }
    }

    async function onGameTrace({ path }: GameAction["move:trace"]) {
        const result = await tx
            .moveUnit(path.map((p: THREE.Vector2) => [p.x, p.y]))
            .catch(catchDryRunError);

        eventBus.dispatchEvent({
            type: "sui:trace",
            success: !!result,
        });
    }

    async function onGameGrenade({ unit, x: x1, y: y1 }: GameAction["grenade:target"]) {
        const { x: x0, y: y0 } = unit.gridPosition;
        const result = await tx.performGrenade([x0, y0], [x1, y1]).catch(catchDryRunError);

        eventBus.dispatchEvent({
            type: "sui:grenade",
            success: !!result,
        });
    }

    async function onGameReload({ unit }: GameAction["reload:perform"]) {
        const { x, y } = unit.gridPosition as THREE.Vector2;
        const result = await tx.performReload([x, y]).catch(catchDryRunError);

        eventBus.dispatchEvent({
            type: "sui:reload",
            unit: [x, y],
            success: !!result,
        });
    }

    async function onGameAim({ unit, targetUnit }: GameAction["shoot:aim"]) {
        const { x: x0, y: y0 } = unit.gridPosition as THREE.Vector2;
        const { x: x1, y: y1 } = targetUnit.gridPosition as THREE.Vector2;

        const result = await tx.performAttack([x0, y0], [x1, y1]).catch(catchDryRunError);

        eventBus.dispatchEvent({
            type: "sui:aim",
            success: !!result,
        });
    }

    /** Next turn button is clicked in the UI */
    async function onNextTurn() {
        const result = await tx.nextTurn().catch(catchDryRunError);

        if (!result) throw new Error("Failed to execute next turn transaction");

        const events = result.data.events || [];
        const eventType = `${packageId}::history::HistoryUpdated`;
        const historyBcs = events.find((e) => e.type == eventType)?.bcs;
        if (!historyBcs) return;
        const history = bcs.vector(HistoryRecord).parse(fromBase64(historyBcs));
        if (!history) return;
        const first = history[0]; // the first record cannot be an empty
        if (!first?.NextTurn) throw new Error("NextTurn record is missing in the history log");

        eventBus.dispatchEvent({ type: "sui:tx_success", history });

        if (!result) console.error("Failed to execute next turn transaction");
        if (game) {
            eventBus.dispatchEvent({
                type: "sui:next_turn",
                turn: first.NextTurn,
            });
        }
    }

    async function onExit() {
        if (!game) return;

        const result = await tx.destroyGame(game.objectId, true).catch(catchDryRunError);
        if (host) sessionStorage.removeItem(HOST_KEY);
        if (!result) throw new Error("Failed to execute destroy game transaction");
        unsetMapKey();
    }

    /** Universal try-catch mechanism for all dry runs */
    function catchDryRunError(e: any): null {
        const cause = e.cause as DryRunTransactionBlockResponse & { executionErrorSource: string };
        const message = cause.executionErrorSource;
        const [mod, fun, code] = parseVMError(message);

        eventBus.dispatchEvent({
            type: "sui:dry_run_failed",
            message: vmAbortCodeToMessage(mod, fun, code),
            function: fun,
            module: mod,
            code,
        });

        return null;
    }

    function unsetMapKey() {
        sessionStorage.removeItem(LS_KEY);
        setMapKey(null);
    }
}

/**
 * A map item in the list of maps.
 * Displays the map name, popularity, and author.
 */
function MapItem({ preset }: { preset: Preset & SuiObjectRef }) {
    const name = useSuinsName({ address: preset.author });
    const size = preset.map.grid.length;

    return (
        <div className="flex flex-row justify-between w-full text-left">
            <p style={{ width: `18ch` }}>
                {preset.name.slice(0, 17)}
                {preset.name.length > 17 && "..."}
            </p>
            {/* size is of varying length, so we need to set a fixed width */}
            <p style={{ width: `18ch` }}>
                Size: {size}x{size}
            </p>
            <p style={{ width: `14ch` }}>Score: {preset.popularity}</p>
            <p style={{ width: `20ch` }}>
                By:{" "}
                {(name && `@${name}`) ||
                    (preset.author == normalizeSuiAddress("0x0") ? "system" : "unknown")}
            </p>
        </div>
    );
}

function HostedGameItem({
    game,
    onSelect,
}: {
    game: Host & SuiObjectRef;
    onSelect: (host: Host) => void;
}) {
    const name = useSuinsName({ address: game.host });
    const { data: preset } = usePreset({ id: game.presetId });

    return (
        <div
            className="flex flex-row justify-between w-full text-left interactive p-3"
            onClick={() => onSelect(game)}
        >
            <p>Map: {preset?.name || "..."}</p>
            <p>Host: {(name && `@${name}`) || formatAddress(game.host)}</p>
            <p>{timeAgo(+game.timestampMs)}</p>
        </div>
    );
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
