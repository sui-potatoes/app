// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { NavLink } from "react-router-dom";
import { Transaction } from "@mysten/sui/transactions";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { useRecruits } from "./hooks/useRecruits";
import { useSuiClient } from "@mysten/dapp-kit";
import { normalizeSuiAddress } from "@mysten/sui/utils";
import { useNameGenerator } from "./hooks/useNameGenerator";
import { SuiObjectRef } from "@mysten/sui/client";
import { Loader } from "./Loader";

export function Crew() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const {
        data: recruits,
        isRefetching,
        isFetching,
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

    const numRecruits = recruits?.length || 0;

    return (
        <div className="flex flex-col justify-center h-full">
            <h1 className="text-center">MY CREW ({numRecruits} / 3)</h1>
            <div className="flex justify-center align-middle">
                {(isFetching || isExecuting) && <Loader />}
                {!isRefetching &&
                    recruits &&
                    recruits.concat(blanks(3 - numRecruits)).map((recruit) => (
                        <div
                            key={recruit.id}
                            className="col col-3 align-middle w-60 p-4 m-4 rounded"
                        >
                            {recruit.metadata.name == "Blank" ? (
                                <>
                                    <p
                                        title="Hire a new recruit"
                                        className="text-center recruit-blank"
                                        onClick={() => hireRecruit()}
                                    >
                                        +
                                    </p>
                                </>
                            ) : (
                                <>
                                    <div className="image-card">
                                        <img src="/images/recruit.webp" alt="recruit" />
                                        <div className="card-image-overlay">
                                            <h2 className="text-center">
                                                {recruit.metadata.name} | {recruit.rank.$kind}
                                            </h2>
                                        </div>
                                        <div
                                            title="Dismiss recruit"
                                            className="card-dismiss-cross"
                                            onClick={() => dismissRecruit(recruit)}
                                        >
                                            &#10005;
                                        </div>
                                    </div>
                                    {/* <p className="text-center mt-3">{recruit.metadata.backstory}</p>
                                    <p className="text-center italic">
                                        Unlock full backstory by completing missions
                                    </p> */}
                                    <br />
                                    {/* <div className="flex justify-between">
                                        <p>Aim: {recruit.stats.aim}</p>
                                        <p>Health: {recruit.stats.health}</p>
                                        <p>Mobility: {recruit.stats.mobility}</p>
                                    </div>
                                    <div className="flex justify-between">
                                        <p>Dodge: {recruit.stats.dodge}</p>
                                    </div>
                                    <hr className="my-4" />
                                    <div className="flex">
                                        <p>Weapon: {recruit.weapon?.name || "Automatic Rifle"}</p>
                                    </div>
                                    <div className="flex justify-between">
                                        <p>Damage: {recruit.weapon?.stats.damage || 5}</p>
                                        <p>Crit Chance: {recruit.weapon?.stats.damage || 0}</p>
                                    </div> */}
                                </>
                            )}
                        </div>
                    ))}
            </div>
            <div className="flex justify-center">
                <NavLink to="/commander" className="menu-control">
                    Back
                </NavLink>
            </div>
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
        setTimeout(() => refetch(), 1000);
    }
}

function blanks(n: number): any[] {
    let recruits = [];
    for (let i = 0; i < n; i++) {
        recruits.push({
            id: (i + 100).toString(),
            stats: { aim: 0, dodge: 0, health: 0, mobility: 0 },
            rank: { Rookie: true },
            metadata: { name: "Blank", backstory: "Blank" },
            weapon: null,
            armor: null,
        });
    }
    return recruits;
}
