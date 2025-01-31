// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./../Game";
import { Camera } from "../Camera";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";
import { MoveMode } from "./MoveMode";
import { Unit } from "../Unit";
import JEASINGS from "jeasings";

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class ShootMode extends Mode {
    public readonly name = "Shoot";
    /** List of targets for the action to choose between */
    public targets: Unit[] = [];
    /** Currently chosen target */
    private currentTarget: Unit | null = null; // Index of the current target
    /** Whether the camera is already in the aiming mode */
    private isAiming = false;
    /** Name of the function to  */
    public static moveFun(pkg: string) {
        return `${pkg}::commander::perform_attack`;
    }

    /** Shoot Mode takes control of the Camera while active */
    constructor(protected camera: Camera) {
        super();
    }

    connect(this: Game, mode: this) {
        if (this.selectedUnit === null) {
            throw new Error("Can't perform action without a selected unit or tile.");
        }

        const selectedUnit = this.selectedUnit;
        const targets = Object.values(this.units).filter(
            (unit) => unit.id !== selectedUnit.id && chance(selectedUnit, unit) > 0,
        );

        if (targets.length === 0) {
            return console.log("No targets available.");
        }

        this.eventBus?.addEventListener("ui", mode._uiEventListener.bind(this));

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

        (this.mode as ShootMode).currentTarget?.removeTarget();
        this.eventBus?.removeEventListener("ui", mode._uiEventListener.bind(this));

        // remove `<` and `>` buttons
        // mode.ui.removeButton("<");
        // mode.ui.removeButton(">");

        mode.targets = [];
        mode.isAiming = false;
        mode.currentTarget = null;

        mode.camera.moveBack();
    }

    input(this: Game, controls: Controls, _: this) {
        if (!controls.mouse[THREE.MOUSE.LEFT]) {
            return;
        }

        const { x, y } = this.pointer;
        const cell = this.grid.grid[x][y];
        const pos = this.selectedUnit?.gridPosition;

        if (pos?.x === x && pos?.y === y) return; // clicked on the selected unit
        if (typeof cell.unit === "number" && cell.type !== "Unwalkable") {
            this.selectedUnit = this.units[cell.unit];
            this.switchMode(new MoveMode(controls));
        }
    }

    async performAction(this: Game, _mode: this): Promise<void> {
        console.log("shoot action performed");
    }

    async aimAtTarget(this: Game, mode: this) {
        if (!this.selectedUnit || !mode.currentTarget) {
            throw new Error("Can't aim at target without a selected unit or target.");
        }

        const selectedUnit = this.selectedUnit;

        // move camera to the selected unit aiming at the target
        selectedUnit.playAnimation("SniperShot");
        selectedUnit.mixer.timeScale = 0.1;

        if (!mode.isAiming) {
            selectedUnit.lookAt(mode.currentTarget.position);

            const [low, high] = damage(this.selectedUnit);
            const chanceToHit = chance(this.selectedUnit, mode.currentTarget);
            mode.currentTarget.lookAt(selectedUnit.position);
            mode.currentTarget.drawTarget(chanceToHit, low, high);

            // get the future position of the camera
            const fake = new THREE.Object3D();
            fake.position.set(
                ...selectedUnit.position
                    .clone()
                    .add(new THREE.Vector3(0, 1.5, 0))
                    .toArray(),
            );
            fake.lookAt(mode.currentTarget.position);
            fake.translateZ(-1);
            fake.translateX(-0.3);

            await mode.camera.moveToUnit(fake.position.clone(), mode.currentTarget.position);
            mode.isAiming = true;
        } else {
            const fake = new THREE.Object3D();
            fake.position.set(...mode.camera.position.toArray());
            fake.rotation.set(...mode.camera.rotation.toArray());
            fake.lookAt(mode.currentTarget.position);

            mode.camera.position.set(fake.position.x, fake.position.y, fake.position.z);
            const mt1 = new THREE.Matrix4();
            mt1.lookAt(fake.position, mode.currentTarget.position, new THREE.Vector3(0, 1, 0));
            const { x, y, z, w } = mode.camera.quaternion.clone().setFromRotationMatrix(mt1);

            await new Promise((resolve) => {
                // get angle change between current camera and the target
                // const angleChange = mode.camera.rotation.y - fake.rotation.y
                new JEASINGS.JEasing(mode.camera.quaternion)
                    .to({ x, y, z, w }, 500)
                    .easing(JEASINGS.Sinusoidal.In)
                    .onComplete(() => resolve(null))
                    .start();

                selectedUnit.lookAt(mode.currentTarget!.position);
            });
        }
    }

    nextTarget(forward: boolean = true) {
        if (this.currentTarget === null) {
            throw new Error("No targets available.");
        }

        this.currentTarget.removeTarget();
        const index = this.targets.indexOf(this.currentTarget) - (forward ? 1 : -1);

        if (index < 0) {
            this.currentTarget = this.targets[this.targets.length - 1];
        } else if (index >= this.targets.length) {
            this.currentTarget = this.targets[0];
        } else {
            this.currentTarget = this.targets[index];
        }
    }

    protected _uiEventListener() {
        console.log("ui event listener");
    }
}

/**
 *
 * @param unit
 * @returns
 */
function damage(unit: Unit | null): [number, number] {
    if (!unit) return [0, 0];
    const stats = unit.props.stats;

    let damage_low = stats.damage - stats.spread;
    let damage_high = stats.damage + stats.spread + (stats.plus_one ? 1 : 0);

    return [damage_low, damage_high];
}

const CLOSE_DISTANCE_MODIFIER = 5;
const DISTANCE_MODIFIER = 10;

function chance(unit: Unit | null, target: Unit | null): number {
    if (!unit || !target) return 0;

    let aim = unit.props.stats.aim;
    let distance =
        Math.abs(unit.gridPosition.x - target.gridPosition.x) +
        Math.abs(unit.gridPosition.y - target.gridPosition.y);
    let eff_range = unit.props.stats.range;

    if (distance == eff_range) {
        return aim;
    }

    if (distance < eff_range) {
        return aim + (eff_range - distance) * CLOSE_DISTANCE_MODIFIER;
    }

    return aim - (distance - eff_range) * DISTANCE_MODIFIER;
}
