// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useZkLogin } from "@mysten/enoki/react";
import { useEffect, useMemo, useState } from "react";
import * as Tone from "tone";

export default function Audio() {
    const zkLogin = useZkLogin();
    const [midi, setMidi] = useState<MIDIAccess | null>(null);

    const synths = useMemo(() => new Array(4).fill(0).map(() => new Tone.Synth().toDestination()), []);
    const oscillators = useMemo(() => new Array(4).fill(0).map(() => new Tone.Oscillator().toDestination()), []);

    useEffect(() => {
        if (!!midi) return;

        function onMIDISuccess(midiAccess: MIDIAccess) {
            console.log("MIDI ready!");
            setMidi(midiAccess);
        }

        function onMIDIFailure(msg: any) {
            console.error(`Failed to get MIDI access - ${msg}`);
        }

        navigator.requestMIDIAccess().then(onMIDISuccess, onMIDIFailure);
    }, []);

    return (
        <>
            <input type="text" value={zkLogin.address} className="bg-white border-2 border-sky-500" />
            <br />
            <button onClick={play}>Play C4</button>
        </>
    );

    async function play() {
        if (!midi) return;

        const op1 = [...midi.outputs.values()][0];

        // left to right: note on, note number, velocity
        op1.send([0x90, 60, 100]);
        // stop
        await new Promise((resolve) => setTimeout(resolve, 1000));

        op1.send([0x80, 60, 100]);


        // // generate sequence of 32 random bytes
        // const bytes = new Uint8Array(32);
        // window.crypto.getRandomValues(bytes);

        // if (bytes.length % 4 !== 0) {
        //     throw new Error("bytes length must be a multiple of 4");
        // }

        // // 8 values per bar
        // // 4 notes, 4 velocities

        // Tone.getTransport().start();
    }
}
