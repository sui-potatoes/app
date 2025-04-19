// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "../Game";
import { Camera } from "../Camera";
import { Controls } from "../Controls";
import { Mode } from "./Mode";
import { MoveMode } from "./MoveMode";
import { Unit } from "../Unit";
import { ReloadMode } from "./ReloadMode";
import { Grid } from "../Grid";

export type ShootModeEvent = {
    aim: { unit: Unit; targetUnit: Unit };
    shoot: { unit: Unit; targetUnit: Unit };
    no_ammo: {};
    no_targets: {};
};

/**
 * None is the default game mode. It allows selecting units and their actions.
 * When game resets the mode is set to None.
 */
export class ShootMode implements Mode {
    /** Name of the Mode */
    public readonly name = "shoot";
    /** Mode action cost */
    public readonly cost = 2;
    /** List of targets for the action to choose between */
    public targets: Unit[] = [];
    /** Currently chosen target */
    private currentTarget: Unit | null = null; // Index of the current target
    /** Whether the camera is already in the aiming mode */
    private isAiming = false;
    /** Store listener cb to unsubscribe later */
    private _prevCb: ((_: {}) => void) | null = null;
    private _nextCb: ((_: {}) => void) | null = null;

    /** Shoot Mode takes control of the Camera while active */
    constructor(
        protected camera: Camera,
        protected controls: Controls,
    ) {}

    connect(this: Game, mode: this) {
        if (this.selectedUnit === null) return this.switchMode(new MoveMode(mode.controls));
        if (this.selectedUnit.props.ap.value == 0)
            return this.switchMode(new MoveMode(mode.controls));

        const selectedUnit = this.selectedUnit;
        const targets = Object.values(this.units).filter((unit) => {
            // can't aim at yourself
            if (unit.id === selectedUnit.id) return false;

            let hitChance = chance(selectedUnit, unit);
            if (hitChance === 0) return false;

            // TODO: in the future, add team tags
            // if (unit.team === selectedUnit.team) return false;

            const d = distance(selectedUnit, unit);
            if (d > selectedUnit.props.stats.range + MAX_DISTANCE_OFFSET) return false;

            return true;
        });

        if (this.selectedUnit.props.ap.value == 0) {
            return this.switchMode(new MoveMode(mode.controls));
        }

        if (this.selectedUnit.props.ammo.value == 0) {
            this.eventBus?.dispatchEvent({ type: "game:shoot:no_ammo" });
            return this.switchMode(new ReloadMode());
        }

        if (targets.length === 0) {
            this.eventBus?.dispatchEvent({
                type: "game:shoot:no_targets",
            });

            return this.switchMode(new MoveMode(mode.controls));
        }

        // subscribe to the UI events
        mode._nextCb = mode._uiEventListener.bind(this, "next_target");
        mode._prevCb = mode._uiEventListener.bind(this, "prev_target");
        this.eventBus?.addEventListener("ui:prev_target", mode._prevCb);
        this.eventBus?.addEventListener("ui:next_target", mode._nextCb);

        // set the targets and the current target
        mode.targets = targets;
        mode.currentTarget = targets[0];
        mode.aimAtTarget.call(this, mode);
    }

    disconnect(this: Game, mode: this) {
        if (this.selectedUnit) {
            this.selectedUnit.defaultAnimation();
        }

        // unsubscribe from the UI events
        (this.mode as ShootMode).currentTarget?.removeTarget();
        mode._nextCb && this.eventBus?.removeEventListener("ui:next_target", mode._nextCb);
        mode._prevCb && this.eventBus?.removeEventListener("ui:prev_target", mode._prevCb);
        mode._nextCb = null;
        mode._prevCb = null;

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

        selectedUnit.spendAp(mode.cost);
        mode.camera.resetForSize(this.grid.size);

        // perform the shooting action
        await selectedUnit.shoot(target);
        selectedUnit.props.ammo.value -= 1;

        this.eventBus?.dispatchEvent({
            type: "game:shoot:shoot",
            unit: selectedUnit,
            targetUnit: target,
        });
    }

