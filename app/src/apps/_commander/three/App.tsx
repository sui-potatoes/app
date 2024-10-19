// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useEffect } from "react";
// import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import * as THREE from "three";
import { ControllableCamera, Crate, Grid, GameObject, Unit } from "./components/GameObject";

// animation

/**
 * Body for the ThreeJS app.
 */
export default function Three() {
    useEffect(() => {
        addThree();
    }, []);
    return <div id="three"></div>;
}

function addThree() {
    // get the root element, skip if it already has children (i.e. ThreeJS is already running)
    const root = document.getElementById("three");
    if (!root || root.childNodes.length > 0) {
        return;
    }

    // set up the scene
    const width = 1024;
    const height = 768;

    // create scene
    const scene = new THREE.Scene();
    const grid = new Grid(10); // And first there was a grid
    const camera = new ControllableCamera(width / height);

    camera.position.add(grid.center);
    camera.lookAt(grid.center);

    console.log(grid.scale);

    // create renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(width, height);
    renderer.setAnimationLoop(animate);
    renderer.setPixelRatio(window.devicePixelRatio);
    root.appendChild(renderer.domElement);

    const light = new THREE.DirectionalLight(0xffffff, 1);
    light.position.add(grid.center.add(new THREE.Vector3(0, 10, 0)));
    light.target.position.add(grid.center);
    light.castShadow = true;
    scene.add(light);

    scene.fog = new THREE.Fog(0xeeeeee, 1, 90);

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
    grid.addGameObject(new Crate(), new THREE.Vector2(0, 0));
    grid.addGameObject(new Crate(), new THREE.Vector2(0, 9));
    grid.addGameObject(new Crate(), new THREE.Vector2(9, 0));
    grid.addGameObject(new Crate(), new THREE.Vector2(9, 9));

    const events = ["keydown", "keyup", "contextmenu", "mousedown", "click", "mouseup", "mousemove", "wheel"];
    events.forEach((name) =>
        window.addEventListener(name, (e: any) => {
            grid._input(e);
            camera._input(e);
            scene.children.forEach((child) => {
                if (child instanceof GameObject) {
                    child._input(e as KeyboardEvent | MouseEvent | WheelEvent);
                }
            });
        }),
    );

    window.addEventListener("resize", () => {
        const rect = root.getBoundingClientRect();
        camera.aspect = rect.width / rect.height;
        camera.updateProjectionMatrix();
        renderer.setSize(rect.width, rect.height);
    });

    // render the scene
    function animate(time: number) {
        raycaster.setFromCamera(pointer, camera);
        const intersections = raycaster.intersectObjects(scene.children, false);

        for (let intersection of intersections) {
            // @ts-ignore
            intersection.object._hover && intersection.object._hover(intersection);
        }

        scene.children.forEach((child) => {
            if (child instanceof GameObject) {
                child._process(time);
            }
        });

        renderer.render(scene, camera);
    }
}
