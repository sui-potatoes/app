// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

import type { SuiClientTypes } from "@mysten/sui/client";

/** Thrown when a transaction simulation (dry-run) fails before execution. */
export class SimulationError extends Error {
    constructor(public readonly error: SuiClientTypes.ExecutionError | null) {
        super(error?.message || "Transaction simulation failed");
    }

    /** `[module, function, abortCode]` when the failure is a Move abort. */
    get abortInfo(): [string, string, number] | null {
        const abort = this.error?.MoveAbort;
        if (!abort) return null;

        return [
            abort.location?.module || "unknown",
            abort.location?.functionName || "unknown",
            Number(abort.abortCode),
        ];
    }
}

/** Maps abort codes from each module to a text message */
export function vmAbortCodeToMessage(mod: string, fun: string, code: number) {
    let errorName = code.toString();

    // prettier-ignore
    switch (`${mod}:${code}`) {
        case "map:1": errorName = 'EUnitAlreadyonTile'; break;
        case "map:2": errorName = `ETileIsUnwalkable`; break;
        case "map:3": errorName = `EPathUnwalkable`; break;
        case "map:4": errorName = `EIncorrectPath`; break;
        case "map:5": errorName = `ENoUnit`; break;
        case "map:6": errorName = `EPathTooShort`; break;
        case "map:7": errorName = `ETileOutOfBounds`; break;
        case "map:8": errorName = `ETileIsWall`; break;
        case "map:9": errorName = `ENoLineOfSight`; break;
    }

    return `Abort '${errorName}' at '${mod}::${fun}'`;
}

/** Parses the standard abort code received in a dryRun */
export function parseVMError(error: string): [string, string, number] {
    if (error.startsWith("VMError")) {
        const search1 = /sub status (\d+)/.exec(error);
        const search2 = /([a-z_]+)::([a-z_]+) at offset/.exec(error);

        if (search1 === null || search2 === null) {
            throw new Error(`Unable to parse VMError: ${error}`);
        }

        const [, code] = search1;
        const [, mod, fun] = search2;

        return [mod, fun, +code];
    } else {
        throw new Error(`Unknown dry run error: ${error}`);
    }
}

// test value:
// "VMError with status ABORTED with sub status 3 at location Module ModuleId { address: 66e5b5d3a74f72f5833fb586992ae3050e86e57f994c8795b01cca1b6ccedae2, name: Identifier(\"map\") } and message 0x66e5b5d3a74f72f5833fb586992ae3050e86e57f994c8795b01cca1b6ccedae2::map::move_unit at offset 98 at code offset 98 in function definition 5"
