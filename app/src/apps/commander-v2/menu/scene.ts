// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";
import { clone } from 'three/examples/jsm/utils/SkeletonUtils.js';

const loader = new GLTFLoader();

export async function createMenuScene(element: string) {
    const root = document.getElementById(element);

    // prevent duplicate scene creation
    if (!root || root.children.length > 0) {
        return;
    }

    const witdh = window.innerWidth;
    const height = window.innerHeight;

    const renderer = new THREE.WebGLRenderer({ antialias: true });
    renderer.setSize(witdh, height);
    renderer.setPixelRatio(window.devicePixelRatio);
    root.appendChild(renderer.domElement);

    const scene = new THREE.Scene();
    const camera = new THREE.PerspectiveCamera(75, witdh / height, 0.1, 100);

    camera.position.z = -1;
    camera.position.y = 2;
    camera.position.x = -1;
    camera.lookAt(0, 1, 0);

    window.addEventListener("resize", () => {
        const witdh = window.innerWidth;
        const height = window.innerHeight;
        renderer.setSize(witdh, height);
        camera.aspect = witdh / height;
        camera.updateProjectionMatrix();
    });

    const geometry = new THREE.CircleGeometry(10, 1000);
    const material = new THREE.MeshStandardMaterial({
        color: 0x111111,
        side: THREE.DoubleSide,
        // reflectivity: 1,
        shadowSide: THREE.DoubleSide,
    });
    const plane = new THREE.Mesh(geometry, material);
    plane.receiveShadow = true;
    plane.rotateX(-Math.PI / 2);
    scene.add(plane);

    {
        const light = new THREE.SpotLight(0xffffff, 40);
        light.target.position.set(0, 0, 0);
        light.position.set(2, 10, 4);
        light.castShadow = true;
        light.shadow.mapSize.width = 512; // default
        light.shadow.mapSize.height = 512; // default
        light.shadow.camera.near = 0.5; // default
        light.shadow.camera.far = 500; // default
        scene.add(light);
    };

    // directional light from below
    {
        const light = new THREE.DirectionalLight(0x1111aa, 0.5);
        light.position.set(1, 0, 1);
        light.target.position.set(0, 1, 0);
        light.castShadow = true;
        scene.add(light);
    };

    // directional light from below and behind
    {
        const light = new THREE.DirectionalLight(0x551111, 0.5);
        light.position.set(-4, 0, 2);
        light.target.position.set(0, 1, 0);
        light.castShadow = true;
        scene.add(light);
    };

    // scene.fog = new THREE.Fog(0x111111, 1, 10);
    // const ambientLight = new THREE.AmbientLight(0x404040);
    // scene.add(ambientLight);

    const gltf = await loader.loadAsync("/soldier_3.glb");
    console.log(gltf.animations);
    const model = gltf.scene;
    const mixer1 = new THREE.AnimationMixer(model);
    {
        const clip = THREE.AnimationClip.findByName(gltf.animations, "Idle");
        const action = mixer1.clipAction(clip, undefined, THREE.NormalAnimationBlendMode);
        model.castShadow = true;
        model.receiveShadow = false;
        action.setLoop(THREE.LoopRepeat, 1000);
        action.play();
    };

    // place first unit
    model.position.set(0.5, 0, 0.5);
    scene.add(model);

    // second unit
    const second = clone(model);
    second.position.x = 0.5;
    second.position.z = -0.5;
    second.rotateY(-Math.PI / 4);
    scene.add(second);

    const mixer2 = new THREE.AnimationMixer(second);
    {
        const clip = THREE.AnimationClip.findByName(gltf.animations, "Static");
        const action = mixer2.clipAction(clip, undefined, THREE.NormalAnimationBlendMode);
        model.castShadow = true;
        action.setLoop(THREE.LoopRepeat, 1000);
        action.play();
    };

    // third unit
    const third = clone(model);
    third.position.x = -0.5;
    third.position.z = -0.5;
    third.rotateY(-Math.PI / 2);
    scene.add(third);

    const mixer3 = new THREE.AnimationMixer(third);
    {
        const clip = THREE.AnimationClip.findByName(gltf.animations, "SniperShot");
        const action = mixer3.clipAction(clip, undefined, THREE.NormalAnimationBlendMode);
        model.castShadow = true;
        action.setLoop(THREE.LoopRepeat, 10000);
        action.play();
    };

    function animate() {
        renderer.render(scene, camera);
        mixer1 && mixer1.update(0.002);
        mixer2 && mixer2.update(0.001);
        mixer3 && mixer3.update(0.003);

        // camera rotation
        const center = new THREE.Vector3(0, 1, 0);
        const distance = camera.position.distanceTo(center);

        camera.position.y = Math.abs(camera.rotation.y) + 2;
        camera.translateZ(-distance);
        camera.rotateOnWorldAxis(new THREE.Vector3(0, 1, 0), 0.001);
        camera.translateZ(distance);
        camera.lookAt(center);
    }

    renderer.setAnimationLoop(animate);
}
