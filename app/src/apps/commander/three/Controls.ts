// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export type ControlsEvents = {
    contextmenu: MouseEvent;
    mousedown: MouseEvent;
    click: MouseEvent;
    mouseup: MouseEvent;
    mousemove: MouseEvent;
    wheel: WheelEvent;
    touchstart: TouchEvent;
    touchend: TouchEvent;
    touchmove: TouchEvent;
    touchcancel: TouchEvent;
    keydown: KeyboardEvent;
    keyup: KeyboardEvent;
};

export class Controls extends THREE.Controls<ControlsEvents> {
    /** These events are listened on the `domElement` */
    static EVENTS: string[] = [
        "contextmenu",
        "mousedown",
        "click",
        "mouseup",
        "mousemove",
        "wheel",
        "touchstart",
        "touchend",
        "touchmove",
        "touchcancel",
    ];

    /** These events are listened on the `window` element */
    static KEYBOARD_EVENTS: string[] = ["keydown", "keyup"];

    public mouse = {
        [THREE.MOUSE.LEFT]: false,
        [THREE.MOUSE.RIGHT]: false,
        [THREE.MOUSE.MIDDLE]: false,
    };

    public keys = {
        shift: false,
        ctrl: false,
        alt: false,
        space: false,
        up: false,
        down: false,
        left: false,
        right: false,
    };

    constructor(camera: THREE.Object3D, domElement: HTMLElement) {
        super(camera, domElement);
    }

    /** Connect the controls to the dom element */
    connect(): void {
        Controls.EVENTS.forEach((eventName) => {
            (this.domElement || window).addEventListener(eventName, this._input.bind(this));
        });
    }

    /** Disconnect the controls from the dom element */
    disconnect(): void {
        Controls.EVENTS.forEach((eventName) => {
            (this.domElement || window).removeEventListener(eventName, this._input.bind(this));
        });
    }

    _input(event: Event): void {
        if (event instanceof MouseEvent) {
            switch (event.type) {
                case "mousemove":
                    // this.dispatchEvent(event as ControlsEvents["mousemove"]);
                    break;
                case "mousedown":
                    if (event.button === THREE.MOUSE.LEFT) this.mouse[THREE.MOUSE.LEFT] = true;
                    if (event.button === THREE.MOUSE.MIDDLE) this.mouse[THREE.MOUSE.MIDDLE] = true;
                    if (event.button === THREE.MOUSE.RIGHT) this.mouse[THREE.MOUSE.RIGHT] = true;
                    break;
                case "mouseup":
                    if (event.button === THREE.MOUSE.LEFT) this.mouse[THREE.MOUSE.LEFT] = false;
                    if (event.button === THREE.MOUSE.MIDDLE) this.mouse[THREE.MOUSE.MIDDLE] = false;
                    if (event.button === THREE.MOUSE.RIGHT) this.mouse[THREE.MOUSE.RIGHT] = false;
                    break;
            }
        }
        
        if (event instanceof KeyboardEvent) {
        }
        if (event instanceof WheelEvent) {
        }
        if (event instanceof TouchEvent) {
        }
        if (event instanceof PointerEvent) {
        }
    }

    update(_delta: number) {
        console.log("update");
        this.update(0.001);
    }
}
