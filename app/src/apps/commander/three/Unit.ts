// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Unit as UnitBCS } from "../lib/bcs";

/**
 * BCS definition of the `Unit` struct, which matches the struct
 * definition in the Move part of the application.
 */
export type UnitInner = typeof UnitBCS.$inferType;

/**
 * Represents a unit in the game.
 * Unit has properties and can perform actions.
 */
export class Unit extends THREE.Object3D {
    constructor(public data: UnitInner) {
        super();
        this.data = data;
    }

    /**
     *
     */
    nextTurn() {
        this.data.ap.value = this.data.ap.maxValue;
    }
}
