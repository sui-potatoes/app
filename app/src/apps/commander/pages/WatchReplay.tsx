// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useParams } from "react-router-dom";
import { Replay, Preset, HistoryRecord } from "../types/bcs";
import { fromBase64 } from "@mysten/sui/utils";
import { Footer, Loader } from "./Components";
import { useMemo, useState, useEffect } from "react";
import { Camera, EventBus, loadModels } from "../engine";
import { GameApp } from "./play/Game";
import { GameMap } from "../hooks/useGame";

export function WatchReplay() {
    const { gameId } = useParams();
    const camera = useMemo(() => loadCamera(), []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [initialGame, setInitialGame] = useState<GameMap>();
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const [sentHistory, setSentHistory] = useState<(typeof HistoryRecord.$inferType)[]>([]);

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
    }, []);

    const { data: replay, isFetching: isFetchingReplay } = useSuiClientQuery(
        "getObject",
        {
            id: gameId || "",
            options: { showBcs: true },
        },
        {
            enabled: !!gameId,
            select(data) {
                if (!data.data) return null;
                if (!data.data.bcs) return null;
                if (data.data.bcs.dataType !== "moveObject") return null;

                const bytes = fromBase64(data.data.bcs.bcsBytes);
                return Replay.parse(bytes);
            },
        },
    );

    const { data: preset, isFetching: isFetchingPreset } = useSuiClientQuery(
        "getObject",
        { id: replay?.presetId || "", options: { showBcs: true } },
        {
            enabled: !!replay?.presetId,
            select(data) {
                if (!data.data) return null;
                if (!data.data.bcs) return null;
                if (data.data.bcs.dataType !== "moveObject") return null;
                const bytes = fromBase64(data.data.bcs.bcsBytes);
                return Preset.parse(bytes);
            },
        },
    );

    useEffect(() => {
        if (!replay || !preset || !!initialGame) return;

        const placements = replay.history
            .filter((h) => h.$kind === "RecruitPlaced")
            .map((h) => [h.RecruitPlaced!.x, h.RecruitPlaced!.y]);

        const map = preset.map;
        placements.forEach(([x, y]) => {
            map.grid[x][y].unit = {
                recruit: "",
                ap: { value: 2, max_value: 2 },
                ammo: { value: 3, max_value: 3 },
                hp: { value: 10, max_value: 10 },
                grenade_used: false,
                last_turn: 0,
                stats: {} as any,
            };
        });

        const gameMap: GameMap = {
            objectId: "",
            version: "",
            digest: "",
            initialSharedVersion: "",
            map: {
                recruits: [],
                map: preset.map,
                id: "",
                history: [],
                players: [],
                positions: [],
            } as any,
        };

        setInitialGame(gameMap);
    }, [replay, preset]);

    useEffect(() => {
        if (!replay) return;
        if (!initialGame) return;
        if (!modelsLoaded) return;
        if (sentHistory.length >= replay.history.length) return;

        const offset = replay.history.filter((h) => h.$kind === "RecruitPlaced").length;

        setSentHistory(replay.history.slice(0, offset));

        const indexRef = { value: offset };
        const interval = setInterval(function nextRecord() {
            if (!replay) return;
            if (indexRef.value >= replay.history.length) {
                return clearInterval(interval);
            }

            const currentEvent = replay.history[indexRef.value];
            const newHistory = replay.history.slice(0, indexRef.value + 1);

            switch (currentEvent.$kind) {
                case "Attack":
                    // For Attack events, include the next event as well
                    setSentHistory(replay.history.slice(0, indexRef.value + 2));
                    indexRef.value += 2;
                    break;
                case "NextTurn":
                    // NextTurn event is emitted instantly.
                    setSentHistory(newHistory);
                    indexRef.value += 1;
                    nextRecord();
                    break;
                default:
                    setSentHistory(newHistory);
                    indexRef.value += 1;
                    break;
            }

            if (indexRef.value >= replay.history.length) {
                clearInterval(interval);
            }
        }, 3000);

        return () => clearInterval(interval);
    }, [modelsLoaded, replay, initialGame]);

    if (!gameId) return <div>No game id</div>;

    if (isFetchingReplay) return <Loader text="Fetching Replay..." />;
    if (replay == null) return <div>Replay not found</div>;

    if (isFetchingPreset) return <Loader text="Fetching Preset..." />;
    if (preset == null) return <div>Preset not found</div>;

    // Construct the Game object from the Replay and Preset.
    return (
        <>
            {modelsLoaded && initialGame && (
                <GameApp
                    map={initialGame}
                    camera={camera}
                    eventBus={eventBus}
                    history={sentHistory}
                    orbit={true}
                />
            )}
            {!modelsLoaded && <Loader text="Loading models..." />}
            <div id="ui">
                <div
                    id="panel-bottom"
                    className="fixed w-full text-xs bottom-0 left-0 p-0 text-center mb-10 normal-case overflow-auto h-20"
                >
                    {sentHistory.map((history, i) => (
                        <p key={"log-" + i} className="text-sm normal-case text-white">
                            {history.$kind}: {JSON.stringify(history[history.$kind])}
                        </p>
                    ))}
                </div>
            </div>
            <Footer to=".." />
        </>
    );
}

/**
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera() {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    camera.resetForSize(10);
    return camera;
}
