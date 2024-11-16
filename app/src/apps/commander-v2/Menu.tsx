// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";

export function Menu() {
    return (
        <div className="flex justify-center align-middle h-screen flex-col">
            <NavLink to="playground" className="menu-control">Playground</NavLink>
            <NavLink to="crew" className="menu-control">My Crew</NavLink>
            <NavLink to="settings" className="menu-control">Settings</NavLink>
            <NavLink to="/" className="menu-control">Exit Game</NavLink>
        </div>
    );
}
