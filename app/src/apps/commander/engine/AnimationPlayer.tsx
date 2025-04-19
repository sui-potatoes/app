// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import * as THREE from "three";

export class AnimationPlayer {
    public readonly animations: THREE.AnimationClip[];
    public readonly mixer: THREE.AnimationMixer;
    protected currentAction: THREE.AnimationAction | null = null;

    constructor(
        public readonly model: THREE.Object3D,
        animations: THREE.AnimationClip[],
        initialAnimation: string,
    ) {
        this.animations = animations;
        this.mixer = new THREE.AnimationMixer(model);

        // play the initial animation
        {
            const clip = THREE.AnimationClip.findByName(this.animations, initialAnimation);
            const action = this.mixer.clipAction(clip, this.model, THREE.NormalAnimationBlendMode);
            action.play();
        }

        console.log(this.animations.map((a) => a.name));
    }

    play(animation: string, timeScale: number = 1, fadeIn: number = 0.5) {
        const clip = THREE.AnimationClip.findByName(this.animations, animation);
        const action = this.mixer.clipAction(clip, this.model, THREE.NormalAnimationBlendMode);

        if (!action) {
            throw new Error(
                `Animation ${animation} not found. Available names are: ${this.animations.map((clip) => clip.name).join(", ")}`,
            );
        }

        action.timeScale = timeScale;
        action.reset();
        fadeIn == 0 && this.mixer.stopAllAction();

        if (this.currentAction) {
            this.currentAction.setLoop(THREE.LoopOnce, 1);
            this.currentAction.clampWhenFinished = true;
            this.currentAction.blendMode = THREE.NormalAnimationBlendMode;
            // Set up cross fade from current to new animation
            this.currentAction.fadeOut(fadeIn);
            action.fadeIn(fadeIn);
        }

        action.play();
        this.currentAction = action;

        const wait = new Promise((resolve) => {
            const listener = ({
                action,
                direction: _,
            }: {
                action: THREE.AnimationAction;
                direction: number;
            }) => {
                if (action == this.currentAction) {
                    this.mixer.removeEventListener("finished", listener);
                    resolve(void 0);
                }
            };

            this.mixer.addEventListener("finished", listener);
        });

        return {
            action,
            wait,
        };
    }

    playOnce(animation: string, timeScale: number = 1, fadeIn: number = 0.5) {
        const { action, wait } = this.play(animation, timeScale, fadeIn);
        action.setLoop(THREE.LoopOnce, 1);
        action.clampWhenFinished = true;
        return { action, wait};
    }
}
