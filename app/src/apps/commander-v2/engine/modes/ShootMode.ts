// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";
import { MoveMode } from "./MoveMode";
import { Unit } from "../Unit";

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class ShootMode implements Mode {
    /** List of targets for the action to choose between */
    public targets: THREE.Vector2[] = [];
    /** Currently chosen target */
    private currentTarget: Unit | null = null; // Index of the current target
    /** Shoot Mode takes control of the Camera while active */
    constructor(protected camera: THREE.Camera) {}

    get name(): string {
        return "None";
    }

    connect(this: Game, mode: this) {
        if (this.selectedUnit === null || this.selectedTile === null) {
            throw new Error("Can't perform action without a selected unit or tile.");
        }

        const selectedUnit = this.selectedUnit;

        console.log(`Selected Unit: ${this.selectedUnit.id}`);
        const targets = Object.values(this.units).filter((unit) => {
            if (unit.id === selectedUnit.id) {
                return false;
            }
            console.log(unit.gridPosition.distanceTo(selectedUnit.gridPosition));
            return true;
        });

        if (targets.length === 0) {
            console.log("No targets available.");
            return;
        }

        mode.targets = targets.map((unit) => unit.gridPosition);
        mode.currentTarget = targets[0];

        console.log(`Targets: ${targets.map((unit) => unit.id).join(", ")}`);
        console.log(`Current Target: ${mode.currentTarget.id}`);

        // move camera to the selected unit aiming at the target
        selectedUnit.lookAt(mode.currentTarget.position);
        selectedUnit.playAnimation("Snipershot");
        selectedUnit.mixer.timeScale = 0.1;
        mode.camera.position.set(selectedUnit.position.x, 1.5, selectedUnit.position.z);
        mode.camera.translateY(1);
        mode.camera.lookAt(mode.currentTarget.position);
    }

    disconnect(this: Game, mode: this) {
        if (!this.selectedUnit || !this.selectedTile) {
            throw new Error("Can't perform action without a selected unit or tile.");
        }

        this.selectedUnit.playAnimation("Idle");
        this.selectedUnit.mixer.timeScale = 1;

        mode.targets = [];
        mode.currentTarget = null;

        {
            const offset = 30 / 2 - 0.5;
            mode.camera.position.set(offset, 20, offset);
            mode.camera.lookAt(offset, 0, offset);
        }
    }

    input(this: Game, controls: Controls, _: this) {
        if (!controls.mouse[THREE.MOUSE.LEFT]) {
            return;
        }

        const { x, y } = this.pointer;
        const cell = this.grid.grid[x][y];

        if (this.selectedTile !== null && this.selectedTile.x === x && this.selectedTile.y === y) {
            return;
        }

        if (typeof cell.unit === "number" && cell.type !== "Obstacle") {
            this.selectedUnit = this.units[cell.unit];
            this.selectedTile = new THREE.Vector2(x, y);
            this.switchMode(new MoveMode());
        }
    }

    async performAction() {}
}
