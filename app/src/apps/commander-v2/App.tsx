// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect } from "react";
import "./styles.css";
import { createMenuScene } from "./menu/scene";
import { Menu } from "./Menu";
import { Settings } from "./Settings";
import { Playground } from "./Playground";
import { Route, Routes } from "react-router-dom";
import { Crew } from "./Crew";

export default function App() {
    useEffect(() => { createMenuScene("menu-scene") }, []);

    return (
        <div id="commander-v2" className="items-start">
            <div id="menu-scene"></div>
            <Routes>
                <Route path="/" element={<Menu />} />
                <Route path="crew" element={<Crew />} />
                <Route path="settings" element={<Settings />} />
                <Route path="playground" element={<Playground />} />
            </Routes>
        </div>
    );
}