    async aimAtTarget(this: Game, mode: this) {
        if (!this.selectedUnit || !mode.currentTarget) {
            throw new Error("Can't aim at target without a selected unit or target.");
        }

        const selectedUnit = this.selectedUnit;

        // move camera to the selected unit aiming at the target
        selectedUnit.playAnimation("shooting", 0.1, 0.1);

        this.eventBus?.dispatchEvent({
            type: "game:shoot:aim",
            unit: selectedUnit,
            targetUnit: mode.currentTarget,
        });

        // using this object to get the position of the camera
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
        selectedUnit.lookAt(mode.currentTarget.position);

        const [low, high] = damage(this.selectedUnit);
        const defenseBonus = coverBonus(this.grid, this.selectedUnit, mode.currentTarget);
        let chanceToHit = chance(this.selectedUnit, mode.currentTarget);
        chanceToHit = Math.max(0, chanceToHit - defenseBonus);
        mode.currentTarget.lookAt(selectedUnit.position);
        mode.currentTarget.drawTarget(chanceToHit, defenseBonus, low, high);

        if (!mode.isAiming) {
            await mode.camera.moveToUnit(fake.position.clone(), mode.currentTarget.position);
            mode.isAiming = true;
        } else {
            mode.camera.position.copy(fake.position);
            mode.camera.lookAt(mode.currentTarget.position);
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
        const defenseBonus = coverBonus(this.grid, this.selectedUnit, mode.currentTarget);
        mode.currentTarget.drawTarget(
            Math.max(0, chanceToHit - defenseBonus),
            defenseBonus,
            low,
            high,
        );
        mode.currentTarget.lookAt(this.selectedUnit.position);
    }

    /** Listen to UI events, expecting `next_target` or `prev_target` action */
    protected _uiEventListener(this: Game, action: "next_target" | "prev_target") {
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

    // === Spectator Mode ===

    forceTriggerAction(target: Unit) {
        this.currentTarget = target;
    }
}

const CLOSE_DISTANCE_MODIFIER = 5;
const DISTANCE_MODIFIER = 10;
const MAX_DISTANCE_OFFSET = 3;

function distance(unit: Unit, target: Unit) {
    return (
        Math.abs(unit.gridPosition.x - target.gridPosition.x) +
        Math.abs(unit.gridPosition.y - target.gridPosition.y)
    );
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

const DEFENSE_MULTIPLIER = 25;

function coverBonus(grid: Grid, unit: Unit, target: Unit): number {
    if (!unit || !target) return 0;

    const dY = Math.abs(target.gridPosition.y - unit.gridPosition.y);
    const dX = Math.abs(target.gridPosition.x - unit.gridPosition.x);
    const targetTile = grid.grid[target.gridPosition.x][target.gridPosition.y];

    if (dY === 0 && dX === 0) return 0;

    // horizontal position, either left or right
    // direction = attack direction
    if (dY > dX) {
        const isLeft = target.gridPosition.y < unit.gridPosition.y;
        const isRight = target.gridPosition.y > unit.gridPosition.y;

        if (isLeft) {
            const middleTile = grid.grid[target.gridPosition.x][unit.gridPosition.y + 1];

            // try target tile first, or else -> middle tile
            if (targetTile.type === "Cover") {
                return targetTile.right * DEFENSE_MULTIPLIER;
            } else if (middleTile.type === "Cover") {
                return middleTile.left * DEFENSE_MULTIPLIER;
            } else return 0;
        }

        if (isRight) {
            const middleTile = grid.grid[target.gridPosition.x][unit.gridPosition.y - 1];

            // try target tile first, or else -> middle tile
            if (targetTile.type === "Cover") {
                return targetTile.left * DEFENSE_MULTIPLIER;
            } else if (middleTile.type === "Cover") {
                return middleTile.right * DEFENSE_MULTIPLIER;
            } else return 0;
        }
    }

    // horizontal
    if (dX > dY) {
        const isUp = target.gridPosition.x < unit.gridPosition.x;
        const isDown = target.gridPosition.x > unit.gridPosition.x;

        if (isUp) {
            const middleTile = grid.grid[target.gridPosition.x + 1][unit.gridPosition.y];

            // try target tile first, or else -> middle tile
            if (targetTile.type === "Cover") {
                return targetTile.down * DEFENSE_MULTIPLIER;
            } else if (middleTile.type === "Cover") {
                return middleTile.up * DEFENSE_MULTIPLIER;
            } else return 0;
        }
        if (isDown) {
            const middleTile = grid.grid[target.gridPosition.x - 1][unit.gridPosition.y];

            // try target tile first, or else -> middle tile
            if (targetTile.type === "Cover") {
                return targetTile.up * DEFENSE_MULTIPLIER;
            } else if (middleTile.type === "Cover") {
                return middleTile.down * DEFENSE_MULTIPLIER;
            } else return 0;
        }
    }

    // TODO: come back and add neighboring tiles' cover bonuses
    if (dX === dY) {
        const isUp = target.gridPosition.x < unit.gridPosition.x;
        const isDown = target.gridPosition.x > unit.gridPosition.x;
        const isLeft = target.gridPosition.y < unit.gridPosition.y;
        const isRight = target.gridPosition.y > unit.gridPosition.y;

        if (targetTile.type === "Cover") {
            if (isUp && isLeft)
                return Math.min(targetTile.down, targetTile.right) * DEFENSE_MULTIPLIER;
            if (isUp && isRight)
                return Math.min(targetTile.down, targetTile.left) * DEFENSE_MULTIPLIER;
            if (isDown && isLeft)
                return Math.min(targetTile.up, targetTile.right) * DEFENSE_MULTIPLIER;
            if (isDown && isRight)
                return Math.min(targetTile.up, targetTile.left) * DEFENSE_MULTIPLIER;
        }
    }

    return 0;
}

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
