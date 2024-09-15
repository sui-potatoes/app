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

export function Editor({ game, refetch }: Props) {
    const zkLogin = useZkLogin();
    const flow = useEnokiFlow();
    const client = useSuiClient();
    const packageId = useNetworkVariable("commanderPackageId");

    // const [action, selectAction] = useState<SelectedAction | null>(null);
    const [tile, setTile] = useState<SelectedTile | null>(null);
    const [inventory, setInventory] = useState<string>();
    const [wait, setWait] = useState(false);

    const isEmpty = tile && game.map.grid[tile?.x][tile?.y].$kind === "Empty";
    const kind = tile && game.map.grid[tile?.x][tile?.y].$kind;
    const unitOptions = ["sniper", "soldier", "barricade"];

    return (
        <div className="grid grid-cols-6">
            <div className="col-span-4">
                <div className={`${wait ? "disabled" : ""}`}>
                    <EditorMap
                        grid={game.map}
                        onSelect={(tile, x, y) => setTile({ tile, x, y })}
                        onPoint={(_unit, _x, _y) => {}}
                    />
                </div>
            </div>
            <div className="col-span-1">
                <div>
                    <h2>Selected Tile</h2>
                    <p>Type: {!isEmpty ? kind : "None"}</p>
                    <h2>Actions</h2>
                    <h2>Inventory</h2>
                    <select className="mb-4 w-full" onChange={(e) => setInventory(e.target.value)}>
                        {unitOptions.map((unit) => (
                            <option key={unit} value={unit}>
                                {unit}
                            </option>
                        ))}
                    </select>
                    {!isEmpty && (
                        <button
                            onClick={() =>
                                confirm(
                                    "Are you sure you want to remote this unit?",
                                ) && setTile(null)
                            }
                        >
                            Remove
                        </button>
                    )}
                    {isEmpty && inventory && (
                        <button
                            onClick={() => placeFromInventory().then(() => setWait(false))}
                        >Place</button>
                    )}
                </div>
            </div>
        </div>
    );

    async function placeFromInventory() {
        if (!zkLogin.address) return;
        if (!tile) return;
        if (!game) return;
        setWait(true);

        let unit;
        const tx = new Transaction();
        const team = tx.moveCall({ target: `${packageId}::commander::team_neutral` });

        if (inventory == "soldier") {
            unit = tx.moveCall({ target: `${packageId}::unit::soldier` });
        }

        if (inventory == "sniper") {
            unit = tx.moveCall({ target: `${packageId}::unit::sniper` });
        }

        if (inventory == "barricade") {
            unit = tx.moveCall({ target: `${packageId}::unit::barricade` });
        }

        if (!unit) return console.log("unit not found");

        tx.moveCall({
            target: `${packageId}::commander::place_unit`,
            arguments: [
                tx.object(game.id),
                tx.pure.u16(tile.x),
                tx.pure.u16(tile.y),
                unit,
                team
            ]
        });

        await client.signAndExecuteTransaction({
            signer: await flow.getKeypair({ network: "testnet" }),
            requestType: "WaitForLocalExecution",
            transaction: tx as any,
        });

        refetch();
    }
}
