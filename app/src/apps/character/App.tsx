// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./character.css";
import { useEffect, useState } from "react";
import { useCurrentAccount } from "@mysten/dapp-kit-react";
import { Transaction } from "@mysten/sui/transactions";
import { useParams } from "react-router-dom";
import { Char } from "./Char";
import { bcs } from "@mysten/sui/bcs";
import { Param } from "./Param";
import { toast, Toaster } from "react-hot-toast";
import {
    CHARACTER_BUILDER_ID as builderId,
    CHARACTER_PACKAGE_ID as packageId,
} from "../../constants";
import { explorerUrl } from "../../explorer";
import { useOwnedBcsObjects } from "../../hooks/useBcsObjects";
import { useGoogleSignIn } from "../../hooks/useGoogleSignIn";
import { useSignAndExecute } from "../../hooks/useSignAndExecute";

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
    const account = useCurrentAccount();
    const address = account?.address;
    const { signIn } = useGoogleSignIn();
    const signAndExecute = useSignAndExecute();
    const [characterId, setCharacterId] = useState(urlId);
    const [canInteract, setCanInteract] = useState(false);
    const { data: characters, refetch } = useOwnedBcsObjects({
        owner: address,
        type: `${packageId}::character::Character`,
        schema: CharBCS,
    });
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
        if (!characters.length) {
            setCanInteract(true);
            return;
        }

        const { objectId, image } = characters[0];

        setCanInteract(true);
        setCharacterId(objectId);
        setChar({ ...image });
        setInitialCharacter(JSON.stringify({ ...image }));
    }, [characters]);

    const isConnected = !!address;
    const isSaveDisabled = !address || !canInteract || JSON.stringify(char) === initialCharacter;

    return (
        <div className="md:grid md:grid-cols-[1fr_auto] gap-10 md:gap-16 flex flex-col items-center md:flex-none relative md:h-[calc(100vh-40px)] md:content-center">
            <div className="flex items-center justify-center relative">
                <Char {...char} />
                {!isConnected && (
                    <div className="absolute inset-0 z-10 flex items-center justify-center backdrop-blur-sm bg-overlay">
                        <p className="text-sm tracking-wider uppercase text-foreground">
                            <button
                                className="text-brand hover:text-brand uppercase"
                                onClick={() => signIn()}
                            >
                                Sign in
                            </button>{" "}
                            to use the app
                        </p>
                    </div>
                )}
            </div>
            <div className="flex flex-col gap-3 justify-center md:w-[240px] md:flex-shrink-0">
                <div className="flex flex-col gap-1.5">
                    <div className="text-sm tracking-wider uppercase">Character</div>
                    <p className="text-secondary text-[11px] tracking-wider uppercase">
                        {!address
                            ? "sign in to edit"
                            : characterId
                              ? "editing your character"
                              : "new character"}
                    </p>
                    <div className="w-[60px] h-px bg-line mt-1" />
                </div>
                <div className="text-sm tracking-wider uppercase">
                    <button
                        disabled={isSaveDisabled}
                        className="btn btn-primary w-full"
                        onClick={() =>
                            characterId ? updateCharacter(char) : createCharacter(char)
                        }
                    >
                        {characterId ? "Update" : "Create"} Character
                    </button>
                    {!address && (
                        <p className="text-secondary text-[11px] tracking-wider uppercase mt-1.5">
                            sign in to save
                        </p>
                    )}
                </div>
                <div className="text-sm tracking-wider uppercase">
                    <button
                        disabled={!canInteract}
                        className="btn w-full"
                        onClick={() => {
                            const pick = (arr: string[]) =>
                                arr[Math.floor(Math.random() * arr.length)];
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
                {characterId && (
                    <div className="param block my-[10px] text-sm tracking-wider uppercase">
                        <a
                            href={explorerUrl(characterId)}
                            target="_blank"
                            rel="noreferrer"
                            className="uppercase"
                        >
                            View on devxplorer
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
        if (!address) return;
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

        tx.transferObjects([char], address);

        await signAndExecute(tx);
        toast.success("Character created successfully!");
        refetch();
    }

    /**
     * Send the `update` command to the `character` module.
     */
    async function updateCharacter(data: Character) {
        if (!address) return;
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

        await signAndExecute(tx);
        toast.success("Character updated successfully!");

        refetch();
    }
}
