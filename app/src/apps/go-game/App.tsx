// Copyright (c) Sui Potatoes
// SPDX-License-Identifier: MIT

import "./go-game.css";
import { Board } from "./Board";
import { useState, useEffect } from "react";
import { useEnokiFlow, useZkLogin } from "@mysten/enoki/react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { formatAddress } from "@mysten/sui/utils";
import { toast } from "react-hot-toast";
import { GO_BACK_KEY } from "../../App";
import { useNetworkVariable } from "../../networkConfig";
import { useAccount } from "./hooks/useAccount";
import { useGame } from "./hooks/useGame";
import { useMyGames } from "./hooks/useMyGames";
import { useOpenGames } from "./hooks/useOpenGames";
import { useGameActions } from "./hooks/useGameActions";

const BOARD_SIZES = [9, 13, 19];

const DEMO_BOARD = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 0, 0, 2, 0, 0, 0],
    [0, 0, 1, 0, 1, 0, 0, 0, 2, 0, 2, 0, 0],
    [0, 1, 0, 1, 0, 0, 0, 0, 0, 2, 0, 2, 0],
    [0, 0, 1, 0, 1, 1, 0, 0, 2, 0, 2, 0, 0],
    [0, 0, 0, 1, 0, 1, 0, 2, 0, 2, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 1, 0, 2, 0, 2, 0, 0, 0],
    [0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 2, 0, 0],
    [0, 1, 0, 1, 0, 2, 0, 2, 0, 2, 0, 2, 0],
    [0, 0, 1, 0, 0, 0, 2, 0, 2, 0, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 0, 2, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
];

