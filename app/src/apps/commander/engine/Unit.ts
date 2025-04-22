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
import { AnimationPlayer } from "./AnimationPlayer";

/** Animations supported by the current unit model */
type Animation =
    | "idle"
    | "reload"
    | "death"
    | "run"
    | "shooting"
    | "take_damage"
    | "crouch_idle"
    | "toss_grenade"
    | "crouch_reload"
    | "put_back_rifle"
    | "crouch_shooting";

const RIFLE_OBJECT_NAME = "Rifle";

/**
 * Implements the base class for the Unit object. Contains both the data (from
 * the `Move` side of the application) and the visual representation.
 */
export class UnitModel extends THREE.Object3D {
    public readonly model: THREE.Object3D;
    public readonly animationPlayer: AnimationPlayer;

    public readonly aimCircle: THREE.Group = new THREE.Group();
    public readonly statsPanel: THREE.Group = new THREE.Group();
    public readonly light = new THREE.SpotLight(0xffffff, 20, 10, Math.PI / 2);
    protected cover: Cover = "low";

    protected text: Text;
    protected updateQueue: ((d: number) => {})[] = [];

    constructor(
        public props: typeof UnitProps.$inferType,
        gltf: GLTF,
    ) {
        super();

        this.model = clone(gltf.scene);
        this.model.castShadow = true;
        this.model.receiveShadow = true;
        this.animationPlayer = new AnimationPlayer(this.model, [...gltf.animations], "idle");
        this.model.scale.set(0.9, 0.9, 0.9);

        const hat = this.model.getObjectByName("MocapGuy_Hat");
        if (hat) hat.parent!.remove(hat);

        this.model.castShadow = true;
        this.model.receiveShadow = true;

        this.model.traverse((child) => {
            if (child instanceof THREE.Mesh) {
                child.castShadow = true;
                child.receiveShadow = true;
            }
        });

        this.light.position.set(0, 4, 0);
        this.light.target = this.model;
        this.light.castShadow = true;
        this.light.shadow.mapSize.set(1024, 1024);
        this.light.shadow.radius = 10;

        this.aimCircle.renderOrder = 0;

        this.applyMorphTargets([...new Array(10).fill(Math.abs(Math.random()))]);

        this.add(this.light);
        this.add(this.model);
        this.add(this.aimCircle);
        this.add(this.statsPanel);
    }

    // === Animations ===

    async defaultAnimation(timeScale: number = 1, fadeIn: number = 0) {
        // this.animationPlayer.
        let animation: Animation = this.cover == "low" ? "crouch_idle" : "idle";
        return this.animationPlayer.play(animation, timeScale, fadeIn);
    }

    // === Unit Actions ===

    /** Perform movement along the path */
    async walk(path: THREE.Vector2[]) {
        this.animationPlayer.play("run", 0.5);

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

        let animation: Animation = this.cover == "low" ? "crouch_idle" : "idle";

        this.animationPlayer.play(animation, 0.5);
    }

    /** Play reload animation once and then return to idle */
    async reload() {
        const animation: Animation = this.cover == "low" ? "crouch_reload" : "reload";
        await this.playAnimationOnce(animation, 1, 0.5).wait;
        return this.defaultAnimation(1, 0.1);
    }

    async death() {
        await this.playAnimationOnce("death", 1, 0.5).wait;
    }

    async grenade() {
        await this.playAnimationOnce("toss_grenade", 0.9, 0.5).wait;
        return this.defaultAnimation(1, 0.1);
    }

