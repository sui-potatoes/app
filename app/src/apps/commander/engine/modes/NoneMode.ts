// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "../Game";
import { Controls } from "../Controls";
import { Mode } from "./Mode";
import { MoveMode } from "./MoveMode";

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class NoneMode implements Mode {
    public readonly name = "none";

    connect() {}
    disconnect() {}
    input(this: Game, controls: Controls, _: this) {
        if (!controls.mouse[THREE.MOUSE.LEFT]) {
            return;
        }

        const { x, y } = this.pointer;
        const cell = this.grid.grid[x][y];

        if (typeof cell.unit === "number" && cell.type !== "Obstacle") {
            if (!this.selectedUnit?.gridPosition.equals(new THREE.Vector2(x, y))) {
                this.selectUnit(x, y);
                this.switchMode(new MoveMode(controls));
            }
        }
    }

    async performAction() {}
}
