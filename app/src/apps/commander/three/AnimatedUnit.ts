// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";
import { GameObject } from "./GameObject";
import { GLTFLoader } from "three/addons/loaders/GLTFLoader.js";

const loader = new GLTFLoader();

const IDLE = "Idle";
const STATIC = "Static";
const RUN = "Run";
const MELEE = "Melee";
const SHOOTING = "Shooting";
const SNIPERSHOT = "Snipershot";
const DEATH = "Death";
const DAMAGE = "Damage";
const CROUCH_DEATH = "CrouchDeath";
const CROUCH_DAMAGE = "CrouchDamage";

/**
 * Simple `Unit` object which has a texture.
 * In the current implementation of Commander, we have predefined unit classes,
 * each with their own texture: soldier, heavy, sniper and scarecrow.
 */
export class AnimatedUnit extends GameObject<THREE.Object3DEventMap> {
    public animations: THREE.AnimationClip[];

    protected mixer: THREE.AnimationMixer | null;
    protected model: THREE.Object3D | null;
    protected _isReady: boolean = false;

    constructor() {
        const geometry = new THREE.PlaneGeometry(0, 0);
        const material = new THREE.MeshStandardMaterial({ color: 0xaaaaaa });

        super(geometry, material);

        // this.rotation.x = -Math.PI / 2;
        this.receiveShadow = true;
        this.animations = [];
        this.mixer = null;
        this.model = null;

        loader.loadAsync("/soldier_2.gltf").then((gltf) => {
            this.model = gltf.scene;
            this.animations = gltf.animations;
            this.mixer = new THREE.AnimationMixer(this.model);
            this._ready();
        });
    }

    get isReady(): boolean {
        return this._isReady;
    }

    _process(_delta: number): void {
        if (this.mixer) {
            this.mixer.update(0.01);
        }
    }

    _select() {
        this.playAnimation(IDLE);
    }

    _deselect(): void {
        this.playAnimation(STATIC);
    }

    _ready(): void {
        if (this.model) {
            this.model.scale.set(0.7, 0.7, 0.7);
            // this.model.rotation.x = Math.PI / 2;
            this.playAnimation(STATIC);
            this.add(this.model);
        }
    }

    private playAnimation(name: string) {
        if (this.mixer && this.model && this.animations) {
            this.mixer.stopAllAction();
            const clip = THREE.AnimationClip.findByName(this.animations, name);
            const action = this.mixer.clipAction(clip);
            action.play();
        }
    }
}
