// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./Game";
import { Controls } from "./Controls";
import { GLTF, GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js';
import { Unit } from "./Unit";
import { UI } from "./UI";

export const models: { [key: string]: GLTF } = {};

/**
 * Creates a new Game scene (not to be confused with the Menu background scene).
 */
export async function createScene(element: string) {
    const root = document.getElementById(element);
    if (!root || root.children.length !== 0) {
        return;
    }

    const offset = 30 / 2 - 0.5;
    const scene = new THREE.Scene();

    const ui = new UI(root);
    ui.leftPanel.append(
        ui.createButton("move"),
        ui.createButton("attack"),
    );
    ui.rightPanel.append(
        ui.createButton("cancel"),
        ui.createButton("confirm"),
    );

    const aspect = window.innerWidth / window.innerHeight;
    const camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 1000);
    camera.position.set(offset, 20, offset);
    camera.lookAt(offset, 0, offset);

    const renderer = new THREE.WebGLRenderer();
    renderer.setSize(window.innerWidth, window.innerHeight);
    renderer.setPixelRatio(window.devicePixelRatio);
    root.appendChild(renderer.domElement);

    const ambientLight = new THREE.AmbientLight(0xffffff, 0.1);
    scene.add(ambientLight);

    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');

    const loader = new GLTFLoader();
    loader.setDRACOLoader(dracoLoader);

    // loaded unit scene with animations
    const unit = models.soldier = await loader.loadAsync("/soldier_2.gltf");

    // load other models
    models.floor = await loader.loadAsync("/models/rusted_floor.glb");
    models.fence = await loader.loadAsync("/models/fence.glb");
    models.fenceCorner = await loader.loadAsync("/models/fence_corner.glb");

    // game
    const game = new Game();
    game.addUnit(new Unit(unit), 10, 10);
    scene.add(game);

    // controls & raycaster
    const controls = new Controls(game, renderer.domElement, camera);
    controls.connect();
    controls.addEventListener("scroll", ({ delta }) => {
        let newPosition = camera.position.z + delta * 0.01;
        if (newPosition >= 0 && newPosition < 30) {
            camera.position.z = newPosition;
        }
    });
    controls.addEventListener("zoom", ({ delta }) => {
        let newPosition = camera.position.y + delta * 0.1;
        if (newPosition >= 10 && newPosition <= 30) {
            camera.position.y = newPosition;
        }
    });

    function animate() {
        controls.update(0.01);
        const cursor = controls.raycast(game.plane);
        cursor && game.update(cursor);
        game.input(controls);

        renderer.render(scene, camera);
    }

    renderer.setAnimationLoop(animate);

    window.addEventListener("resize", () => {
        camera.aspect = window.innerWidth / window.innerHeight;
        camera.updateProjectionMatrix();
        renderer.setSize(window.innerWidth, window.innerHeight);
    });

    // on unfocus
    window.addEventListener("blur", () => {
        controls.disconnect();
        renderer.setAnimationLoop(null);
        // ui.domElement.style.visibility = "hidden";
    });

    // on focus
    window.addEventListener("focus", () => {
        controls.connect();
        renderer.setAnimationLoop(animate);
        // ui.domElement.style.visibility = "visible";
    });
}
