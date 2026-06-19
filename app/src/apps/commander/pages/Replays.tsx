// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useCurrentAccount } from "@mysten/dapp-kit-react";
import { formatAddress } from "@mysten/sui/utils";
import { NavLink } from "react-router-dom";
import { COMMANDER_V2_PACKAGE_ID } from "../../../constants";
import { useOwnedBcsObjects, WithRef } from "../../../hooks/useBcsObjects";
import { Replay as ReplayBcs } from "../types/bcs";
import { useGameTransactions } from "../hooks/useGameTransactions";
import { Footer, Loader } from "./Components";

export type Replay = WithRef<typeof ReplayBcs.$inferType>;

export function Replays() {
    const address = useCurrentAccount()?.address;
    const { deleteReplay, canTransact } = useGameTransactions({ map: null });
    const { data: replays, refetch } = useOwnedBcsObjects({
        owner: address,
        type: `${COMMANDER_V2_PACKAGE_ID}::replay::Replay`,
        schema: ReplayBcs,
    });

    if (!replays) return <Loader text="Fetching replays..." />;

    return (
        <div className="flex justify-between flex-col w-full">
            <div className="p-10 max-w-xl">
                <h1 className="p-1 mb-10 page-heading">
                    <NavLink to="../play">PLAY</NavLink> / replays
                </h1>
            </div>
            <div className="p-10 max-w-3xl">
                {replays.length === 0 && (
                    <div>
                        No replays found. <br />
                        Replays can be saved after a game is finished.
                    </div>
                )}
                {replays.map((replay) => (
                    <div key={replay.objectId} className="options-row interactive w-full">
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
            <Footer to="../play" />
        </div>
    );
}
