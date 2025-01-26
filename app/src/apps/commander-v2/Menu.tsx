// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { NavLink } from "react-router-dom";
import { GOBACK_KEY } from "../../App";
import { createMenuScene } from "./menu/scene";
import { useEffect } from "react";

export function Menu() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const disabled = !zkLogin.address;
    const className = disabled ? "menu-control disabled" : "menu-control";

    useEffect(() => {
        createMenuScene("menu-scene");
    }, []);

    return (
        <>
            <div id="menu-scene"></div>,
            <div className="flex justify-center align-middle h-screen flex-col">
                {disabled && (
                    <div
                        className="menu-control"
                        onClick={async () => {
                            localStorage.setItem(GOBACK_KEY, window.location.href);

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
                        Sign in to play
                    </div>
                )}
                <NavLink to="playground" className={className}>
                    Playground
                </NavLink>
                <NavLink to="crew" className={className}>
                    My Crew
                </NavLink>
                <NavLink to="inventory" className={className}>
                    Inventory
                </NavLink>
                <NavLink to="settings" className={className}>
                    Settings
                </NavLink>
                <NavLink to="/" className="menu-control">
                    Exit Game
                </NavLink>
            </div>
        </>
    );
}
