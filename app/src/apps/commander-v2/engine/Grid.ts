// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Tile } from "./Game";
import { models } from "./scene";
import { clone } from "three/examples/jsm/utils/SkeletonUtils.js";

export class Grid extends THREE.Object3D {
    public readonly grid: Tile[][];
    public readonly meshes: { [key: string]: THREE.Object3D | THREE.Group } = {};
    public readonly size: number = 30;
    public readonly floor = new THREE.Group();

    constructor(size: number) {
        super();
        this.size = size;
        this.grid = Array.from({ length: size }, () => Array(size).fill({ type: "Empty" }));
        this.add(this.floor);
        this.initFloorTiles(size);
    }

    isInBounds(x: number, y: number) {
        return x >= 0 && x < this.size && y >= 0 && y < this.size;
    }

    initFloorTiles(size: number) {
        const mesh = models.base_tile.scene.children[0] as THREE.Mesh;
        const tileMaterial = mesh.material as THREE.MeshStandardMaterial;
        const material = tileMaterial.clone();
        const floor = new THREE.Mesh(new THREE.PlaneGeometry(size, size), material);

        floor.rotation.x = -Math.PI / 2;
        floor.position.set(size / 2 - 0.5, 0, size / 2 - 0.5);
        this.floor.add(floor);

        // alternatively, add individual tiles
        // for (let i = 0; i < size; i++) {
        //     for (let j = 0; j < size; j++) {
        //         const floorTile = clone(models.base_tile.scene);
        //         floorTile.position.set(i, 0, j);
        //         floorTile.scale.set(1.1, 1, 1.1);
        //         this.floor.add(floorTile);
        //     }
        // }
    }

    clearCell(x: number, y: number) {
        if (this.grid[x][y].type === "Obstacle") {
            this.remove(this.meshes[`${x}-${y}`].clear());
        }

        let unit;
        if (this.grid[x][y].type === "Cover") {
            unit = this.grid[x][y].unit;
            this.remove(this.meshes[`${x}-${y}-UP`].clear());
        }

        if (this.grid[x][y].type === "Empty") {
            return
        }

        this.grid[x][y] = { type: "Empty", unit };
    }

    drawBarrier(x: number, z: number, direction: "UP" | "DOWN" | "LEFT" | "RIGHT") {
        // const fence = clone(models.barrier_steel.scene);
        // fence.scale.set(1, 1.5, 1);
        // fence.position.set(x, 0, z);
        const mesh = new THREE.Mesh(
            new THREE.BoxGeometry(0.1, 0.8, 1),
            new THREE.MeshStandardMaterial({ color: 0x333333 }),
        );
        mesh.position.set(x, 0.4, z);

        switch (direction) {
            case "UP": {
                mesh.position.z -= 0.5;
                mesh.rotation.y = Math.PI / 2;
                // fence.rotation.y = Math.PI;
                // return fence;
                return mesh;
            }
            // case "DOWN": return fence;
            case "DOWN": {
                mesh.position.z += 0.5;
                mesh.rotation.y = Math.PI / 2;
                // mesh.rotation.y = -Math.PI / 2;
                return mesh;
            }
            case "LEFT": {
                mesh.position.x -= 0.5;

                // fence.rotation.y = -Math.PI / 2;
                // return fence;
                return mesh;
            }
            case "RIGHT": {
                mesh.position.x += 0.5;

                return mesh;
                // fence.rotation.y = Math.PI / 2;
                // return fence;
            }
        }
    }