function timeAgo(ms: number): string {
    const diff = Date.now() - ms;
    const minutes = Math.floor(diff / 60000);
    if (minutes < 1) return "just now";
    if (minutes < 60) return `${minutes}m ago`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}h ago`;
    return `${Math.floor(hours / 24)}d ago`;
}

export default function App() {
    const { id: gameId } = useParams();

    if (!gameId) return <Lobby />;
    return <GameView gameId={gameId} />;
}

// ─── Lobby ────────────────────────────────────────────────────────────────────

function Lobby() {
    const navigate = useNavigate();
    const flow = useEnokiFlow();
    const zkLogin = useZkLogin();
    const packageId = useNetworkVariable("goPackageId");

    const { data: account, refetch: refetchAccount } = useAccount(
        packageId,
        zkLogin.address ?? undefined,
    );
    const { data: openGames = [] } = useOpenGames(packageId, account?.id, !!zkLogin.address);
    const { data: myGamesDetails = {} } = useMyGames(account?.games as string[] | undefined);
    const actions = useGameActions();

    const [busy, setBusy] = useState(false);

    if (!zkLogin.address) {
        return (
            <div className="flex items-center justify-center relative md:h-[calc(100vh-40px)]">
                <Board
                    disabled
                    size={13}
                    data={DEMO_BOARD}
                    lastMove={{ x: 10, y: 8 }}
                    turn={1}
                    onClick={() => {}}
                />
                <div
                    className="absolute inset-0 z-10 flex items-center justify-center backdrop-blur-sm"
                    style={{
                        background:
                            "color-mix(in srgb, var(--background-color) 80%, transparent)",
                    }}
                >
                    <p
                        className="text-sm tracking-wider uppercase"
                        style={{ color: "var(--text-color)" }}
                    >
                        <button
                            style={{ color: "var(--accent-color)", textTransform: "uppercase" }}
                            onClick={signIn}
                        >
                            Sign in
                        </button>{" "}
                        to play
                    </p>
                </div>
            </div>
        );
    }

    return (
        <div className="flex flex-col gap-3 justify-center md:h-[calc(100vh-40px)] text-sm uppercase tracking-wider">
            <div className="flex flex-col md:flex-row gap-8">
                <div className="flex flex-col gap-3">
                    <div>My Games</div>
                    {!account || !(account.games as string[]).length ? (
                        <p style={{ color: "var(--text-secondary)" }}>No games yet</p>
                    ) : (
                        <ul className="my-games">
                            {(account.games as string[]).map((id, i) => {
                                const details = myGamesDetails[id];
                                return (
                                    <li key={`game-${i}`} className="flex items-baseline gap-3">
                                        <Link to={`/go/${id}`}>{formatAddress(id)}</Link>
                                        {details && (
                                            <span
                                                style={{
                                                    color: "var(--text-secondary)",
                                                    fontSize: "11px",
                                                }}
                                            >
                                                {details.board.size}×{details.board.size} ·{" "}
                                                {details.players.player1 === details.players.player2 ? "S" : "M"} ·{" "}
                                                {timeAgo(Number(details.created_at))}
                                            </span>
                                        )}
                                    </li>
                                );
                            })}
                        </ul>
                    )}
                </div>
                <div
                    className="flex flex-col gap-3 md:border-l md:pl-8"
                    style={{ borderColor: "var(--border-color)" }}
                >
                    <div>Open Games</div>
                    {openGames.length === 0 ? (
                        <p style={{ color: "var(--text-secondary)" }}>No open games</p>
                    ) : (
                        <ul className="my-games">
                            {openGames.map((g) => (
                                <li key={g.id} className="flex items-baseline gap-3">
                                    <Link to={`/go/${g.id}`}>{formatAddress(g.id)}</Link>
                                    <span
                                        style={{ color: "var(--text-secondary)", fontSize: "11px" }}
                                    >
                                        {g.size}×{g.size} · {timeAgo(g.timestampMs)}
                                    </span>
                                </li>
                            ))}
                        </ul>
                    )}
                </div>
            </div>
            <div className="pt-3">
                <div className="divider w-[200px] mb-4" />
                <div>
                    NEW GAME:{" "}
                    {BOARD_SIZES.map((size, i) => (
                        <span key={size}>
                            <button
                                disabled={busy}
                                onClick={() => handleNewGame(size)}
                                style={{ textTransform: "uppercase", color: "var(--accent-color)" }}
                            >
                                {size}x{size}
                            </button>
                            {i < BOARD_SIZES.length - 1 && " / "}
                        </span>
                    ))}
                </div>
            </div>
            {busy && <div className="spinner" />}
        </div>
    );

    async function signIn() {
        localStorage.setItem(GO_BACK_KEY, window.location.href);
        history.pushState({}, "", "/");
        window.location.href = await flow.createAuthorizationURL({
            provider: "google",
            clientId: "591411088609-6kbt6b07a6np6mq2mnlq97i150amussh.apps.googleusercontent.com",
            redirectUrl: window.location.href.split("#")[0],
            network: "testnet",
        });
    }

    async function handleNewGame(size: number) {
        setBusy(true);
        try {
            const newGameId = await actions.newGame(account ?? null, size);
            if (newGameId) {
                await toast.success("Game created!");
                await refetchAccount();
                navigate(`/go/${newGameId}`);
            }
        } finally {
            setBusy(false);
        }
    }
}

// ─── Game view ────────────────────────────────────────────────────────────────

function GameView({ gameId }: { gameId: string }) {
    const packageId = useNetworkVariable("goPackageId");
    const zkLogin = useZkLogin();

    const { data: account, refetch: refetchAccount } = useAccount(
        packageId,
        zkLogin.address ?? undefined,
    );
    const { data: game, refetch: refetchGame } = useGame(gameId);
    const actions = useGameActions();
    const navigate = useNavigate();

    const [busy, setBusy] = useState(false);
    const [boardData, setBoardData] = useState<number[][]>(Array(9).fill(Array(9).fill(0)));
    const [isBlackTurn, setIsBlackTurn] = useState(true);

    // Sync board state from on-chain data, preserving optimistic updates until confirmed
    useEffect(() => {
        if (game) {
            setBoardData(game.board.grid.grid);
            setIsBlackTurn(game.board.is_black);
        }
    }, [game]);

    console.log(game);

    if (!game) return null;

    const players = [game.players.player1, game.players.player2].filter(Boolean) as string[];
    const isSolo = game.players.player1 === game.players.player2;
    const isMyGame = account ? players.includes(account.id) : false;
    const myColor = game.players.player1 === account?.id ? "Black" : "White";
    const currentTurn = isBlackTurn ? "Black" : "White";
    const isMyTurn = isMyGame && (isSolo || myColor === currentTurn);
    const moves = game.board.moves;
    const lastMove = moves.length ? moves[moves.length - 1] : undefined;
    const size = game.board.size as 9 | 13 | 19;

    return (
        <div className="flex max-md:flex-col max-md:items-center items-center md:h-[calc(100vh-40px)] md:gap-5">
            <div className="max-md:w-full md:flex-1 flex items-center justify-center relative">
                <Board
                    disabled={busy || !isMyTurn || players.length < 2}
                    size={size}
                    data={boardData}
                    lastMove={lastMove ? { x: lastMove.row, y: lastMove.column } : undefined}
                    turn={(isBlackTurn ? 1 : 2) as 1 | 2}
                    onClick={handlePlay}
                />
                {game.is_over && (
                    <div
                        className="absolute inset-0 z-10 flex flex-col gap-3 items-center justify-center backdrop-blur-sm"
                        style={{
                            background:
                                "color-mix(in srgb, var(--background-color) 80%, transparent)",
                        }}
                    >
                        <p
                            className="text-sm tracking-wider uppercase"
                            style={{ color: "var(--text-secondary)" }}
                        >
                            Opponent left the game
                        </p>
                        {isMyGame && (
                            <button
                                disabled={busy}
                                onClick={handleEnd}
                                style={{ color: "var(--accent-color)", textTransform: "uppercase" }}
                            >
                                Wrap Up
                            </button>
                        )}
                    </div>
                )}
                {!game.is_over && players.length < 2 && (
                    <div
                        className="absolute inset-0 z-10 flex flex-col gap-3 items-center justify-center backdrop-blur-sm"
                        style={{
                            background:
                                "color-mix(in srgb, var(--background-color) 80%, transparent)",
                        }}
                    >
                        <p
                            className="text-sm tracking-wider uppercase"
                            style={{ color: "var(--text-secondary)" }}
                        >
                            Waiting for players
                        </p>
                        <button
                            disabled={busy}
                            onClick={handleJoin}
                            style={{ color: "var(--accent-color)", textTransform: "uppercase" }}
                        >
                            {isMyGame ? "Play Solo" : `Join? ${!account ? "(Sign in first)" : ""}`}
                        </button>
                    </div>
                )}
            </div>
            <div className="flex flex-col gap-3 justify-center text-sm uppercase tracking-wider text-left items-start md:w-[170px] md:flex-shrink-0">
                <p style={{ color: "var(--text-secondary)" }}>
                    {isMyGame && isSolo
                        ? `${currentTurn} turn`
                        : isMyGame && players.length === 2
                          ? isMyTurn
                              ? "Your turn"
                              : "Opponent's turn"
                          : ""}
                </p>
                {busy && <div className="spinner" />}
                <div className="divider w-[150px]" />
                <div className="flex flex-col gap-3">
                    <a
                        href={`https://suiscan.xyz/testnet/object/${game.id}`}
                        target="_blank"
                        style={{ textTransform: "uppercase" }}
                    >
                        Game (Explorer)
                    </a>
                    {isMyGame && (
                        <button disabled={busy} className="text-left" style={{ textTransform: "uppercase" }} onClick={handleEnd}>
                            Quit / End Game
                        </button>
                    )}
                </div>
            </div>
        </div>
    );

    async function handlePlay(x: number, y: number) {
        if (busy || !isMyTurn || boardData[x][y] !== 0 || !account || !game) return;
        setBusy(true);
        try {
            await actions.play(game, account, x, y, (updated) => {
                setBoardData(updated.board.grid.grid);
                setIsBlackTurn(updated.board.is_black);
                setBusy(false);
            });
            await refetchGame();
        } finally {
            setBusy(false);
        }
    }

    async function handleJoin() {
        setBusy(true);
        try {
            await actions.joinGame(game!, account ?? null);
            await refetchAccount();
            await refetchGame();
        } finally {
            setBusy(false);
        }
    }

    async function handleEnd() {
        if (!account) return;
        setBusy(true);
        try {
            await actions.endGame(game!, account);
            navigate("/go");
        } finally {
            setBusy(false);
        }
    }
}
