// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { GameScreen } from "./Components";

export function Headquarters() {
    return (
        <GameScreen title="headquarters">
            <div className="flex justify-center w-full">
                <NavLink to="armor" className="p-10 text-center card interactive">
                    <img className="" src="/images/icon_armory.svg" />
                    <h2>ARMOR</h2>
                </NavLink>
                <NavLink to="crew" className="p-10 text-center card interactive">
                    <img className="" src="/images/icon_crew.svg" />
                    <h2>CREW</h2>
                </NavLink>
                <NavLink to="weapons" className="p-10 text-center card interactive">
                    <img className="" src="/images/icon_weapons.svg" />
                    <h2>WEAPONS</h2>
                </NavLink>
            </div>
        </GameScreen>
    );
}
