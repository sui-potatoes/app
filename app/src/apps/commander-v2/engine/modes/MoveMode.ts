// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "../Game";
import { Controls } from "../Controls";
import { Mode } from "./Mode";
import { NoneMode } from "./NoneMode";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { Unit } from "../Unit";

const COLOR = 0x1ae7bf;
const DARKER_COLOR = 0x568882;

export type MoveModeEvent = {
    perform: { unit: Unit; path: THREE.Vector2[] };
    trace: { path: THREE.Vector2[] };
};

/**
 * Move mode allows the player to move the selected unit.
 * It shows the walkable tiles and the path to the target.
 *
 * - Move costs 1 AP.
 */
export class MoveMode implements Mode {
    /** Name of the Mode */
    public readonly name = "move";
    /** Mode action cost */
    public readonly cost = 1;
    /** Target tile position */
    public target: THREE.Vector2 | null = null;
    /** Path to the target */
    public path: THREE.Vector2[] = [];
    /** Line used for drawing paths */
    private line: Line2 | null = null;
    /** Click callback  */
    private _clickCb = ({}: { button: number }) => {};
    /** The Group used for highlighting tiles */
    public readonly highlight = new THREE.Group();

    constructor(private controls: Controls) {}

    connect(this: Game, mode: this) {
        if (!this.selectedUnit) return this.switchMode(new NoneMode());

        this.add(mode.highlight);

        mode._clickCb = mode.onClick.bind(this);
        mode.controls.addEventListener("click", mode._clickCb);

        if (this.selectedUnit.props.ap.value == 0) {
            const { x, y } = this.selectedUnit.gridPosition;
            const singleTile = [x, y, 0] as [number, number, number];
            return mode.drawWalkable(new Set([singleTile]));
        }

        const mobility = this.selectedUnit.props.stats.mobility;
        const { x, y } = this.selectedUnit.gridPosition;
        const walkable = this.grid.walkableTiles([x, y], mobility);
        mode.drawWalkable(walkable);
    }

    disconnect(this: Game, mode: this) {
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
        unit.spendAp(mode.cost);
        await unit.walk(path);

        this.eventBus?.dispatchEvent({
            type: "game:move:perform",
            unit,
            path,
        });

        unit.gridPosition.set(mode.target.x, mode.target.y);
        mode.path = [];
        mode.target = null;
        this._isBlocked = false;
    }

    // === Custom methods ===

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

        const points = path.map(([x, z]) => new THREE.Vector3(x, 0.1, -z));
        this.line = newLine(points);
        this.highlight.add(this.line);
    }

    drawWalkable(tiles: Set<[number, number, number]>) {
        this.clearHighlight();
        tiles.forEach(([x, z, distance]) => {
            const geometry = new THREE.BoxGeometry(1, 0.1, 1);
            const material = new THREE.MeshStandardMaterial({
                color: DARKER_COLOR,
                transparent: true,
                opacity: 2 / (distance + 2),
            });

            const cube = new THREE.Mesh(geometry, material);
            cube.position.set(x, 0.001, -z);
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

        if (this.selectedUnit === null) return;
        if (!(this.mode instanceof MoveMode)) {
            return console.error(`Invalid mode ${this.mode.name}`);
        }

        if (button === THREE.MOUSE.LEFT) {
            if (tile.type === "Unwalkable") return;
            if (tile.unit) {
                this.selectUnit(x, z); // order of operations is important!
                this.switchMode(this.mode);
                return;
            }

            if (this.selectedUnit.props.ap.value === 0) return;

            mode.target = new THREE.Vector2(x, z);
            const limit = this.selectedUnit.props.stats.mobility + 1;

            let path = this.grid.tracePath(this.selectedUnit?.gridPosition!, mode.target, limit);
            if (!path || path.length === 0) return;
            if (path.length > limit) path = path.slice(-limit);
            path.reverse();
            mode.path = path.map(([x, z]) => new THREE.Vector2(x, -z));
            mode.target = path[path.length - 1]; // update target to the last step of the path
            mode.drawPath(path);

            this.eventBus?.dispatchEvent({ type: "game:move:trace", path });
        }
    }

    // === Spectator Mode ===

    forceTriggerAction(path: THREE.Vector2[]) {
        this.target = path[path.length - 1];
        this.path = path.map(([x, z]) => new THREE.Vector2(x, -z));
        this.drawPath(path);
    }
}

function newLine(path: THREE.Vector3[]) {
    const curve = new THREE.CatmullRomCurve3(path, false, "catmullrom", 0.05);
    const points = curve.getPoints(30);
    const geometry = new THREE.BufferGeometry().setFromPoints(points);
    const material = new THREE.LineBasicMaterial({ color: 0xff0000 });
    const curveObject = new THREE.Line(geometry, material);

    return new Line2(
        new LineGeometry().fromLine(curveObject),
        new LineMaterial({ color: COLOR, linewidth: 3, alphaToCoverage: true }),
    );
}
