// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect, useState } from "react";
import { EventBus, GameAction, NoneMode, ShootMode, SuiAction, UIKey } from "../../engine";
import { Recruit } from "../../types/bcs";
import { type Unit } from "../../engine/Unit";

type Recruit = typeof Recruit.$inferType;

/**
 * The length of the log displayed in the UI.
 */
const LOG_LENGTH = 5;
const LS_KEY = "commander-v2";

const BUTTON_CONTENTS: Record<UIKey, string | JSX.Element> = {
    shoot: <img src="/images/target.svg" />,
    reload: <img src="/images/reload.svg" />,
    grenade: <img src="/images/grenade.svg" />,
    cancel: <img src="/images/cancel.svg" />,
    confirm: <img src="/images/confirm.svg" />,
    next_target: ">",
    prev_target: "<",
    edit: "edit",
    next_turn: <img src="/images/clock.svg" />,
};

/**
 * UI Component which renders buttons and emits events in the `eventBus` under the `ui` type.
 * Listens to the in-game events to render additional buttons and log the actions.
 */
export function UI({
    eventBus,
    isExecuting,
    recruits,
}: {
    eventBus: EventBus;
    isExecuting?: boolean;
    turn: number;
    recruits: { [key: string]: Recruit } | undefined;
}) {
    const [panelDisabled, setPanelDisabled] = useState(true);
    const [shootMode, setShootMode] = useState(false);
    const [mode, setMode] = useState<string | null>(null);
    const [log, setLog] = useState<string[]>([]);
    const [unit, setUnit] = useState<Unit | null>(null);
    const [recruit, setRecruit] = useState<Recruit | null>(null);

    const onAction = (action: UIKey) =>
        eventBus.dispatchEvent({ type: `ui:${action}`, name: action });
    const button = (id: UIKey, disabled?: boolean, text?: string) => (
        <button
            onClick={() => onAction(id)}
            onMouseEnter={(e) => e.stopPropagation()}
            className={
                "action-button interactive mb-4" +
                (disabled || isExecuting ? " disabled" : "") +
                (mode && mode.toLocaleLowerCase() == id ? " selected" : "")
            }
        >
            {BUTTON_CONTENTS[id] || text || id}
        </button>
    );

    // Subscribe to the game events to update the UI.
    useEffect(() => {
        function onGameModeSwitch(event: GameAction["mode_switch"]) {
            setMode(event.mode.name);

            if (event.mode instanceof ShootMode) setShootMode(true);
            else setShootMode(false);

            if (event.mode instanceof NoneMode) setPanelDisabled(true);
            else setPanelDisabled(false);
        }

        function onGameUnitSelected(event: GameAction["unit_selected"]) {
            if (!recruits) return;
            let unit = event.unit;
            let recruitId = unit.props.recruit;
            if (recruitId in recruits) {
                setRecruit(recruits[recruitId]);
                setUnit(unit);
            }
        }

        eventBus.addEventListener("game:mode_switch", onGameModeSwitch);
        eventBus.addEventListener("game:unit_selected", onGameUnitSelected);
        return () => {
            eventBus.removeEventListener("game:mode_switch", onGameModeSwitch);
            eventBus.removeEventListener("game:unit_selected", onGameUnitSelected);
        };
    }, [recruits]);

    // Subscribe to the SUI events + all events to update the log.
    useEffect(() => {
        function onNextTurn(_event: SuiAction["next_turn"]) {
            // ... mark next turn ?
        }

        eventBus.addEventListener("sui:next_turn", onNextTurn);
        eventBus.all(({ data }) => {
            setLog((log) => {
                // @ts-ignore
                let { type, action, message } = data;
                let fullLog = [...log, `${type}: ${message || action || ""}`];
                if (fullLog.length > LOG_LENGTH) fullLog = fullLog.slice(fullLog.length - 5);
                return fullLog;
            });
        });

        return () => eventBus.removeEventListener("sui:next_turn", onNextTurn);
    }, []);

    const reloadText =
        (unit && "Reload " + unit.props.ammo.value + "/" + unit.props.ammo.max_value) || "Reload";

    return (
        <div id="ui" className="normal-case">
            {unit && recruit && (
                <div
                    id="panel-top"
                    className="fixed w-full text-xs top-0 left-0 p-0 text-center mt-10"
                >
                    <p className="text-sm text-white">
                        {recruit.metadata.name} ({recruit.rank.$kind}) HP: {unit.props.hp.value}/
                        {unit.props.hp.max_value}; AP {unit.props.ap.value}/2; Ammo:{" "}
                        {unit.props.ammo.value}/{unit.props.ammo.max_value}
                    </p>
                </div>
            )}
            <div
                id="panel-left"
                className="fixed h-full left-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {button("shoot")}
                {button("reload", unit?.props.ammo.value == unit?.props.ammo.max_value, reloadText)}
                {button("grenade")}
                <button
                    onClick={() => onAction("next_turn")}
                    className={"action-button interactive mt-40" + (isExecuting ? " disabled" : "")}
                >
                    {BUTTON_CONTENTS["next_turn"]}
                </button>
            </div>
            <div
                id="panel-bottom"
                className="fixed w-full text-xs bottom-0 left-0 p-0 text-center mb-10 normal-case"
            >
                {log.map((entry, i) => (
                    <p key={"log-" + i} className="text-sm normal-case text-white">
                        {entry}
                    </p>
                ))}
            </div>
            <div
                id="panel-right"
                className="fixed h-full right-0 top-0 p-10 flex justify-end flex-col text-center"
            >
                {shootMode && button("next_target", false, ">")}
                {shootMode && button("prev_target", false, "<")}
                {button("confirm", panelDisabled)}
                {button("cancel", panelDisabled)}
                {button("edit")}
                <button
                    onClick={() => {
                        sessionStorage.removeItem(LS_KEY);
                        window.location.reload();
                    }}
                    className={"action-button interactive mt-40" + (isExecuting ? " disabled" : "")}
                >
                    Exit
                </button>
            </div>
        </div>
    );
}
