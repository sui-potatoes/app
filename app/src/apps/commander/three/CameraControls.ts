// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export type ControlsEvents = {};

export class CameraControls extends THREE.Controls<ControlsEvents> {
    constructor(camera: THREE.Camera, domElement: HTMLElement) {
        super(camera, domElement);
    }

    update(_delta: number) {
        console.log('update');
        this.update(0.001);
    }
}
