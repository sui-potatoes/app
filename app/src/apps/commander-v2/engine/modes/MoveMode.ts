// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";
import { NoneMode } from "./NoneMode";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";

export class MoveMode implements Mode {
    public target: THREE.Vector2 | null = null;
    public path: THREE.Vector2[] = [];

    /** Line used for drawing paths */
    private line: Line2 | null = null;

    /** Click callback  */
    private _clickCb = ({}: { button: number }) => {};

    /** The Group used for highlighting tiles */
    public readonly highlight = new THREE.Group();

    constructor(private controls: Controls) {}

    get name(): string {
        return "Move";
    }

    connect(this: Game, mode: this) {
        if (!this.selectedUnit) {
            throw new Error("Can't perform action without a selected Unit.");
        }

        this.add(mode.highlight);

        mode._clickCb = mode.onClick.bind(this);
        mode.controls.addEventListener("click", mode._clickCb);

        const { x, y } = this.selectedUnit.gridPosition;
        const walkable = this.grid.walkableTiles([x, y], 8);
        mode.drawWalkable(walkable);
    }

    disconnect(this: Game, mode: this) {
        // this.selectedTile = null;
        // this.selectedUnit = null;
        mode.target = null;
        mode.path = [];
        mode.clearHighlight();
        this.remove(mode.highlight);
        mode.drawWalkable(new Set());
        mode.drawPath([]);

        mode.controls.removeEventListener("click", mode._clickCb);
    }

    input(this: Game, _controls: Controls, _mode: this) {}

    async performAction(this: Game, mode: this) {
        if (this._isBlocked) return;
        if (!mode.target) return;
        if (!this.selectedUnit) return;
        if (!mode.path) return;

        this._isBlocked = true;

        const unitId = this.selectedUnit.id;
        const unit = this.selectedUnit;
        const path = mode.path;

        this.grid.grid[unit.gridPosition.x][unit.gridPosition.y].unit = null;
        this.grid.grid[mode.target.x][mode.target.y].unit = unitId;

        mode.drawPath([]);
        mode.drawWalkable(new Set());
        this.mode = new NoneMode();

        await unit.walk(path);

        unit.gridPosition.set(mode.target.x, mode.target.y);
        mode.path = [];
        mode.target = null;
        this._isBlocked = false;
    }

    /* Custom methods */

    /**
     * Draws a path on the grid.
     * @param path Array of grid coordinates.
     */
    drawPath(path: THREE.Vector2[]) {
        if (this.line) {
            this.highlight.remove(this.line);
            this.line.geometry.dispose();
            this.line.material.dispose();
            this.line = null;
        }

        if (path.length < 2) {
            return;
        }

        const points = path.map(([x, z]) => new THREE.Vector3(x, 0.3, z));
        this.line = newLine(points);
        this.highlight.add(this.line);
    }

    drawWalkable(tiles: Set<[number, number, number]>) {
        this.clearHighlight();
        tiles.forEach(([x, z, distance]) => {
            const geometry = new THREE.BoxGeometry(1, 0.1, 1);
            const material = new THREE.MeshStandardMaterial({
                color: "red",
                transparent: true,
                opacity: 2 / (distance + 2),
            });

            const cube = new THREE.Mesh(geometry, material);
            cube.position.set(x, 0.1, z);
            this.highlight.add(cube);
        });
    }

    clearHighlight() {
        // @ts-ignore
        this.highlight.children.forEach((child: THREE.Mesh) => {
            child.geometry.dispose();
            Array.isArray(child.material)
                ? child.material.forEach((m) => m.dispose())
                : child.material.dispose();
        });
        this.highlight.clear();
    }

    onClick(this: Game, { button }: { button: number }) {
        const { x, y: z } = this.pointer;
        const mode = this.mode as MoveMode;
        const tile = this.grid.grid[x][z];

        if (button === THREE.MOUSE.LEFT) {
            if (tile.type === "Obstacle") return;
            if (tile.unit) {
                this.selectUnit(x, z); // order of operations is important!
                this.switchMode(this.mode);
                return
            }

            if (this.selectUnit === null) return;

            mode.target = new THREE.Vector2(x, z);
            let path = this.grid.tracePath(this.selectedUnit?.gridPosition!, mode.target);
            if (!path || path.length === 0) return;
            if (path.length > 8) path = path.slice(-9);

            mode.path = path;
            mode.target = path[0]; // update target to the last step of the path
            mode.drawPath(path);
        }
    }
}

function newLine(points: THREE.Vector3[]) {
    const geometry = new LineGeometry().setPositions(points.map((p) => p.toArray()).flat());
    const material = new LineMaterial({
        color: "crimson",
        linewidth: 4,
        alphaToCoverage: false,
    });

    return new Line2(geometry, material);
}
