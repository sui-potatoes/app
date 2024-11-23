// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { Game } from "./Game";
import { Controls } from "./Controls";
import { GLTF, GLTFLoader } from "three/examples/jsm/loaders/GLTFLoader.js";
import { DRACOLoader } from 'three/addons/loaders/DRACOLoader.js';
import { Unit } from "./Unit";
import { UI } from "./UI";

import Stats from "stats.js";
import JEASINGS from "jeasings";
import { EditMode } from "./modes/EditMode";
import { NoneMode } from "./modes/NoneMode";
import { ShootMode } from "./modes/ShootMode";
import { MoveMode } from "./modes/MoveMode";

export const models: { [key: string]: GLTF } = {};

/**
 * Creates a new Game scene (not to be confused with the Menu background scene).
 */
export async function createScene(element: string) {
    const root = document.getElementById(element);
    if (!root || root.children.length !== 0) {
        return;
    }

     // 0: fps, 1: ms, 2: mb, 3+: custom
    const stats = new Stats();
    stats.showPanel(0);
    // stats.showPanel(1);
    // stats.showPanel(2);
    document.body.appendChild( stats.dom );

    const offset = 30 / 2 - 0.5;
    const scene = new THREE.Scene();

    const ui = new UI(root);
    ui.leftPanel.append(
        ui.createButton("move"),
        ui.createButton("shoot"),
        ui.createButton("edit"),
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

    const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
    scene.add(ambientLight);

    // scene.fog = new THREE.Fog(0x000000, 10, 30);

    const dracoLoader = new DRACOLoader();
    dracoLoader.setDecoderPath('https://www.gstatic.com/draco/versioned/decoders/1.5.6/');

    const loader = new GLTFLoader();
    loader.setDRACOLoader(dracoLoader);

    // loaded unit scene with animations
    const unit = models.soldier = await loader.loadAsync("/soldier_2.gltf");

    // load other models
    models.base_tile = await loader.loadAsync("/models/base_tile.glb");
    models.barrier_steel = await loader.loadAsync("/models/barrier_steel.glb");
    models.barrel_stack = await loader.loadAsync("/models/barrel_stack.glb");

    // game
    const game = new Game();
    game.addUnit(new Unit(unit, 14, 15));
    game.addUnit(new Unit(unit, 10, 20));
    game.addUnit(new Unit(unit, 6, 4));
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

    ui.addEventListener("button", ({ id }) => {
        switch (id) {
            case "confirm": return game.performAction();
            case "move": return game.switchMode(new MoveMode());
            case "shoot": return game.switchMode(new ShootMode(camera));
            case "edit": return game.switchMode(new EditMode(controls));
            case "cancel": return game.switchMode(new NoneMode());
        }
    })

    function animate() {
        stats.begin();
        JEASINGS.update();

        controls.update(0.01);
        const cursor = controls.raycast(game.plane);
        cursor && game.update(cursor);
        game.input(controls);

        renderer.render(scene, camera);
        stats.end();
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
