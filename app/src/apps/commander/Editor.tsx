// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClient } from "@mysten/dapp-kit";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../networkConfig";
import { Game, Unit } from "./types";
import { useState } from "react";
import { EditorMap } from "./EditorMap";
import { Transaction } from "@mysten/sui/transactions";

type Props = {
    game: typeof Game.$inferType;
    refetch: () => void;
    setGame: (game: any) => void;
};

type SelectedTile = {
    tile: typeof Unit.$inferType | null;
    x: number;
    y: number;
};

// type Change = {
//     kind: string;
//     x: number;
//     y: number;
// };

export function Editor({ game, refetch }: Props) {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const packageId = useNetworkVariable("commanderPackageId");

    const [tile, setTile] = useState<SelectedTile | null>(null);
    // const [changes, setChanges] = useState<Change[]>([]);
    const [inventory, setInventory] = useState<string>();
    const [tool, setTool] = useState<"place" | "remove">("place");
    const [wait, setWait] = useState(false);

    const isEmpty = tile && game.map.grid[tile?.x][tile?.y].$kind === "Empty";
    const kind = (tile && game.map.grid[tile?.x][tile?.y].$kind) || "None";
    const unitOptions = ["sniper", "soldier", "heavy", "barricade"];

    return (
        <div className="grid md:grid-cols-2 gap-5 items-center">
            <div className="max-md:flex max-md:flex-col gap-3 max-md:justify-center max-md:items-center">
                <div className={`${wait ? "disabled" : ""}`}>
                    <EditorMap
                        grid={game.map}
                        onSelect={(tile, x, y) => setTile({ tile, x, y })}
                        onPoint={(unit, x, y) => performAction(unit, x, y)}
                    />
                </div>
            </div>
            <div className="flex flex-col justify-center">
                <div>
                    <h2 className="text-lg my-2">Selected Tile</h2>
                    <p>Type: {!isEmpty ? kind : "None"}</p>
                    <h2 className="text-xl my-2">Tools</h2>
                    <p>
                        After selecting a tool, right click where you want to
                        apply it
                    </p>
                    <ul className="mt-2">
                        {unitOptions.map((unitOpt) => {
                            const isActive =
                                tool == "place" && inventory === unitOpt;
                            const className = isActive ? "underline" : "";

                            return (
                                <li key={unitOpt}>
                                    <button
                                        className={className}
                                        onClick={() => {
                                            setTool("place");
                                            setInventory(unitOpt);
                                        }}
                                    >
                                        Place {unitOpt}
                                    </button>
                                </li>
                            );
                        })}
                        <li key="remove">
                            <button
                                className={`${tool === "remove" ? "underline" : ""} my-1`}
                                onClick={() => setTool("remove")}
                            >
                                Remove
                            </button>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    );

    async function performAction(
        _unit: typeof Unit.$inferType | null,
        x: number,
        y: number,
    ) {
        console.log("performAction", _unit, x, y);
        console.log("tool", tool);
        console.log("inventory", inventory);
        if (tool === "place" && inventory) {
            return placeFromInventory(x, y).then(() => setWait(false));
        }

        if (tool === "remove") {
            return removeUnit(x, y).then(() => setWait(false));
        }
    }

    async function removeUnit(x: number, y: number) {
        if (!zkLogin.address) return;
        if (!game) return;
        setWait(true);

        const tx = new Transaction();
        tx.moveCall({
            target: `${packageId}::commander::remove_unit`,
            arguments: [tx.object(game.id), tx.pure.u16(x), tx.pure.u16(y)],
        });

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        refetch();
    }

    async function placeFromInventory(x: number, y: number) {
        if (!zkLogin.address) return;
        if (!game) return;
        setWait(true);

        let unit;
        const tx = new Transaction();
        const team = tx.moveCall({
            target: `${packageId}::commander::team_neutral`,
        });

        if (inventory == "soldier") {
            unit = tx.moveCall({ target: `${packageId}::unit::soldier` });
        }

        if (inventory == "sniper") {
            unit = tx.moveCall({ target: `${packageId}::unit::sniper` });
        }

        if (inventory == "barricade") {
            unit = tx.moveCall({ target: `${packageId}::unit::barricade` });
        }

        if (inventory == "heavy") {
            unit = tx.moveCall({ target: `${packageId}::unit::heavy` });
        }

        if (!unit) return console.log("unit not found");

        tx.moveCall({
            target: `${packageId}::commander::place_unit`,
            arguments: [
                tx.object(game.id),
                tx.pure.u16(x),
                tx.pure.u16(y),
                unit,
                team,
            ],
        });

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        refetch();
    }
}
