// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useMemo, useState } from "react";
import { Camera, Game, loadModels, EditMode, Controls, EventBus } from "./engine";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Stats } from "@react-three/drei";
import { fromHex } from "@mysten/bcs";
import { Footer } from "./Footer";
import { NavLink } from "react-router-dom";

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
            <Canvas camera={camera} onCreated={({ gl }) => gl.setClearColor("lightblue")}>
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

        eventBus.all(function saveState() {
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
    const [tool, setTool] = useState("object");

    useEffect(() => {
        function onEditorEvent(event: any) {
            setDirection(event.direction);
            setTool(event.tool);
        }

        eventBus.addEventListener("editor", onEditorEvent);
        return () => eventBus.removeEventListener("editor", onEditorEvent);
    }, []);

    return (
        <div id="ui">
            <div id="panel-top" className="fixed w-full text-xs top-0 left-0 p-0 text-center mt-10">
                <p className="text-sm text-white">
                    Tool: {tool}; Direction: {direction}
                </p>
            </div>
            <div id="panel-bottom" className="fixed w-full text-xs bottom-0 left-0 p-0 text-center">
                <div className="absolute" style={{ bottom: "0px" }}>
                    <Footer to="../play" />
                </div>
                <div className="mb-10">
                    <p className="text-sm text-white">
                        Click to place objects; right-click to remove
                    </p>
                    <p className="text-sm text-white">Use WSAD keys to change direction</p>
                    <p className="text-sm text-white">
                        C - Cover; H - High Cover; O - Object; U - Unwalkable
                    </p>
                </div>
            </div>
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
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                <h1 className="block p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../play">PLAY</NavLink> / editor
                </h1>
            </div>
            <div className="p-10 text-uppercase text-lg rounded max-w-3xl">
                {/* continue the preset if there is one */}
                {preset && (
                    <button
                        className="options-row uppercase hover:no-underline mb-10 w-full"
                        style={{ border: "0.01em solid grey" }}
                        onClick={() => setSize(size)}
                    >
                        Continue with preset
                    </button>
                )}
                <button
                    className="options-row w-full hover:no-underline"
                    onClick={() => startOver(10)}
                >
                    SMALL (10x10)
                </button>
                <button
                    className="options-row w-full hover:no-underline"
                    onClick={() => startOver(15)}
                >
                    MEDIUM (20x20)
                </button>
                <button
                    className="options-row w-full hover:no-underline"
                    onClick={() => startOver(30)}
                >
                    LARGE (30x30)
                </button>
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
