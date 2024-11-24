// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";
import { MoveMode } from "./MoveMode";
import { Unit } from "../Unit";
import { UI } from "../UI";

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class ShootMode implements Mode {
    /** List of targets for the action to choose between */
    public targets: Unit[] = [];
    /** Currently chosen target */
    private currentTarget: Unit | null = null; // Index of the current target
    /** Shoot Mode takes control of the Camera while active */
    constructor(protected camera: THREE.Camera, protected ui: UI) {}

    get name(): string {
        return "None";
    }

    connect(this: Game, mode: this) {
        if (this.selectedUnit === null) {
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

        // add UI buttons to select targets
        const prev = mode.ui.createButton('<');
        const next = mode.ui.createButton('>');
        mode.ui.leftPanel.append(prev, next);

        prev.addEventListener("click", () => {
            mode.nextTarget(false);
            mode.aimAtTarget.call(this, mode);
        });

        next.addEventListener("click", () => {
            mode.nextTarget(true)
            mode.aimAtTarget.call(this, mode);
        });

        // set the targets and the current target
        mode.targets = targets;
        mode.currentTarget = targets[0];
        mode.aimAtTarget.call(this, mode);
    }

    disconnect(this: Game, mode: this) {
        if (!this.selectedUnit) {
            throw new Error("Can't perform action without a selected unit or tile.");
        }

        this.selectedUnit.playAnimation("Idle");
        this.selectedUnit.mixer.timeScale = 1;

        // remove `<` and `>` buttons
        mode.ui.removeButton('<');
        mode.ui.removeButton('>');

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

        if (this.selectedUnit?.gridPosition.x === x && this.selectedUnit?.gridPosition.y === y) {
            return;
        }

        if (typeof cell.unit === "number" && cell.type !== "Obstacle") {
            this.selectedUnit = this.units[cell.unit];
            this.switchMode(new MoveMode(controls));
        }
    }

    async performAction() {}

    aimAtTarget(this: Game, mode: this) {
        if (!this.selectedUnit || !mode.currentTarget) {
            throw new Error("Can't aim at target without a selected unit or target.");
        }

        const selectedUnit = this.selectedUnit;

        // move camera to the selected unit aiming at the target
        selectedUnit.lookAt(mode.currentTarget.position);
        selectedUnit.playAnimation("Snipershot");
        selectedUnit.mixer.timeScale = 0.1;

        mode.camera.position.set(selectedUnit.position.x, 1.5, selectedUnit.position.z);
        mode.camera.lookAt(mode.currentTarget.position);
        mode.camera.translateZ(1);
        mode.camera.translateX(0.3);
        mode.camera.lookAt(mode.currentTarget.position);
    }

    nextTarget(forward: boolean = true) {
        if (this.currentTarget === null) {
            throw new Error("No targets available.");
        }

        const index = this.targets.indexOf(this.currentTarget) - (forward ? 1 : -1);

        console.log(this.targets.indexOf(this.currentTarget), -forward, index);

        if (index < 0) {
            this.currentTarget = this.targets[this.targets.length - 1];
        } else if (index >= this.targets.length) {
            this.currentTarget = this.targets[0];
        } else {
            this.currentTarget = this.targets[index];
        }
    }
}
