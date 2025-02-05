// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Controls } from "./Controls";
import { Unit } from "./Unit";
import { Grid } from "./Grid";
import { Mode } from "./modes/Mode";
import { NoneMode } from "./modes/NoneMode";
import { GameMap } from "../hooks/useGame";
import { models } from "./models";
import { EventBus } from "./EventBus";
import { AttackEvent } from "../Playground";

export type Tile =
    | { type: "Empty"; unit: number | null }
    | { type: "Unwalkable"; unit: number | null }
    | {
          type: "Cover";
          up: number;
          down: number;
          left: number;
          right: number;
          unit: number | null;
      };

/**
 * The base class for the Game scene and related objects. Contains the game logic,
 * grid movement, character stats, and other game-related data. A super-class for
 * game logic.
 *
 * TODO:
 * - [x] implement Controls class
 * - [ ] implement Sound class
 * - [ ] implement Models and Textures classes
 * - [ ] behaviours for game interface

 */
export class Game extends THREE.Object3D {
    /** The Plane used for intersections */
    public readonly plane: THREE.Mesh;
    /** The Grid object */
    public readonly grid: Grid;
    /** Current turn */
    public turn: number;
    /**
     * Mode is a configurable behavior that can be switched at runtime. It allows
     * the game to have different states of interaction. For example, when a unit
     * is selected, the mode changes to `Move` by default. If another action is
     * selected, the mode changes to that action. Additionally, there's an `Edit`
     * mode which allows modifying the map.
     *
     * Modes are what define the game's behavior and interaction.
     * See the `modes` directory for more information.
     *
     * @see Mode
     */
    public mode: Mode = new NoneMode();
    /** Optionally registered EventBus */
    protected eventBus: EventBus | null = null;
    /** Selected Unit */
    protected selectedUnit: Unit | null = null;
    /** Active pointer based on input */
    protected pointer: THREE.Vector2 = new THREE.Vector2();
    /** List of `Unit`s placed on the map, indexed by their Unique ID */
    protected units: { [key: number]: Unit } = {};
    /** Flag to block execution any other action from being run in parallel */
    protected _isBlocked: boolean = false;

    /** Contruct the `Game` instance from BCS representation (fetched Sui Object) */
    public static fromBCS(data: GameMap): Game {
        const map = data.map.map;
        const size = map.grid[0].length;
        const game = new Game(size, true);

        game.turn = map.turn;

        for (let x = 0; x < size; x++) {
            for (let z = 0; z < size; z++) {
                let mapTile = map.grid[x][z];
                let unit = mapTile.unit;

                if (mapTile.tile_type.$kind == "Unwalkable") {
                    game.grid.setCell(x, z, { type: "Unwalkable", unit: null });
                }

                if (mapTile.tile_type.$kind == "Empty") {
                    game.grid.setCell(x, z, { type: "Empty", unit: null });
                }

                if (mapTile.tile_type.$kind === "Cover") {
                    const { left, right, down, up } = mapTile.tile_type.Cover;
                    game.grid.setCell(x, z, { type: "Cover", left, right, up, down, unit: null });
                }

                if (unit) {
                    // correct ap points for the unit based on game.turn
                    if (unit.last_turn < game.turn) {
                        unit.last_turn = game.turn;
                        unit.ap.value = unit.ap.max_value;
                    }

                    let unitObj = new Unit(unit, models.soldier, x, z);
                    game.addUnit(unitObj);
                }
            }
        }

        return game;
    }

    constructor(
        public size: number,
        useGrid: boolean = false,
    ) {
        super();

        if (useGrid) {
            const offset = this.offset;
            const helper = new THREE.GridHelper(size, size);
            helper.position.set(offset, +0.02, -offset);
            this.add(helper);
        }

        // create the intersectable plane
        this.turn = 0;
        this.plane = this.initPlane(size);
        this.add(this.plane);
        this.grid = new Grid(size);
        this.add(this.grid);
        this.switchMode(new NoneMode());
    }

    // === Turn ===

    nextTurn() {
        this.turn += 1;
    }

    /** Apply event received from Sui */
    applyAttackEvent(event: AttackEvent) {
        const {
            attacker: _,
            target: [x1, y1],
            damage,
            is_kia,
        } = event;
        const unitId = this.grid.grid[x1][y1].unit;

        if (unitId === null) return; // ignore, fetched event too late

        this.units[unitId]!.props.hp.value -= damage;

        if (is_kia) {
            this.grid.grid[x1][y1].unit = null;
            this.remove(this.units[unitId]!);
            delete this.units[unitId];
        }
    }

