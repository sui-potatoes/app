// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game, Tile } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";

/**
 * The `Edit` mode allows the user to modify the map by adding, removing or modifying
 * obstacles, cover, and empty tiles.
 *
 * Edit mode cannot be used in the game.
 * There will be a special mode for editing the map.
 */
export class EditMode extends Mode {
    pointerMesh: THREE.Mesh<THREE.BoxGeometry, THREE.MeshStandardMaterial> | null = null;

    public readonly name = "Edit";
    private _cb: ((_: any) => void) | null = null;

    /** Separate listener for controls */
    constructor(private controls: Controls) {
        super();
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
            mode.pointerMesh.position.set(x, 0.5, -y);
            this.add(mode.pointerMesh);
        } else {
            mode.pointerMesh.position.set(x, 0.5, -y);
        }

        const pointer = mode.pointerMesh;

        // if obstacle, color red, if empty, color green, if cover, color blue
        if (this.grid.grid[x][y].type === "Unwalkable") {
            pointer.material.color.set("red");
        } else if (this.grid.grid[x][y].type === "Empty") {
            pointer.material.color.set("green");
        } else if (this.grid.grid[x][y].type === "Cover") {
            pointer.material.color.set("blue");
        }

        if (controls.mouse[THREE.MOUSE.RIGHT]) {
            this.grid.clearCell(x, y);
        }

        if (controls.mouse[THREE.MOUSE.LEFT]) {
            this.grid.setCell(x, y, {
                type: "Cover",
                up: 1,
                down: 0,
                left: 0,
                right: 0,
                unit: null,
            });
        }
    }

    onClick(this: Game, { button }: { button: number }) {
        const { x, y } = this.pointer;

        if (button === THREE.MOUSE.RIGHT) {
            return this.grid.clearCell(x, y);
        }

        if (button === THREE.MOUSE.MIDDLE) {
            const curr = this.grid.grid[x][y];
            const def: Tile = {
                type: "Cover",
                up: 0,
                down: 0,
                left: 0,
                right: 0,
                unit: null,
            };

            if (curr.type === "Cover") {
                switch (true) {
                    case curr.up > 0:
                        return this.grid.setCell(x, y, { ...def, up: 0, right: 1 });
                    case curr.right > 0:
                        return this.grid.setCell(x, y, { ...def, right: 0, down: 1 });
                    case curr.down > 0:
                        return this.grid.setCell(x, y, { ...def, down: 0, left: 1 });
                    case curr.left > 0:
                        return this.grid.setCell(x, y, { ...def, left: 0, up: 1 });
                }
            }
        }

        if (button === THREE.MOUSE.LEFT) {
            return this.grid.setCell(x, y, {
                type: "Cover",
                up: 1,
                down: 0,
                left: 0,
                right: 0,
                unit: null,
            });
        }
    }
}
