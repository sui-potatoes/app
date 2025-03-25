// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Route, Routes } from "react-router-dom";
import Root from "./Root.tsx";
import { NavLink } from "react-router-dom";
import GoGame from "./apps/go-game/App.tsx";
import Libraries from "./apps/libraries/App.tsx";
import Character from "./apps/character/App.tsx";
import CommanderV2 from "./apps/commander-v2/App.tsx";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useEffect } from "react";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiAddress, normalizeStructTag, SUI_TYPE_ARG } from "@mysten/sui/utils";
import { requestSuiFromFaucetV1, getFaucetHost } from "@mysten/sui/faucet";

export const GO_BACK_KEY = "go_back";

export function App() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();

    const suiClient = useSuiClient();

    useEffect(() => {
        if (window.location.hash)
            flow.handleAuthCallback().then(() => {
                // @ts-ignore
                window.location = localStorage.getItem(GO_BACK_KEY)
                    ? localStorage.getItem(GO_BACK_KEY)
                    : window.location.href.split("#")[0];

                localStorage.removeItem(GO_BACK_KEY);
            });
    }, []);

    useEffect(() => {
        (async () => {
            if (!zkLogin.address) return;

            const balance = await suiClient.getBalance({
                owner: normalizeSuiAddress(zkLogin.address),
                coinType: normalizeStructTag(SUI_TYPE_ARG),
            });

            if (BigInt(balance.totalBalance) === 0n)
                requestSuiFromFaucetV1({
                    host: getFaucetHost("testnet"),
                    recipient: normalizeSuiAddress(zkLogin.address),
                });
        })();
    }, [zkLogin.address]);

    return (
        <div className="md:flex flex-wrap gap-5 items-center">
            <div className="sidebar">
                <ul>
                    <li>
                        {(!zkLogin.address && (
                            <button
                                className="connect"
                                onClick={async () => {
                                    localStorage.setItem(GO_BACK_KEY, window.location.href);

                                    // Refresh the page to go back to the root path, this is a
                                    // workaround for the issue where google auth doesn't work
                                    // when the app is hosted on a subpath.
                                    history.pushState({}, "", "/");
                                    window.location.href = await flow.createAuthorizationURL({
                                        provider: "google",
                                        clientId:
                                            "591411088609-6kbt6b07a6np6mq2mnlq97i150amussh.apps.googleusercontent.com",
                                        redirectUrl: window.location.href.split("#")[0],
                                        network: "testnet",
                                    });
                                }}
                            >
                                Sign In
                            </button>
                        )) || (
                            <button onClick={() => flow.logout()} className="connect">
                                Sign Out
                            </button>
                        )}
                    </li>
                    <li>
                        <NavLink to="/go">go game</NavLink>
                    </li>
                    <li>
                        <NavLink to="/character">character</NavLink>
                    </li>
                    {/* <li>
                        <NavLink to="/commander">commander</NavLink>
                    </li> */}
                    <li>
                        <NavLink to="/commander">commander</NavLink>
                    </li>
                    <li>
                        <NavLink to="/libraries">libraries (for devs)</NavLink>
                    </li>
                    <li>
                        <a href="https://github.com/sui-potatoes/app" target="_blank">
                            Source Code
                        </a>
                    </li>
                </ul>
            </div>
            <div className="content py-[10px] px-[20px] md:py-[20px]">
                <Routes>
                    <Route index path="/" element={<Root />} />
                    <Route path="/go" element={<GoGame />} />
                    <Route path="/go/:id" element={<GoGame />} />
                    <Route path="/character" element={<Character />} />
                    {/* <Route path="/commander" element={<Commander />} /> */}
                    <Route path="/commander/*" element={<CommanderV2 />} />
                    <Route path="/libraries" element={<Libraries />} />
                </Routes>
            </div>
        </div>
    );
}
