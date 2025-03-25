// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import JEASINGS from "jeasings";
import { OrbitControls, Stats } from "@react-three/drei";
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
import { HistoryRecord } from "../../types/bcs";
import { GameMap } from "../../hooks/useGame";
import { SuiAction } from "../../engine/EventBus";

type GameAppProps = {
    map: GameMap;
    camera: Camera;
    eventBus: EventBus;
    history?: (typeof HistoryRecord.$inferType)[];
    orbit?: boolean;
};

/**
 * The Game itself, rendered inside the `Canvas` component.
 */
export function GameApp({ map, camera, orbit, eventBus, history }: GameAppProps) {
    const size = map.map.map.grid.length;
    const pos = (size / 2);

    return (
        <>
            <Canvas camera={camera}>
                {orbit && (
                    <OrbitControls
                        target={new THREE.Vector3(5, 0, -pos + 0.5)}
                        minDistance={4}
                        maxDistance={12}
                    />
                )}
                <App map={map} camera={camera} eventBus={eventBus} history={history} />
                <Stats />
            </Canvas>
        </>
    );
}

type AppProps = {
    map: GameMap;
    camera: Camera;
    eventBus: EventBus;
    history?: (typeof HistoryRecord.$inferType)[];
};

function App({ map, camera, eventBus, history }: AppProps) {
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
        controls.connect();
        camera.resetForSize(game.size);
        game.registerEventBus(eventBus);
        game.registerControls(controls);

        controls.addEventListener("scroll", onScroll);
        controls.addEventListener("zoom", onZoom);

        // sui event handlers
        eventBus.addEventListener("sui:attack", onSuiAttack);
        eventBus.addEventListener("sui:reload", onSuiReload);
        eventBus.addEventListener("sui:next_turn", onSuiNextTurn);

        // ui event handler
        eventBus.addEventListener("ui:cancel", onUICancel);
        eventBus.addEventListener("ui:confirm", onUIConfirm);
        eventBus.addEventListener("ui:grenade", onGrenadeMode);
        eventBus.addEventListener("ui:shoot", onShootMode);
        eventBus.addEventListener("ui:reload", onReloadMode);
        eventBus.addEventListener("ui:edit", onEditMode);

        return () => {
            controls.removeEventListener("scroll", onScroll);
            controls.removeEventListener("zoom", onZoom);
            eventBus.removeEventListener("sui:attack", onSuiAttack);
            eventBus.removeEventListener("sui:reload", onSuiReload);
            eventBus.removeEventListener("sui:next_turn", onSuiNextTurn);
        };
    }, []);

    // track history updates, send them to the game
    useEffect(() => {
        game.applyHistory(history || []);
    }, [history]);

    return (
        <>
            <primitive object={game} />
            <ambientLight color={"white"} intensity={0.5} />
            <fog attach="fog" args={["white", 0.5, 200]} />
        </>
    );

    // === Event Handlers ===

    function onSuiAttack(event: SuiAction["attack"]) {
        game.applyAttackEvent(event);
    }

    function onSuiReload(event: SuiAction["reload"]) {
        game.applyReloadEvent(event);
    }

    function onSuiNextTurn(event: SuiAction["next_turn"]) {
        game.turn = event.turn;
    }

    function onEditMode() {
        game.switchMode(new EditMode(controls));
    }

    function onReloadMode() {
        game.switchMode(new ReloadMode());
    }

    function onShootMode() {
        game.switchMode(new ShootMode(camera, controls));
    }

    function onGrenadeMode() {
        game.switchMode(new GrenadeMode(controls));
    }

    function onUIConfirm() {
        game.performAction();
    }

    function onUICancel() {
        game.switchMode(new MoveMode(controls));
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
