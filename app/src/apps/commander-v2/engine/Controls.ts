// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./Game";

export type ControlsEvents = {
    zoom: { delta: number };
    keyup: { key: string; altKey: boolean };
    scroll: { delta: number };
    click: { x: number; y: number; button: number };
};

export interface Pointer {
    x: number;
    y: number;
}

export class Controls extends THREE.Controls<ControlsEvents> {
    private pointer: THREE.Vector2;
    private _inputCb: any;

    /** Mouse buttons state. */
    public readonly mouse = {
        [THREE.MOUSE.LEFT]: false,
        [THREE.MOUSE.RIGHT]: false,
        [THREE.MOUSE.MIDDLE]: false,
    };

    public readonly arrows = {
        UP: false,
        DOWN: false,
        LEFT: false,
        RIGHT: false,
    };

    public readonly pointers: { [key: number]: PointerEvent } = {};

    constructor(object: Game, domElement: HTMLElement) {
        super(object, domElement);

        this.pointer = new THREE.Vector2();
        this._inputCb = this._input.bind(this);
    }

    connect(): void {
        this.domElement?.addEventListener("click", this._inputCb, false);
        this.domElement?.addEventListener("touchstart", this._inputCb, false);
        this.domElement?.addEventListener("wheel", this._inputCb, false);
        this.domElement?.addEventListener("mousedown", this._inputCb, false);
        this.domElement?.addEventListener("mouseup", this._inputCb, false);
        this.domElement?.addEventListener("contextmenu", this._inputCb, false);

        this.domElement?.addEventListener("pointerdown", this._inputCb, false);
        this.domElement?.addEventListener("pointerup", this._inputCb, false);
        this.domElement?.addEventListener("pointermove", this._inputCb, false);

        window.addEventListener("keydown", this._inputCb, false);
        window.addEventListener("keyup", this._inputCb, false);
    }

    disconnect(): void {
        this.domElement?.removeEventListener("click", this._inputCb, false);
        this.domElement?.removeEventListener("touchstart", this._inputCb, false);
        this.domElement?.removeEventListener("wheel", this._inputCb, false);
        this.domElement?.removeEventListener("mousedown", this._inputCb, false);
        this.domElement?.removeEventListener("mouseup", this._inputCb, false);
        this.domElement?.removeEventListener("contextmenu", this._inputCb, false);

        this.domElement?.removeEventListener("pointerdown", this._inputCb, false);
        this.domElement?.removeEventListener("pointerup", this._inputCb, false);
        this.domElement?.removeEventListener("pointermove", this._inputCb, false);

        window.removeEventListener("keydown", this._inputCb, false);
        window.removeEventListener("keyup", this._inputCb, false);
    }

    update(_d: number) {}

    _input(event: MouseEvent | KeyboardEvent | WheelEvent | TouchEvent | PointerEvent): void {
        if (event.type === "pointermove" && event instanceof MouseEvent) {
            this.pointer.x = (event.clientX / window.innerWidth) * 2 - 1;
            this.pointer.y = -(event.clientY / window.innerHeight) * 2 + 1;
        }

        if (event.type === "touchstart") {
            event.preventDefault();
        }

        // pinch zoom
        if (event instanceof WheelEvent && event.type === "wheel") {
            event.preventDefault();

            let hasDecimals = event.deltaY % 1 !== 0;
            if (hasDecimals) {
                this.dispatchEvent({ type: "zoom", delta: event.deltaY });
            } else {
                this.dispatchEvent({ type: "scroll", delta: event.deltaY });
            }
        }

        if (event.type === "contextmenu") {
            event.preventDefault();
            this.mouse[THREE.MOUSE.RIGHT] = true;
        }

        if (event.type === "keydown" && event instanceof KeyboardEvent) {
            switch (event.key) {
                case "ArrowUp":
                    this.arrows.UP = true;
                    break;
                case "ArrowDown":
                    this.arrows.DOWN = true;
                    break;
                case "ArrowLeft":
                    this.arrows.LEFT = true;
                    break;
                case "ArrowRight":
                    this.arrows.RIGHT = true;
                    break;
            }
        }

        if (event.type === "keyup" && event instanceof KeyboardEvent) {
            switch (event.key) {
                case "ArrowUp":
                    this.arrows.UP = false;
                    break;
                case "ArrowDown":
                    this.arrows.DOWN = false;
                    break;
                case "ArrowLeft":
                    this.arrows.LEFT = false;
                    break;
                case "ArrowRight":
                    this.arrows.RIGHT = false;
                    break;
            }

            this.dispatchEvent({
                type: "keyup",
                key: event.key,
                altKey: event.altKey,
            });
        }

        if (event instanceof PointerEvent) {
            event.preventDefault();

            if (event.type === "pointerup") {
                delete this.pointers[event.pointerId];

                if (event.pointerType === "touch") {
                    this.dispatchEvent({
                        type: "click",
                        x: this.pointer.x,
                        y: this.pointer.y,
                        button: event.button,
                    });
                }

                if (event.pointerType === "mouse") {
                    this.mouse[event.button as 0 | 1 | 2] = false;

                    this.dispatchEvent({
                        type: "click",
                        x: this.pointer.x,
                        y: this.pointer.y,
                        button: event.button,
                    });
                } else {
                    this.mouse[THREE.MOUSE.LEFT] = false;
                }
            }

            if (event.type === "pointerdown") {
                this.pointers[event.pointerId] = event;

                if (event.pointerType === "mouse") {
                    this.mouse[event.button as 0 | 1 | 2] = true;
                } else {
                    this.mouse[THREE.MOUSE.LEFT] = true;
                }
            }

            if (event.type === "pointermove") {
                // pinch zoom
                // TODO: somehow resolve a conflict with the rotation
                if (Object.keys(this.pointers).length == 2 && event.pointerType === "touch") {
                    let other = Object.values(this.pointers).find(
                        (p) => p.pointerId !== event.pointerId,
                    )!;
                    let old = this.pointers[event.pointerId];

                    let oldX = old.clientX - other.clientX;
                    let oldY = old.clientY - other.clientY;
                    let oldDistance = Math.sqrt(oldX * oldX + oldY * oldY);

                    let newX = event.clientX - other.clientX;
                    let newY = event.clientY - other.clientY;
                    let newDistance = Math.sqrt(newX * newX + newY * newY);

                    // if (oldDistance > newDistance) {
                    this.dispatchEvent({ type: "zoom", delta: oldDistance - newDistance });
                }

                // rotation and pan
                if (Object.keys(this.pointers).length == 2) {
                }

                this.pointers[event.pointerId] = event;
            }
        }
    }
}
