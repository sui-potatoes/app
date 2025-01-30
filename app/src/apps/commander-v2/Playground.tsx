// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// import { NavLink } from "react-router-dom";
// import { createScene } from "./engine/scene";
// import { useEffect } from "react";
import { Canvas, extend, useFrame, useThree } from "@react-three/fiber";
import { Camera } from "./engine/Camera";
import * as THREE from "three";
import { useEffect, useMemo, useState } from "react";
import { Game } from "./engine/Game";
import { Unit } from "./engine/Unit";
import { loadModels, models } from "./engine/scene";
import { UI as inUI } from "./engine/UI";
import { Controls, ControlsEvents } from "./engine/Controls";
import JEASINGS from "jeasings";
import { MoveMode } from "./engine/modes/MoveMode";
import { ShootMode } from "./engine/modes/ShootMode";
import { GrenadeMode } from "./engine/modes/GrenadeMode";
import { EditMode } from "./engine/modes/EditMode";
import { NoneMode } from "./engine/modes/NoneMode";
import { Stats } from "@react-three/drei";

extend({ Camera, Game });

export type GameEvents = {
    ui: { action: string };
    controls: { action: ControlsEvents };
};

export type GameDispatcher = THREE.EventDispatcher<GameEvents>;

declare module "@react-three/fiber" {
    interface ThreeElements {
        game: Game;
    }
}

export const SIZE = 10;

export function Playground() {
    const camera = useMemo(loadCamera, []);
    const eventStream = useMemo(() => new THREE.EventDispatcher<GameEvents>(), []);
    const [modelsLoaded, setModelsLoaded] = useState(false);

    useEffect(() => {
        loadModels().then(() => setModelsLoaded(true));
        console.log("Models loaded");
    }, [models]);

    if (!modelsLoaded) return <>...</>;

    return (
        <>
            <Canvas camera={camera}>
                {modelsLoaded && <GameApp eventStream={eventStream} camera={camera} />}
                <Stats />
            </Canvas>
            <UI onAction={(action) => eventStream.dispatchEvent({ type: "ui", action })} />
        </>
    );
}

export function GameApp({ camera, eventStream }: { camera: Camera; eventStream: GameDispatcher }) {
    const { gl } = useThree();
    const game = useMemo(() => new Game(SIZE, false), []);
    const controls = useMemo(() => new Controls(game, gl.domElement, camera), []);

    useFrame((root, delta) => {
        JEASINGS.update();
        controls.update(delta);
        const cursor = root.raycaster.intersectObject(game.plane)[0];
        game.update(cursor || null, delta);
        game.input(controls);
    });

    useEffect(() => {
        controls.connect();
        game.addUnit(new Unit(models.soldier, 2, 1));
        game.addUnit(new Unit(models.soldier, 6, 4));

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

        eventStream.addEventListener("ui", ({ action }) => {
            switch (action) {
                case "confirm":
                    return game.performAction();
                case "move":
                    return game.switchMode(new MoveMode(controls));
                case "shoot":
                    return game.switchMode(new ShootMode(camera, new inUI(gl.domElement)));
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

export function UI({ onAction }: { onAction: (id: string) => void }) {
    const button = (id: string) => (
        <button onClick={() => onAction(id)} className="action-button mb-2">
            {id}
        </button>
    );

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
    const size = SIZE;
    const aspect = window.innerWidth / window.innerHeight;
    const camera = new Camera(75, aspect, 0.1, 100);
    const offset = size / 2 - 0.5;

    camera.defaultPosition = new THREE.Vector3(offset, size + 5, offset * 2);
    camera.defaultTarget = new THREE.Vector3(offset, 0, offset);
    camera.position.copy(camera.defaultPosition);
    camera.lookAt(camera.defaultTarget);

    return camera;
}
