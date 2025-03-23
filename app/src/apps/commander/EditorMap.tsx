// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useState } from "react";
import { MapProps } from "./three/Map";

export function EditorMap({ grid, disabled, highlight, onTarget, onSelect }: MapProps) {
    const [selected, setSelected] = useState<HTMLDivElement>();

    // now the same thing but with divs
    return (
        <div className={`game-grid w-full ${disabled ? "disabled" : ""} sand`}>
            {grid.grid.map((row, x) => {
                return (
                    <div className="row" key={`row-${x}`}>
                        {row.map((tile, y) => {
                            if (tile.$kind === "Empty") {
                                const highlightClass = highlight.some((e) => e.x == x && e.y == y)
                                    ? "highlight"
                                    : "";
                                const className = [
                                    "flex",
                                    "cell",
                                    "cell-empty",
                                    highlightClass,
                                ].join(" ");

                                return (
                                    <div
                                        key={`cell-${x}-${y}`}
                                        className={className}
                                        ref={(el) => {
                                            if (el && el == selected) {
                                                el.classList.add("selected");
                                            } else if (el) {
                                                el.classList.remove("selected");
                                            }
                                        }}
                                        onContextMenu={(e) => {
                                            e.preventDefault();
                                            onTarget(x, y);
                                        }}
                                        onClick={(e) => {
                                            setSelected(e.currentTarget);
                                            onSelect(null, x, y);
                                        }}
                                    ></div>
                                );
                            }

                            if (tile.$kind === "Unit") {
                                const highlightClass = highlight.some((e) => e.x == x && e.y == y)
                                    ? "highlight"
                                    : "";
                                const unitClass = `unit-${tile.Unit.unit.name.toLowerCase()}`;
                                const ap = tile.Unit.unit.ap.value;
                                const className = [
                                    "cell",
                                    "cell-unit",
                                    unitClass,
                                    highlightClass,
                                ].join(" ");

                                const apBar = (
                                    <div className="ap-bar">
                                        {Array.from({ length: ap }, (_, i) => i).map((i) => (
                                            <div key={i} className="ap-pt"></div>
                                        ))}
                                    </div>
                                );

                                return (
                                    <div
                                        className={className}
                                        ref={(el) => {
                                            if (el && el == selected) {
                                                el.classList.add("selected");
                                            } else if (el) {
                                                el.classList.remove("selected");
                                            }
                                        }}
                                        onContextMenu={(e) => {
                                            e.preventDefault();
                                            onTarget(x, y);
                                        }}
                                        onClick={(e) => {
                                            e.preventDefault();
                                            setSelected(e.currentTarget);
                                            onSelect(tile.Unit.unit, x, y);
                                        }}
                                        key={`cell-${x}-${y}`}
                                    >
                                        {apBar}
                                        {tile.Unit.unit.symbol}
                                    </div>
                                );
                            }
                        })}
                    </div>
                );
            })}
        </div>
    );
}
