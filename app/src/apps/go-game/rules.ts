// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

/**
 * Client-side Go capture rule, used for optimistic board updates. The chain
 * remains authoritative — polling reconciles any divergence (ko, suicide).
 */

type Board = number[][];

/** Place a stone and remove any adjacent opponent groups left without liberties. */
export function applyMove(board: Board, x: number, y: number, color: 1 | 2): Board {
    const size = board.length;
    const next = board.map((row) => [...row]);
    next[x][y] = color;
    const opponent = color === 1 ? 2 : 1;

    const neighbors = (i: number, j: number): [number, number][] =>
        (
            [
                [i - 1, j],
                [i + 1, j],
                [i, j - 1],
                [i, j + 1],
            ] as [number, number][]
        ).filter(([a, b]) => a >= 0 && a < size && b >= 0 && b < size);

    /** Flood-fill the group at (i, j), counting its liberties. */
    const group = (i: number, j: number) => {
        const groupColor = next[i][j];
        const stones = new Set<string>([`${i},${j}`]);
        const stack: [number, number][] = [[i, j]];
        let liberties = 0;

        while (stack.length) {
            const [a, b] = stack.pop()!;
            for (const [c, d] of neighbors(a, b)) {
                if (next[c][d] === 0) liberties++;
                else if (next[c][d] === groupColor && !stones.has(`${c},${d}`)) {
                    stones.add(`${c},${d}`);
                    stack.push([c, d]);
                }
            }
        }

        return { stones, liberties };
    };

    for (const [i, j] of neighbors(x, y)) {
        if (next[i][j] !== opponent) continue;

        const { stones, liberties } = group(i, j);
        if (liberties === 0) {
            for (const stone of stones) {
                const [a, b] = stone.split(",").map(Number);
                next[a][b] = 0;
            }
        }
    }

    return next;
}
