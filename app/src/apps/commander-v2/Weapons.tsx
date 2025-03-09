// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { NavLink } from "react-router-dom";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { fromBase64 } from "@mysten/bcs";
import { Transaction } from "@mysten/sui/transactions";
import { Weapon as WeaponBcs } from "./types/bcs";
import { Loader, Footer, Slider, SliderRange } from "./Components";
import { SuiObjectRef } from "@mysten/sui/client";
import { useState } from "react";

type Weapon = typeof WeaponBcs.$inferType & SuiObjectRef & { hasUpgrades: boolean };

export function Weapons() {
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const zkLogin = useZkLogin();
    const [selected, setSelected] = useState<Weapon | undefined>();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (!zkLogin.address) {
        return <></>;
    }

    const {
        data: weapons,
        isPending,
        isError,
        error,
        refetch,
    } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address,
            filter: { MoveModule: { package: packageId, module: "weapon" } },
            options: { showBcs: true, showType: true },
        },
        {
            enabled: !!zkLogin.address,
            gcTime: 10000,
            select(data) {
                return data.data.map((obj) => {
                    // @ts-ignore
                    const weapon = WeaponBcs.parse(fromBase64(obj.data?.bcs!.bcsBytes));
                    return {
                        ...weapon,
                        hasUpgrades: Object.keys(weapon.upgrades).length > 0,
                        objectId: obj.data?.objectId,
                        version: obj.data?.version,
                        digest: obj.data?.digest,
                    } as Weapon & SuiObjectRef;
                });
            },
        },
    );

    if (isPending || isExecuting) return <Loader />;
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
    const displayed = weapons
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
            <div className="text-left text-uppercase text-lg p-10">
                <h1 className="block p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../headquaters">HEADQUATERS</NavLink> / WEAPONS
                </h1>
                <div className="flex justify-start">
                    <div className="text-uppercase text-lg w-96 rounded max-w-md hover:cursor-pointer">
                        <div>
                            {displayed.map((w) => (
                                <div
                                    className={
                                        "options-row " +
                                        (selected?.objectId == w.objectId ? "selected" : "")
                                    }
                                    key={w.objectId}
                                    onClick={() => setSelected(w)}
                                >
                                    <label>
                                        {w.name}
                                        {w.hasUpgrades ? "+" : ""}
                                    </label>
                                    <p>{!w.hasUpgrades && count[w.name]}</p>
                                </div>
                            ))}
                        </div>
                        <div
                            className="options-row mt-10"
                            onClick={() =>
                                mintWeapon(rngTier(), { ...rngUpgrade(), ...rngUpgrade() })
                            }
                        >
                            <div>New random weapon</div>
                            <div>+</div>
                        </div>
                    </div>
                    {selected && (
                        <div
                            className="ml-10 pr-10 text-lg max-w-3xl overflow-auto"
                            style={{ maxHeight: "80vh" }}
                        >
                            <div className="mb-10">
                                <h2 className="mb-2">DESCRIPTION</h2>
                                <p>{nameToDescription(selected.name)}</p>
                                <h2></h2>
                                <img src={nameToImage(selected.name)} />
                            </div>
                            <div>
                                <h2 className="mb-2">STATS</h2>
                                <div className="options-row" title="Base damage stat of the weapon">
                                    <label>DAMAGE</label>
                                    <SliderRange
                                        range={[
                                            selected.stats.damage - selected.stats.spread,
                                            selected.stats.damage,
                                        ]}
                                        maxValue={10}
                                    />
                                </div>
                                <div className="options-row" title="Effective range of the weapon">
                                    <label>RANGE</label>
                                    <Slider value={selected.stats.range} maxValue={10} />
                                </div>
                                <div className="options-row" title="Ammo capacity of the weapon">
                                    <label>AMMO</label>
                                    <Slider value={selected.stats.ammo} maxValue={6} />
                                </div>
                                <div
                                    className="options-row"
                                    title="Chance of dealing critical damage"
                                >
                                    <label>CRIT CHANCE</label>
                                    <Slider value={selected.stats.crit_chance} maxValue={100} />
                                </div>
                                <div className="options-row" title="Aim stat bonus when equipped">
                                    <label>AIM BONUS</label>
                                    <Slider value={selected.stats.aim} maxValue={100} />
                                </div>
                            </div>

                            <h2 className="mb-2 mt-10">UPGRADES</h2>
                            <div className="w-full">
                                {[...Array(2)].map((_, i) => {
                                    if (selected.upgrades[i]) {
                                        const upgrade = selected.upgrades[i];
                                        return (
                                            <div
                                                className="my-auto options-row hover:cursor-default"
                                                key={i}
                                            >
                                                <div className="text-left">{upgrade.name}</div>
                                                {/* <div>{upgradeStatDescription(upgrade.stats)}</div> */}
                                                {/* <div className="yes-no bold">⨉</div> */}
                                                {/* <div className="yes-no">remove</div> */}
                                                <div>⨉</div>
                                            </div>
                                        );
                                    } else {
                                        return (
                                            <div
                                                className="my-auto options-row hover:cursor-pointer"
                                                key={i}
                                            >
                                                <div className="text-left uppercase">
                                                    Empty upgrade slot
                                                </div>
                                                <div>+</div>
                                                {/* <div className="yes-no bold">+</div> */}
                                            </div>
                                        );
                                    }
                                })}
                                <div className="my-auto options-row hover:cursor-default">
                                    <div className="text-left uppercase" style={{ color: "grey" }}>
                                        Upgrade slot unavailable
                                    </div>
                                </div>
                            </div>
                            <p className="mt-2">
                                An upgrade can only be used once. Once installed, it can be removed
                                and thrown out or replaced with another upgrade.
                            </p>
                            <div
                                className="mt-10 py-10 yes-no"
                                style={{ width: "172.8px", marginLeft: "0", padding: "10px 0" }}
                                onClick={() => throwAway(selected)}
                            >
                                THROW AWAY
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <Footer to="../headquaters" />
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

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::weapon::destroy`,
            arguments: [tx.objectRef(ref)],
        });

        await executeTransaction(tx);
        refetch();
    }
}

function nameToDescription(name: string): string {
    return (
        {
            ["standard rifle"]:
                "Standard issue rifle - a sturdy option for any encounter, not too good - not too bad. A couple upgrades won't hurt",
            ["plasma rifle"]:
                "Plasma rifle - the best in class, uses bleeding edge technology to provide maximum damage at significant range.",
            ["sharpshooter rifle"]:
                "Sharpshooter rifle delivers best damage at long range. A choice for a marksman skilled enough to score critical hits.",
        }[name.toLowerCase()] || "Add description."
    );
}

function nameToImage(name: string): string {
    return (
        {
            ["standard rifle"]: "/images/standard_rifle.svg",
            ["sharpshooter rifle"]: "/images/marksman_rifle.svg",
            ["plasma rifle"]: "/images/plasma_rifle.svg",
        }[name.toLowerCase()] || "/images/standard_rifle.svg"
    );
}

function rngTier(): number {
    return +((Math.random() * 10000) % 3).toFixed(0);
}

function rngUpgrade(): { [key: string]: number } {
    let tier = +((Math.random() * 10000) % 2).toFixed(0);
    let idx = +(((Math.random() * 10000) % 4)).toFixed(0);

    return {
        [["scope", "laser_sight", "stock", "expanded_clip"][idx]]: tier,
    };
}
