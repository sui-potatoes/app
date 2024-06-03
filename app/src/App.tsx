import { Route, Routes } from "react-router-dom";
import Root from "./Root.tsx";
import { NavLink } from "react-router-dom";
import { App as GoGame } from "./apps/go-game/App.tsx";
import { App as RockPaperScissors } from "./apps/rock-paper-scissors/App.tsx";
import { App as Character } from "./apps/character/App.tsx";
import { App as WebRTC } from "./apps/webrtc/App.tsx";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useEffect } from "react";
import { ConnectButton } from "@mysten/dapp-kit";

export function App() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();

    useEffect(() => {
        if (window.location.hash)
            flow.handleAuthCallback().then(() => {
                // @ts-ignore
                window.location = window.location.href.split("#")[0];
            });
    }, []);

    return (
        <div className="container">
            <div className="sidebar">
                <p className="wallet connect">
                    {(!zkLogin.address && (
                        <button
                            className="connect"
                            onClick={async () => {
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
                                            window.location.href.split("#")[0],
                                        network: "testnet",
                                    });
                            }}
                        >
                            Sign In (Google)
                        </button>
                    )) || (
                        <button
                            onClick={() => flow.logout()}
                            className="connect"
                        >
                            Sign Out
                        </button>
                    )}
                </p>
                <p className="wallet connect">
                    <ConnectButton
                        connectText="Connect (Wallet)"
                        className="connect"
                    />
                </p>
                <ul>
                    <li>
                        <NavLink to="/go">go game</NavLink>
                    </li>
                    <li>
                        <NavLink to="/char">character</NavLink>
                    </li>
                    <li>
                        <NavLink to="/webrtc">webrtc</NavLink>
                    </li>
                    <li>
                        <p style={{ cursor: "default" }}>
                            rock paper scissors (disabled)
                        </p>
                    </li>
                </ul>
            </div>
            <div className="content">
                <Routes>
                    <Route path="/" element={<Root />} />
                    <Route path="/go" element={<GoGame />} />
                    <Route path="/go/:id" element={<GoGame />} />
                    <Route path="/char" element={<Character />} />
                    <Route path="/char/:id" element={<Character />} />
                    <Route path="/rps" element={<RockPaperScissors />} />
                    <Route path="/webrtc" element={<WebRTC />} />
                    <Route
                        path="/webrtc/:role(host|guest)"
                        element={<WebRTC />}
                    />
                </Routes>
            </div>
        </div>
    );
}
