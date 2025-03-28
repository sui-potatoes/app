// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { EventMap } from "../engine";

export function printEvent(eventKey: keyof EventMap, map: Partial<EventMap>): string {
    if (map[eventKey] == undefined) {
        throw new Error(`Event ${eventKey} is not defined`);
    }

    switch (eventKey) {
        // UI events block
        case "ui:cancel":
            return `UI: Action cancelled`;
        case "ui:confirm":
            return `UI: Action confirmed`;
        case "ui:edit":
            return `UI: Edit mode activated`;
        case "ui:grenade":
            return `UI: Grenade mode activated`;
        case "ui:next_target":
            return `UI: Next target selected`;
        case "ui:prev_target":
            return `UI: Previous target selected`;
        case "ui:reload":
            return `UI: Reload mode activated`;
        case "ui:shoot":
            return `UI: Shoot mode activated`;
        case "ui:next_turn":
            return `UI: Next turn requested`;

        // Game events block
        case "game:unit_selected":
            return `Unit selected at '(${[...map[eventKey].unit.gridPosition]})`;

        // Mode block
        case "game:mode:perform":
            return `Mode action '${map[eventKey].mode.name}' performed`;
        case "game:mode:switch":
            return `Mode switched to '${map[eventKey].mode.name}'`;

        // Move mode
        case "game:move:trace":
            return `Path traced, length: ${map[eventKey].path.length - 1}`;
        case "game:move:perform":
            return `Performing 'move' action`;

        // Edit mode
        case "game:editor:change":
            return `Tile '(${map[eventKey].location})' changed with '${map[eventKey].tool}'`;
        case "game:editor:direction":
            return `Direction changed '${map[eventKey].direction}'`;
        case "game:editor:message":
            return `Editor message: ${map[eventKey].message}`;
        case "game:editor:tool":
            return `Tool changed to '${map[eventKey].tool}', direction: '${map[eventKey].direction}'`;

        // Grenade mode
        case "game:grenade:target":
            return `Grenade target set to '(${[map[eventKey].x, map[eventKey].y]})'`;

        // Reload mode
        case "game:reload:perform":
            return `Performing 'reload' action`;

        // Shoot mode
        case "game:shoot:aim":
            return `Aiming at '(${[...map[eventKey].targetUnit.gridPosition]})'`;
        case "game:shoot:no_ammo":
            return `No ammo left to shoot`;
        case "game:shoot:shoot":
            return `Performing 'shoot' action`;
        case "game:shoot:no_targets":
            return `No targets in range`;

        // Sui events
        case "sui:next_turn":
            return `Sui: next turn started - ${map[eventKey].turn}`;
        case "sui:aim":
            return `Sui: shot can${!map[eventKey].success ? "'t" : ""} be performed`;
        case "sui:attack":
            return `Sui: attack performed, result: ${map[eventKey].result}, damage: ${map[eventKey].damage}`;
        case "sui:grenade":
            return `Sui: grenade can${!map[eventKey].success ? "'t" : ""} be thrown`;
        case "sui:map_created":
            return `Sui: map created`;
        case "sui:path":
            return `Sui: path traced, length: ${map[eventKey].path.length - 1}`;
        case "sui:reload":
            return `Sui: reload ${map[eventKey].success ? "successful" : "failed"}`;
        case "sui:trace":
            return `Sui: path traced; ${map[eventKey].success}`;
        case "sui:dry_run_failed":
            return `Sui: ${map[eventKey].message}`;
        case "sui:tx_success":
            return `Sui: transaction successful`;

        case "all":
            return "";

        default:
            return `${eventKey}: unparsed event`;
    }
}