    initRandom() {
        const texture = new THREE.TextureLoader().load("/images/texture-concrete.jpg");
        texture.wrapS = THREE.RepeatWrapping;
        texture.wrapT = THREE.RepeatWrapping;
        texture.repeat.set(1, 1);

        this.grid.forEach((col, x) => {
            col.forEach((_el, z) => {
                if (Math.random() > 0.7) {
                    const rngBool = () => Math.random() > 0.5;
                    const tile = (this.grid[x][z] = {
                        type: "Cover",
                        UP: rngBool(),
                        DOWN: rngBool(),
                        LEFT: rngBool(),
                        RIGHT: rngBool(),
                    });

                    // place obstacles instead of cover
                    if (tile.DOWN && tile.LEFT && tile.RIGHT && tile.UP) {
                        this.grid[x][z] = { type: "Obstacle" };

                        const barrels = clone(models.barrel_stack.scene);
                        barrels.scale.set(0.5, 0.5, 0.5);
                        barrels.position.set(x, 0, z);

                        this.meshes[`${x}-${z}`] = barrels;
                        this.add(barrels);
                        return;
                    }

                    const group = new THREE.Group();

                    if (tile.UP) group.add(this.drawBarrier(x, z, "UP"));
                    if (tile.DOWN) group.add(this.drawBarrier(x, z, "DOWN"));
                    if (tile.LEFT) group.add(this.drawBarrier(x, z, "LEFT"));
                    if (tile.RIGHT) group.add(this.drawBarrier(x, z, "RIGHT"));

                    this.meshes[`${x}-${z}-UP`] = group;
                    this.add(group);
                }
            });
        });
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
                    const to = this.grid[x][y];
                    const from = this.grid[nx][ny];
                    const direction = this.coordsToDirection([nx, ny], [x, y]);

                    if (to.type === "Obstacle") continue;

                    if (to.type === "Cover") {
                        if (direction === "UP" && to.DOWN) continue;
                        if (direction === "DOWN" && to.UP) continue;
                        if (direction === "LEFT" && to.RIGHT) continue;
                        if (direction === "RIGHT" && to.LEFT) continue;
                    }

                    if (from.type === "Cover") {
                        if (direction === "UP" && from.UP) continue;
                        if (direction === "DOWN" && from.DOWN) continue;
                        if (direction === "LEFT" && from.LEFT) continue;
                        if (direction === "RIGHT" && from.RIGHT) continue;
                    }

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

    private coordsToDirection(from: [number, number], to: [number, number]) {
        let [x0, y0] = from;
        let [x1, y1] = to;

        if (x0 < x1) return "RIGHT";
        if (x0 > x1) return "LEFT";
        if (y0 < y1) return "DOWN";
        if (y0 > y1) return "UP";
    }

    /**
     * Traces a path from start to end using the wave algorithm.
     */
    tracePath(start: [number, number], end: [number, number], _limit: number = 30) {
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

                    const to = this.grid[x][y];
                    const from = this.grid[nx][ny];
                    const direction = this.coordsToDirection([nx, ny], [x, y]);

                    if (to.type === "Obstacle") continue;
                    if (to.type === "Cover") {
                        if (direction === "UP" && to.DOWN) continue;
                        if (direction === "DOWN" && to.UP) continue;
                        if (direction === "LEFT" && to.RIGHT) continue;
                        if (direction === "RIGHT" && to.LEFT) continue;
                    }

                    if (from.type === "Cover") {
                        if (direction === "UP" && from.UP) continue;
                        if (direction === "DOWN" && from.DOWN) continue;
                        if (direction === "LEFT" && from.LEFT) continue;
                        if (direction === "RIGHT" && from.RIGHT) continue;
                    }

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
                const [nx, ny] = [x1 + dx, y1 + dy];
                if (!this.isInBounds(nx, ny)) {
                    continue;
                }

                const direction = this.coordsToDirection([x1, y1], [nx, ny]);
                const from = this.grid[x1][y1];
                const to = this.grid[nx][ny];

                if (to.type === "Cover") {
                    if (direction === "UP" && to.DOWN) continue;
                    if (direction === "DOWN" && to.UP) continue;
                    if (direction === "LEFT" && to.RIGHT) continue;
                    if (direction === "RIGHT" && to.LEFT) continue;
                }

                if (from.type === "Cover") {
                    if (direction === "UP" && from.UP) continue;
                    if (direction === "DOWN" && from.DOWN) continue;
                    if (direction === "LEFT" && from.LEFT) continue;
                    if (direction === "RIGHT" && from.RIGHT) continue;
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

        return path;
    }
}
