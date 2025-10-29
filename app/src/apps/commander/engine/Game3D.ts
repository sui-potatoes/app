// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import {
    Game,
    Interface3D,
    Grid3D,
    Unit,
    SuiAction,
    MoveMode,
    ShootMode,
    ReloadMode,
    Camera,
} from "./index";
import { GameMap } from "../hooks/useGame";
import { HistoryRecord } from "../types/bcs";
import { pathToCoordinates } from "../types/cursor";
import { models } from "./models";

export class Game3D extends Game implements Interface3D {
    public readonly objects = new THREE.Group();

    /** The Plane used for intersections */
    public readonly plane: THREE.Mesh;
    /** The Grid object */
    public readonly grid: Grid3D;

    constructor(
        public size: number,
        useGrid: boolean = false,
    ) {
        super(size);

        if (useGrid) {
            const offset = this.offset;
            const helper = new THREE.GridHelper(size, size);
            helper.position.set(offset, +0.02, -offset);
            this.add(helper);
        }

        // create plane for intersections
        this.plane = this.initPlane(size);
        this.add(this.plane);
        this.grid = new Grid3D(size);
    }

    // === Overrides ===

    /** Apply event received from Sui */
    async applyAttackEvent({ damage, targetUnit: [x1, y1] }: SuiAction["attack"]) {
        const unitId = this.grid.grid[x1][y1].unit;

        if (unitId === null) return; // ignore, fetched event too late

        this.units[unitId]!.props.hp.value -= damage;

        if (this.units[unitId]!.props.hp.value <= 0) {
            this.grid.grid[x1][y1].unit = null;
            await this.units[unitId]!.death();
            this.remove(this.units[unitId]!);
            delete this.units[unitId];
        }
    }

    async applyHistory(history: (typeof HistoryRecord.$inferType)[]) {
        let i = this.historyIdx;
        while (i < history.length) {
            const record = history[i];
            if (record.$kind === "Move") {
                const path = pathToCoordinates(record.Move);
                this.selectUnit(path[0][0], path[0][1]);
                this.switchMode(new MoveMode(this.controls!));

                if (!(this.mode instanceof MoveMode)) {
                    throw new Error(`Invalid mode ${this.mode.name}`);
                }

                (this.mode as MoveMode).forceTriggerAction(
                    path.map(([x, z]) => new THREE.Vector2(x, z)),
                );
                await this.performAction();
            } else if (record.$kind === "NextTurn") {
                this.nextTurn();
            } else if (record.$kind === "Attack") {
                const { origin, target } = record.Attack;
                const nextRecord = history[i + 1];
                i += 1; // skip next record, we're handling it here

                if (
                    !nextRecord ||
                    !["CriticalHit", "Miss", "Dodged", "Damage"].includes(nextRecord.$kind)
                ) {
                    throw new Error(
                        "Incorrect History log, expected Damage, CriticalHit, Miss or Dodged",
                    );
                }

                this.selectUnit(origin[0], origin[1]);
                this.switchMode(
                    new ShootMode(
                        {
                            moveBack: () => {},
                            moveToUnit: () => {},
                            resetForSize: () => {},
                        } as unknown as Camera,
                        this.controls!,
                    ),
                );

                if (!(this.mode instanceof ShootMode)) {
                    throw new Error(`Invalid mode ${this.mode.name}`);
                }

                const targetObject = this.units[this.grid.grid[target[0]][target[1]].unit!]!;
                (this.mode as ShootMode).forceTriggerAction(targetObject);
                await this.performAction();

                const unit = [origin[0], origin[1]] as [number, number];
                const targetUnit = [target[0], target[1]] as [number, number];

                if (nextRecord.$kind === "Miss") {
                    this.applyAttackEvent({ unit, targetUnit, result: "Miss", damage: 0 });
                } else if (nextRecord.$kind === "Dodged") {
                    this.applyAttackEvent({ unit, targetUnit, result: "Dodged", damage: 0 });
                } else if (nextRecord.$kind === "Damage") {
                    this.applyAttackEvent({
                        unit,
                        targetUnit,
                        result: "Damage",
                        damage: nextRecord.Damage,
                    });
                } else if (nextRecord.$kind === "CriticalHit") {
                    this.applyAttackEvent({
                        unit,
                        targetUnit,
                        result: "CriticalHit",
                        damage: nextRecord.CriticalHit,
                    });
                } else throw new Error(`Unsupported event ${nextRecord.$kind}`);
            } else if (record.$kind === "Reload") {
                const [x, y] = record.Reload;
                this.selectUnit(x, y);
                this.switchMode(new ReloadMode());
                await this.performAction();
            } else {
                console.log("Unsupported event", record);
            }

            i++;
        }
        this.historyIdx = i;
    }

    /** Construct the `Game` instance from BCS representation (fetched Sui Object) */
    public static fromBCS(data: GameMap): Game3D {
        const map = data.map.map;
        const size = map.grid[0].length;
        const game = new this(size, true);

        game.historyIdx = data.map.history.length;
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

                    let unitObj = new Unit(unit, models.the_dude!, x, z);
                    game.addUnit(unitObj);
                }
            }
        }

        return game;
    }

    addUnit(unit: Unit) {
        super.addUnit(unit);
        this.add(unit);
    }
}
