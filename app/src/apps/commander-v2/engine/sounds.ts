// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as Tone from "tone";

const sampleList = {
    chop: "/samples/selected/Chopsticks_09.wav",
    stab: "/samples/selected/Stab_08.wav",
    kick: "/samples/selected/Kick_05.wav",
    atmos: "/samples/selected/Atmos_05.wav",
} as const;

export type SampleName = keyof typeof sampleList;

/** Contains all loaded samples. */
export const samples: Record<SampleName, Tone.ToneAudioBuffer | null> = {
    chop: null,
    stab: null,
    kick: null,
    atmos: null,
};

/** Trigger loading of all models. */
export async function loadModels() {
    await Promise.all(
        Object.entries(sampleList).map(async ([key, url]) => {
            samples[key as SampleName] = await new Tone.ToneAudioBuffer().load(url);
        }),
    );
}
