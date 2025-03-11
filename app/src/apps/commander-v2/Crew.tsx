// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { Transaction } from "@mysten/sui/transactions";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { useRecruits, Recruit } from "./hooks/useRecruits";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiAddress } from "@mysten/sui/utils";
import { useNameGenerator } from "./hooks/useNameGenerator";
import { SuiObjectRef } from "@mysten/sui/client";
import { Footer, Modal, StatRecord } from "./Components";
import { useState } from "react";
import { Armor, useArmor } from "./hooks/useArmor";
import { armorMetadata } from "./types/metadata";

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
    const { data: recruits, refetch } = useRecruits({
        owner: zkLogin.address!,
        enabled: !!zkLogin.address,
    });

    // const { data: weapons, isPending: weaponsFetching } = useWeapons({ address: zkLogin.address });
    const { data: armors, isPending: _armorsFetching } = useArmor({
        address: zkLogin.address,
        unique: true,
    });

    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10">
                <h1 className="p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../headquaters">HEADQUATERS</NavLink> / CREW
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
                                <p>
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
                                        modifier={selected.armor?.stats}
                                        className="options-row"
                                    />
                                ))}
                            </div>

                            <div className="mt-10 w-full flex justify-between">
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">WEAPON</h3>
                                    {(selected.weapon && <></>) || (
                                        <div className="px-20 py-10 text-center interactive">
                                            +
                                        </div>
                                    )}
                                </div>
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">ARMOR</h3>
                                    {(selected.armor && (
                                        <>
                                            <div
                                                className="h-30 px-2 py-2 text-center interactive"
                                                style={{ maxWidth: "150px" }}
                                            >
                                                <img
                                                    src={armorMetadata(selected.armor.name).image}
                                                />
                                                <label className="mt-2">
                                                    {selected.armor.name}
                                                </label>
                                                {/* {["armor", "dodge", "mobility"].map((stat) => (
                                                    <div className="flex justify-between">
                                                        <div>{stat.toUpperCase()}</div>
                                                        <div>
                                                            {(selected.armor!.stats as any)[stat]}
                                                        </div>
                                                    </div>
                                                ))} */}
                                            </div>
                                        </>
                                    )) || (
                                        <div
                                            className="px-20 py-10 text-center interactive"
                                            onClick={() => setShowModal("armor")}
                                        >
                                            +
                                        </div>
                                    )}
                                </div>
                                {/* Utility slot  */}
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">UTILITY</h3>
                                    <div className="px-20 py-10 text-center interactive">
                                        +
                                    </div>
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
                        {armors?.reverse().map((a) => {
                            return (
                                <div
                                    className="text-xl m-10 p-10 option-row interactive"
                                    key={a.name}
                                >
                                    <label className="text-xl mb-10">{a.name}</label>
                                    <img src={armorMetadata(a.name).image} />
                                    {["armor", "dodge", "mobility"].map((stat) => (
                                        <div className="flex justify-between">
                                            <div>{stat.toUpperCase()}</div>
                                            <div>{(a.stats as any)[stat]}</div>
                                        </div>
                                    ))}
                                    <button
                                        className="yes-no"
                                        style={{
                                            width: "100%",
                                            margin: "20px 0 0 0",
                                            padding: "10px 15px",
                                        }}
                                        onClick={() => addArmor(selected!, a)}
                                    >
                                        select
                                    </button>
                                </div>
                            );
                        })}
                    </div>
                )}
            </Modal>
            <Footer to="../headquaters" />
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

        tx.moveCall({
            target: `${packageId}::recruit::add_armor`,
            arguments: [tx.objectRef(r), tx.objectRef(a)],
        });

        await executeTransaction(tx).then(console.log);
        setTimeout(() => refetch(), 1000);
        selected.armor = a;
        setShowModal(false);
    }
}
