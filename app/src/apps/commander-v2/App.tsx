// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./styles.css";
import { Menu } from "./pages/Menu";
import { Options } from "./pages/Options";
import { Playground } from "./pages/Play";
import { Route, Routes, useLocation } from "react-router-dom";
import { Armor } from "./pages/Armor";
import { Crew } from "./pages/Crew";
import { Headquarters } from "./pages/Headquarters";
import { Weapons } from "./pages/Weapons";
import { Editor } from "./pages/Editor";
import { useZkLogin } from "@mysten/enoki/react";
import * as Tone from "tone";
import { useEffect } from "react";

export default function App() {
    const zkLogin = useZkLogin();
    const location = useLocation();

    useEffect(() => {
        const filter = new Tone.Filter(300, "bandpass").toDestination();
        const player = new Tone.Player(
            "/samples/Percussion/Chopsticks/Chopsticks_09.wav",
            onLoad,
        ).connect(filter);

        function onLoad() {
            const slice = player.buffer.slice(0.02, 0.1);
            player.buffer.set(slice);
            player.toFrequency(0.5);
        }

        setTimeout(() => {
            document.querySelectorAll(".interactive").forEach((e) => {
                e.addEventListener("mouseenter", (e) => {
                    if (
                        e.target &&
                        e.target instanceof HTMLElement &&
                        e.target.classList.contains("interactive")
                    ) {
                        player.stop();
                        player.start();
                    }
                });
            });
        }, 500);
    }, [location.pathname, zkLogin.address]);

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
