// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Canvas } from "@react-three/fiber";
import { useEffect, useMemo, useState } from "react";
import { loadModel, models, UnitModel } from "../../engine";
import { Loader } from "../Components";
import { OrbitControls, Plane } from "@react-three/drei";
import { useFrame } from "@react-three/fiber";
import { GLTF } from "three/examples/jsm/loaders/GLTFLoader.js";
import * as THREE from "three";

/// Character Editor using ThreeJS and morph targets.
export function Character({ morphTargets }: { morphTargets: number[] }) {
    const [modelLoaded, setModelLoaded] = useState(false);
    useEffect(() => {
        loadModel("the_dude").then(() => setModelLoaded(true));
    }, []);

    if (!modelLoaded || !models.the_dude) {
        return <Loader text="Loading model..." />;
    }

    return (
        <Canvas camera={{ position: [0, 3, 4] }} shadows>
            {/* <color attach="background" args={["#000000"]} /> */}
            <ambientLight intensity={2} />
            <OrbitControls
                rotateSpeed={0.5}
                panSpeed={0.5}
                zoomSpeed={0.5}
                position0={[10, 4, 4]}
            />
            <Scene model={models.the_dude} morphTargets={morphTargets} />
        </Canvas>
    );
}

export function Scene({ model, morphTargets }: { model: GLTF; morphTargets: number[] }) {
    const unit = useMemo(() => new UnitModel({} as any, model), [model]);
    const [_mesh, setMesh] = useState<THREE.SkinnedMesh>();
    const material = useMemo(
        () => new THREE.MeshStandardMaterial({ color: 0x333333, metalness: 0.5, roughness: 0.5 }),
        [],
    );

    useFrame((_, delta) => {
        unit.update(delta);
    });

    useEffect(() => {
        unit.light.position.set(0, 4, 1);
        unit.position.set(0, -1, 0);
        unit.model.scale.set(2, 2, 2);
        unit.playAnimation("idle", 0.2, 0);

        const mesh = unit.model.getObjectByName("Body") as THREE.SkinnedMesh;

        (mesh.material as THREE.MeshPhysicalMaterial).color.setHSL(
            Math.max(morphTargets[0] / 10, 0.01),
            Math.max(morphTargets[1], 0.1),
            Math.max(morphTargets[2], 0.1),
        );

        mesh.morphTargetInfluences = morphTargets || mesh.morphTargetInfluences;

        setMesh(mesh as THREE.SkinnedMesh);
    }, [morphTargets]);

    return (
        <>
            <primitive object={unit} />
            <directionalLight
                position={[30, 2, 30]}
                target={unit.model}
                castShadow
                shadow-mapSize={[1024, 1024]}
                shadow-radius={2}
            />
            <Plane
                args={[2, 2]}
                material={material}
                position={[0, -1, 0]}
                rotation-x={-Math.PI / 2}
                receiveShadow
            />
        </>
    );
}
