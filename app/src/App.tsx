import { Route, Routes } from "react-router-dom";
import Root from "./Root.tsx";
import { NavLink } from "react-router-dom";
import { App as GoGame } from "./apps/go-game/App.tsx";
// import { App as RockPaperScissors } from "./apps/rock-paper-scissors/App.tsx";
import { App as Character } from "./apps/character/App.tsx";
import { App as Dungeon } from "./apps/dungeon/App.tsx";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useEffect } from "react";
import { useSuiClient } from "@mysten/dapp-kit";
import {
    normalizeSuiAddress,
    normalizeStructTag,
    SUI_TYPE_ARG,
} from "@mysten/sui/utils";
import { requestSuiFromFaucetV1, getFaucetHost } from "@mysten/sui/faucet";
import { Toaster } from "react-hot-toast";

const GOBACK_KEY = "go_back";

export function App() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();

    const suiClient = useSuiClient();

    useEffect(() => {
        if (window.location.hash)
            flow.handleAuthCallback().then(() => {
                // @ts-ignore
                window.location = localStorage.getItem(GOBACK_KEY)
                    ? localStorage.getItem(GOBACK_KEY)
                    : window.location.href.split("#")[0];

                localStorage.removeItem(GOBACK_KEY);
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
        <div className="md:flex flex-wrap gap-5 items-center min-h-[100vh]">
            <div className="sidebar">
                <p className="wallet connect">
                    <u>
                        {(!zkLogin.address && (
                            <button
                                className="connect"
                                onClick={async () => {
                                    localStorage.setItem(
                                        GOBACK_KEY,
                                        window.location.href,
                                    );

                                    // Refresh the page to go back to the root path, this is a
                                    // workaround for the issue where google auth doesn't work
                                    // when the app is hosted on a subpath.
                                    history.pushState({}, "", "/");
                                    window.location.href =
                                        await flow.createAuthorizationURL({
                                            provider: "google",
                                            clientId:
                                                "591411088609-6kbt6b07a6np6mq2mnlq97i150amussh.apps.googleusercontent.com",
                                            redirectUrl:
                                                window.location.href.split(
                                                    "#",
                                                )[0],
                                            network: "testnet",
                                        });
                                }}
                            >
                                Sign In
                            </button>
                        )) || (
                            <button
                                onClick={() => flow.logout()}
                                className="connect"
                            >
                                Sign Out
                            </button>
                        )}
                    </u>
                </p>
                <ul>
                    <li>
                        <NavLink to="/go">go game</NavLink>
                    </li>
                    <li>
                        <NavLink to="/char">character</NavLink>
                    </li>
                    <li>
                        <NavLink to="/dungeon">dungeon</NavLink>
                    </li>
                    <li>
                        <a href="https://github.com/sui-potatoes/app" target="_blank">Source Code</a>
                        {/* <NavLink  to="/">rock paper scissors (disabled)</NavLink> */}
                        {/* <p style={{ cursor: "default" }}>
                            rock paper scissors (disabled)
                        </p> */}
                    </li>
                </ul>
            </div>
            <div className="content py-[10px] px-[20px] md:py-[20px]">
                <Routes>
                    <Route path="/" element={<Root />} />
                    <Route path="/go" element={<GoGame />} />
                    <Route path="/go/:id" element={<GoGame />} />
                    <Route path="/char" element={<Character />} />
                    <Route path="/dungeon" element={<Dungeon />} />
                    {/* <Route path="/rps" element={<RockPaperScissors />} /> */}
                </Routes>
            </div>

            <Toaster position={"bottom-center"} />
        </div>
    );
}
