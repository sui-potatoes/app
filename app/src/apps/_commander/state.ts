// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Grid, Action, Unit } from "./types";

export class GridState {
    // public actions: Action[];

    constructor(public grid: typeof Grid.$inferType) {
        // this.actions = [];
    }
}

/**
 * 
 *
 * @param unit
 * @param action
 * @returns
 */
export function actionRange(unit: typeof Unit.$inferType, action: typeof Action.$inferType) {
    if (!action) return 0;

    if (action.inner.$kind === "Move") {
        return Math.floor(unit.ap.value / action.cost);
    }

    if (action.inner.$kind === "Attack") {
        if (action.cost > unit.ap.value) return 0;
        return action.inner.Attack.maxRange;
    }

    if (action.inner.$kind === "Skip") {
        return 0;
    }

    throw new Error("Unknown action kind");
}

/**
 * Find all von-Neumann neighbors of a given cell within a certain range.
 * If bypassObstacles is true, the function will ignore obstacles.
 *
 * @param x The x-coordinate of the cell.
 * @param y The y-coordinate of the cell.
 * @param range The range of the search.
 * @param bypassObstacles Whether to ignore obstacles.
 * @returns An array of cells (x, y) that are within the range.
 */
export function markInRange(
    grid: typeof Grid.$inferType,
    unitX: number,
    unitY: number,
    range: number,
    bypassObstacles: boolean,
) {
    const queue: [number, number, number][] = [[unitX, unitY, 0]];
    const visited: Set<string> = new Set();
    const result = [];

    while (queue.length > 0) {
        const [x, y, d] = queue.shift()!;

        if (x < 0 || x >= grid.grid.length) continue;
        if (y < 0 || y >= grid.grid[x].length) continue;
        if (d > range) continue;
        if (visited.has(`${x},${y}`)) continue;

        visited.add(`${x},${y}`);

        if (x == unitX && y == unitY) {
            queue.push([x - 1, y, d + 1], [x + 1, y, d + 1], [x, y - 1, d + 1], [x, y + 1, d + 1]);
            continue;
        }

        if (!bypassObstacles && grid.grid[x][y].$kind !== "Empty") continue;

        queue.push([x - 1, y, d + 1], [x + 1, y, d + 1], [x, y - 1, d + 1], [x, y + 1, d + 1]);
        result.push({ x, y, d });
    }

    return result;
}
