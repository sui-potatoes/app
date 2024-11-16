// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Controls } from "./Controls";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { Unit } from "./Unit";

export type Tile =
    | { type: "Empty"; unit?: number }
    | { type: "Obstacle" }
    | { type: "Cover"; UP: boolean; DOWN: boolean; LEFT: boolean; RIGHT: boolean; unit?: number };

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
    /** Grid of Tiles */
    private grid: Tile[][];

    /** Line used for drawing paths */
    private line: Line2 | null = null;
    /** Selected Unit */
    private selected: Unit | null = null;
    /** Selected target (not always available) */
    // private target: THREE.Vector2 | null = null;
    /** Active pointer based on input */
    private pointer: THREE.Vector2 = new THREE.Vector2();
    /** Highlighted cell */
    // private targetCell: THREE.Object3D | null = null;

    private units: { [key: number]: Unit } = {};

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
        this.grid = this.initGrid(size);

        // other initializers
        this.add(this.highlight);
    }

    get offset() {
        return 30 / 2 - 0.5;
    }

    addUnit(unit: Unit, x: number, z: number) {
        if (x < 0 || x >= this.grid.length || z < 0 || z >= this.grid[0].length) {
            throw new Error("Invalid Unit positioning");
        }

        if (this.grid[x][z].type === "Obstacle") {
            throw new Error("Unit cannot be placed on an obstacle");
        }

        unit.position.set(x, 0, z);
        this.grid[x][z].unit = unit.id;
        this.units[unit.id] = unit;
        this.add(unit);

        console.log(unit);
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

    initGrid(size: number) {
        const grid = Array.from({ length: size }, () => Array(size).fill({ type: "Empty" }));
        const texture = new THREE.TextureLoader().load("/images/texture-concrete.jpg");
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.repeat.set(1, 1);

        grid.forEach((col, x) => {
            col.forEach((_el, z) => {
                if (Math.random() > 0.6) {
                    const rngBool = () => Math.random() > 0.5;
                    const tile = grid[x][z] = { type: "Cover", UP: true, DOWN: rngBool(), LEFT: rngBool(), RIGHT: rngBool() };

                    const cube = (direction: "UP" | "DOWN" | "LEFT" | "RIGHT") => {
                        const geometry = new THREE.BoxGeometry(0.1, 1, 1);
                        const material = new THREE.MeshStandardMaterial({ map: texture });
                        const cube = new THREE.Mesh(geometry, material);
                        cube.position.set(x, 0.3, z);

                        switch (direction) {
                            case "UP": {
                                cube.rotation.y = Math.PI / 2;
                                cube.position.set(x, 0.3, z - 0.5);
                                break;
                            }
                            case "DOWN": {
                                cube.rotation.y = Math.PI / 2;
                                cube.position.set(x, 0.3, z + 0.5);
                                break;
                            }
                            case "LEFT": {
                                cube.position.set(x - 0.5, 0.3, z);
                                break;
                            }
                            case "RIGHT": {
                                cube.position.set(x + 0.5, 0.3, z);
                                break;
                            }
                        }

                        // cube.add(plane);

                        return cube; //, plane];
                    };

                    // this.add(...cube("UP"));
                    if (tile.UP) this.add(cube("UP"));
                    if (tile.DOWN) this.add(cube("DOWN"));
                    if (tile.LEFT) this.add(cube("LEFT"));
                    if (tile.RIGHT) this.add(cube("RIGHT"));
                }
            });
        });

        return grid;
    }

    /** Called every frame to update the game state. */
    input(controls: Controls) {
        if (Object.values(controls.arrows).includes(true)) {
            const unit = Object.values(this.units)[0];
            switch (true) {
                case controls.arrows.UP:
                    unit.position.z -= 0.1;
                    break;
                case controls.arrows.DOWN:
                    unit.position.z += 0.1;
                    break;
                case controls.arrows.LEFT:
                    unit.position.x -= 0.1;
                    break;
                case controls.arrows.RIGHT:
                    unit.position.x += 0.1;
                    break;
            }
        }

        if (controls.mouse[THREE.MOUSE.LEFT]) {
            let { x, y } = this.pointer;

            // if we're clicking on a unit, select it
            if (
                this.grid[x][y].type !== "Obstacle" &&
                typeof this.grid[x][y].unit === "number" &&
                !this.selected
            ) {
                this.selected = this.units[this.grid[x][y].unit];
                const walkable = this.walkableTiles([x, y], 8);
                this.drawWalkable(walkable);
            }

            // if we have a unit selected and we're clicking on an empty tile
            // try drawing a path to this tile
            if (this.selected && this.grid[x][y].type !== "Obstacle") {
                const path = this.tracePath(
                    [this.selected.position.x, this.selected.position.z],
                    [x, y],
                    8,
                );

                if (path && path.length > 0) {
                    // this.target = new THREE.Vector2(...path[path.length - 1]);
                }
            }
        }

        if (controls.mouse[THREE.MOUSE.RIGHT]) {
            this.selected = null;
            this.drawPath([]);
            this.drawWalkable(new Set());
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

        if (this.grid[x][z].type === "Obstacle") {
            return;
        }

        // if a starting cell is selected, highlight walkable tiles just once
        if (this.selected) {
            return;
        }

        const tiles = this.walkableTiles([x, z], 8);
        this.drawWalkable(tiles);
    }

    updateUnits() {
        for (let id in this.units) {
            this.units[id].update();
        }
    }

    /** Returns the Von Neumann neighborhood of a cell in this order: right, down, left, up. */
    private *vonNeumann(x: number, y: number) {
        if (x < this.grid.length - 1) yield [x + 1, y];
        if (y < this.grid[0].length - 1) yield [x, y + 1];
        if (x > 0) yield [x - 1, y];
        if (y > 0) yield [x, y - 1];
    }

    /**
     * Use wave algorithm to find walkable tiles from a starting point.
     */
    walkableTiles(start: [number, number], limit: number = 30) {
        let [x0, y0] = start;
        let map = Array.from({ length: this.grid.length }, () =>
            Array(this.grid[0].length).fill(0),
        );
        let queue = [[x0, y0]];
        let tiles: Set<[number, number, number]> = new Set([[x0, y0, 1]]);
        let num = 1;

        map[x0][y0] = num;

        search: while (queue.length > 0) {
            num += 1;
            let tempQueue = [...queue];
            queue = [];

            if (num > limit + 1) {
                break;
            }

            for (let [nx, ny] of tempQueue) {
                for (let [x, y] of this.vonNeumann(nx, ny)) {
                    // cover in the target tile restricts movement
                    let to = this.grid[x][y];
                    let from = this.grid[nx][ny];

                    if (to.type === "Obstacle") continue;

                    // DOWN->UP rules
                    if (to.type === "Cover" && to.UP && y > ny && x == nx) continue;
                    if (from.type === "Cover" && from.UP && y < ny) continue;

                    // UP->DOWN rules
                    if (to.type === "Cover" && to.DOWN && y < ny && x == nx) continue;
                    if (from.type === "Cover" && from.DOWN && y > ny) continue;

                    // RIGHT->LEFT rules
                    if (to.type === "Cover" && to.LEFT && x > nx && y == ny) continue;
                    if (from.type === "Cover" && from.LEFT && x < nx && y == ny) continue;

                    // LEFT->RIGHT rules
                    if (to.type === "Cover" && to.RIGHT && x < nx && y == ny) continue;
                    if (from.type === "Cover" && from.RIGHT && x > nx && y == ny) continue;

                    if (map[x][y] == 0) {
                        map[x][y] = num;
                        queue.push([x, y, num]);
                        tiles.add([x, y, num]);
                    }
                }
            }
        }

        return tiles;
    }

    /**
     * Traces a path from start to end using the wave algorithm.
     */
    tracePath(start: [number, number], end: [number, number], limit: number = 30) {
        let [x0, y0] = start;
        let [x1, y1] = end;
        let [width, height] = [this.grid.length, this.grid[0].length];

        // early return
        if (x0 == x1 && y0 == y1) return;
        if (x0 < 0 || x0 >= width || x1 < 0 || x1 >= width) return;
        // if (Math.abs(x0 - x1) + Math.abs(y0 - y1) > limit) return;

        let map = Array.from({ length: width }, () => Array(height).fill(0));
        let queue = [[x0, y0]];
        let num = 1;

        map[x0][y0] = num;

        search: while (queue.length > 0) {
            num += 1;
            let tempQueue = [...queue];
            queue = [];

            for (let [nx, ny] of tempQueue) {
                for (let [x, y] of this.vonNeumann(nx, ny)) {
                    if (map[x][y] !== 0) continue;

                    let to = this.grid[x][y];
                    let from = this.grid[nx][ny];

                    if (to.type === "Obstacle") continue;

                    // DOWN->UP rules
                    if (to.type === "Cover" && to.UP && y > ny && x == nx) continue;
                    if (from.type === "Cover" && from.UP && y < ny  && x == nx) continue;

                    // UP->DOWN rules
                    if (to.type === "Cover" && to.DOWN && y < ny && x == nx) continue;
                    if (from.type === "Cover" && from.DOWN && y > ny && x == nx) continue;

                    // RIGHT->LEFT rules
                    if (to.type === "Cover" && to.LEFT && x > nx && y == ny) continue;
                    if (from.type === "Cover" && from.LEFT && x < nx && y == ny) continue;

                    // LEFT->RIGHT rules
                    if (to.type === "Cover" && to.RIGHT && x < nx && y == ny) continue;
                    if (from.type === "Cover" && from.RIGHT && x > nx && y == ny) continue;

                    if (x == x1 && y == y1) {
                        map[x][y] = num;
                        break search;
                    }

                    map[x][y] = num;
                    queue.push([x, y]);
                }
            }
        }

        if (map[x1][y1] === 0) {
            return;
        }

        let path = [[x1, y1]];
        let num2 = map[x1][y1];

        while (num2 > 1) {
            for (let [dx, dy] of [
                [1, 0],
                [-1, 0],
                [0, 1],
                [0, -1],
            ]) {
                let [nx, ny] = [x1 + dx, y1 + dy];

                if (nx < 0 || nx >= width || ny < 0 || ny >= height) {
                    continue;
                }

                if (map[nx][ny] === num2 - 1) {
                    x1 = nx;
                    y1 = ny;
                    path.push([x1, y1]);
                    num2--;
                    break;
                }
            }
        }

        console.log('path', path);

        this.drawPath(path.slice(-limit - 1) as [number, number][]);
        return path;
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
        // @ts-ignore
        this.highlight.children.forEach((child: THREE.Mesh) => {
            child.geometry.dispose();
            Array.isArray(child.material)
                ? child.material.forEach((m) => m.dispose())
                : child.material.dispose();
        });
        this.highlight.clear();

        tiles.forEach(([x, z, distance]) => {
            const geometry = new THREE.BoxGeometry(1, 0.1, 1);
            const material = new THREE.MeshStandardMaterial({
                color: "red",
                transparent: true,
                opacity: 3 / (distance + 2),
            });

            const cube = new THREE.Mesh(geometry, material);
            cube.position.set(x, 0.1, z);
            this.highlight.add(cube);
        });
    }

    dispose() {
        // TODO: implement me
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
