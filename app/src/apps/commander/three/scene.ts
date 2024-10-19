// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { ControllableCamera } from "./ControllableCamera";
import { GameObject } from "./GameObject";
import { Grid } from "./Grid";
import JEASINGS from "jeasings";

/**
 * Sets up the ThreeJS environment, scene, camera, and grid.
 *
 * @param element
 * @returns
 */
export function newScene(
    element: string,
): { scene: THREE.Scene; camera: ControllableCamera; grid: Grid } | null {
    // get the root element, skip if it already has children (i.e. ThreeJS is already running)
    const root = document.getElementById(element);
    if (!root || root.childNodes.length > 0) {
        return null;
    }

    console.log("Setting up ThreeJS scene");

    // set up the scene
    const width = 1024;
    const height = 768;

    // create scene
    const scene = new THREE.Scene();
    const grid = new Grid(10); // And first there was a grid
    const camera = new ControllableCamera(width / height);

    camera.position.add(grid.center);
    camera.lookAt(grid.center);

    // create renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setAnimationLoop(animate);
    renderer.setPixelRatio(window.devicePixelRatio);
    root.appendChild(renderer.domElement);

    const light = new THREE.DirectionalLight(0xffffff, 5);
    light.position.add(grid.center.add(new THREE.Vector3(0, 10, 0)));
    light.target.position.add(grid.center);
    light.castShadow = true;
    scene.add(light);

    // add ambient light
    const ambientLight = new THREE.AmbientLight(0x404040); // soft white light
    scene.add(ambientLight);

    // enable fog if needed
    // scene.fog = new THREE.Fog(0xeeeeee, 1, 50);

    const pointer = new THREE.Vector2();
    const raycaster = new THREE.Raycaster();
    raycaster.setFromCamera(pointer, camera);

    // update the pointer on mouse move
    renderer.domElement.addEventListener("pointermove", (event) => {
        const el = renderer.domElement;

        const rect = el.getBoundingClientRect();
        const relX = Math.min(event.clientX, rect.right) - rect.left;
        const relY = Math.min(event.clientY, rect.bottom) - rect.top;

        pointer.set((relX / rect.width) * 2 - 1, -(relY / rect.height) * 2 + 1);
    });

    // try adding a GameObject
    grid.initialize(scene);

    const events = ["contextmenu", "mousedown", "click", "mouseup", "mousemove", "wheel"];
    const keyboardEvents = ["keydown", "keyup"];
    events.forEach((name) =>
        renderer.domElement.addEventListener(name, (e: any) => {
            grid._input(e);
            camera._input(e);
        }),
    );

    keyboardEvents.forEach((name) =>
        window.addEventListener(name, (e: any) => {
            grid._input(e);
            camera._input(e);
        }),
    );

    window.addEventListener("resize", () => {
        const rect = root.getBoundingClientRect();
        camera.aspect = rect.width / rect.height;
        camera.updateProjectionMatrix();
        renderer.setSize(rect.width, rect.height);
    });

    return { scene, camera, grid };

    /**
     * Render loop.
     * @param time The time since the last frame.
     */
    function animate(time: number) {
        raycaster.setFromCamera(pointer, camera);
        const intersections = raycaster.intersectObjects(scene.children, false);

        for (let intersection of intersections) {
            if (intersection.object instanceof GameObject) {
                // @ts-ignore
                intersection.object._hover && intersection.object._hover(intersection);
            }
        }

        scene.children.forEach((child) => {
            if (child instanceof GameObject) {
                child._process(time);
            }
        });

        // smooth transitions
        JEASINGS.update();

        renderer.render(scene, camera);
    }
}
