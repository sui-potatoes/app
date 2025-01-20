// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import * as JEASINGS from "jeasings";

export class Camera extends THREE.PerspectiveCamera {

    public defaultPosition = new THREE.Vector3();
    public defaultTarget = new THREE.Vector3();
    public rotationMatrix = new THREE.Matrix4();

    async moveToUnit(point: THREE.Vector3, lookAt: THREE.Vector3) {
        return new Promise((resolve) => {
            new JEASINGS.JEasing(this.position)
                .to({ x: point.x, y: point.y, z: point.z }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(new THREE.Vector3(lookAt.x, lookAt.y, lookAt.z)))
                .start()
                .onComplete(() => {
                    resolve(null);
                });
        });
    }

    async moveBack() {
        return new Promise((resolve) => {
            const { x, y, z } = this.defaultPosition.clone();
            new JEASINGS.JEasing(this.position)
                .to({ x, y, z }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(this.defaultTarget.clone()))
                .start()
                .onComplete(() => resolve(null));
        });
    }
}
