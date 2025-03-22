// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { ControlsEvents } from "./Controls";
import { HistoryRecord } from "../types/bcs";
import { Unit } from "./Unit";
import { Mode, ModeEvent } from "./modes/Mode";
import { Prefixed, UnPrefixed } from "../types/utils";

/** Events emitted by transaction sender, post network requests */
export type SuiAction = {
    next_turn: { turn: number };
    reload: { unit: [number, number]; success: boolean };
    path: { path: [number, number][] };
    trace: { success: boolean };
    aim: { success: boolean };
    map_created: {};
    grenade: { success: boolean };
    tx_success: { history: HistoryRecord[] };
    attack: {
        unit: [number, number];
        target: [number, number];
        result: "CriticalHit" | "Damage" | "Miss";
        damage: number;
    };
};

/** Events emitted by the `Game` instance during the gameplay */
export type GameAction = {
    mode_action: { mode: Mode };
    mode_switch: { mode: Mode };
    unit_selected: { unit: Unit };
} & ModeEvent;

export type UIKey =
    | "shoot"
    | "reload"
    | "grenade"
    | "next_turn"
    | "next_target"
    | "prev_target"
    | "confirm"
    | "cancel"
    | "edit";

type HistoryRecord = typeof HistoryRecord.$inferType;
type HistoryKey = Exclude<keyof HistoryRecord, "$kind">;

/**
 * Observer events are constructed from the history records.
 * All of them are prefixed with `observer:` and the type of the record.
 */
export type ObserverEvent<T extends HistoryKey> = {
    [U in Prefixed<"observer", T>]: { data: HistoryRecord[UnPrefixed<U>] };
};

export type GameUIEvent<T extends UIKey> = {
    [U in Prefixed<"ui", T>]: { name: UnPrefixed<U> };
};

export type SuiEvent<T extends keyof SuiAction> = {
    [U in Prefixed<"sui", T>]: SuiAction[UnPrefixed<U>];
};

export type GameEvent<T extends keyof GameAction> = {
    [U in Prefixed<"game", T>]: GameAction[UnPrefixed<U>];
};

export type InputEvent<T extends keyof ControlsEvents> = {
    [U in Prefixed<"input", T>]: ControlsEvents[UnPrefixed<U>];
};

/** All events emitted by the EventBus */
// prettier-ignore
type EventMap =
    & GameUIEvent<UIKey>
    & SuiEvent<keyof SuiAction>
    & GameEvent<keyof GameAction>
    & InputEvent<keyof ControlsEvents>
    & ObserverEvent<HistoryKey>
    & { all: { type: keyof EventMap; data: EventMap[Exclude<keyof EventMap, "all">] } };

/**
 * Custom event dispatcher for the game. Handles the interaction between the
 * game, UI and transactional events.
 */
export class EventBus extends THREE.EventDispatcher<EventMap> {
    /** Subscribe to all events. */
    public all(callback: (event: EventMap["all"]) => void): void {
        this.addEventListener("all", ({ type, data }) => callback({ type, data }));
    }

    public dispatchEvent<T extends keyof EventMap>(event: THREE.BaseEvent<T> & EventMap[T]): void {
        super.dispatchEvent(event);
        super.dispatchEvent({ type: "all", data: event }); // all is always dispatched first
    }
}
