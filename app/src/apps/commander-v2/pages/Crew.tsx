// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { Transaction } from "@mysten/sui/transactions";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../../networkConfig";
import { useTransactionExecutor } from "../hooks/useTransactionExecutor";
import { useRecruits, Recruit } from "../hooks/useRecruits";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiAddress } from "@mysten/sui/utils";
import { useNameGenerator } from "../hooks/useNameGenerator";
import { SuiObjectRef } from "@mysten/sui/client";
import { Footer, Modal, StatRecord, Loader } from "./Components";
import { useState } from "react";
import { Armor, useArmor } from "../hooks/useArmor";
import { armorMetadata, weaponMetadata } from "../types/metadata";
import { useWeapons, Weapon } from "../hooks/useWeapons";
import { WEAPON_STATS } from "./Weapons";
import { mergeStats } from "../types/bcs";

/** Main stats of the Recruit with descriptions */
export const RECRUIT_STATS: StatRecord[] = [
    {
        key: "aim",
        name: "AIM",
        maxValue: 100,
        description: "Change of hitting the target at effective range",
    },
    {
        key: "health",
        name: "HEALTH",
        maxValue: 20,
        description: "Number of health points a recruit has",
    },
    {
        key: "mobility",
        name: "MOBILITY",
        maxValue: 10,
        description: "How many tiles this unit can move in a single action",
    },
    { key: "armor", name: "ARMOR", maxValue: 3, description: "Incoming damage negation value" },
    {
        key: "dodge",
        name: "DODGE",
        maxValue: 100,
        description: "Chance of dodging incoming damage",
    },
];

