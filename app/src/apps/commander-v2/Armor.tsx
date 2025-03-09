// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Transaction } from "@mysten/sui/transactions";
import { useNetworkVariable } from "../../networkConfig";
import { NavLink } from "react-router-dom";
import { useTransactionExecutor } from "./hooks/useTransactionExecutor";
import { fromBase64 } from "@mysten/bcs";
import { Armor as ArmorBcs } from "./types/bcs";
import { SuiObjectRef } from "@mysten/sui/client";
import { Footer, Loader, Slider } from "./Components";
import { useState } from "react";

type Armor = typeof ArmorBcs.$inferType & SuiObjectRef;

export function Armor() {
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const zkLogin = useZkLogin();
    const [selected, setSelected] = useState<Armor | undefined>();
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
    const {
        data: armors,
        isPending,
        isError,
        error,
        refetch,
    } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address,
            filter: { MoveModule: { package: packageId, module: "armor" } },
            options: { showBcs: true, showType: true },
        },
        {
            enabled: !!zkLogin.address,
            gcTime: 10000,
            select(data) {
                return data.data.map((obj) => {
                    // @ts-ignore
                    const armor = ArmorBcs.parse(fromBase64(obj.data?.bcs!.bcsBytes));
                    return {
                        ...armor,
                        objectId: obj.data?.objectId,
                        version: obj.data?.version,
                        digest: obj.data?.digest,
                    } as Armor & SuiObjectRef;
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

    // count identical armor pieces, keep just one unique in the navigation set
    const count: { [key: string]: number } = {};
    const displayed = armors.filter((a) => {
        if (a.name in count) {
            count[a.name]++;
            return false;
        }
        count[a.name] = 1;
        return true;
    });

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left text-uppercase text-lg p-10">
                <h1 className="block p-1 mb-10 uppercase white page-heading">
                    <NavLink to="../headquaters">HEADQUATERS</NavLink> / ARMOR
                </h1>
                <div className="flex justify-start">
                    <div className="text-uppercase text-lg w-96 rounded max-w-md hover:cursor-pointer h-500">
                        <div>
                            {displayed.map((a) => (
                                <div
                                    className={
                                        "options-row " +
                                        (selected?.name == a.name ? "selected" : "")
                                    }
                                    key={a.name}
                                    onClick={() => setSelected(a)}
                                >
                                    <label>{a.name}</label>
                                    <p>{count[a.name]}</p>
                                </div>
                            ))}
                        </div>
                        <div className="options-row mt-10" onClick={() => mintArmor(rngTier())}>
                            <div>New random piece</div>
                            <div>+</div>
                        </div>
                    </div>
                    {selected && (
                        <div className="size-max ml-10 text-lg max-w-3xl">
                            <div className="mb-10">
                                <h2 className="mb-2">DESCRIPTION</h2>
                                <p>
                                    Armor protects the wearer and decreases incoming damage.
                                    Depending on the type it may provide additional stat benefits or
                                    decreases.
                                </p>
                            </div>
                            <div>
                                <h2 className="mb-2">STATS</h2>
                                <div
                                    className="options-row"
                                    title="Rank is based on experience the unit has and progresses"
                                >
                                    <label>ARMOR</label>
                                    <Slider value={selected.stats.armor} maxValue={5} />
                                </div>
                                <div
                                    className="options-row"
                                    title="Change of avoiding damage completely if the weapon can be dodged"
                                >
                                    <label>DODGE</label>
                                    <Slider value={selected.stats.dodge} maxValue={100} />
                                </div>
                                <div
                                    className="options-row"
                                    title="Change of avoiding damage completely if the weapon can be dodged"
                                >
                                    <label>MOBILITY</label>
                                    <Slider value={selected.stats.mobility} maxValue={10} />
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <div className="text-left text-uppercase text-lg p-10 max-w-3xl"></div>
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

