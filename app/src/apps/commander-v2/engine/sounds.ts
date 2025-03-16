// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as Tone from "tone";

/** Contains all loaded samples. */
export const samples: { [key: string]: Tone.ToneAudioBuffer } = {};

const sampleList = {
    chop: "/samples/selected/Percussion/Chopsticks/Chopsticks_09.wav",
    stab: "/samples/selected/Stab/Stab_08.wav",
    kick: "/samples/selected/Kick/Kick_05.wav",
    atmos: "/samples/selected/Atmos/Atmos_05.wav",
};

/** Trigger loading of all models. */
export async function loadModels() {
    await Promise.all(
        Object.entries(sampleList).map(async ([key, url]) => {
            samples[key] = await new Tone.ToneAudioBuffer().load(url);
        })
    );
}
