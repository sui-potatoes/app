// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { ControlsEvents } from "./Controls";

export interface BaseGameEvent<T extends string = string> {
    readonly action: T;
}

/**
 * Game events are divided into categories:
 * - `ui` events are related to the user interface
 * - `controls` events are related to the game controls
 * - `sui` events are related to the SUI transactions
 * - `all` events includes all events
 */
export type GameEvent = {
    all: { data: any };
    ui: { action: string };
    sui: { action: string } & any;
    game: { action: string } & any;
    three: { action: string };
    controls: { action: ControlsEvents };
};

/**
 * Custom event dispatcher for the game. Handles the interaction between the
 * game, UI and transactional events.
 *
 * Extends the `EventDispatcher` class from `three.js`, and adds a custom
 * subscription option to all events.
 */
export class EventBus extends THREE.EventDispatcher<GameEvent> {
    /**
     * Overrides the `dispatchEvent` method from the `EventDispatcher` class.
     * Adds the `all` event type to all events.
     */
    public dispatchEvent<T extends keyof GameEvent>(
        event: THREE.BaseEvent<T> & GameEvent[T] & BaseGameEvent,
    ): void {
        super.dispatchEvent({ type: "all", data: event }); // all is always dispatched first
        super.dispatchEvent({ ...event });
    }

    /**
     * Subscribe to all events.
     */
    public all<T extends keyof GameEvent>(
        callback: (event: THREE.BaseEvent<T> & GameEvent[T]) => void,
    ): void {
        this.addEventListener("all", (event) => {
            callback({ type: event.type, ...event.data });
        });
    }
}
