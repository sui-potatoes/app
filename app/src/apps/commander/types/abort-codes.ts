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
    }

    return `Abort '${errorName}' at '${mod}::${fun}'`;
}
