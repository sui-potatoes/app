// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount, useDAppKit } from "@mysten/dapp-kit-react";
import { getFaucetHost, requestSuiFromFaucetV2 } from "@mysten/sui/faucet";
import { useEffect } from "react";
import { NavLink, Route, Routes } from "react-router-dom";

import Character from "./apps/character/App.tsx";
import GoGame from "./apps/go-game/App.tsx";
import Libraries from "./apps/libraries/App.tsx";
import { NETWORK } from "./constants";
import { FaucetModal } from "./FaucetModal";
import { useGoogleSignIn } from "./hooks/useGoogleSignIn";
import Root from "./Root.tsx";

// Commander is temporarily disabled — its nav link and route are removed.
// The sub-app (`./apps/commander`) is kept in the tree for later re-enabling.
const NAV_LINKS = [
    { to: "/go", label: "go game" },
    { to: "/character", label: "character" },
    { to: "/libraries", label: "libraries (for devs)" },
];

export function App() {
    const dAppKit = useDAppKit();
    const account = useCurrentAccount();
    const { canSignIn, signIn, signOut } = useGoogleSignIn();

    // Top up fresh zkLogin accounts from the testnet faucet.
    useEffect(() => {
        if (!account) return;

        const client = dAppKit.getClient();
        client.core
            .getBalance({ owner: account.address })
            .then(({ balance }) => {
                if (BigInt(balance.balance) === 0n) {
                    return requestSuiFromFaucetV2({
                        host: getFaucetHost(NETWORK),
                        recipient: account.address,
                    });
                }
            })
            .catch(console.warn);
    }, [dAppKit, account]);

    return (
        <div className="flex flex-col md:flex-row md:items-start">
            <div className="sidebar">
                <NavLink to="/" className="sidebar-brand" end>
                    Pot8os
                </NavLink>
                <ul>
                    {NAV_LINKS.map(({ to, label }) => (
                        <li key={to}>
                            <NavLink to={to}>{label}</NavLink>
                        </li>
                    ))}
                </ul>
                <ul className="sidebar-footer">
                    <li>
                        {account ? (
                            <button className="connect" onClick={() => signOut()}>
                                Sign Out
                            </button>
                        ) : (
                            <button
                                className="connect"
                                disabled={!canSignIn}
                                onClick={() => signIn()}
                            >
                                Sign In
                            </button>
                        )}
                    </li>
                    <li>
                        <a href="https://github.com/sui-potatoes/app" target="_blank">
                            Source Code
                        </a>
                    </li>
                </ul>
            </div>
            <div className="content py-[10px] px-[20px] md:py-[20px] md:px-[48px] lg:px-[72px]">
                <Routes>
                    <Route index path="/" element={<Root />} />
                    <Route path="/go" element={<GoGame />} />
                    <Route path="/go/:id" element={<GoGame />} />
                    <Route path="/character" element={<Character />} />
                    <Route path="/libraries" element={<Libraries />} />
                </Routes>
            </div>
            <FaucetModal />
        </div>
    );
}
