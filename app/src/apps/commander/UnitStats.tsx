// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useState } from "react";
import { Action, Game, Unit } from "./types";

type Props = {
    game: typeof Game.$inferType;
    unit: typeof Unit.$inferType | null;
    onSelect: (idx: number, action: typeof Action.$inferType) => void;
};

export function UnitStats({ onSelect, game, unit }: Props) {
    const [selectedAction, setSelectedAction] = useState<number>(
        unit?.actions.findIndex((a) => a.inner.$kind === "Move") || 0,
    );

    useEffect(() => {
        if (!unit) return;
        onSelect(selectedAction, unit?.actions[selectedAction]);
    }, [unit]);

    if (!unit) return <p>Click on a unit to see the stats</p>;

    const unitAp = unit.turn === game.turn ? unit.ap.value : unit.ap.maxValue;

    return (
        <>
            <h2 className="my-2 text-xl">{unit.name}</h2>
            <p>
                Health: {unit.health.value}/{unit.health.maxValue}
            </p>
            <p>
                AP: {unitAp}/{unit.ap.maxValue}
            </p>
            <h2 className="my-2 text-xl">Actions</h2>
            <ul className="unit-actions">
                {unit.actions.map((action, i) => (
                    <li key={i} className={i == selectedAction ? "selected-action" : ""}>
                        <a
                            onClick={() => {
                                setSelectedAction(i);
                                onSelect(i, action);
                            }}
                        >
                            {action.name}
                        </a>{" "}
                        - {action.cost} AP
                    </li>
                ))}
            </ul>
        </>
    );
}
