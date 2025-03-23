// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Game } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";
import { NoneMode } from "./NoneMode";
import { Unit } from "../Unit";

export type ReloadModeEvent = {
    perform: { unit: Unit };
};

/**
 * Perform a reload action.
 */
export class ReloadMode implements Mode {
    /** Name of the Mode */
    public readonly name = "reload";
    /** Mode action cost */
    public readonly cost = 1;

    connect(this: Game, _mode: this) {
        if (!this.selectedUnit) return this.switchMode(new NoneMode());
        if (this.selectedUnit.props.ap.value == 0) {
            return this.switchMode(new NoneMode());
        }

        this.eventBus?.dispatchEvent({
            type: "game:reload:perform",
            unit: this.selectedUnit,
        });
    }

    disconnect(this: Game, _mode: this) {}

    input(this: Game, _controls: Controls, _mode: this) {}

    async performAction(this: Game, mode: this) {
        if (this._isBlocked) return;
        if (!this.selectedUnit) return;

        this._isBlocked = true;
        const unit = this.selectedUnit;
        unit.spendAp(mode.cost);
        this._isBlocked = false;
    }
}
