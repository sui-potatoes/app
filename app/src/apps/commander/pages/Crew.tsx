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
import { SuiObjectRef, SuiTransactionBlockResponse } from "@mysten/sui/client";
import { Modal, StatRecord, Loader, GameScreen } from "./Components";
import { useState } from "react";
import { Armor, useArmor } from "../hooks/useArmor";
import { armorMetadata, weaponMetadata } from "../types/metadata";
import { useWeapons, Weapon } from "../hooks/useWeapons";
import { WEAPON_STATS } from "./Weapons";
import { mergeStats } from "../types/bcs";
import { Character } from "./play/Character";
import { fromHex } from "@mysten/bcs";

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
    } = useRecruits({ owner: zkLogin.address!, enabled: !!zkLogin.address });

    const {
        data: weapons,
        refetch: refetchWeapons,
        isPending: weaponsFetching,
    } = useWeapons({ address: zkLogin.address, unique: true });

    const {
        data: armors,
        refetch: refetchArmors,
        isPending: armorsFetching,
    } = useArmor({ address: zkLogin.address, unique: true });

    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const canTransact = !!zkLogin.address && !!executeTransaction;

    if (weapons && selected?.weapon) weapons.unshift(selected.weapon as Weapon);
    if (armors && selected?.armor && !armors.some((a) => a.name == selected.armor?.name)) {
        armors.unshift(selected.armor as Armor);
    }

    if (isPending || isExecuting) return <Loader />;

    // prettier-ignore
    const title = <><NavLink to="../headquarters">HEADQUARTERS</NavLink> / CREW</>;

    return (
        <GameScreen footerTo="../headquarters" className="justify-between" title={title}>
            <div className="w-xs">
                <h2 className="mb-2">RECRUITS</h2>
                <div className="overflowing">
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
                                {/* <div>({r.rank.$kind})</div> */}
                            </div>
                        );
                    })}
                </div>
                <div
                    key="new-recruit"
                    className={`options-row text-center ${(recruits?.length || 0) > 1 ? "mt-10" : ""} ${!canTransact ? "non-interactive" : "interactive"}`}
                    onClick={hireRecruit}
                >
                    <div>NEW HIRE</div>
                    <div>+</div>
                </div>
            </div>
            {selected && (
                <>
                    <div className="w-auto h-screen min-w-xl">
                        <Character morphTargets={[...fromHex(selected.id)].map((e) => e / 200)} />
                    </div>
                    <div className="text-lg w-xl overflowing">
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
                        <h2 className="mt-10 text-left">EQUIPMENT</h2>
                        <div className="w-full">
                            {/* Weapon selection */}
                            <div className="options-row">
                                <h3 className="text-left">WEAPON</h3>
                                <div
                                    style={{ border: "none" }}
                                    className="interactive px-4"
                                    onClick={() => setShowModal("weapon")}
                                >
                                    {selected && selected.weapon
                                        ? `${selected.weapon.name}${selected.weapon.upgrades.length > 0 ? "+" : ""}`
                                        : "Standard Rifle"}
                                </div>
                            </div>
                            {/* Armor selection */}
                            {/* max width is 30% of the container */}
                            <div className="options-row">
                                <h3 className="text-left">ARMOR</h3>
                                {(selected.armor && (
                                    <>
                                        <div
                                            style={{ border: "none" }}
                                            className="interactive px-4 h-full"
                                            onClick={() => setShowModal("armor")}
                                        >
                                            {selected.armor.name}
                                        </div>
                                    </>
                                )) || (
                                    <div
                                        style={{ width: "180px" }}
                                        className="text-center interactive px-4"
                                        onClick={() => setShowModal("armor")}
                                    >
                                        Select armor
                                    </div>
                                )}
                            </div>
                        </div>
                        <div
                            className="mt-10 py-10 yes-no"
                            style={{ width: "200", marginLeft: "0", padding: "10px 0" }}
                            onClick={() => dismissRecruit(selected)}
                        >
                            DISMISS
                        </div>
                    </div>
                </>
            )}
            <Modal show={!!showModal} onClose={() => setShowModal(false)}>
                {/* armor selection modal */}
                {showModal === "armor" && (
                    <div className="flex justify-between" onClick={(e) => e.preventDefault()}>
                        {armors?.length == 0 && (
                            <div className="m-auto flex flex-col items-center">
                                <p>Armor inventory is empty.</p>
                                <p>Win armor by challenging other players</p>
                            </div>
                        )}
                        {armorsFetching && <Loader />}
                        {!armorsFetching &&
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
                        className="flex flex-col"
                        style={{ height: "95vh", marginTop: "5vh" }}
                    >
                        {weapons?.length == 0 && (
                            <div className="m-auto flex flex-col items-center">
                                <p>Weapon inventory is empty.</p>
                                <p>Win weapons by challenging other players</p>
                            </div>
                        )}
                        {weaponsFetching && <Loader />}
                        <div className="mt-10"></div>
                        {!weaponsFetching &&
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
        </GameScreen>
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

        await executeTransaction(tx);
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

        const { data } = await executeTransaction(tx);
        updateRef(data);

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

        const { data } = await executeTransaction(tx);
        updateRef(data);

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

        const { data } = await executeTransaction(tx);
        updateRef(data);

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

        const { data } = await executeTransaction(tx);
        updateRef(data);

        setTimeout(() => {
            refetchWeapons();
            refetch();
        }, 1000);
        selected.weapon = null;
        setShowModal(false);
    }

    function updateRef(data?: SuiTransactionBlockResponse) {
        if (!selected) return;
        if (!data) throw new Error("Expected transaction data");
        if (!data.objectChanges) throw new Error("Expected object changes");

        const objectId = selected.objectId;
        const newRef = data.objectChanges.find(
            (c) => c.type === "mutated" && c.objectId == objectId,
        ) as SuiObjectRef | undefined;

        if (!newRef) throw new Error("Expected new object reference");

        selected.objectId = newRef.objectId;
        selected.version = newRef.version;
        selected.digest = newRef.digest;
    }
}
