// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { ControlsEvents } from "./Controls";
import { ModeEvent } from "./modes/Mode";
import { Unit } from "./Unit";
import { HistoryRecord } from "../types/bcs";
import { PrefixedEventMap } from "../types/utils";

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
        targetUnit: [number, number];
        result: "CriticalHit" | "Damage" | "Miss";
        damage: number;
    };
};

/** Events emitted by the `Game` instance during the gameplay */
export type GameAction = { unit_selected: { unit: Unit } } & ModeEvent;

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

export type GameUIEvent = PrefixedEventMap<"ui", { [U in UIKey]: { name: U } }, UIKey>;
export type SuiEvent = PrefixedEventMap<"sui", SuiAction, keyof SuiAction>;
export type GameEvent = PrefixedEventMap<"game", GameAction, keyof GameAction>;
export type InputEvent = PrefixedEventMap<"input", ControlsEvents, keyof ControlsEvents>;
export type ObserverEvent = PrefixedEventMap<
    "observer",
    { [U in HistoryKey]: { data: NonNullable<HistoryRecord[U]> } },
    HistoryKey
>;

type AllEvent<T extends Exclude<keyof EventMap, "all">> = THREE.BaseEvent<T> &
    (GameUIEvent & SuiEvent & GameEvent & InputEvent & ObserverEvent)[T];

export type EventKey = Exclude<keyof EventMap, "all">;

/** All events emitted by the EventBus */
// prettier-ignore
export type EventMap =
    & GameUIEvent
    & ObserverEvent
    & SuiEvent
    & GameEvent
    & InputEvent
    & { all: Partial<{ [K in EventKey]: AllEvent<K> }> & { eventType: EventKey } };

/**
 * Custom event dispatcher for the game. Handles the interaction between the
 * game, UI and transactional events.
 */
export class EventBus extends THREE.EventDispatcher<EventMap> {
    public dispatchEvent<T extends keyof EventMap>(event: THREE.BaseEvent<T> & EventMap[T]): void {
        super.dispatchEvent(event);
        super.dispatchEvent({
            type: "all",
            [event.type]: event,
            eventType: event.type as Exclude<keyof EventMap, "all">,
        });
    }
}
