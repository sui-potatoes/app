// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
// import { bcs } from "../types/bcs";
import { GLTF } from "three/examples/jsm/loaders/GLTFLoader.js";
import { clone } from "three/examples/jsm/utils/SkeletonUtils.js";
import JEASINGS from "jeasings";

/**
 * Implements the base class for the Unit object. Contains both the data (from
 * the `Move` side of the application) and the visual representation.
 */
export class UnitModel extends THREE.Object3D {
    public readonly model: THREE.Object3D;
    public readonly animations: THREE.AnimationClip[];
    public readonly mixer: THREE.AnimationMixer;
    public readonly light = new THREE.SpotLight(0xffffff, 20, 10, Math.PI / 2);

    constructor(gltf: GLTF) {
        super();

        this.animations = Array.from(gltf.animations);
        this.model = clone(gltf.scene);
        this.model.castShadow = true;
        this.model.receiveShadow = true;
        this.mixer = new THREE.AnimationMixer(this.model);

        this.light.position.set(0, 4, 0);
        this.light.target = this.model;
        this.light.castShadow = true;

        this.add(this.light);
        this.add(this.model);
    }

    playAnimation(name: string, once = false) {
        // const clip = THREE.AnimationClip.findByName(this.animations, name);
        // const action = this.mixer.clipAction(clip, undefined, THREE.NormalAnimationBlendMode);
        // action.play();

        return new Promise((resolve) => {
            const mixer = this.mixer!;
            const unit = this;

            const clip = THREE.AnimationClip.findByName(this.animations, name);
            const action = this.mixer!.clipAction(clip, undefined, THREE.NormalAnimationBlendMode);
            mixer.stopAllAction();
            action.setLoop(once ? THREE.LoopOnce : THREE.LoopRepeat, 10);
            action.play();

            mixer.addEventListener("finished", onFinished);

            function onFinished() {
                action.stop();
                unit.playAnimation("Idle");
                mixer.removeEventListener("finished", onFinished);
                resolve(null);
            }
        });
    }

    async walk(path: THREE.Vector2[]) {
        path.reverse();
        this.playAnimation("Run");

        let easings: [{ x: number; z: number }, JEASINGS.JEasing][] = path
            .slice(1)
            .map(({ x, y: z }) => [
                { x, z },
                new JEASINGS.JEasing(this.position).to({ x, z }, 300 + Math.random() * 100),
            ]);

        while (easings.length) {
            await new Promise((resolve) => {
                let [target, easing] = easings.shift()!;
                this.lookAt(target.x, 0, target.z);
                easing.onComplete(() => resolve(void 0));
                easing.start();
            });
        }

        this.playAnimation("Idle");
    }

    update() {
        this.mixer.update(0.01);
    }
}

export class Unit extends UnitModel {
    constructor(gltf: GLTF) {
        super(gltf);
        this.playAnimation("Idle");
    }
}
