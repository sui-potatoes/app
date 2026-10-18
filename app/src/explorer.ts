// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NETWORK } from "./constants";

/**
 * Explorer link for anything searchable: a transaction digest, an address or an
 * object id. devxplorer resolves the kind from the value itself.
 */
export function explorerUrl(query: string, network: string = NETWORK): string {
    return `https://devxplorer.io?search=${query}&network=${network}`;
}
