// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import JEASINGS from "jeasings";
import { Stats } from "@react-three/drei";
import { Loader } from "./Loader";
import { useEffect, useMemo, useState } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import {
    Game,
    Camera,
    Controls,
    Unit,
    MoveMode,
    GameEvent,
    EventBus,
    GrenadeMode,
    ShootMode,
    EditMode,
    NoneMode,
    ReloadMode,
    models,
    loadModels,
} from "./engine";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useSuiClient } from "@mysten/dapp-kit";

import { bcs, Recruit } from "./types/bcs";
import { GameMap, useGame } from "./hooks/useGame";
import { useGameRecruits } from "./hooks/useGameRecruits";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { useNetworkVariable } from "../../networkConfig";
import { useNameGenerator } from "./hooks/useNameGenerator";
import { Footer } from "./Footer";
import { NavLink } from "react-router-dom";

export const SIZE = 10;
export const LS_KEY = "commander-v2";

export type AttackEvent = {
    game: string;
    attacker: [number, number];
    target: [number, number];
    damage: number;
    hit_chance: number;
    is_dodged: boolean;
    is_missed: boolean;
    is_plus_one: boolean;
    is_crit: boolean;
    is_kia: boolean;
};

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
    const camera = useMemo(() => loadCamera(), []);
    const eventBus = useMemo(() => new EventBus(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const [mapKey, setMapKey] = useState<string | null>(sessionStorage.getItem(LS_KEY));
    const { data: map, isFetching, isFetched } = useGame({ id: mapKey, enabled: true });
    const { data: recruits } = useGameRecruits({ recruits: map?.map.recruits || [] });
    const [lockedTx, setLockedTx] = useState<Transaction | null>(null);
    const canTransact = !!zkLogin.address && !!executeTransaction && !isExecuting;

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
                eventBus.dispatchEvent({
                    type: "sui",
                    action: "trace",
                    message: "path checked",
                });
            }

            if (event.action === "aim") {
                const { x: x0, y: y0 } = event.unit.gridPosition as THREE.Vector2;
                const { x: x1, y: y1 } = event.targetUnit.gridPosition as THREE.Vector2;

                const result = await performAttack([x0, y0], [x1, y1]);
                if (!result) return console.log("unable to perform attack");
                setLockedTx(result.tx);
                eventBus.dispatchEvent({
                    type: "sui",
                    action: "aim",
                    message: "target within range",
                });
            }

            if (event.action === "reload") {
                const { x, y } = event.unit.gridPosition as THREE.Vector2;
                const result = await performReload([x, y]);
                if (!result) return console.log("unable to reload");
                setLockedTx(result.tx);
                eventBus.dispatchEvent({
                    type: "sui",
                    action: "reload",
                    message: "unit can reload",
                });
            }
        }

        async function onNextTurn(event: GameEvent["ui"]) {
            if (!executeTransaction) return;
            if (event.action === "next_turn") {
                const res = await nextTurn();
                if (!res) return console.log("unable to end turn");

                await executeTransaction(res.tx);
                if (map) {
                    const turn = ++map.map.map.turn;
                    eventBus.dispatchEvent({
                        type: "sui",
                        action: "next_turn",
                        message: "next turn: " + (turn + 1),
                        turn,
                    });
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

    /**
     * Submit the locked transaction when the user clicks the confirm button.
     * This event listener is reset every time a transaction is executed.
     */
    useEffect(
        function submitLockedTransaction() {
            if (!lockedTx) return;

            /** Listen to the ui:confirm event, trigger tx sending */
            async function onConfirm(event: GameEvent["ui"]) {
                if (event.action === "confirm" && lockedTx && canTransact) {
                    setLockedTx(null);
                    const res = await executeTransaction(lockedTx);
                    const events = res.data.events || [];
                    eventBus.dispatchEvent({
                        type: "sui",
                        action: "tx:success",
                        effects: res.effects,
                    });

                    events.forEach((event) => {
                        switch (event.type) {
                            case `${packageId}::event::AttackEvent`:
                                const data = event.parsedJson as AttackEvent;
                                eventBus.dispatchEvent({
                                    type: "sui",
                                    action: "attack",
                                    message: printAttackEvent(data),
                                    data,
                                });
                                break;
                            case `${packageId}::event::MoveEvent`: {
                                const { path } = event.parsedJson as { path: [number, number][] };
                                eventBus.dispatchEvent({
                                    type: "sui",
                                    action: "path",
                                    path,
                                    message:
                                        "Unit moves: " +
                                        path.map((p) => `(${p.toString()})`).join(", "),
                                });
                                break;
                            }
                            case `${packageId}::event::ReloadEvent`: {
                                const { unit } = event.parsedJson as { unit: [number, number] };
                                eventBus.dispatchEvent({
                                    type: "sui",
                                    action: "reload",
                                    unit,
                                    message: "Unit reloads: " + unit.toString(),
                                });
                            }
                        }
                    });
                }
            }

            eventBus.addEventListener("ui", onConfirm);
            return () => eventBus.removeEventListener("ui", onConfirm);
        },
        [lockedTx, map],
    );

    const centerDiv = (children: any) => (
        <div className="text-center bg-black/40 w-full h-full flex items-center justify-center">
            {children}
        </div>
    );

    if (isFetching || (isExecuting && !map)) return <Loader />;
    if (isFetched && !map) return centerDiv("Map not found");
    if (!modelsLoaded) return centerDiv("Models not loaded");
    if (!map)
        return (
            <div className="flex justify-between align-middle h-screen flex-col w-full">
                <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                    <h1 className="block p-1 mb-10 uppercase white page-heading">play</h1>
                </div>
                <div className="p-10 uppercase text-lg rounded max-w-3xl">
                    <a
                        className="options-row hover:cursor-pointer hover:no-underline"
                        onClick={() =>
                            createDemo(1, [
                                [0, 3],
                                [6, 5],
                            ])
                        }
                    >
                        Create demo 1
                    </a>
                    <a
                        className="options-row hover:cursor-pointer hover:no-underline"
                        style={{ border: "1px solid grey" }}
                        onClick={() =>
                            createDemo(2, [
                                [8, 2],
                                [7, 6],
                                [1, 2],
                                [1, 7],
                            ])
                        }
                    >
                        Create demo 2
                    </a>
                    <NavLink to="../editor" className="options-row mt-10 uppercase hover:no-underline">
                        Level Editor
                    </NavLink>
                </div>
                <Footer />
            </div>
        );

    return (
        <>
            <Canvas camera={camera}>
                {modelsLoaded && map && <GameApp map={map} eventBus={eventBus} camera={camera} />}
                <Stats />
            </Canvas>
            <UI
                isExecuting={isExecuting}
                recruits={recruits}
                turn={map.map.map.turn}
                eventBus={eventBus}
            />
        </>
    );

    // === Transaction functions ===

    async function createDemo(num: 1 | 2, positions: [number, number][] = []) {
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.moveCall({ target: `${packageId}::commander::demo_${num}` });

        for (let [x, y] of positions) {
            const { name, backstory } = await useNameGenerator();
            const recruit = tx.moveCall({
                target: `${packageId}::recruit::new`,
                arguments: [tx.pure.string(name), tx.pure.string(backstory)],
            });

            const armor = tx.moveCall({
                target: `${packageId}::items::armor`,
                arguments: [tx.pure.u8(1)],
            });

            tx.moveCall({
                target: `${packageId}::recruit::add_armor`,
                arguments: [recruit, armor],
            });

            tx.moveCall({
                target: `${packageId}::commander::place_recruit`,
                arguments: [game, recruit, tx.pure.u16(x), tx.pure.u16(y)],
            });
        }

        tx.moveCall({ target: `${packageId}::commander::share`, arguments: [game] });

        const res = await executeTransaction(tx);
        const map = res.data.objectChanges?.find((change) => {
            return (
                change.type === "created" && change.objectType === `${packageId}::commander::Game`
            );
        });

        if (!map) throw new Error("Map not found, something is off");
        if (map.type !== "created") throw new Error("Map not created, something is off");

        sessionStorage.setItem(LS_KEY, map.objectId);
        eventBus.dispatchEvent({ type: "sui", action: "map_created" });
        setTimeout(() => setMapKey(map.objectId), 1000); // somehow the map is not found immediately
    }

    /** Perform ranged attack. I've been waiting for this soooo long */
    async function performAttack(unit: [number, number], target: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

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

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        return { res, tx };
    }

    async function performReload(unit: [number, number]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        tx.moveCall({
            target: `${packageId}::commander::perform_reload`,
            arguments: [game, tx.pure.u16(unit[0]), tx.pure.u16(unit[1])],
        });

        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

        return { res, tx };
    }

    /** Move the unit on the map. The initial coordinate is the gridPosition of the unit. */
    async function moveUnit(path: [number, number][]) {
        if (!map) return;
        if (!canTransact) return;

        const tx = new Transaction();
        const game = tx.sharedObjectRef({
            objectId: map.objectId,
            initialSharedVersion: map.initialSharedVersion,
            mutable: true,
        });

        const pathArg = tx.pure(bcs.vector(bcs.vector(bcs.u16())).serialize(path));

        tx.moveCall({ target: `${packageId}::commander::move_unit`, arguments: [game, pathArg] });
        tx.setSender(zkLogin.address!);

        const res = await client.dryRunTransactionBlock({
            transactionBlock: await tx.build({ client: client as any }),
        });

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

        tx.moveCall({ target: `${packageId}::commander::next_turn`, arguments: [game] });
        tx.setSender(zkLogin.address!);

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
        camera.resetForSize(game.size);
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

        eventBus.addEventListener("sui", ({ action, data, unit }) => {
            if (action == "attack") {
                let params = data as AttackEvent;
                game.applyAttackEvent(params);
            }

            if (action == "next_turn") {
                game.turn = game.turn + 1;
            }

            if (action == "reload") {
                game.applyReloadEvent(unit);
            }
        });

        eventBus.addEventListener("ui", ({ action }) => {
            switch (action) {
                case "confirm":
                    return game.performAction();
                // case "move":
                //     return game.switchMode(new MoveMode(controls));
                case "reload":
                    return game.switchMode(new ReloadMode());
                case "shoot":
                    return game.switchMode(new ShootMode(camera, controls));
                case "grenade":
                    return game.switchMode(new GrenadeMode(controls));
                case "edit":
                    return game.switchMode(new EditMode(controls));
                case "cancel":
                    return game.switchMode(new MoveMode(controls));
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

type Recruit = typeof Recruit.$inferType;

/**
 * UI Component which renders buttons and emits events in the `eventBus` under the `ui` type.
 * Listens to the in-game events to render additional buttons and log the actions.
 */
export function UI({
    eventBus,
    isExecuting,
    turn: initilTurn,
    recruits,
}: {
    eventBus: EventBus;
    isExecuting?: boolean;
    turn: number;
    recruits: { [key: string]: Recruit } | undefined;
}) {
    const [panelDisabled, setPanelDisabled] = useState(true);
    const [shootMode, setShootMode] = useState(false);
    const [turn, setTurn] = useState(initilTurn);
    const [mode, setMode] = useState<string | null>(null);
    const [log, setLog] = useState<string[]>([]);
    const [unit, setUnit] = useState<Unit | null>(null);
    const [recruit, setRecruit] = useState<Recruit | null>(null);

    const onAction = (action: string) => eventBus.dispatchEvent({ type: "ui", action });
    const button = (id: string, disabled?: boolean, text?: string) => (
        <button
            onClick={() => onAction(id)}
            className={
                "action-button mb-2" +
                (disabled || isExecuting ? " disabled" : "") +
                (mode && mode.toLocaleLowerCase() == id ? " active" : "")
            }
        >
            {text || id}
        </button>
    );

    // Subscribe to the game events to update the UI.
    useEffect(() => {
        function gameEventsHandler(event: GameEvent["game"]) {
            if (event.action === "mode_switch") {
                setMode(event.mode.name);

                if (event.mode instanceof ShootMode) setShootMode(true);
                else setShootMode(false);

                if (event.mode instanceof NoneMode) setPanelDisabled(true);
                else setPanelDisabled(false);
            }

            if (event.action === "unit_selected" && recruits) {
                let unit = event.unit as Unit;
                let recruitId = unit.props.recruit;
                if (recruitId in recruits) {
                    setRecruit(recruits[recruitId]);
                    setUnit(unit);
                }
            }
        }

        eventBus.addEventListener("game", gameEventsHandler);
        return () => eventBus.removeEventListener("game", gameEventsHandler);
    }, [recruits]);

    // Subscribe to the SUI events + all events to update the log.
    useEffect(() => {
        eventBus.addEventListener("sui", (event) => {
            if (event.action === "next_turn") {
                setTurn(event.turn);
            }
        });

        eventBus.all((event) => {
            setLog((log) => {
                let { type, action, message } = event;
                let fullLog = [...log, `${type}: ${message || action || ""}`];
                if (fullLog.length > LOG_LENGTH) fullLog = fullLog.slice(fullLog.length - 5);
                return fullLog;
            });
        });
    }, []);

    const reloadText =
        (unit && "Reload " + unit.props.ammo.value + "/" + unit.props.ammo.max_value) || "Reload";

    return (
        <div id="ui">
            {unit && recruit && (
                <div
                    id="panel-top"
                    className="fixed w-full text-xs top-0 left-0 p-0 text-center mt-10"
                >
                    <p className="text-sm text-white">
                        {recruit.metadata.name} ({recruit.rank.$kind}) HP: {unit.props.hp.value}/
                        {unit.props.hp.max_value}; AP {unit.props.ap.value}/2; Ammo:{" "}
                        {unit.props.ammo.value}/{unit.props.ammo.max_value}
                    </p>
                </div>
            )}
            <div
                id="panel-left"
                className="fixed h-full left-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {button("shoot")}
                {button("reload", unit?.props.ammo.value == unit?.props.ammo.max_value, reloadText)}
                {button("grenade", true)}
                <button
                    onClick={() => onAction("next_turn")}
                    className={"action-button mt-40" + (isExecuting ? " disabled" : "")}
                >
                    End Turn ({turn + 1})
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
                <button
                    onClick={() => {
                        sessionStorage.removeItem(LS_KEY);
                        window.location.reload();
                    }}
                    className={"action-button mt-40" + (isExecuting ? " disabled" : "")}
                >
                    Exit
                </button>
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

/**
 * Print the attack event as a nice string.
 */
function printAttackEvent(event: AttackEvent): string {
    if (event.is_missed) return "Miss!";
    if (event.is_dodged) return "Dodged!";
    if (event.is_kia) return "Killed in action! Damage: " + event.damage;
    if (event.is_crit) return `Critical hit! ${event.damage} damage`;
    return `Dealt ${event.damage} damage`;
}
