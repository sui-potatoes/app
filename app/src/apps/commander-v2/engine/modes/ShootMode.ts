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
import { BaseGameEvent, GameEvent } from "../EventBus";
import { NoneMode } from "./NoneMode";

export type ShootModeEvents = BaseGameEvent & {
    aim: { unit: Unit; target: Unit };
};

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class ShootMode extends Mode {
    public readonly name = "Shoot";
    public readonly cost = 2;
    /** List of targets for the action to choose between */
    public targets: Unit[] = [];
    /** Currently chosen target */
    private currentTarget: Unit | null = null; // Index of the current target
    /** Whether the camera is already in the aiming mode */
    private isAiming = false;
    /** Store listener cb to unsubscribe later */
    private _cb: ((_: GameEvent["ui"]) => void) | null = null;

    /** Shoot Mode takes control of the Camera while active */
    constructor(protected camera: Camera) {
        super();
    }

    connect(this: Game, mode: this) {
        if (this.selectedUnit === null) return this.switchMode(new NoneMode());
        if (this.selectedUnit.props.ap.value == 0) return this.switchMode(new NoneMode());

        const selectedUnit = this.selectedUnit;
        const targets = Object.values(this.units).filter(
            (unit) => unit.id !== selectedUnit.id && chance(selectedUnit, unit) > 0,
        );

        if (targets.length === 0) {
            return console.log("No targets available.");
        }

        // subscribe to the UI events
        mode._cb = mode._uiEventListener.bind(this);
        this.eventBus?.addEventListener("ui", mode._cb);

        // set the targets and the current target
        mode.targets = targets;
        mode.currentTarget = targets[0];
        mode.aimAtTarget.call(this, mode);
    }

    disconnect(this: Game, mode: this) {
        if (this.selectedUnit) {
            this.selectedUnit.playAnimation("Idle").play();
            this.selectedUnit.mixer.timeScale = 1;
        }

        // unsubscribe from the UI events
        (this.mode as ShootMode).currentTarget?.removeTarget();
        mode._cb && this.eventBus?.removeEventListener("ui", mode._cb);
        mode._cb = null;

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

    async performAction(this: Game, mode: this): Promise<void> {
        if (!this.selectedUnit || !mode.currentTarget) {
            throw new Error("Can't perform action without a selected unit or target.");
        }

        const selectedUnit = this.selectedUnit;
        const target = mode.currentTarget;

        selectedUnit.spendAp(mode.cost); //

        // perform the shooting action
        await selectedUnit.shoot(target);

        this.tryDispatch({ type: "game", action: "shoot", unit: selectedUnit, targetUnit: target });
    }

    async aimAtTarget(this: Game, mode: this) {
        if (!this.selectedUnit || !mode.currentTarget) {
            throw new Error("Can't aim at target without a selected unit or target.");
        }

        const selectedUnit = this.selectedUnit;

        // move camera to the selected unit aiming at the target
        selectedUnit.playAnimation("SniperShot", 0.1).play();

        this.tryDispatch({
            type: "game",
            action: "aim",
            unit: selectedUnit,
            targetUnit: mode.currentTarget,
        });

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

    nextTarget(this: Game, mode: this, forward: boolean = true) {
        if (!this.selectedUnit) return;
        if (mode.currentTarget === null) throw new Error("No targets available.");

        mode.currentTarget.removeTarget();
        const index = mode.targets.indexOf(mode.currentTarget) - (forward ? 1 : -1);

        if (index < 0) {
            mode.currentTarget = mode.targets[mode.targets.length - 1];
        } else if (index >= mode.targets.length) {
            mode.currentTarget = mode.targets[0];
        } else {
            mode.currentTarget = mode.targets[index];
        }

        const [low, high] = damage(this.selectedUnit);
        const chanceToHit = chance(this.selectedUnit, mode.currentTarget);
        mode.currentTarget.drawTarget(chanceToHit, low, high);
    }

    /** Listen to UI events, expecting `next_target` or `prev_target` action */
    protected _uiEventListener(this: Game, { action }: GameEvent["ui"]) {
        const mode = this.mode as this;
        if (action == "next_target") {
            mode.nextTarget.call(this, mode);
            mode.aimAtTarget.call(this, mode);
        }

        if (action == "prev_target") {
            mode.nextTarget.call(this, mode);
            mode.aimAtTarget.call(this, mode);
        }
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

    if (distance == eff_range) return aim;
    if (distance < eff_range) return aim + (eff_range - distance) * CLOSE_DISTANCE_MODIFIER;
    return aim - (distance - eff_range) * DISTANCE_MODIFIER;
}
