// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useMemo, useState } from "react";
import { Camera, Game } from "./engine";
import { Canvas } from "@react-three/fiber";

export function Editor() {
    const [size, _] = useState(30);
    const camera = useMemo(() => loadCamera(size), [size]);
    const game = useMemo(() => new Game(size), [size]);

    return (
        <>
            <Canvas camera={camera} onCreated={({ gl }) => gl.setClearColor("lightblue")}>
                <primitive object={game} />
            </Canvas>
        </>
    )
}

/**
 * Load the camera for the game.
 * Happens just ones in `useMemo` and is used in the `Canvas` component.
 */
function loadCamera(size: number) {
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    camera.resetForSize(size);
    return camera;
}