    /** Move rifle attachment from right hand to left hand */
    _moveRifle() {
        const rifle = this.model.getObjectByName(RIFLE_OBJECT_NAME);
        const leftHand = this.model.getObjectByName("mixamorigLeftHand");
        const rightHand = this.model.getObjectByName("mixamorigRightHand");

        if (!rifle || !leftHand || !rightHand)
            return console.log("no rifle, left hand or right hand");

        const worldPos = new THREE.Vector3();
        const worldQuat = new THREE.Quaternion();
        rifle.getWorldPosition(worldPos);
        rifle.getWorldQuaternion(worldQuat);

        if (rifle && rifle.parent == rightHand && leftHand) {
            console.log("moving rifle to left hand");

            rightHand.remove(rifle);
            // rifle.position.copy(worldPos);

            leftHand.add(rifle);
            rifle.quaternion.copy(worldQuat);
            rifle.position.set(-0.1, 0, -0.1);
        }

        if (rifle && rifle.parent == leftHand && rightHand) {
            leftHand.remove(rifle);

            // rifle.position.copy(worldPos);
            rifle.quaternion.copy(worldQuat);

            rightHand.add(rifle);
        }
    }

    /** Do the "fancy" shooting animation with particles flying toward the target */
    async shoot(target: this) {
        let startAnimation: Animation = this.cover == "low" ? "shooting" : "crouch_shooting";

        this.animationPlayer.play(startAnimation, 3, 0);

        // create a vector from this to targetPos and normalize it
        const targetPos = this.worldToLocal(target.position.clone());

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

        promises.push(target.playAnimationOnce("take_damage", 1.2, 0.1).wait);

        await Promise.all(promises);

        target.defaultAnimation(1, 0.2);

        particles.clear();
        this.defaultAnimation();
    }

    // === Animation & Game Loop ===

    /** Play an animation by name */
    playAnimation(name: Animation, timeScale: number = 1, fadeIn: number = 1) {
        return this.animationPlayer.play(name, timeScale, fadeIn);
    }

    playAnimationOnce(name: Animation, timeScale: number = 1, fadeIn: number = 1) {
        return this.animationPlayer.playOnce(name, timeScale, fadeIn);
    }

    update(delta: number) {
        this.animationPlayer.mixer.update(delta);
        this.updateQueue.forEach((fn) => fn(delta));
    }

    // === Visual Indicators ===

    /** Target is drawn on the currently targeted unit */
    drawTarget(chance: number, defenseBonus: number, damage_low: number, damage_high: number) {
        this.updateQueue = [];

        const text = (this.text = new Text());
        const defenseText = defenseBonus > 0 ? ` (-${defenseBonus}%)` : "";
        text.text = `CHANCE: ${chance}%${defenseText}\nDAMAGE: ${damage_low}-${damage_high}\nHEALTH: ${this.props.hp.value}/${this.props.hp.max_value}`;
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
        circle.position.set(0, this.cover !== "low" ? 1.5 : 1.1, 0.8);
        circle.add(innerCircle);
        circle.add(innerCircle2);

        this.updateQueue.push((d) => (innerCircle.rotation.y += d * 1.2));
        this.updateQueue.push((d) => (innerCircle2.rotation.y += d * 0.9));

        circle.rotation.x = Math.PI / 2;
        this.aimCircle.add(circle);
    }

    /** Removes the attack params info from the target */
    removeTarget() {
        this.text?.dispose(); // must be done explicitly!
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

    applyMorphTargets(morphTargets: number[]) {
        const mesh = this.model.getObjectByName("Body") as THREE.SkinnedMesh;

        (mesh.material as THREE.MeshPhysicalMaterial).color.setHSL(
            Math.max(morphTargets[0] / 10, 0.01),
            Math.max(morphTargets[1], 0.1),
            Math.max(morphTargets[2], 0.1),
        );

        mesh.morphTargetInfluences = morphTargets || mesh.morphTargetInfluences;
    }
}

type Cover = "none" | "low" | "high";

export class Unit extends UnitModel {
    public readonly gridPosition: THREE.Vector2 = new THREE.Vector2();

    constructor(props: typeof UnitProps.$inferType, gltf: GLTF, x: number, z: number) {
        super(props, gltf);
        this.gridPosition.set(x, z);
        this.defaultAnimation();
    }

    /** Set the cover of the Unit (which affects animations) */
    setCover(cover: Cover) {
        this.cover = cover;
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
