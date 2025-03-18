// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import JEASINGS from "jeasings";
import { Stats } from "@react-three/drei";
import { useEffect, useMemo } from "react";
import { Canvas, useFrame, useThree } from "@react-three/fiber";
import {
    Game,
    Camera,
    Controls,
    MoveMode,
    EventBus,
    GrenadeMode,
    ShootMode,
    EditMode,
    ReloadMode,
} from "../../engine";
import { GameMap } from "../../hooks/useGame";
import { SuiEvent } from "../../engine/EventBus";

type GameAppProps = {
    map: GameMap;
    camera: Camera;
    eventBus: EventBus;
};

/**
 * The Game itself, rendered inside the `Canvas` component.
 */
export function GameApp({ map, camera, eventBus }: GameAppProps) {
    return (
        <>
            <Canvas camera={camera}>
                <App map={map} camera={camera} eventBus={eventBus} />
                <Stats />
            </Canvas>
        </>
    );
}

function App({ map, camera, eventBus }: { map: GameMap; camera: Camera; eventBus: EventBus }) {
    const { gl } = useThree();
    const game = useMemo(() => Game.fromBCS(map), []);
    const controls = useMemo(() => new Controls(game, gl.domElement), []);

    // actions to perform on each frame:
    // - track easing functions
    // - pass raycasting information to Game
    // - update game state (which then triggers in-game elements' updates)
    useFrame((root, delta) => {
        JEASINGS.update();
        controls.update(delta);
        const cursor = root.raycaster.intersectObject(game.plane)[0];
        game.update(cursor || null, delta);
        game.input(controls);
    });

    // on mount:
    // - reset camera
    // - register event bus
    // - connect controls
    // - track scroll and zoom for camera
    // - listen to Sui events
    // - listen to UI events
    useEffect(() => {
        camera.resetForSize(game.size);
        game.registerEventBus(eventBus);
        controls.connect();

        controls.addEventListener("scroll", onScroll);
        controls.addEventListener("zoom", onZoom);
        eventBus.addEventListener("sui", onSuiEvent);
        eventBus.addEventListener("ui", onUIEvent);

        return () => {
            controls.removeEventListener("scroll", onScroll);
            controls.removeEventListener("zoom", onZoom);
            eventBus.removeEventListener("sui", onSuiEvent);
            eventBus.removeEventListener("ui", onUIEvent);
        };
    }, []);

    return (
        <>
            <primitive object={game} />
            <ambientLight color={"white"} intensity={0.5} />
            <fog attach="fog" args={["white", 0.5, 200]} />
        </>
    );

    // === Event Handlers ===

    // prettier-ignore
    function onSuiEvent(evt: SuiEvent) {
        switch (evt.action) {
            case "attack": return game.applyAttackEvent(evt);
            case "reload": return game.applyReloadEvent(evt.unit);
            case "next_turn": return game.turn = evt.turn;
        }
    }

    // prettier-ignore
    function onUIEvent({ action }: { action: string }) {
        switch (action) {
            // in-game actions / modesx
            // case "move": return game.switchMode(new MoveMode(controls));
            case "edit": return game.switchMode(new EditMode(controls));
            case "shoot": return game.switchMode(new ShootMode(camera, controls));
            case "reload": return game.switchMode(new ReloadMode());
            case "grenade": return game.switchMode(new GrenadeMode(controls));

            // confirm / cancel
            case "confirm": return game.performAction();
            case "cancel": return game.switchMode(new MoveMode(controls));
        }
    }

    function onZoom({ delta }: { delta: number }) {
        let newPosition = camera.position.y + delta * 0.01;
        if (newPosition >= 0 && newPosition <= 15) {
            camera.position.y = newPosition;
            camera.lookAt(camera.defaultTarget);
        }
    }

    function onScroll({ delta }: { delta: number }) {
        let newPosition = camera.position.z + delta * 0.01;
        if (newPosition >= 0 && newPosition < 15) {
            camera.position.z = newPosition;
            camera.lookAt(camera.defaultTarget);
        }
    }
}
