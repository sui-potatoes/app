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
            "/public/samples/Percussion/Chopsticks/Chopsticks_09.wav",
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
        }, 1000);

        console.log("App mounted");
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

/**
 *
 * Routing:
 *
 * Chopsticks -> ping pong -> auto filter -> reverb
 * Atmos -> filter -> reverb
 * Bass -> reverb
 */
// function playMusic() {
//     const kick = new Tone.Player("/public/samples/Kick/Kick_05.wav");
//     const chop = new Tone.Player("/public/samples/Percussion/Chopsticks/Chopsticks_09.wav");
//     const stab = new Tone.Player("/public/samples/Stab/Stab_08.wav"); // 10, 21, 08
//     const pad = new Tone.GrainPlayer("/public/samples/Atmos/Atmos_05.wav");

//     // Create a dark bass pulse
//     const bass = new Tone.MonoSynth({
//         oscillator: { type: "sine" },
//         filter: { type: "lowpass", frequency: 200 },
//         envelope: { attack: 0.1, decay: 0.2, sustain: 0.5, release: 0.8 },
//     }).toDestination();

//     bass.volume.value = -10;

//     const filter = new Tone.Filter(200, "lowpass").toDestination();
//     const pingPong = new Tone.PingPongDelay("4n", 0.2);
//     const reverb = new Tone.Reverb(0.5).toDestination();
//     const hallReverb = new Tone.Reverb(0.8).toDestination();

//     // sample player

//     const autoFilter = new Tone.AutoFilter("4n").toDestination();

//     kick.connect(filter);
//     kick.volume.value = -10;

//     autoFilter.start();
//     autoFilter.wet.value = 1;
//     autoFilter.baseFrequency = 500;
//     autoFilter.wet.value = 1;

//     pingPong.connect(autoFilter);
//     chop.connect(pingPong);
//     chop.volume.value = -20;
//     // chop.connect(filter);
//     chop.connect(autoFilter);

//     pad.connect(reverb);
//     pad.connect(filter);
//     bass.connect(reverb);

//     pad.grainSize = 0.01;
//     pad.playbackRate = 1;
//     pad.volume.value = -4;

//     stab.connect(hallReverb);
//     stab.reverse = true;
//     stab.fadeIn = 10;

//     // Start Everything
//     async function startMusic() {
//         await Tone.start();
//         Tone.getTransport().bpm.value = 100;
//         Tone.getTransport().start();

//         // bass loop, repeat each note every 1m
//         new Tone.Loop((time) => {
//             bass.triggerAttackRelease("F2", "4n", time);
//             bass.triggerAttackRelease("F#2", "8n", time + 0.3);
//         }, "1m").start();

//         new Tone.Loop((_time) => kick.start(), "2n").start();

//         // pad loop, repeat every 4m
//         new Tone.Loop(() => pad.start(), "4m").start();
//         new Tone.Loop(() => chop.start(), "4m").start();

//         // stab loop, repeat every 4m
//         new Tone.Loop(() => stab.start(), "4m").start();
//     }

//     // Call startMusic() when user interacts with the page
//     let musicStarted = false;
//     document.querySelector(".commander-v2")?.addEventListener("click", () => {
//         if (!musicStarted) {
//             startMusic();
//             musicStarted = true;
//         }
//     });
// }
