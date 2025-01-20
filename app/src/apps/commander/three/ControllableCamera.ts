// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Component } from "./GameObject";
import JEASINGS from "jeasings";
import { CameraControls } from "./CameraControls";

const { MOUSE } = THREE;
// const CLOSEUP = new THREE.Vector3(-0.2, -0.2, -0.3);

/**
 * A camera that can be controlled by the player.
 */
export class ControllableCamera extends THREE.PerspectiveCamera implements Component {
    protected shiftPressed = false;
    protected wheelPressed = false;
    protected rightClickPressed = false;
    protected leftClickPressed = false;

    protected reverse: boolean = false;
    protected center: THREE.Vector3;
    protected defaultPosition: THREE.Vector3;
    protected controls: CameraControls;

    constructor(aspect: number, domElement: HTMLElement) {
        super(45, aspect, 1, 5000);

        this.center = new THREE.Vector3(0, 0, 0);
        this.defaultPosition = new THREE.Vector3(0, 10, 0);
        this.position.set(0, 10, 0);
        this.controls = new CameraControls(this, domElement);
        this.controls.connect();
    }

    initialize(scene: THREE.Scene) {
        scene.add(this);
        this._ready();
    }

    _ready(): void {}
    _select(): void {}
    _deselect(): void {}
    _process(_delta: number): void {}

    setDefaults(center: THREE.Vector3) {
        this.center = center;
        this.position.add(center).multiply(new THREE.Vector3(1, 1, 3));
        this.defaultPosition = this.position.clone();
        this.lookAt(center);
    }

    async moveToUnit(point: THREE.Vector2, lookAt: THREE.Vector2) {
        return new Promise((resolve) => {
            new JEASINGS.JEasing(this.position)
                .to({ x: point.x, y: 1, z: point.y }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(new THREE.Vector3(lookAt.x, 0, lookAt.y)))
                .start()
                .onComplete(() => {
                    resolve(null);
                });
        });
    }

    async moveBack() {
        return new Promise((resolve) => {
            const { x, y, z } = !this.reverse
                ? this.defaultPosition.clone()
                : this.defaultPosition.clone().multiply(new THREE.Vector3(1, 1, -1));

            new JEASINGS.JEasing(this.position)
                .to({ x, y, z }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(this.center.clone()))
                .start()
                .onComplete(() => resolve(null));
        });
    }

    /**
     * Track global inputs: keyboard, mouse, and wheel events.
     * Currently tracked:
     * - Spacebar: Animate the camera to show the other side of the board.
     * - Mousewheel: Zoom in and out.
     * - Wheel + Mousemove: Rotate the camera.
     *
     *
     * @param event Input event.
     */
    _input(event: MouseEvent | KeyboardEvent | WheelEvent | TouchEvent): void {
        if (event instanceof KeyboardEvent) {
            switch (event.type) {
                case "keydown":
                    if (event.key === "Shift") this.shiftPressed = true;
                    break;
                case "keyup":
                    if (event.key === "Shift") this.shiftPressed = false;

                    // on space, animate the camera
                    if (event.key === " " || event.key == "Spacebar") {
                        const newPosition = this.defaultPosition.clone();
                        const { x, y, z } = !this.reverse
                            ? newPosition.multiply(new THREE.Vector3(1, 1, -1))
                            : newPosition;
                        new JEASINGS.JEasing(this.position)
                            .to({ z, y, x }, 1000)
                            .easing(JEASINGS.Sinusoidal.In)
                            .onUpdate(() => this.lookAt(this.center))
                            .onComplete(() => {
                                this.reverse = !this.reverse;
                            })
                            .start();
                    }
                    break;
            }
        }

        if (event instanceof WheelEvent) {
            if (event.type === "wheel") {
                this.translateZ(event.deltaY * 0.001 * (this.reverse ? 1 : -1));
            }
        }

        if (event instanceof MouseEvent) {
            switch (event.type) {
                case "mousemove":
                    // hacky-ish way to rotate the camera around the `center` point
                    // what we do is translate the camera to the center (Z axis),
                    // rotate it in place around Y axis, and then translate it back
                    // by the same amount.
                    if (this.leftClickPressed) {
                        const distance = this.position.distanceTo(this.center);

                        this.translateZ(-distance);
                        this.rotateOnWorldAxis(new THREE.Vector3(0, 1, 0), event.movementX * 0.01);
                        this.translateZ(distance);
                        this.lookAt(this.center);
                    }

                    if (this.rightClickPressed) {
                        this.rotateOnWorldAxis(
                            new THREE.Vector3(0, 1, 0),
                            event.movementX * 0.001 * (this.reverse ? -1 : 1),
                        );
                    }

                    break;
                case "mousedown":
                    // mark the wheel as pressed
                    if (event.button === MOUSE.LEFT) this.leftClickPressed = true;
                    if (event.button === MOUSE.MIDDLE) this.wheelPressed = true;
                    if (event.button === MOUSE.RIGHT) this.rightClickPressed = true;
                    break;
                case "mouseup":
                    if (event.button === MOUSE.LEFT) this.leftClickPressed = false;
                    if (event.button === MOUSE.MIDDLE) this.wheelPressed = false;
                    if (event.button === MOUSE.RIGHT) this.rightClickPressed = false;
                    break;
            }
        }
    }
}
