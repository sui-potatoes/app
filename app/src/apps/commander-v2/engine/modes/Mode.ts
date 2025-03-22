// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Game } from "./../Game";
import { Controls } from "./../Controls";
import { Prefixed, UnPrefixed } from "../../types/utils";
import { ShootModeEvent } from "./ShootMode";
import { EditModeEvent } from "./EditMode";
import { MoveModeEvent } from "./MoveMode";
import { ReloadModeEvent } from "./ReloadMode";
import { GrenadeModeEvent } from "./GrenadeMode";

type PrefixedModeEvent<P extends string, K extends {}, T extends Extract<keyof K, string>> = {
    [U in Prefixed<P, T>]: K[Extract<UnPrefixed<U>, T>];
};

type ModeName = "grenade" | "reload" | "shoot" | "editor" | "move" | "none";

type BaseModeEvents = {
    switch: { mode: Mode };
    perform: { mode: Mode };
};

// prettier-ignore
export type ModeEvent =
    & PrefixedModeEvent<"mode", BaseModeEvents, keyof BaseModeEvents>
    & PrefixedModeEvent<"grenade", GrenadeModeEvent, keyof GrenadeModeEvent>
    & PrefixedModeEvent<"reload", ReloadModeEvent, keyof ReloadModeEvent>
    & PrefixedModeEvent<"shoot", ShootModeEvent, keyof ShootModeEvent>
    & PrefixedModeEvent<"editor", EditModeEvent, keyof EditModeEvent>
    & PrefixedModeEvent<"move", MoveModeEvent, keyof MoveModeEvent>;

/**
 * Each Mode defines a different way of interacting with the game. By default, the game mode is
 * `None`, however, when a `Unit` is selected, the game mode changes to `Move` by default. If
 * another action is selected, the game mode changes to that action. Additionally, there's an `Edit`
 * mode which allows modifying the map.
 *
 * Each game mode comes with 4 default functions: `connect`, `disconnect`, `input` and
 * `performAction`. The latter may not be necessary for all modes.
 *
 * Action is a mixin, and its scope and `this` argument are bound to the `Game` instance. The
 * `Storage` type parameter defines the structure of the data the mode needs to store.
 */
export abstract class Mode {
    /** Name of the Mode */
    public abstract readonly name: ModeName;
    /** Connection handler, called when the mode is connected */
    abstract connect(this: Game, mode: this): void;
    /** Disconnection handler, called when the mode is disconnected */
    abstract disconnect(this: Game, mode: this): void;
    /** Input handler, called when the mode is active */
    abstract input(this: Game, controls: Controls, mode: this): void;
    /** Action handler, called when the mode is active and an action is performed */
    async performAction(this: Game, _mode: this): Promise<void> {
        return;
    }
}
