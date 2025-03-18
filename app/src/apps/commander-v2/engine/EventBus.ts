// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { ControlsEvents } from "./Controls";
import { HistoryRecord } from "../types/bcs";
import { Unit } from "./Unit";
import { Mode } from "./modes/Mode";

export interface BaseGameEvent<T extends string = string> {
    readonly action: T;
}

const uiKeys = [
    "shoot",
    "reload",
    "grenade",
    "next_turn",
    "next_target",
    "prev_target",
    "confirm",
    "cancel",
    "edit",
] as const;

/** UI events are simple text commands indicating selected action. */
export type GameUIEvent = { action: (typeof uiKeys)[number] };

/** Events emitted by transaction sender, post network requests */
export type SuiEvent = { message?: string } & (
    | {
          action: "attack";
          damage: number;
          kind: typeof HistoryRecord.$inferType.$kind;
          unit: [number, number];
      }
    | { action: "next_turn"; turn: number }
    | { action: "reload"; unit: [number, number]; success: boolean }
    | { action: "path"; path: [number, number][] }
    | { action: "trace"; success: boolean }
    | { action: "aim"; success: boolean }
    | { action: "map_created" }
    | { action: "grenade"; success: boolean }
    | { action: "tx:success"; history: (typeof HistoryRecord.$inferType)[] }
);

/** Events emitted by the `Game` instance during the gameplay */
export type InGameEvent = { message?: string } & (
    | { action: "trace"; path: THREE.Vector2[] }
    | { action: "aim"; unit: Unit; targetUnit: Unit }
    | { action: "reload"; unit: Unit }
    | { action: "mode_switch"; mode: Mode }
    | { action: "unit_selected"; unit: Unit }
    | { action: "grenade_target"; unit: Unit, x: number, y: number }
);

/**
 * Game events are divided into categories:
 * - `ui` events are related to the user interface
 * - `controls` events are related to the game controls
 * - `sui` events are related to the SUI transactions
 * - `all` events includes all events
 */
export type GameEvent = {
    all: {
        type: keyof GameEvent;
        data: { type: keyof GameEvent } & GameEvent[Exclude<keyof GameEvent, "all">];
    };
    ui: GameUIEvent;
    sui: SuiEvent;
    game: InGameEvent;
    three: { action: string };
    editor: { tool: string; direction: string };
} & ControlsEvents;

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
        event: THREE.BaseEvent<T> & GameEvent[T],
    ): void {
        // @ts-ignore
        super.dispatchEvent({ type: "all", data: event }); // all is always dispatched first
        super.dispatchEvent({ ...event });
    }

    /** Subscribe to all events. */
    public all(callback: (event: GameEvent["all"]) => void): void {
        this.addEventListener("all", (event) =>
            callback({ type: event.data.type, data: event.data }),
        );
    }
}
