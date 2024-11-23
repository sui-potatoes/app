// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./Game";
import { Controls } from "./Controls";

/**
 * Each Mode defines a different way of interacting with the game. By default, the game mode is
 * `None`, however, when a `Unit` is selected, the game mode changes to `Move` by default. If
 * another action is selected, the game mode changes to that action. Additionally, there's an `Edit`
 * mode which allows modifying the map.
 *
 * Each game mode comes with 4 default functions: `connect`, `disconnect`, `input` and
 * `performAction`. The latter may not be necessary for all modes.
 *
 * Action is a mixin, and its scope and `this` argument are bound to the `Game` instance. The
 * `Storage` type parameter defines the structure of the data the mode needs to store.
 */
export interface Mode<Storage> {
    name: string;
    connect(this: Game, storage: Storage): void;
    disconnect(this: Game, storage: Storage): void;
    input(this: Game, controls: Controls, storage: Storage): void;
    performAction(this: Game, storage: Storage): Promise<void>;
    storage: Storage;
}

export const Edit: Mode<{
    pointerMesh: THREE.Mesh<THREE.BoxGeometry, THREE.MeshStandardMaterial> | null;
}> = {
    name: "Edit",
    connect(storage) {
        !storage.pointerMesh && (storage.pointerMesh = null);
    },
    disconnect(storage) {
        storage.pointerMesh?.geometry.dispose();
        storage.pointerMesh?.material.dispose();
        storage.pointerMesh?.clear();
        storage.pointerMesh && this.remove(storage.pointerMesh);
        storage.pointerMesh = null;
    },
    input(controls, storage) {
        const { x, y } = this.pointer;
        if (storage.pointerMesh === null) {
            storage.pointerMesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({ color: 0x00ff00 }),
            );
            storage.pointerMesh.material.transparent = true;
            storage.pointerMesh.material.opacity = 0.5;
            storage.pointerMesh.position.set(x, 0.5, y);
            this.add(storage.pointerMesh);
        } else {
            storage.pointerMesh.position.set(x, 0.5, y);
        }

        const pointer = storage.pointerMesh;

        // if obstacle, color red, if empty, color green, if cover, color blue
        if (this.grid.grid[x][y].type === "Obstacle") {
            pointer.material.color.set("red");
        } else if (this.grid.grid[x][y].type === "Empty") {
            pointer.material.color.set("green");
        } else if (this.grid.grid[x][y].type === "Cover") {
            pointer.material.color.set("blue");
        }

        if (controls.mouse[THREE.MOUSE.LEFT]) {
            this.grid.clearCell(x, y);
        }
    },
    async performAction() {},
    storage: { pointerMesh: null },
};

export const Move: Mode<{ target: THREE.Vector2 | null; path: THREE.Vector2[] }> = {
    name: "Move",
    connect(storage) {
        if (this.selectedTile) {
            const { x, y } = this.selectedTile;
            const walkable = this.grid.walkableTiles([x, y], 8);
            this.drawWalkable(walkable);
        }

        storage.path = [];
        storage.target = null;
    },
    disconnect(storage) {
        storage.target = null;
        this.drawWalkable(new Set());
        this.drawPath([]);
    },
    input(controls, storage) {
        if (!controls.mouse[THREE.MOUSE.LEFT]) return;
        if (!this.selectedTile) return;

        const { x, y } = this.pointer;
        const cell = this.grid.grid[x][y];

        if (cell.type === "Obstacle") return;
        if (typeof cell.unit === "number") return;

        let path = this.grid.tracePath(this.selectedTile!, new THREE.Vector2(x, y));

        if (!path || path.length === 0) return;
        if (path.length > 8) path = path.slice(-9);

        storage.path = path;
        storage.target = path[0];

        this.drawPath(path);
    },
    async performAction(storage) {
        if (this._isBlocked) return;
        if (!storage.target) return;
        if (!this.selectedUnit) return;
        if (!this.selectedTile) return;
        if (!storage.path) return;

        this._isBlocked = true;

        const unitId = this.selectedUnit.id;
        const unit = this.selectedUnit;
        const path = storage.path;

        this.grid.grid[this.selectedTile.x][this.selectedTile.y].unit = null;
        this.grid.grid[storage.target.x][storage.target.y].unit = unitId;
        this.selectedUnit = null;
        this.selectedTile = null;

        this.drawPath([]);
        this.drawWalkable(new Set());
        this.mode = None;

        await unit.walk(path);

        storage.path = [];
        storage.target = null;
        this._isBlocked = false;
    },
    storage: { target: null, path: [] },
};

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export const None: Mode<{}> = {
    name: "None",
    connect() {},
    disconnect() {},
    input(controls) {
        if (!controls.mouse[THREE.MOUSE.LEFT]) {
            return;
        }

        const { x, y } = this.pointer;
        const cell = this.grid.grid[x][y];

        if (this.selectedTile !== null && this.selectedTile.x === x && this.selectedTile.y === y) {
            return;
        }

        if (typeof cell.unit === "number" && cell.type !== "Obstacle") {
            this.selectedUnit = this.units[cell.unit];
            this.selectedTile = new THREE.Vector2(x, y);
            this.switchMode(Move);
        }
    },
    async performAction() {},
    storage: {},
};

export type GameMode = typeof None | typeof Move;
