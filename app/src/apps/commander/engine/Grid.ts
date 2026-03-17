// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

import { Map as GameMap } from "../types/bcs";
import { bcs } from "@mysten/bcs";
import { Tile } from "../types/common";
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
export class Grid {
    public readonly grid: Tile[][];
    public spawnPositions: THREE.Vector2[] = [];

    constructor(public readonly size: number) {
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
    }

    isInBounds(x: number, y: number) {
        return x >= 0 && x < this.size && y >= 0 && y < this.size;
    }

    setCell(x: number, y: number, tile: Tile) {
        this._setCell(x, y, tile);
        this.grid[x][y] = tile;
    }

    clearCell(x: number, y: number) {
        let unit = this.grid[x][y].unit;
        this._clearCell(x, y, this.grid[x][y]);
        this.grid[x][y] = { type: "Empty", unit };
    }

    /** Returns the Von Neumann neighborhood of a cell in this order: right, down, left, up. */
    protected *vonNeumann(x: number, y: number) {
        if (x < this.grid.length - 1) yield [x + 1, y];
        if (y < this.grid[0].length - 1) yield [x, y + 1];
        if (x > 0) yield [x - 1, y];
        if (y > 0) yield [x, y - 1];
    }

    /** Returns the direction from one coordinate to another. */
    protected coordsToDirection(from: [number, number], to: [number, number]) {
        let [x0, y0] = from;
        let [x1, y1] = to;

        if (x0 < x1) return "DOWN";
        if (x0 > x1) return "UP";
        if (y0 > y1) return "LEFT";
        if (y0 < y1) return "RIGHT";
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
            if (!this._markSpawn(x, y)) throw new Error("Invalid spawn position");
        });
    }

    /** Override this method to clear the cell. */

    protected _clearCell(_x: number, _y: number, _tile: Tile) {}
    protected _setCell(_x: number, _y: number, _tile: Tile) {}

    /** Edit mode marker, add a mesh to the cell to indicate a spawn point. */
    protected _markSpawn(_x: number, _y: number): boolean {
        return true;
    }
}
