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
import { Editor } from "./Editor";
import { useTransactionExecutor } from "./useTransactionExecutor";

export default function Commander() {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const [mode, setMode] = useState<"play" | "edit">("play");
    const [game, setGame] = useState<typeof Game.$inferType | null>(null);

    const packageId = useNetworkVariable("commanderPackageId");
    const { executor, executeTransaction } = useTransactionExecutor({
        // @ts-ignore
        client,
        signer: () => flow.getKeypair({ network: "testnet" }),
        enabled: !!zkLogin.address,
    });
    const { data, isPending, refetch, error } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address || "",
            filter: { StructType: `${packageId}::commander::Game` },
            options: { showBcs: true, showOwner: true },
        },
        { enabled: !!zkLogin.address },
    );

    useEffect(() => {
        if (!data) return;
        if (!data.data[0]) return;
        if (!data.data[0].data) return;

        const object = data.data[0].data!;
        const { bcsBytes } = object.bcs as { bcsBytes: string };
        const game = Game.parse(fromB64(bcsBytes));

        setGame(game);
    }, [data]);

    if (!zkLogin.address) return <p>Please sign to play.</p>;
    if (isPending) return <p>Loading...</p>;
    if (error) return <p>Error: {error.message}</p>;
    if (game === null)
        return (
            <>
                <h1 className="text-2xl mb-2">
                    Commander (
                    <a href={`https://suiscan.xyz/testnet/object/${packageId}`}>Explorer</a>)
                </h1>
                <p className="w-1/2 word-break mb-2">
                    Commander is a simple sandbox implementation of a turn-based tactical game.
                    Currently, a solo experience, where you can try moving units around, perform
                    attacks on targets, and try your creativity in the "Editor" mode.
                </p>
                <p className="w-1/2 word-break mb-10">
                    If you're just starting, try the "Preset", if you want to experince a custom map
                    building experience, "Custom" option is your choice.
                </p>
                <p>
                    <button disabled={!zkLogin.address} onClick={() => newPreset()}>
                        New Game (Preset)
                    </button>
                </p>
                <p>
                    <button disabled={!zkLogin.address} onClick={() => newGame()}>
                        New Game (Custom)
                    </button>
                </p>
            </>
        );

    return (
        <div className="commander">
            <h1>Commander</h1>
            <p className="my-5">
                <button
                    onClick={() => setMode("play")}
                    className={mode == "play" ? "underline" : ""}
                >
                    Play
                </button>
                {" | "}
                <button
                    onClick={() => setMode("edit")}
                    className={mode == "edit" ? "underline" : ""}
                >
                    Edit
                </button>
            </p>
            {mode == "play" && (
                <Play game={game} refetch={() => refetch()} setGame={(value) => setGame(value)} />
            )}
            {mode == "edit" && (
                <Editor game={game} refetch={() => refetch()} setGame={(value) => setGame(value)} />
            )}
        </div>
    );

    async function newPreset() {
        if (!zkLogin.address) return;
        if (!executor) return;

        setMode("play");

        const tx = new Transaction();
        const game = tx.moveCall({ target: `${packageId}::commander::preset` });
        tx.transferObjects([game], zkLogin.address!);

        const { digest } = await executeTransaction(tx);
        await client.waitForTransaction({ digest });
        refetch();
    }

    async function newGame() {
        if (!zkLogin.address) return;
        if (!executor) return;

        setMode("edit");

        const tx = new Transaction();
        const game = tx.moveCall({
            target: `${packageId}::commander::new`,
            arguments: [tx.pure.u16(10), tx.pure.u16(10)], // width, height
        });

        tx.transferObjects([game], zkLogin.address!);

        const { digest } = await executeTransaction(tx);
        await client.waitForTransaction({ digest });
        refetch();
    }
}
