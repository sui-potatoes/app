// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Controls } from "./Controls";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { Unit } from "./Unit";
import { Grid } from "./Grid";

export type Tile =
    | { type: "Empty"; unit?: number }
    | { type: "Obstacle" }
    | { type: "Cover"; UP: boolean; DOWN: boolean; LEFT: boolean; RIGHT: boolean; unit?: number };

export type Mode = "Move" | "None" | "Edit";

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
    public mode: Mode = "None";

    /** In Edit mode, a mesh follows the pointer position */
    private pointerMesh: THREE.Mesh | null = null;

    /** Line used for drawing paths */
    private line: Line2 | null = null;
    /** Selected Unit */
    private selected: Unit | null = null;
    /** Selected Tile (assuming Unit is there) */
    private selectedTile: THREE.Vector2 | null = null;
    /** Target Tile (eg, the target destination in Move action) */
    private targetTile: THREE.Vector2 | null = null;
    /** Active pointer based on input */
    private pointer: THREE.Vector2 = new THREE.Vector2();
    private units: { [key: number]: Unit } = {};

    private _isBlocked: boolean = false;

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
            // throw new Error("Unit cannot be placed on an obstacle");
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
        // in default mode we can select units and then switch to Move mode
        if (this.mode == "None") {
            if (controls.mouse[THREE.MOUSE.LEFT]) {
                let { x, y: z } = this.pointer;
                if (this.grid.grid[x][z].type === "Obstacle") return;
                if (!this.grid.grid[x][z].unit) return;

                const walkable = this.grid.walkableTiles([x, z], 8);
                this.drawWalkable(walkable);
                this.selectedTile = new THREE.Vector2(x, z);
                this.selected = this.units[this.grid.grid[x][z].unit];
                this.mode = "Move";
                return;
            }
        }

        // in edit mode a mesh follows the pointer position
        if (this.mode == "Edit") {
            let { x, y: z } = this.pointer;
            if (this.pointerMesh == null) {
                this.pointerMesh = new THREE.Mesh(
                    new THREE.BoxGeometry(1, 1, 1),
                    new THREE.MeshStandardMaterial({
                        color: "red",
                        transparent: true,
                        opacity: 0.3,
                    }),
                );
                this.pointerMesh.position.set(x, 0.5, z);
                this.add(this.pointerMesh);
            } else {
                this.pointerMesh.position.set(x, 0.5, z);
            }

            if (!(this.pointerMesh.material instanceof THREE.MeshStandardMaterial)) {
                throw new Error("Material is off");
            }

            // if obstacle, color red, if empty, color green, if cover, color blue
            if (this.grid.grid[x][z].type === "Obstacle") {
                this.pointerMesh.material.color.set("red");
            } else if (this.grid.grid[x][z].type === "Empty") {
                this.pointerMesh.material.color.set("green");
            } else if (this.grid.grid[x][z].type === "Cover") {
                this.pointerMesh.material.color.set("blue");
            }

            if (controls.mouse[THREE.MOUSE.LEFT]) {
                this.grid.clearCell(x, z);
            }
        }

        if (this.mode == "Move") {
            if (controls.mouse[THREE.MOUSE.LEFT]) {
                let { x, y } = this.pointer;

                // if we have a unit selected and we're clicking on an empty tile
                // try drawing a path to this tile
                if (this.selected && this.grid.grid[x][y].type !== "Obstacle") {
                    const path = this.grid.tracePath(
                        [this.selected.position.x, this.selected.position.z],
                        [x, y],
                        8,
                    );

                    if (path && path.length > 0) {
                        const newDestination = new THREE.Vector2(...path.slice(-8 - 1)[0]);

                        if (
                            this.targetTile?.x != newDestination.x ||
                            this.targetTile?.y != newDestination.y
                        ) {
                            this.targetTile = newDestination;
                            this.drawPath(path.slice(-8 - 1) as [number, number][]);
                        }
                    }
                }
            }
        }

        if (controls.mouse[THREE.MOUSE.RIGHT]) {
            this.switchMode("None");
        }
    }

    async performAction() {
        if (this._isBlocked) {
            return;
        }

        if (this.mode === "None") {
            return;
        }

        if (
            this.mode === "Move" &&
            this.selected &&
            this.selectedTile &&
            this.targetTile &&
            this.grid.grid[this.selectedTile.x][this.selectedTile.y].type !== "Obstacle" &&
            this.grid.grid[this.targetTile.x][this.targetTile.y].type !== "Obstacle"
        ) {
            this._isBlocked = true;

            const path = this.grid.tracePath(
                this.selectedTile.toArray(),
                this.targetTile.toArray(),
                8,
            );

            if (!path) {
                this._isBlocked = false;
                return;
            }

            const unitId = this.selected.id;
            const unit = this.selected;
            // @ts-ignore
            this.grid.grid[this.selectedTile.x][this.selectedTile.y].unit = null;
            // @ts-ignore
            this.grid.grid[this.targetTile.x][this.targetTile.y].unit = unitId;
            this.selected = null;
            this.selectedTile = null;
            this.targetTile = null;
            this.drawPath([]);
            this.drawWalkable(new Set());
            this.mode = "None";

            await unit.walk(path.map(([x, z]) => new THREE.Vector2(x, z)));
            this._isBlocked = false;
        }
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
        if (this.pointer.x == x && this.pointer.y == z) {
            return;
        }

        this.pointer.set(x, z);

        if (this.grid.grid[x][z].type === "Obstacle") {
            return;
        }

        // if a starting cell is selected, highlight walkable tiles just once
        if (this.selected) {
            return;
        }

        if (this.grid.grid[x][z].unit) {
            return; // highlight the unit tile when pointer over
        }
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
    drawPath(path: [number, number][]) {
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

    drawTarget() {}

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

    dispose() {
        // TODO: implement me
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

    switchMode(mode: Mode) {
        this.mode = mode;
        this.selected = null;
        this.selectedTile = null;

        this.pointerMesh?.geometry.dispose();
        this.pointerMesh && this.remove(this.pointerMesh);
        this.pointerMesh = null;

        this.targetTile = null;
        this.drawPath([]);
        this.drawWalkable(new Set());
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
