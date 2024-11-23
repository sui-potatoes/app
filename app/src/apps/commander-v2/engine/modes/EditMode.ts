// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game, Tile } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";

/**
 * The `Edit` mode allows the user to modify the map by adding, removing or modifying
 * obstacles, cover, and empty tiles.
 */
export class EditMode implements Mode {
    pointerMesh: THREE.Mesh<THREE.BoxGeometry, THREE.MeshStandardMaterial> | null = null;

    private _cb: ((_: any) => void) | null = null;

    /** Separate listener for controls,  */
    constructor(private controls: Controls) {}

    get name() {
        return "Edit";
    }

    connect(this: Game, mode: this) {
        mode.pointerMesh = null;
        mode._cb = mode.onClick.bind(this);
        mode.controls.addEventListener("click", mode._cb);
    }

    disconnect(this: Game, mode: this): void {
        mode.pointerMesh?.geometry.dispose();
        mode.pointerMesh?.material.dispose();
        mode.pointerMesh?.clear();
        mode.pointerMesh && this.remove(mode.pointerMesh);
        mode.pointerMesh = null;
        mode.controls.removeEventListener("click", mode.onClick.bind(this));
        mode._cb !== null && mode.controls.removeEventListener("click", mode._cb);
    }

    input(this: Game, controls: Controls, mode: this) {
        const { x, y } = this.pointer;
        if (mode.pointerMesh === null) {
            mode.pointerMesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({ color: 0x00ff00 }),
            );
            mode.pointerMesh.material.transparent = true;
            mode.pointerMesh.material.opacity = 0.5;
            mode.pointerMesh.position.set(x, 0.5, y);
            this.add(mode.pointerMesh);
        } else {
            mode.pointerMesh.position.set(x, 0.5, y);
        }

        const pointer = mode.pointerMesh;

        // if obstacle, color red, if empty, color green, if cover, color blue
        if (this.grid.grid[x][y].type === "Obstacle") {
            pointer.material.color.set("red");
        } else if (this.grid.grid[x][y].type === "Empty") {
            pointer.material.color.set("green");
        } else if (this.grid.grid[x][y].type === "Cover") {
            pointer.material.color.set("blue");
        }

        if (controls.mouse[THREE.MOUSE.RIGHT]) {
            this.grid.clearCell(x, y);
        }

        if (controls.mouse[THREE.MOUSE.MIDDLE]) {
            alert("Middle click");
        }

        if (controls.mouse[THREE.MOUSE.LEFT]) {
            this.grid.setCell(x, y, {
                type: "Cover",
                UP: true,
                DOWN: false,
                LEFT: false,
                RIGHT: false,
                unit: null
            });
        }
    }

    async performAction() {}

    onClick(this: Game, { button }: { button: number; }) {
        const { x, y } = this.pointer;

        if (button === THREE.MOUSE.RIGHT) {
            return this.grid.clearCell(x, y);
        }

        if (button === THREE.MOUSE.MIDDLE) {
            const curr = this.grid.grid[x][y];
            const def: Tile = { type: "Cover", UP: false, DOWN: false, LEFT: false, RIGHT: false, unit: null };

            if (curr.type === "Cover") {
                switch (true) {
                    case curr.UP: return this.grid.setCell(x, y, { ...def, UP: false, RIGHT: true });
                    case curr.RIGHT: return this.grid.setCell(x, y, { ...def, RIGHT: false, DOWN: true });
                    case curr.DOWN: return this.grid.setCell(x, y, { ...def, DOWN: false, LEFT: true });
                    case curr.LEFT: return this.grid.setCell(x, y, { ...def, LEFT: false, UP: true });
                }
            }
        }

        if (button === THREE.MOUSE.LEFT) {
            return this.grid.setCell(x, y, {
                type: "Cover",
                UP: true,
                DOWN: false,
                LEFT: false,
                RIGHT: false,
                unit: null
            });
        }
    }
}
