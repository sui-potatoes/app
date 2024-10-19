// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useState } from "react";
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
    onTarget: (unit: typeof UnitType.$inferType | null, x: number, y: number) => void;
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
    const [unit, setUnit] = useState<typeof UnitType.$inferType | null>(null);

    console.log('map', unit);

    useEffect(() => {
        if (!scene) return;
        scene.grid.highlightCells(highlight);
    }, [highlight]);

    useEffect(() => {
        if (scene) return;

        const _scene = newScene(ROOT);
        if (!_scene) return;

        setScene(_scene);

        // add initial game objects as loaded from the `gameGrid`
        initialize(_scene.grid);

        _scene.grid.addEventListener("selectCell", onSelectCell);
        _scene.grid.addEventListener("pointCell", onPointCell);
    }, []);

    return <div id={ROOT}></div>;

    // return {
    //     mapElement: <div id={ROOT}></div>,
    //     async moveObject(x: number, y: number, path: { x: number; y: number }[]) {
    //         if (!scene) return;
    //         await scene.grid.objectFollowGridPath(
    //             new THREE.Vector2(x, y),
    //             path.map((p) => new THREE.Vector2(p.x, p.y)),
    //         );
    //     },
    // };

    function initialize(grid: Grid) {
        gameGrid.grid.forEach((row, x) => {
            row.forEach((tile, y) => {
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
        let { x, y } = point.addScalar(-1); // adjust for 1-indexed grid
        if (gameGrid.grid[x][y].$kind === "Empty") {
            setUnit(null);
            onSelect(null, x, y);
        } else {
            setUnit(gameGrid.grid[x][y].Unit!.unit);
            onSelect(gameGrid.grid[x][y].Unit!.unit, x, y);
        }
    }

    /**
     * Triggered on `pointCell` event from the `Grid`.
     * @param param0
     */
    function onPointCell({ point }: { point: THREE.Vector2 }) {
        console.log('pointing cell', unit);
        onTarget(unit, point.x, point.y);
    }
}