    applyReloadEvent(unit: [number, number]) {
        const [x, z] = unit;
        const unitId = this.grid.grid[x][z].unit;

        if (unitId === null) return; // ignore, fetched event too late

        console.log("reloading unit", unitId);

        this.units[unitId]!.props.ammo.value = this.units[unitId]!.props.ammo.max_value;
    }

    // === Component integration ===

    /** Register an EventBus to the Game */
    registerEventBus(eventBus: EventBus) {
        this.eventBus = eventBus;
    }

    /** Try dispatching an event if the EventBus is present */
    tryDispatch(event: { action: string } & any) {
        this.eventBus?.dispatchEvent({ type: "game", ...event });
    }

    // === Animation Loop & Controls

    selectUnit(x: number, z: number) {
        if (!this.grid.grid[x][z].unit) {
            this.selectedUnit?.markSelected(this, false);
            this.selectedUnit = null;
            return;
        }

        this.selectedUnit?.markSelected(this, false);
        this.selectedUnit = this.units[this.grid.grid[x][z].unit];
        this.selectedUnit.markSelected(this, true);
        this.eventBus?.dispatchEvent({
            type: "game",
            action: "unit_selected",
            unit: this.selectedUnit,
        });
    }

    /** Called every frame to update the game state. */
    input(controls: Controls) {
        this.mode.input.call(this, controls, this.mode);
    }

    /**
     * Update the state of the game based on the cursor intersection.
     * This is maintained by the `Controls` class.
     */
    update(cursor: THREE.Intersection | null, delta: number) {
        if (cursor !== null) {
            const [rawX, _, rawZ] = cursor.point;
            const [x, z] = [Math.floor(rawX + 0.5), Math.floor(rawZ + 0.5)];
            this.updatePointer(x, z);
        }

        // update all units
        for (let id in this.units) {
            this.units[id].update(delta);
        }
    }

    /** Update the pointer position. */
    updatePointer(x: number, z: number) {
        z = -z; // flip the z-axis
        if (this.pointer.x == x && this.pointer.y == z) return;

        this.pointer.set(x, z);

        if (this.grid.grid[x][z].type === "Unwalkable") return;
        if (this.selectedUnit) return;

        // TODO: highlight the unit tile when pointer over to give user a hint
        //  that a unit is clickable
        if (this.grid.grid[x][z].unit) return;
    }

    // === Mode Controls ===

    /**
     * Switch between different modes. This method uses JavaScript's dynamic
     * method invocation to call the `connect` and `disconnect` methods of the
     * current and new mode.
     *
     * @param mode The new mode to switch to.
     */
    switchMode(mode: Mode) {
        this.mode.disconnect.call(this, this.mode);
        this.mode = mode;
        this.mode.connect.call(this, this.mode);
        this.tryDispatch({
            action: "mode_switch",
            game: this,
            mode: this.mode,
            message: `mode switched to ${this.mode.name}`,
        });
    }

    /**
     * Perform an action of the current mode.
     * Each mode must implement a `performAction` method.
     */
    async performAction() {
        if (this._isBlocked) return;
        this.tryDispatch({ action: "action", game: this, mode: this.mode });
        await this.mode.performAction.call(this, this.mode);
        this.switchMode(new NoneMode());
    }

    // === Scene Setup ===

    /** The plane handling the intersections -> marking coordinates of the cursor */
    initPlane(size: number) {
        const offset = this.offset;
        const geometry = new THREE.PlaneGeometry(size, size);
        const material = new THREE.MeshBasicMaterial({ color: 0 });
        const plane = new THREE.Mesh(geometry, material);

        plane.rotateX(-Math.PI / 2);
        plane.position.set(offset, -0.0, -offset);

        return plane;
    }

    /** The offset of the grid. This is used to center the grid in the scene. */
    get offset() {
        return this.size / 2 - 0.5;
    }

    /** Add a unit to the game, use its grid position to place it on the map. */
    addUnit(unit: Unit) {
        const { x, y: z } = unit.gridPosition.clone();

        if (!this.grid.isInBounds(x, z)) {
            throw new Error("Invalid Unit positioning");
        }

        if (this.grid.grid[x][z].type === "Unwalkable") {
            return;
        }

        unit.position.set(x, 0, -z);
        this.grid.grid[x][z].unit = unit.id;
        this.units[unit.id] = unit;
        this.add(unit);
    }
}
