// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { Footer } from "./Components";

export function Headquaters() {
    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10 max-w-xl">
                <h1 className="block p-1 mb-10 uppercase white page-heading">headquaters</h1>
            </div>
            <div className="px-20 justify-center text-uppercase text-2xl flex max-w-full">
                <NavLink to="armor" className="p-10 text-center card">
                    <img className="" src="/images/armor.svg" />
                    <h2>ARMOR</h2>
                </NavLink>
                <NavLink to="crew" className="p-10 text-center card">
                    <img className="" src="/images/crew.svg" />
                    <h2>CREW</h2>
                </NavLink>
                <NavLink to="weapons" className="p-10 text-center card">
                    <img className="" src="/images/weapons.svg" />
                    <h2>WEAPONS</h2>
                </NavLink>
            </div>
            <div></div>
            <Footer />
        </div>
    );
}
