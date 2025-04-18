// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { GLTF, GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from "three/addons/loaders/DRACOLoader.js";

const modelsList = {
    soldier: "/models/soldier_3.glb",
    base_tile: "/models/base_tile.glb",
    barrier_steel: "/models/barrier_steel.glb",
    barrel_stack: "/models/barrel_stack.glb",
    the_dude: "/models/the_dude.glb",
} as const;

export type ModelName = keyof typeof modelsList;

/**
 * Contains all loaded models.
 * Required to be loaded before the game starts.
 */
export const models: Record<ModelName, GLTF | null> & { loaded: boolean } = {
    soldier: null,
    the_dude: null,
    base_tile: null,
    barrier_steel: null,
    barrel_stack: null,
    loaded: false,
};

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath("https://www.gstatic.com/draco/versioned/decoders/1.5.6/");

const loader = new GLTFLoader();
loader.setDRACOLoader(dracoLoader);

/** Trigger loading of all models. */
export async function loadModels() {
    await Promise.all(
        Object.entries(modelsList).map(async ([key, url]) => {
            models[key as ModelName] = await loader.loadAsync(url);
        }),
    );

    models.loaded = true;
}
