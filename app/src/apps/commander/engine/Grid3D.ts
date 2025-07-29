// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { Grid } from "./Grid";
import { Tile } from "../types/common";
import * as THREE from "three";

const OBSTACLE_TEXTURE = new THREE.TextureLoader().load("/textures/crate.jpg");
const FLOOR_TEXTURE = new THREE.TextureLoader().load("/textures/sand.jpg");
const BARRIER_TEXTURE = new THREE.TextureLoader().load("/textures/sandstone-brick.png");

export class Grid3D extends Grid {
    public readonly meshes: { [key: string]: THREE.Object3D | THREE.Group } = {};
    public readonly floor = new THREE.Group();
    public readonly objects = new THREE.Group();

    constructor(public readonly size: number) {
        super(size);

        this.objects.add(this.floor);
        this.initFloorTiles(size);
    }

    initFloorTiles(size: number) {
        const tileMaterial = new THREE.MeshStandardMaterial({ map: FLOOR_TEXTURE });

        tileMaterial.color = new THREE.Color(0xaaaaaa);

        const floor = new THREE.Mesh(new THREE.PlaneGeometry(size, size), tileMaterial);
        const secondFloor = new THREE.Mesh(
            new THREE.PlaneGeometry(size * 2, size * 2),
            tileMaterial.clone(),
        );

        // Enable shadows for floor
        floor.receiveShadow = true;
        secondFloor.receiveShadow = true;

        floor.rotation.x = -Math.PI / 2;
        floor.position.set(size / 2 - 0.5, 0, -(size / 2 - 0.5));

        secondFloor.rotation.x = -Math.PI / 2;
        secondFloor.position.set(size / 2, -0.1, -size / 2);

        // Initialize grass
        // Do not do it here yet.
        // this.initGrassFloorTiles(size);

        // add fog around the play area
        const fogMaterial = tileMaterial.clone();
        fogMaterial.color = new THREE.Color(0x000000);
        fogMaterial.opacity = 0.5;
        fogMaterial.transparent = true;

        const fog = new THREE.Mesh(new THREE.PlaneGeometry(size * 4, size * 4), fogMaterial);
        fog.receiveShadow = true;

        fog.rotation.x = -Math.PI / 2;
        fog.position.set(size / 2, -0.05, -size / 2);

        this.floor.add(floor);
        this.objects.add(secondFloor);
    }

    /** Helper utility to draw grass on the ground */
    _initGrassFloorTiles(size: number) {
        // Add grass using instanced cones
        const grassGeometry = new THREE.ConeGeometry(0.02, 0.1, 4);
        const grassMaterial = new THREE.MeshStandardMaterial({
            color: 0x2d5a27,
            roughness: 0.8,
            metalness: 0.4,
        });

        // Create instanced mesh for grass
        const grassCount = 100 * size * size * 5; // 5 grass blades per tile
        const grassMesh = new THREE.InstancedMesh(grassGeometry, grassMaterial, grassCount);

        // Create dummy object for matrix calculations
        const dummy = new THREE.Object3D();

        // Position grass instances
        for (let i = 0; i < grassCount; i++) {
            const x = Math.random() * size - 0.5;
            const z = Math.random() * size - 0.5;
            const height = 0.05 + Math.random() * 0.05;
            const rotation = Math.random() * Math.PI * 2;
            const tilt = (Math.random() - 1) * 0.2; // Slight random tilt

            dummy.position.set(x, height / 2, -z);
            dummy.rotation.set(tilt, rotation, tilt);
            dummy.scale.set(0.2, height / 0.03, 0.2); // Scale height while keeping base size
            dummy.updateMatrix();

            grassMesh.setMatrixAt(i, dummy.matrix);
        }

        grassMesh.instanceMatrix.needsUpdate = true;
        grassMesh.castShadow = true;
        grassMesh.receiveShadow = true;
        this.floor.add(grassMesh);
    }

    _clearCell(x: number, y: number, tile: Tile) {
        switch (tile.type) {
            case "Unwalkable":
                this.objects.remove(this.meshes[`${x}-${y}`]?.clear());
                break;
            case "Cover":
                this.objects.remove(this.meshes[`${x}-${y}`]?.clear());
                break;
        }
    }

    _setCell(x: number, y: number, tile: Tile) {
        this._clearCell(x, y, tile);
        this.grid[x][y] = { ...tile, unit: this.grid[x][y].unit };
        const group = new THREE.Group();

        if (tile.type === "Unwalkable") {
            this.grid[x][y] = { type: "Unwalkable", unit: null };

            const mesh = new THREE.Mesh(
                new THREE.BoxGeometry(1, 1, 1),
                new THREE.MeshStandardMaterial({ map: OBSTACLE_TEXTURE }),
            );
            mesh.material.color = new THREE.Color(0xaaaaaa);
            mesh.position.set(x, 0.5, -y);
            mesh.castShadow = true;
            mesh.receiveShadow = true;
            group.add(mesh);
        }

        if (tile.type === "Cover") {
            if (tile.up) group.add(this.drawBarrier(x, y, "UP", tile.up));
            if (tile.down) group.add(this.drawBarrier(x, y, "DOWN", tile.down));
            if (tile.left) group.add(this.drawBarrier(x, y, "LEFT", tile.left));
            if (tile.right) group.add(this.drawBarrier(x, y, "RIGHT", tile.right));
        }

        this.meshes[`${x}-${y}`] = group;
        this.objects.add(group);
    }

    drawBarrier(x: number, z: number, direction: "UP" | "DOWN" | "LEFT" | "RIGHT", type: number) {
        const height = type == 1 ? 1 : 2.5;

        const mesh = new THREE.Mesh(
            new THREE.BoxGeometry(0.1, height, 1),
            new THREE.MeshStandardMaterial({ map: BARRIER_TEXTURE }),
        );

        // Enable shadows for barriers
        mesh.material.color = new THREE.Color(0xaaaaaa);
        mesh.castShadow = true;
        mesh.receiveShadow = true;
        mesh.position.set(x, 0.5, -z);

        switch (direction) {
            case "UP": {
                mesh.position.x -= 0.5;
                return mesh;
            }
            case "DOWN": {
                mesh.position.x += 0.5;
                mesh.rotation.y = Math.PI;
                return mesh;
            }
            case "LEFT": {
                mesh.position.z += 0.5;
                mesh.rotation.y = -Math.PI / 2;
                return mesh;
            }
            case "RIGHT": {
                mesh.position.z -= 0.5;
                mesh.rotation.y = -Math.PI / 2;
                return mesh;
            }
        }
    }

    // === Edit Mode ===

    removeSpawn(x: number, y: number) {
        this.spawnPositions = this.spawnPositions.filter((pos) => pos.x !== x || pos.y !== y);
        this.objects.remove(this.meshes[`${x}-${y}`]);
        delete this.meshes[`${x}-${y}`];
    }

    _markSpawn(x: number, y: number): boolean {
        if (this.grid[x][y].type === "Unwalkable") {
            return false;
        }

        const mesh = new THREE.Mesh(
            new THREE.BoxGeometry(1, 2, 1),
            new THREE.MeshStandardMaterial({ color: 0xffffff, opacity: 0.5, transparent: true }),
        );
        this.spawnPositions.push(new THREE.Vector2(x, y));
        this.meshes[`${x}-${y}`] = mesh;
        mesh.position.set(x, 0, -y);
        this.objects.add(mesh);
        return true;
    }
}
