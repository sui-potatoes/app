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
import { Footer } from "./Components";
import { useState } from "react";
import { Slider } from "./Components";

export function Crew() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const [selected, setSelected] = useState<Recruit | undefined>();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const {
        data: recruits,
        // isRefetching,
        // isFetching,
        refetch,
    } = useRecruits({ owner: zkLogin.address!, enabled: !!zkLogin.address });
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (!zkLogin.address) {
        return "no zkLogin address";
    }

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10">
                <h1 className="block p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../headquaters">HEADQUATERS</NavLink> / CREW
                </h1>
                <div className="flex justify-start">
                    <div className="text-uppercase text-lg w-96 rounded max-w-md hover:cursor-pointer h-500">
                        <div>
                            {recruits?.map((r) => {
                                return (
                                    <div
                                        key={r.objectId}
                                        className={
                                            "options-row " +
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
                            className={`options-row text-center ${(recruits?.length || 0) > 1 ? "mt-10" : ""}`}
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
                                <div
                                    className="options-row"
                                    title="Change of hitting the target at effective range"
                                >
                                    <label>AIM</label>
                                    <div className="ml-24">
                                        <Slider value={selected.stats.aim} maxValue={100} />
                                    </div>
                                </div>
                                <div
                                    className="options-row"
                                    title="Number of health points a recruit has"
                                >
                                    <label>HEALTH</label>
                                    <div className="ml-24">
                                        <Slider value={selected.stats.health} maxValue={20} />
                                    </div>
                                </div>
                                <div
                                    className="options-row"
                                    title="How many tiles Unit can move in a single action"
                                >
                                    <label>MOBILITY</label>
                                    <div className="ml-24">
                                        <Slider value={selected.stats.mobility} maxValue={10} />
                                    </div>
                                </div>
                                <div className="options-row" title="Incoming damage negation value">
                                    <label>ARMOR</label>
                                    <div className="ml-24">
                                        <Slider value={selected.stats.armor} maxValue={5} />
                                    </div>
                                </div>
                                <div className="options-row" title="Chance of dodging the ">
                                    <label>DODGE</label>
                                    <div className="ml-24">
                                        <Slider value={selected.stats.dodge} maxValue={100} />
                                    </div>
                                </div>
                            </div>

                            <div className="mt-10 w-full flex justify-between">
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">WEAPON</h3>
                                    {(selected.weapon && <></>) || (
                                        <div
                                            className="h-30 border border-grey px-20 py-10 uppercase text-center hover:cursor-pointer"
                                            style={{ borderWidth: "0.01em" }}
                                        >
                                            +
                                        </div>
                                    )}
                                </div>
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">ARMOR</h3>
                                    {(selected.armor && <></>) || (
                                        <div
                                            className="h-30 border border-grey px-20 py-10 uppercase text-center hover:cursor-pointer"
                                            style={{ borderWidth: "0.01em" }}
                                        >
                                            +
                                        </div>
                                    )}
                                </div>
                                <div className="my-auto">
                                    <h3 className="text-left mb-4">UTILITY</h3>
                                    {(selected.armor && <></>) || (
                                        <div
                                            className="h-30 w-30 border border-grey px-20 py-10 uppercase text-center hover:cursor-pointer"
                                            style={{ borderWidth: "0.01em" }}
                                        >
                                            +
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
}
