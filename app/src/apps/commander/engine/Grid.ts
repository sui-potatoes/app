// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Tile } from "./Game";
import { models } from "./models";
import { clone } from "three/examples/jsm/utils/SkeletonUtils.js";
import { Map as GameMap } from "../types/bcs";
import { bcs } from "@mysten/bcs";
import { normalizeSuiObjectId } from "@mysten/sui/utils";

const LocalPreset = bcs.struct("LocalPreset", {
    map: GameMap,
    positions: bcs.vector(bcs.vector(bcs.u8())),
});

/**
 * Grid follows the structure of the game board, similar to how it is handled in
 * Move. Grid coordinates are 0-indexed, with the origin at the top-left corner.
 *
 * [0, 0] - top left: first row, first column
 * [1, 0] - second row, first column
 * [0, 1] - first row, second column
 */
export class Grid extends THREE.Object3D {
    public readonly grid: Tile[][];
    public readonly meshes: { [key: string]: THREE.Object3D | THREE.Group } = {};
    public readonly floor = new THREE.Group();
    public spawnPositions: THREE.Vector2[] = [];

    constructor(public readonly size: number) {
        super();
        this.size = size;
        this.grid = [];

        // we cannot use Array(size).fill([]) because it will create a reference
        // to the same array and hence all the columns will be the same.
        //
        // hashtag: ilovejavascript
        for (let i = 0; i < size; i++) {
            this.grid.push([]);
            for (let j = 0; j < size; j++) {
                this.grid[i].push({ type: "Empty", unit: null });
            }
        }

        this.add(this.floor);
        this.initFloorTiles(size);
    }

    isInBounds(x: number, y: number) {
        return x >= 0 && x < this.size && y >= 0 && y < this.size;
    }

    initFloorTiles(size: number) {
        const texture = new THREE.TextureLoader().load("/textures/sand.jpg");
        texture.anisotropy = 2;
        const tileMaterial = new THREE.MeshStandardMaterial({
            map: texture,
        });

        tileMaterial.color = new THREE.Color(0xaaaaaa);

        const floor = new THREE.Mesh(new THREE.PlaneGeometry(size, size), tileMaterial);
        const secondFloor = new THREE.Mesh(
            new THREE.PlaneGeometry(size * 2, size * 2),
            tileMaterial.clone(),
        );

        // Enable shadows for floor
        floor.receiveShadow = true;
        secondFloor.receiveShadow = true;

        floor.rotation.x = -Math.PI / 2;
        floor.position.set(size / 2 - 0.5, 0, -(size / 2 - 0.5));

        secondFloor.rotation.x = -Math.PI / 2;
        secondFloor.position.set(size / 2, -0.1, -size / 2);

        // Initialize grass
        // Do not do it here yet.
        // this.initGrassFloorTiles(size);

        // add fog around the play area
        const fogMaterial = tileMaterial.clone();
        fogMaterial.color = new THREE.Color(0x000000);
        fogMaterial.opacity = 0.5;
        fogMaterial.transparent = true;

        const fog = new THREE.Mesh(new THREE.PlaneGeometry(size * 4, size * 4), fogMaterial);
        fog.receiveShadow = true;

        fog.rotation.x = -Math.PI / 2;
        fog.position.set(size / 2, -0.05, -size / 2);

        this.floor.add(floor);
        this.add(secondFloor);
    }

    /** Helper utility to draw grass on the ground */
    _initGrassFloorTiles(size: number) {
        // Add grass using instanced cones
        const grassGeometry = new THREE.ConeGeometry(0.02, 0.1, 4);
        const grassMaterial = new THREE.MeshStandardMaterial({
            color: 0x2d5a27,
            roughness: 0.8,
            metalness: 0.4,
        });

        // Create instanced mesh for grass
        const grassCount = 100 * size * size * 5; // 5 grass blades per tile
        const grassMesh = new THREE.InstancedMesh(grassGeometry, grassMaterial, grassCount);

        // Create dummy object for matrix calculations
        const dummy = new THREE.Object3D();

        // Position grass instances
        for (let i = 0; i < grassCount; i++) {
            const x = Math.random() * size - 0.5;
            const z = Math.random() * size - 0.5;
            const height = 0.05 + Math.random() * 0.05;
            const rotation = Math.random() * Math.PI * 2;
            const tilt = (Math.random() - 1) * 0.2; // Slight random tilt

            dummy.position.set(x, height / 2, -z);
            dummy.rotation.set(tilt, rotation, tilt);
            dummy.scale.set(0.2, height / 0.03, 0.2); // Scale height while keeping base size
            dummy.updateMatrix();

            grassMesh.setMatrixAt(i, dummy.matrix);
        }

        grassMesh.instanceMatrix.needsUpdate = true;
        grassMesh.castShadow = true;
        grassMesh.receiveShadow = true;
        this.floor.add(grassMesh);
    }

