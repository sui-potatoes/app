// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import * as JEASINGS from "jeasings";

export class Camera extends THREE.PerspectiveCamera {
    public defaultPosition = new THREE.Vector3();
    public defaultTarget = new THREE.Vector3();
    public rotationMatrix = new THREE.Matrix4();

    /**
     * Recalculates the default position and target for the camera based on the
     * size of the grid.
     *
     * @param size - size of the grid
     */
    public resetForSize(size: number) {
        const offset = size / 2 - 0.5;
        this.defaultPosition = new THREE.Vector3(offset * 2, size + 5, -offset);
        this.defaultTarget = new THREE.Vector3(offset, 0, -offset);
        this.position.copy(this.defaultPosition);
        this.lookAt(this.defaultTarget);
    }

    /**
     * Smoothly moves the camera to the specified point and looks at the specified target.
     *
     * @param point
     * @param lookAt
     */
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

    /** Smoothly moves the camera to the default position. */
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
