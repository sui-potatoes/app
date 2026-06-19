// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useDAppKit, useWallets } from "@mysten/dapp-kit-react";
import { isGoogleWallet } from "@mysten/enoki";

/**
 * Sign-in / sign-out via the Enoki Google zkLogin wallet.
 * The OAuth flow runs in a popup managed by the wallet itself.
 */
export function useGoogleSignIn() {
    const dAppKit = useDAppKit();
    const googleWallet = useWallets().find(isGoogleWallet);

    return {
        canSignIn: !!googleWallet,
        async signIn() {
            if (!googleWallet) throw new Error("Google wallet is not registered");
            try {
                return await dAppKit.connectWallet({ wallet: googleWallet });
            } catch (e) {
                // a failure before the OAuth redirect leaves the popup on
                // about:blank with no visible error — at least log it
                console.error("zkLogin sign-in failed:", e);
                throw e;
            }
        },
        signOut: () => dAppKit.disconnectWallet(),
    };
}
