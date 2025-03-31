// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

// @ts-ignore
import { Text } from "troika-three-text";
import { GLTF } from "three/examples/jsm/loaders/GLTFLoader.js";
import { clone } from "three/examples/jsm/utils/SkeletonUtils.js";
import { Line2 } from "three/addons/lines/Line2.js";
import JEASINGS from "jeasings";
import { LineMaterial } from "three/examples/jsm/lines/LineMaterial.js";
import { LineGeometry } from "three/examples/jsm/lines/LineGeometry.js";
import { Unit as UnitProps } from "../types/bcs";
import * as THREE from "three";
import { Game } from "./Game";

/**
 * Implements the base class for the Unit object. Contains both the data (from
 * the `Move` side of the application) and the visual representation.
 */
export class UnitModel extends THREE.Object3D {
    public readonly model: THREE.Object3D;
    public readonly animations: THREE.AnimationClip[];
    public readonly mixer: THREE.AnimationMixer;
    public readonly aimCircle: THREE.Group = new THREE.Group();
    public readonly statsPanel: THREE.Group = new THREE.Group();
    public readonly light = new THREE.SpotLight(0xffffff, 20, 10, Math.PI / 2);

    protected text: Text;
    protected updateQueue: ((d: number) => {})[] = [];

    constructor(
        public props: typeof UnitProps.$inferType,
        gltf: GLTF,
    ) {
        super();

        this.animations = Array.from(gltf.animations);
        this.model = clone(gltf.scene);
        this.model.castShadow = true;
        this.model.receiveShadow = true;
        this.mixer = new THREE.AnimationMixer(this.model);

        this.light.position.set(0, 4, 0);
        this.light.target = this.model;
        this.light.castShadow = true;
        this.aimCircle.renderOrder = 0;

        this.add(this.light);
        this.add(this.model);
        this.add(this.aimCircle);
        this.add(this.statsPanel);
    }

    // === Unit Actions ===

    /** Perform movemement along the path */
    async walk(path: THREE.Vector2[]) {
        this.playAnimation("Run", 0.5).play();

        let easings: [{ x: number; z: number }, JEASINGS.JEasing][] = path
            .slice(1)
            .map(({ x, y: z }) => [
                { x, z },
                new JEASINGS.JEasing(this.position).to({ x, z }, 400 + Math.random() * 100),
            ]);

        while (easings.length) {
            await new Promise((resolve) => {
                let [target, easing] = easings.shift()!;
                this.lookAt(target.x, 0, target.z);
                easing.onComplete(() => resolve(void 0));
                easing.start();
            });
        }

        this.playAnimation("Idle").play();
    }

    /** Do the "fancy" shooting animation with particles flying toward the target */
    async shoot(target: this) {
        this.playAnimation("SniperShot", 3).play();

        // create a vector from this to targetPos and normalize it
        const targetPos = this.worldToLocal(target.position.clone());
        // const direction = targetPos.clone().normalize().multiplyScalar(0.5);

        // send particles to the target
        const particles = new THREE.Group();
        const particleGeo = new LineGeometry().setPositions([
            0,
            0,
            0,
            ...targetPos
                .clone()
                .normalize()
                .multiplyScalar(Math.min(0.5, Math.abs(Math.random()))),
        ]);
        const particleMat = new LineMaterial({
            color: 0xffbd6d,
            linewidth: 3,
            alphaToCoverage: true,
        });

        const tempParticles = [];

        for (let i = 0; i < 4; i++) {
            const particle = new Line2(particleGeo, particleMat);
            particle.position.set(0, 1.5, 0);
            particle.translateX(-0.12);
            particle.translateZ(1);
            tempParticles.push(particle);
        }

        this.add(particles);

        const promises = tempParticles.map((particle, i) => {
            const rng = () => Math.random() * 0.1;
            const end = targetPos.clone().multiplyScalar(0.8);
            return new Promise((resolve) => {
                setTimeout(() => {
                    particles.add(particle);
                    new JEASINGS.JEasing(particle.position)
                        .to({ x: end.x + rng(), y: end.y + 1.5 + rng(), z: end.z + rng() }, 100)
                        .start()
                        .onComplete(() => {
                            particles.remove(particle);
                            resolve(void 0);
                        });
                }, i * 400);
            });
        });

        target
            .playAnimation("Damage", 0.5)
            .crossFadeTo(target.playAnimation("Idle"), 1, true)
            .play();

        await Promise.all(promises);

        particles.clear();
        this.playAnimation("Idle").play();
    }

    // === Animation & Game Loop ===