    clearCell(x: number, y: number) {
        if (this.grid[x][y].type === "Unwalkable") {
            this.remove(this.meshes[`${x}-${y}`]?.clear());
        }

        let unit = null;
        if (this.grid[x][y].type === "Cover") {
            unit = this.grid[x][y].unit;
            this.remove(this.meshes[`${x}-${y}`]?.clear());
        }

        if (this.grid[x][y].type === "Empty") {
            return;
        }

        this.grid[x][y] = { type: "Empty", unit };
    }

    setCell(x: number, z: number, tile: Tile) {
        this.clearCell(x, z);
        this.grid[x][z] = { ...tile, unit: this.grid[x][z].unit };
        const group = new THREE.Group();

        if (tile.type === "Unwalkable") {
            this.grid[x][z] = { type: "Unwalkable", unit: null };

            const texture = new THREE.TextureLoader().load("/textures/crate.jpg");
            const mesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({ map: texture }),
            );
            mesh.material.color = new THREE.Color(0xaaaaaa);
            mesh.position.set(x, 0.5, -z);
            mesh.castShadow = true;
            mesh.receiveShadow = true;
            group.add(mesh);

            // if (models.barrel_stack === null) {
            //     throw new Error("Barrel stack model is not loaded!");
            // }

            // const barrels = clone(models.barrel_stack.scene);
            // barrels.scale.set(0.5, 0.5, 0.5);
            // barrels.position.set(x, 0, -z);

            // // Enable shadows for barrels
            // barrels.traverse((child) => {
            //     if (child instanceof THREE.Mesh) {
            //         child.castShadow = true;
            //         child.receiveShadow = true;
            //     }
            // });

            // this.meshes[`${x}-${z}`] = barrels;
            // this.add(barrels);
            // return;
        }

        if (tile.type === "Cover") {
            if (tile.up) group.add(this.drawBarrier(x, z, "UP", tile.up));
            if (tile.down) group.add(this.drawBarrier(x, z, "DOWN", tile.down));
            if (tile.left) group.add(this.drawBarrier(x, z, "LEFT", tile.left));
            if (tile.right) group.add(this.drawBarrier(x, z, "RIGHT", tile.right));
        }

