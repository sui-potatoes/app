// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./character.css";
import { useEffect, useState } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { GO_BACK_KEY } from "../../App";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { Transaction } from "@mysten/sui/transactions";
import { fromB64 } from "@mysten/bcs";
import { useParams } from "react-router-dom";
import { Char } from "./Char";
import { bcs } from "@mysten/sui/bcs";
import { Param } from "./Param";
import { normalizeSuiAddress } from "@mysten/sui/utils";
import { toast, Toaster } from "react-hot-toast";

const image = bcs.struct("Props", {
    body_type: bcs.String,
    hair_type: bcs.String,
    body: bcs.String,
    hair: bcs.String,
    hairColour: bcs.String,
    eyesColour: bcs.String,
    pantsColour: bcs.String,
    skinColour: bcs.String,
    baseColour: bcs.String,
    accentColour: bcs.String,
});

const CharBCS = bcs.struct("Character", {
    id: bcs.Address,
    image,
});

export type Character = {
    body_type: string;
    hair_type: string;
    hairColour: string;
    eyesColour: string;
    skinColour: string;
    baseColour: string;
    pantsColour: string;
    accentColour: string;
};

export const COLOURS = [
    "be4a2f",
    "d77643",
    "ead4aa",
    "e4a672",
    "b86f50",
    "733e39",
    "3e2731",
    "a22633",
    "e43b44",
    "f77622",
    "feae34",
    "fee761",
    "63c74d",
    "3e8948",
    "265c42",
    "193c3e",
    "124e89",
    "0099db",
    "2ce8f5",
    // "ffffff",
    "c0cbdc",
    "8b9bb4",
    "5a6988",
    "3a4466",
    "262b44",
    "181425",
    "ff0044",
    "68386c",
    "b55088",
    "f6757a",
    "e8b796",
    "c28569",
];

