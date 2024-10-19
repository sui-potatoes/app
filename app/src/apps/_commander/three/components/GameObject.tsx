import * as THREE from "three";
import { Line2 } from 'three/addons/lines/Line2.js';
import { LineGeometry } from 'three/addons/lines/LineGeometry.js';
import { LineMaterial } from "three/examples/jsm/lines/LineMaterial.js";

interface Component {
    initialize: (scene: THREE.Scene) => void;
    _ready: () => void;
    _input: (event: any) => void;
    _process: (delta: number) => void;
    _click?: (intersect: THREE.Intersection) => void;
    _hover?: (intersect: THREE.Intersection) => void;

    // addEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | AddEventListenerOptions) => void;
    // dispatchEvent: (event: Event) => boolean;
    // removeEventListener: (type: string, listener: EventListenerOrEventListenerObject, options?: boolean | EventListenerOptions) => void;
}

/**
 * Base class for in-game objects.
 * Implements Godot-style components with a ready, input, and process method.
 */
export class GameObject extends THREE.Mesh implements Component {
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
    constructor(geometry: THREE.BufferGeometry, material: THREE.Material) {
        super(geometry, material);
    }

    initialize(scene: THREE.Scene) {
        scene.add(this);
        this._ready();
    }

    _ready(): void {}

    /**
     * Called when an input event is received, such as a mouse click or key press.
     * Can be used to handle user input and update the object's state.
     */
    _input(_event: MouseEvent | KeyboardEvent | WheelEvent): void {}

    /**
     * Called every frame. The `delta` parameter is the time since the last frame,
     * in milliseconds.
     *
     * @param delta Time since the last frame.
     */
    _process(_delta: number): void {}
}

/**
 * Implements a 2D grid in the 3D world.
 * Used to place and move objects in the game.
 */
export class Grid extends GameObject {
    /** Name of the Object. */
    public name = "Grid";

    /** Internal grid helper to render the grid. */
    protected gridHelper: THREE.GridHelper;

    /** Currently selected cell, captured via Raycasting */
    public selectedCell: THREE.Vector2 | null;

    /** Cursor plane, placed where the cursor is pointing */
    protected cursor: THREE.Group;

    /** Line that is drawn on click and traced to the cursor */
    protected pathTracer: THREE.Group;

    /** Units placed on the Grid */
    protected units: THREE.Group;

    /** Inner grid, a simple representation of  */
    protected innerGrid: (GameObject | null)[][];

    /** Construct the Grid using dimensions and divisions */
    constructor(public size: number) {
        const geometry = new THREE.PlaneGeometry( size, size );
        const material = new THREE.MeshBasicMaterial( {color: 0x000000, side: THREE.DoubleSide} );

        super(geometry, material);

        this.position.y = -0.001;
        this.position.x = Math.ceil(size / 2);
        this.position.z = Math.ceil(size / 2);
        this.rotation.x = Math.PI / 2;

        // Create the grid helper
        this.gridHelper = new THREE.GridHelper(size, size, 0xaa5555, 0xffffff);
        this.gridHelper.position.y = 0;
        this.gridHelper.position.x = Math.ceil(size / 2);
        this.gridHelper.position.z = Math.ceil(size / 2);
        this.size = size;

        // Create the cursor
        this.cursor = this.newCursor();

        // Stab values
        this.selectedCell = null;

        // Path tracer
        this.pathTracer = new THREE.Group();
        this.units = new THREE.Group();
        this.innerGrid = Array.from({ length: size }, () => Array.from({ length: size }, () => null));
    }

    get center() {
        return new THREE.Vector3(Math.ceil(this.size / 2), 0, Math.ceil(this.size / 2));
    }

    get cellOffset() {
        return this.scale.multiplyScalar(0.5);
    }

    /** Adds the plane + gridHelper to the scene */
    initialize(scene: THREE.Scene) {
        scene.add(this);
        scene.add(this.gridHelper);
        scene.add(this.cursor);
        scene.add(this.pathTracer);
        scene.add(this.units);
        this._ready();
    }

    _hover(intersect: THREE.Intersection) {
        const cell = this.gridCell(intersect.point);
        this.cursor.position.set(cell.x - 0.5, 0, cell.y - 0.5);
        this.redrawPath(this.selectedCell || cell, this.cursor.position);
    }

    /**
     * Finds the cell given the real coordinates of the intersection point.
     * @param point Intersection point of a Raycaster.
     */
    gridCell(point: THREE.Vector3) {
        return new THREE.Vector2(
            +(point.x / this.scale.x + 0.5).toFixed(0),
            +(point.z / this.scale.z + 0.5).toFixed(0),
        );
    }

    gridWorld(point: THREE.Vector2) {
        return new THREE.Vector3(point.x - 0.5, 0, point.y - 0.5);
    }

    _input(event: MouseEvent | KeyboardEvent | WheelEvent): void {
        if (event instanceof MouseEvent) {
            if (event.type === "click") {
                this.selectedCell = this.gridCell(this.cursor.position);
            }

            // on right click, clear the path tracer
            if (event.type === "contextmenu") {
                this.selectedCell = null;
                this.pathTracer.clear();
                event.preventDefault();
            }
        }
    }

