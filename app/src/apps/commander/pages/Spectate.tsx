// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import { useRecentGames } from "../hooks/useRecentGames";
import { useState } from "react";
import { formatAddress } from "@mysten/sui/utils";
import { useGame } from "../hooks/useGame";
import { usePreset } from "../hooks/usePreset";
import { GameScreen, Loader } from "./Components";
import { NavLink } from "react-router-dom";
import { timeAgo } from "../types/utils";

/**
 * Show the list of currently played games which were registered in the recent
 * games list. Commander only stores up to 20 recent games, and some may not be
 * cleaned up when the game is over.
 *
 * When a game is selected, it will be shown in the `SelectedMap` component.
 */
export function Spectate() {
    const { data: games } = useRecentGames({});
    const [selected, setSelected] = useState<string>();

    if (!games) return <Loader text="fetching recent games" />;

    return (
        <GameScreen title="spectate">
            <div className="w-xl">
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
            {selected && <SelectedMap id={selected} />}
        </GameScreen>
    );
}

/**
 * Show the details of a selected game in a panel on the right side.
 */
function SelectedMap({ id }: { id: string }) {
    const { data: game, isFetching: isFetchingGame } = useGame({ id });
    const { data: preset, isFetching: isFetchingPreset } = usePreset({
        id: game?.map.map.id || null,
        enabled: !!game,
    });

    const [historyDirection, setHistoryDirection] = useState<"up" | "down">("down");

    return (
        <div className="ml-10 w-full max-w-3xl overflow-auto" style={{ maxHeight: "80vh" }}>
            <div className="mb-10 mx-2">
                <h2 className="mb-2">Game</h2>
                <div className="">
                    <div className="options-row">
                        <div>Recruits</div>
                        <div className={!isFetchingGame ? " animate-fade-in" : ""}>
                            {game?.map.recruits.length}
                        </div>
                    </div>
                    <div className="options-row w-full">
                        <div>Size</div>
                        <div className={!isFetchingGame ? " animate-fade-in" : ""}>
                            {game && `${game?.map.map.grid.length}x${game?.map.map.grid[0].length}`}
                        </div>
                    </div>
                    <div className="options-row w-full">
                        <div>Map</div>
                        <div className={!isFetchingPreset ? " animate-fade-in" : ""}>
                            {preset?.name || "..."}
                        </div>
                    </div>
                    <NavLink
                        className="block mt-10 py-2 text-center interactive w-full"
                        to={`../spectate/${id}`}
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
                                setHistoryDirection(historyDirection === "up" ? "down" : "up")
                            }
                        >
                            {historyDirection === "up" ? <>&#x25B2;</> : <>&#x25BC;</>}
                        </div>
                    </div>

                    <div
                        className={`overflow-auto${!isFetchingGame ? " animate-fade-in" : ""}`}
                        style={{ maxHeight: "40vh" }}
                    >
                        {(historyDirection === "up"
                            ? game?.map.history.reverse()
                            : game?.map.history
                        )?.map((record, i) => (
                            <div className="options-row flex w-full" key={i}>
                                <div className="normal-case mr-10">{record.$kind}</div>
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
    );
}
