// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCallback, useEffect, useRef, useState } from "react";
import * as THREE from "three";
import { newScene } from "./scene";
import { AnimatedUnit } from "./AnimatedUnit";
import { Grid } from "./Grid";
import { Crate } from "./Crate";
import { Grid as GridType, Unit as UnitType } from "../types";

/**
 * The ID of the root element for the ThreeJS scene.
 */
const ROOT = "three";

/**
 * Props for the ThreeJS Map app.
 */
export type MapProps = {
    disabled?: boolean;
    grid: typeof GridType.$inferType;
    highlight: { x: number; y: number; d: number }[];
    /** Callback when Unit is commanded to perform an action at X, Y */
    onTarget: (x: number, y: number) => void;
    onSelect: (unit: typeof UnitType.$inferType | null, x: number, y: number) => void;
};

/**
 * Body for the ThreeJS Map app.
 *
 * Acts as a bridge between the `Map` component and the ThreeJS scene.
 * Returns the `mapElement` and a `moveObject` function to move objects on the grid.
 */
export function Map({ grid: gameGrid, highlight, onTarget, onSelect }: MapProps) {
    const [scene, setScene] = useState<{ grid: Grid } | null>(null);

    useEffect(() => {
        if (!scene) return;
        console.log('highlight', highlight);
        scene.grid.highlightCells(highlight.map(({ x, y, d }) => ({ x: y, y: x, d })));
    }, [highlight]);

    useEffect(() => {
        if (scene) return;

        const _scene = newScene(ROOT);
        if (!_scene) return;

        setScene(_scene);

        // add initial game objects as loaded from the `gameGrid`
        initialize(_scene.grid);

        // EventDispatcher implementation in Three.js stores the initial context
        // of the `onSelect` and `onTarget` callbacks. This is somewhat tricky
        // since we can't use it to trigger any state changes. A temporary
        // workaround is to use a `useRef` for values used in the callback.
        //
        // However, there's more to it than just active Unit and Action.
        _scene.grid.addEventListener("selectCell", onSelectCell);
        _scene.grid.addEventListener("pointCell", onPointCell);
    }, []);

    return <div id={ROOT} onContextMenu={(e) => e.preventDefault()} />;

    function initialize(grid: Grid) {
        gameGrid.grid.forEach((row, y) => {
            row.forEach((tile, x) => {
                if (tile.$kind === "Empty" || !tile.Unit) {
                    return;
                }

                if (["Barricade", "Crate"].includes(tile.Unit.unit.name)) {
                    grid.addGameObject(new Crate(), new THREE.Vector2(x, y));
                    return;
                }

                // `/images/unit-${unit.unit.name.toLowerCase()}.png`
                grid.addGameObject(new AnimatedUnit(), new THREE.Vector2(x, y));
            });
        });
    }

    /**
     * Triggered on `selectCell` event from the `Grid`.
     * @param param0
     */
    function onSelectCell({ point }: { point: THREE.Vector2 }) {
        let { x: y, y: x } = point.addScalar(-1); // adjust for 1-indexed grid
        if (gameGrid.grid[x][y].$kind === "Empty") {
            onSelect(null, x, y);
        } else {
            onSelect(gameGrid.grid[x][y].Unit!.unit, x, y);
        }
    }

    /**
     * Triggered on `pointCell` event from the `Grid`.
     * @param param0
     */
    function onPointCell({ point }: { point: THREE.Vector2 }) {
        let { x: y, y: x } = point.addScalar(-1); // adjust for 1-indexed grid
        onTarget(x, y);
    }
}
