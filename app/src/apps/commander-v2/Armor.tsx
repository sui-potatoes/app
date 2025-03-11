// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { NavLink } from "react-router-dom";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { Footer, Loader, StatRecord } from "./Components";
import { useState } from "react";
import { type Armor, useArmor } from "./hooks/useArmor";
import { armorMetadata } from "./types/metadata";

export const ARMOR_STATS: StatRecord[] = [
    {
        key: "armor",
        name: "ARMOR",
        maxValue: 3,
        description: "Incoming damage negation value",
    },
    {
        key: "dodge",
        name: "DODGE",
        maxValue: 100,
        description: "Chance of dodging incoming damage",
    },
    {
        key: "mobility",
        name: "MOBILITY",
        maxValue: 10,
        description: "How many tiles this unit can move in a single action",
    },
];

export function Armor() {
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const zkLogin = useZkLogin();
    const [selected, setSelected] = useState<Armor | undefined>();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { data, isPending, error, isError, refetch } = useArmor({ address: zkLogin.address });
    const { executeTransaction, isExecuting } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (isPending || isExecuting) return <Loader />;
    if (isError) {
        return (
            <div className="flex justify-center align-middle h-screen flex-col">
                <div>Error: {error.message}</div>
            </div>
        );
    }

    // count identical armor pieces, keep just one unique in the navigation set
    const count: { [key: string]: number } = {};
    const displayed = data.filter((a) => {
        if (a.name in count) {
            count[a.name]++;
            return false;
        }
        count[a.name] = 1;
        return true;
    });

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left p-10">
                <h1 className="block p-1 mb-10 page-heading">
                    <NavLink to="../headquaters">HEADQUATERS</NavLink> / ARMOR
                </h1>
                <div className="flex justify-start">
                    <div className="w-96 max-w-md">
                        <div>
                            {displayed.map((a) => (
                                <div
                                    className={
                                        "options-row interactive " +
                                        (selected?.name == a.name ? "selected" : "")
                                    }
                                    key={a.name}
                                    onClick={() => setSelected(a)}
                                >
                                    <a>{a.name}</a>
                                    <p>{count[a.name]}</p>
                                </div>
                            ))}
                        </div>
                        <div
                            className="options-row interactive mt-10"
                            onClick={() => mintArmor(rngTier())}
                        >
                            <div>New random piece</div>
                            <div>+</div>
                        </div>
                    </div>
                    {selected && (
                        <div className="size-max ml-10 max-w-3xl">
                            <div className="mb-10">
                                <h2 className="mb-2">DESCRIPTION</h2>
                                <img src={armorMetadata(selected.name).image} />
                                <p>
                                    Armor protects the wearer and decreases incoming damage.
                                    Depending on the type it may provide additional stat benefits or
                                    decreases.
                                </p>
                            </div>
                            <div>
                                <h2 className="mb-2">STATS</h2>
                                {ARMOR_STATS.map((record) => (
                                    <StatRecord
                                        key={record.key}
                                        record={record}
                                        stats={selected.stats}
                                        className="options-row"
                                    />
                                ))}
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <Footer to="../headquaters" />
        </div>
    );

    /**w
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

    // async function throwAway(ref: SuiObjectRef) {
    //     if (!zkLogin.address) throw new Error("Not logged in");
    //     if (!executeTransaction) throw new Error("No transaction executor");
    //     if (isExecuting) throw new Error("Already executing a transaction");

    //     const tx = new Transaction();
    //     tx.moveCall({
    //         target: `${packageId}::armor::destroy`,
    //         arguments: [tx.objectRef(ref)],
    //     });

    //     await executeTransaction(tx);
    //     refetch();
    // }
}

function rngTier(): number {
    return +(((Math.random() * 10000) % 2) + 1).toFixed(0);
}
