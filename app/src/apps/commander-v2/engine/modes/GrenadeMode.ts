// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Mode } from "./Mode";
import { Game } from "../Game";
import { Controls } from "../Controls";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import { MoveMode } from "./MoveMode";

export class GrenadeMode extends Mode {
    /** Click callback  */
    private _clickCb = ({}: { button: number }) => {};

    /** Target, where grenade can be thrown */
    private targetTile: THREE.Vector2 | null = null;

    public readonly elements = new THREE.Group();

    constructor(private controls: Controls) {
        super();
    }

    connect(this: Game, mode: this): void {
        mode._clickCb = mode.onClick.bind(this);
        mode.controls.addEventListener("click", mode._clickCb);
        this.add(mode.elements);
    }

    disconnect(this: Game, mode: this): void {
        mode.controls.removeEventListener("click", mode._clickCb);
        mode.targetTile = null;
        mode.elements.clear();
        this.remove(mode.elements);
    }

    input(this: Game, _controls: any, _mode: this): void {
        return;
    }

    get name(): string {
        return "Grenade";
    }

    onClick(this: Game, event: { button: number }) {
        if (!this.selectedUnit) return;
        const mode = this.mode as GrenadeMode;

        // left click to select target tile
        if (event.button == THREE.MOUSE.LEFT) {
            mode.targetTile = this.pointer.clone();
            mode.drawBlastArea.call(this, mode.targetTile);
        }

        if (event.button == THREE.MOUSE.RIGHT) {
            this.switchMode(new MoveMode((this.mode as GrenadeMode).controls));
        }
    }

    drawBlastArea(this: Game, tile: THREE.Vector2) {
        if (!this.selectedUnit) return;

        const mode = this.mode as GrenadeMode;
        const radius = 2;
        const { x, y } = tile;

        mode.elements.clear();

        const tiles = this.grid.radiusTiles([x, y], radius);
        for (const [x, y] of tiles) {
            const mesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({
                    color: 0x000000,
                    transparent: true,
                    opacity: 0.5,
                }),
            );
            mesh.position.set(x, 0, y);
            mode.elements.add(mesh);
        }

        const mesh = new THREE.Mesh(
            new THREE.SphereGeometry(radius - 0.25),
            new THREE.MeshStandardMaterial({
                color: 0xff0000,
                transparent: true,
                opacity: 0.3,
            }),
        );
        mesh.position.set(x, 0, y);
        mode.elements.add(mesh);
        mode.drawThrowCurve.call(this, tile);
    }

    drawThrowCurve(this: Game, to: THREE.Vector2) {
        if (!this.selectedUnit) return;

        const { x: x0, y: z0 } = this.selectedUnit.gridPosition;
        const { x: x1, y: z1 } = to;

        const start = new THREE.Vector3(x0, 0.1, z0);
        const end = new THREE.Vector3(x1, 0.1, z1);

        const mid = new THREE.Vector3()
            .addVectors(start, end)
            .multiplyScalar(0.5)
            .add(new THREE.Vector3(0, 4, 0));

        const curve = new THREE.QuadraticBezierCurve3(start, mid, end);
        const points = curve.getPoints(50);

        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        const material = new THREE.LineBasicMaterial({
            color: 0xff3333,
            colorWrite: true,
            linewidth: 20,
        });

        const line2 = new LineGeometry().fromLine(new THREE.Line(geometry, material));
        const mode = this.mode as GrenadeMode;

        mode.elements.add(new Line2(line2, new LineMaterial({ color: 0xff3333, linewidth: 4, fog: true })));
    }
}
