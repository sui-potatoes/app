// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useMemo, useState } from "react";
import { Camera, Game, loadModels, EditMode, Controls } from "./engine";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import { Stats } from "@react-three/drei";

export function Editor() {
    const [size, setSize] = useState(0);
    const [modelsLoaded, setModelsLoaded] = useState(false);
    const camera = useMemo(() => loadCamera(size), [size]);

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
    }, []);

    if (size == 0) return <SelectSize setSize={setSize} />;
    if (!modelsLoaded) return <div>Loading models...</div>;

    return (
        <>
            <Canvas camera={camera} onCreated={({ gl }) => gl.setClearColor("lightblue")}>
                <Field size={size} camera={camera} />
            </Canvas>
        </>
    );
}

type FieldProps = {
    size: number;
    camera: Camera;
};

export function Field({ size, camera }: FieldProps) {
    const { gl } = useThree();
    const game = useMemo(() => new Game(size, true), [size]);
    const controls = useMemo(() => new Controls(game, gl.domElement), [game]);
    const center: [number, number, number] = [size / 2, 0, -size / 2];

    useEffect(() => {
        game.switchMode(new EditMode(controls));
        camera.resetForSize(size);
        controls.connect();
        controls.addEventListener("zoom", ({ delta }) => {
            camera.position.x += Math.sign(delta) * 0.5;
            camera.lookAt(...center);
        });
    }, []);

    useFrame((root, delta) => {
        controls.update(delta);
        const cursor = root.raycaster.intersectObject(game.plane)[0];
        game.update(cursor || null, delta);
        game.input(controls);
    });

    return <>
        <Stats />
        <ambientLight color={"white"} intensity={0.5} />
        <pointLight position={[size / 2, size, -size / 2]} intensity={100} />
        <primitive object={game} />
    </>
}

export function SelectSize({ setSize }: { setSize: (size: number) => void }) {
    return (
        <div className="flex justify-center align-middle h-screen flex-col">
            <button onClick={() => setSize(10)}>Small (10x10)</button>
            <button onClick={() => setSize(15)}>Medium (20x20)</button>
            <button onClick={() => setSize(30)}>Large (30x30)</button>
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
