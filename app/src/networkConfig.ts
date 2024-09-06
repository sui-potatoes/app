// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { getFullnodeUrl } from "@mysten/sui/client";
import {
    GOGAME_PACKAGE_ID,
    CHARACTER_PACKAGE_ID,
    CHARACTER_BUILDER_ID,
} from "./constants";
import { createNetworkConfig } from "@mysten/dapp-kit";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
    createNetworkConfig({
        testnet: {
            url: getFullnodeUrl("testnet"),
            variables: {
                goPackageId: GOGAME_PACKAGE_ID,
                characterPackageId: CHARACTER_PACKAGE_ID,
                /** The ID of the Builder object from `character` package */
                characterBuilderId: CHARACTER_BUILDER_ID,
            },
        },
    });

export { useNetworkVariable, useNetworkVariables, networkConfig };
