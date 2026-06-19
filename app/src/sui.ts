// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { createDAppKit } from "@mysten/dapp-kit-react";
import { enokiWalletsInitializer } from "@mysten/enoki";
import { SuiGraphQLClient } from "@mysten/sui/graphql";
import { SuiGrpcClient } from "@mysten/sui/grpc";
import { GOOGLE_CLIENT_ID, NETWORK } from "./constants";

if (!import.meta.env.VITE_ENOKI_API_KEY) {
    console.error(
        "VITE_ENOKI_API_KEY is not set — zkLogin sign-in will fail with a blank popup. " +
            "Add it to app/.env and restart the dev server.",
    );
}

/**
 * Central dApp Kit instance: a gRPC client per network and the Enoki
 * zkLogin wallets (Google) registered through the wallet standard.
 */
export const dAppKit = createDAppKit({
    networks: [NETWORK],
    defaultNetwork: NETWORK,
    createClient: (network) =>
        new SuiGrpcClient({
            network,
            baseUrl: `https://fullnode.${network}.sui.io:443`,
        }),
    walletInitializers: [
        enokiWalletsInitializer({
            apiKey: import.meta.env.VITE_ENOKI_API_KEY,
            providers: {
                google: {
                    clientId: GOOGLE_CLIENT_ID,
                    // Google only authorizes exact redirect URIs; the wallet's
                    // default (current page URL) breaks sign-in on sub-routes.
                    redirectUrl: `${window.location.origin}/`,
                },
            },
        }),
    ],
});

/**
 * GraphQL client for queries that have no gRPC equivalent
 * (e.g. filtered transaction history).
 */
export const graphqlClient = new SuiGraphQLClient({
    network: NETWORK,
    url: `https://graphql.${NETWORK}.sui.io/graphql`,
});

declare module "@mysten/dapp-kit-core" {
    interface Register {
        dAppKit: typeof dAppKit;
    }
}
