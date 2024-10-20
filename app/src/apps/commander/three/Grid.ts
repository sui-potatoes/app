// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { GameObject } from "./GameObject";
import { Line2 } from "three/addons/lines/Line2.js";
import { LineGeometry } from "three/addons/lines/LineGeometry.js";
import { LineMaterial } from "three/addons/lines/LineMaterial.js";
import JEASINGS from "jeasings";
import { AnimatedUnit } from "./AnimatedUnit";

export interface GridEvents extends THREE.Object3DEventMap {
    selectCell: { point: THREE.Vector2 };
    deselectCell: {};
    pointCell: { point: THREE.Vector2 };
    moveObject: { from: THREE.Vector2; to: THREE.Vector2 };

    moveObjectStart: { from: THREE.Vector2; to: THREE.Vector2; id: string };
    moveObjectEnd: { id: string };
}

/**
 * Scale of models in the game. Each is expected to be 1x1x1.
 */
const SCALE = 1;
/**
 * Offset of the model in the grid. Used to center the model in the grid.
 */
const OFFSET = SCALE / 2;

/**
 * The time it takes to move from one cell to another.
 */
const CELL_TRANSITION = 500;

/**
 * Implements a 2D grid in the 3D world.
 * Used to place and move objects in the game.
 */
export class Grid extends GameObject<GridEvents> {
    /** Name of the Object. */
    public name = "Grid";

    /** Whether the selected object should look at the cursor. */
    protected followCursor = false;

    /** Internal grid helper to render the grid. */
    protected gridHelper: THREE.GridHelper;

    /** Currently selected cell, captured via Raycasting */
    public selectedCell: THREE.Vector2 | null;

    /** Currently selected object */
    public selectedObject: GameObject<any> | null;

    /** Cursor plane, placed where the cursor is pointing */
    protected cursor: THREE.Group;

    /** Line that is drawn on click and traced to the cursor */
    protected pathTracer: THREE.Group;

    /** Units placed on the Grid */
    protected units: THREE.Group;

    /** Inner grid, a simple representation of  */
    protected innerGrid: (GameObject<any> | null)[][];

    /** Highlighted cells as planes. The `d` parameter marks the intensity of the colour */
    protected highlight: THREE.Group;

    /** Construct the Grid using dimensions and divisions */
    constructor(public width: number, public height: number) {
        const geometry = new THREE.PlaneGeometry(width, height);
        const material = new THREE.MeshBasicMaterial({ color: 0x000000, side: THREE.DoubleSide });

        super(geometry, material);

        this.position.y = -0.001;
        this.position.x = Math.ceil(width / 2) - 1;
        this.position.z = Math.ceil(height / 2) - 1;
        this.rotation.x = Math.PI / 2;

        // Create the grid helper
        this.gridHelper = new THREE.GridHelper(Math.max(width, height), Math.max(width, height), 0xaa5555, 0xffffff);
        this.gridHelper.position.y = 0;
        this.gridHelper.position.x = Math.ceil(width / 2) - 1;
        this.gridHelper.position.z = Math.ceil(height / 2) - 1;

        // Create the cursor
        this.cursor = this.newCursor();

        // Stab values
        this.selectedCell = null;
        this.selectedObject = null;

        // Path tracer
        this.pathTracer = new THREE.Group();
        this.highlight = new THREE.Group();
        this.units = new THREE.Group();
        this.innerGrid = Array.from({ length: width }, () =>
            Array.from({ length: height }, () => null),
        );
    }

    get center() {
        return new THREE.Vector3(Math.ceil(this.width / 2), 0, Math.ceil(this.height / 2));
    }

    get cellOffset() {
        return this.scale.multiplyScalar(OFFSET);
    }

    /** Adds the plane + gridHelper to the scene */
    initialize(scene: THREE.Scene) {
        scene.add(this);
        // scene.add(this.gridHelper);
        scene.add(this.cursor);
        scene.add(this.pathTracer);
        scene.add(this.units);
        scene.add(this.highlight);
        this._ready();
    }

