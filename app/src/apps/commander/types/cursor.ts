// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

const UP = 1 << 0;
const RIGHT = 1 << 1;
const DOWN = 1 << 2;
const LEFT = 1 << 3;

interface Cursor {
    x: number;
    y: number;
}

export function directionToString(direction: number): string {
    if (direction == UP) return "UP";
    if (direction == RIGHT) return "RIGHT";
    if (direction == DOWN) return "DOWN";
    if (direction == LEFT) return "LEFT";
    throw new Error(`Invalid direction: ${direction}`);
}

export function pathToCoordinates(path: number[]): [number, number][] {
    const [x, y] = [path.shift()!, path.shift()!];
    const coordinates = [[x, y]];
    const cursor = { x, y } as Cursor;

    if (x == undefined || y == undefined) {
        return []; // TODO: study this case
    }

    while (path.length) {
        let direction = path.shift()!;
        if (direction == UP) cursor.x--;
        if (direction == RIGHT) cursor.y++;
        if (direction == DOWN) cursor.x++;
        if (direction == LEFT) cursor.y--;
        coordinates.push([cursor.x, cursor.y]);
    }

    return coordinates as [number, number][];
}

export function coordinatesToPath(coordinates: [number, number][]) {
    const path = [...coordinates[0]];
    let cursor = { x: coordinates[0][0], y: coordinates[0][1] } as Cursor;

    for (let i = 1; i < coordinates.length; i++) {
        const [x, y] = coordinates[i];
        if (x == undefined || y == undefined) {
            throw new Error(`Invalid coordinates: ${coordinates}`);
        }
        if (x < cursor.x) path.push(UP);
        if (y > cursor.y) path.push(RIGHT);
        if (x > cursor.x) path.push(DOWN);
        if (y < cursor.y) path.push(LEFT);
        cursor = { x, y };
    }

    return path;
}
