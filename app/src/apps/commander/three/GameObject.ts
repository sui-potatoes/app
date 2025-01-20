// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export interface Component {
    initialize: (scene: THREE.Scene) => void;
    _ready: () => void;
    _input: (event: MouseEvent | KeyboardEvent | WheelEvent | TouchEvent) => void;
    _select: () => void;
    _deselect: () => void;
    _process: (delta: number) => void;
    _click?: (intersect: THREE.Intersection) => void;
    _hover?: (intersect: THREE.Intersection) => void;
}

/**
 * Base class for in-game objects.
 * Implements Godot-style components with a ready, input, and process method.
 */
export class GameObject<TEventMap extends THREE.Object3DEventMap>
    extends THREE.Mesh<THREE.BufferGeometry, THREE.Material | THREE.Material[], TEventMap>
    implements Component
{
    /**
     * Name of the object.
     */
    public name = "GameObject";

    /**
     * Constructor.
     * @param position Position on the grid.
     * @param geometry Geometry of the object.
     * @param material Material of the object.
     */
    constructor(geometry: THREE.BufferGeometry, material: THREE.Material | THREE.Material[]) {
        super(geometry, material);
    }

    initialize(scene: THREE.Scene) {
        scene.add(this);
    }

    _ready(): void {}

    /**
     * Called when an input event is received, such as a mouse click or key press.
     * Can be used to handle user input and update the object's state.
     */
    _input(_event: MouseEvent | KeyboardEvent | WheelEvent | TouchEvent): void {}

    /**
     * Called every frame. The `delta` parameter is the time since the last frame,
     * in milliseconds.
     *
     * @param delta Time since the last frame.
     */
    _process(_delta: number): void {}

    /**
     * Called when the object is clicked on the grid.
     */
    _select(): void {}

    /**
     * Called when the object is deselected on the grid.
     */
    _deselect(): void {}
}
