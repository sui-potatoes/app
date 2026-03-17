// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export interface Interface3D {
    readonly objects: THREE.Group;

    add(object: THREE.Object3D): void;
    remove(object: THREE.Object3D): void;
}
