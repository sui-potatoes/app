// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useState } from "react";
import { Grid, Unit } from "./types";

export type MapProps = {
    grid: typeof Grid.$inferType;
    /** Callback when Unit is commanded to perform an action at X, Y */
    onPoint: (unit: typeof Unit.$inferType | null, x: number, y: number) => void;
    onSelect: (unit: typeof Unit.$inferType | null, x: number, y: number) => void;
};

// I want to add a class to the selected div and remove it from the previous one
export function Map({ grid, onPoint, onSelect }: MapProps) {
    const [selected, setSelected] = useState<HTMLDivElement>();
    const [selectedUnit, setSelectedUnit] = useState<typeof Unit.$inferType | null>(null);

    // now the same thing but with divs
    return (
        <div
            className="grid game-grid"
            style={{
                display: "grid",
                gridTemplateColumns: `repeat(${grid.grid[0].length}, ${60}px)`,
            }}
        >
            {grid.grid.map((row, x) => {
                return row.map((tile, y) => {
                    if (tile.$kind === "Empty") {
                        return (
                            <div
                                key={`${x}-${y}`}
                                className="cell cell-empty"
                                ref={(el) => {
                                    if (el && el == selected) {
                                        el.classList.add("selected");
                                    } else if (el) {
                                        el.classList.remove("selected");
                                    }
                                }}
                                onContextMenu={(e) => {
                                    e.preventDefault();
                                    onPoint(selectedUnit || null, x, y);
                                }}
                                onClick={(e) => {
                                    setSelected(e.currentTarget);
                                    onSelect(null, x, y);
                                }}
                            ></div>
                        );
                    }

                    if (tile.$kind === "Unit") {
                        return (
                            <div
                                className={`unit-${tile.Unit.unit.name.toLowerCase()} cell cell-empty`}
                                ref={(el) => {
                                    if (el && el == selected) {
                                        el.classList.add("selected");
                                    } else if (el) {
                                        el.classList.remove("selected");
                                    }
                                }}
                                onContextMenu={(e) => {
                                    e.preventDefault();
                                    onPoint(selectedUnit, x, y);
                                }}
                                onClick={(e) => {
                                    e.preventDefault();
                                    setSelected(e.currentTarget);
                                    setSelectedUnit(tile.Unit.unit);
                                    onSelect(tile.Unit.unit, x, y);
                                }}
                                key={`${x}-${y}`}
                            >
                                {tile.Unit.unit.symbol}
                            </div>
                        );
                    }
                });
            })}
        </div>
    );
}
