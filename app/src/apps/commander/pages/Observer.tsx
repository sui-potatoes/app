// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useParams } from "react-router-dom";
import { GameMap, useGame } from "../hooks/useGame";
import { useEffect, useMemo, useState } from "react";
import { GameApp } from "./play/Game";
import { Camera, EventBus, loadModels } from "../engine";
import { Footer, Loader } from "./Components";

export function Observer() {
    const { gameId } = useParams();
    const camera = useMemo(() => loadCamera(), []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const [initialGame, setInitialGame] = useState<GameMap>();
    const [_historyIdx, setHistoryIdx] = useState(0);
    const { data: game } = useGame({ id: gameId!, refetchInterval: 1000 });
    const history = game?.map.history;

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
    }, []);

    // to prevent re-renders, we set initial game state just once and then
    // only call updates on history.
    useEffect(() => {
        if (!game || !!initialGame) return;
        setHistoryIdx(game.map.history.length);
        setInitialGame(game);
    }, [game]);

    if (!initialGame) return <Loader text="loading game" />;

    return (
        <>
            {modelsLoaded && (
                <GameApp
                    map={initialGame}
                    camera={camera}
                    eventBus={eventBus}
                    history={history}
                    orbit={true}
                />
            )}
            {!modelsLoaded && <Loader text="loading models" />}
            <div id="ui">
                <div
                    id="panel-bottom"
                    className="fixed w-full text-xs bottom-0 left-0 p-0 text-center mb-10 normal-case overflow-auto h-20"
                >
                    {game?.map.history.map((history, i) => (
                        <p key={"log-" + i} className="text-sm normal-case text-white">
                            {history.$kind}: {JSON.stringify(history[history.$kind])}
                        </p>
                    ))}
                </div>
            </div>
            <Footer to="../spectate" />
        </>
    );
}

/**
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera() {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 200);
    camera.resetForSize(10);
    return camera;
}
