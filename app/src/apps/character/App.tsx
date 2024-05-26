import "./character.css";
import { useEffect, useState } from "react";
// import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useSuiClient, useSuiClientQuery } from "@mysten/dapp-kit";
import { useNetworkVariable } from "../../networkConfig";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import { fromB64 } from "@mysten/bcs";
import { useParams } from "react-router-dom";
import { Char } from "./Char";
import { bcs } from "@mysten/sui.js/bcs";
import { Param } from "./Param";
import { normalizeSuiAddress } from "@mysten/sui.js/utils";

const image = bcs.struct("Props", {
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
    body: string;
    hair: string;
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

export function App() {
    const { id: characterId } = useParams();
    // const flow = useEnokiFlow();
    // const zkLogin = useZkLogin();
    const client = useSuiClient();
    const packageId = useNetworkVariable("characterPackageId");
    const builderId = useNetworkVariable("characterBuilderId");
    // const navigate = useNavigate();
    const [char, setChar] = useState<Character>({
        body: "office",
        hair: "wind",
        hairColour: "0099db",
        eyesColour: "e43b44",
        skinColour: "c0cbdc",
        baseColour: "3a4466",
        pantsColour: "262b44",
        accentColour: "ead4aa",
    });

    const [extra, setExtra] = useState("");
    const [canInteract, setCanInteract] = useState(true);
    const { data: character } = useSuiClientQuery("getObject", {
        id: characterId || "",
        options: { showBcs: true },
    });

    useEffect(() => {
        if (!character?.data) return;
        setChar(() => ({
            // @ts-ignore
            ...CharBCS.parse(fromB64(character.data.bcs.bcsBytes)).image,
        }));
    }, [character]);

    return (
        <div className="columns">
            <div className="character-select column">
                <Char {...char} extra={extra} />
            </div>
            <div
                className="column"
                style={{
                    display: "flex",
                    flexDirection: "column",
                    justifyContent: "center",
                }}
            >
                <Param
                    name="hair"
                    defaultValue="wind"
                    disabled={!canInteract}
                    values={["wind", "flat", "bang", "punk"]}
                    onChange={(hair) => setChar({ ...char, hair })}
                />
                <Param
                    name="body"
                    defaultValue="office"
                    disabled={!canInteract}
                    values={["office", "blazer", "tshirt"]}
                    onChange={(body) => setChar({ ...char, body })}
                />
                <Param
                    isColour
                    name="hair"
                    defaultValue="0099db"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(hairColour) => {
                        console.log('change hair', hairColour);
                        setChar({ ...char, hairColour })
                    }}
                />
                <Param
                    isColour
                    name="eyes"
                    defaultValue="e43b44"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(eyesColour) => setChar({ ...char, eyesColour })}
                />
                <Param
                    isColour
                    name="skin"
                    defaultValue="c0cbdc"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(skinColour) => setChar({ ...char, skinColour })}
                />
                <Param
                    isColour
                    name="base"
                    defaultValue="3a4466"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(baseColour) => setChar({ ...char, baseColour })}
                />
                <Param
                    isColour
                    name="pants"
                    defaultValue="262b44"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(pantsColour) =>
                        setChar({ ...char, pantsColour })
                    }
                />
                <Param
                    isColour
                    name="accent"
                    defaultValue="ead4aa"
                    disabled={!canInteract}
                    values={COLOURS}
                    onChange={(accentColour) =>
                        setChar({ ...char, accentColour })
                    }
                />
            </div>
        </div>
    );

    /**
     * Get the character image from the builder Move module.
     *
     * Currently unused to avoid unnecessary Move calls and improve UI, but if
     * the builder object was modifiable, this would be the way to get the image.
     */
    // @ts-ignore
    async function getCharacter(data: Character) {
        setCanInteract(false);
        const inspect = new TransactionBlock();
        inspect.moveCall({
            target: `${packageId}::character::new`,
            arguments: [
                inspect.object(builderId),
                inspect.pure.string(data.body),
                inspect.pure.string(data.hair),
                inspect.pure.string(data.hairColour),
                inspect.pure.string(data.eyesColour),
                inspect.pure.string(data.pantsColour),
                inspect.pure.string(data.skinColour),
                inspect.pure.string(data.baseColour),
                inspect.pure.string(data.accentColour),
            ],
        });

        const { results, error } = await client.devInspectTransactionBlock({
            sender: normalizeSuiAddress('0xa11ce'), // @ts-ignore
            transactionBlock: inspect,
        });

        if (!results || !results[0] || !results[0].returnValues) {
            console.error("Invalid character", error);
            setCanInteract(true);
            return;
        }

        const [bcsBytes, _type] = results[0].returnValues[0];
        const { body, hair } = CharBCS.parse(new Uint8Array(bcsBytes)).image;

        setChar(data);
        setExtra(body + hair); // both urlencoded!
        setCanInteract(true);
    }
}