export default function App() {
    const { id: urlId } = useParams();
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const client = useSuiClient();
    const packageId = useNetworkVariable("characterPackageId");
    const builderId = useNetworkVariable("characterBuilderId");
    const [characterId, setCharacterId] = useState(urlId);
    const [canInteract, setCanInteract] = useState(false);
    const {
        data: characters,
        refetch,
    } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin?.address!,
            options: { showBcs: true },
            filter: { StructType: `${packageId}::character::Character` },
        },
        { enabled: !!zkLogin },
    );
    const [char, setChar] = useState<Character>({
        hair_type: "wind",
        body_type: "office",
        hairColour: "0099db",
        eyesColour: "e43b44",
        skinColour: "c0cbdc",
        baseColour: "3a4466",
        pantsColour: "262b44",
        accentColour: "ead4aa",
    });

    const [initialCharacter, setInitialCharacter] = useState<string | null>(null);

    useEffect(() => {
        if (!characters) return;
        if (!characters.data.length) {
            setCanInteract(true);
            return;
        }

        const data = characters.data[0].data!;
        const { image } = CharBCS.parse(
            // @ts-ignore
            new Uint8Array(fromB64(data.bcs.bcsBytes)),
        );

        setCanInteract(true);
        setCharacterId(data.objectId);
        setChar({ ...image });
        setInitialCharacter(JSON.stringify({ ...image }));
    }, [characters]);

    const isConnected = !!zkLogin.address;
    const isSaveDisabled = !zkLogin.address || !canInteract || JSON.stringify(char) === initialCharacter;

    return (
        <div className="md:grid md:grid-cols-[1fr_auto] gap-5 flex flex-col items-center md:flex-none relative md:h-[calc(100vh-40px)] md:content-center">
            <div className="flex items-center justify-center relative">
                <Char {...char} />
                {!isConnected && (
                    <div className="absolute inset-0 z-10 flex items-center justify-center backdrop-blur-sm" style={{ background: "color-mix(in srgb, var(--background-color) 80%, transparent)" }}>
                        <p className="text-sm tracking-wider uppercase" style={{ color: "var(--text-color)" }}>
                            <button
                                style={{ color: "var(--accent-color)", textTransform: "uppercase" }}
                                onClick={async () => {
                                    localStorage.setItem(GO_BACK_KEY, window.location.href);
                                    history.pushState({}, "", "/");
                                    window.location.href = await flow.createAuthorizationURL({
                                        provider: "google",
                                        clientId: "591411088609-6kbt6b07a6np6mq2mnlq97i150amussh.apps.googleusercontent.com",
                                        redirectUrl: window.location.href.split("#")[0],
                                        network: "testnet",
                                    });
                                }}
                            >
                                Sign in
                            </button>{" "}
                            to use the app
                        </p>
                    </div>
                )}
            </div>
            <div className="flex flex-col gap-3 justify-center md:w-[240px] md:flex-shrink-0">
                <div className="sm-show text-sm tracking-wider uppercase">
                    <button
                        disabled={isSaveDisabled}
                        style={{ color: isSaveDisabled ? "var(--disabled-color)" : "var(--accent-color)", textTransform: "uppercase" }}
                        onClick={() => {
                            characterId ? updateCharacter(char) : createCharacter(char);
                        }}
                    >
                        {characterId ? "Update" : "Create"} Character{" "}
                        {!zkLogin.address && " (Login required)"}
                    </button>
                </div>
                <div className="text-sm tracking-wider uppercase">
                    <button
                        disabled={!canInteract}
                        style={{ color: "var(--accent-color)", textTransform: "uppercase" }}
                        onClick={() => {
                            const pick = (arr: string[]) => arr[Math.floor(Math.random() * arr.length)];
                            setChar({
                                hair_type: pick(["wind", "flat", "bang", "punk"]),
                                body_type: pick(["office", "blazer", "tshirt"]),
                                hairColour: pick(COLOURS),
                                eyesColour: pick(COLOURS),
                                skinColour: pick(COLOURS),
                                baseColour: pick(COLOURS),
                                pantsColour: pick(COLOURS),
                                accentColour: pick(COLOURS),
                            });
                        }}
                    >
                        Randomize
                    </button>
                </div>
                <Param
                        name="hair type"
                        defaultValue={char.hair_type}
                        disabled={!canInteract}
                        values={["wind", "flat", "bang", "punk"]}
                        onChange={(hair_type) => setChar({ ...char, hair_type })}
                    />
                    <Param
                        name="body type"
                        defaultValue={char.body_type}
                        disabled={!canInteract}
                        values={["office", "blazer", "tshirt"]}
                        onChange={(body_type) => setChar({ ...char, body_type })}
                    />
                    <Param
                        isColour
                        name="hair"
                        defaultValue={char.hairColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(hairColour) => setChar({ ...char, hairColour })}
                    />
                    <Param
                        isColour
                        name="eyes"
                        defaultValue={char.eyesColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(eyesColour) => setChar({ ...char, eyesColour })}
                    />
                    <Param
                        isColour
                        name="skin"
                        defaultValue={char.skinColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(skinColour) => setChar({ ...char, skinColour })}
                    />
                    <Param
                        isColour
                        name="base"
                        defaultValue={char.baseColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(baseColour) => setChar({ ...char, baseColour })}
                    />
                    <Param
                        isColour
                        name="pants"
                        defaultValue={char.pantsColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(pantsColour) => setChar({ ...char, pantsColour })}
                    />
                    <Param
                        isColour
                        name="accent"
                        defaultValue={char.accentColour}
                        disabled={!canInteract}
                        values={COLOURS}
                        onChange={(accentColour) => setChar({ ...char, accentColour })}
                    />
                    <div className="md-show param text-sm tracking-wider uppercase">
                        <button
                            style={{ padding: "20px 0", color: isSaveDisabled ? "var(--disabled-color)" : "var(--accent-color)", textTransform: "uppercase" }}
                            disabled={isSaveDisabled}
                            onClick={() => {
                                characterId ? updateCharacter(char) : createCharacter(char);
                            }}
                        >
                            {characterId ? "Update" : "Create"} Character{" "}
                            {!zkLogin.address && " (Login required)"}
                        </button>
                    </div>
                    {characterId && (
                        <div className="param text-sm tracking-wider uppercase" style={{ display: "block", margin: "10px 0" }}>
                            <a
                                href={`https://suiscan.xyz/testnet/object/${characterId}`}
                                target="_blank"
                                rel="noreferrer"
                                style={{ textTransform: "uppercase" }}
                            >
                                View on SuiScan
                            </a>
                        </div>
                    )}
            </div>
            <Toaster position="bottom-center" />
        </div>
    );

    /**
     * Send the `new` command to the `character` module.
     */
    async function createCharacter(data: Character) {
        if (!flow || !zkLogin) return;
        if (!canInteract) return;
        setCanInteract(false);

        const tx = new Transaction();
        const char = tx.moveCall({
            target: `${packageId}::character::new`,
            arguments: [
                tx.object(builderId),
                tx.pure.string(data.body_type),
                tx.pure.string(data.hair_type),
                tx.pure.string(data.eyesColour),
                tx.pure.string(data.hairColour),
                tx.pure.string(data.pantsColour),
                tx.pure.string(data.skinColour),
                tx.pure.string(data.baseColour),
                tx.pure.string(data.accentColour),
            ],
        });

        tx.transferObjects([char], zkLogin.address!);

        const result = await client.signAndExecuteTransaction({
            signer: (await flow.getKeypair({ network: "testnet" })) as any,
            transaction: tx as any,
        });

        console.log("Transaction sent", result.digest);
        await client.waitForTransaction({
            digest: result.digest,
            timeout: 10000,
            pollInterval: 500,
        });
        toast.success("Character created successfully!");
        refetch();
    }

    /**
     * Send the `update` command to the `character` module.
     */
    async function updateCharacter(data: Character) {
        if (!flow || !zkLogin) return;
        if (!canInteract) return;
        if (!characterId) return;
        setCanInteract(false);

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::character::edit`,
            arguments: [
                tx.object(builderId),
                tx.object(characterId),
                tx.pure.string(data.body_type),
                tx.pure.string(data.hair_type),
                tx.pure.string(data.eyesColour),
                tx.pure.string(data.hairColour),
                tx.pure.string(data.pantsColour),
                tx.pure.string(data.skinColour),
                tx.pure.string(data.baseColour),
                tx.pure.string(data.accentColour),
            ],
        });

        const result = await client.signAndExecuteTransaction({
            signer: (await flow.getKeypair({ network: "testnet" })) as any,
            transaction: tx as any,
        });

        console.log("Transaction sent", result.digest);
        await client.waitForTransaction({
            digest: result.digest,
            timeout: 10000,
            pollInterval: 500,
        });
        toast.success("Character updated successfully!");

        refetch();
    }

    /**
     * Get the character image from the builder Move module.
     *
     * Currently unused to avoid unnecessary Move calls and improve UI, but if
     * the builder object was modifiable, this would be the way to get the image.
     */
    // @ts-ignore
    async function getCharacter(data: Character) {
        setCanInteract(false);
        const inspect = new Transaction();
        inspect.moveCall({
            target: `${packageId}::character::new`,
            arguments: [
                inspect.object(builderId),
                inspect.pure.string(data.body_type),
                inspect.pure.string(data.hair_type),
                inspect.pure.string(data.hairColour),
                inspect.pure.string(data.eyesColour),
                inspect.pure.string(data.pantsColour),
                inspect.pure.string(data.skinColour),
                inspect.pure.string(data.baseColour),
                inspect.pure.string(data.accentColour),
            ],
        });

        const { results, error } = await client.devInspectTransactionBlock({
            sender: normalizeSuiAddress("0xa11ce"),
            transactionBlock: inspect as any,
        });

        if (!results || !results[0] || !results[0].returnValues) {
            console.error("Invalid character", error);
            setCanInteract(true);
            return;
        }

        // const [bcsBytes, _type] = results[0].returnValues[0];
        // const { body, hair } = CharBCS.parse(new Uint8Array(bcsBytes)).image;

        setChar(data);
        // setExtra(body + hair); // both urlencoded!
        setCanInteract(true);
    }
}
