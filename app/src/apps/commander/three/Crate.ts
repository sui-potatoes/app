// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { GameObject} from "./GameObject";

/**
 * Simple `Crate` object which has a texture.
 * Has size of 1x1x1 and can be placed on the grid.
 */
export class Crate extends GameObject<THREE.Object3DEventMap> {
    constructor() {
        const geometry = new THREE.BoxGeometry(1, 1, 1);
        const texture = new THREE.TextureLoader().load("/images/unit-barricade.png");
        const material = new THREE.MeshStandardMaterial({ color: 0xaaaaaa, map: texture });

        super(geometry, material);
        this.receiveShadow = true;
    }
}
