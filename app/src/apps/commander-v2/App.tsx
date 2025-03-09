// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./styles.css";
import { Menu } from "./Menu";
import { Options } from "./Options";
import { Playground } from "./Play";
import { Route, Routes } from "react-router-dom";
import { Armor } from "./Armor";
import { Crew } from "./Crew";
import { Headquaters } from "./Headquaters";
import { Weapons } from "./Weapons";
import { Editor } from "./Editor";
import { useZkLogin } from "@mysten/enoki/react";

export default function App() {
    const zkLogin = useZkLogin();

    return (
        <div id="commander-v2" className="items-start">
            <div className="w-full h-full bg-opacity-70 bg-black">
                <Routes>
                    <Route path="/" element={<Menu />} />
                    {zkLogin && (
                        <>
                            <Route path="headquaters/crew" element={<Crew />} />
                            <Route path="headquaters/armor" element={<Armor />} />
                            <Route path="headquaters/weapons" element={<Weapons />} />
                            <Route path="headquaters" element={<Headquaters />} />
                            <Route path="options" element={<Options />} />
                            <Route path="play" element={<Playground />} />
                            <Route path="editor" element={<Editor />} />
                        </>
                    )}
                </Routes>
            </div>
        </div>
    );
}
