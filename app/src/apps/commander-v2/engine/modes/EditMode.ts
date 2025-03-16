// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game, Tile } from "./../Game";
import { Controls } from "./../Controls";
import { Mode } from "./Mode";

export type EditModeEvents = {
    editor: {
        message: string;
        tool: "Cover" | "High Cover" | "Object" | "Unwalkable";
        direction: "up" | "down" | "left" | "right";
    };
};

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
    public coverDirection: "up" | "down" | "left" | "right" = "up";
    public tool: "Cover" | "High Cover" | "Object" | "Unwalkable" = "Cover";
    private _clickCb: ((_: any) => void) | null = null;
    private _keyupCb: ((_: any) => void) | null = null;

    /** Separate listener for controls */
    constructor(private controls: Controls) {
        super();
    }

    connect(this: Game, mode: this) {
        mode.pointerMesh = null;
        mode._clickCb = mode.onClick.bind(this);
        mode._keyupCb = mode.onKeyup.bind(this);
        mode.controls.addEventListener("click", mode._clickCb);
        mode.controls.addEventListener("keyup", mode._keyupCb);
    }

    disconnect(this: Game, mode: this): void {
        mode.pointerMesh?.geometry.dispose();
        mode.pointerMesh?.material.dispose();
        mode.pointerMesh?.clear();
        mode.pointerMesh && this.remove(mode.pointerMesh);
        mode.pointerMesh = null;
        mode.controls.removeEventListener("click", mode.onClick.bind(this));
        mode._clickCb !== null && mode.controls.removeEventListener("click", mode._clickCb);
    }

    input(this: Game, controls: Controls, mode: this) {
        const { x, y } = this.pointer;
        if (mode.pointerMesh === null) {
            mode.pointerMesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({ color: 0x00ff00 }),
            );
            const light = new THREE.PointLight(0xffffff, 5, 100);
            light.position.set(0, 3, 0);
            mode.pointerMesh.add(light);
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
    }

    onClick(this: Game, { button }: { button: number }) {
        const { x, y } = this.pointer;
        const mode = this.mode as EditMode;

        if (button === THREE.MOUSE.RIGHT) {
            this.tryDispatch({
                type: "editor",
                message: `clear cell at (${x},${y})`,
            })
            return this.grid.clearCell(x, y);
        }

        if (button === THREE.MOUSE.LEFT) {
            if (mode.tool === "Object") {
                return this.grid.setCell(x, y, { type: "Unwalkable", unit: null });
            }

            if (mode.tool === "Cover" || mode.tool === "High Cover") {
                const curr = this.grid.grid[x][y];
                const def: Tile = {
                    type: "Cover",
                    up: 0,
                    down: 0,
                    left: 0,
                    right: 0,
                    unit: null,
                };

                const value = mode.tool === "Cover" ? 1 : 2;

                if (curr.type === "Cover") {
                    return this.grid.setCell(x, y, { ...curr, [mode.coverDirection]: value });
                } else {
                    return this.grid.setCell(x, y, { ...def, ...{ [mode.coverDirection]: value } });
                }
            }
        }
    }

    onKeyup(this: Game, { key }: { key: string }) {
        const mode = this.mode as EditMode;

        switch (key) {

            // === Tool Selection ===
            case "c":
                mode.tool = "Cover";
                break;
            case "h":
                mode.tool = "High Cover";
                break;
            case "o":
                mode.tool = "Object";
                break;
            case "u":
                mode.tool = "Unwalkable";
                break;

            // === Directional keys ===
            case "w":
                mode.coverDirection = "up";
                break;
            case "a":
                mode.coverDirection = "left";
                break;
            case "s":
                mode.coverDirection = "down";
                break;
            case "d":
                mode.coverDirection = "right";
                break;
        }

        this.tryDispatch({
            type: "editor",
            message: `tool change: ${mode.tool}; direction: ${mode.coverDirection}`,
            tool: mode.tool,
            direction: mode.coverDirection,
        });

        console.log((this.mode as EditMode).coverDirection)
    }
}
