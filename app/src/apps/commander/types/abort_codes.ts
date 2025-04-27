// Copyright (c) Mysten Labs, Inc.
// SPDX-License-Identifier: Apache-2.0

/** Maps abort codes from each module to a text message */
export function vmAbortCodeToMessage(mod: string, fun: string, code: number) {
    let errorName = code.toString();

    // prettier-ignore
    switch (`${mod}:${code}`) {
        case "map:1": errorName = 'EUnitAlreadyOnTile'; break;
        case "map:2": errorName = `ETileNotWalkable`; break;
        case "map:3": errorName = `EPathNotWalkable`; break;
        case "map:4": errorName = `EIncorrectPath`; break;
        case "map:5": errorName = `ENoUnit`; break;
        case "map:6": errorName = `EPathTooShort`; break;
        case "map:7": errorName = `ETileOutOfBounds`; break;

        case "commander:0": errorName = `ENotAuthor`; break;
        case "commander:1": errorName = `ENotPlayer`; break;
        case "commander:2": errorName = `EInvalidGame`; break;
        case "commander:3": errorName = `ENotYourRecruit`; break;
        case "commander:4": errorName = `EIncorrectHost`; break;
        case "commander:5": errorName = `EHostNotSpecified`; break;
        case "commander:6": errorName = `ECannotPlay`; break;
        case "commander:7": errorName = `ENotReady`; break;
        case "commander:8": errorName = `EInvalidState`; break;
        case "commander:9": errorName = `EMustPlaceRecruits`; break;
        case "commander:10": errorName = `EAlreadyPlacedRecruits`; break;
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
