// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../../networkConfig";
import { NavLink } from "react-router-dom";
import { useTransactionExecutor } from "../hooks/useTransactionExecutor";
import { Transaction } from "@mysten/sui/transactions";
import { Loader, Footer, StatRecord } from "./Components";
import { SuiObjectRef } from "@mysten/sui/client";
import { useState } from "react";
import { type Weapon, useWeapons } from "../hooks/useWeapons";
import { weaponImgUrls, weaponMetadata } from "../types/metadata";
import { preload } from "react-dom";

export const WEAPON_STATS: StatRecord[] = [
    {
        key: "damage",
        name: "DAMAGE",
        maxValue: 10,
        description: "Damage range of the weapon",
        process: (s) => [s.damage - s.spread, s.damage + s.spread],
    },
    { key: "range", name: "RANGE", maxValue: 10, description: "Effective range of the weapon" },
    { key: "ammo", name: "AMMO", maxValue: 6, description: "Ammo capacity of the weapon" },
    {
        key: "crit_chance",
        name: "CRIT CHANCE",
        maxValue: 100,
        description: "Chance of dealing critical damage",
    },
    { key: "aim", name: "AIM BONUS", maxValue: 100, description: "Aim stat bonus when equipped" },
];

export function Weapons() {
    weaponImgUrls().map((url) => preload(url, { as: "image" }));

    const flow = useEnokiFlow();
    const client = useSuiClient();
    const zkLogin = useZkLogin();
    const [selected, setSelected] = useState<Weapon | undefined>();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { data, isPending, isError, error, refetch } = useWeapons({ address: zkLogin.address });
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const canTransact = !!zkLogin.address && !!executeTransaction;

    if (isError) {
        return (
            <div className="flex justify-center align-middle h-screen flex-col">
                <div>Error: {error.message}</div>
            </div>
        );
    }

    // count identical weapons; weapons with upgrades are not counted
    // and considered unique
    const count: { [key: string]: number } = {};
    const displayed = (data || [])
        .sort((a, b) => a.name.localeCompare(b.name))
        .filter((w) => {
            if (w.name in count && !w.hasUpgrades) {
                count[w.name]++;
                return false;
            }

            // don't count weapons with upgrades
            if (!w.hasUpgrades) count[w.name] = 1;
            return true;
        });

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left p-10">
                <h1 className="p-1 mb-10 white page-heading">
                    <NavLink to="../headquarters">HEADQUATERS</NavLink> / WEAPONS
                </h1>
                <div className="flex justify-start">
                    <div className="w-96 max-w-md">
                        <div>
                            {(isPending || isExecuting) && <Loader />}
                            {displayed.map((w) => (
                                <div
                                    className={
                                        "options-row interactive " +
                                        (selected?.objectId == w.objectId ? "selected" : "")
                                    }
                                    key={w.objectId}
                                    onClick={() => setSelected(w)}
                                >
                                    <a>
                                        {w.name}
                                        {w.hasUpgrades ? "+" : ""}
                                    </a>
                                    <p>{!w.hasUpgrades && count[w.name]}</p>
                                </div>
                            ))}
                        </div>
                        <div
                            className={`options-row mt-10 ${!canTransact ? "non-interactive" : "interactive"}`}
                            onClick={() => mintWeapon(rngTier(), { ...rngUpgrade() })}
                        >
                            <div>New random weapon</div>
                            <div>+</div>
                        </div>
                    </div>
                    {selected && (
                        <div
                            className="ml-10 px-10 pb-10 max-w-3xl overflow-auto"
                            style={{ maxHeight: "80vh" }}
                        >
                            <div className="mb-10">
                                <h2 className="mb-2">DESCRIPTION</h2>
                                <p className="normal-case">
                                    {weaponMetadata(selected.name).description}
                                </p>
                                <img src={weaponMetadata(selected.name).image} />
                            </div>
                            <div>
                                <h2 className="mb-2">STATS</h2>
                                {WEAPON_STATS.map((record) => (
                                    <StatRecord
                                        key={record.key}
                                        record={record}
                                        stats={selected.stats}
                                        className="options-row"
                                    />
                                ))}
                            </div>

                            <h2 className="mb-2 mt-10">UPGRADES</h2>
                            <div className="w-full">
                                {[...Array(2)].map((_, i) => {
                                    if (selected.upgrades[i]) {
                                        const upgrade = selected.upgrades[i];
                                        return (
                                            <div
                                                className="my-auto options-row interactive"
                                                key={i}
                                            >
                                                <a>{upgrade.name}</a>
                                                <div>⨉</div>
                                            </div>
                                        );
                                    } else {
                                        return (
                                            <div
                                                className="my-auto options-row interactive"
                                                key={i}
                                            >
                                                <div className="text-left">Empty upgrade slot</div>
                                                <div>+</div>
                                            </div>
                                        );
                                    }
                                })}
                                <div className="my-auto options-row non-interactive">
                                    <div className="text-left">Upgrade slot unavailable</div>
                                </div>
                            </div>
                            <p className="mt-2 normal-case">
                                An upgrade can only be used once. Once installed, it can be removed
                                and thrown out or replaced with another upgrade.
                            </p>
                            <div
                                className="mt-10 py-10 text-center interactive"
                                style={{ width: "172.8px", marginLeft: "0", padding: "10px 0" }}
                                onClick={() => throwAway(selected)}
                            >
                                throw away
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <Footer to="../headquarters" />
        </div>
    );

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

    // async function removeWeaponUpgrade(ref: SuiObjectRef, idx: number) {
    //     if (!zkLogin.address) throw new Error("Not logged in");
    //     if (!executeTransaction) throw new Error("No transaction executor");
    //     if (isExecuting) throw new Error("Already executing a transaction");

    //     const tx = new Transaction();
    //     const weapon = tx.objectRef(ref);
    //     tx.moveCall({
    //         target: `${packageId}::weapon::remove_upgrade`,
    //         arguments: [weapon, tx.pure.u8(idx)],
    //     });

    //     await executeTransaction(tx);
    //     refetch();
    // }

    async function throwAway(ref: SuiObjectRef) {
        if (!zkLogin.address) throw new Error("Not logged in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!confirm("Are you sure you want to throw away this weapon? It will be gone forever!"))
            throw new Error("User refused");

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::weapon::destroy`,
            arguments: [tx.objectRef(ref)],
        });

        await executeTransaction(tx).then(console.log);
        setTimeout(() => refetch(), 1000);
        refetch();
    }
}

function rngTier(): number {
    return +((Math.random() * 10000) % 3).toFixed(0);
}

function rngUpgrade(): { [key: string]: number } {
    let tier = +((Math.random() * 10000) % 2).toFixed(0);
    let idx = +((Math.random() * 10000) % 4).toFixed(0);

    return {
        [["scope", "laser_sight", "stock", "expanded_clip"][idx]]: tier,
    };
}
