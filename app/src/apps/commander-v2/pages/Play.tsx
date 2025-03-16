// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import JEASINGS from "jeasings";
import { Stats } from "@react-three/drei";
import { Loader, Footer } from "./Components";
import { useEffect, useMemo, useState } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { UI } from "./play/UI";
import {
    Game,
    Camera,
    Controls,
    MoveMode,
    GameEvent,
    EventBus,
    GrenadeMode,
    ShootMode,
    EditMode,
    ReloadMode,
    models,
    loadModels,
} from "../engine";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useSuiClient } from "@mysten/dapp-kit";

import { bcs, HistoryRecord } from "../types/bcs";
import { GameMap, useGame } from "../hooks/useGame";
import { useGameRecruits } from "../hooks/useGameRecruits";
import { useTransactionExecutor } from "../hooks/useTransactionExecutor";
import { useNetworkVariable } from "../../../networkConfig";
import { useNameGenerator } from "../hooks/useNameGenerator";
import { NavLink } from "react-router-dom";
import { fromBase64 } from "@mysten/bcs";

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

                console.log(x0, y0, x1, y1);

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

                    const eventType = `${packageId}::history::HistoryUpdated`;
                    const historyBcs = events.find((e) => e.type == eventType)?.bcs;

                    if (!historyBcs) return;

                    const decoded = bcs.vector(HistoryRecord).parse(fromBase64(historyBcs));
                    const first = decoded[0]!; // the cannot be an empty History event

                    // prettier-ignore
                    switch (first.$kind) {
                        case "Reload": return eventBus.dispatchEvent({
                            type: "sui",
                            action: "reload",
                            unit: first.Reload as [number, number],
                            message: `unit (${first.Reload}) reloads`
                        });
                        case "NextTurn": return eventBus.dispatchEvent({
                            type: "sui",
                            action: "next_turn",
                            message: `next turn`
                        });;
                        case "Move": return eventBus.dispatchEvent({
                            type: "sui",
                            action: "path",
                            path: first.Move,
                            message:
                                "unit moves: " +
                                first.Move.map((p) => `(${p.toString()})`).join(", "),
                        });
                        case "Attack": return;
                    }

                    // const data = event.parsedJson as AttackEvent;
                    // eventBus.dispatchEvent({
                    //     type: "sui",
                    //     action: "attack",
                    //     message: printAttackEvent(data),
                    //     data,
                    // });
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
            <div className="flex justify-between flex-col w-full">
                <div className="text-left p-10 max-w-xl">
                    <h1 className="p-1 mb-10 page-heading">play</h1>
                </div>
                <div className="p-10 max-w-3xl">
                    <a
                        className="options-row interactive"
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
                        className="options-row interactive"
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
                    <NavLink to="../editor" className="options-row mt-10 interactive">
                        Level Editor
                    </NavLink>
                </div>
                <Footer />
            </div>
        );

    return (
        <>
            <Canvas camera={camera}>
                {modelsLoaded && <GameApp map={map} eventBus={eventBus} camera={camera} />}
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
            if (action == "attack" && data && unit) {
                let params = data as AttackEvent;
                game.applyAttackEvent(params);
            }

            if (action == "next_turn") {
                game.turn = game.turn + 1;
            }

            if (action == "reload" && data && unit) {
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
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera() {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    camera.resetForSize(SIZE);
    return camera;
}

// /**
//  * Print the attack event as a nice string.
//  */
// function printAttackEvent(event: AttackEvent): string {
//     if (event.is_missed) return "Miss!";
//     if (event.is_dodged) return "Dodged!";
//     if (event.is_kia) return "Killed in action! Damage: " + event.damage;
//     if (event.is_crit) return `Critical hit! ${event.damage} damage`;
//     return `Dealt ${event.damage} damage`;
// }
