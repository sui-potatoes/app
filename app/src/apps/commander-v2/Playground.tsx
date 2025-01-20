// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { createScene } from "./engine/scene";
import { useEffect } from "react";

export function Playground() {
    useEffect(() => { createScene("game-scene"); }, []);

    return (
        <>
            <div id="game-scene"></div>
            <div className="flex justify-center align-middle h-screen flex-col">
                <h1 className="menu-control">Playground</h1>
                <NavLink className="menu-control" to="/commander-v2">Back</NavLink>
            </div>
        </>
    );
}
