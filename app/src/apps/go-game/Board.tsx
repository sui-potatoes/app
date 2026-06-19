// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

type Matrix = number[][];

/** Star-point (hoshi) coordinates per board size — orientation aids. */
const STAR_POINTS: Record<number, [number, number][]> = {
    9: [
        [2, 2],
        [2, 6],
        [6, 2],
        [6, 6],
        [4, 4],
    ],
    13: [
        [3, 3],
        [3, 9],
        [9, 3],
        [9, 9],
        [6, 6],
    ],
    19: [
        [3, 3],
        [3, 9],
        [3, 15],
        [9, 3],
        [9, 9],
        [9, 15],
        [15, 3],
        [15, 9],
        [15, 15],
    ],
};

/**
 * Renders a Go board.
 */
export function Board({
    size,
    data,
    turn,
    disabled,
    onClick,
    lastMove,
    padding = 2,
    cellSize = 20,
}: {
    size: 9 | 13 | 19;
    data: Matrix;
    turn: 1 | 2;
    disabled: boolean;
    padding?: number;
    cellSize?: number;
    lastMove?: { x: number; y: number };
    onClick: (x: number, y: number) => void;
}) {
    const width = size * (cellSize + 1) + size * padding;
    const center = (n: number) => n * cellSize + n * padding + cellSize / 2;
    const stars = STAR_POINTS[size] ?? [];

    return (
        <svg
            viewBox={`0 0 ${width} ${width}`}
            style={{
                display: "block",
                margin: "0 auto",
                width: "100%",
                maxWidth: "min(80vw, 80vh)",
                height: "auto",
                aspectRatio: "1",
            }}
            className={
                (disabled ? "disabled " : "") +
                (turn == 1 ? "to-move-black" : "to-move-white")
            }
        >
            <defs>
                <pattern
                    id="grid"
                    width={cellSize + padding}
                    x={cellSize / 2}
                    y={cellSize / 2}
                    height={cellSize + padding}
                    patternUnits="userSpaceOnUse"
                >
                    <path className="grid-line" d="M 40 0 L 0 0 0 40" fill="none" strokeWidth="1" />
                </pattern>
            </defs>
            <rect
                width={width - cellSize * 1.5}
                height={width - cellSize * 1.5}
                x={cellSize / 2}
                y={cellSize / 2}
                fill="url(#grid)"
            />
            {stars.map(([i, j]) => (
                <circle
                    key={`star-${i}-${j}`}
                    className="star-point"
                    cx={center(i)}
                    cy={center(j)}
                    r={cellSize / 7}
                />
            ))}
            {data.map((row, i) => (
                <g key={`row-${i}`} id={`row-${i}`}>
                    {row.map((el, j) => (
                        <circle
                            id={`${i}-${j}`}
                            key={`${i}-${j}`}
                            cx={center(i)}
                            cy={center(j)}
                            r={cellSize / 2}
                            className={
                                (el === 1 ? "black" : el === 2 ? "white" : "empty") + " cell"
                            }
                            onClick={() => onClick(i, j)}
                        />
                    ))}
                </g>
            ))}
            {lastMove && data[lastMove.x]?.[lastMove.y] !== 0 && (
                <circle
                    className={
                        "last-move " +
                        (data[lastMove.x][lastMove.y] === 1 ? "on-black" : "on-white")
                    }
                    cx={center(lastMove.x)}
                    cy={center(lastMove.y)}
                    r={cellSize / 5}
                />
            )}
        </svg>
    );
}