        this.meshes[`${x}-${z}`] = group;
        this.add(group);
    }

    drawBarrier(x: number, z: number, direction: "UP" | "DOWN" | "LEFT" | "RIGHT", type: number) {
        const height = type == 1 ? 1 : 2.5;

        const texture = new THREE.TextureLoader().load("/textures/sandstone-brick.png");
        texture.colorSpace = THREE.SRGBColorSpace;
        const mesh = new THREE.Mesh(
            new THREE.BoxGeometry(0.1, height, 1),
            new THREE.MeshStandardMaterial({ map: texture }),
        );

        // Enable shadows for barriers
        mesh.material.color = new THREE.Color(0xaaaaaa);
        mesh.castShadow = true;
        mesh.receiveShadow = true;
        mesh.position.set(x, 0.5, -z);

        switch (direction) {
            case "UP": {
                mesh.position.x -= 0.5;
                return mesh;
            }
            case "DOWN": {
                mesh.position.x += 0.5;
                mesh.rotation.y = Math.PI;
                return mesh;
            }
            case "LEFT": {
                mesh.position.z += 0.5;
                mesh.rotation.y = -Math.PI / 2;
                return mesh;
            }
            case "RIGHT": {
                mesh.position.z -= 0.5;
                mesh.rotation.y = -Math.PI / 2;
                return mesh;
            }
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

        while (queue.length > 0) {
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

                    if (to.unit !== null) continue;
                    if (to.type === "Unwalkable") continue;
                    if (to.type === "Cover") {
                        if (direction === "UP" && to.down) continue;
                        if (direction === "DOWN" && to.up) continue;
                        if (direction === "LEFT" && to.right) continue;
                        if (direction === "RIGHT" && to.left) continue;
                    }

                    if (from.type === "Cover") {
                        if (direction === "UP" && from.up) continue;
                        if (direction === "DOWN" && from.down) continue;
                        if (direction === "LEFT" && from.left) continue;
                        if (direction === "RIGHT" && from.right) continue;
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

    /**
     * Almost the same as walkableTiles, but returns the tiles within a radius, and ignores obstacles.
     * This is useful for finding tiles within a certain range, like for a grenade throw.
     */
    radiusTiles(start: [number, number], radius: number) {
        let [x0, y0] = start;
        let map = Array.from({ length: this.grid.length }, () =>
            Array(this.grid[0].length).fill(0),
        );
        let queue = [[x0, y0]];
        let tiles: Set<[number, number, number]> = new Set([[x0, y0, 1]]);
        let num = 1;

        map[x0][y0] = num;

        while (queue.length > 0) {
            num += 1;
            let tempQueue = [...queue];
            queue = [];

            if (num > radius + 1) {
                break;
            }

            for (let [nx, ny] of tempQueue) {
                for (let [x, y] of this.vonNeumann(nx, ny)) {
                    if (map[x][y] !== 0) continue;

                    map[x][y] = num;
                    queue.push([x, y, num]);
                    tiles.add([x, y, num]);
                }
            }
        }

        return tiles;
    }

    private coordsToDirection(from: [number, number], to: [number, number]) {
        let [x0, y0] = from;
        let [x1, y1] = to;

        if (x0 < x1) return "DOWN";
        if (x0 > x1) return "UP";
        if (y0 > y1) return "LEFT";
        if (y0 < y1) return "RIGHT";
    }

    // === Edit Mode ===

    /** Edit mode marker, add a mesh to the cell to indicate a spawn point. */
    markSpawn(x: number, y: number) {
        if (this.grid[x][y].type === "Unwalkable") {
            return false;
        }

        const mesh = new THREE.Mesh(
            new THREE.BoxGeometry(1, 2, 1),
            new THREE.MeshStandardMaterial({ color: 0xffffff, opacity: 0.5, transparent: true }),
        );
        this.spawnPositions.push(new THREE.Vector2(x, y));
        this.meshes[`${x}-${y}`] = mesh;
        mesh.position.set(x, 0, -y);
        this.add(mesh);
    }

    removeSpawn(x: number, y: number) {
        this.spawnPositions = this.spawnPositions.filter((pos) => pos.x !== x || pos.y !== y);
        this.remove(this.meshes[`${x}-${y}`]);
        delete this.meshes[`${x}-${y}`];
    }

    resetFromBcs(bcs: Uint8Array) {
        const { map, positions } = LocalPreset.parse(bcs);
        map.grid.forEach((row, x) => {
            row.forEach((cell, y) => {
                switch (cell.tile_type.$kind) {
                    case "Empty":
                        return this.setCell(x, y, { type: "Empty", unit: null });
                    case "Unwalkable":
                        return this.setCell(x, y, { type: "Unwalkable", unit: null });
                    case "Cover": {
                        const { left, right, up, down } = cell.tile_type.Cover;
                        this.setCell(x, y, { type: "Cover", left, right, up, down, unit: null });
                    }
                }
            });
        });
        positions.forEach(([x, y]) => {
            this.spawnPositions.push(new THREE.Vector2(x, y));
            this.markSpawn(x, y);
        });
    }

    toBytes() {
        const grid = this.grid;
        return LocalPreset.serialize({
            map: {
                id: normalizeSuiObjectId("0x0"),
                grid: grid.map((row) =>
                    row.map((cell) => {
                        switch (cell.type) {
                            case "Empty":
                                return { tile_type: { ["Empty"]: true }, unit: null };
                            case "Cover":
                                return {
                                    tile_type: { ["Cover"]: { ...cell } },
                                    unit: null,
                                };
                            case "Unwalkable":
                                return { tile_type: { ["Unwalkable"]: true }, unit: null };
                        }
                    }),
                ),
                turn: 0,
            },
            positions: [...this.spawnPositions.map((pos) => [pos.x, pos.y])],
        });
    }

    // === Utilities ===

    /**
     * Traces a path from start to end using the wave algorithm.
     */
    tracePath(start: THREE.Vector2, end: THREE.Vector2, _limit: number = 30) {
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

                    if (to.unit !== null) continue;
                    if (to.type === "Unwalkable") continue;
                    if (to.type === "Cover") {
                        if (direction === "UP" && to.down) continue;
                        if (direction === "DOWN" && to.up) continue;
                        if (direction === "LEFT" && to.right) continue;
                        if (direction === "RIGHT" && to.left) continue;
                    }

                    if (from.type === "Cover") {
                        if (direction === "UP" && from.up) continue;
                        if (direction === "DOWN" && from.down) continue;
                        if (direction === "LEFT" && from.left) continue;
                        if (direction === "RIGHT" && from.right) continue;
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
                    if (direction === "UP" && to.down) continue;
                    if (direction === "DOWN" && to.up) continue;
                    if (direction === "LEFT" && to.right) continue;
                    if (direction === "RIGHT" && to.left) continue;
                }

                if (from.type === "Cover") {
                    if (direction === "UP" && from.up) continue;
                    if (direction === "DOWN" && from.down) continue;
                    if (direction === "LEFT" && from.left) continue;
                    if (direction === "RIGHT" && from.right) continue;
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

        return path.map(([x, y]) => new THREE.Vector2(x, y));
    }
}
