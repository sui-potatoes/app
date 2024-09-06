// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Board } from "./App";

type Matrix = number[][];

/**
 * Renders a Go board.
 */
export function PlayableBoard({
    size,
    imageBlob,
    onClick,
}: {
    board: typeof Board.$inferType;
    imageBlob: string;
    size: 9 | 13 | 19;
    onClick: (x: number, y: number) => void;
}) {
    console.log(decodeURIComponent(imageBlob));



    return (∆
        <div
            id="#board"
            className="board"
            dangerouslySetInnerHTML={{ __html: decodeURIComponent(imageBlob) }}
            ref={(el) => {
                el?.addEventListener("click", (e) => {
                    const { x, y } = e.target as HTMLDivElement;
                    onClick(x, y);
                });
            }}
        ></div>
    );

    // return (
    //     // <svg
    //     //     style={{ zoom, display: "inline-flex" }}
    //     //     className={
    //     //         (disabled ? "disabled " : " ") + (turn == 1 ? "black" : "white")
    //     //     }
    //     //     width={width}
    //     //     height={width}
    //     // >
    //     //     <defs>
    //     //         <pattern
    //     //             id="grid"
    //     //             width={cellSize + padding}
    //     //             x={cellSize / 2}
    //     //             y={cellSize / 2}
    //     //             height={cellSize + padding}
    //     //             patternUnits="userSpaceOnUse"
    //     //         >
    //     //             <path
    //     //                 d="M 40 0 L 0 0 0 40"
    //     //                 fill="none"
    //     //                 stroke="gray"
    //     //                 strokeWidth="1"
    //     //             />
    //     //         </pattern>
    //     //     </defs>
    //     //     <rect
    //     //         width={width - cellSize * 1.5}
    //     //         height={width - cellSize * 1.5}
    //     //         x={cellSize / 2}
    //     //         y={cellSize / 2}
    //     //         fill="url(#grid)"
    //     //     />
    //     //     {data.map((row, i) => (
    //     //         <g key={`row-${i}`} id={`row-${i}`}>
    //     //             {row.map((el, j) => (
    //     //                 <circle
    //     //                     id={`${i}-${j}`}
    //     //                     key={`${i}-${j}`}
    //     //                     cx={i * cellSize + i * padding + cellSize / 2}
    //     //                     cy={j * cellSize + j * padding + cellSize / 2}
    //     //                     r={cellSize / 2}
    //     //                     className={
    //     //                         (el === 1
    //     //                             ? "black"
    //     //                             : el === 2
    //     //                               ? "white"
    //     //                               : "empty") +
    //     //                         " cell" +
    //     //                         (lastMove &&
    //     //                         lastMove.x === i &&
    //     //                         lastMove.y === j
    //     //                             ? " last-move"
    //     //                             : "")
    //     //                     }
    //     //                     onClick={() => onClick(i, j)}
    //     //                 />
    //     //             ))}
    //     //         </g>
    //     //     ))}
    //     // </svg>
    // );
}
