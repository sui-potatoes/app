// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useZkLogin } from "@mysten/enoki/react";
import { useNetworkVariable } from "../../../networkConfig";
import { formatAddress, fromBase64 } from "@mysten/sui/utils";
import { SuiObjectRef } from "@mysten/sui/client";
import { NavLink } from "react-router-dom";
import { Replay } from "../types/bcs";
import { useGameTransactions } from "../hooks/useGameTransactions";
import { Loader, GameScreen } from "./Components";

export type Replay = typeof Replay.$inferType & SuiObjectRef;

export function Replays() {
    const zkLogin = useZkLogin();
    const packageId = useNetworkVariable("commanderV2PackageId");
    const { deleteReplay, canTransact } = useGameTransactions({ map: null });
    const { data: replays, refetch } = useSuiClientQuery(
        "getOwnedObjects",
        {
            owner: zkLogin.address!,
            filter: { StructType: `${packageId}::replay::Replay` },
            options: { showBcs: true },
        },
        {
            enabled: !!zkLogin.address,
            select(data): Replay[] {
                if (!data.data) return [];
                return data.data
                    .map((obj) => {
                        if (!obj.data) return null;
                        if (!obj.data.bcs) return null;
                        if (obj.data.bcs.dataType !== "moveObject") return null;

                        const bytes = fromBase64(obj.data.bcs.bcsBytes);
                        const replay = Replay.parse(bytes);
                        return {
                            id: replay.id,
                            presetId: replay.presetId,
                            history: replay.history,
                            objectId: obj.data.objectId,
                            version: obj.data.version,
                            digest: obj.data.digest,
                        };
                    })
                    .filter((r) => r !== null);
            },
        },
    );

    if (!replays) return <Loader text="Fetching replays..." />;

    return (
        <GameScreen
            title={
                <>
                    <NavLink to="../play">PLAY</NavLink> / replays
                </>
            }
            footerTo="../play"
        >
            <div className="pl-10 max-w-2xl">
                <h2 className="mb-2">REPLAYS</h2>
                <div className="overflowing">
                    {replays.length === 0 && (
                        <div>
                            No replays found. <br />
                            Replays can be saved after a game is finished.
                        </div>
                    )}
                    {replays?.map((replay) => (
                        <div className="options-row interactive w-full">
                            <a>
                                {formatAddress(replay.objectId)} ({replay.history.length} actions)
                            </a>
                            <div className="flex gap-2">
                                <button className="px-4 w-full">
                                    <NavLink to={`../watch/${replay.objectId}`}>Watch</NavLink>
                                </button>
                                <button className="px-4 w-full">
                                    <a
                                        onClick={() =>
                                            canTransact &&
                                            confirm("Are you sure? This is irreversible action!") &&
                                            deleteReplay(replay.objectId).then(() => {
                                                setTimeout(() => refetch(), 1000);
                                            })
                                        }
                                    >
                                        Delete
                                    </a>
                                </button>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </GameScreen>
    );
}