export function Crew() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const [showModal, setShowModal] = useState<"armor" | "weapon" | false>(false);
    const [selected, setSelected] = useState<Recruit | undefined>();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const {
        data: recruits,
        refetch,
        isPending,
    } = useRecruits({
        owner: zkLogin.address!,
        enabled: !!zkLogin.address,
    });

    const {
        data: weapons,
        refetch: refetchWeapons,
        isPending: _weaponsFetching,
    } = useWeapons({
        address: zkLogin.address,
        unique: true,
    });
    const {
        data: armors,
        refetch: refetchArmors,
        isPending: _armorsFetching,
    } = useArmor({
        address: zkLogin.address,
        unique: true,
    });

    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (weapons && selected?.weapon) weapons.unshift(selected.weapon as Weapon);
    if (armors && selected?.armor && !armors.some((a) => a.name == selected.armor?.name)) {
        armors.unshift(selected.armor as Armor);
    }

    if (isPending || isExecuting) return <Loader />;

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10">
                <h1 className="p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../HEADQUARTERS">HEADQUARTERS</NavLink> / CREW
                </h1>
                <div className="flex justify-start">
                    <div className="w-96 rounded max-w-md">
                        <div>
                            {recruits?.map((r) => {
                                return (
                                    <div
                                        key={r.objectId}
                                        className={
                                            "options-row interactive " +
                                            (selected?.objectId == r.objectId ? "selected" : "")
                                        }
                                        onClick={() => setSelected(r)}
                                    >
                                        <div>{r.metadata.name}</div>
                                        <div>({r.rank.$kind})</div>
                                    </div>
                                );
                            })}
                        </div>
                        <div
                            key="new-recruit"
                            className={`options-row interactive text-center ${(recruits?.length || 0) > 1 ? "mt-10" : ""}`}
                            onClick={hireRecruit}
                        >
                            <div>NEW HIRE</div>
                            <div>+</div>
                        </div>
                    </div>
                    {selected && (
                        <div className="size-max ml-10 text-lg max-w-3xl">
                            <div className="mb-10">
                                <h2 className="mb-2">BACKSTORY</h2>
                                <p className="normal-case">
                                    {selected.metadata.backstory == "Story locked"
                                        ? "Get more experience to unlock character backstory and traits."
                                        : selected.metadata.backstory}
                                </p>
                            </div>
                            <div>
                                <h2 className="mb-2">STATS</h2>
                                <div
                                    className="options-row"
                                    title="Rank is based on experience the unit has and progresses"
                                >
                                    <label>RANK</label>
                                    <p>{selected.rank.$kind}</p>
                                </div>
                                {RECRUIT_STATS.map((record) => (
                                    <StatRecord
                                        key={record.key}
                                        record={record}
                                        stats={selected.stats}
                                        modifier={mergeStats(
                                            selected.armor?.stats,
                                            selected.weapon?.stats,
                                        )}
                                        className="options-row"
                                    />
                                ))}
                            </div>

                            <div className="mt-10 w-full flex justify-between">
                                {/* Weapon selection */}
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">WEAPON</h3>
                                    {(selected.weapon && (
                                        <div
                                            style={{
                                                height: "200px",
                                                minWidth: "200px",
                                                maxWidth: "400px",
                                            }}
                                            className="h-full text-center flex flex-col interactive"
                                            onClick={() => setShowModal("weapon")}
                                        >
                                            <img
                                                src={weaponMetadata(selected.weapon.name).image}
                                                style={{ maxHeight: "150px" }}
                                            />
                                            <label className="mt-2">
                                                {selected.weapon.name}
                                                {selected.weapon.upgrades.length > 0 && "+"}
                                            </label>
                                        </div>
                                    )) || (
                                        <div
                                            style={{ height: "200px", width: "375px" }}
                                            className="text-center flex flex-col interactive"
                                            onClick={() => setShowModal("weapon")}
                                        >
                                            <div className="my-auto">
                                                Select
                                                <br />
                                                weapon
                                            </div>
                                        </div>
                                    )}
                                </div>
                                {/* Armor selection */}
                                {/* max width is 30% of the container */}
                                <div className="my-auto max-w-1/3 ml-10">
                                    <h3 className="text-left mb-4">ARMOR</h3>
                                    {(selected.armor && (
                                        <div
                                            style={{ height: "200px", width: "200px" }}
                                            className="text-center flex flex-col interactive"
                                            onClick={() => setShowModal("armor")}
                                        >
                                            <img
                                                src={armorMetadata(selected.armor.name).image}
                                                style={{ maxHeight: "150px" }}
                                            />
                                            <label>{selected.armor.name}</label>
                                        </div>
                                    )) || (
                                        <div
                                            style={{ height: "200px", width: "200px" }}
                                            className="text-center flex flex-col interactive"
                                            onClick={() => setShowModal("armor")}
                                        >
                                            <div className="my-auto">
                                                Select
                                                <br />
                                                armor
                                            </div>
                                        </div>
                                    )}
                                </div>
                            </div>
                            <div
                                className="mt-10 py-10 yes-no"
                                style={{ width: "172.8px", marginLeft: "0", padding: "10px 0" }}
                                onClick={() => dismissRecruit(selected)}
                            >
                                DISMISS
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <Modal show={!!showModal} onClose={() => setShowModal(false)}>
                {/* armor selection modal */}
                {showModal === "armor" && (
                    <div className="flex justify-between" onClick={(e) => e.preventDefault()}>
                        {_armorsFetching && <Loader />}
                        {!_armorsFetching &&
                            armors?.reverse().map((a) => {
                                const isSelected = a.name == selected?.armor?.name;
                                return (
                                    <div
                                        key={a.name}
                                        onClick={() =>
                                            isSelected
                                                ? removeArmor(selected!)
                                                : addArmor(selected!, a)
                                        }
                                        className={
                                            "m-10 p-10 option-row interactive" +
                                            (isSelected ? " selected" : "")
                                        }
                                    >
                                        <label className="text-xl mb-10">{a.name}</label>
                                        <img src={armorMetadata(a.name).image} />
                                        {["armor", "dodge", "mobility"].map((stat) => (
                                            <div className="flex justify-between" key={stat}>
                                                <div>{stat.toUpperCase()}</div>
                                                <div>{(a.stats as any)[stat]}</div>
                                            </div>
                                        ))}
                                        <button
                                            className="yes-no interactive"
                                            style={{
                                                width: "100%",
                                                margin: "20px 0 0 0",
                                                padding: "10px 15px",
                                            }}
                                        >
                                            {isSelected ? "remove" : "select"}
                                        </button>
                                    </div>
                                );
                            })}
                    </div>
                )}
                {showModal === "weapon" && (
                    <div
                        onClick={(e) => e.preventDefault()}
                        style={{ height: "95vh", marginTop: "5vh" }}
                    >
                        {_weaponsFetching && <Loader />}
                        <div className="mt-10"></div>
                        {!_weaponsFetching &&
                            weapons?.map((w) => {
                                const isSelected = selected?.weapon?.id == w.id;

                                return (
                                    <div
                                        className={
                                            "p-10 mb-2 mx-2 option-row interactive" +
                                            (isSelected ? " selected" : "")
                                        }
                                        key={w.objectId}
                                        onClick={() => {
                                            isSelected
                                                ? removeWeapon(selected!)
                                                : addWeapon(selected!, w);
                                        }}
                                    >
                                        <label className="text-xl mb-10">
                                            {w.name}
                                            {w.hasUpgrades && "+"}
                                        </label>
                                        <img src={weaponMetadata(w.name).image} />
                                        {WEAPON_STATS.map((record) => (
                                            <StatRecord
                                                key={record.key}
                                                record={record}
                                                stats={w.stats}
                                                className="flex justify-between"
                                            />
                                        ))}
                                        {w.hasUpgrades && (
                                            <></>
                                            // <div className="flex justify-between">
                                            //     {w.upgrades.map((u) => (
                                            //         <div key={u.name}>{u.name}</div>
                                            //     ))}
                                            // </div>
                                        )}
                                        <button
                                            className="yes-no interactive"
                                            style={{
                                                width: "100%",
                                                margin: "20px 0 0 0",
                                                padding: "10px 15px",
                                            }}
                                        >
                                            {isSelected ? "remove" : "select"}
                                        </button>
                                    </div>
                                );
                            })}
                    </div>
                )}
            </Modal>
            <Footer to="../headquarters" />
        </div>
    );

    /**
     * TODO:
     * - Improve name generator, so that it doesn't take so long to process, additionally, block the
     *  UI while the name is being generated and the transaction is being process.
     */
    async function hireRecruit() {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");

        const { name, backstory } = await useNameGenerator();

        const tx = new Transaction();
        const recruit = tx.moveCall({
            target: `${packageId}::recruit::new`,
            arguments: [tx.pure.string(name), tx.pure.string(backstory)],
        });

        tx.transferObjects([recruit], zkLogin.address);

        await executeTransaction(tx);
        setTimeout(() => refetch(), 1000);
    }

    /**
     *
     * @param id
     * @returns
     */
    async function dismissRecruit(recruit: SuiObjectRef) {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!confirm("Are you sure you want to dismiss a recruit?")) return;

        const tx = new Transaction();
        const [weapon, armor] = tx.moveCall({
            target: `${packageId}::recruit::dismiss`,
            arguments: [tx.objectRef(recruit)],
        });

        tx.moveCall({
            target: `${normalizeSuiAddress("0x1")}::option::destroy_none`,
            typeArguments: [`${packageId}::weapon::Weapon`],
            arguments: [weapon],
        });

        tx.moveCall({
            target: `${normalizeSuiAddress("0x1")}::option::destroy_none`,
            typeArguments: [`${packageId}::armor::Armor`],
            arguments: [armor],
        });

        await executeTransaction(tx).then(console.log);
        const removedIdx = recruits?.findIndex((r) => r.id == recruit.objectId);
        removedIdx && recruits?.splice(removedIdx, 1);
        setSelected(undefined);
        setTimeout(() => refetch(), 1000);
    }

    /** Adds Armor to the Recruit */
    async function addArmor(r: Recruit, a: Armor) {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!selected) throw new Error("Recruit has to be selected");

        const tx = new Transaction();
        const recruitArg = tx.objectRef(r);

        if (selected.armor) {
            const armor = tx.moveCall({
                target: `${packageId}::recruit::remove_armor`,
                arguments: [recruitArg],
            });

            tx.transferObjects([armor], zkLogin.address);
        }

        tx.moveCall({
            target: `${packageId}::recruit::add_armor`,
            arguments: [recruitArg, tx.objectRef(a)],
        });

        await executeTransaction(tx).then(console.log);
        setTimeout(() => {
            refetchArmors();
            refetch();
        }, 1000);
        selected.armor = a;
        setShowModal(false);
    }

    /** Removes Armor from the Recruit */
    async function removeArmor(r: Recruit) {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!selected) throw new Error("Recruit has to be selected");

        const tx = new Transaction();
        const armor = tx.moveCall({
            target: `${packageId}::recruit::remove_armor`,
            arguments: [tx.objectRef(r)],
        });

        tx.transferObjects([armor], zkLogin.address);

        await executeTransaction(tx).then(console.log);
        setTimeout(() => {
            refetchArmors();
            refetch();
        }, 1000);
        selected.armor = null;
        setShowModal(false);
    }

    /** Adds Weapon to the Recruit */
    async function addWeapon(r: Recruit, w: Weapon) {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!selected) throw new Error("Recruit has to be selected");

        const tx = new Transaction();
        const recruitArg = tx.objectRef(r);

        if (selected.weapon) {
            const weapon = tx.moveCall({
                target: `${packageId}::recruit::remove_weapon`,
                arguments: [recruitArg],
            });

            tx.transferObjects([weapon], zkLogin.address);
        }

        tx.moveCall({
            target: `${packageId}::recruit::add_weapon`,
            arguments: [recruitArg, tx.objectRef(w)],
        });

        await executeTransaction(tx).then(console.log);
        setTimeout(() => {
            refetchWeapons();
            refetch();
        }, 1000);
        selected.weapon = w;
        setShowModal(false);
    }

    async function removeWeapon(r: Recruit) {
        if (!zkLogin.address) throw new Error("Not signed in");
        if (!executeTransaction) throw new Error("No transaction executor");
        if (isExecuting) throw new Error("Already executing a transaction");
        if (!selected) throw new Error("Recruit has to be selected");

        const tx = new Transaction();
        const weapon = tx.moveCall({
            target: `${packageId}::recruit::remove_weapon`,
            arguments: [tx.objectRef(r)],
        });

        tx.transferObjects([weapon], zkLogin.address);

        await executeTransaction(tx).then(console.log);
        setTimeout(() => {
            refetchWeapons();
            refetch();
        }, 1000);
        selected.weapon = null;
        setShowModal(false);
    }
}