    highlightCells(cells: { x: number; y: number; d: number }[]) {
        this.highlight.clear();

        // add planes for each cell
        for (let { x, y, d } of cells) {
            const plane = new THREE.Mesh(
                new THREE.PlaneGeometry(1, 1),
                new THREE.MeshBasicMaterial({
                    color: 0xaa0000,
                    side: THREE.DoubleSide,
                    transparent: true,
                    opacity: 1 / (d + 1),
                }),
            );

            plane.rotation.x = Math.PI / 2;
            plane.position.set(x - OFFSET, 0.01, y - OFFSET);
            this.highlight.add(plane);
        }
    }

    /**
     * Moves an object from one cell to another. If object in `from` is
     * `AnimatedUnit`, call its `followPath` method.
     */
    async unitFollowPath(from: THREE.Vector2, path: THREE.Vector2[]) {
        const object = this.innerGrid[from.x][from.y];

        if (object === null || path.length == 0) return;
        if (object instanceof AnimatedUnit) {
            object.movement.start();
        }

        this.selectedCell = null;

        // move the object to the first point
        const transitions = path.map((point) => {
            let hasTurned = false;
            const easing = new JEASINGS.JEasing(object.position).to(
                { x: point.x - OFFSET, z: point.y - OFFSET },
                CELL_TRANSITION,
            );

            return {
                promise: new Promise<void>((resolve) => {
                    easing
                        .onUpdate(() => {
                            if (!hasTurned) {
                                object.lookAt(this.gridWorld(point));
                                hasTurned = true;
                            }
                        })
                        .onComplete(() => resolve());
                }),
                start: () => easing.start(),
            };
        });

        return transitions
            .reduce(async (prev, current) => {
                await prev;
                current.start();
                return current.promise;
            }, Promise.resolve())
            .then(() => {
                if (object instanceof AnimatedUnit) {
                    object.movement.stop();
                }

                this.selectCell(path[path.length - 1]);
            });
    }

    async unitPerformRangedAttack(from: THREE.Vector2, to: THREE.Vector2) {
        const object = this.innerGrid[from.x][from.y];
        const target = this.innerGrid[to.x][to.y];

        if (object === null || target === null) return;
        if (object instanceof AnimatedUnit) {
            object.lookAt(this.gridWorld(to));
            target.lookAt(this.gridWorld(from));
            return Promise.all([
                object.attack.prepare(),
                target instanceof AnimatedUnit && target.attack.receive()
            ]);
        }
    }

    async unitDeath(at: THREE.Vector2) {
        const object = this.innerGrid[at.x][at.y];

        if (object === null) return;
        if (object instanceof AnimatedUnit) {
            await object.attack.death();
        }

        this.removeGameObject(at);
    }

    /**
     * Finds the cell given the real coordinates of the intersection point.
     * @param point Intersection point of a Raycaster.
     */
    gridCell(point: THREE.Vector3) {
        const x = +(point.x / this.scale.x + OFFSET).toFixed(0);
        const y = +(point.z / this.scale.z + OFFSET).toFixed(0);

        return new THREE.Vector2(
            Math.max(0, Math.min(this.width - 1, x)),
            Math.max(0, Math.min(this.height - 1, y)),
        );
    }

    gridWorld(point: THREE.Vector2) {
        return new THREE.Vector3(point.x - OFFSET, 0, point.y - OFFSET);
    }

    _hover(intersect: THREE.Intersection) {
        const cell = this.gridCell(intersect.point);
        this.cursor.position.set(cell.x - OFFSET, 0, cell.y - OFFSET);
        this.redrawPath(this.selectedCell || cell, this.cursor.position);
    }

    _process(delta: number): void {
        // proxy process events to the cursor and to units
        this.cursor.children.forEach(
            (child) => child instanceof GameObject && child._process(delta),
        );
        this.units.children.forEach(
            (child) => child instanceof GameObject && child._process(delta),
        );
    }

    _input(event: MouseEvent | KeyboardEvent | WheelEvent): void {
        // proxy input events to the cursor and to units
        this.cursor.children.forEach((child) => child instanceof GameObject && child._input(event));
        this.units.children.forEach((child) => child instanceof GameObject && child._input(event));

        if (event instanceof MouseEvent) {
            event.preventDefault();

            if (event.type === "click") {
                const cell = this.gridCell(this.cursor.position);
                this.selectCell(cell);
                return;
            }

            // on right click, clear the path tracer
            if (event.type === "contextmenu") {
                this.dispatchEvent({
                    type: "pointCell",
                    point: this.gridCell(this.cursor.position),
                });

                // this.deselectCell();
                this.pathTracer.clear();
            }
        }
    }

