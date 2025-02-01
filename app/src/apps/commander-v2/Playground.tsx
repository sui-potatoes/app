// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Canvas, useFrame, useThree } from "@react-three/fiber";
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
import { EventBus, GameEvent } from "./engine/EventBus";
import { bcs } from "./types/bcs";
import * as THREE from "three";

export const SIZE = 10;
export const LS_KEY = "commander-v2";

/**
 * The main component of the game.
 */
export function Playground() {
    const packageId = useNetworkVariable("commanderV2PackageId");
    const client = useSuiClient();
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        client: client as any,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const camera = useMemo(loadCamera, []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const localKey = localStorage.getItem(LS_KEY);
    const { data: map, isFetching, isFetched, refetch } = useGame({ id: localKey, enabled: true });
    const [lockedTx, setLockedTx] = useState<Transaction | null>(null);

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
        eventBus.dispatchEvent({ type: "three", action: "models_loaded" });
        eventBus.all((_event) => {}); // subscribe to all events if needed
    }, [models]);

    useEffect(() => {
        if (!map) return;

        /** Listen to move performed event */
        async function onGameEvent(event: GameEvent["game"]) {
            if (event.action === "trace") {
                const result = await moveUnit(event.path.map((p: THREE.Vector2) => [p.x, p.y]));
                if (!result) return console.log("unable to move unit");
                setLockedTx(result.tx);
                eventBus.dispatchEvent({ type: "sui", action: "trace:success" });
            }

            if (event.action === "aim") {
                const { x: x0, y: y0 } = event.unit.gridPosition as THREE.Vector2;
                const { x: x1, y: y1 } = event.targetUnit.gridPosition as THREE.Vector2;

                const result = await performAttack([x0, y0], [x1, y1]);
                if (!result) return console.log("unable to perform attack");
                setLockedTx(result.tx);
                eventBus.dispatchEvent({ type: "sui", action: "aim:success" });
            }
        }

        async function onNextTurn(event: GameEvent["ui"]) {
            if (event.action === "next_turn") {
                const res = await nextTurn();
                if (!res) return console.log("unable to end turn");

                await executeTransaction(res.tx)!.wait();
                eventBus.dispatchEvent({ type: "sui", action: "next_turn:success" });
                if (map) {
                    map.map.map.turn += 1;
                }
            }
        }

        eventBus.addEventListener("game", onGameEvent);
        eventBus.addEventListener("ui", onNextTurn);

        return () => {
            eventBus.removeEventListener("game", onGameEvent);
            eventBus.removeEventListener("ui", onNextTurn);
        };
    }, [map, executeTransaction]);

    useEffect(() => {
        if (!lockedTx) return;

        /** Listen to the ui:confirm event, trigger tx sending */
        async function onConfirm(event: GameEvent["ui"]) {
            if (event.action === "confirm" && lockedTx && !isExecuting) {
                setLockedTx(null);
                const res = await executeTransaction(lockedTx)!.wait();
                eventBus.dispatchEvent({ type: "sui", action: "tx:success", effects: res.effects });
            }
        }

        eventBus.addEventListener("ui", onConfirm);
        return () => eventBus.removeEventListener("ui", onConfirm);
    }, [lockedTx]);

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
            <UI isExecuting={isExecuting} turn={map.map.map.turn} eventBus={eventBus} />
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
        eventBus.dispatchEvent({ type: "sui", action: "map_created" });
        refetch();
    }

    /** Perform ranged attack. I've been waiting for this soooo long */
    async function performAttack(unit: [number, number], target: [number, number]) {
        if (!map) return;
        if (isExecuting) return;
        if (!zkLogin.address) return;
        if (!executeTransaction) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        const rng = tx.object.random();

        tx.moveCall({
            target: `${packageId}::commander::perform_attack`,
            arguments: [
                game,
                rng,
                tx.pure.u16(unit[0]),
                tx.pure.u16(unit[1]),
                tx.pure.u16(target[0]),
                tx.pure.u16(target[1]),
            ],
        });

        tx.setSender(zkLogin.address);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        return { res, tx };
    }

    /** Move the unit on the map. The initial coordinate is the gridPosition of the unit. */
    async function moveUnit(path: [number, number][]) {
        if (!map) return;
        if (isExecuting) return;
        if (!zkLogin.address) return;
        if (!executeTransaction) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        const pathArg = tx.pure(bcs.vector(bcs.vector(bcs.u16())).serialize(path));

        tx.moveCall({ target: `${packageId}::commander::move_unit`, arguments: [game, pathArg] });
        tx.setSender(zkLogin.address);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        return { res, tx };
    }

    /** End the turn. */
    async function nextTurn() {
        if (!map) return;
        if (isExecuting) return;
        if (!zkLogin.address) return;
        if (!executeTransaction) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({ target: `${packageId}::commander::next_turn`, arguments: [game] });
        tx.setSender(zkLogin.address);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        return { res, tx };
    }
}

/**
 * The Game itself, rendered inside the `Canvas` component.
 */
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
    const game = useMemo(() => Game.fromBCS(map), []);
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

        eventBus.addEventListener("sui", ({ action }) => {
            if (action == "next_turn:success") {
                game.turn = game.turn + 1;
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

/**
 * The length of the log displayed in the UI.
 */
const LOG_LENGTH = 5;

/**
 * UI Component which renders buttons and emits events in the `eventBus` under the `ui` type.
 * Listens to the in-game events to render additional buttons and log the actions.
 */
export function UI({
    eventBus,
    isExecuting,
    turn,
}: {
    eventBus: EventBus;
    isExecuting?: boolean;
    turn: number;
}) {
    const onAction = (action: string) => eventBus.dispatchEvent({ type: "ui", action });
    const button = (id: string, disabled?: boolean, text?: string) => (
        <button
            onClick={() => onAction(id)}
            className={"action-button mb-2" + (disabled || isExecuting ? " disabled" : "")}
        >
            {text || id}
        </button>
    );

    const [panelDisabled, setPanelDisabled] = useState(true);
    const [shootMode, setShootMode] = useState(false);
    const [log, setLog] = useState<string[]>([]);

    useEffect(() => {
        eventBus.addEventListener("game", (event) => {
            if (event.action === "mode_switch") {
                if (event.mode instanceof ShootMode) setShootMode(true);
                else setShootMode(false);

                if (event.mode instanceof NoneMode) setPanelDisabled(true);
                else setPanelDisabled(false);
            }
        });

        eventBus.all((event) => {
            setLog((log) => {
                let { type, action } = event;
                let fullLog = [...log, `${type}: ${action ? action : ""}`];
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
                {button("grenade", true)}
                <button
                    onClick={() => onAction("next_turn")}
                    className={"action-button mt-40" + (isExecuting ? " disabled" : "")}
                >
                    End Turn ({turn})
                </button>
            </div>
            <div
                id="panel-bottom"
                className="fixed w-full text-xs bottom-0 left-0 p-0 text-center mb-10"
            >
                {log.map((entry, i) => (
                    <p key={"log-" + i} className="text-sm text-white">
                        {entry}
                    </p>
                ))}
            </div>
            <div
                id="panel-right"
                className="fixed h-full right-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {shootMode && button("next_target", false, ">")}
                {shootMode && button("prev_target", false, "<")}
                {button("confirm", panelDisabled)}
                {button("cancel", panelDisabled)}
                {button("edit")}
            </div>
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
