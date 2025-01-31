// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// import { NavLink } from "react-router-dom";
// import { createScene } from "./engine/scene";
// import { useEffect } from "react";
import { Canvas, extend, useFrame, useThree } from "@react-three/fiber";
import { Camera } from "./engine/Camera";
import { useEffect, useMemo, useState } from "react";
import { Game } from "./engine/Game";
import { loadModels, models } from "./engine/models";
import { Controls } from "./engine/Controls";
import JEASINGS from "jeasings";
import { MoveMode } from "./engine/modes/MoveMode";
import { ShootMode } from "./engine/modes/ShootMode";
import { GrenadeMode } from "./engine/modes/GrenadeMode";
import { EditMode } from "./engine/modes/EditMode";
import { NoneMode } from "./engine/modes/NoneMode";
import { Stats } from "@react-three/drei";
import { GameMap, useGame } from "./hooks/useGame";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { useSuiClient } from "@mysten/dapp-kit";
import { EventBus } from "./engine/EventBus";

extend({ Camera, Game });

declare module "@react-three/fiber" {
    interface ThreeElements {
        game: Game;
    }
}

export const SIZE = 10;
export const LS_KEY = "commander-v2";

export function Playground() {
    const packageId = useNetworkVariable("commanderV2PackageId");
    const client = useSuiClient() as any;
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const camera = useMemo(loadCamera, []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const localKey = localStorage.getItem(LS_KEY);
    const { data: map, isFetching, isFetched } = useGame({ id: localKey, enabled: true });

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
        eventBus.dispatchEvent({ type: "three", action: "models_loaded" });
        eventBus.all((_event) => {}); // subscribe to all events if needed
    }, [models]);

    const centerDiv = (children: any) => (
        <div className="text-center bg-black/40 w-full h-full flex items-center justify-center">
            {children}
        </div>
    );

    if (isFetching) return centerDiv("Loading...");
    if (isFetched && !map) return centerDiv("Map not found");
    if (!modelsLoaded) return centerDiv("Models not loaded");
    if (!map)
        return centerDiv(
            <div className="block">
                <h1 className="mb-10">Map not found</h1>
                <button onClick={() => createMap()}>create demo 1</button>
            </div>,
        );

    if (map) {
        const size = map.map.map.grid[0].length;
        camera.resetForSize(size);
    }

    return (
        <>
            <Canvas camera={camera}>
                {modelsLoaded && map && <GameApp map={map} eventBus={eventBus} camera={camera} />}
                <Stats />
            </Canvas>
            <UI eventBus={eventBus} />
        </>
    );

    async function createMap() {
        if (isExecuting) return;
        if (!zkLogin.address) return;
        if (!executeTransaction) return;

        const tx = new Transaction();
        const r1 = tx.moveCall({ target: `${packageId}::recruit::default` });
        const r2 = tx.moveCall({ target: `${packageId}::recruit::default` });
        const game = tx.moveCall({ target: `${packageId}::commander::demo` });

        tx.moveCall({
            target: `${packageId}::commander::place_recruit`,
            arguments: [game, r1, tx.pure.u16(0), tx.pure.u16(3)],
        });

        tx.moveCall({
            target: `${packageId}::commander::place_recruit`,
            arguments: [game, r2, tx.pure.u16(6), tx.pure.u16(5)],
        });

        tx.moveCall({ target: `${packageId}::commander::share`, arguments: [game] });

        const res = await executeTransaction(tx)!.wait();
        const map = res.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!map) throw new Error("Map not found, something is off");
        if (map.type !== "created") throw new Error("Map not created, something is off");

        localStorage.setItem(LS_KEY, map.objectId);
        alert("Map created");

        eventBus.dispatchEvent({ type: "sui", action: "map_created" });
    }
}

export function GameApp({
    map,
    camera,
    eventBus,
}: {
    map: GameMap;
    camera: Camera;
    eventBus: EventBus;
}) {
    const { gl } = useThree();
    const game = useMemo(() => Game.fromBCS(map), [map]);
    const controls = useMemo(() => new Controls(game, gl.domElement), []);

    useFrame((root, delta) => {
        JEASINGS.update();
        controls.update(delta);
        const cursor = root.raycaster.intersectObject(game.plane)[0];
        game.update(cursor || null, delta);
        game.input(controls);
    });

    useEffect(() => {
        game.registerEventBus(eventBus);
        controls.connect();
        controls.addEventListener("scroll", ({ delta }) => {
            let newPosition = camera.position.z + delta * 0.01;
            if (newPosition >= 0 && newPosition < SIZE + 5) {
                camera.position.z = newPosition;
                camera.lookAt(camera.defaultTarget);
            }
        });

        controls.addEventListener("zoom", ({ delta }) => {
            let newPosition = camera.position.y + delta * 0.01;
            if (newPosition >= 0 && newPosition <= SIZE + 5) {
                camera.position.y = newPosition;
                camera.lookAt(camera.defaultTarget);
            }
        });

        eventBus.addEventListener("ui", ({ action }) => {
            switch (action) {
                case "confirm":
                    return game.performAction();
                case "move":
                    return game.switchMode(new MoveMode(controls));
                case "shoot":
                    return game.switchMode(new ShootMode(camera));
                case "grenade":
                    return game.switchMode(new GrenadeMode(controls));
                case "edit":
                    return game.switchMode(new EditMode(controls));
                case "cancel":
                    return game.switchMode(new NoneMode());
            }
        });
    }, []);

    return (
        <>
            <primitive object={game} />
            <ambientLight color={"white"} intensity={0.5} />
            <fog attach="fog" args={["white", 0.5, 200]} />
        </>
    );
}

const LOG_LENGTH = 5;

export function UI({ eventBus }: { eventBus: EventBus }) {
    const onAction = (action: string) => eventBus.dispatchEvent({ type: "ui", action });
    const button = (id: string) => (
        <button onClick={() => onAction(id)} className="action-button mb-2">
            {id}
        </button>
    );

    const [log, setLog] = useState<string[]>([]);

    useEffect(() => {
        eventBus.all((event) => {
            setLog((log) => {
                let { type, action } = event;
                let fullLog = [...log, `${type}: ${action ? action : ''}`];
                if (fullLog.length > LOG_LENGTH) fullLog = fullLog.slice(fullLog.length - 5);
                return fullLog;
            });
        });
    }, []);

    return (
        <div id="ui">
            <div
                id="panel-left"
                className="fixed h-full left-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {button("move")}
                {button("shoot")}
                {button("grenade")}
                <button onClick={() => onAction("end_turn")} className="action-button mt-40">
                    End Turn
                </button>
            </div>
            <div id="panel-bottom" className="fixed w-full text-xs bottom-0 left-0 p-0 text-center mb-10">
                {log.map((entry, i) => (<p key={'log-' + i} className="text-sm text-white">{entry}</p>))}
            </div>
            <div
                id="panel-right"
                className="fixed h-full right-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {button("confirm")}
                {button("cancel")}
                {button("edit")}
            </div>
        </div>
    );
}

function loadCamera() {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    camera.resetForSize(SIZE);
    return camera;
}
