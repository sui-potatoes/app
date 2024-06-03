import { getFullnodeUrl } from "@mysten/sui/client";
import {
    RPS_PACKAGE_ID,
    GOGAME_PACKAGE_ID,
    CHARACTER_PACKAGE_ID,
    CHARACTER_BUILDER_ID,
    WEBRTC_PACKAGE_ID,
} from "./constants";
import { createNetworkConfig } from "@mysten/dapp-kit";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
    createNetworkConfig({
        devnet: {
            url: getFullnodeUrl("devnet"),
            variables: {
                packageId: RPS_PACKAGE_ID,
                goPackageId: GOGAME_PACKAGE_ID,
                characterPackageId: CHARACTER_PACKAGE_ID,
                /** The ID of the Builder object from `character` package */
                characterBuilderId: CHARACTER_BUILDER_ID,
                webrtcPackageId: WEBRTC_PACKAGE_ID,
            },
        },
        testnet: {
            url: getFullnodeUrl("testnet"),
            variables: {
                packageId: RPS_PACKAGE_ID,
                goPackageId: GOGAME_PACKAGE_ID,
                characterPackageId: CHARACTER_PACKAGE_ID,
                /** The ID of the Builder object from `character` package */
                characterBuilderId: CHARACTER_BUILDER_ID,
                webrtcPackageId: WEBRTC_PACKAGE_ID,
            },
        },
    });

export { useNetworkVariable, useNetworkVariables, networkConfig };
