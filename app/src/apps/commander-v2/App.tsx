// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./styles.css";
import { Menu } from "./Menu";
import { Options } from "./Options";
import { Playground } from "./Play";
import { Route, Routes } from "react-router-dom";
import { Crew } from "./Crew";
import { Headquaters } from "./Headquaters";
import { Editor } from "./Editor";

export default function App() {
    return (
        <div id="commander-v2" className="items-start">
            <div className="w-full h-full bg-opacity-70 bg-black">
                <Routes>
                    <Route path="/" element={<Menu />} />
                    <Route path="headquaters/crew" element={<Crew />} />
                    <Route path="headquaters" element={<Headquaters />} />
                    <Route path="headquaters/:type" element={<Headquaters />} />
                    <Route path="options" element={<Options />} />
                    <Route path="play" element={<Playground />} />
                    <Route path="editor" element={<Editor />} />
                </Routes>
            </div>
        </div>
    );
}
