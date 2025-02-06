// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { NavLink } from "react-router-dom";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { fromBase64 } from "@mysten/bcs";
import { Armor, Stats, Weapon } from "./types/bcs";
import { SuiObjectRef } from "@mysten/sui/client";
import { Loader } from "./Loader";

export function Inventory() {
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const zkLogin = useZkLogin();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (!zkLogin.address) {
        return (
            <div className="flex justify-center align-middle h-screen flex-col">
                <h1 className="text-center">Inventory</h1>
                <NavLink to="/" className="menu-control">
                    Exit Game
                </NavLink>
            </div>
        );
    }

    // get all owned objects, with a 10 second garbage collection time
    const {
        data: myObjects,
        isPending,
        isError,
        error,
        refetch,
    } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address,
            filter: { Package: packageId },
            options: { showBcs: true, showType: true },
        },
        {
            enabled: !!zkLogin.address,
            gcTime: 10000,
            select(data) {
                return data.data.map((obj) => ({
                    objectId: obj.data?.objectId,
                    version: obj.data?.version,
                    digest: obj.data?.digest,
                    type: obj.data?.type,
                    count: 1, // @ts-ignore
                    bcs: fromBase64(obj.data?.bcs!.bcsBytes),
                }));
            },
        },
    );

    const armor = (myObjects || [])
        .filter((obj) => obj.type === `${packageId}::armor::Armor`)
        .map((obj) => ({ ...obj, parsed: Armor.parse(obj.bcs) }));

    const weapon = (myObjects || [])
        .filter((obj) => obj.type === `${packageId}::weapon::Weapon`)
        .map((obj) => ({ ...obj, parsed: Weapon.parse(obj.bcs) }));

    if (isPending || isExecuting) return <Loader />;

    if (isError) {
        return (
            <div className="flex justify-center align-middle h-screen flex-col">
                <div>Error: {error.message}</div>
            </div>
        );
    }

    return (
        <div className="flex justify-center align-middle h-screen flex-col">
            <h1 className="text-center">Inventory</h1>
            <NavLink to=".." className="menu-control">
                Back to menu
            </NavLink>
            <div className="flex justify-center align-middle">
                {armor.map((a) => (
                    <div
                        key={a.objectId}
                        className="col col-3 align-middle w-60 p-4 py-0 bg-black m-4 rounded"
                    >
                        <h2 className="text-center py-2">
                            {a.parsed.name} ({a.count})
                        </h2>
                        <img src={nameToImage(a.parsed.name)} alt="armor" />
                        <p className="text-center mt-3">
                            <button onClick={() => throwAwayArmor(a as SuiObjectRef)}>
                                THROW AWAY
                            </button>
                        </p>
                        <hr className="my-4" />
                        <p className="text-center mt-3">{statsToText(a.parsed.stats)}</p>
                        {/* <p className="text-center uppercase mt-2">
                            <button onClick={() => console.log("equip armor")}>EQUIP</button>
                            </p>
                        */}
                    </div>
                ))}
            </div>
            <div className="flex justify-center align-middle">
                {weapon.map((w) => (
                    <div
                        key={w.objectId}
                        className="col col-3 align-middle w-60 p-4 py-0 bg-black m-4 rounded"
                    >
                        <h2 className="text-center py-2">
                            {w.parsed.name} ({w.count})
                        </h2>
                        <img src="/images/weapon.webp" alt="weapon" />
                        <p className="text-center mt-3">
                            <button onClick={() => throwAwayWeapon(w as SuiObjectRef)}>
                                THROW AWAY
                            </button>
                        </p>
                        <hr className="my-4" />
                        <p className="text-center mt-3">{statsToText(w.parsed.stats)}</p>
                        <hr className="my-4" />

                        {w.parsed.upgrades.map((u, i) => (
                            <p className="text-center mt-3">
                                <span key={u.name}>
                                    - {u.name}: {statsToText(u.stats)}{" "}
                                    <button
                                        onClick={() => removeWeaponUpgrade(w as SuiObjectRef, i)}
                                    >
                                        REMOVE
                                    </button>
                                </span>
                            </p>
                        ))}
                        {/* <p className="text-center uppercase mt-2">
                            <button onClick={() => console.log("equip weapon")}>EQUIP</button>
                        </p> */}
                    </div>
                ))}
            </div>
            <button onClick={() => mintWeapon(rngTier(), rngUpgrade())}>mint weapon</button>
            <button onClick={() => mintArmor(rngTier())}>mint armor</button>
        </div>
    );

    /**
     * Mints an armor object of the given tier.
     */
    async function mintArmor(tier: number) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (![1, 2, 3].includes(tier)) throw new Error(`Invalid armor tier ${tier}`);

        const tx = new Transaction();
        const armor = tx.moveCall({
            target: `${packageId}::items::armor`,
            arguments: [tx.pure.u8(tier)],
        });

        tx.transferObjects([armor], zkLogin.address!);

        await executeTransaction!(tx);
        setTimeout(() => refetch(), 1000);
    }

    /**
     * Mints a weapon object of the given tier and upgrades.
     * Upgrades can be any combination of scope, laser_sight, stock, and expanded_clip.
     * Each upgrade can be tier 1, 2, or 3.
     */
    async function mintWeapon(tier: number, upgrades: { [key: string]: number }) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (![1, 2, 3].includes(tier)) throw new Error(`Invalid weapon tier ${tier}`);

        const tx = new Transaction();
        const weapon = tx.moveCall({
            target: `${packageId}::items::rifle`,
            arguments: [tx.pure.u8(tier)],
        });

        if (upgrades.scope && [1, 2, 3].includes(upgrades.scope)) {
            const upgrade = tx.moveCall({
                target: `${packageId}::items::scope`,
                arguments: [tx.pure.u8(upgrades.scope)],
            });

            tx.moveCall({
                target: `${packageId}::weapon::add_upgrade`,
                arguments: [weapon, upgrade],
            });
        }

        if (upgrades.laser_sight && [1, 2, 3].includes(upgrades.laser_sight)) {
            const upgrade = tx.moveCall({
                target: `${packageId}::items::laser_sight`,
                arguments: [tx.pure.u8(upgrades.laser_sight)],
            });

            tx.moveCall({
                target: `${packageId}::weapon::add_upgrade`,
                arguments: [weapon, upgrade],
            });
        }

        if (upgrades.stock && [1, 2, 3].includes(upgrades.stock)) {
            const upgrade = tx.moveCall({
                target: `${packageId}::items::stock`,
                arguments: [tx.pure.u8(upgrades.stock)],
            });

            tx.moveCall({
                target: `${packageId}::weapon::add_upgrade`,
                arguments: [weapon, upgrade],
            });
        }

        if (upgrades.expanded_clip && [1, 2, 3].includes(upgrades.expanded_clip)) {
            const upgrade = tx.moveCall({
                target: `${packageId}::items::expanded_clip`,
                arguments: [tx.pure.u8(upgrades.expanded_clip)],
            });

            tx.moveCall({
                target: `${packageId}::weapon::add_upgrade`,
                arguments: [weapon, upgrade],
            });
        }

        tx.transferObjects([weapon], zkLogin.address!);

        await executeTransaction!(tx);
        setTimeout(() => refetch(), 1000);
    }

    async function removeWeaponUpgrade(ref: SuiObjectRef, idx: number) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");

        const tx = new Transaction();
        const weapon = tx.objectRef(ref);
        tx.moveCall({
            target: `${packageId}::weapon::remove_upgrade`,
            arguments: [weapon, tx.pure.u8(idx)],
        });

        await executeTransaction(tx);
        refetch();
    }

    async function throwAwayArmor(ref: SuiObjectRef) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::armor::destroy`,
            arguments: [tx.objectRef(ref)],
        });

        await executeTransaction(tx);
        refetch();
    }

    async function throwAwayWeapon(ref: SuiObjectRef) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::weapon::destroy`,
            arguments: [tx.objectRef(ref)],
        });

        await executeTransaction(tx);
        refetch();
    }
}