    add(..._objects: THREE.Object3D[]): this {
        throw new Error("Method not implemented. Use `addGameObject` instead.");
    }

    addGameObject(gameObject: GameObject, position: THREE.Vector2) {
        if (position.x < 0 || position.x >= this.size || position.y < 0 || position.y >= this.size) {
            throw new Error("Position out of bounds");
        }

        gameObject.position.set(position.x + 0.5, 0.5, position.y + 0.5);
        gameObject.scale.set(0.9, 0.9, 0.9);
        this.units.add(gameObject);
    }

    removeGameObject(position: THREE.Vector2): GameObject | null {
        const gameObject = this.innerGrid[position.x][position.y];
        this.innerGrid[position.x][position.y] = null;
        if (gameObject) {
            this.units.remove(gameObject);
        }

        return gameObject
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
            return
        }

        const start = new THREE.Vector3(from.x - 0.5, 0.1, from.y - 0.5);
        const end = new THREE.Vector3(to.x, 0.1, to.z);

        const mid = new THREE.Vector3().addVectors(start, end).multiplyScalar(0.5).add(new THREE.Vector3(0, 3, 0));
        const curve = new THREE.QuadraticBezierCurve3(start, mid, end);
        const points = curve.getPoints(50);

        const geometry = new THREE.BufferGeometry().setFromPoints(points);
        const material = new THREE.LineBasicMaterial({ color: 0xff3333, colorWrite: true, linewidth: 20 });
        const line = new THREE.Line(geometry, material);

        const line2 = new LineGeometry();
        line2.fromLine(line);

        this.pathTracer.clear();
        this.pathTracer.add(new Line2(line2, new LineMaterial({ color: 0xff3333, linewidth: 4, fog: true })));
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
            new THREE.MeshStandardMaterial({ side: THREE.DoubleSide }),
        );
        plane.name = "Cursor";
        plane.receiveShadow = true;
        plane.rotation.x = Math.PI / 2;
        plane.receiveShadow = true;

        const light = new THREE.DirectionalLight(0x2222aa, 0);
        light.position.set(0, 20, 0);
        light.target = plane;
        light.castShadow = true;

        const group = new THREE.Group();
        group.add(plane);
        group.add(light);
        return group;
    }

    private gridToWorld(position: THREE.Vector2) {
        return new THREE.Vector3(position.x - 0.5, 0, position.y - 0.5);
    }
}

/**
 * A camera that can be controlled by the player.
 */
export class ControllableCamera extends THREE.PerspectiveCamera implements Component {
    protected shiftPressed = false;
    protected wheelPressed = false;

    constructor(aspect: number) {
        super(45, aspect, 1, 5000);

        this.position.z = 10;
        this.position.y = 10;
        // this.lookAt(0, 0, 0);
    }

    initialize(scene: THREE.Scene) {
        scene.add(this);
        this._ready();
    }

    _ready(): void {}
    _process(_delta: number): void {}

    _input(event: MouseEvent | KeyboardEvent | WheelEvent): void {
        if (event instanceof KeyboardEvent) {
            switch (event.type) {
                case "keydown":
                    if (event.key === "Shift") this.shiftPressed = true;
                    break;
                case "keyup":
                    if (event.key === "Shift") this.shiftPressed = false;
                    break;
            }
        }

        if (event instanceof WheelEvent) {
            if (event.type === "wheel") {
                this.position.z += event.deltaY * 0.01 * (this.shiftPressed ? 1 : 0.1);
            }
        }

        if (event instanceof MouseEvent) {
            switch (event.type) {
                case "mousemove":
                    if (this.wheelPressed) {
                        this.rotation.x += event.movementY * 0.001;
                    }
                    break;
                case "mousedown":
                    // mark the wheel as pressed
                    if (event.button === 1) this.wheelPressed = true;
                    break;
                case "mouseup":
                    if (event.button === 1) this.wheelPressed = false;
                    break;
                case "mousemove":
                    if (this.wheelPressed) {
                        this.rotation.y += event.movementX * 0.01;
                        this.rotation.x += event.movementY * 0.01;
                    }
                    break;
            }
        }
    }
}

export class Crate extends GameObject {
    constructor() {
        const geometry = new THREE.BoxGeometry(1, 1, 1);
        const texture = new THREE.TextureLoader().load("/images/unit-barricade.png");
        const material = new THREE.MeshStandardMaterial({ color: 0xaaaaaa, map: texture });

        super(geometry, material);
        this.receiveShadow = true;
    }
}

export class Unit extends GameObject {
    constructor(texture?: string) {
        let map;
        if (texture) {
            map = new THREE.TextureLoader().load(texture);
        }

        const geometry = new THREE.BoxGeometry(1, 1, 1);
        const material = new THREE.MeshStandardMaterial({ color: 0xaaaaaa, map });

        super(geometry, material);
        this.receiveShadow = true;
    }
}

// function gridTracePath(grid: Grid, from: THREE.Vector2, to: THREE.Vector2) {
