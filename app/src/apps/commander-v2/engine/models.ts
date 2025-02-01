// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { GLTF, GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js';

/**
 * Contains all loaded models.
 * Required to be loaded before the game starts.
 */
export const models: { [key: string]: GLTF } = {};

const dracoLoader = new DRACOLoader();
dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');

const loader = new GLTFLoader();
loader.setDRACOLoader(dracoLoader);

/** Trigger loading of all models. */
export async function loadModels() {
    let [
        soldier,
        base_tile,
        barrier_steel,
        barrel_stack
    ] = await Promise.all([
        loader.loadAsync("/soldier_3.glb"),
        loader.loadAsync("/models/base_tile.glb"),
        loader.loadAsync("/models/barrier_steel.glb"),
        loader.loadAsync("/models/barrel_stack.glb"),
    ]);

    models.soldier = soldier;
    models.base_tile = base_tile;
    models.barrier_steel = barrier_steel;
    models.barrel_stack = barrel_stack;
}
