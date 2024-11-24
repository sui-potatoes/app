// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Game } from "./../Game";
import { Controls } from "./../Controls";

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
    public abstract get name(): string;
    abstract connect(this: Game, mode: this): void;
    abstract disconnect(this: Game, mode: this): void;
    abstract input(this: Game, controls: Controls, mode: this): void;
    async performAction(this: Game, _mode: this): Promise<void> {
        return;
    }
}
