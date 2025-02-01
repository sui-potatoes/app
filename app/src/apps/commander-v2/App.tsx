// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./styles.css";
import { Menu } from "./Menu";
import { Settings } from "./Settings";
import { Playground } from "./Playground";
import { Route, Routes } from "react-router-dom";
import { Crew } from "./Crew";
import { Inventory } from "./Inventory";

export default function App() {
    return (
        <div id="commander-v2" className="items-start">
            <Routes>
                <Route path="/" element={<Menu />} />
                <Route path="crew" element={<Crew />} />
                <Route path="inventory" element={<Inventory />} />
                <Route path="settings" element={<Settings />} />
                <Route path="playground" element={<Playground />} />
            </Routes>
        </div>
    );
}