    add(..._objects: THREE.Object3D[]): this {
        throw new Error("Method not implemented. Use `addGameObject` instead.");
    }

    addGameObject<TEventMap extends THREE.Object3DEventMap>(
        gameObject: GameObject<TEventMap>,
        position: THREE.Vector2,
    ) {
        if (
            position.x < 0 ||
            position.x >= this.width ||
            position.y < 0 ||
            position.y >= this.height
        ) {
            throw new Error("Position out of bounds");
        }

        gameObject.position.set(position.x - OFFSET, 0.0, position.y - OFFSET);
        gameObject.scale.set(0.9, 0.9, 0.9);
        this.units.add(gameObject);
        this.innerGrid[position.x][position.y] = gameObject;
    }

    removeGameObject<TEventMap extends THREE.Object3DEventMap>(
        position: THREE.Vector2,
    ): GameObject<TEventMap> | null {
        const gameObject = this.innerGrid[position.x][position.y];
        this.innerGrid[position.x][position.y] = null;
        if (gameObject) {
            this.units.remove(gameObject);
        }

        return gameObject;
    }

    private deselectCell() {
        if (this.selectedCell === null) {
            return;
        }

        const selectedObject = this.innerGrid[this.selectedCell.x][this.selectedCell.y];

        // call `_deselect` on the object in the cell if it exists
        if (selectedObject !== null) {
            selectedObject._deselect();
        }

        // reset the selected cell and dispatch the event
        this.selectedCell = null;
        this.selectedObject = null;
        this.dispatchEvent({ type: "deselectCell" });
        this.highlight.clear();
    }

    private selectCell(point: THREE.Vector2) {
        this.deselectCell();
        this.selectedCell = point;
        this.dispatchEvent({ type: "selectCell", point: this.selectedCell });

        const selectedObject = this.innerGrid[point.x][point.y];

        if (selectedObject !== null) {
            selectedObject._select();
            this.selectedObject = selectedObject;
        }
    }

    /**
     * Draw a bezier curve from the selected cell to the cursor. Midpoint is the
     * average of the two points.
     *
     * @param from
     * @param to
     */
    private redrawPath(from: THREE.Vector2, to: THREE.Vector3) {
        if (!this.selectedCell) {
            this.pathTracer.clear();
            return;
        }

        // don't turn units when moving cursor
        if (this.selectedObject) {
            // this.selectedObject.lookAt(to);
        }

        const start = new THREE.Vector3(from.x - OFFSET, 0.1, from.y - OFFSET);
        const end = new THREE.Vector3(to.x, 0.1, to.z);

        const mid = new THREE.Vector3()
            .addVectors(start, end)
            .multiplyScalar(OFFSET)
            .add(new THREE.Vector3(0, 3, 0));

        const curve = new THREE.QuadraticBezierCurve3(start, mid, end);
        const points = curve.getPoints(50);

        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        const material = new THREE.LineBasicMaterial({
            color: 0xff3333,
            colorWrite: true,
            linewidth: 20,
        });

        const line2 = new LineGeometry().fromLine(new THREE.Line(geometry, material));

        this.pathTracer.clear();
        this.pathTracer.add(
            new Line2(line2, new LineMaterial({ color: 0xff3333, linewidth: 4, fog: true })),
        );
    }

    /**
     * Separated for visibilty: creates the cursor plane with directional light
     * pointing at it.
     *
     * @returns Cursor plane with light.
     */
    private newCursor(): THREE.Group {
        const plane = new THREE.Mesh(
            new THREE.PlaneGeometry(1, 1),
            new THREE.MeshStandardMaterial({ side: THREE.DoubleSide, color: 0xaa000000 }),
        );
        plane.name = "Cursor";
        plane.receiveShadow = true;
        plane.rotation.x = Math.PI / 2;
        plane.receiveShadow = true;

        const light = new THREE.DirectionalLight(0x111111, 0);
        light.position.set(0, 20, 0);
        light.target = plane;
        light.castShadow = true;

        const gridHelper = new THREE.GridHelper(3, 3, 0x555555, 0x555555);

        const group = new THREE.Group();
        group.add(gridHelper);
        group.add(plane);
        group.add(light);
        return group;
    }
}
