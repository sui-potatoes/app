// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { Transaction } from "@mysten/sui/transactions";
import { useEffect, useState } from "react";
import { Game } from "./types";
import { fromB64 } from "@mysten/bcs";
import { Play } from "./Play";

import "./commander.css";

export default function Commander() {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const [game, setGame] = useState<typeof Game.$inferType | null>(null);

    const packageId = useNetworkVariable("commanderPackageId");
    const { data, isPending, refetch, error } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address || "",
            filter: { StructType: `${packageId}::commander::Game` },
            options: { showBcs: true },
        },
        { enabled: !!zkLogin.address },
    );

    useEffect(() => {
        if (!data) return;
        if (!data.data[0]) return;
        if (!data.data[0].data) return;

        const { bcsBytes } = data.data[0].data.bcs as { bcsBytes: string };

        const game = Game.parse(fromB64(bcsBytes));
        setGame(game);
    }, [data]);

    if (isPending) return <p>Loading...</p>;
    if (error) return <p>Error: {error.message}</p>;
    if (game === null)
        return (
            <>
                <h1>Commander</h1>
                <p>Package ID: {packageId}</p>
                <p>
                    <button
                        disabled={!zkLogin.address}
                        onClick={() => newPreset()}
                    >
                        New Game (Preset)
                    </button>
                </p>
                <p>
                    <button
                        disabled={!zkLogin.address}
                        onClick={() => newGame()}
                    >
                        New Game (Custom)
                    </button>
                </p>
            </>
        );

    return (
        // I want tailwind columns, so that the map is 2/3 of the screen and the unit stats are 1/3
        <Play game={game} refetch={() => refetch()} setGame={(value) => setGame(value)} />
    );

    async function newPreset() {
        if (!zkLogin.address) return;

        const tx = new Transaction();
        const game = tx.moveCall({ target: `${packageId}::commander::preset` });
        tx.transferObjects([game], zkLogin.address!);

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        await refetch();
    }

    async function newGame() {
        if (!zkLogin.address) return;

        const tx = new Transaction();
        const game = tx.moveCall({
            target: `${packageId}::commander::new`,
            arguments: [tx.pure.u16(10), tx.pure.u16(10)], // width, height
        });

        tx.transferObjects([game], zkLogin.address!);

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        await refetch();
    }
}
