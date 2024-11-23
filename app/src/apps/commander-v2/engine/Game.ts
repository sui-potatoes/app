// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Controls } from "./Controls";
import { Unit } from "./Unit";
import { Grid } from "./Grid";
import { Mode } from "./modes/Mode";
import { NoneMode } from "./modes/NoneMode";

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
    /** The Grid object */
    public readonly grid: Grid;

    /**
     * Mode is a configurable behavior that can be switched at runtime. It allows
     * the game to have different states of interaction. For example, when a unit
     * is selected, the mode changes to `Move` by default. If another action is
     * selected, the mode changes to that action. Additionally, there's an `Edit`
     * mode which allows modifying the map.
     *
     * Modes are what define the game's behavior and interaction.
     *
     * @see Mode
     */
    public mode: Mode = new NoneMode();

    /** Selected Unit */
    protected selectedUnit: Unit | null = null;
    /** Selected Tile (assuming Unit is there) */
    protected selectedTile: THREE.Vector2 | null = null;

    /** Active pointer based on input */
    protected pointer: THREE.Vector2 = new THREE.Vector2();
    /** List of `Unit`s placed on the map, indexed by their Unique ID */
    protected units: { [key: number]: Unit } = {};
    /** Flag to block execution any other action from being run in parallel */
    protected _isBlocked: boolean = false;

    constructor(useGrid: boolean = false) {
        super();

        const size = 30; // Game.SIZE;

        if (useGrid) {
            const offset = this.offset;
            const helper = new THREE.GridHelper(30, 30);
            helper.position.set(offset, -0.01, offset);
            this.add(helper);
        }

        // create the intersectable plane
        this.plane = this.initPlane(size);
        this.add(this.plane);

        // init the grid with random obstacles
        this.grid = new Grid(size);
        this.grid.initRandom();
        this.add(this.grid);
    }

    get offset() {
        return 30 / 2 - 0.5;
    }

    addUnit(unit: Unit) {
        const { x, y: z } = unit.gridPosition;

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
        this.mode.input.call(this, controls, this.mode);
    }

    async performAction() {
        if (this._isBlocked) return;
        this.mode.performAction.call(this, this.mode);
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

    switchMode(mode: Mode) {
        this.mode.disconnect.call(this, this.mode);
        this.mode = mode;
        this.mode.connect.call(this, this.mode);
    }
}
