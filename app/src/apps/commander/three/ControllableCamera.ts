// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Component } from "./GameObject";
import JEASINGS from "jeasings";

const CLOSEUP = new THREE.Vector3(-0.2, -0.2, -0.3);

/**
 * A camera that can be controlled by the player.
 */
export class ControllableCamera extends THREE.PerspectiveCamera implements Component {
    protected shiftPressed = false;
    protected wheelPressed = false;
    protected reverse: boolean = false;

    constructor(aspect: number) {
        super(45, aspect, 1, 5000);

        this.position.z = 10;
        this.position.y = 10;
    }

    initialize(scene: THREE.Scene) {
        scene.add(this);
        this._ready();
    }

    _ready(): void {}
    _select(): void {}
    _deselect(): void {}
    _process(_delta: number): void {}

    async moveToUnit(point: THREE.Vector2, lookAt: THREE.Vector2) {
        return new Promise((resolve) => {
            new JEASINGS.JEasing(this.position)
                .to({ x: point.x, y: 1, z: point.y }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(new THREE.Vector3(lookAt.x, 1, lookAt.y)))
                .start()
                .onComplete(() => {
                    console.log(this.getWorldDirection(new THREE.Vector3()));
                    this.translateX(CLOSEUP.x);
                    resolve(null);
                });
        });
    }

    async moveBack() {
        return new Promise((resolve) => {
            const { x, y, z } = !this.reverse
                ? new THREE.Vector3(5, 10, 5)
                : new THREE.Vector3(5, 10, -8);

            new JEASINGS.JEasing(this.position)
                .to({ x, y, z }, 1000)
                .easing(JEASINGS.Sinusoidal.In)
                .onUpdate(() => this.lookAt(new THREE.Vector3(5, 0, 5)))
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
    _input(event: MouseEvent | KeyboardEvent | WheelEvent): void {
        if (event instanceof KeyboardEvent) {
            switch (event.type) {
                case "keydown":
                    if (event.key === "Shift") this.shiftPressed = true;
                    break;
                case "keyup":
                    if (event.key === "Shift") this.shiftPressed = false;

                    // on space, animate the camera
                    if (event.key === " " || event.key == "Spacebar") {
                        new JEASINGS.JEasing(this.position)
                            .to({ z: this.reverse ? 15 : -8 }, 1000)
                            .easing(JEASINGS.Sinusoidal.In)
                            .onUpdate(() => this.lookAt(5, 0, 5))
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
                this.position.z += event.deltaY * 0.001 * (this.reverse ? 1 : -1);
            }
        }

        if (event instanceof MouseEvent) {
            switch (event.type) {
                case "mousemove":
                    if (this.wheelPressed) {
                        this.rotation.x += event.movementY * 0.001 * (this.reverse ? -1 : 1);
                    }
                    break;
                case "mousedown":
                    // mark the wheel as pressed
                    if (event.button === 1) this.wheelPressed = true;
                    break;
                case "mouseup":
                    if (event.button === 1) this.wheelPressed = false;
                    break;
            }
        }
    }
}
