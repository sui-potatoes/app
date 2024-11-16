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
import { useState } from "react";

export function Crew() {
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const [isBlocked, setIsBlocked] = useState(false);
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { data: recruits, isRefetching, refetch } = useRecruits({ owner: zkLogin.address!, enabled: !!zkLogin.address });
    const { executeTransaction } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });

    if (!zkLogin.address) {
        return 'no zkLogin address';
    }

    const numRecruits = recruits?.length || 0;

    return (
        <div className="flex flex-col justify-center h-full">
            <h1 className="text-center">MY CREW</h1>
            <div className="flex justify-center align-middle">
                {/* columns template */}
                {isRefetching && <p>Loading...</p>}
                {!isRefetching && recruits && recruits.map((recruit) => (
                    <div key={recruit.id} className="col col-3 align-middle w-60 p-4 bg-black m-4 rounded">
                        <h2 className="text-center">{recruit.metadata.name} / {recruit.rank.$kind}</h2>
                        <img src="/images/recruit.webp" alt="recruit" />
                        <p className="text-center mt-3">{recruit.metadata.backstory}</p>
                        <p className="text-center italic">Unlock full backstory by completing missions</p>
                        <br />
                        <div className="flex justify-between">
                            <p>Aim: {recruit.stats.aim}</p>
                            <p>Health: {recruit.stats.health}</p>
                            <p>Mobility: {recruit.stats.mobility}</p>
                        </div>
                        <div className="flex justify-between">
                            <p>Dodge: {recruit.stats.dodge}</p>
                            <p>Will: {recruit.stats.will}</p>
                            <p>Hack: {recruit.stats.hack}</p>
                        </div>
                        <hr className="my-4" />
                        <div className="flex">
                            <p>Weapon: {recruit.weapon?.name || "Automatic Rifle"}</p>
                        </div>
                        <div className="flex justify-between">
                            <p>Damage: {recruit.weapon?.damage || 5}</p>
                            <p>Crit Chance: {recruit.weapon?.crit_chance || 0}</p>
                        </div>
                        <p className="text-center uppercase mt-2">
                            <button onClick={() => dismissRecruit(recruit.id)}>DISMISS</button>
                        </p>
                    </div>
                ))}
            </div>
            <div className="flex justify-center">
                <NavLink to="/commander-v2" className="menu-control">Back</NavLink>
                {numRecruits < 3 && <button onClick={() => hireRecruit().catch(console.log)} className="menu-control">Hire Recruit</button>}
            </div>
        </div>
    );

    /**
     * TODO:
     * - Improve name generator, so that it doesn't take so long to process, additionally, block the
     *  UI while the name is being generated and the transaction is being process.
     */
    async function hireRecruit() {
        if (!zkLogin.address) return;
        if (!executeTransaction) return;
        if (isBlocked) return;

        setIsBlocked(true);

        const { name, backstory } = await useNameGenerator();
        const tx = new Transaction();
        const recruit = tx.moveCall({
            target: `${packageId}::recruit::new`,
            arguments: [
                tx.pure.string(name),
                tx.pure.string(backstory),
            ]
        });

        tx.transferObjects([recruit], zkLogin.address);

        await executeTransaction(tx)!.wait();
        refetch();
        setIsBlocked(false);
    }

    /**
     * 
     * @param id 
     * @returns 
     */
    async function dismissRecruit(id: string) {
        if (!zkLogin.address) return;
        if (!executeTransaction) return;
        if (!confirm('Are you sure you want to dismiss a recruit?')) return;

        const tx = new Transaction();
        const weapon = tx.moveCall({
            target: `${packageId}::recruit::dismiss`,
            arguments: [tx.object(id)],
        });

        tx.moveCall({
            target: `${normalizeSuiAddress('0x1')}::option::destroy_none`,
            typeArguments: [`${packageId}::weapon::Weapon`],
            arguments: [weapon]
        });

        await executeTransaction(tx)!.wait().then(console.log);
        refetch();
    }
}