function rngTier(): number {
    return +(((Math.random() * 10000) % 2) + 1).toFixed(0);
}

function rngUpgrade(): { [key: string]: number } {
    let tier = +(((Math.random() * 10000) % 2) + 1).toFixed(0);
    let idx = +((Math.random() * 10000) % 4).toFixed(0);

    return {
        [["scope", "laser_sight", "stock", "expanded_clip"][idx]]: tier,
    };
}

const nameToSlug = (name: string) =>
    ({
        mobility: "MOB",
        aim: "AIM",
        health: "HP",
        armor: "ARM",
        dodge: "DODGE",
        defense: "DEF",
        damage: "DMG",
        spread: "SPRD",
        plus_one: "PLONE",
        crit_chance: "CRIT",
        is_dodgeable: "DG+",
        area_size: "AREA",
        env_damage: "ENV",
        range: "RNG",
        ammo: "AMMO",
        _: "UNK",
    })[name];

function statsToText(stats: Stats) {
    const keys = Object.keys(stats).sort() as (keyof Stats)[];
    return keys
        .filter((key) => +stats[key] > 0)
        .map((key) => {
            let value =
                +stats[key] > 128
                    ? "-" + (+stats[key] - 128)
                    : "+" + typeof stats[key] == "boolean"
                      ? ""
                      : stats[key];
            return `${nameToSlug(key)}: ${value}`;
        })
        .join("; ");
}

function nameToImage(name: string) {
    if (name == "Light Armor") {
        return "/images/armor-light.webp";
    }

    if (name == "Medium Armor") {
        return "/images/armor-medium.webp";
    }

    return "/images/armor-medium.webp";
}