    /** Play an animation by name */
    playAnimation(name: string, timeScale: number = 1) {
        this.mixer.stopAllAction();
        const clip = THREE.AnimationClip.findByName(this.animations, name);
        const action = this.mixer.clipAction(clip, this, THREE.NormalAnimationBlendMode);

        if (!action) {
            throw new Error(
                `Animation ${name} not found. Available names are: ${this.animations.map((clip) => clip.name).join(", ")}`,
            );
        }

        action.setLoop(THREE.LoopRepeat, 999);

        action.timeScale = timeScale;
        return action;
    }

    update(delta: number) {
        this.mixer.update(delta);
        this.updateQueue.forEach((fn) => fn(delta));
    }

    // === Visual Indicators ===

    /** Target is drawn on the currently targeted unit */
    drawTarget(chance: number, damage_low: number, damage_high: number) {
        this.updateQueue = [];

        const text = (this.text = new Text());
        text.text = `CHANCE: ${chance}%\nDAMAGE: ${damage_low}-${damage_high}\nHEALTH: ${this.props.hp.value}/${this.props.hp.max_value}`;
        text.fontSize = 0.1;
        text.color = 0x1ae7bf;
        text.sync();
        text.position.set(0.4, 1.8, 0.8);
        this.aimCircle.add(text);

        // adds an aim circle to the unit
        const circle = createCircleSegmentLine(0.3, 32, 0x1ae7bf, 0, Math.PI * 2, 1);
        const innerCircle = createCircleSegmentLine(0.25, 32, 0x1ae7bf, Math.PI / 2, Math.PI, 0.8);
        const innerCircle2 = createCircleSegmentLine(
            0.22,
            32,
            0x1ae7bf,
            Math.PI * 1.1,
            Math.PI * 1.5,
            0.8,
        );
        circle.position.set(0, 1.5, 0.8);
        circle.add(innerCircle);
        circle.add(innerCircle2);

        this.updateQueue.push((d) => (innerCircle.rotation.y += d * 1.2));
        this.updateQueue.push((d) => (innerCircle2.rotation.y += d * 0.9));

        circle.rotation.x = Math.PI / 2;
        this.aimCircle.add(circle);
    }

    /** Removes the attack params info from the target */
    removeTarget() {
        this.text.dispose(); // must be done explicitly!
        this.aimCircle.clear();
        this.updateQueue = [];
    }

    /** AP bar is shown when a unit is selected */
    drawApBar() {
        this.statsPanel.clear();
        // const maxValue = this.props.ap.max_value
        const ap = this.props.ap.value;

        if (ap === 0) return;
        if (ap > 0) {
            let line = createCircleSegmentLine(0.4, 32, 0x1ae7bf, 0, Math.PI / 2, 4);
            line.position.set(0, 0.1, 0);
            this.statsPanel.add(line);
        }
        if (ap > 1) {
            let line = createCircleSegmentLine(0.4, 32, 0x1ae7bf, Math.PI / 2 + 0.3, Math.PI, 4);
            line.position.set(0, 0.1, 0);
            this.statsPanel.add(line);
        }
    }
}

export class Unit extends UnitModel {
    public readonly gridPosition: THREE.Vector2 = new THREE.Vector2();

    constructor(props: typeof UnitProps.$inferType, gltf: GLTF, x: number, z: number) {
        super(props, gltf);
        this.gridPosition.set(x, z);
        this.playAnimation("Idle").play();
    }

    markSelected(game: Game, selected: boolean) {
        if (this.props.last_turn < game.turn) {
            this.props.last_turn = game.turn;
            this.props.ap.value = this.props.ap.max_value;
        }

        if (selected) this.drawApBar();
        else this.statsPanel.clear();
    }

    spendAp(value: number) {
        this.props.ap.value = Math.max(0, this.props.ap.value - value);
        this.drawApBar();
    }
}

function createCircleSegmentLine(
    radius: number,
    segments: number,
    color: number,
    startAngle: number,
    endAngle: number,
    width: number = 0.4,
) {
    const vertices = [];
    const angleStep = (endAngle - startAngle) / segments;

    for (let i = 0; i <= segments; i++) {
        const theta = startAngle + i * angleStep;
        vertices.push(radius * Math.cos(theta), 0, radius * Math.sin(theta));
    }

    const lineGeo = new LineGeometry().setPositions(vertices);
    const material = new LineMaterial({ color, linewidth: width, alphaToCoverage: true });
    const circleSegment = new Line2(lineGeo, material);

    return circleSegment;
}
