// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useMemo, useState } from "react";
import { Camera, Game, loadModels, EditMode, Controls, EventBus, GameAction } from "../engine";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Stats } from "@react-three/drei";
import { fromHex } from "@mysten/bcs";
import { Footer } from "./Components";
import { NavLink, useNavigate } from "react-router-dom";
import { useGameTransactions } from "../hooks/useGameTransactions";
import { Modal } from "./Components";

const STORAGE_KEY = "editor-state";

export function Editor() {
    const [size, setSize] = useState(0);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const camera = useMemo(() => loadCamera(size), [size]);
    const eventBus = useMemo(() => new EventBus(), []);
    const [preset, setPreset] = useState<string | null>(null);

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
        setPreset(sessionStorage.getItem(STORAGE_KEY));
    }, []);

    if (size == 0) return <SelectSize preset={preset} setSize={setSize} />;
    if (!modelsLoaded) return <div>Loading models...</div>;

    return (
        <>
            <Canvas camera={camera} onCreated={({ gl }) => gl.setClearColor("black")}>
                <Field size={size} preset={preset} eventBus={eventBus} camera={camera} />
            </Canvas>
            <UI eventBus={eventBus} />
        </>
    );
}

type FieldProps = {
    size: number;
    preset: string | null;
    camera: Camera;
    eventBus: EventBus;
};

export function Field({ size, eventBus, camera, preset }: FieldProps) {
    const { gl } = useThree();
    const game = useMemo(() => {
        const game = new Game(size, true);
        if (preset) game.grid.resetFromBcs(fromHex(preset));
        return game;
    }, [size, preset]);
    const controls = useMemo(() => new Controls(game, gl.domElement), [game]);
    const center: [number, number, number] = [size / 2, 0, -size / 2];

    useEffect(() => {
        game.registerEventBus(eventBus);
        game.switchMode(new EditMode(controls));
        camera.resetForSize(size);
        controls.connect();
        controls.addEventListener("zoom", ({ delta }) => {
            camera.position.x += Math.sign(delta) * 0.5;
            camera.lookAt(...center);
        });

        // save the state of the editor on any event
        eventBus.addEventListener("all", function saveState() {
            sessionStorage.setItem(STORAGE_KEY, game.grid.toBytes().toHex());
        });
    }, []);

    useFrame((root, delta) => {
        controls.update(delta);
        const cursor = root.raycaster.intersectObject(game.plane)[0];
        game.update(cursor || null, delta);
        game.input(controls);
    });

    return (
        <>
            <Stats />
            <ambientLight color={"white"} intensity={0.5} />
            <pointLight position={[size / 2, size, -size / 2]} intensity={100} />
            <primitive object={game} />
        </>
    );
}

export function UI({ eventBus }: { eventBus: EventBus }) {
    const [direction, setDirection] = useState("up");
    const [showPublishModal, setShowPublishModal] = useState(false);
    const { canTransact, publishMap } = useGameTransactions({ map: null });
    const navigate = useNavigate();
    const [name, setName] = useState("");
    const [tool, setTool] = useState("object");

    useEffect(() => {
        function onEditorToolChange(event: GameAction["editor:tool"]) {
            setDirection(event.direction);
            setTool(event.tool);
        }

        eventBus.addEventListener("game:editor:tool", onEditorToolChange);
        return () => eventBus.removeEventListener("game:editor:tool", onEditorToolChange);
    }, []);

    return (
        <div id="ui">
            <div id="panel-top" className="fixed w-full text-xs top-0 left-0 p-0 text-center mt-10">
                <p className="text-sm">
                    Tool: {tool}; Direction: {direction}
                </p>
            </div>
            <div id="panel-bottom" className="fixed w-full text-xs bottom-0 left-0 p-0 text-center">
                <div className="absolute" style={{ bottom: "0px" }}>
                    <Footer to="../play" />
                </div>
                <div className="mb-10">
                    <p className="text-sm">Click to place objects; right-click to remove</p>
                    <p className="text-sm">Use WSAD keys to change direction</p>
                    <p className="text-sm">C - Cover; H - High Cover; O - Object; U - Unwalkable</p>
                    <p className="text-sm">1 - Set Spawn Point; 2 - Remove Spawn</p>
                    <p className="text-sm">A Map MUST have at least one spawn point</p>
                </div>
                <div className="absolute right-0 bottom-0">
                    <button
                        disabled={!canTransact}
                        onClick={() => {
                            if (canTransact) {
                                setShowPublishModal(true);
                                // silly hack to focus the input
                                setTimeout(() => document.getElementById("name")?.focus(), 100);
                            }
                        }}
                        className="text-center fixed flex justify-between bottom-10 right-10 p-4 text-lg border-2 border-gray-500 rounded-md"
                    >
                        publish
                    </button>
                </div>
            </div>
            <Modal show={showPublishModal} onClose={() => setShowPublishModal(false)}>
                <div className="flex flex-col gap-4" onClick={(e) => e.stopPropagation()}>
                    <div className="flex justify-between">
                        <label htmlFor="name" className="p-6">
                            Name:
                        </label>
                        <input
                            type="text"
                            id="name"
                            style={{ borderBottom: "1px solid grey" }}
                            className="focus:outline-none w-full m-4 gap-2"
                            placeholder="Map Name"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                        />
                        <button
                            className="p-4 focus:outline-none"
                            onClick={() =>
                                publishMap(
                                    name,
                                    fromHex(sessionStorage.getItem(STORAGE_KEY) || ""),
                                ).then(() => {
                                    sessionStorage.removeItem(STORAGE_KEY);
                                    setShowPublishModal(false);
                                    navigate("../play");
                                })
                            }
                        >
                            Publish
                        </button>
                    </div>
                </div>
            </Modal>
        </div>
    );
}

export function SelectSize({
    setSize,
    preset,
}: {
    setSize: (size: number) => void;
    preset: string | null;
}) {
    let size = 0;
    if (preset) {
        const bcs = fromHex(preset);
        size = bcs[32]; // ID is 32 bytes, so we take the next byte as the size
    }

    const startOver = (size: number) => {
        sessionStorage.removeItem(STORAGE_KEY);
        setSize(size);
    };

    return (
        <div className="flex justify-between flex-col w-full">
            <div className="p-10 max-w-xl">
                <h1 className="p-1 mb-10 page-heading">
                    <NavLink to="../play">PLAY</NavLink> / editor
                </h1>
            </div>
            <div className="p-10 max-w-3xl">
                {/* continue the preset if there is one */}
                {preset && (
                    <div
                        className="options-row interactive mb-10 w-full"
                        onClick={() => setSize(size)}
                    >
                        <a>Continue last session</a>
                    </div>
                )}
                <div className="options-row interactive w-full" onClick={() => startOver(10)}>
                    <a>SMALL (10x10)</a>
                </div>
                <div className="options-row interactive w-full" onClick={() => startOver(15)}>
                    <a>MEDIUM (20x20)</a>
                </div>
                <div className="options-row interactive w-full" onClick={() => startOver(30)}>
                    <a>LARGE (30x30)</a>
                </div>
            </div>
            <Footer to="../play" />
        </div>
    );
}

/**
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera(size: number) {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 300);
    camera.resetForSize(size);
    return camera;
}
