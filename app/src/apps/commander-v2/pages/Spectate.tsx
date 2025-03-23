// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useRecentGames } from "../hooks/useRecentGames";
import { useState } from "react";
import { formatAddress } from "@mysten/sui/utils";
import { useGame } from "../hooks/useGame";
import { Footer, Loader } from "./Components";
import { NavLink } from "react-router-dom";

export function Spectate() {
    const { data: games } = useRecentGames({});
    const [selected, setSelected] = useState<string>();
    const { data: game } = useGame({ id: selected!, enabled: !!selected });

    if (!games) return "loading...";
    if (games.length === 0) return "no games found";

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left p-10">
                <h1 className="block p-1 mb-10 page-heading">SPECTATE</h1>
                <div className="flex justify-start">
                    <div className="w-96 max-w-md">
                        <h2 className="mb-2">Recent games</h2>
                        {games.map((game) => {
                            return (
                                <div
                                    className={
                                        "options-row interactive " +
                                        (selected == game.id ? "selected" : "")
                                    }
                                    key={game.id}
                                    onClick={() => setSelected(game.id)}
                                >
                                    <a>{formatAddress(game.id)}</a>
                                    <p>{timeAgo(+game.timestamp_ms)}</p>
                                </div>
                            );
                        })}
                    </div>
                    {selected && !game && <Loader />}
                    {selected && (
                        <div className="size-max ml-10 max-w-3xl">
                            <div className="mb-10">
                                <h2 className="mb-2">Game</h2>
                                <div className="options-row">
                                    <div>Recruits</div>
                                    <div>{game?.map.recruits.length}</div>
                                </div>
                                <h2 className="mb-2 mt-10">History log</h2>
                                {game?.map.history.map((record, i) => (
                                    <div className="options-row flex min-w-96" key={i}>
                                        <div className="normal-case">{record.$kind}</div>
                                        <div>{JSON.stringify(record[record.$kind])}</div>
                                    </div>
                                ))}
                            </div>
                            <NavLink
                                className="block mt-10 py-2 text-center interactive w-full"
                                to={`../spectate/${selected}`}
                            >
                                spectate
                            </NavLink>
                        </div>
                    )}
                </div>
            </div>
            <Footer to=".." />
        </div>
    );
}

function timeAgo(time: number) {
    const diff = Date.now() - time;
    if (diff < 1000) return "just now";
    if (diff < 60000) return Math.floor(diff / 1000) + "s ago";
    if (diff < 3600000) return Math.floor(diff / 60000) + "m ago";
    if (diff < 86400000) return Math.floor(diff / 3600000) + "h ago";
    return Math.floor(diff / 86400000) + "d ago";
}
