// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as Tone from "tone";
import { samples } from "./../engine/sounds";

/** Hook to create a player for a given sample. */
export function usePlayer({ sample }: { sample: string }) {
    const player = new Tone.Player(samples[sample]).toDestination();
    return player;
}
