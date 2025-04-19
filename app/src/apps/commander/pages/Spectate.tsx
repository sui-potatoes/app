// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useRecentGames } from "../hooks/useRecentGames";
import { useState } from "react";
import { formatAddress } from "@mysten/sui/utils";
import { useGame } from "../hooks/useGame";
import { Footer, Loader } from "./Components";
import { NavLink } from "react-router-dom";
import { timeAgo } from "../types/utils";

export function Spectate() {
    const { data: games } = useRecentGames({});
    const [selected, setSelected] = useState<string>();
    const { data: game, isFetching } = useGame({ id: selected!, enabled: !!selected });
    const [historyDirection, setHistoryDirection] = useState<"up" | "down">("down");

    if (!games) return <Loader text="fetching recent games" />;

    return (
        <div className="flex justify-between align-middle h-screen flex-col w-full">
            <div className="text-left p-10">
                <h1 className="block p-1 mb-10 page-heading">SPECTATE</h1>
                <div className="flex justify-start">
                    <div className="w-96 max-w-md">
                        <h2 className="mb-2">Currently playing</h2>
                        <div style={{ maxHeight: "40vh" }}>
                            {!games.length ? (
                                <p>No games are played at the moment</p>
                            ) : (
                                games
                                    .slice()
                                    .reverse()
                                    .map((game) => {
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
                                    })
                            )}
                        </div>
                    </div>
                    {selected && (
                        <div
                            className="ml-10 w-full max-w-3xl overflow-auto"
                            style={{ maxHeight: "80vh" }}
                        >
                            <div className="mb-10 mx-2">
                                <h2 className="mb-2">Game</h2>
                                <div className="">
                                    {/* {!isFetching ? " animate-fade-in" : ""}> */}
                                    <div className="options-row">
                                        <div>Recruits</div>
                                        <div className={!isFetching ? " animate-fade-in" : ""}>
                                            {game?.map.recruits.length}
                                        </div>
                                    </div>
                                    <div className="options-row w-full">
                                        <div>Size</div>
                                        <div className={!isFetching ? " animate-fade-in" : ""}>
                                            {game &&
                                                `${game?.map.map.grid.length}x${game?.map.map.grid[0].length}`}
                                        </div>
                                    </div>
                                    <NavLink
                                        className="block mt-10 py-2 text-center interactive w-full"
                                        to={`../spectate/${selected}`}
                                    >
                                        spectate
                                    </NavLink>

                                    {/* rotate circle symbol unicode */}
                                    <div className="flex justify-between mb-2 mt-10">
                                        <h2>History log</h2>
                                        {/* up and down arrow symbols */}
                                        <div
                                            className="hover:cursor-pointer"
                                            onClick={() =>
                                                setHistoryDirection(
                                                    historyDirection === "up" ? "down" : "up",
                                                )
                                            }
                                        >
                                            {historyDirection === "up" ? (
                                                <>&#x25B2;</>
                                            ) : (
                                                <>&#x25BC;</>
                                            )}
                                        </div>
                                    </div>

                                    <div
                                        className={`overflow-auto${!isFetching ? " animate-fade-in" : ""}`}
                                        style={{ maxHeight: "40vh" }}
                                    >
                                        {(historyDirection === "up"
                                            ? game?.map.history.reverse()
                                            : game?.map.history
                                        )?.map((record, i) => (
                                            <div className="options-row flex w-full" key={i}>
                                                <div className="normal-case mr-10">
                                                    {record.$kind}
                                                </div>
                                                <div>
                                                    {record.$kind === "UnitKIA"
                                                        ? formatAddress(record.UnitKIA)
                                                        : JSON.stringify(record[record.$kind])}
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                </div>
                            </div>
                        </div>
                    )}
                </div>
            </div>
            <Footer to=".." />
        </div>
    );
}
