// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./styles.css";
import { Menu } from "./pages/Menu";
import { Options } from "./pages/Options";
import { Playground } from "./pages/Play";
import { Route, Routes } from "react-router-dom";
import { Armor } from "./pages/Armor";
import { Crew } from "./pages/Crew";
import { Headquarters } from "./pages/Headquarters";
import { Weapons } from "./pages/Weapons";
import { Editor } from "./pages/Editor";
import { useZkLogin } from "@mysten/enoki/react";

export default function App() {
    const zkLogin = useZkLogin();

    return (
        <div className="commander-v2">
            <div className="w-full h-full bg-opacity-70 bg-black">
                <Routes>
                    <Route path="/" element={<Menu />} />
                    {zkLogin && (
                        <>
                            <Route path="headquarters/crew" element={<Crew />} />
                            <Route path="headquarters/armor" element={<Armor />} />
                            <Route path="headquarters/weapons" element={<Weapons />} />
                            <Route path="headquarters" element={<Headquarters />} />
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
