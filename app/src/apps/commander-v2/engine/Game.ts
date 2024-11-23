// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Controls } from "./Controls";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { Unit } from "./Unit";
import { Grid } from "./Grid";
import { None, GameMode } from "./Mode";

export type Tile =
    | { type: "Empty"; unit: number | null }
    | { type: "Obstacle"; unit: number | null }
    | {
          type: "Cover";
          UP: boolean;
          DOWN: boolean;
          LEFT: boolean;
          RIGHT: boolean;
          unit: number | null;
      };

/**
 * The base class for the Game scene and related objects. Contains the game logic,
 * grid movement, character stats, and other game-related data. A super-class for
 * game logic.
 *
 * TODO:
 * - implement Controls class
 * - implement Sound class
 * - implement Models and Textures classes
 */
export class Game extends THREE.Object3D {
    /** Default size of the Grid */
    static readonly SIZE: 30;
    /** The Plane used for intersections */
    public readonly plane: THREE.Mesh;
    /** The Group used for highlighting */
    public readonly highlight = new THREE.Group();
    /** The Grid object */
    public readonly grid: Grid;
    /** Default Mode is none - show nothing */
    public mode: GameMode = None;

    /** In Edit mode, a mesh follows the pointer position */
    // private pointerMesh: THREE.Mesh | null = null;

    /** Line used for drawing paths */
    private line: Line2 | null = null;

    /** Selected Unit */
    protected selectedUnit: Unit | null = null;
    /** Selected Tile (assuming Unit is there) */
    protected selectedTile: THREE.Vector2 | null = null;

    /** Target Tile (eg, the target destination in Move action) */
    // private targetTile: THREE.Vector2 | null = null;

    /** Active pointer based on input */
    protected pointer: THREE.Vector2 = new THREE.Vector2();
    /** List of `Unit`s placed on the map, indexed by their Unique ID */
    protected units: { [key: number]: Unit } = {};
    /** Flag to block execution any other action from being run in parallel */
    protected _isBlocked: boolean = false;

    constructor() {
        super();

        const size = 30; // Game.SIZE;
        const offset = this.offset;
        const helper = new THREE.GridHelper(30, 30);
        helper.position.set(offset, -0.01, offset);

        // create the intersectable plane
        this.plane = this.initPlane(size);
        this.add(this.plane);

        // init the grid with random obstacles
        this.grid = new Grid(size);
        this.grid.initRandom();
        this.add(this.grid);

        // other initializers
        this.add(this.highlight);
    }

    get offset() {
        return 30 / 2 - 0.5;
    }

    addUnit(unit: Unit, x: number, z: number) {
        if (!this.grid.isInBounds(x, z)) {
            throw new Error("Invalid Unit positioning");
        }

        if (this.grid.grid[x][z].type === "Obstacle") {
            return;
        }

        unit.position.set(x, 0, z);
        this.grid.grid[x][z].unit = unit.id;
        this.units[unit.id] = unit;
        this.add(unit);
    }

    initPlane(size: number) {
        const offset = this.offset;
        const geometry = new THREE.PlaneGeometry(size, size);
        const material = new THREE.MeshStandardMaterial({ color: 0xaaaaaa });
        const plane = new THREE.Mesh(geometry, material);

        plane.receiveShadow = true;
        plane.castShadow = false;
        plane.rotateX(-Math.PI / 2);
        plane.position.set(offset, -0.02, offset);

        return plane;
    }

    /** Called every frame to update the game state. */
    input(controls: Controls) {
        if (controls.mouse[THREE.MOUSE.RIGHT]) {
            this.switchMode(None);
            this.selectedTile = null;
            this.selectedUnit = null;
        }

        this.mode.input.call(this, controls, this.mode.storage as any);
    }

    async performAction() {
        if (this._isBlocked) return;

        this.mode.performAction.call(this, this.mode.storage as any);
    }

    /**
     * Update the state of the game based on the cursor intersection.
     * This is maintained by the `Controls` class.
     */
    update(cursor: THREE.Intersection) {
        const [rawX, _, rawZ] = cursor.point;
        const [x, z] = [Math.floor(rawX + 0.5), Math.floor(rawZ + 0.5)];

        this.updatePointer(x, z);
        this.updateUnits();
    }

    /**
     * Update the pointer position and highlight walkable tiles.
     */
    updatePointer(x: number, z: number) {
        if (this.pointer.x == x && this.pointer.y == z) return;

        this.pointer.set(x, z);

        if (this.grid.grid[x][z].type === "Obstacle") return;
        if (this.selectedUnit) return;
        if (this.grid.grid[x][z].unit) return; // highlight the unit tile when pointer over
    }

    updateUnits() {
        for (let id in this.units) {
            this.units[id].update();
        }
    }

    /**
     * Draws a path on the grid.
     * @param path Array of grid coordinates.
     */
    drawPath(path: THREE.Vector2[]) {
        if (this.line) {
            this.remove(this.line);
            this.line.geometry.dispose();
            this.line.material.dispose();
            this.line = null;
        }

        if (path.length < 2) {
            return;
        }

        const points = path.map(([x, z]) => new THREE.Vector3(x, 0.3, z));
        this.line = newLine(points);
        this.add(this.line);
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

    switchMode(mode: GameMode) {
        this.mode.disconnect.call(this, this.mode.storage as any);
        this.mode = mode;
        this.mode.connect.call(this, this.mode.storage as any);
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
