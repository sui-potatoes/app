// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { Footer } from "./Components";

export function Headquarters() {
    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                <h1 className="block p-1 mb-10 uppercase white page-heading">headquarters</h1>
            </div>
            <div className="px-20 justify-center text-uppercase text-2xl flex max-w-full">
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
            <Footer />
        </div>
    );
}
